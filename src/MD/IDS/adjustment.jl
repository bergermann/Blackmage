

"""
    getAlignmentEnabled(sd::SingleDevice)

Return if IDS alignment mode is active for single device `sd`.
"""
function getAlignmentEnabled(sd::SingleDevice)
    return getAlignmentEnabled(sd.ids)
end

"""
    getAlignmentEnabled(md::MultiDevice)

Return if IDS alignment mode is active for all devices in multidevice `md`.
"""
function getAlignmentEnabled(md::MultiDevice)
    enabled = true

    for i in eachindex(md)
        enabled_ = getAlignmentEnabled(md[i]); enabled *= enabled_
        if !enabled_; println("Alignment not enabled for device $i."); end
    end
    
    return enabled
end



"""
    getContrast(sd::SingleDevice; threshold::Int=850)

Return IDS alignment mode contrast for all axes in permille for single device `sd`.
Gives warning if `threshold` is exceeded.
"""
function getContrast(sd::SingleDevice; threshold::Int=850)
    return getContrast(sd.ids; threshold=threshold)
end

"""
    getContrast!(contrast::Vector{Int},sd::SingleDevice; threshold::Int=850)

Update IDS alignment mode `contrast` for all axes in permille for single device `sd`.
Gives warning if `threshold` is exceeded.
"""
function getContrast!(contrast::Vector{Int},sd::SingleDevice; threshold::Int=850)
    return getContrast!(contrast,sd.ids; threshold=threshold)
end

"""
    getContrast(md::MultiDevice; threshold::Int=850)

Return IDS alignment mode contrast for all axes in permille for all devices in multidevice
`md`. Gives warning if `threshold` is exceeded.
"""
function getContrast(md::MultiDevice; threshold::Int=850)
    contrast = Dict{Int,Vector{Int}}()

    for i in eachindex(md)
        contrast[i] = getContrast(md[i]; threshold=threshold)
    end

    return contrast
end

"""
    getContrast!(contrast::Dict{Int,Vector{Int}},md::MultiDevice;
        threshold::Int=850)

Update existing IDS alignment mode `contrast` dict for all axes in permille for all devices
in multidevice `md`. Gives warning if `threshold` is exceeded.
"""
function getContrast!(contrast::Dict{Int,Vector{Int}},md::MultiDevice;
        threshold::Int=850)

    for i in eachindex(md)
        getContrast!(contrast[i],md[i]; threshold=threshold)
    end

    return
end