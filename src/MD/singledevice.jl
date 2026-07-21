
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
    "Position of disc center point in m."
    p0::Float64
    "Vector of interferometer positions in m."
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

"""
    update!(state::SingleState,target::Real)

Update values of `state` to position `target` assuming no tilts.
"""
function update!(state::SingleState,target::Real)
    state.p0 = target; state.p3 .= target
    state.xtilt = state.ytilt = 0.

    return
end

"""
    update!(state::SingleState,target::Union{Vector{<:Real},NTuple{3}};
        α::Real=0,r::Real=0.15)

Update values of `state` to individual motor positions `target`.
"""
function update!(state::SingleState,target::Union{Vector{<:Real},NTuple{3}};
        α::Real=0,r::Real=0.15)

    @assert length(target) == 3 "Target must contain exactly 3 elements."

    state.p3 .= target
    state.p0, state.xtilt, state.ytilt = pos2tilt(target; α=α,r=r)

    return
end

"""
    update!(state::SingleState,target::Real,xtilt::Real,ytilt::Real)

Update values of `state` with given `xtilt` and `ytilt` and disc center position `target`.
"""
function update!(state::SingleState,target::Real,xtilt::Real,ytilt::Real;
        α::Real=0,r::Real=0.15)

    state.p0 = target; state.xtilt = xtilt; state.ytilt=ytilt

    state.p3 .= tilt2pos(xtilt,ytilt; α=α,r=r) .+ target
    
    return
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

    "State of FCM device."
    stateFCM::StateFCM

    @doc """
        SingleDevice(mc_ip,mc_port,mc,ids_ip,ids_port,ids,settings,bdry,state,target)
    """
    function SingleDevice(mc_ip,mc_port,mc,ids_ip,ids_port,ids,settings,bdry,state,target,stateFCM)
        new(mc_ip,mc_port,mc,ids_ip,ids_port,ids,settings,bdry,state,target,stateFCM)
    end
    
    @doc """
        SingleDevice(mc_ip,ids_ip; mc_port=2000,ids_port=9090,disc_settings...)
    """
    function SingleDevice(mc_ip,ids_ip; mc_port=2000,ids_port=9090,disc_settings...)
        new(
            mc_ip,mc_port,connect(mc_ip,mc_port),
            ids_ip,ids_port,connect(ids_ip,ids_port),
            DiscSettings(; disc_settings...),Boundaries(),
            SingleState(),SingleState(),
            FCM_OFF
        )
    end
end; const SD = SingleDevice
