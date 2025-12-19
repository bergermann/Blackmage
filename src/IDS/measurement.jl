

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
    getAbsolutePosition(device::D,req::Dict,axis::Int)

Return absolute IDS position of `axis` (duh).
"""
function getAbsolutePosition(device::D,req::Dict,axis::Int)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    return request(device,req,:displace,"getAbsolutePosition";
        params=[axis-1])[2]
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
    getAxisDisplacement(device::D,req::Dict,axis::Int)

Get relative IDS position of `axis`.
"""
function getAxisDisplacement(device::D,req::Dict,axis::Int)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    return request(device,req,:displace,"getAxisDisplacement";
        params=[axis-1])[2]
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
    getReferencePosition(device::D,req::Dict,axis::Int)

Get IDS reference position of `axis` (duh).
"""
function getReferencePosition(device::D,req::Dict,axis::Int)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    return request(device,req,:displace,"getReferencePosition";
        params=[axis-1])
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
    getAxisSignalQuality(device::D,req::Dict,axis::Int; threshold::Int=850)

Return IDS signal quality in permille for `axis`. Gives warning if value exceeds `threshold`.
"""
function getAxisSignalQuality(device::D,req::Dict,axis::Int; threshold::Int=850)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    r = request(device,req,:displace,"getAxisSignalQuality"; params=[axis-1])

    if r[2]+r[3] > threshold
        @warn "Contrast threshold is reached for axis $axis with $(r[2]+r[3]) > $threshold."
    end

    return r[2], r[3]
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



"""
    getAverageN(device::D,req::Dict)

I forgot what this function does, look it up in the manual lolololo
"""
function getAverageN(device::D,req::Dict)
    return request(device,req,:displace,"getAverageN")[2]
end

"""
    setAverageN(device::D,req::Dict,N::Int)

I forgot what this function does, look it up in the manual lolololo
"""
function setAverageN(device::D,req::Dict,N::Int)
    @assert 0 <= N <= 24 "N must be between 0 and 24 (inclusive)."

    request(device,req,:displace,"setAverageN"; params=[N]); return
end
