


"""
    getMeasurementEnabled(sd::SingleDevice)

Return if IDS displacement measurement is enabled for single device `sd`.
"""
function getMeasurementEnabled(sd::SingleDevice)
    return getMeasurementEnabled(sd.ids)
end

"""
    getMeasurementEnabled(md::MultiDevice)

Return if IDS displacement measurement is enabled for all devices in multidevice `md`.
"""
function getMeasurementEnabled(md::MultiDevice)
    enabled = true

    for i in eachindex(md)
        enabled_ = getMeasurementEnabled(md[i]); enabled *= enabled_
        if !enabled_; println("Measurement not enabled for device $i."); end
    end
    
    return enabled
end

function getMeasurementEnabled_(md::MultiDevice)
    enabled = true

    for device in md
        enabled *= getMeasurementEnabled(device)
    end
    
    return enabled
end


"""
    startMeasurement(sd::SingleDevice; dt::Real=1.0,timeout::Real=120)

Start IDS displacement measurement for single device `sd`. Alignment mode has
to be disabled. If measurement still hasn't started after `timeout` seconds, check for errors
(usually takes < 2 minutes). Checks every `dt` seconds.
"""
function startMeasurement(sd::SingleDevice; dt::Real=1.0,timeout::Real=300)
    startMeasurement(sd.ids; dt=dt,timeout=timeout); return
end

"""
    startMeasurement(md::MultiDevice; dt::Real=1.0,timeout::Real=120)

Start IDS displacement measurement for all devices in multidevice `md`. Alignment mode has
to be disabled. If measurement still hasn't started after `timeout` seconds, check for errors
(usually takes < 2 minutes). Checks every `dt` seconds.
"""
function startMeasurement(md::MultiDevice; dt::Real=1.0,timeout::Real=300)
    # for i in eachindex(md)
    #     println("Starting measurement for device $i.")
    #     startMeasurement(md[i]; dt=dt,timeout=timeout)
    # end

    startMeasurement_(md)

    t = 0
    while !getMeasurementEnabled_(md)
        sleep(dt); t += dt

        if t > timeout
            for i in eachindex(md); if !getMeasurementEnabled(md[i])
                @warn "Measurement still not activated for device $i after $timeout seconds."
            end; break; end
        end
    end

    return
end

"""
    startMeasurement_(md::MultiDevice)

Start IDS displacement measurement without validation check.
"""
function startMeasurement_(md::MultiDevice)
    for i in eachindex(md)
        println("Starting measurement for device $i.")
        startMeasurement_(md[i].ids)
    end; return
end



"""
    stopMeasurement(sd::SingleDevice)

Stop IDS displacement measurement for all devices im multidevice `md`.
"""
function stopMeasurement(sd::SingleDevice)
    stopMeasurement(sd.ids); return
end

"""
    stopMeasurement(md::MultiDevice)

Stop IDS displacement measurement for all devices im multidevice `md`.
"""
function stopMeasurement(md::MultiDevice)
    for i in eachindex(md)
        println("Stopping measurement for device $i.")
        stopMeasurement(md[i])
    end; return
end



"""
    getAbsPos(sd::SingleDevice,axis::Int)

Get absolute IDS position of `axis` for single device `sd`.
"""
function getAbsPos(sd::SingleDevice,axis::Int)
    return getAbsolutePosition(sd.ids,axis)
end

"""
    getAbsPos(sd::SingleDevice)

Get absolute IDS positions of all axes for single device `sd`.
"""
function getAbsPos(sd::SingleDevice)
    return getAbsolutePositions(sd.ids)
end

"""
    getAbsPos!(a::Vector{Int},sd::SingleDevice)

Write absolute IDS positions directly to vector `a` of length 3, see
[`getAbsPos`](@ref).
"""
function getAbsPos!(a::Vector{Int},sd::SingleDevice)
    return getAbsolutePositions!(a,sd.ids)
end

"""
    getAbsPos(md::MultiDevice)

Get absolute IDS positions of all axes for all devices in multidevice `md`.
"""
function getAbsPos(md::MultiDevice)
    return Dict(i => getAbsPos(md[i]) for i in eachindex(md))
end

"""
    getAbsPos!(md::MultiDevice)

Update internal absolute position log of multidevice `md`.
"""
function getAbsPos!(md::MultiDevice)
    for i in eachindex(md)
        getAbsPos!(md.logger.apos[i],md[i])
    end

    return
end



"""
    getRelPos(sd::SingleDevice,axis::Int)

Get relative IDS position of `axis` for single device `sd`.
"""
function getRelPos(sd::SingleDevice,axis::Int)
    return getAxisDisplacement(sd.ids,axis)
end

"""
    getRelPos(sd::SingleDevice)

Get relative IDS positions of all axes for single device `sd`.
"""
function getRelPos(sd::SingleDevice)
    return getAxesDisplacement(sd.ids)
end

"""
    getRelPos!(a::Vector{Int},sd::SingleDevice)

Write relative IDS positions directly to vector `a` of length 3, see
[`getRelPos`](@ref).
"""
function getRelPos!(a::Vector{Int},sd::SingleDevice)
    return getAxesDisplacement!(a,sd.ids)
end

"""
    getRelPos(md::MultiDevice)

Get relative IDS positions of all axes for all devices in multidevice `md`.
"""
function getRelPos(md::MultiDevice)
    return Dict(i => getRelPos(md[i]) for i in eachindex(md))
end

"""
    getRelPos!(md::MultiDevice)

Update internal relative position log of multidevice `md`.
"""
function getRelPos!(md::MultiDevice)
    for i in eachindex(md)
        getRelPos!(md.logger.rpos[i],md[i])
    end

    return
end



"""
    getRefPos(sd::SingleDevice,axis::Int)

Get IDS reference position of `axis` for single device `sd`.
"""
function getRefPos(sd::SingleDevice,axis::Int)
    return getReferencePosition(sd.ids,axis)
end

"""
    getRefPos(sd::SingleDevice)

Get IDS reference positions of all axes for single device `sd`.
"""
function getRefPos(sd::SingleDevice)
    return getReferencePositions(sd.ids)
end

"""
    getRefPos!(a::Vector{Int},sd::SingleDevice)

Write IDS reference positions directly to vector `a` of length 3, see
[`getRefPos`](@ref).
"""
function getRefPos!(a::Vector{Int},sd::SingleDevice)
    return getReferencePositions!(a,sd.ids)
end

"""
    getRefPos(md::MultiDevice)

Get IDS reference positions of all axes for all devices in multidevice `md`.
"""
function getRefPos(md::MultiDevice)
    return Dict(i => getRefPos(md[i]) for i in eachindex(md))
end

# """
#     getRefPos!(md::MultiDevice)

# Update internal reference position log of multidevice `md`.
# """
# function getRefPos!(md::MultiDevice)
#     for i in eachindex(md)
#         getRefPos!(md.logger.refpos[i],md[i])
#     end

#     return
# end


#

"""
    getSignal(sd::SingleDevice,axis::Int; threshold::Int=850)

Return IDS signal quality in permille of `axis` for single device `sd`.
Gives warning if value exceeds `threshold`.
"""
function getSignal(sd::SingleDevice,axis::Int; threshold::Int=850)
    return getAxisSignalQuality(sd.ids,axis; threshold=threshold)
end

"""
    getSignal(sd::SingleDevice; threshold::Int=850)

Return IDS signal quality in permille of all axes for single device `sd`.
Gives warning if value exceeds `threshold`.
"""
function getSignal(sd::SingleDevice; threshold::Int=850)
    return getAxesSignalQuality(sd.ids; threshold=threshold)
end

"""
    getSignal!(a::Vector{Int},sd::SingleDevice; threshold::Int=850)

Write IDS signal quality directly to vector `a` of length 3, see
[`getSignal`](@ref).
"""
function getSignal!(a::Vector{Int},sd::SingleDevice; threshold::Int=850)
    return getAxesSignalQuality!(a,sd.ids; threshold=threshold)
end

"""
    getSignal(md::MultiDevice; threshold::Int=850)
    
Return IDS signal quality in permille for all axes for all devices in multidevice `md`.
Gives warning if value exceeds `threshold`.
"""
function getSignal(md::MultiDevice; threshold::Int=850)
    return Dict(i => getSignal(md[i]; threshold=threshold) for i in eachindex(md))
end

"""
    getSignal!(md::MultiDevice; threshold::Int=850)

Update internal signal quality log of multidevice `md`.Gives warning if value exceeds
`threshold`.
"""
function getSignal!(md::MultiDevice; threshold::Int=850)
    for i in eachindex(md)
        getSignal!(md.logger.signal[i],md[i]; threshold=threshold)
    end

    return
end



"""
    resetAxes(sd::SingleDevice)

Re-zero relative values of all IDS axes at their current positions for single device `sd`.
"""
function resetAxes(sd::SingleDevice)
    resetAxes(sd.ids); return
end

"""
    resetAxes(md::MultiDevice)

Re-zero relative values of all IDS axes at their current positions for all devices in
multidevice `md`.
"""
function resetAxes(md::MultiDevice)
    for device in md
        resetAxes(device)
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

