


"""
    getHumidityM(md::MultiDevice,req::Dict,axis::Int)

Return manually set ECU humidity in percent for all devices in multidevice `md`.
"""
function getHumidityM(md::MultiDevice,req::Dict,axis::Int)
    return Dict(i=>getHumidityM(md.ids[i],req,axis) for i in eachindex(md))
end

"""
    setHumidityM(md::MultiDevice,req::Dict,axis::Int,humidity::AbstractArray{Float64})

Manually set ECU humidity in percent for all devices in multidevice `md` in ascending order.
"""
function setHumidityM(md::MultiDevice,req::Dict,axis::Int,humidity::AbstractArray{Float64})
    @assert length(md) == length(humidity) "Length mismatch between device count and humidity."

    idx = 1; for i in sort!(keys(eachindex(md)))
        setHumidityM(md.ids[i],req,axis,humidity[i]); idx += 1
    end

    return
end

"""
    setHumidityM(md::MultiDevice,req::Dict,axis::Int,humidity::Float64)

Manually set ECU humidity in percent for all devices in multidevice `md`.
"""
function setHumidityM(md::MultiDevice,req::Dict,axis::Int,humidity::Float64)
    for i in eachindex(md)
        setHumidityM(md.ids[i],req,axis,humidity)
    end; return
end


"""
    getPressureM(md::MultiDevice,req::Dict,axis::Int)

Return manually set ECU pressure in hPa for all devices in multidevice `md`.
"""
function getPressureM(md::MultiDevice,req::Dict,axis::Int)
    return Dict(i=>getPressureM(md.ids[i],req,axis) for i in eachindex(md))
end

"""
    setPressureM(md::MultiDevice,req::Dict,axis::Int,pressure::AbstractArray{Float64})

Manually set ECU pressure in hPa for all devices in multidevice `md` in ascending order.
"""
function setPressureM(md::MultiDevice,req::Dict,axis::Int,pressure::AbstractArray{Float64})
    @assert length(md) == length(pressure) "Length mismatch between device count and pressure."

    idx = 1; for i in sort!(keys(eachindex(md)))
        setPressureM(md.ids[i],req,axis,pressure[i]); idx += 1
    end

    return
end

"""
    setPressureM(md::MultiDevice,req::Dict,axis::Int,pressure::Float64)

Manually set ECU pressure in hPa for all devices in multidevice `md`.
"""
function setPressureM(md::MultiDevice,req::Dict,axis::Int,pressure::Float64)
    for i in eachindex(md)
        setPressure(md.ids[i],req,axis,pressure)
    end; return
end



"""
    getTemperatureM(md::MultiDevice,req::Dict,axis::Int)

Return manually set ECU temperature in °C for all devices in multidevice `md`.
"""
function getTemperatureM(md::MultiDevice,req::Dict,axis::Int)
    return Dict(i=>getTemperatureM(md.ids[i],req,axis) for i in eachindex(md))
end

"""
    setTemperatureM(md::MultiDevice,req::Dict,axis::Int,temp::AbstractArray{Float64})

Manually set ECU temperature in °C for all devices in multidevice `md` in ascending order.
"""
function setTemperatureM(md::MultiDevice,req::Dict,axis::Int,temp::AbstractArray{Float64})
    @assert length(md) == length(temp) "Length mismatch between device count and temperature."

    idx = 1; for i in sort!(keys(eachindex(md)))
        setTemperatureM(md.ids[i],req,axis,temp[i]); idx += 1
    end

    return
end

"""
    setTemperatureM(md::MultiDevice,req::Dict,axis::Int,temp::Float64)

Manually set ECU temperature in °C for all devices in multidevice `md` in ascending order.
"""
function setTemperatureM(md::MultiDevice,req::Dict,axis::Int,temp::Float64)
    for i in eachindex(md)
        setTemperatureM(md.ids[i],req,axis,temp)
    end; return
end


"""
    getRefractiveIndexM(md::MultiDevice,req::Dict,axis::Int)

Return manually set ECU refractive index for all devices in multidevice `md`.
"""
function getRefractiveIndexM(md::MultiDevice,req::Dict,axis::Int)
    return Dict(i=>getRefractiveIndexM(md.ids[i],req,axis) for i in eachindex(md))
end

"""
    setRefractiveIndexM(md::MultiDevice,req::Dict,axis::Int,index::AbstractArray{Float64})

Manually set ECU refractive index for all devices in multidevice `md` in ascending order.
"""
function setRefractiveIndexM(md::MultiDevice,req::Dict,axis::Int,index::AbstractArray{Float64})
    @assert length(md) == length(index) "Length mismatch between device count and index."

    idx = 1; for i in sort!(keys(eachindex(md)))
        setRefractiveIndexM(md.ids[i],req,axis,index[i]); idx += 1
    end

    return
end

"""
    setRefractiveIndexM(md::MultiDevice,req::Dict,axis::Int,index::Float64)

Manually set ECU refractive index for all devices in multidevice `md` in ascending order.
"""
function setRefractiveIndexM(md::MultiDevice,req::Dict,axis::Int,index::Float64)
    for i in eachindex(md)
        setRefractiveIndexM(md.ids[i],req,axis,index)
    end; return
end

