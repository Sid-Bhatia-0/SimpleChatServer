import Sockets

const PORT = 50000

function try_send(socket, message)
    try
        println(socket, message)
    catch error
        @error error
        close(socket)
    end

    return nothing
end

function start_client(port)
    socket = Sockets.connect(port)

    @async while !eof(socket)
        println(stdout, readline(socket))
    end

    while isopen(socket)
        message = readline(stdin)
        try_send(socket, message)
    end

    return nothing
end

start_client(PORT)
