


struct AttoException <: Exception
    errorcode::Int
end

Base.showerror(io::IO,e::AttoException) = 
    print(io,"Device encountered error with code ",e.errorcode,".")


"""
    Displacement

Container type for writing measured interferometer position and contrast readout to, with
timestamp. If container is full, restarts overwriting from beginning.

-`Displacement(n::Integer)` Initialize with `n` slots.
"""
mutable struct Displacement
    "Position data in pm."
    dX::Matrix{Int}
    "Contrast in permille."
    dC::Matrix{Int}
    "Timestamp in ms since t0."
    dT::Vector{Int}
    "Current index, next data is written to idx+1."
    idx::Int
    "Maximum data point before overwriting old ones."
    n::Int

    "Reference time for timestamp."
    t0::DateTime

    "Control state for measuring/writing loop."
    active::Bool

    function Displacement(n::Integer)
        new(zeros(Int,3,n),zeros(Int,3,n),zeros(Int,n),0,n,now(),false)
    end
end


"""
    updateRequestID!(req::Dict)

Increment request ID by 1.
"""
function updateRequestID!(req::Dict)
    req["id"] = string(parse(Int,req["id"])+1)

    return
end

"""
    request(device::TCPSocket,req::Dict,interface::Symbol,
        method::String; params::Array=[])

Send JSON formatted command as bytestring to IDS device.
"""
function request(device::TCPSocket,req::Dict,interface::Symbol,
        method::String; params::Array=[])
    
    updateRequestID!(req)
    req["method"] = I[interface]*method
    req["params"] = params

    send(device,JSON.json(req))
    msg = JSON.parse(String(recv(device)))

    if haskey(msg,"result")
        result = msg["result"]
    elseif haskey(msg,"error")
        print(msg[error])
        throw(AttoException(-1))
    else
        display(msg)
        throw(AttoException(-2))
    end

    if result[1] != 0
        showError(device,req,result[1])
        throw(AttoException(result[1]))
    end

    return result
end


include("record.jl")

include("interfaces.jl")

include("system.jl")
include("errors.jl")

include("measurement.jl")

include("adjustment.jl")
include("pilotlaser.jl")

include("ecu.jl")
include("manual.jl")

include("access.jl")

const req = Dict(
    "jsonrpc" => "2.0",
    "method" => "",
    "id" => "0",
    "api" => "2",
    "params" => [],
)