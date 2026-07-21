

"""
    getAlignmentEnabled(sd::SingleDevice,req::Dict)

Return if IDS alignment mode is active for single device `sd`.
"""
function getAlignmentEnabled(sd::SingleDevice,req::Dict)
    return getAlignmentEnabled(sd.ids,req)
end

"""
    getAlignmentEnabled(md::MultiDevice,req::Dict)

Return if IDS alignment mode is active for all devices in multidevice `md`.
"""
function getAlignmentEnabled(md::MultiDevice,req::Dict)
    enabled = true

    for i in eachindex(md)
        enabled_ = getAlignmentEnabled(md[i],req); enabled *= enabled_
        if !enabled_; println("Alignment not enabled for device $i."); end
    end
    
    return enabled
end



"""
    getContrast(sd::SingleDevice,req::Dict; threshold::Int=850)

Return IDS alignment mode contrast for all axes in permille for single device `sd`.
Gives warning if `threshold` is exceeded.
"""
function getContrast(sd::SingleDevice,req::Dict; threshold::Int=850)
    return getContrast(sd.ids,req; threshold=threshold)
end

"""
    getContrast(md::MultiDevice,req::Dict; threshold::Int=850)

Return IDS alignment mode contrast for all axes in permille for all devices in multidevice
`md`. Gives warning if `threshold` is exceeded.
"""
function getContrast(md::MultiDevice,req::Dict; threshold::Int=850)
    contrast = Dict{Int,Vector{Int}}()

    for i in eachindex(md)
        contrast[i] = getContrast(md[i],req; threshold=threshold)
    end

    return contrast
end
