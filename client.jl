import Sockets

function start(port)
    socket = Sockets.connect(2001)

    while true
        line = readline(stdin)
        if line == "quit"
            close(socket)
            break
        else
            try
                println(socket, line)
                println(stdout, readline(socket))
            catch error
                println(error)
                break
            end
        end
    end

    return nothing
end

start(2001)
