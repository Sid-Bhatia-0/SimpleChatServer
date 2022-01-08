import Sockets

const SERVER_HOST = Sockets.localhost # Sockets.ip"127.0.0.1"
const SERVER_PORT = 50000

function try_send(socket, message)
    try
        println(socket, message)
    catch error
        @error error
        close(socket)
    end

    return nothing
end

function try_broadcast(room, message)
    @info message

    for socket in room
        try_send(socket, message)
    end

    return nothing
end

function start_server(server_host, server_port)
    room = Set{Sockets.TCPSocket}()

    room_lock = ReentrantLock()

    server = Sockets.listen(server_host, server_port)
    @info "server started listening"

    while true
        socket = Sockets.accept(server)

        peername = Sockets.getpeername(socket)
        @info "(peername = $(peername)) socket accepted"

        @async begin
            try_send(socket, "Enter a nickname")
            nickname = readline(socket)

            if occursin(r"^[A-Za-z0-9]{1,32}$", nickname)
                user_entry_message = "[$(nickname) has entered the room]"
                lock(room_lock) do
                    push!(room, socket)
                    try_broadcast(room, user_entry_message)
                end

                while !eof(socket)
                    message = readline(socket)
                    if all(char -> isprint(char) && isascii(char), message)
                        broadcast_message = "$(nickname): $(message)"
                        lock(room_lock) do
                            try_broadcast(room, broadcast_message)
                        end
                    else
                        @info "(peername = $(peername)) invalid message"
                        try_send(socket, "[ERROR: message must be composed only of printable ascii characters]")
                        close(socket)
                        break
                    end
                end

                close(socket)

                user_exit_message = "[$(nickname) has left the room]"
                lock(room_lock) do
                    pop!(room, socket)
                    try_broadcast(room, user_exit_message)
                end
            else
                @info "(peername = $(peername)) invalid nickname"
                try_send(socket, "[ERROR: nickname must be composed only of a-z, A-Z, and 0-9 and its length must be between 1 to 32 characters (both inclusive)]")
                close(socket)
            end

            @info "(peername = $(peername)) socket disconnected"
        end
    end

    return nothing
end

start_server(SERVER_HOST, SERVER_PORT)
