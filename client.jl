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

    return nothing
end

function start_client(server_ip_address, server_port_number)
    socket = Sockets.connect(server_ip_address, server_port_number)
    sockname = Sockets.getsockname(socket)
    client_ip_address = sockname[1]
    client_port_number = Int(sockname[2])

    @info "Connected to server" server_ip_address server_port_number client_ip_address client_port_number

    t = errormonitor(
        @async while !eof(socket)
            println(readline(socket))
        end
    )

    while isopen(socket)
        try_send(socket, readline())
    end

    wait(t)

    return nothing
end

start_client(SERVER_IP_ADDRESS, SERVER_PORT_NUMBER)
