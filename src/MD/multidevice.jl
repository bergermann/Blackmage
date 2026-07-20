

"Multidevice settings."
mutable struct MultiDeviceSettings
    "Wether to do precision adjustment after mcTarget command."
    doprecision::Bool
    "Global settings for precision corrections."
    psettings::@NamedTuple{maxsteps::Int64,maxiter::Int64,correctess::Bool,doublepass::Bool}


    function MultiDeviceSettings(doprecision,(maxsteps,maxiter,correctess,doublepass))
        new(
            doprecision,
            (maxsteps,maxiter,correctess,doublepass),
        )
    end

    function MultiDeviceSettings()
        new(
            false,
            (maxsteps=10,maxiter=10,correctess=false,doublepass=true),
        )
    end
end



"""
    Logger

Log file to track interferometer position (relative and absolute), contrast and timestamp.
"""
mutable struct Logger
    "Control state for measuring/writing loop."
    active::Bool
    "Read-write lock."
    lock::ReentrantLock
    "Absolute position data."
    apos::Dict{Int,Vector{Int}}
    "Relative position data."
    rpos::Dict{Int,Vector{Int}}
    "Interferometer signal contrast."
    contrast::Dict{Int,Vector{Int}}

    "Timestamp of last measurement in unix time."
    timestamp::Float64

    "JSON dict for IDS requests."
    req::Dict{String,Union{String,Vector}}

    @doc """
        Logger(active,apos,rpos,contrast)
    """
    function Logger(active,lock,apos,rpos,contrast,timestamp,req)
        new(active,lock,apos,rpos,contrast,timestamp,req)
    end

    @doc """
        Logger(ndisk)
    """
    function Logger(ndisk)
        new(
            false,
            ReentrantLock(),
            Dict(i => zeros(Float64,3) for i in 1:ndisk),
            Dict(i => zeros(Float64,3) for i in 1:ndisk),
            Dict(i => zeros(Float64,3) for i in 1:ndisk),
            0.,
            Dict(
                "jsonrpc" => "2.0",
                "method" => "",
                "id" => "0",
                "api" => "2",
                "params" => [],
            )
        )
    end
end



"Collection of disc devices including 3 motors and an interferometer each."
struct MultiDevice
    "Disc devices with index."
    devices::Dict{Int,SingleDevice}
    "Position data buffer."
    logger::Logger
    "Multidevice settings."
    settings::MultiDeviceSettings

    "Flag if device is currently moving."
    moving::Bool
    "Flag if device is at target after moving."
    target::Bool

    @doc """
        MultiDevice(devices,logger,settings)
    """
    function MultiDevice(devices,logger,settings,moving,target)
        new(devices,logger,settings,moving,target)
    end

    @doc """
        MultiDevice(mc_ips::AbstractArray{IPv4},ids_ips::AbstractArray{IPv4};
            masters::AbstractArray{Int}=ones(Int,length(mc_ips)),
            mc_port::Int=2000,ids_port::Int=9090)
    """
    function MultiDevice(mc_ips::AbstractVector{IPv4},ids_ips::AbstractVector{IPv4};
            masters::AbstractVector{Int}=ones(Int,length(mc_ips)),
            mc_port::Int=2000,ids_port::Int=9090,timeout::Real=10)

        @assert length(mc_ips) == length(ids_ips) == length(masters)
            "mc, ids addresses and master axes need same lengths."

        devices = Dict{Int,SingleDevice}()

        for i in eachindex(mc_ips)
            mc = try
                connect(mc_ips[i],mc_port,timeout)
            catch e
                @warn "Could not open MC port $i."; display(e); nothing
            end

            ids = try
                connect(ids_ips[i],ids_port,timeout)
            catch e
                @warn "Could not open IDS port $i."; display(e); nothing
            end

            devices[i] = SingleDevice(
                 mc_ips[i], mc_port, mc,
                ids_ips[i],ids_port,ids,
                DiscSettings(),Boundaries(),
                SingleState(),SingleState(),
                FCM_OFF
            )
        end

        new(
            devices,
            Logger(length(devices)),
            MultiDeviceSettings(),
            false,
            true
        )
    end

    @doc """
        MultiDevice(mc_ips,ids_ips; kwargs...)
    """
    function MultiDevice(mc_ips,ids_ips; kwargs...)
        MultiDevice(IPv4.(mc_ips),IPv4.(ids_ips); kwargs...)
    end

    @doc """
        MultiDevice()
    """
    function MultiDevice()
        new(
            Dict{Int,SingleDevice}(),
            Logger(0),
            MultiDeviceSettings(),
            false,
            true
        )
    end
end

# MultiDevice(mc_ips::AbstractVector{String},ids_ips::AbstractVector{String}; kwargs...) =
#     MultiDevice(IPv4.(mc_ips),IPv4.(ids_ips); kwargs...)


const MD = MultiDevice

import Base: setproperty!, getindex, eachindex, iterate, length, haskey, isopen, open, close

Base.getindex(md::MultiDevice,inds...) = getindex(md.devices,inds...)
Base.setindex!(md::MultiDevice,X,inds...) = setindex!(md.devices,X,inds...)
Base.eachindex(md::MultiDevice) = eachindex(md.devices)
Base.iterate(md::MultiDevice) = iterate(values(md.devices))
Base.iterate(md::MultiDevice,i::Integer) = iterate(values(md.devices),i)
Base.length(md::MultiDevice) = length(md.devices)
Base.haskey(md::MultiDevice,key) = haskey(md.devices,key)

function Base.setproperty!(md::MultiDevice,name::Symbol,x)
    if hasfield(MultiDevice,name)
        setproperty!(md,name,x)
    elseif hasfield(DiscSettings,name)
        for i in eachindex(md)
            setproperty!(md.devices[i].settings,name,x)
        end
    else
        throw(FieldError(MultiDevice,name))
    end

    return
end

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

function Base.open(md::MultiDevice; timeout=10)
    for i in eachindex(md)
        if isnothing(md[i].mc) || !isopen(md.devices[i].mc)
            md[i].mc = try
                connect(md[i].mc_ip,md[i].mc_port,timeout)
            catch e
                @warn "Could not open MC port $i."; display(e); nothing
            end
        end

        if isnothing(md[i].ids) || !isopen(md.devices[i].ids)
            md[i].ids = try
                connect(md[i].ids_ip,md[i].ids_port,timeout)
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


