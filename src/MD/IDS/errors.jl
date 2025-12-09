

### NYI from developers side
# function errorNumberToRecommendation(device::D,req::Dict,e::Int; l::Int=1)
#     @assert l == 0 || l == 1 "Error style `l` needs to be 0 or 1."

#     return request(device,req,:service,"errorNumberToRecommendation")[2]
# end


"""
    errorNumberToString(device::D,req::Dict,e::Int; l::Int=1)

Convert IDS error number to respective error message with verbosity level `l`.
"""
function errorNumberToString(device::D,req::Dict,e::Int; l::Int=1)
    @assert l == 0 || l == 1 "Error style `l` needs to be 0 or 1."

    return replace(request(device,req,:service,"errorNumberToString",
        params=[l,e])[2],
        "AXIS_0" => "AXIS_1",
        "AXIS_1" => "AXIS_2",
        "AXIS_2" => "AXIS_3",
        "axis 0" => "axis 1",
        "axis 1" => "axis 2",
        "axis 2" => "axis 3",
        )
end

"""
    showError(device::D,req::Dict,e::Int)

Print full error message corresponding to error number `e`.
"""
function showError(device::D,req::Dict,e::Int)
    println("Error: ",errorNumberToString(device,req,e; l=0))
    println(errorNumberToString(device,req,e; l=1))

    return
end
