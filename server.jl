import Sockets

function start(port)
    sockets = Sockets.TCPSocket[]
    server = Sockets.listen(port)

    task = @async while true
        socket = Sockets.accept(server)

        i = findfirst(!isopen, sockets)

        if isnothing(i)
            push!(sockets, socket)
            client_id = length(sockets)
        else
            sockets[i] = socket
            client_id = i
        end

        println("New client: $(client_id)")

        @async while isopen(socket)
            try
                line = readline(socket)
                if line != ""
                    println("Client $(client_id) wants to broadcast $(line)")
                    for socket_receiver in sockets
                        if isopen(socket_receiver)
                            try
                                println(socket_receiver, line)
                            catch error
                                println(error)
                                close(socket_receiver)
                            end
                        end
                    end
                end
            catch error
                println(error)
                close(socket_sender)
            end
        end
    end

    wait(task)

    return nothing
end

start(2001)
