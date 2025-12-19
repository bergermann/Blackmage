

"One interferometer unit: 32_768 pm"
global const ids_res = 32.768e-9

"Distance unit factors"
const units = Base.ImmutableDict(
    :m => 1.,
    :cm => 1e-2,
    :mm => 1e-3,
    :µm => 1e-6,
    :nm => 1e-9,
    :pm => 1e-12,
)

"""
    metric2ids(val::Real,unit::Symbol; offset::Int=4_500_000)

Convert metric distance to interferometer distance units. `offset` interferometer units 
are added to avoid negative values. `-offset*ids_res` is the minimum metric distance
allowed. `offset` is a hard setting on the datalink (ask Christoph if this needs changed).
"""
function metric2ids(val::Real,unit::Symbol; offset::Int=4_500_000)
    @assert haskey(units,unit) "$unit not available as unit, pick: m, cm, mm, µm, nm"
    
    return round(Int,val*units[unit]/ids_res+offset)
end

metric2ids((val,unit)::Tuple{Real,Symbol}) = metric2ids(val,unit)



"""
    mcRequest(device::TCPSocket,command::String)

Send `command` as bytestring (BYTE-STRING, not BY-TEST-RING, Béla) to motor controller device. 
"""
function mcRequest(device::TCPSocket,command::String)
    @assert isopen(device) "TCP port is not open."
    
    send(device,command*"\r\n")

    return strip(arecv(device),('\r','\n'))
end



include("system.jl")
include("motor_control_OL.jl")
include("motor_control_CL.jl")
include("motor_control_FL.jl")


