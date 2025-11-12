
using Sockets
const D = Device = TCPSocket


function send(socket::TCPSocket,msg::String)
    write(socket,codeunits(msg))
end

function recv(socket::TCPSocket)
    refreshBuffer(socket)
    return readavailable(socket)
end

function recv(socket::TCPSocket,nb::Integer)
    refreshBuffer(socket)
    return read(socket,nb)
end


function getBufferSize(socket::TCPSocket)
    return socket.buffer.size
end

function refreshBuffer(socket::TCPSocket)
    @async eof(socket)

    return
end

function clearBuffer(socket::TCPSocket)
    socket.buffer.size = 0
    socket.buffer.ptr = 1

    return
end

function isBlocked(socket::TCPSocket)
    refreshBuffer(socket)

    return getBufferSize(socket) == 0
end


function async_reader(socket::TCPSocket,timeout::Real=1)
    c = Channel{String}(1)
    task = @async begin
        reader_task = current_task()

        function timeout_cb(timer)
            put!(c,"")
            Base.throwto(reader_task, InterruptException())
        end

        to = Timer(timeout_cb, timeout)
        str = String(readavailable(socket))
        timeout > 0 && close(to)
        put!(c,str)
    end

    bind(c,task)

    return take!(c)
end

function arecv(socket::TCPSocket,timeout::Real=1)
    refreshBuffer(socket)    
    return async_reader(socket,timeout)
end