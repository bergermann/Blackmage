


"""
    getAlignmentEnabled(device::D)

Return if IDS alignment mode is active.
"""
function getAlignmentEnabled(device::D)
    return request(device,:adjust,"getAdjustmentEnabled")[2]
end

const getAdjustmentEnabled = getAlignmentEnabled

"""
    startAlignment(device::D; dt::Real=0.5,timeout::Real=60)

Start IDS alignment mode. If not started for `timeout` seconds, check for errors. Checks
every `dt` seconds.
"""
function startAlignment(device::D; dt::Real=0.5,timeout::Real=60)
    if getAdjustmentEnabled(device)
        @warn "Alignment already activated."; return
    end

    request(device,:system,"startOpticsAlignment")
    
    t = 0
    while !getAdjustmentEnabled(device)
        sleep(dt); t += dt

        if t > timeout
            @warn "Alignment still not activated after $timeout seconds."; break
        end
    end
    
    return
end

const startOpticsAlignment = startAlignment

"""
    stopAlignment(device::D)

Stop IDS alignment mode (duh).
"""
function stopAlignment(device::D)
    if !getAdjustmentEnabled(device)
        @warn "Alignment already deactivated."; return
    end

    request(device,:system,"stopOpticsAlignment"); return
end

const stopOpticsAlignment = stopAlignment



"""
    getContrast(device::D,axis::Int; threshold::Int=850)

Return IDS alignment mode contrast for `axis` in permille. Gives warning if `threshold` is
exceeded.
"""
function getContrast(device::D,axis::Int; threshold::Int=850)
    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    r = request(device,:adjust,"getContrastInPermille";
        params=[axis-1])

    if r[2]+r[3] > threshold
        @warn "Contrast threshold is reached for axis $axis with $(r[2]+r[3]) > $threshold."
    end

    return r[2], r[3], r[4]
end

"""
    getContrast(device::D; threshold::Int=850)

Return IDS alignment mode contrast for all axes in permille. Gives warning if `threshold` is
exceeded.
"""
function getContrast(device::D; threshold::Int=850)
    contrast = Vector{Int}(undef,3)

    for axis in 1:3
        c, offset, _ = getContrast(device,axis; threshold=threshold)
        contrast[axis] = c+offset
    end

    return contrast
end

"""
    getContrast!(contrast::Vector{Int},device::D; threshold::Int=850)

Update existing IDS alignment mode `contrast` for all axes in permille. Gives warning if
`threshold` is exceeded.
"""
function getContrast!(contrast::Vector{Int},device::D; threshold::Int=850)
    for axis in 1:3
        c, offset, _ = getContrast(device,axis; threshold=threshold)
        contrast[axis] = c+offset
    end

    return
end

const getContrastInPermille  = getContrast
const getContrastInPermille! = getContrast!