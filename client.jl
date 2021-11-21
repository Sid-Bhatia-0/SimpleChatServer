import Sockets

const PORT = 50000

function start(port)
    socket = Sockets.connect(port)

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

start(PORT)
