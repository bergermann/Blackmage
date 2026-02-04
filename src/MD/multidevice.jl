

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
        @assert all(@. 0 < ess <= 100e-6) "Estimated step size [m] needs to be between 0 and 100e-6."
        @assert 1 <= mrss <= 100 "Relative step size rss needs to be between 1 and 100."
        @assert 0 < freq.master <= 100 "Movement frequency freq [Hz] must be positive, smaller than 100."
        @assert 0 < freq.slave  <= 100 "Movement frequency freq [Hz] must be positive, smaller than 100."
        @assert freq.master < freq.slave "Master frequency [Hz] must be smaller than slave frequency."
        @assert 4 <= temp <= 300 "Environment temperature [K] needs to be between 4 and 300."
        @assert 0 < flextol <= 10_000 "Flexdrive tolerance flextol needs to be between 0 and 10_000."
        @assert 0 < flexdist <= 50_000 "Maximum flexdrive distance flexdist needs to be between 0 and 50_000."
        @assert 0.1 <= df <= 3.0 "Drive factor df needs to be between 0.1 and 3.0."

        new(master,ess,mrss,freq,temp,flextol,flexdist,df)
    end
end; const DS = DiscSettings



mutable struct Boundaries; end



struct SingleDevice
    mc_ip::IPv4
    mc_port::Int
    mc::TCPSocket
    
    ids_ip::IPv4
    ids_port::Int
    ids::TCPSocket

    settings::DiscSettings
    bdry::Boundaries

    function SingleDevice(mc_ip,mc_port,ids_ip,ids_port,mc,ids,settings,bdry)
        new(mc_ip,mc_port,ids_ip,ids_port,mc,ids,settings,bdry)
    end

    function SingleDevice(mc_ip,ids_ip; mc_port=2000,ids_port=9090,disc_settings...)
        new(
            mc_ip,mc_port,ids_ip,ids_port,connect(mc_ip,mc_port),connect(ids_ip,ids_port),
            DiscSettings(; disc_settings...), Boundaries()
        )
    end
end; const SD = SingleDevice



mutable struct MultiDeviceSettings; end



struct MultiDevice
    devices::Dict{Int,SingleDevice}
    settings::MultiDeviceSettings

    function MultiDevice(devices,settings)
        new(devices,settings)
    end

    function MultiDevice(mc_ip::AbstractArray{IPv4},ids_ip::AbstractArray{IPv4};
            masters::AbstractArray{Int}=ones(Int,length(mc_ip)),
            mc_port::Int=2000,ids_port::Int=9090)

        @assert length(mc_ip) == length(ids_ip) == length(masters)
            "mc, ids addresses and master axes need same lengths."

        new(
            Dict(i => SingleDevice(mc_ip[i],ids_ip[i]; mc_port=mc_port,ids_port=ids_port)
                for i in eachindex(mc_ip)),
            MultiDeviceSettings()
        )
    end
end

const MD = MultiDevice

import Base: getindex, eachindex, length, open, close, isopen

Base.getindex(md::MultiDevice,inds...) = getindex(md.devices,inds...)
Base.setindex!(md::MultiDevice,X,inds...) = setindex!(md.devices,X,inds...)
Base.eachindex(md::MultiDevice) = eachindex(md.devices)
Base.length(md::MultiDevice) = length(md.devices)

function Base.open(md::MultiDevice)
    for i in eachindex(md)
        try; if !isopen(md.devices[i].mc); open(md.devices[i].mc); end
        catch e; println("Could not open motor port for device $i:\n$e"); end
        
        try; if !isopen(md[i].ids); open(md[i].ids); end
        catch e; println("Could not open IDS port for device $i:\n$e"); end
    end; return    
end

function Base.close(md::MultiDevice)
    for i in eachindex(md)
        close(md[i].mc); close(md[i].ids)
    end; return
end

function Base.isopen(md::MultiDevice)
    open_ = Dict{Integer,Tuple{Bool,Bool}}()

    for i in eachindex(md); open_[i] = (isopen(md[i].mc),isopen(md[i].ids)); end

    return open_
end


include("IDS/IDS.jl")
include("motor_control.jl")
