

"""
    getMeasurementEnabled(device::D)

Return if IDS displacement measurement is enabled.
"""
function getMeasurementEnabled(device::D)
    return request(device,:displace,"getMeasurementEnabled")[2]
end

"""
    startMeasurement(device::D; dt::Real=1.0,timeout::Real=120)

Start IDS displacement measurement. Alignment mode has to be disabled. If measurement still
hasn't started after `timeout` seconds, check for errors (usually takes < 2 minutes). Checks
every `dt` seconds.
"""
function startMeasurement(device::D; dt::Real=1.0,timeout::Real=300)
    @assert !getAdjustmentEnabled(device) "Alignment is enabled, cannot start measurement."
    
    if getMeasurementEnabled(device)
        @info "Measurement already activated."; return
    end

    request(device,:system,"startMeasurement")

    t = 0
    while !getMeasurementEnabled(device)
        sleep(dt); t += dt

        if t > timeout
            @warn "Measurement still not activated after $timeout seconds."; break
        end
    end

    return
end

"""
    startMeasurement_(device::D)

Start IDS displacement measurement without validation check.
"""
function startMeasurement_(device::D)
    @assert !getAdjustmentEnabled(device) "Alignment is enabled, cannot start measurement."
    
    if getMeasurementEnabled(device)
        @info "Measurement already activated."; return
    end

    request(device,:system,"startMeasurement")

    return
end

"""
    stopMeasurement(device::D)

Stop IDS displacement measurement.
"""
function stopMeasurement(device::D)
    if !getMeasurementEnabled(device)
        @info "Measurement already deactivated."; return
    end
    
    request(device,:system,"stopMeasurement"); return
end



"""
    getAbsolutePosition(device::D,axis::Int)

Return absolute IDS position of `axis` (duh) in pm.
"""
function getAbsolutePosition(device::D,axis::Int)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    return request(device,:displace,"getAbsolutePosition";
        params=[axis-1])[2]
end

"""
    getAbsolutePositions(device::D)

Return absolute IDS positions of all axes (duh) in pm.
"""
function getAbsolutePositions(device::D)
    r = request(device,:displace,"getAbsolutePositions")

    return [r[2],r[3],r[4]]
end

"""
    getAbsolutePositions!(a::Vector{Int},device::D)

Write absolute IDS positions in pm directly to vector `a` of length 3, see
[`getAbsolutePositions`](@ref).
"""
function getAbsolutePositions!(a::Vector{Int},device::D)
    @assert length(a) == 3 "Position vector needs to be length 3."

    return a .= request(device,:displace,"getAbsolutePositions")[2:4]
end



"""
    getAxisDisplacement(device::D,axis::Int)

Get relative IDS position of `axis` in pm.
"""
function getAxisDisplacement(device::D,axis::Int)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    return request(device,:displace,"getAxisDisplacement";
        params=[axis-1])[2]
end

"""
    getAxesDisplacement(device::D)

Get relative IDS positions of all axes in pm.
"""
function getAxesDisplacement(device::D)
    r = request(device,:displace,"getAxesDisplacement")

    return [r[2],r[3],r[4]]
end

"""
    getAxesDisplacement!(a::Vector{Int},device::D)

Write relative IDS positions in pm directly to vector `a` of length 3, see
[`getAxesDisplacement`](@ref).
"""
function getAxesDisplacement!(a::Vector{Int},device::D)
    @assert length(a) == 3 "Position vector needs to be length 3."

    return a .= request(device,:displace,"getAxesDisplacement")[2:4]
end



"""
    getReferencePosition(device::D,axis::Int)

Get IDS reference position of `axis` (duh) in pm.
"""
function getReferencePosition(device::D,axis::Int)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    return request(device,:displace,"getReferencePosition";
        params=[axis-1])
end

"""
    getReferencePositions(device::D)

Get IDS reference position of all axes (duh) in pm.
"""
function getReferencePositions(device::D)
    r = request(device,:displace,"getReferencePositions")

    return [r[2],r[3],r[4]]
end

"""
    getReferencePositions!(a::Vector{Int},device::D)

Write IDS reference positions in pm directly to vector `a` of length 3, see
[`getReferencePositions`](@ref).
"""
function getReferencePositions!(a::Vector{Int},device::D)
    @assert length(a) == 3 "Position vector needs to be length 3."

    return a .= request(device,:displace,"getReferencePositions")[2:4]
end



"""
    getAxisSignalQuality(device::D,axis::Int; threshold::Int=850)

Return IDS signal quality in permille for `axis`. Gives warning if value exceeds `threshold`.
"""
function getAxisSignalQuality(device::D,axis::Int; threshold::Int=850)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    r = request(device,:displace,"getAxisSignalQuality"; params=[axis-1])

    if r[2]+r[3] > threshold
        @warn "Contrast threshold is reached for axis $axis with $(r[2]+r[3]) > $threshold."
    end

    return r[2], r[3]
end

"""
    getAxesSignalQuality(device::D; threshold::Int=850)

Return IDS signal quality in permille for all axes. Gives warning if values exceed `threshold`.
"""
function getAxesSignalQuality(device::D; threshold::Int=850)
    contrast = Vector{Int}(undef,3)

    for axis in 1:3
        c, offset = getAxisSignalQuality(device,axis; threshold=threshold)
        contrast[axis] = c+offset
    end

    return contrast
end

"""
    getAxesSignalQuality!(a::Vector{Int},device::D; threshold::Int=850)

Write IDS signal quality directly to vector `a` of length 3, see
[`getAxesSignalQuality`](@ref). Gives warning if values exceed `threshold`.
"""
function getAxesSignalQuality!(a::Vector{Int},device::D; threshold::Int=850)
    @assert length(a) == 3 "Signal vector needs to be length 3."

    for axis in 1:3
        c, offset = getAxisSignalQuality(device,axis; threshold=threshold)
        a[axis] = c+offset
    end

    return a
end



"""
    getAverageN(device::D)

I forgot what this function does, look it up in the manual lolololo
"""
function getAverageN(device::D)
    return request(device,:displace,"getAverageN")[2]
end

"""
    setAverageN(device::D,N::Int)

I forgot what this function does, look it up in the manual lolololo
"""
function setAverageN(device::D,N::Int)
    @assert 0 <= N <= 24 "N must be between 0 and 24 (inclusive)."

    request(device,:displace,"setAverageN"; params=[N]); return
end
