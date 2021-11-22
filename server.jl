import Sockets

const PORT = 50000

function try_send(socket, message)
    try
        println(socket, message)
    catch error
        println(error)
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

function start_server(port)
    room = Set{Sockets.TCPSocket}()

    server = Sockets.listen(port)
    println("server started listening")

    while true
        socket = Sockets.accept(server)
        socket_id = hash(socket)
        println("socket_id $(socket_id) accepted")

        @async begin
            try_send(socket, "Enter a nickname")
            nickname = readline(socket)

            if occursin(r"^[A-Za-z0-9_]{1,32}$", nickname)
                push!(room, socket)
                try_broadcast(room, "$(nickname) has entered the room")

                while isopen(socket) && !eof(socket)
                    message = readline(socket)
                    try_broadcast(room, "$(nickname): $(message)")
                end

                pop!(room, socket)
                try_broadcast(room, "$(nickname) has left the room")
            else
                try_send(socket, "ERROR: invalid nickname")
                close(socket)
            end
        end

        @assert !isopen(socket) "socket must not be open at this point!"
        println("socket_id $(socket_id) disconnected")
    end

    return nothing
end

start_server(PORT)
