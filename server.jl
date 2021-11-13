import Sockets

function start(port)
    server = Sockets.listen(port)

    while true
        println("listening...")
        socket = Sockets.accept(server)
        println("accepted a connection")

        while true
            try
                line = readline(socket)
                println(socket, "You said: " * line)
                println(stdout, "Client said: " * line)
            catch error
                println(error)
                close(socket)
                break
            end
        end
    end

    return nothing
end

start(2001)
