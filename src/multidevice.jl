
export MultiDevice

struct MultiDevice
    ip_mc::Dict{Int,IPv4}
    ip_ids::Dict{Int,IPv4}
    
    mc::Dict{Int,TCPSocket}
    ids::Dict{Int,TCPSocket}

    masters::Dict{Int,Int}

    function MultiDevice(ip_mc,ip_ids,mc,ids,masters)
        @assert length(ip_mc) == length(ip_ids) == length(mc) == length(ids) == length(masters)
            "mc, ids addresses and master axes need same lengths."
        @assert all(k->(in(k,keys(ids)) && in(k,keys(masters))
                && in(k,keys(ip_mc)) && in(k,keys(ip_ids))),keys(mc))
            "mc, ids addresses and master axes need matching keys."

        new(ip_mc,ip_ids,mc,ids,masters)
    end

    function MultiDevice(ip_mc::AbstractArray{IPv4},ip_ids::AbstractArray{IPv4};
            masters=ones(Int,length(ip_mc)),port_mc::Int=2000,port_ids::Int=9090)

        @assert length(ip_mc) == length(ip_ids) == length(masters)
            "mc, ids addresses and master axes need same lengths."
        @assert all(@. 1 <= masters <= 3) "All master axes have to be 1, 2 or 3."

        new(
            Dict(i=>                   ip_mc[i] for i in eachindex(ip_mc)),
            Dict(i=>                  ip_ids[i] for i in eachindex(ip_ids)),
            Dict(i=>connect( ip_mc[i],port_mc)  for i in eachindex(ip_mc)),
            Dict(i=>connect(ip_ids[i],port_ids) for i in eachindex(ip_ids)),
            Dict(i=>                 masters[i] for i in eachindex(masters)),
        )
    end
end

const MD = MultiDevice

import Base.getindex, Base.length
Base.getindex(md::MultiDevice,idx) = (md.mc[idx],md.ids[idx])

function Base.length(md::MultiDevice)
    @assert length(md.ip_mc) == length(md.ip_ids) == length(md.mc) == length(md.ids) ==
        length(md.masters) "Length mismatch detected!"
    
    return length(md.mc)
end


include("MD/motor_control.jl")
