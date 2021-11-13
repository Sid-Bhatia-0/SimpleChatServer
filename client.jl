import Sockets

function start(port)
    socket = Sockets.connect(2001)

    @async while isopen(socket) && !eof(socket)
        println(stdout, readline(socket))
    end

    while isopen(socket)
        line = readline(stdin)
        try
            println(socket, line)
        catch error
            println(error)
            close(socket)
        end
    end

    return nothing
end

start(2001)
