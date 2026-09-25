
__precompile__(true)

"""
    Blackmage

Control interface for combined Attocube IDS system and JPE CADM4/FCM2 motor controllers.
"""
module Blackmage

export units

using Sockets, Dates, JSON
export connect, TCPSocket, now, @ip_str

export Displacement, req    # IDS

export getAlignmentEnabled, startAlignment, stopAlignment, getContrast, getContrast!  # adjustment

export enableECU, disableECU    # ECU
export getECUEnabled, getECUConnected
export getHumidity, getPressure, getTemperature, getRefractiveIndex

export getHumidityM, setHumidityM   # manual
export getPressureM, setPressureM
export getTemperatureM, setTemperatureM
export getRefractiveIndexM, setRefractiveIndexM

export getMeasurementEnabled, startMeasurement, stopMeasurement # measurement
export getAbsolutePosition, getAbsolutePositions, getAbsolutePositions!
export getAxisDisplacement, getAxesDisplacement, getAxesDisplacement!
export getReferencePosition, getReferencePositions
export getAxisSignalQuality, getAxesSignalQuality, getAxesSignalQuality!

export enablePL, disablePL  # pilot

export getCurrentMode, getDeviceType    # system
export getSystemError, resetError
export getInitMode, setInitMode
export resetAxis, resetAxes
export getMasterAxis, setMasterAxis
export getPassMode, setPassMode

export record!, stop_record!, measurePos    # record
export plot



export metric2ids   # MC
export mcVersion

export mcVersion, mcMods, mcModuleSlot, mcStages    # MC system
export mcGetIP, mcSetIP

export mcMove, mcStop, mcStopAllMotors  # MC OL

export mcEnableFCM, mcDisableFCM, mcSetupFCM, mcReSetupFCM, mcStopAll   # MC CL
export mcTargetFCM, mcWaitForTarget, mcStatusFCM, mcTargetP
export autoAlign

export mcTarget, mcWait, mcMoveDirect   # MC FL

export tilt2pos, pos2tilt, kart2cyl, cyl2kart

export DiscSettings, Boundaries, SingleState, SingleDevice, MultiDeviceSettings, MultiDevice  # MD
export mcZero
export getAbsPos, getAbsPos!, getRelPos, getRelPos!, getRefPos, getRefPos!
export getSignal, getSignal!

export updateLog!, LogContext, LC_IDLE_INIT, LC_IDLE_TARGET, LC_MOVING, LC_CORRECTING



include("socketing.jl")
include("IDS/IDS.jl")
include("MC/MC.jl")
include("MD/MD.jl")

end

# to fix:
# add axes(device,axis) functions
# interrupt race condition?

# todo:
# make mcTargetP(md) write to and use logger data
# target settings, target validation
# add timeout to mcWait(md)
# proper log writing
# split raw IDS and MC controls into new packages?
# add tilt corrections to mcTarget(md) (revisit motor_control_FL)
# add lower threshold to getAxisSignalQuality?
# streamline exported names
# create individual precision correction function
# move config loading from whitemage to here