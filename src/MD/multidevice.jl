
export MultiDevice

struct DiscSettings
    master::Int
    ess::NTuple{3,Int}
    mrss::NTuple{3,Int}
    freq::NamedTuple{master::Int64,slave::Int64}
    temp::Int
    flextol::Int
    flexdist::Int

    function DiscSettings(;
            master=1,                      
            ess=(15e-6,15e-6,15e-6),
            mrss=(5,5,5),
            freq=(master=50,slave=70),
            temp=300,
            flextol=300,
            flexdist=5000)

        new(master,ess,mrss,freq,temp,flextol,flexdist)
    end
end

const DS = DiscSettings

struct MultiDevice
    ip_mc::Dict{Int,IPv4}
    ip_ids::Dict{Int,IPv4}
    
    mc::Dict{Int,TCPSocket}
    ids::Dict{Int,TCPSocket}

    settings::Dict{Int,DiscSettings}

    function MultiDevice(ip_mc,ip_ids,mc,ids,settings)
        @assert length(ip_mc) == length(ip_ids) == length(mc) == length(ids) == length(settings)
            "mc, ids addresses and master axes need same lengths."
        @assert all(k->(in(k,keys(ids)) && in(k,keys(settings))
                && in(k,keys(ip_mc)) && in(k,keys(ip_ids))),keys(mc))
            "mc, ids addresses and master axes need matching keys."

        new(ip_mc,ip_ids,mc,ids,settings)
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
            Dict(i=>    DS(; master=masters[i]) for i in eachindex(masters)),
        )
    end
end

const MD = MultiDevice

import Base.getindex, Base.eachindex, Base.length
Base.getindex(md::MultiDevice,idx) = (mc=md.mc[idx],ids=md.ids[idx])
Base.eachindex(md::MultiDevice) = eachindex(md.mc)

function Base.length(md::MultiDevice)
    @assert length(md.ip_mc) == length(md.ip_ids) == length(md.mc) == length(md.ids) ==
        length(md.settings) "Length mismatch detected!"
    
    return length(md.mc)
end


include("motor_control.jl")
