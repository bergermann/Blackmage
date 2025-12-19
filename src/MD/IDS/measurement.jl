
"""
    getMeasurementEnabled(md::MultiDevice,req::Dict)

Return if IDS displacement measurement is enabled for all devices in multidevice `md`.
"""
function getMeasurementEnabled(md::MultiDevice,req::Dict)
    enabled = true

    for i in eachindex(md)
        enabled_ = getMeasurementEnabled(md.ids[i],req); enabled *= enabled_
        if !enabled_; println("Measurement not enabled for device $i."); end
    end
    
    return enabled
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
        startMeasurement(md.ids[i],req; dt=dt,timeout=timeout)
    end

    return
end

"""
    startMeasurement_(md::MultiDevice,req::Dict)

Starts IDS displacement measurement without validation check.
"""
function startMeasurement_(md::MultiDevice,req::Dict)
    for i in eachindex(md)
        println("Starting measurement for device $i.")
        startMeasurement_(md.ids[i],req)
    end; return
end

"""
    stopMeasurement(md::MultiDevice,req::Dict)

Stops IDS displacement measurement for all devices im multidevice `md`.
"""
function stopMeasurement(md::MultiDevice,req::Dict)
    for i in eachindex(md)
        println("Stopping measurement for device $i.")
        stopMeasurement(md.ids[i],req)
    end; return
end



"""
    getAbsolutePositions(md::MultiDevice,req::Dict)

Return absolute IDS positions of all axes (duh) for all devices in multidevice `md`.
"""
function getAbsolutePositions(md::MultiDevice,req::Dict)
    return Dict(i => getAbsolutePositions(md.ids[i],req) for i in eachindex(md))
end



"""
    getAxesDisplacement(md::MultiDevice,req::Dict)

Get relative IDS positions of all axes for all devices in multidevice `md`.
"""
function getAxesDisplacement(md::MultiDevice,req::Dict)
    return Dict(i => getAxesDisplacement(md.ids[i],req) for i in eachindex(md))
end


"""
    getReferencePositions(md::MultiDevice,req::Dict)

Get IDS reference position of all axes (duh) of all devices in multidevice `md`.
"""
function getReferencePositions(md::MultiDevice,req::Dict)
    return Dict(i => getReferencePositions(md.ids[i],req) for i in eachindex(md))
end



"""
    getAxesSignalQuality(md::MultiDevice,req::Dict; threshold::Int=850)

Return IDS signal quality in permille for all axes for all devices in multidevice `md`.
"""
function getAxesSignalQuality(md::MultiDevice,req::Dict; threshold::Int=850)
    return Dict(i => getAxesSignalQuality(md.ids[i],req; threshold=threshold)
        for i in eachindex(md))
end


