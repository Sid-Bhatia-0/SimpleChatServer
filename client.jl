import Sockets

const SERVER_IP_ADDRESS = Sockets.localhost # Sockets.ip"127.0.0.1"
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

function start_client(server_ip_address, server_port)
    socket = Sockets.connect(server_ip_address, server_port)
    sockname = Sockets.getsockname(socket)
    peername = Sockets.getpeername(socket)

    @info "Connected to server" sockname peername

    errormonitor(
        @async while !eof(socket)
            println(readline(socket))
        end
    )

    while isopen(socket)
        try_send(socket, readline())
    end

    return nothing
end

start_client(SERVER_IP_ADDRESS, SERVER_PORT)
