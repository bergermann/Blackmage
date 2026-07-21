


"""
    mcMove(sd::SingleDevice,addr::Int,dir::Int,steps::Int;
        freq::Int=50,
        rss::Int=100,
        temp::Int=sd.settings.temp,
        stage::String="MM1",
        df::Real=1.0)

Single device version of [`mcMove`](@ref).
"""
function mcMove(sd::SingleDevice,addr::Int,dir::Int,steps::Int;
        freq::Int=50,
        rss::Int=100,
        temp::Int=sd.settings.temp,
        stage::String="MM1",
        df::Real=1.0)
    
    @assert 1 <= addr <= 3 "Motor address must be 1, 2 or 3."
    @assert dir == 0 || dir == 1 "Direction dir must be 1 or 2."
    @assert 0 < freq <= 100 "Movement frequency freq must be positive, smaller than 100."
    @assert 0 <= steps <= 50000 "Steps must be non-negative, maximum 50_000."
    @assert 1 <= rss <= 100 "Relative step size rss needs to be between 1 and 100."
    @assert 4 <= temp <= 300 "Environment temperature [K] needs to be between 4 and 300."
    @assert 0.1 <= df <= 3.0 "Drive factor df needs to be between 0.1 and 3.0."

    steps == 0 && @warn "Unlimited movement started, use stop command to interrupt."

    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    println("Status stage $addr: ",
        mcRequest(sd.mc,"MOV $addr $dir $freq $rss $steps $temp $stage $df"))

    return
end

mcMove(sd::SingleDevice,addr::AbstractVector{<:Int},dir::Int,steps::Int; kwargs...) = mcMove.(sd,addr,dir,steps; kwargs...)



"""
    mcStop(sd::SingleDevice,addr::Int)

Single device version of [`mcStop`](@ref).
"""
function mcStop(sd::SingleDevice,addr::Int)
    @assert 1 <= addr <= 3 "Motor address must be 1, 2 or 3."
    
    if sd.stateFCM == FCM_ON; sd.stateFCM = FCM_SEMI; end

    println("Status stage $addr: ",mcRequest(sd.mc,"STP $addr"))

    return
end

mcStop(sd::SingleDevice,addr::AbstractVector{<:Int}) = mcStop.(sd,addr)
