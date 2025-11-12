
"""
Strings to access different parts of the IDS interface.
"""
const interfaces = Base.ImmutableDict(
    :access     => "", # access,

    :adjust     => "com.attocube.ids.adjustment.",
    :axis       => "com.attocube.ids.axis.",
    :displace   => "com.attocube.ids.displacement.",
    # :nlc        => "com.attocube.ids.nlc.", # non-linearity compensation, not required
    :pilot      => "com.attocube.ids.pilotlaser.",
    :realtime   => "com.attocube.ids.realtime.",
    :system     => "com.attocube.ids.system.",

    :ecu        => "com.attocube.ecu.",
    :ecum       => "com.attocube.ecu.manual.",

    :about      => "com.attocube.system.about.",
    :network    => "com.attocube.system.network.",
    :service    => "com.attocube.system.",   # system service,
    :update     => "com.attocube.system.update.",
)

const I = interfaces