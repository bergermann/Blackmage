# Bug fixes

| # | File:Line | Bug | Fix |
|---|-----------|-----|-----|
| 1 | `MD/IDS/measurement.jl:182` | `resetAxes(::SingleDevice)` called itself → **StackOverflow** | `resetAxes(sd,req)` → `resetAxes(sd.ids,req)` |
| 2 | `MD/multidevice.jl:83,187` | `setproperty!(::MultiDevice)` called itself → **StackOverflow**; struct was immutable | `setproperty!(md,…)` → `setfield!(md,…)`; `struct` → `mutable struct` |
| 3 | `MD/motor_control_SD.jl:29` | `mcEnableFCM(::SingleDevice)` used undefined `ds` and field `maxdist` | `ds.freq.*` → `sd.settings.freq.*`; `maxdist` → `flexdist` |
| 4 | `MD/IDS/adjustment.jl:8,36` | `getAlignmentEnabled`/`getContrast` single-device method mistyped `::MultiDevice` (has no `.ids`), overwritten by loop method | `::MultiDevice` → `::SingleDevice` |
| 5 | `MD/IDS/ecu.jl:91` | `getECUConnected` loop used `md.ids` (no such field), ignored index | `md.ids` → `md[i]` |
| 6 | `MD/motor_control_MD.jl:231` | `mcTargetP(md)` passed unit `:p0` (not in `units`) → `KeyError` | `:p0` → `:m` |
| 7 | `MD/motor_control_MD.jl:345` | `mcStatusFCM` gave `Dict` 4 type params | `Dict{Int,Tuple{Bool},Vector{Bool},Vector{Int}}` → `Dict{Int,Tuple{Bool,Vector{Bool},Vector{Int}}}` |
| 8 | `MD/IDS/manual.jl:89` | `setPressureM` called non-existent `setPressure` | `setPressure` → `setPressureM` |
| 9 | `MD/IDS/manual.jl:46,99,152` | Dict variants referenced undefined `index` | `keys(index)` → `keys(humidity)`/`keys(pressure)`/`keys(temp)` |
| 10 | `MD/IDS/manual.jl:22,75,128,181` | `sort!(keys(eachindex(md)))` — can't sort a key set | → `sort!(collect(eachindex(md)))` |
| 11 | `MD/motor_control_OL.jl:67` vs `MD/motor_control_SD.jl:9` | duplicate `mcStopAllMotors(::SingleDevice)`: the OL body (no `stateFCM` update) silently overwrote the SD body → wrong FCM state after a stop, **and breaks precompilation on Julia 1.12** | removed the OL duplicate; SD body (updates `stateFCM`, delegates to MC loop) survives |
| 12 | `MC/motor_control_tilts.jl:58` | `pos2tilt` returned `asin(n1/n_)` **twice** → ytilt always equalled xtilt (`n2` was computed but unused) | 2nd tilt → `asin(n2/n_)` |
| 13 | `MD/singledevice.jl:142,144` | `update!(::SingleState,target,xtilt,ytilt)`: `state.xilt` (no such field → `FieldError`) and undefined `dz` | `xilt`→`xtilt`; `dz`→`target` |
| 14 | `MD/multidevice.jl:133` | `MultiDevice(...; masters=…)` built `DiscSettings()` → per-device master axis silently ignored (always 1) | `DiscSettings(master=masters[i])` |
| 15 | `MD/motor_control_SD.jl:182,190` | `mcTargetP(sd[,target]; kwargs...)` splatted kwargs **positionally** (`,kwargs...`) → `MethodError` whenever a kwarg was passed | `; kwargs...` |
| 16 | `MD/motor_control_MD.jl:216` | `mcTargetP(md,::Dict; kwargs...)` silently dropped kwargs (`= mcTargetP(md,target,:m)`) | forward `; kwargs...` |
| 17 | `IDS/measurement.jl:214` | `getAxesSignalQuality!` referenced `threshold` but declared no such kwarg → `UndefVarError` | add `; threshold::Int=850` |
| 18 | `IDS/manual.jl:112` | `setTemperatureM` sent rpc `"setPressureInHPa"` → **set pressure instead of temperature** | → `"setTemperatureInDegrees"` |
| 19 | `IDS/IDS.jl:74` | `request` error branch did `msg[error]` (the `error` **function** as key) → `KeyError` masking the real device error | → `msg["error"]` |
| 20 | `MC/motor_control_FL.jl:154,158` | `mcTarget` (FL tilt variant) indexed `dz[i]` with undefined `i` (loop var is `addr`) → `UndefVarError` | → `dz[addr]` |
