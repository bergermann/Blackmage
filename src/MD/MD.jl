
@enum StateFCM FCM_OFF FCM_ON FCM_SEMI

include("singledevice.jl")
include("multidevice.jl")
include("IDS/IDS.jl")
include("motor_control_SD.jl")
include("motor_control_MD.jl")
include("motor_control_OL.jl")
include("logging.jl")


function addMockLog_(md::MultiDevice)
    @assert isempty(md.devices) "Real devices present in multidevice"

    md.logger.apos[1] = [0,0,0]
    md.logger.rpos[1] = [0,0,0]
    md.logger.contrast[1] = [0,0,0]

    return
end