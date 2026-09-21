
@enum StateFCM::UInt8 FCM_OFF FCM_ON FCM_SEMI
@enum LogContext::UInt8 LC_IDLE_INIT LC_IDLE_TARGET LC_MOVING LC_CORRECTING

include("singledevice.jl")
include("multidevice.jl")
include("IDS/IDS.jl")
include("motor_control_SD.jl")
include("motor_control_MD.jl")
include("logging.jl")
