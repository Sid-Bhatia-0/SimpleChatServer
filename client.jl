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

function start_client(server_host, server_port)
    socket = Sockets.connect(server_host, server_port)

    @async while !eof(socket)
        println(readline(socket))
    end

    while isopen(socket)
        try_send(socket, readline())
    end

    return nothing
end

start_client(SERVER_HOST, SERVER_PORT)
