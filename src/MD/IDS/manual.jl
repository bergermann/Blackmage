


"""
    getHumidityM(md::MultiDevice,req::Dict)

Return manually set ECU humidity in percent for all devices in multidevice `md`.
"""
function getHumidityM(md::MultiDevice,req::Dict)
    return Dict(i=>[getHumidityM(md[i].ids,req,axis) for axis in 1:3]
        for i in eachindex(md))
end

"""
    setHumidityM(md::MultiDevice,req::Dict,humidity::AbstractVector{Float64})

Manually set ECU humidity in percent for all devices in multidevice `md` in ascending order.
"""
function setHumidityM(md::MultiDevice,req::Dict,humidity::AbstractVector{Float64})
    @assert length(md) == length(humidity) "Length mismatch between device count and humidity."

    idx = 1; for i in sort!(keys(eachindex(md))), axis in 1:3
        setHumidityM(md[i].ids,req,axis,humidity[idx]); idx += 1
    end

    return
end

"""
    setHumidityM(md::MultiDevice,req::Dict,humidity::Float64)

Manually set ECU humidity in percent for all devices in multidevice `md`.
"""
function setHumidityM(md::MultiDevice,req::Dict,humidity::Float64)
    for i in eachindex(md), axis in 1:3
        setHumidityM(md[i].ids,req,axis,humidity)
    end; return
end

"""
    setHumidityM(md::MultiDevice,req::Dict,humidity::Dict{Int,Vector{Float64}})

Manually set ECU humidity in percent for all devices in multidevice `md`.
"""
function setHumidityM(md::MultiDevice,req::Dict,humidity::Dict{Int,Vector{Float64}})
    @assert all(k->haskey(md,k),keys(index)) "Key mismatch between device and pressure."

    for i in eachindex(md), axis in 1:3
        setHumidityM(md[i].ids,req,axis,humidity[i][axis])
    end

    return
end



"""
    getPressureM(md::MultiDevice,req::Dict)

Return manually set ECU pressure in hPa for all devices in multidevice `md`.
"""
function getPressureM(md::MultiDevice,req::Dict)
    return Dict(i=>[getPressureM(md[i].ids,req,axis) for axis in 1:3]
        for i in eachindex(md))
end

"""
    setPressureM(md::MultiDevice,req::Dict,pressure::AbstractArray{Float64})

Manually set ECU pressure in hPa for all devices in multidevice `md` in ascending order.
"""
function setPressureM(md::MultiDevice,req::Dict,pressure::AbstractVector{Float64})
    @assert length(md) == length(pressure) "Length mismatch between device count and pressure."

    idx = 1; for i in sort!(keys(eachindex(md))), axis in 1:3
        setPressureM(md[i].ids,req,axis,pressure[idx]); idx += 1
    end

    return
end

"""
    setPressureM(md::MultiDevice,req::Dict,pressure::Float64)

Manually set ECU pressure in hPa for all devices in multidevice `md`.
"""
function setPressureM(md::MultiDevice,req::Dict,pressure::Float64)
    for i in eachindex(md), axis in 1:3
        setPressure(md[i].ids,req,axis,pressure)
    end; return
end

"""
    setPressureM(md::MultiDevice,req::Dict,pressure::Dict{Int,Vector{Float64}})

Manually set ECU pressure in hPa for all devices in multidevice `md`.
"""
function setPressureM(md::MultiDevice,req::Dict,pressure::Dict{Int,Vector{Float64}})
    @assert all(k->haskey(md,k),keys(index)) "Key mismatch between device and pressure."

    for i in eachindex(md), axis in 1:3
        setPressureM(md[i].ids,req,axis,pressure[i][axis])
    end

    return
end



"""
    getTemperatureM(md::MultiDevice,req::Dict)

Return manually set ECU temperature in °C for all devices in multidevice `md`.
"""
function getTemperatureM(md::MultiDevice,req::Dict)
    return Dict(i=>[getTemperatureM(md[i].ids,req,axis) for axis in 1:3]
        for i in eachindex(md))
end

"""
    setTemperatureM(md::MultiDevice,req::Dict,temp::AbstractVector{Float64})

Manually set ECU temperature in °C for all devices in multidevice `md` in ascending order.
"""
function setTemperatureM(md::MultiDevice,req::Dict,temp::AbstractVector{Float64})
    @assert length(md) == length(temp) "Length mismatch between device count and temperature."

    idx = 1; for i in sort!(keys(eachindex(md))), axis in 1:3
        setTemperatureM(md[i].ids,req,axis,temp[idx]); idx += 1
    end

    return
end

"""
    setTemperatureM(md::MultiDevice,req::Dict,temp::Float64)

Manually set ECU temperature in °C for all devices in multidevice `md` in ascending order.
"""
function setTemperatureM(md::MultiDevice,req::Dict,temp::Float64)
    for i in eachindex(md), axis in 1:3
        setTemperatureM(md[i].ids,req,axis,temp)
    end; return
end

"""
    setTemperatureM(md::MultiDevice,req::Dict,temp::Dict{Int,Vector{Float64}})

Manually set ECU temperature in °C for all devices in multidevice `md`.
"""
function setTemperatureM(md::MultiDevice,req::Dict,temp::Dict{Int,Vector{Float64}})
    @assert all(k->haskey(md,k),keys(index)) "Key mismatch between device and temp."
    
    for i in eachindex(md), axis in 1:3
        setTemperatureM(md[i].ids,req,axis,temp[i][axis])
    end

    return
end



"""
    getRefractiveIndexM(md::MultiDevice,req::Dict)

Return manually set ECU refractive index for all devices in multidevice `md`.
"""
function getRefractiveIndexM(md::MultiDevice,req::Dict)
    return Dict(i=>[getRefractiveIndexM(md[i].ids,req,axis) for axis in 1:3]
        for i in eachindex(md))
end

"""
    setRefractiveIndexM(md::MultiDevice,req::Dict,index::AbstractVector{Float64})

Manually set ECU refractive index for all devices in multidevice `md` in ascending order.
"""
function setRefractiveIndexM(md::MultiDevice,req::Dict,index::AbstractVector{Float64})
    @assert length(md) == length(index) "Length mismatch between device count and index."

    idx = 1; for i in sort!(keys(eachindex(md))), axis in 1:3
        setRefractiveIndexM(md[i].ids,req,axis,index[idx]); idx += 1
    end

    return
end

"""
    setRefractiveIndexM(md::MultiDevice,req::Dict,index::Float64)

Manually set ECU refractive index for all devices in multidevice `md`.
"""
function setRefractiveIndexM(md::MultiDevice,req::Dict,index::Float64)
    for i in eachindex(md), axis in 1:3
        setRefractiveIndexM(md[i].ids,req,axis,index)
    end; return
end

"""
    setRefractiveIndexM(md::MultiDevice,req::Dict,index::Dict{Int,Vector{Float64}})

Manually set ECU refractive index for all devices in multidevice `md`.
"""
function setRefractiveIndexM(md::MultiDevice,req::Dict,index::Dict{Int,Vector{Float64}})
    @assert all(k->haskey(md,k),keys(index)) "Key mismatch between device and index."

    for i in eachindex(md), axis in 1:3
        setRefractiveIndexM(md[i].ids,req,axis,index[i][axis])
    end

    return
end