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
    for socket in room
        try_send(socket, message)
    end

    return nothing
end

function start_server(server_host, server_port)
    room = Set{Sockets.TCPSocket}()

    server = Sockets.listen(server_host, server_port)
    @info "server started listening"

    while true
        socket = Sockets.accept(server)
        socket_id = hash(socket)
        @info "socket_id $(socket_id) accepted"

        @async begin
            try_send(socket, "Enter a nickname")
            nickname = readline(socket)

            if occursin(r"^[A-Za-z0-9_]{1,32}$", nickname)
                push!(room, socket)
                try_broadcast(room, "$(nickname) has entered the room")

                while !eof(socket)
                    message = readline(socket)
                    try_broadcast(room, "$(nickname): $(message)")
                end

                close(socket)
                pop!(room, socket)
                try_broadcast(room, "$(nickname) has left the room")
            else
                try_send(socket, "ERROR: invalid nickname")
                close(socket)
            end

            @info "socket_id $(socket_id) disconnected"
        end
    end

    return nothing
end

start_server(SERVER_HOST, SERVER_PORT)
