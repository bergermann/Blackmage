

"""
    getAlignmentEnabled(md::MultiDevice,req::Dict)

Return if IDS alignment mode is active for all devices in multidevice `md`.
"""
function getAlignmentEnabled(md::MultiDevice,req::Dict)
    for i in eachindex(md.ids)
        getAlignmentEnabled(md.ids[i],req)
    end; return
end


"""

Return IDS alignment mode contrast for `axis` 
Gives warning if `threshold` is exceeded.
"""
function getContrast(md::MultiDevice,req::Dict,axis::Int; threshold::Int=850)

    @assert 1 <= axis <= 3 "Axis index must be 1, 2 or 3."

    r = request(device,req,:adjust,"getContrastInPermille";
        params=[axis-1])

    if r[2]+r[3] > threshold
        @warn "Contrast threshold is reached for axis $axis with $(r[2]+r[3]) > $threshold."
    end

    return r[2], r[3], r[4]
end

"""
    getContrast(md::MultiDevice,req::Dict,axis::Int; threshold::Int=850)

Return IDS alignment mode contrast for all axes in permille for all devices in multidevice
`md`. Gives warning if `threshold` is exceeded.
"""
function getContrast(device::D,req::Dict; threshold::Int=850)
    contrast = Dict{Int,Tuple{}}
    contrast = Vector{Int}(undef,3)

    for axis in 1:3
        c, offset, _ = getContrast(device,req,axis; threshold=threshold)
        contrast[axis] = c+offset
    end

    return contrast
end

const getContrastInPermille = getContrast