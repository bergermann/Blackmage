
@enum StateFCM::UInt8 FCM_OFF FCM_ON FCM_SEMI
@enum LogContext::UInt8 LC_IDLE_INIT LC_IDLE_TARGET LC_MOVING LC_CORRECTING

include("singledevice.jl")
include("multidevice.jl")
include("IDS/IDS.jl")
include("motor_control_SD.jl")
include("motor_control_MD.jl")
include("logging.jl")


function addMockLog_(md::MultiDevice)
    @assert isempty(md.devices) "Real devices present in multidevice"

    if length(md) > 0
        for i in eachindex(md)
            md.logger.apos[i] = [0,0,0]
            md.logger.rpos[i] = [0,0,0]
            md.logger.contrast[i] = [0,0,0]
        end
    else
        md.logger.apos[1] = [0,0,0]
        md.logger.rpos[1] = [0,0,0]
        md.logger.contrast[1] = [0,0,0]
    end

    return
end
