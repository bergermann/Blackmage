
# FIX add sd variants?

"""
    getHumidityM(md::MultiDevice)

Return manually set ECU humidity in percent for all devices in multidevice `md`.
"""
function getHumidityM(md::MultiDevice)
    return Dict(i=>[getHumidityM(md[i].ids,axis) for axis in 1:3]
        for i in eachindex(md))
end

"""
    setHumidityM(md::MultiDevice,humidity::AbstractVector{Float64})

Manually set ECU humidity in percent for all devices in multidevice `md` in ascending order.
"""
function setHumidityM(md::MultiDevice,humidity::AbstractVector{Float64})
    @assert length(md) == length(humidity) "Length mismatch between device count and humidity."

    idx = 1; for i in sort!(keys(eachindex(md))), axis in 1:3
        setHumidityM(md[i].ids,axis,humidity[idx]); idx += 1
    end

    return
end

"""
    setHumidityM(md::MultiDevice,humidity::Float64)

Manually set ECU humidity in percent for all devices in multidevice `md`.
"""
function setHumidityM(md::MultiDevice,humidity::Float64)
    for i in eachindex(md), axis in 1:3
        setHumidityM(md[i].ids,axis,humidity)
    end; return
end

"""
    setHumidityM(md::MultiDevice,humidity::Dict{Int,Vector{Float64}})

Manually set ECU humidity in percent for all devices in multidevice `md`.
"""
function setHumidityM(md::MultiDevice,humidity::Dict{Int,Vector{Float64}})
    @assert all(k->haskey(md,k),keys(index)) "Key mismatch between device and pressure."

    for i in eachindex(md), axis in 1:3
        setHumidityM(md[i].ids,axis,humidity[i][axis])
    end

    return
end



"""
    getPressureM(md::MultiDevice)

Return manually set ECU pressure in hPa for all devices in multidevice `md`.
"""
function getPressureM(md::MultiDevice)
    return Dict(i=>[getPressureM(md[i].ids,axis) for axis in 1:3]
        for i in eachindex(md))
end

"""
    setPressureM(md::MultiDevice,pressure::AbstractArray{Float64})

Manually set ECU pressure in hPa for all devices in multidevice `md` in ascending order.
"""
function setPressureM(md::MultiDevice,pressure::AbstractVector{Float64})
    @assert length(md) == length(pressure) "Length mismatch between device count and pressure."

    idx = 1; for i in sort!(keys(eachindex(md))), axis in 1:3
        setPressureM(md[i].ids,axis,pressure[idx]); idx += 1
    end

    return
end

"""
    setPressureM(md::MultiDevice,pressure::Float64)

Manually set ECU pressure in hPa for all devices in multidevice `md`.
"""
function setPressureM(md::MultiDevice,pressure::Float64)
    for i in eachindex(md), axis in 1:3
        setPressure(md[i].ids,axis,pressure)
    end; return
end

"""
    setPressureM(md::MultiDevice,pressure::Dict{Int,Vector{Float64}})

Manually set ECU pressure in hPa for all devices in multidevice `md`.
"""
function setPressureM(md::MultiDevice,pressure::Dict{Int,Vector{Float64}})
    @assert all(k->haskey(md,k),keys(index)) "Key mismatch between device and pressure."

    for i in eachindex(md), axis in 1:3
        setPressureM(md[i].ids,axis,pressure[i][axis])
    end

    return
end



"""
    getTemperatureM(md::MultiDevice)

Return manually set ECU temperature in °C for all devices in multidevice `md`.
"""
function getTemperatureM(md::MultiDevice)
    return Dict(i=>[getTemperatureM(md[i].ids,axis) for axis in 1:3]
        for i in eachindex(md))
end

"""
    setTemperatureM(md::MultiDevice,temp::AbstractVector{Float64})

Manually set ECU temperature in °C for all devices in multidevice `md` in ascending order.
"""
function setTemperatureM(md::MultiDevice,temp::AbstractVector{Float64})
    @assert length(md) == length(temp) "Length mismatch between device count and temperature."

    idx = 1; for i in sort!(keys(eachindex(md))), axis in 1:3
        setTemperatureM(md[i].ids,axis,temp[idx]); idx += 1
    end

    return
end

"""
    setTemperatureM(md::MultiDevice,temp::Float64)

Manually set ECU temperature in °C for all devices in multidevice `md` in ascending order.
"""
function setTemperatureM(md::MultiDevice,temp::Float64)
    for i in eachindex(md), axis in 1:3
        setTemperatureM(md[i].ids,axis,temp)
    end; return
end

"""
    setTemperatureM(md::MultiDevice,temp::Dict{Int,Vector{Float64}})

Manually set ECU temperature in °C for all devices in multidevice `md`.
"""
function setTemperatureM(md::MultiDevice,temp::Dict{Int,Vector{Float64}})
    @assert all(k->haskey(md,k),keys(index)) "Key mismatch between device and temp."
    
    for i in eachindex(md), axis in 1:3
        setTemperatureM(md[i].ids,axis,temp[i][axis])
    end

    return
end



"""
    getRefractiveIndexM(md::MultiDevice)

Return manually set ECU refractive index for all devices in multidevice `md`.
"""
function getRefractiveIndexM(md::MultiDevice)
    return Dict(i=>[getRefractiveIndexM(md[i].ids,axis) for axis in 1:3]
        for i in eachindex(md))
end

"""
    setRefractiveIndexM(md::MultiDevice,index::AbstractVector{Float64})

Manually set ECU refractive index for all devices in multidevice `md` in ascending order.
"""
function setRefractiveIndexM(md::MultiDevice,index::AbstractVector{Float64})
    @assert length(md) == length(index) "Length mismatch between device count and index."

    idx = 1; for i in sort!(keys(eachindex(md))), axis in 1:3
        setRefractiveIndexM(md[i].ids,axis,index[idx]); idx += 1
    end

    return
end

"""
    setRefractiveIndexM(md::MultiDevice,index::Float64)

Manually set ECU refractive index for all devices in multidevice `md`.
"""
function setRefractiveIndexM(md::MultiDevice,index::Float64)
    for i in eachindex(md), axis in 1:3
        setRefractiveIndexM(md[i].ids,axis,index)
    end; return
end

"""
    setRefractiveIndexM(md::MultiDevice,index::Dict{Int,Vector{Float64}})

Manually set ECU refractive index for all devices in multidevice `md`.
"""
function setRefractiveIndexM(md::MultiDevice,index::Dict{Int,Vector{Float64}})
    @assert all(k->haskey(md,k),keys(index)) "Key mismatch between device and index."

    for i in eachindex(md), axis in 1:3
        setRefractiveIndexM(md[i].ids,axis,index[i][axis])
    end

    return
end