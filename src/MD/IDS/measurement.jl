


"""
    getMeasurementEnabled(sd::SingleDevice,req::Dict)

Return if IDS displacement measurement is enabled for single device `sd`.
"""
function getMeasurementEnabled(sd::SingleDevice,req::Dict)
    return getMeasurementEnabled(sd.ids,req)
end

"""
    getMeasurementEnabled(md::MultiDevice,req::Dict)

Return if IDS displacement measurement is enabled for all devices in multidevice `md`.
"""
function getMeasurementEnabled(md::MultiDevice,req::Dict)
    enabled = true

    for i in eachindex(md)
        enabled_ = getMeasurementEnabled(md[i],req); enabled *= enabled_
        if !enabled_; println("Measurement not enabled for device $i."); end
    end
    
    return enabled
end



"""
    startMeasurement(sd::SingleDevice,req::Dict; dt::Real=1.0,timeout::Real=120)

Start IDS displacement measurement for single device `sd`. Alignment mode has
to be disabled. If measurement still hasn't started after `timeout` seconds, check for errors
(usually takes < 2 minutes). Checks every `dt` seconds.
"""
function startMeasurement(sd::SingleDevice,req::Dict; dt::Real=1.0,timeout::Real=300)
    startMeasurement(sd.ids,req; dt=dt,timeout=timeout); return
end

"""
    startMeasurement(md::MultiDevice,req::Dict; dt::Real=1.0,timeout::Real=120)

Start IDS displacement measurement for all devices in multidevice `md`. Alignment mode has
to be disabled. If measurement still hasn't started after `timeout` seconds, check for errors
(usually takes < 2 minutes). Checks every `dt` seconds.
"""
function startMeasurement(md::MultiDevice,req::Dict; dt::Real=1.0,timeout::Real=300)
    for i in eachindex(md)
        println("Starting measurement for device $i.")
        startMeasurement(md[i],req; dt=dt,timeout=timeout)
    end

    return
end

"""
    startMeasurement_(md::MultiDevice,req::Dict)

Start IDS displacement measurement without validation check.
"""
function startMeasurement_(md::MultiDevice,req::Dict)
    for i in eachindex(md)
        println("Starting measurement for device $i.")
        startMeasurement_(md[i].ids,req)
    end; return
end



"""
    stopMeasurement(sd::SingleDevice,req::Dict)

Stop IDS displacement measurement for all devices im multidevice `md`.
"""
function stopMeasurement(sd::SingleDevice,req::Dict)
    stopMeasurement(sd.ids,req); return
end

"""
    stopMeasurement(md::MultiDevice,req::Dict)

Stop IDS displacement measurement for all devices im multidevice `md`.
"""
function stopMeasurement(md::MultiDevice,req::Dict)
    for i in eachindex(md)
        println("Stopping measurement for device $i.")
        stopMeasurement(md[i],req)
    end; return
end



"""
    getAbsPos(sd::SingleDevice,req::Dict,axis::Int)

Get absolute IDS position of `axis` for single device `sd`.
"""
function getAbsPos(sd::SingleDevice,req::Dict,axis::Int)
    return getAbsolutePosition(sd.ids,req,axis)
end

"""
    getAbsPos(sd::SingleDevice,req::Dict)

Get absolute IDS positions of all axes for single device `sd`.
"""
function getAbsPos(sd::SingleDevice,req::Dict)
    return getAbsolutePositions(sd.ids,req)
end

"""
    getAbsPos!(a::Vector{Int},sd::SingleDevice,req::Dict)

Write absolute IDS positions directly to vector `a` of length 3, see
[`getAbsPos`](@ref).
"""
function getAbsPos!(a::Vector{Int},sd::SingleDevice,req::Dict)
    return getAbsolutePositions!(a,sd.ids,req)
end

"""
    getAbsPos(md::MultiDevice,req::Dict)

Get absolute IDS positions of all axes for all devices in multidevice `md`.
"""
function getAbsPos(md::MultiDevice,req::Dict)
    return Dict(i => getAbsPos(md[i],req) for i in eachindex(md))
end

"""
    getAbsPos!(md::MultiDevice,req::Dict)

Update internal absolute position log of multidevice `md`.
"""
function getAbsPos!(md::MultiDevice,req::Dict)
    for i in eachindex(md)
        getAbsPos!(md.logger.apos[i],md[i],req)
    end

    return
end



"""
    getRelPos(sd::SingleDevice,req::Dict,axis::Int)

Get relative IDS position of `axis` for single device `sd`.
"""
function getRelPos(sd::SingleDevice,req::Dict,axis::Int)
    return getAxisDisplacement(sd.ids,req,axis)
end

"""
    getRelPos(sd::SingleDevice,req::Dict)

Get relative IDS positions of all axes for single device `sd`.
"""
function getRelPos(sd::SingleDevice,req::Dict)
    return getAxesDisplacement(sd.ids,req)
end

"""
    getRelPos!(a::Vector{Int},sd::SingleDevice,req::Dict)

Write relative IDS positions directly to vector `a` of length 3, see
[`getRelPos`](@ref).
"""
function getRelPos!(a::Vector{Int},sd::SingleDevice,req::Dict)
    return getAxesDisplacement!(a,sd.ids,req)
end

"""
    getRelPos(md::MultiDevice,req::Dict)

Get relative IDS positions of all axes for all devices in multidevice `md`.
"""
function getRelPos(md::MultiDevice,req::Dict)
    return Dict(i => getRelPos(md[i],req) for i in eachindex(md))
end

"""
    getRelPos!(md::MultiDevice,req::Dict)

Update internal relative position log of multidevice `md`.
"""
function getRelPos!(md::MultiDevice,req::Dict)
    for i in eachindex(md)
        getRelPos!(md.logger.rpos[i],md[i],req)
    end

    return
end



"""
    getRefPos(sd::SingleDevice,req::Dict,axis::Int)

Get IDS reference position of `axis` for single device `sd`.
"""
function getRefPos(sd::SingleDevice,req::Dict,axis::Int)
    return getReferencePosition(sd.ids,req,axis)
end

"""
    getRefPos(sd::SingleDevice,req::Dict)

Get IDS reference positions of all axes for single device `sd`.
"""
function getRefPos(sd::SingleDevice,req::Dict)
    return getReferencePositions(sd.ids,req)
end

"""
    getRefPos!(a::Vector{Int},sd::SingleDevice,req::Dict)

Write IDS reference positions directly to vector `a` of length 3, see
[`getRefPos`](@ref).
"""
function getRefPos!(a::Vector{Int},sd::SingleDevice,req::Dict)
    return getReferencePositions!(a,sd.ids,req)
end

"""
    getRefPos(md::MultiDevice,req::Dict)

Get IDS reference positions of all axes for all devices in multidevice `md`.
"""
function getRefPos(md::MultiDevice,req::Dict)
    return Dict(i => getRefPos(md[i],req) for i in eachindex(md))
end

# """
#     getRefPos!(md::MultiDevice,req::Dict)

# Update internal reference position log of multidevice `md`.
# """
# function getRefPos!(md::MultiDevice,req::Dict)
#     for i in eachindex(md)
#         getRefPos!(md.logger.refpos[i],md[i],req)
#     end

#     return
# end



"""
    getSignal(md::MultiDevice,req::Dict; threshold::Int=850)

    
"""
function getSignal(md::MultiDevice,req::Dict; threshold::Int=850)
    return Dict(i => getAxesSignalQuality(md[i],req; threshold=threshold)
        for i in eachindex(md))
end



"""
    getSignal(sd::SingleDevice,req::Dict,axis::Int; threshold::Int=850)

Return IDS signal quality in permille of `axis` for single device `sd`.
Gives warning if value exceeds `threshold`.
"""
function getSignal(sd::SingleDevice,req::Dict,axis::Int; threshold::Int=850)
    return getAxisSignalQuality(sd.ids,req,axis; threshold=threshold)
end

"""
    getSignal(sd::SingleDevice,req::Dict; threshold::Int=850)

Return IDS signal quality in permille of all axes for single device `sd`.
Gives warning if value exceeds `threshold`.
"""
function getSignal(sd::SingleDevice,req::Dict; threshold::Int=850)
    return getAxesSignalQuality(sd.ids,req; threshold=threshold)
end

"""
    getSignal!(a::Vector{Int},sd::SingleDevice,req::Dict; threshold::Int=850)

Write IDS signal quality directly to vector `a` of length 3, see
[`getSignal`](@ref).
"""
function getSignal!(a::Vector{Int},sd::SingleDevice,req::Dict; threshold::Int=850)
    return getAxesSignalQuality!(a,sd.ids,req; threshold=threshold)
end

"""
    getSignal(md::MultiDevice,req::Dict; threshold::Int=850)
    
Return IDS signal quality in permille for all axes for all devices in multidevice `md`.
Gives warning if value exceeds `threshold`.
"""
function getSignal(md::MultiDevice,req::Dict; threshold::Int=850)
    return Dict(i => getSignal(md[i],req; threshold=threshold) for i in eachindex(md))
end

"""
    getSignal!(md::MultiDevice,req::Dict; threshold::Int=850)

Update internal signal quality log of multidevice `md`.Gives warning if value exceeds
`threshold`.
"""
function getSignal!(md::MultiDevice,req::Dict; threshold::Int=850)
    for i in eachindex(md)
        getSignal!(md.logger.signal[i],md[i],req; threshold=threshold)
    end

    return
end



"""
    resetAxes(sd::SingleDevice,req::Dict)

Re-zero relative values of all IDS axes at their current positions for single device `sd`.
"""
function resetAxes(sd::SingleDevice,req::Dict)
    resetAxes(sd.ids,req); return
end

"""
    resetAxes(md::MultiDevice,req::Dict)

Re-zero relative values of all IDS axes at their current positions for all devices in
multidevice `md`.
"""
function resetAxes(md::MultiDevice,req::Dict)
    for device in md
        resetAxes(device,req)
    end; return
end



# """
#     measurePos(md::MultiDevice,n::Int; dt::Real=0.)

# Measure IDS positions of each device in multidevice `md` `n` times, return dict of mean and
# standard deviation of the distribution. Enforce delay `dt` between each measurement.
# """
# function measurePos(md::MultiDevice,n::Int; dt::Real=0.)
#     data = Dict{Int,Tuple{Float64,Float64}}()

#     for i in eachindex(md)
#         data[i] = measurePos(md[i].ids,n; dt=dt)
#     end
    
#     return data
# end



function updateLog!(md::MultiDevice)
    for i in eachindex(md)
        getRelativePositions!(md.logger.rpos,  md[i].ids,md.req)
        getAbsolutePositions!(md.logger.apos,  md[i].ids,md.req)
        getAxesSignalQuality!(md.logger.signal,md[i].ids,md.req)
    end

    md.logger.timestamp = datetime2unix(now())

    return
end

function updateLog_(md::MultiDevice)
    md.logger.apos[1]     += rand(3:5,3)
    md.logger.rpos[1]     += rand(0:5,3)
    md.logger.contrast[1] += rand(0:1,3)

    md.logger.timestamp += 1.

    return
end


