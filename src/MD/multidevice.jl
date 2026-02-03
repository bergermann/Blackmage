

mutable struct DiscSettings
    master::Int
    ess::NTuple{3,Float64}
    mrss::NTuple{3,Int}
    freq::@NamedTuple{master::Int64,slave::Int64}
    temp::Int
    flextol::Int
    flexdist::Int
    df::Float64

    function DiscSettings(;
            master=1,                      
            ess=(15e-6,15e-6,15e-6),
            mrss=(5,5,5),
            freq=(master=50,slave=70),
            temp=300,
            flextol=300,
            flexdist=5000,
            df=1.0)

        @assert 1 <= master <= 3 "Master axis has to be 1, 2 or 3."
        @assert 
        @assert 1 <= mrss <= 100 "Relative step size rss needs to between 1 and 100."
        @assert 0 < freq.master <= 100 "Movement frequency freq must be positive, smaller than 100."
        @assert 0 < freq.slave  <= 100 "Movement frequency freq must be positive, smaller than 100."
        @assert freq.master < freq.slave "Master frequency must be smaller than slave frequency."
        @assert 4 <= temp <= 300 "Environment temperature [K] needs to between 4 and 300."
        @assert 0 < freq <= 100 "Movement frequency freq must be positive, smaller than 100."
        @assert 0 < freq <= 100 "Movement frequency freq must be positive, smaller than 100."
        @assert 0.1 <= df <= 3.0 "Drive factor df needs to be between 0.1 and 3.0."

        new(master,ess,mrss,freq,temp,flextol,flexdist)
    end
end; const DS = DiscSettings



mutable struct Boundaries; end



struct SingleDevice
    ip_mc::IPv4
    ip_ids::IPv4
    
    mc::TCPSocket
    ids::TCPSocket

    settings::DiscSettings

    bdry::Boundaries

    function SingleDevice(ip_mc,ip_ids,mc,ids,settings)
        new(ip_mc,ip_ids,mc,ids,settings)
    end

    function SingleDevice(ip_mc::AbstractArray{IPv4},ip_ids::AbstractArray{IPv4};
            master::Int=1,port_mc::Int=2000,port_ids::Int=9090)


        new(
            Dict(i=>                   ip_mc[i] for i in eachindex(ip_mc)),
            Dict(i=>                  ip_ids[i] for i in eachindex(ip_ids)),

            Dict(i=>connect( ip_mc[i],port_mc)  for i in eachindex(ip_mc)),
            Dict(i=>connect(ip_ids[i],port_ids) for i in eachindex(ip_ids)),

            Dict(i=>    DS(; master=masters[i]) for i in eachindex(masters)),
        )
    end
end; const SD = SingleDevice



struct MultiDevice
    devices::Dict{Int,SingleDevice}

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

import Base: getindex, eachindex, length, open, close, isopen

Base.getindex(md::MultiDevice,idx) = (mc=md.mc[idx],ids=md.ids[idx])
Base.eachindex(md::MultiDevice) = eachindex(md.mc)

function Base.length(md::MultiDevice)
    @assert length(md.ip_mc) == length(md.ip_ids) == length(md.mc) == length(md.ids) ==
        length(md.settings) "Length mismatch detected!"
    
    return length(md.mc)
end

function Base.open(md::MultiDevice)
    for i in eachindex(md)
        try; if !isopen(md.mc[i]); open(md.mc[i]); end
        catch e; println("Could not open motor port for device $i:\n$e"); end
        
        try; if !isopen(md.ids[i]); open(md.ids[i]); end
        catch e; println("Could not open IDS port for device $i:\n$e"); end
    end; return    
end

function Base.close(md::MultiDevice)
    for i in eachindex(md)
        close(md.mc[i]); close(md.ids[i])
    end; return
end

function Base.isopen(md::MultiDevice)
    open_ = falses(2,length(md))

    idx = 1
    for i in sort!(keys(eachindex(md)))
        open_[1,idx] = isopen(md.mc[i]); open_[2,idx] = isopen(md.ids[i])
    end

    return open_
end


include("IDS/IDS.jl")
include("motor_control.jl")
