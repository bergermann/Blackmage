

### NYI from developers side
# function errorNumberToRecommendation(device::D,e::Int; l::Int=1)
#     @assert l == 0 || l == 1 "Error style `l` needs to be 0 or 1."

#     return request(device,:service,"errorNumberToRecommendation")[2]
# end


"""
    errorNumberToString(device::D,e::Int; l::Int=1)

Convert IDS error number to respective error message with verbosity level `l`.
"""
function errorNumberToString(device::D,e::Int; l::Int=1)
    @assert l == 0 || l == 1 "Error style `l` needs to be 0 or 1."

    return replace(request(device,:service,"errorNumberToString",
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
    showError(device::D,e::Int)

Print full error message corresponding to error number `e`.
"""
function showError(device::D,e::Int)
    println("Error: ",errorNumberToString(device,e; l=0))
    println(errorNumberToString(device,e; l=1))

    return
end
