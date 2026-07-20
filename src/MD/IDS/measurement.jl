


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
    getAbsolutePositions(sd::SingleDevice,req::Dict)

Return absolute IDS positions of all axes (duh) for single device `sd`.
"""
function getAbsolutePositions(sd::SingleDevice,req::Dict)
    return getAbsolutePositions(sd.ids,req)
end

"""
    getAbsolutePositions(md::MultiDevice,req::Dict)

Return absolute IDS positions of all axes (duh) for all devices in multidevice `md`.
"""
function getAbsolutePositions(md::MultiDevice,req::Dict)
    return Dict(i => getAbsolutePositions(md[i],req) for i in eachindex(md))
end



"""
    getAxesDisplacement(sd::SingleDevice,req::Dict)

Get relative IDS positions of all axes for single device `sd`.
"""
function getAxesDisplacement(sd::SingleDevice,req::Dict)
    return getAxesDisplacement(sd.ids,req)
end

"""
    getAxesDisplacement(md::MultiDevice,req::Dict)

Get relative IDS positions of all axes for all devices in multidevice `md`.
"""
function getAxesDisplacement(md::MultiDevice,req::Dict)
    return Dict(i => getAxesDisplacement(md[i],req) for i in eachindex(md))
end



"""
    getReferencePositions(sd::SingleDevice,req::Dict)

Get IDS reference position of all axes (duh) of single device `sd`.
"""
function getReferencePositions(sd::SingleDevice,req::Dict)
    return getReferencePositions(sd.ids,req)
end

"""
    getReferencePositions(md::MultiDevice,req::Dict)

Get IDS reference position of all axes (duh) of all devices in multidevice `md`.
"""
function getReferencePositions(md::MultiDevice,req::Dict)
    return Dict(i => getReferencePositions(md[i],req) for i in eachindex(md))
end



"""
    getAxesSignalQuality(sd::SingleDevice,req::Dict; threshold::Int=850)

Return IDS signal quality in permille for all axes for single device `sd`.
"""
function getAxesSignalQuality(sd::SingleDevice,req::Dict; threshold::Int=850)
    return getAxesSignalQuality(sd.ids,req; threshold=threshold)
end

"""
    getAxesSignalQuality(md::MultiDevice,req::Dict; threshold::Int=850)

Return IDS signal quality in permille for all axes for all devices in multidevice `md`.
"""
function getAxesSignalQuality(md::MultiDevice,req::Dict; threshold::Int=850)
    return Dict(i => getAxesSignalQuality(md[i],req; threshold=threshold)
        for i in eachindex(md))
end



"""
    resetAxes(sd::SingleDevice,req::Dict)

Re-zero relative values of all IDS axes at their current positions for single device `sd`.
"""
function resetAxes(sd::SingleDevice,req::Dict)
    resetAxes(sd,req); return
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



"""
    measurePos(md::MultiDevice,n::Int; dt::Real=0.)

Measure IDS positions of each device in multidevice `md` `n` times, return dict of mean and
standard deviation of the distribution. Enforce delay `dt` between each measurement.
"""
function measurePos(md::MultiDevice,n::Int; dt::Real=0.)
    data = Dict{Int,Tuple{Float64,Float64}}()

    for i in eachindex(md)
        data[i] = measurePos(md[i].ids,n; dt=dt)
    end
    
    return data
end



function updateLog!(md::MultiDevice)
    for i in eachindex(md)
        getAbsolutePositions!(md.logger.apos,md[i].ids,md.req)
        getRelativePositions!(md.logger.rpos,md[i].ids,md.req)
        getAxesSignalQuality!(md.logger.apos,md[i].ids,md.req)
    end

    return
end

function updateLog_(md::MultiDevice)
    md.logger.apos[1]     += rand(3:5,3)
    md.logger.rpos[1]     += rand(0:5,3)
    md.logger.contrast[1] += rand(0:1,3)

    return
end