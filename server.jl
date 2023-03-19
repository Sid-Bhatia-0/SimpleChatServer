import Sockets

const SERVER_IP_ADDRESS = Sockets.localhost # Sockets.ip"127.0.0.1"
const SERVER_PORT_NUMBER = 50000

function try_send(socket, message)
    try
        println(socket, message)
    catch error
        @error error
        close(socket)
    end
end

function try_broadcast(room, message)
    for socket in room
        try_send(socket, message)
    end
end

is_valid_nickname(nickname) = occursin(r"^[A-Za-z0-9]{1,32}$", nickname)

is_valid_message(message) = !isempty(message) && all(char -> isprint(char) && isascii(char), message)

function handle_socket(room, room_lock, socket)
    peername = Sockets.getpeername(socket)
    client_ip_address = peername[1]
    client_port_number = Int(peername[2])
    @info "Socket accepted" client_ip_address client_port_number

    try_send(socket, "Enter a nickname")
    nickname = readline(socket)
    @info "Nickname entered" client_ip_address client_port_number nickname

    if is_valid_nickname(nickname)
        user_entry_message = "[$(nickname) has entered the room]"
        lock(room_lock) do
            push!(room, socket)
            @info "Broadcasting user entry message" client_ip_address client_port_number nickname message=user_entry_message
            try_broadcast(room, user_entry_message)
        end

        while !eof(socket)
            chat_message = readline(socket)
            @info "Chat message entered" client_ip_address client_port_number nickname message=chat_message

            if is_valid_message(chat_message)
                chat_message_with_nickname = "$(nickname): $(chat_message)"
                lock(room_lock) do
                    @info "Broadcasting chat message" client_ip_address client_port_number nickname message=chat_message_with_nickname
                    try_broadcast(room, chat_message_with_nickname)
                end
            else
                @info "Invalid chat message" client_ip_address client_port_number nickname message=chat_message
                try_send(socket, "[ERROR: message must be composed only of printable ascii characters]")
                close(socket)
                break
            end
        end

        user_exit_message = "[$(nickname) has left the room]"
        lock(room_lock) do
            pop!(room, socket)
            @info "Broadcasting user exit message" client_ip_address client_port_number nickname message=user_exit_message
            try_broadcast(room, user_exit_message)
        end
    else
        @info "Invalid nickname" client_ip_address client_port_number nickname
        try_send(socket, "[ERROR: nickname must be composed only of a-z, A-Z, and 0-9 and its length must be between 1 to 32 characters (both inclusive)]")
        close(socket)
    end

    @info "Socket closed" client_ip_address client_port_number nickname
end

function start_server(server_ip_address, server_port_number)
    room = Set{Sockets.TCPSocket}()

    room_lock = ReentrantLock()

    server = Sockets.listen(server_ip_address, server_port_number)
    @info "Server started listening" server_ip_address server_port_number

    while true
        socket = Sockets.accept(server)

        errormonitor(@async handle_socket(room, room_lock, socket))
    end
end

start_server(SERVER_IP_ADDRESS, SERVER_PORT_NUMBER)
