

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
        @assert 0 < freq.master <= 100 "Movement frequency freq.master [Hz] must be positive, smaller than 100."
        @assert 0 < freq.slave  <= 100 "Movement frequency freq.slave [Hz] must be positive, smaller than 100."
        @assert freq.master < freq.slave "Master frequency [Hz] must be smaller than slave frequency."
        @assert 4 <= temp <= 300 "Environment temperature [K] needs to be between 4 and 300."
        @assert 0 < flextol <= 10_000 "Flexdrive tolerance flextol needs to be between 0 and 10_000."
        @assert 0 < flexdist <= 50_000 "Maximum flexdrive distance flexdist needs to be between 0 and 50_000."
        @assert 0.1 <= df <= 3.0 "Drive factor df needs to be between 0.1 and 3.0."

        new(master,ess,mrss,freq,temp,flextol,flexdist,df)
    end
end; const DS = DiscSettings



mutable struct Boundaries; end



mutable struct SingleDevice
    mc_ip::IPv4
    mc_port::Int
    mc::Union{Nothing,TCPSocket}
    
    ids_ip::IPv4
    ids_port::Int
    ids::Union{Nothing,TCPSocket}

    settings::DiscSettings
    bdry::Boundaries

    function SingleDevice(mc_ip,mc_port,mc,ids_ip,ids_port,ids,settings,bdry)
        new(mc_ip,mc_port,ids_ip,ids_port,mc,ids,settings,bdry)
    end

    function SingleDevice(mc_ip,ids_ip; mc_port=2000,ids_port=9090,disc_settings...)
        new(
            mc_ip,mc_port,connect(mc_ip,mc_port),
            ids_ip,ids_port,connect(ids_ip,ids_port),
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

        devices = Dict{Int,SingleDevice}()

        for i in eachindex(mc_ip)
            mc = try
                connect(mc_ip[i],mc_port)
            catch e
                @warn "Could not open MC port $i."; display(e); nothing
            end

            ids = try
                connect(ids_ip[i],ids_port)
            catch e
                @warn "Could not open IDS port $i."; display(e); nothing
            end

            devices[i] = SingleDevice(
                 mc_ip[i], mc_port, mc,
                ids_ip[i],ids_port,ids,
                DiscSettings(),Boundaries()
            )
        end

        new(
            devices,
            MultiDeviceSettings()
        )
    end
end

const MD = MultiDevice

import Base: getindex, eachindex, length, isopen, open, close

Base.getindex(md::MultiDevice,inds...) = getindex(md.devices,inds...)
Base.setindex!(md::MultiDevice,X,inds...) = setindex!(md.devices,X,inds...)
Base.eachindex(md::MultiDevice) = eachindex(md.devices)
Base.length(md::MultiDevice) = length(md.devices)

function Base.isopen(md::MultiDevice)
    open_ = true

    for i in eachindex(md)
        open_ *= (!isnothing(md[i].mc)  && isopen(md[i].mc))
        open_ *= (!isnothing(md[i].ids) && isopen(md[i].ids))
    end

    if !open_; display(open_status(md)); end

    return open_
end

function isopen_mc(md::MultiDevice)
    open_ = true

    for i in eachindex(md); open_ *= (!isnothing(md[i].mc) && isopen(md[i].mc)); end

    if !open_; display(open_status(md)); end

    return open_
end

function isopen_ids(md::MultiDevice)
    open_ = true

    for i in eachindex(md); open_ *= (!isnothing(md[i].ids) && isopen(md[i].ids)); end

    if !open_; display(open_status(md)); end

    return open_
end

function open_status(md::MultiDevice)
    open_ = Dict{Integer,Tuple{Bool,Bool}}()

    for i in eachindex(md)
        open_[i] = (!isnothing(md[i].mc)  && isopen(md[i].mc),
                    !isnothing(md[i].ids) && isopen(md[i].ids))
    end

    return open_
end

function Base.open(md::MultiDevice)
    for i in eachindex(md)
        if isnothing(md[i].mc) || !isopen(md.devices[i].mc)
            md[i].mc = try
                connect(md[i].mc_ip,md[i].mc_port)
            catch e
                @warn "Could not open MC port $i."; display(e); nothing
            end
        end

        if isnothing(md[i].ids) || !isopen(md.devices[i].ids)
            md[i].ids = try
                connect(md[i].ids_ip,md[i].ids_port)
            catch e
                @warn "Could not open IDS port $i."; display(e); nothing
            end
        end
    end; return    
end

function Base.close(md::MultiDevice)
    for i in eachindex(md)
        try close(md[i].mc);  catch; end
        try close(md[i].ids); catch; end
    end; return
end



include("IDS/IDS.jl")
include("motor_control.jl")
