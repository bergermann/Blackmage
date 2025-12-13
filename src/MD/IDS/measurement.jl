
export getMeasurementEnabled, startMeasurement, stopMeasurement
export getAbsolutePosition, getAbsolutePositions
export getAxisDisplacement, getAxesDisplacement
export getReferencePosition, getReferencePositions
export getAxisSignalQuality, getAxesSignalQuality


"""
    getMeasurementEnabled(device::D,req::Dict)

Return if IDS displacement measurement is enabled.
"""
function getMeasurementEnabled(device::D,req::Dict)
    return request(device,req,:displace,"getMeasurementEnabled")[2]
end

"""
    startMeasurement(device::D,req::Dict; dt::Real=1.0,timeout::Real=120)

Start IDS displacement measurement. Alignment mode has to be disabled. If measurement still
hasn't started after `timeout` seconds, check for errors (usually takes < 2 minutes). Checks
every `dt` seconds.
"""
function startMeasurement(device::D,req::Dict; dt::Real=1.0,timeout::Real=300)
    @assert !getAdjustmentEnabled(device,req) "Alignment is enabled, cannot start measurement."
    
    if getMeasurementEnabled(device,req)
        @info "Measurement already activated."; return
    end

    request(device,req,:system,"startMeasurement")

    t = 0
    while !getMeasurementEnabled(device,req)
        sleep(dt); t += dt

        if t > timeout
            @warn "Measurement still not activated after $timeout seconds."; break
        end
    end

    return
end

"""
    stopMeasurement(device::D,req::Dict)

Stops IDS displacement measurement.
"""
function stopMeasurement(device::D,req::Dict)
    if !getMeasurementEnabled(device,req)
        @info "Measurement already deactivated."; return
    end
    
    request(device,req,:system,"stopMeasurement"); return
end



"""
    getAbsolutePositions(device::D,req::Dict)

Return absolute IDS positions of all axes (duh).
"""
function getAbsolutePositions(device::D,req::Dict)
    r = request(device,req,:displace,"getAbsolutePositions")

    return [r[2],r[3],r[4]]
end



"""
    getAxesDisplacement(device::D,req::Dict)

Get relative IDS positions of all axes.
"""
function getAxesDisplacement(device::D,req::Dict)
    r = request(device,req,:displace,"getAxesDisplacement")

    return [r[2],r[3],r[4]]
end


"""
    getReferencePositions(device::D,req::Dict)

Get IDS reference position of all axes (duh).
"""
function getReferencePositions(device::D,req::Dict)
    r = request(device,req,:displace,"getReferencePositions")

    return [r[2],r[3],r[4]]
end



"""
    getAxesSignalQuality(device::D,req::Dict; threshold::Int=850)

Return IDS signal quality in permille for all axes. Gives warning if values exceed `threshold`.
"""
function getAxesSignalQuality(device::D,req::Dict; threshold::Int=850)
    contrast = Vector{Int}(undef,3)

    for axis in 1:3
        c, offset = getAxisSignalQuality(device,req,axis; threshold=threshold)
        contrast[axis] = c+offset
    end

    return contrast
end


