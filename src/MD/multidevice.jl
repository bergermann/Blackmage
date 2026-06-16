
"Disc and motor settings."
mutable struct DiscSettings
    "Master motor axis, 1, 2 or 3."
    master::Int
    "Estimated full step size in m."
    ess::NTuple{3,Float64}
    "Minimum allowed relative step size in percent."
    mrss::NTuple{3,Int}
    "(master, slave) Maximum step frequencies of master and slave motors in Hz."
    freq::@NamedTuple{master::Int64,slave::Int64}
    "Ambient temperature in K."
    temp::Int
    "Flexdrive target tolerance in IDS steps."
    flextol::Int
    "Maximum slave to master distance in flexdrive mode in IDS steps."
    flexdist::Int
    "Drive factor."
    df::Float64

    "Static angle of master motor to zero axis in degrees."
    α::Float64
    "Retroreflector radius from central z axis in m."
    r::Float64

    @doc """
        DiscSettings(;
            master=1,                      
            ess=(15e-6,15e-6,15e-6),
            mrss=(10,10,10),
            freq=(master=50,slave=70),
            temp=300,
            flextol=300,
            flexdist=5000,
            df=1.0,
            α=0.0,
            r=0.15)
    """
    function DiscSettings(;
            master=1,                      
            ess=(15e-6,15e-6,15e-6),
            mrss=(10,10,10),
            freq=(master=50,slave=70),
            temp=300,
            flextol=300,
            flexdist=5000,
            df=1.0,
            α=0.0,
            r=0.15)

        @assert 1 <= master <= 3 "Master axis has to be 1, 2 or 3."
        @assert all(@. 0 < ess <= 100e-6) "Estimated step size [m] needs to be between 0 and 100e-6."
        @assert all(@. 1 <= mrss <= 100) "Relative step size rss needs to be between 1 and 100."
        @assert 0 < freq.master <= 100 "Movement frequency freq.master [Hz] must be positive, smaller than 100."
        @assert 0 < freq.slave  <= 100 "Movement frequency freq.slave [Hz] must be positive, smaller than 100."
        @assert freq.master < freq.slave "Master frequency [Hz] must be smaller than slave frequency."
        @assert 4 <= temp <= 300 "Environment temperature [K] needs to be between 4 and 300."
        @assert 0 < flextol <= 10_000 "Flexdrive tolerance flextol needs to be between 0 and 10_000."
        @assert 0 < flexdist <= 50_000 "Maximum flexdrive distance flexdist needs to be between 0 and 50_000."
        @assert 0.1 <= df <= 3.0 "Drive factor df needs to be between 0.1 and 3.0."
        @assert 0 <= α <= 360 "Static motor angle α needs to be betwen 0° and 360°."
        @assert 0 < r "Interferometeer radius r needs to be larger than 0."

        new(master,ess,mrss,freq,temp,flextol,flexdist,df,α,r)
    end
end; const DS = DiscSettings


"[NYI] Boundary information of disc and fixture for collision avoidance."
mutable struct Boundaries; end

"Disc position and tilt state."
mutable struct SingleState
    "Position of disc center point."
    p0::Float64
    "Vector of interferometer positions."
    p3::Vector{Float64}
    "Disc tilt angle along axis x in degrees."
    xtilt::Float64
    "Disc tilt angle along axis y in degrees."
    ytilt::Float64

    @doc """
        SingleState()
    """
    function SingleState()
        new(0.,[0.,0.,0.],0.,0.)
    end

    @doc """
        SingleState(p0,p3)
    """
    function SingleState(p0,p3)
        new(p0,p3,0.,0.)
    end

    @doc """
        SingleState(p0,p3,xtilt,ytilt)
    """
    function SingleState(p0,p3,xtilt,ytilt)
        new(p0,p3,xtilt,ytilt)
    end
end


"State, settings and network information for single disc and motor set."
mutable struct SingleDevice
    "Motor controller IPv4 address."
    mc_ip::IPv4
    "Motor controller port."
    mc_port::Int
    "Motor controller TCP socket."
    mc::Union{Nothing,TCPSocket}
    
    "IDS IPv4 address."
    ids_ip::IPv4
    "IDS port."
    ids_port::Int
    "IDS TCP socket."
    ids::Union{Nothing,TCPSocket}

    "Disc and motor settings."
    settings::DiscSettings
    "Collision boundary information."
    bdry::Boundaries

    "Current disc position state."
    state::SingleState
    "Target disc position state."
    target::SingleState

    @doc """
        SingleDevice(mc_ip,mc_port,mc,ids_ip,ids_port,ids,settings,bdry,state,target)
    """
    function SingleDevice(mc_ip,mc_port,mc,ids_ip,ids_port,ids,settings,bdry,state,target)
        new(mc_ip,mc_port,mc,ids_ip,ids_port,ids,settings,bdry,state,target)
    end
    
    @doc """
        SingleDevice(mc_ip,ids_ip; mc_port=2000,ids_port=9090,disc_settings...)
    """
    function SingleDevice(mc_ip,ids_ip; mc_port=2000,ids_port=9090,disc_settings...)
        new(
            mc_ip,mc_port,connect(mc_ip,mc_port),
            ids_ip,ids_port,connect(ids_ip,ids_port),
            DiscSettings(; disc_settings...),Boundaries(),
            SingleState(),SingleState()
        )
    end
end; const SD = SingleDevice



"[NYI] Multidevice settings."
mutable struct MultiDeviceSettings; end



# """
#     Logger

# Log file to track interferometer position (relative and absolute), contrast and timestamp.
# """
# mutable struct Logger
#     "HDF5 file. Needs fields `t0::Int`, `t::Vector`, `data::Matrix`.
#     `data` needs to be of size (9*ndisk,:)"
#     file::HDF5.File

#     "Control state for measuring/writing loop."
#     active::Bool

#     @doc """
#         Logger(file,active)
#     """
#     function Logger(file,active)
#         new(file,active)
#     end

#     @doc """
#         Logger(md::MultiDevice,filepath::String)
#     """
#     function Logger(ndisk,filepath::String)
#         new(create_log_file(ndisk,filepath))
#     end
# end



"Collection of disc devices including 3 motors and an interferometer each."
struct MultiDevice
    "Disc devices with index."
    devices::Dict{Int,SingleDevice}
    "Multidevice settings."
    settings::MultiDeviceSettings
    # "Log file."
    # logger::Logger

    @doc """
        MultiDevice(devices,settings)
    """
    function MultiDevice(devices,settings)
        new(devices,settings)
    end

    @doc """
        MultiDevice(mc_ips::AbstractArray{IPv4},ids_ips::AbstractArray{IPv4};
            masters::AbstractArray{Int}=ones(Int,length(mc_ips)),
            mc_port::Int=2000,ids_port::Int=9090)
    """
    function MultiDevice(mc_ips::AbstractVector{IPv4},ids_ips::AbstractVector{IPv4};
            masters::AbstractVector{Int}=ones(Int,length(mc_ips)),
            mc_port::Int=2000,ids_port::Int=9090)

        @assert length(mc_ips) == length(ids_ips) == length(masters)
            "mc, ids addresses and master axes need same lengths."

        devices = Dict{Int,SingleDevice}()

        for i in eachindex(mc_ips)
            mc = try
                connect(mc_ips[i],mc_port)
            catch e
                @warn "Could not open MC port $i."; display(e); nothing
            end

            ids = try
                connect(ids_ips[i],ids_port)
            catch e
                @warn "Could not open IDS port $i."; display(e); nothing
            end

            devices[i] = SingleDevice(
                 mc_ips[i], mc_port, mc,
                ids_ips[i],ids_port,ids,
                DiscSettings(),Boundaries(),
                SingleState(),SingleState()
            )
        end

        new(
            devices,
            MultiDeviceSettings()
        )
    end

    MultiDevice(mc_ips::AbstractVector{String},ids_ips::AbstractVector{String}; kwargs...) =
        MultiDevice(IPv4.(mc_ips),IPv4.(ids_ips); kwargs...)
end

const MD = MultiDevice

import Base: setproperty!, getindex, eachindex, length, isopen, open, close

Base.getindex(md::MultiDevice,inds...) = getindex(md.devices,inds...)
Base.setindex!(md::MultiDevice,X,inds...) = setindex!(md.devices,X,inds...)
Base.eachindex(md::MultiDevice) = eachindex(md.devices)
Base.length(md::MultiDevice) = length(md.devices)

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
include("logging.jl")


#=
md functions to add:
resetAxes
=#