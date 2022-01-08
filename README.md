# ChatServer

This is a simple chat server written in Julia. It uses TCP sockets to communicate messages between a server and multiple clients.

### Getting Started

Follow these steps to test the chat server on you localhost:

1. Clone the project

    ```
    $ git clone https://github.com/Sid-Bhatia-0/ChatServer
    ```

1. Go inside the project directory (`ChatServer`) and start the Julia REPL

    ```
    $ julia
    ```

1. Activate and instantiate the project from the Julia REPL

    ```
    julia> import Pkg; Pkg.activate("."); Pkg.instantiate()
    ```

    This might take some time. This will generate a `Manifest.toml` file inside the directory.

1. Exit the REPL

1. Run `server.jl` in your terminal
    ```
    $ julia --project=. server.jl
    ```

    Wait for the server to acknowldege that it has started listening.

1. Run `client.jl` in a few different terminals and start chatting.
    ```
    $ julia --project=. client.jl
    ```

    You will be prompted to enter a nickname. The nickname must be composed only of a-z, A-Z, and 0-9, and its length must be between 1 to 32 characters (both inclusive).

Clients may come and go, while the server will keep running. Press `Ctrl-c` to exit the processes.
