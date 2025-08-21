--Ice Simulator v1.21
--adding reset logic for stopover
--DONE new athmosphere model
--DONE bug found concorde inlet - annoying repeating sound enginesarecommingon and second fail when heaters are off - completely mad, huh?
--DONE track why inlet0 on concorde eng0fail does not fail, only when inlet is on later
--DONE remove debug sounds
--DONE adjusted a bit coefs
--DONE all old datarefs linked hotfix
--DONE hotfix for pausedsim again
--DONE adjusting all variables to lower coef
--DONE bug found in cloud check, if in clouds then resets to 0 and badweather does not work  -  never
--DONE fixed crash of xplane caused probably by negative square root - altitude below 0
--Simulates Xplane 11.30b icing on airplanes type 737
--v1.14 solving latest FlywithLua 2.7 forcing plugin moving to quarantine
--DONE cessna eng anti-ice bug fixed
--DONE fixed UEEE Yakutsk 48C limit
--DONE fixed 833khz VHF2 bug
--DONE fixed Zibo B738 v3.34+ windows heat bug
--DONE fixed C47/DC3 wings boot bug
--DONE need test Zibo for MAXMACH is more than 0.8? if yes use instead of ACFTYPE MAXMEX > 0.81
--DONE adding optimisation for concorde
--DONE 2391 line tweak code for random generator, generate type of fail by randgen
--DONE add datarefs for idle power engines for medfail scenario where must be idle for recovery
--DONE testing Inlet0 and Inlet1 scenarios, could cause problems
--DONE remove DEBUG sounds in window cloud section before release
--DONE add recognition for 2 and 4 engines planes
--DONE add Inlet1 using previous 2 engines max. affected - at 4 engines inlet1 can cause inlet0 fail, carefull culd be buggy
--DONE v1.1 should be for all aircrafts by weight
--DONE adding clearsky fix
--DONE fixed inclouds seems not work
--DONE testing inclouds icing, seems too big sometimes
--working version for all, not optimized for all ACF
--BUGS: -- RESOLVED Window heat not work on zibo (has no std window heat)
      -- RESOLVED do Window +OAT section to prevent freezing at high temperatures
	  -- RESOLVED Cessna no heat window
	  -- RESOLVED Cessna seen 3.0 heat window reproduce during climb at low + OAT
	  -- RESOLVED Seems freezing on left and right pitot is same not different
	  -- RESOLVED do same hierarchy for AoA and Windows heat like Pitots you did
	  -- RESOLVED correct factors according physics (eg.if its get hotter sensor heats up)
	  -- RESOLVED inlet is freezing when engine AI is on too fast
	  -- RESOLVED inlet fail no flame out correct it (needs 6 instead of 1)
	  -- RESOLVED flameout dont resolve from fail, still 6
	  -- RESOLVED flameout do with delay inside limit from os clock or wind coef, v095b solution dont work
	  -- RESOLVED physics say +2C to -20 (-40C phys limit) of SAT is freezing area
	  -- DONE add incloud icing (dataref in meters in weather, but no visibility maybe effective dataref)
	  -- DONE add copilot sounds for alerts (separate function triggered on counter)
	  -- RESOLVED Window failure temporary disabled for debugging inlet values
	  -- RESOLVED arctic eng fail scenario not possible to recover due to low temps everywhere?
	  -- RESOLVED high fly over FL200 and no clouds should be no more icing
	  -- RESOLVED no ground wing icing, but too fast, within 3 minutes, needs change the step value
	  -- DONE incorporate ACF value for weight of aircraft (maybe later V2?)
	  -- RESOLVED no ground de-ice  - > make timer and/or call xplane vehicle by some universal radio button
	  -- DONE static needs to be created too or bound it to pitot
	  -- RESOLVED all step values are now obsolete, need adjust them everywhere to lower numbers (0.000X)
	  -- RESOLVED make somethingishappening available alltime or twice, do same with icingcondition sound if OK
	  -- DONE include incloud icing into tested window section to all conditions like below -40°C is
	  -- RESOLVED wing icing under heavy snow is too fast - lower values
	  -- RESOLVED pitot2 and static1+2 after 5 minutes ground deice and freq switch off  is not 0 (slowing down only)
	  -- RESOLVED during ground deice after sudden freq swicth all is deiced forever (solve by prepared else but has issues)
	  -- RESOLVED by new addon formula - default xplane logic beta 6 cause stat logic error and others too
	  -- RESOLVED wing antiice needs to be corrected because on large jets (707/747) its rarely used - use heavy ACF and wing area coef
	  -- RESOLVED ..continued.. and few times per season on 737/757
	  -- DONE adjust high and low altitude freeze coeficients for speed and wind force according to physics everywhere
	  -- DONE track bug window not freezing after landing
	  -- RESOVED  adjust heavy clouds- too fast on ground
	  -- DONE 767 static needs to be bound to window heat
	  -- DONE 777 has pitot heat bound to wing anti-ice switch
	  -- DONE TESTING 747-8 needs to bound pitot2 o pitot 1
	  -- DONE C172 add prop ice bound to inlet?
	  -- DONE prop heat progress -  datarefs set, now functions and defining coeficients
      -- DONE TESTING heavy snow too fast icing everywhere caused by high coefs
	  -- DONE on ground during winter cold no snow 737 no wing freezing, add coef for 0 to 6000ft 1.8 or so
	  -- DONE add DC3 surface_boot_on as wind_deice for old planes
	  -- RESOLVED reported pausing the sim keeps growing - made pause sim hold calculations
	  -- DONE test the Concorde below 20K low speed
--datarefs definitions
--alternative random generator oscilating from 0 to 1, staying below 0.01 most of the time
dataref("RANGEN", "sim/cockpit/radios/transponder_brightness", "readonly") 
--engine throttles position/elevation
dataref("throttleno1", "sim/cockpit2/engine/actuators/throttle_ratio", "readonly", 0)
dataref("throttleno2", "sim/cockpit2/engine/actuators/throttle_ratio", "readonly", 1)
dataref("throttleno3", "sim/cockpit2/engine/actuators/throttle_ratio", "readonly", 2)
dataref("throttleno4", "sim/cockpit2/engine/actuators/throttle_ratio", "readonly", 3)
dataref("dowehavepower", "sim/cockpit2/engine/actuators/throttle_ratio_all", "readonly")
--paused sim?
dataref("paused_sim", "sim/time/paused", "readonly") --pause bug resolver
-- Engine type
dataref("ENGTYPE", "sim/aircraft/prop/acf_en_type", "readonly", 0) --piston or fan?
-- Number of engines
dataref("ENGINES", "sim/aircraft/engine/acf_num_engines", "readonly") --how many?
--ZFW:
dataref("ZFW", "sim/aircraft/weight/acf_m_empty", "readonly") --kgs
--Current aircraft weight
dataref("ACWG", "sim/flightmodel/weight/m_total", "readonly")
--Current fuel weight
dataref("MAXMACH", "sim/aircraft/engine/acf_max_mach_eff", "readonly")
--Current fuel weight
dataref("FOB", "sim/flightmodel/weight/m_fuel_total", "readonly")
--Current payload weight writable
--dataref("PAYLD", "sim/flightmodel/weight/m_fixed", "writable")
dataref("PAYLD", "sim/flightmodel/weight/m_fixed", "readonly")
--MaxWeight
dataref("MAXW", "sim/aircraft/weight/acf_m_max", "readonly")
--OAT:
dataref("OAT", "sim/cockpit2/temperature/outside_air_temp_degc", "readonly")
--Aircraft surface temperature
dataref("TAT", "sim/weather/temperature_le_c", "readonly")
--Visibility (low has freezing fog)
dataref("FOG", "sim/weather/visibility_reported_m", "readonly")
--Air density
dataref("AIRDENS", "sim/weather/rho", "readonly")
dataref("ATMODENS", "sim/weather/sigma", "readonly")
--Humidity
dataref("HUMID", "sim/weather/relative_humidity_sealevel_percent", "readonly")
--pressure
dataref("CPRESSURE", "sim/weather/barometer_current_inhg", "readonly")
--Antiice switch for check
dataref("AOA_ON", "sim/cockpit2/ice/ice_AOA_heat_on", "readonly")
dataref("AOA_ON_old", "sim/cockpit/switches/anti_ice_AOA_heat", "readonly")
dataref("AOA2_ON", "sim/cockpit2/ice/ice_AOA_heat_on_copilot", "readonly")
dataref("AOA2_ON_old", "sim/cockpit/switches/anti_ice_AOA_heat2", "readonly")
dataref("Pitot1_ON_old", "sim/cockpit/switches/pitot_heat_on", "readonly")--older datarefs
dataref("Pitot2_ON_old", "sim/cockpit/switches/pitot_heat_on2", "readonly")
dataref("Pitot1_ON", "sim/cockpit2/ice/ice_pitot_heat_on_pilot", "readonly")
dataref("Pitot2_ON", "sim/cockpit2/ice/ice_pitot_heat_on_copilot", "readonly")
dataref("Static1_ON", "sim/cockpit2/ice/ice_static_heat_on_pilot", "readonly") --here static is not present on planes so used as pitot
dataref("Static1_ON_old", "sim/cockpit/switches/pitot_heat_on", "readonly") 
dataref("Static2_ON", "sim/cockpit2/ice/ice_static_heat_on_copilot", "readonly") --here static is not present on planes so used as pitot
dataref("Static2_ON_old", "sim/cockpit/switches/pitot_heat_on2", "readonly") --here static is not present on planes so used as pitot
dataref("Window_ON", "sim/cockpit2/ice/ice_window_heat_on", "readonly")
dataref("Window_ON_old", "sim/cockpit/switches/anti_ice_window_heat", "readonly")
--dataref("Inlet_ON", "sim/cockpit/switches/anti_ice_inlet_heat", "readonly") --not used
dataref("Inlet0_ON", "sim/cockpit2/ice/ice_inlet_heat_on_per_engine", "readonly", 0)
dataref("Inlet0_ON_cowl", "sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine", "readonly", 0)
dataref("Inlet0_ON_old", "sim/cockpit/switches/anti_ice_inlet_heat_per_engine", "readonly", 0)
dataref("Inlet1_ON", "sim/cockpit2/ice/ice_inlet_heat_on_per_engine", "readonly", 1)
dataref("Inlet1_ON_cowl", "sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine", "readonly", 1)
dataref("Inlet1_ON_old", "sim/cockpit/switches/anti_ice_inlet_heat_per_engine", "readonly", 1)
dataref("Prop0_ON", "sim/cockpit2/ice/ice_prop_heat_on_per_engine", "readonly", 0)
dataref("Prop0_ON_old", "sim/cockpit/switches/anti_ice_prop_heat_per_engine", "readonly", 0)
dataref("Prop1_ON", "sim/cockpit2/ice/ice_prop_heat_on_per_engine", "readonly", 1)
dataref("Prop1_ON_old", "sim/cockpit/switches/anti_ice_prop_heat_per_engine", "readonly", 1)
dataref("Prop2_ON", "sim/cockpit2/ice/ice_prop_heat_on_per_engine", "readonly", 2)
dataref("Prop2_ON_old", "sim/cockpit/switches/anti_ice_prop_heat_per_engine", "readonly", 2)
dataref("Prop3_ON", "sim/cockpit/switches/anti_ice_prop_heat_per_engine", "readonly", 3)
dataref("Prop3_ON_old", "sim/cockpit/switches/anti_ice_prop_heat_per_engine", "readonly", 3)
--dataref("Surface_ON", "sim/cockpit/switches/anti_ice_surf_heat", "readonly") -- not used
dataref("Surface_boot_ON_old", "sim/cockpit/switches/anti_ice_surf_boot", "readonly")
--dataref("Antiice_boot_ON", "sim/cockpit2/ice/ice_surface_boot_on", "readonly") --added for DC3
dataref("Surface_boot_ON", "sim/cockpit2/ice/ice_surface_boot_on", "readonly") 
dataref("Surface_hot_bleed_ON", "sim/cockpit2/ice/ice_surface_hot_bleed_air_on", "writable")
dataref("Surface_TSK_ON", "sim/cockpit2/ice/ice_surface_tks_on", "readonly")
dataref("Left_ON", "sim/cockpit2/ice/ice_surfce_heat_left_on", "readonly")
dataref("Left_ON_boot", "sim/cockpit2/ice/ice_surface_boot_left_on", "readonly")
dataref("Left_ON_bleed", "sim/cockpit2/ice/ice_surface_hot_bleed_air_left_on", "readonly")
dataref("Left_ON_old", "sim/cockpit/switches/anti_ice_surf_heat_left", "readonly")
dataref("Right_ON", "sim/cockpit2/ice/ice_surfce_heat_right_on", "readonly")
dataref("Right_ON_boot", "sim/cockpit2/ice/ice_surface_boot_right_on", "readonly")
dataref("Right_ON_bleed", "sim/cockpit2/ice/ice_surface_hot_bleed_air_right_on", "readonly")
dataref("Right_ON_old", "sim/cockpit/switches/anti_ice_surf_heat_right", "readonly")
--Vertical speed:
dataref("Vertical", "sim/flightmodel/position/vh_ind_fpm", "readonly")
--Heading:
dataref("Course", "sim/flightmodel/position/psi", "readonly")
--SPEED:
--dataref("Speed", "sim/cockpit2/gauges/indicators/true_airspeed_kts_pilot", "readonly") -- does not work until power is on
dataref("speed_true", "sim/flightmodel/position/true_airspeed", "readonly")
--HEIGHT:
dataref("Altitude", "sim/flightmodel/misc/h_ind", "readonly") --correct one in feets
--dataref("Altitude", "sim/flightmodel/position/elevation", "readonly") -- in meters
dataref("Height", "sim/flightmodel/position/y_agl", "readonly")
--WIND:
--dataref("Wind_dir", "sim/cockpit2/gauges/indicators/wind_heading_deg_mag", "readonly")
--dataref("Wind_force", "sim/cockpit2/gauges/indicators/wind_speed_kts", "readonly")
dataref("Wind_dir", "sim/weather/wind_direction_degt", "readonly")
dataref("Wind_force", "sim/weather/wind_speed_kt", "readonly")
--RAIN:
dataref("Rain_possible", "sim/weather/rain_percent", "readonly")
dataref("Rain_on_acf", "sim/weather/precipitation_on_aircraft_ratio", "readonly")
dataref("Thunderstorm", "sim/weather/thunderstorm_percent", "readonly")
--CLOUDS meters:
dataref("Cloud_base0", "sim/weather/cloud_base_msl_m[0]", "readonly")
dataref("Cloud_base1", "sim/weather/cloud_base_msl_m[1]", "readonly")
dataref("Cloud_base2", "sim/weather/cloud_base_msl_m[2]", "readonly")

dataref("Cloud_top0", "sim/weather/cloud_tops_msl_m[0]", "readonly")
dataref("Cloud_top1", "sim/weather/cloud_tops_msl_m[1]", "readonly")
dataref("Cloud_top2", "sim/weather/cloud_tops_msl_m[2]", "readonly")

dataref("Cloud_coverage0", "sim/weather/cloud_coverage[0]", "readonly")
dataref("Cloud_coverage1", "sim/weather/cloud_coverage[1]", "readonly")
dataref("Cloud_coverage2", "sim/weather/cloud_coverage[2]", "readonly")

dataref("Cloud_type0", "sim/weather/cloud_type[0]", "readonly")
dataref("Cloud_type1", "sim/weather/cloud_type[1]", "readonly")
dataref("Cloud_type2", "sim/weather/cloud_type[2]", "readonly")

--Ground DE-ICE call
dataref("Ground_deice_call", "sim/cockpit2/radios/actuators/com2_frequency_hz_833", "writable") --call 12210 for deicer
--Forming ice
dataref("ice_on_aoa", "sim/flightmodel/failures/aoa_ice", "writable")
dataref("ice_on_aoa2", "sim/flightmodel/failures/aoa_ice2", "writable")
dataref("ice_on_wing1", "sim/flightmodel/failures/frm_ice", "writable")
dataref("ice_on_wing2", "sim/flightmodel/failures/frm_ice2", "writable")
--dataref("ice_on_inlet", "sim/flightmodel/failures/inlet_ice", "writable")--not used since v1
dataref("ice_on_inlet0", "sim/flightmodel/failures/inlet_ice_per_engine", "writable", 0)
dataref("ice_on_inlet1", "sim/flightmodel/failures/inlet_ice_per_engine", "writable", 1)
dataref("ice_on_prop0", "sim/flightmodel/failures/prop_ice_per_engine", "writable", 0)
dataref("ice_on_prop1", "sim/flightmodel/failures/prop_ice_per_engine", "writable", 1)
dataref("ice_on_prop2", "sim/flightmodel/failures/prop_ice_per_engine", "writable", 2)
dataref("ice_on_prop3", "sim/flightmodel/failures/prop_ice_per_engine", "writable", 3)
dataref("ice_on_pitot1", "sim/flightmodel/failures/pitot_ice", "writable")
dataref("ice_on_pitot2", "sim/flightmodel/failures/pitot_ice2", "writable")
dataref("ice_on_static1", "sim/flightmodel/failures/stat_ice", "writable")
dataref("ice_on_static2", "sim/flightmodel/failures/stat_ice2", "writable")
dataref("ice_on_window", "sim/flightmodel/failures/window_ice", "writable")
--FAILURES:
dataref("fail_on_AOA", "sim/operation/failures/rel_AOA", "writable")
--engine flameout --does not work on all -- temporary disabled
--dataref("flameout_eng0", "sim/operation/failures/rel_engfla0", "writable")
--dataref("flameout_eng1", "sim/operation/failures/rel_engfla1", "writable")
--dataref("flameout_eng2", "sim/operation/failures/rel_engfla2", "writable")
--dataref("flameout_eng3", "sim/operation/failures/rel_engfla3", "writable")
dataref("flameout_eng0", "sim/operation/failures/rel_engfai0", "writable")
dataref("flameout_eng1", "sim/operation/failures/rel_engfai1", "writable")
dataref("flameout_eng2", "sim/operation/failures/rel_engfai2", "writable")
dataref("flameout_eng3", "sim/operation/failures/rel_engfai3", "writable")
dataref("compstall_eng0", "sim/operation/failures/rel_comsta0", "writable")
dataref("compstall_eng1", "sim/operation/failures/rel_comsta1", "writable")
dataref("compstall_eng2", "sim/operation/failures/rel_comsta2", "writable")
dataref("compstall_eng3", "sim/operation/failures/rel_comsta3", "writable")
--dataref("pump_fail0", "sim/operation/failures/rel_fuel_block0", "writable") --not used
--dataref("pump_fail1", "sim/operation/failures/rel_fuel_block1", "writable") --not used
--sim/operation/failures/rel_fuelfl0 // fuel flow
--sim/operation/failures/rel_g_oat
--sim/operation/failures/rel_
--debug sounds
--ONE = load_WAV_file(SCRIPT_DIRECTORY .. "CHATTER/1.wav")
--TWO = load_WAV_file(SCRIPT_DIRECTORY .. "CHATTER/2.wav")
--THREE = load_WAV_file(SCRIPT_DIRECTORY .. "CHATTER/3.wav")
--FOUR = load_WAV_file(SCRIPT_DIRECTORY .. "CHATTER/4.wav")
--local DUMMY = load_WAV_file(SCRIPT_DIRECTORY .. "CHATTER/DUMMY.wav")

LOWERNOSE = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/howaboutlowerthenose.wav")
OHMYGOD = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/ohmygod.wav")
LOOKINGOODTWICE = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/lookingoodtwice.wav")
ICINGCONDITION = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/icingcondition.wav")
GODDAMNIT = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/goddamnit.wav")
WEAREGOODNOW = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/wearegoodnow.wav")
WEHAVEJUSTLOSTENGINEONE = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/wehavejustlostengineone.wav")
ENGINE2ISDOWN = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/engine2isdown.wav")
ENGINESARECOMMINGON = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/enginesarecommingon.wav")
WHATISHAPPENING = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/whatishappening.wav")
BOTHENGINESEMERGENCY = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/bothenginesemergency.wav")
DIVING = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/diving.wav")
MAYDAYMAYDAY = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/maydaymayday.wav")
FIREUPTHESPOOLERS = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/fireupthespoolers.wav")
RECEIVEDCOOCKIES = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/receivedcoockies.wav")
LOOKINGFORYA = load_WAV_file(SCRIPT_DIRECTORY .. "soundtrack/lookingforya.wav")



--let_sound_loop(ONE, false)
--let_sound_loop(TWO, false)
--let_sound_loop(THREE, false)
--let_sound_loop(FOUR, false)
--let_sound_loop(DUMMY, false)

let_sound_loop(LOWERNOSE, false)
let_sound_loop(OHMYGOD, false)
let_sound_loop(LOOKINGOODTWICE, false)
let_sound_loop(ICINGCONDITION, false)
let_sound_loop(GODDAMNIT, false)
let_sound_loop(WEAREGOODNOW, false)
let_sound_loop(WEHAVEJUSTLOSTENGINEONE, false)
let_sound_loop(ENGINE2ISDOWN, false)
let_sound_loop(ENGINESARECOMMINGON, false)
let_sound_loop(WHATISHAPPENING, false)
let_sound_loop(BOTHENGINESEMERGENCY, false)
let_sound_loop(DIVING, false)
let_sound_loop(MAYDAYMAYDAY, false)
let_sound_loop(FIREUPTHESPOOLERS, false)
let_sound_loop(RECEIVEDCOOCKIES, false)
let_sound_loop(LOOKINGFORYA, false)

--lastsound=DUMMY
--Local variables
--incremental step for forming ice
local start_time = os.clock()
local do_once = false
local step_AOA = 0
local step_AOA2 = 0
local AOA_a = 1
local AOA_b = 1
local AOA_c = 1
local AOA_d = 1
local AOA_e = 1
local AOA_f = 1
local AOA_g = 1
local AOA_h = 1
local AOA_i = 1
local AOA2_a = 1
local AOA2_b = 1
local AOA2_c = 1
local AOA2_d = 1
local AOA2_e = 1
local AOA2_f = 1
local AOA2_g = 1
local AOA2_h = 1
local AOA2_i = 1
local step_pitot1 = 0
local pitot1_a = 1
local pitot1_b = 1
local pitot1_c = 1
local pitot1_d = 1
local pitot1_e = 1
local pitot1_f = 1
local pitot1_g = 1
local pitot1_h = 1
local pitot1_i = 1
local step_pitot2 = 0
local pitot2_a = 1
local pitot2_b = 1
local pitot2_c = 1
local pitot2_d = 1
local pitot2_e = 1
local pitot2_f = 1
local pitot2_g = 1
local pitot2_h = 1
local pitot2_i = 1
local step_static1 = 0
local static1_a = 1
local static1_b = 1
local static1_c = 1
local static1_d = 1
local static1_e = 1
local static1_f = 1
local static1_g = 1
local static1_h = 1
local static1_i = 1
local step_static2 = 0
local static2_a = 1
local static2_b = 1
local static2_c = 1
local static2_d = 1
local static2_e = 1
local static2_f = 1
local static2_g = 1
local static2_h = 1
local static2_i = 1
local step_window = 0
local window_a = 1
local window_b = 1
local window_c = 1
local window_d = 1
local window_e = 1
local window_f = 1
local window_g = 1
local window_h = 1 --moisture present
local window_i = 1 --coverage involved
local last_stored_ice_on_window = 0
local step_prop0 = 0
local prop0_a = 1
local prop0_b = 1
local prop0_c = 1
local prop0_d = 1
local prop0_e = 1
local prop0_f = 1
local prop0_g = 1
local step_prop1 = 0
local prop1_a = 1
local prop1_b = 1
local prop1_c = 1
local prop1_d = 1
local prop1_e = 1
local prop1_f = 1
local prop1_g = 1
--local inlet_ratio_left = 1
--local inlet_ratio_right = 1
local step_inlet0 = 0
local inlet0_a = 1
local inlet0_b = 1
local inlet0_c = 1
local inlet0_d = 1
local inlet0_e = 1
local inlet0_f = 1
local inlet0_g = 1
local inlet0_h = 1 --moisture present
local inlet0_i = 1 --coverage involved
local inlet_ratio_left = 1
local step_inlet1 = 0
local inlet1_a = 1
local inlet1_b = 1
local inlet1_c = 1
local inlet1_d = 1
local inlet1_e = 1
local inlet1_f = 1
local inlet1_g = 1
local inlet1_h = 1 --moisture present
local inlet1_i = 1 --coverage involved
local inlet_ratio_right = 1
local step_wing1 = 0
local wing1_a = 1
local wing1_b = 1
local wing1_c = 1
local wing1_d = 1
local wing1_e = 1
local wing1_f = 1
local wing1_g = 1
local wing1_h = 1 --moisture present
local wing1_i = 1 --coverage involved
local step_wing2 = 0
local wing2_a = 1
local wing2_b = 1
local wing2_c = 1
local wing2_d = 1
local wing2_e = 1
local wing2_f = 1
local wing2_g = 1
local wing2_h = 1 --moisture present
local wing2_i = 1 --coverage involved
local engine0_has_failed = 0
local engine1_has_failed = 0
local delay_eng0 = 1
local delay_eng1 = 1
local delay_coef0 = 1
local delay_coef1 = 1
local doom0 = 0
local doom1 = 0
local doom0_a = 0
local doom0_b = 0
local doom0_c = 0
local doom0_d = 0
local doom0_e = 0
local doom0_f = 0
local doom1_a = 0
local doom1_b = 0
local doom1_c = 0
local doom1_d = 0
local doom1_e = 0
local doom1_f = 0
local doom_g0 = 0
local doom_g1 = 0
local played_lowernose = false
local played_ohmygod = false
local played_lookingoodtwice = false
local played_icingcondition = false
local played_goddamnit = false
local played_wearegoodnow = false
local played_wehavejustlostengineone = false
local played_engine2isdown = false
local played_enginesarecommingon = false 
local played_whatishappening = false
local played_bothenginesemergency = false
local played_diving = false
local played_maydaymayday = false
local played_fireupthespoolers = false 
local played_receivedcoockies = false 
local played_lookingforya = false 
local freq_terminated = false
local ACF = 1
local ACFTYPE = 0 -- 0 - jet, 1 - turboprop, 2 - piston, 4 - four engine piston, 767 - B767, 748 - 747-800
local in_clouds = 0
local ground_deice = 0
local count = 0
local counted = 0 
local icelbs = 0 -- weight of ice
local wingarea = 16 -- 16m2 as default for smallest ACF
local PAYLOAD = PAYLD*2.2 -- in lbs
local FOBLBS = FOB*2.2 -- in lbs
local ZFWLBS = ZFW*2.2 -- in lbs
local superhardfail = false -- cannot recover
local hardfail = false -- can recover
local medfail = false  -- recovery possible after crew action
local softfail = false -- recovery after some time
local randomsaved_value = 0
local randomsaved = false
local enginesidle = false
local superhardfail1 = false -- cannot recover
local hardfail1 = false -- can recover
local medfail1 = false  -- recovery possible after crew action
local softfail1 = false -- recovery after some time
local randomsaved_value1 = 0
local randomsaved1 = false
local enginesidle1 = false
local inbadweather = false
local altitude_temp = Altitude
--koef_j = 25 --unused
dxib_mul = 0.00015 --Default X-Plane Icing bypass multiplier global speed value
local clearsky_general = 1 --clearskycoef

-- define aircraft category
-- 1 kg of ice = 2.2 lbs of ice
if ZFWLBS > 0 and ZFWLBS < 4500 and ENGTYPE < 2 then -- type is piston light aircraft
   wingarea = 20
   ACF = wingarea/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   --ACF = wingarea/100 -- new coef for weight, use only for wings as last coeficient
   ACFTYPE = 2 -- piston
   --2.5 unloaded, less heavier ACF more effect on wing ice
   --1.6 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
   --play_sound(ONE)
end
if ZFWLBS > 3000 and ZFWLBS < 14000 and ENGTYPE  == 2 then -- type is propliner
   wingarea = 39
   ACF = wingarea/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   ACFTYPE = 1 -- turboprop
   --0.780 unloaded, less heavier ACF more effect on wing ice
   --0.458 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
end
if ZFWLBS > 5000 and ZFWLBS < 22000 and ENGTYPE > 3 then -- type is very small jet
   wingarea = 29
   ACF = (2*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   ACFTYPE = 0 -- jet
   --0.446 unloaded, less heavier ACF more effect on wing ice
   --0.232 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
end
if ZFWLBS > 14000 and ZFWLBS < 100000 and ENGTYPE < 2 then -- type is old piston engine war bird
   wingarea = 160
   ACF = (2*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   ACFTYPE = 2 -- piston
   --1.002 unloaded, less heavier ACF more effect on wing ice
   --0.736 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
   --play_sound(ONE)
end
if ZFWLBS > 17000 and ZFWLBS < 20000 and ENGTYPE < 2 then -- type is old piston engine cargo plane
   wingarea = 92
   ACF = wingarea/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   ACFTYPE = 4.7 -- piston C47/DC3
   --1.02 unloaded, less heavier ACF more effect on wing ice
   --0.736 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
   --play_sound(ONE)
end
if ZFWLBS > 22000 and ZFWLBS < 40000 and ENGTYPE > 3 then -- type is bizjet or similar small jet aircraft
   wingarea = 49
   ACF = (2*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   ACFTYPE = 0 -- jet
   --0.992 unloaded, less heavier ACF more effect on wing ice
   --0.245 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
end
if ZFWLBS > 25000 and ZFWLBS < 40000 and ENGTYPE == 3 then -- type is ATR72 or similar turboprop
   wingarea = 61
   ACF = (2*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   ACFTYPE = 1 -- turboprop
   --0.680 unloaded, less heavier ACF more effect on wing ice
   --0.244 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
end
if ZFWLBS > 40000 and ZFWLBS < 75000 and ENGTYPE > 3 then -- type is EMB1xx or similar regional jet
   wingarea = 73
   ACF = (4*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   --0.643 unloaded, less heavier ACF more effect on wing ice
   --0.194 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
   --play_sound(ONE)
end
if ZFWLBS > 75000 and ZFWLBS < 148000 and ENGTYPE > 3 then -- type is MD80/737/727/A319
   wingarea = 127
   ACF = (4*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   --play_sound(TWO)
   --0.569 unloaded, less heavier ACF more effect on wing ice
   --0.097 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
end
if ZFWLBS > 90000 and ZFWLBS < 93000 and MAXMACH > 0.81 then --and ENGTYPE > 3 then -- type is 737-800
   wingarea = 124
   ACF = (4*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   ACFTYPE = 738
   --play_sound(ONE)
   --248/90800+11280+46000/100
   --0.642 unloaded, less heavier ACF more effect on wing ice
   --0.001 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
end
--if ZFWLBS > 90000 and ZFWLBS < 93000 and ENGTYPE > 3 then -- type is A320
if ZFWLBS > 90000 and ZFWLBS < 91000 and MAXMACH < 0.81 then --ENGTYPE > 3 then -- type is A320
   wingarea = 124
   ACF = (4*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   ACFTYPE = 320
   --play_sound(ONE)
   --248/90800+11280+46000/100
   --0.642 unloaded, less heavier ACF more effect on wing ice
   --0.001 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
end
if ZFWLBS > 148000 and ZFWLBS < 202000 and MAXMACH < 0.99 then -- type is 707/DC8/767
   wingarea = 283
   ACF = (4*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   ACFTYPE = 767
   --0.691 unloaded, less heavier ACF more effect on wing ice
   --0.183 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
  -- play_sound(ONE)
end
if ZFWLBS > 168000 and ZFWLBS < 189000 and MAXMACH > 2.0 then -- type is Concorde
   wingarea = 358
   ACF = (4*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   ACFTYPE = 202
   --1.200 unloaded, less heavier ACF more effect on wing ice
   --0.XXX loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
   --play_sound(FOUR)
end
if ZFWLBS > 202000 and ZFWLBS < 300000 then -- type is L1011/A330/MD11
   wingarea = 339
   ACF = (4*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   --0.626 unloaded, less heavier ACF more effect on wing ice
   --0.167 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
   --play_sound(ONE)
end
if ZFWLBS > 300000 and ZFWLBS < 400000 then -- type is 777 or similar heavy
   wingarea = 437
   ACF = (4*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   --0.660 unloaded, less heavier ACF more effect on wing ice
   --0.194 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
   --play_sound(ONE)
end
if ZFWLBS > 400000 and ZFWLBS < 540000 then -- type is 747
   wingarea = 554
   ACF = (4*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   ACFTYPE = 748
   --0.621 unloaded, less heavier ACF more effect on wing ice
   --0.181 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
   --play_sound(ONE)
end
if ZFWLBS > 540000 and ZFWLBS < 700000 then -- type is A380
   wingarea = 845
   ACF = (4*wingarea)/((ZFWLBS+PAYLOAD+FOBLBS)/100) -- coef for weight, use only for wings as last coeficient
   --0.669 unloaded, less heavier ACF more effect on wing ice
   --0.226 loaded, more heavier ACF less effect on wing ice 
   --icelbs = (wingarea/100)*0.004*1000*2.2 --not used neligible effect
   -- 1% of wing area assume max. ice coverage of weight m2, 4mm ice = m3 = 50,8 = 5*2.2 = 11 lbs of ice?
   --play_sound(ONE)
end
-- end of AC type

function waitforsim()
    --if os.clock() > start_time + 59 and do_once == false then
	if os.clock() > start_time + 2 and do_once == false then
	--play_sound(ONE)
	step_AOA = 0 --default values (for comparation, otherwise lua stops)
	step_AOA2 = 0
	step_pitot1 = 0 
	step_pitot2 = 0 
	step_static1 = 0 
	step_static2 = 0 
	step_window = 0
	step_prop0 = 0
	step_prop1 = 0
	step_inlet0 = 0
	step_inlet1 = 0
	step_wing1 = 0
	step_wing2 = 0
	ice_on_aoa = 0
	ice_on_aoa2 = 0
	ice_on_pitot1 = 0
	ice_on_pitot2 = 0
	ice_on_static1 = 0
	ice_on_static2 = 0
	ice_on_window = 0
	ice_on_prop0 = 0
	ice_on_prop1 = 0
	ice_on_inlet0 = 0
	ice_on_inlet1 = 0
	ice_on_wing1 = 0
	ice_on_wing2 = 0
	fail_on_AOA = 0
	CHUMIDITY = HUMID
	--inbadweather = 0
	--FAN_MEM=set_fan_vol --temp value until bug resolved
	do_once=true
    end
end
-- Menu driven antiice routine
--local dis = 1

--add_macro("Simulate Anti-ice", "Enable_icesim()")

--function Enable_icesim()
--dis = 0
--end

--old datarefs bugfixer
function old_datarefs()
Pitot1_ON_old = Pitot1_ON
Pitot2_ON_old = Pitot2_ON
AOA_ON_old = AOA_ON
AOA2_ON_old = AOA2_ON
Static1_ON_old = Static1_ON
Static2_ON_old = Static2_ON
Window_ON_old = Window_ON
Inlet0_ON_old = Inlet0_ON
Inlet1_ON_old = Inlet1_ON
Prop0_ON_old = Prop0_ON
Prop1_ON_old = Prop1_ON
Prop2_ON_old = Prop2_ON
Prop3_ON_old = Prop3_ON
Inlet0_ON_cowl = Inlet0_ON
Inlet1_ON_cowl = Inlet1_ON
Surface_boot_ON_old = Surface_boot_ON
Surface_hot_bleed_ON = Surface_boot_ON
Surface_TSK_ON = Surface_boot_ON
Left_ON_old = Left_ON
Left_ON_bleed = Left_ON
Left_ON_boot = Left_ON
Right_ON_old = Right_ON
Right_ON_bleed = Right_ON
Right_ON_boot = Right_ON
end

-- Simple Ground De-ice 
function Ground()
  if speed_true < 50 and Ground_deice_call == 122100 and OAT < 2 then --if you called on COM2 122.10 you have ground deice 
     ground_deice = 0 -- use this as condition in all sensors below zero. If deice 0 normal freezing, if 1 spray active, no freeze
	 count = count + 1 -- timer in seconds
	 if played_lookingforya == false then
	    play_sound(LOOKINGFORYA) -- here replace with call deice
		played_lookingforya = true
	 end
	 if count > 360 and count < 960 then -- after 5 minutes they are here and started
	    ground_deice = 1 -- use this as condition in all sensors below zero. If deice 0 normal freezing, if 1 no freezing
	    if played_receivedcoockies == false then
    	   play_sound(RECEIVEDCOOCKIES) -- here replace with something about deicers
		   played_receivedcoockies = true
		end
	 end 
	 if count > 960 and count < 1560 then -- finished
	     ground_deice = 1
		 --Ground_deice_call = 12220 does not work
		 --play_sound(TWO)
	     if played_fireupthespoolers == false then 
    	   play_sound(FIREUPTHESPOOLERS) -- here replace with something about deicers finished
		   played_fireupthespoolers = true
		 end
		 --step_AOA = 0 --set all to deiced
		 --step_pitot1 = 0
		 --step_pitot2 = 0
		 --step_window = 0
		 --step_inlet0 = 0
	     --step_inlet1 = 0
	     --step_wing1 = 0
	     --step_wing2 = 0
		 -- below is override of all sensors
	     ice_on_aoa = ice_on_aoa - 0.01
		 if ice_on_aoa < 0.01 then ice_on_aoa = 0 end -- limit value
		 ice_on_aoa2 = ice_on_aoa2 - 0.01
		 if ice_on_aoa2 < 0.01 then ice_on_aoa2 = 0 end
	     ice_on_pitot1 = ice_on_pitot1 - 0.01 
		 if ice_on_pitot1 < 0.01 then ice_on_pitot1 = 0 end
		 ice_on_pitot2 = ice_on_pitot2 - 0.01
		 if ice_on_pitot2 < 0.01 then ice_on_pitot2 = 0 end
		 ice_on_static1 = ice_on_static1 - 0.01 
		 if ice_on_static1 < 0.01 then ice_on_static1 = 0 end
		 ice_on_static2 = ice_on_static2 - 0.01
		 if ice_on_static2 < 0.01 then ice_on_static2 = 0 end
		 ice_on_window = ice_on_window - 0.01
		 if ice_on_window < 0.01 then ice_on_window = 0 end
		 ice_on_prop0 = ice_on_prop0 - 0.01
		 if ice_on_prop0 < 0.01 then ice_on_prop0 = 0 end
		 ice_on_prop1 = ice_on_prop1 - 0.01
		 if ice_on_prop1 < 0.01 then ice_on_prop1 = 0 end
		 ice_on_inlet0 = ice_on_inlet0 - 0.01
		 if ice_on_inlet0 < 0.01 then ice_on_inlet0 = 0 end
	     ice_on_inlet1 = ice_on_inlet1 - 0.01
		 if ice_on_inlet1< 0.01 then ice_on_inlet1 = 0 end
	     ice_on_wing1 = ice_on_wing1 - 0.01
		 if ice_on_wing1 < 0.01 then ice_on_wing1 = 0 end
	     ice_on_wing2 = ice_on_wing2 - 0.01
		 if ice_on_wing2 < 0.01 then ice_on_wing2 = 0 end
	     fail_on_AOA = 0
	 end --end of deice procedure
	 if count > 1560 then
     	 count = 1560 
		 counted = 1 
		 ground_deice = 0
		 --play_sound(ONE)
     end -- limit value
  else --first routine terminator
	 ground_deice = 0
	 if speed_true > 60 and freq_terminated == false then --switch off from 122.10 
	  set( "sim/cockpit2/radios/actuators/com2_frequency_hz", 12130)
	  freq_terminated = true
	 end
  end
end

--end of ground de-ice

--test function -- DISABLE later
--function test()
-- if ground_deice == 1 then play_sound(ONE)
 --else 
 --play_sound(TWO)  
-- end
--end

function General_sounds() -- play general sounds
 if played_diving == false and Vertical < -5000 then 
	   play_sound(DIVING)
	   played_diving = true --you hear that? dont play it again
 end
 if engine0_has_failed == 1 and Vertical < -5000 then
      if played_maydaymayday == false then 
	     play_sound(MAYDAYMAYDAY)
	     played_maydaymayday = true --you hear that? dont play it again
      end
 end
 if Vertical > 3000 then
    if played_lowernose == false then
	   play_sound(LOWERNOSE)
       played_lowernose = true --you hear that? dont play it again
	end
 end
 end --end of sounds
 
 --bad weather check
 --function badweather() --make this at last because of clouds variable overwriting
 
--end --badweather end
 
 function clearsky()
 inbadweather = false
 --new cloud check here
	if Height >= Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   in_clouds0 = 1
	   inbadweather = true 
	   --play_sound(ONE) --debug sound
	   else
	   in_clouds0 = 0
	   inbadweather = false 
	end
	if Height >= Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   in_clouds1 = 1
	   inbadweather = true 
	   --play_sound(TWO) --debug sound
	   else
	   in_clouds1 = 0
	   inbadweather = false 
	end
	if Height >= Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   in_clouds2 = 1
	   inbadweather = true 
	   --play_sound(ONE) --debug sound
	   else
	   in_clouds2 = 0
	   inbadweather = false 
	end
 --aircrafts_altitude = altitude nepoužito
 --raining
 --if Rain_on_acf >= 0.025 or FOG <= 1000 or in_clouds == 1 then inbadweather = true end
 if Rain_on_acf >= 0.025 then inbadweather = true end
 if FOG <= 1000 then inbadweather = true end
 if in_clouds0 == 1 then inbadweather = true end
 if in_clouds1 == 1 then inbadweather = true end
 if in_clouds2 == 1 then inbadweather = true end
 --play_sound(THREE)
 --inbadweather = true --bug here never happens
-- end
 --fog
-- if  then inbadweather = true else inbadweather = false end
 --inclouds dataref mame
 --if  then inbadweather = true else inbadweather = false end
 --clearsky conditions
   SUPRESSURE=(CPRESSURE*3)/100
   altitude_temp = Altitude
   --inbadweather = true --debug
   --if altitude_temp == 0 then altitude_temp = 1 end --divide by zero protection
   --if altitude_temp <= 0 then altitude_temp = 1 end --negative square root protection
   --if altitude_temp > 1 and altitude_temp < 100 then koef_j = 2 end --slow down icing on ground --alternative 15
   --if altitude_temp >= 100 and altitude_temp < 1000 then koef_j = 3 end --slow down icing on ground --alternative 75
   --if altitude_temp >= 1000 and altitude_temp < 2000 then koef_j = 5 end --slow down icing on ground --alternative 75
   --if altitude_temp >= 2000 and altitude_temp < 3000 then koef_j = 6 end --slow down icing on ground --alternative 75
   --if altitude_temp >= 3000 and altitude_temp < 4000 then koef_j = 8 end --slow down icing on ground --alternative 75
  -- if altitude_temp >= 4000 and altitude_temp < 5000 then koef_j = 10 end --slow down icing on ground --alternative 75
  -- if altitude_temp >= 5000 then koef_j = 20 end --slow down icing on ground --alternative 75
  -- if altitude_temp < 20000 and inbadweather == false then --good but chilly weather and clear sky
   --if altitude_temp > 1 and altitude_temp < 100 then koef_j = 5 end --slow down icing on ground --alternative 15
   --if altitude_temp >= 100 and altitude_temp < 1000 then koef_j = 6 end --slow down icing on ground --alternative 75
   if altitude_temp >= 10000 and altitude_temp < 12000 then CHUMIDITY = 50 end --slow down icing on ground --alternative 75
   if altitude_temp >= 12000 and altitude_temp < 13000 then CHUMIDITY = 40 end --slow down icing on ground --alternative 75
   if altitude_temp >= 13000 and altitude_temp < 14000 then CHUMIDITY = 30 end --slow down icing on ground --alternative 75
   if altitude_temp >= 14000 and altitude_temp < 15000 then CHUMIDITY = 15 end --slow down icing on ground --alternative 75
   if altitude_temp >= 15000 then CHUMIDITY = 10 end --slow down icing on ground --alternative 75
   --CHUMIDITY = CHUMIDITY
   --inbadweather = true --test
   --if altitude_temp < 20000 and inbadweather == false then --good but chilly weather and clear sky, slow down a lot everything
   if inbadweather == false then --good but chilly weather and clear sky, slow down a lot everything
   --if altitude_temp < 20000 and FOG >= 1000 then --good but chilly weather and clear sky
    --clearsky_general =koef_j/math.sqrt(altitude_temp) -- in 10.000ft koef 0.2, in 1000ft 0.6, on ground 2.8!, higher 20 higher result
	--clearsky_general = SUPRESSURE*(ATMODENS/2)*math.abs(CHUMIDITY/100)
	clearsky_general = SUPRESSURE*(ATMODENS/2) --*math.abs(CHUMIDITY/100)
	--play_sound(THREE)
   end
	--else if inbadweather == true then
   if inbadweather == true then
	--clearsky_general = SUPRESSURE*AIRDENS*math.abs(CHUMIDITY/100) -- bad weather detected, slow down a bit the bad weather coeficients
	clearsky_general = SUPRESSURE*AIRDENS --*math.abs(CHUMIDITY/100) -- bad weather detected, slow down a bit the bad weather coeficients
	--play_sound(FOUR)
   end 
  --end
   --end of clearsky
 end
 
-- anti ice check
function AOA() -- check conditions for Angle of Atack block
--AOA fail section
--OAT is below zero
 if OAT < 0 and AOA_ON == 1 then
   --step_AOA = 0
   step_AOA = 0.01
   --play_sound(ONE)
   -- new override formula
   if paused_sim == 1 then step_AOA = 0 end --paused sim bug resolver
   ice_on_aoa = ice_on_aoa-step_AOA
   if ice_on_aoa > 0.99995 then ice_on_aoa = 1 end -- limit value
   if ice_on_aoa < 0.000001 then ice_on_aoa = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
 end
  if OAT > 0 then -- AOA is off and hot outside
   step_AOA = dxib_mul -- default coeficient for AOA , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_AOA = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_AOA = 0 end --paused sim bug resolver
   if speed_true > 10 and speed_true < 100 then AOA_a = 2 end -- adds speed of forming ice on AOA by factor
   if speed_true > 100 and speed_true < 200 then AOA_a = 4 end
   if speed_true > 200 then AOA_a = 8 end
   if Altitude > 0 and Altitude < 6000 then AOA_b = 1.5 end
   if Altitude > 6000 and Altitude < 12000 then AOA_b = 2 end -- adds another speed of forming ice on AOA by factor
   if Altitude > 12000 and Altitude < 30000 then AOA_b = 6 end
   if Altitude > 30000 then AOA_b = 8 end
   if OAT < 0 and OAT > -20 then  AOA_c = 1 end -- adds another speed of forming ice on AOA by factor
   if OAT < -20 and OAT > -40 then  AOA_c = 6 end
   if OAT < -40 then AOA_c = 8 end
   --if OAT > -40 then AOA_c = 0 end -- new from physics analysis, stops further freezing
   --if FOG > 1000 then AOA_d = 1 end -- adds another speed of forming ice on AOA by factor
   --if FOG < 1000 then AOA_d = 8 end
   if FOG > 5000 then AOA_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then AOA_d = 1.1 end
   if FOG > 1000 and FOG <= 3000 then AOA_d = 1.2 end
   if FOG < 1000 then AOA_d = 1.5 end
   if Rain_on_acf < 0.025 then AOA_e = 1 end -- adds another speed of forming ice on AOA by factor
   if Rain_on_acf > 0.025 then AOA_e = 6 end
   if Wind_force < 10 then AOA_f = 3 end -- AOA gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then AOA_f = 1 end
   if Wind_force > 30 and speed_true > 200 then AOA_f = 0.4 end -- AOA is heating a bit from high speeds of wind and movement
   if paused_sim == 1 then step_AOA = 0 end --paused sim bug resolver
   ice_on_aoa = ice_on_aoa-step_AOA*AOA_a*AOA_b*AOA_c*AOA_d*AOA_e*AOA_f*clearsky_general -- formula for forming ice on AOA
   --play_sound(TWO)
   if ice_on_aoa > 0.99995 then 
    ice_on_aoa = 1 
	fail_on_AOA = 6 
   end -- limit value
   if ice_on_aoa < 0.000001 then 
    ice_on_aoa = 0 
	fail_on_AOA = 0 
   end -- limit value2
   --if ice_on_aoa < 0.9 then fail_on_AOA = 0 end -- disable failure does not work
   
   end -- end of OAT is below zero
   if OAT < 0 and AOA_ON ~= 1 and ground_deice == 0 then -- AOA is off and cold outside
   step_AOA = dxib_mul -- default coeficient for AOA , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_AOA = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_AOA = 0 end --paused sim bug resolver
   if speed_true > 10 and speed_true < 100 then AOA_a = 1.1 end -- adds speed of forming ice on AOA by factor
   if speed_true > 100 and speed_true < 200 then AOA_a = 1.2 end
   if speed_true > 200 then AOA_a = 1.5 end
   if Altitude > 0 and Altitude < 6000 then AOA_b = 1.5 end
   if Altitude > 6000 and Altitude < 12000 then AOA_b = 1.2 end -- adds another speed of forming ice on AOA by factor
   if Altitude > 12000 and Altitude < 30000 then AOA_b = 1.1 end
   if Altitude > 30000 then AOA_b = 1 end
   if OAT < 0 and OAT > -20 then  AOA_c = 1.5 end -- adds another speed of forming ice on AOA by factor
   if OAT < -20 and OAT > -40 then  AOA_c = 1.2 end
   --if OAT > -40 then AOA_c = 4 end
   --if OAT < -40 then AOA_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 0 then AOA_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 1 then AOA_c = 1 end -- new from physics analysis, in clouds icing
   --if FOG > 1000 then AOA_d = 1 end -- adds another speed of forming ice on AOA by factor
   --if FOG < 1000 then AOA_d = 2 end
   if FOG > 5000 then AOA_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then AOA_d = 1.5 end
   if FOG > 1000 and FOG <= 3000 then AOA_d = 1.8 end
   if FOG < 1000 then AOA_d = 2.0 end
   if Rain_on_acf < 0.025 then AOA_e = 1 end -- adds another speed of forming ice on AOA by factor
   if Rain_on_acf > 0.025 then AOA_e = 1.5 end
   if Wind_force < 10 then AOA_f = 0.9 end -- AOA gets hotter from low wind force
   if Wind_force > 10 and Wind_force < 30 then AOA_f = 1 end
   if Wind_force > 30 and speed_true > 200 then AOA_f = 1.2 end -- AOA is cooling down a bit from high speeds of wind and movement
   if Wind_dir > 270 and Wind_dir < 359 then AOA_g = 1.2 end -- Pitot1 gets colder from direct wind
   if Wind_dir > 0 and Wind_dir < 270 then AOA_g = 0.8 end -- Pitot1 dont absorb cold air because no wind on left side
   --new cloud check here
	if Height > Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   if Cloud_type0 == 0 then AOA_h = 1 end --clear
	   if Cloud_type0 == 1 then AOA_h = 1.2 end --cirrus
	   if Cloud_type0 == 2 then AOA_h = 1.5 end --scattered
	   if Cloud_type0 == 3 then AOA_h = 1.8 end --broken
	   if Cloud_type0 == 4 then AOA_h = 2 end --overcast
	   if Cloud_type0 == 5 then AOA_h = 3 end --stratus
	   if Cloud_coverage0 < 1 then AOA_i = 1 end -- clear sky
	   if Cloud_coverage0 >= 1 and Cloud_coverage0 < 2 then AOA_i = 1 end -- a few clouds
	   if Cloud_coverage0 >= 2 and Cloud_coverage0 < 3 then AOA_i = 1.2 end -- normal coverage
	   if Cloud_coverage0 >= 3 and Cloud_coverage0 < 4 then AOA_i = 1.5 end -- lot of clouds
	   if Cloud_coverage0 >= 4 and Cloud_coverage0 < 5 then AOA_i = 1.8 end -- very high coverage
	   if Cloud_coverage0 >= 5 then AOA_i = 2 end -- full coverage
	   --play_sound(ONE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	   --play_sound(TWO) --debug sound
	end
	if Height > Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   if Cloud_type1 == 0 then AOA_h = 1 end --clear
	   if Cloud_type1 == 1 then AOA_h = 1.2 end --cirrus
	   if Cloud_type1 == 2 then AOA_h = 1.4 end --scattered
	   if Cloud_type1 == 3 then AOA_h = 1.5 end --broken
	   if Cloud_type1 == 4 then AOA_h = 2 end --overcast
	   if Cloud_type1 == 5 then AOA_h = 2.5 end --stratus
	   if Cloud_coverage1 < 1 then AOA_i = 1 end -- clear sky
	   if Cloud_coverage1 >= 1 and Cloud_coverage1 < 2 then AOA_i = 1 end -- a few clouds
	   if Cloud_coverage1 >= 2 and Cloud_coverage1 < 3 then AOA_i = 1.5 end -- normal coverage
	   if Cloud_coverage1 >= 3 and Cloud_coverage1 < 4 then AOA_i = 2 end -- lot of clouds
	   if Cloud_coverage1 >= 4 and Cloud_coverage1 < 5 then AOA_i = 3 end -- very high coverage
	   if Cloud_coverage1 >= 5 then AOA_i = 4 end -- full coverage
	   --play_sound(TWO) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if Height > Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   if Cloud_type2 == 0 then AOA_h = 1 end --clear
	   if Cloud_type2 == 1 then AOA_h = 1.1 end --cirrus
	   if Cloud_type2 == 2 then AOA_h = 1.3 end --scattered
	   if Cloud_type2 == 3 then AOA_h = 1.4 end --broken
	   if Cloud_type2 == 4 then AOA_h = 1.8 end --overcast
	   if Cloud_type2 == 5 then AOA_h = 2 end --stratus
	   if Cloud_coverage2 < 1 then AOA_i = 1 end -- clear sky
	   if Cloud_coverage2 >= 1 and Cloud_coverage2 < 2 then AOA_i = 1 end -- a few clouds
	   if Cloud_coverage2 >= 2 and Cloud_coverage2 < 3 then AOA_i = 1.5 end -- normal coverage
	   if Cloud_coverage2 >= 3 and Cloud_coverage2 < 4 then AOA_i = 2 end -- lot of clouds
	   if Cloud_coverage2 >= 4 and Cloud_coverage2 < 5 then AOA_i = 3 end -- very high coverage
	   if Cloud_coverage2 >= 5 then AOA_i = 4 end -- full coverage
	   --play_sound(THREE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if in_clouds ~= 1 and Altitude > 20000 then
    	AOA_h = 0
		--play_sound(LOOKINGOODTWICE) --debug sound
		--play_sound(THREE)
	end -- not in clouds above FL200? no more ice cumulation
	--end of new cloud check here
   if paused_sim == 1 then step_AOA = 0 end --paused sim bug resolver
   ice_on_aoa = ice_on_aoa+step_AOA*AOA_a*AOA_b*AOA_c*AOA_d*AOA_e*AOA_f*AOA_g*AOA_h*AOA_i*clearsky_general --clearskycoef -- formula for forming ice on AOA
   --play_sound(THREE)
   --if played_lowernose == false and ice_on_aoa > 0.5 and Vertical > 1000 then
	   --play_sound(LOWERNOSE)
   --played_lowernose = true --you hear that? dont play it again
   --end
   if ice_on_aoa > 0.99995 then 
    ice_on_aoa = 1 
	fail_on_AOA = 6 
	if played_ohmygod == false then 
	   play_sound(OHMYGOD)
	   played_ohmygod = true --you hear that? dont play it again
    end
   end -- limit value
   if ice_on_aoa < 0.000001 then 
    ice_on_aoa = 0 
	fail_on_AOA = 0 
	if played_lookingoodtwice == false and played_wearegoodnow == true then 
	   play_sound(LOOKINGOODTWICE)
	   played_lookingoodtwice = true --you hear that? dont play it again
    end
   end -- limit value2
  
   end -- of AOA fail, seems no effect on ACF
  end -- end of AOA
  
  function AOA2() -- check conditions for Angle of Atack block
--AOA fail section
-- 767 bug resolver here
if ACFTYPE == 767 then ice_on_aoa2 = 0 end
-- end of 767 bug resolver
--OAT is below zero
 if OAT < 0 and AOA2_ON == 1 then
   --step_AOA2 = 0
   step_AOA2 = 0.01 -- override default xplane logic
   --if paused_sim == 1 then step_AOA2 = 0 end --paused sim bug resolver
   --play_sound(ONE)
   -- new override formula
   if paused_sim == 1 then step_AOA2 = 0 end --paused sim bug resolver
   ice_on_aoa2 = ice_on_aoa2-step_AOA2
   if ice_on_aoa2 > 0.99995 then ice_on_aoa2 = 1 end -- limit value
   if ice_on_aoa2 < 0.000001 then ice_on_aoa2 = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
 end
  if OAT > 0 then -- AOA is off and hot outside
   step_AOA2 = dxib_mul -- default coeficient for AOA , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_AOA2 = (AIRDENS/10000)*math.abs(HUMID/100)
  -- if paused_sim == 1 then step_AOA2 = 0 end --paused sim bug resolver
   if speed_true > 10 and speed_true < 100 then AOA2_a = 2 end -- adds speed of forming ice on AOA by factor
   if speed_true > 100 and speed_true < 200 then AOA2_a = 4 end
   if speed_true > 200 then AOA2_a = 8 end
   if Altitude > 0 and Altitude < 6000 then AOA2_b = 1.5 end
   if Altitude > 6000 and Altitude < 12000 then AOA2_b = 2 end -- adds another speed of forming ice on AOA by factor
   if Altitude > 12000 and Altitude < 30000 then AOA2_b = 6 end
   if Altitude > 30000 then AOA2_b = 8 end
   if OAT < 0 and OAT > -20 then  AOA2_c = 1 end -- adds another speed of forming ice on AOA by factor
   if OAT < -20 and OAT > -40 then  AOA2_c = 6 end
   if OAT < -40 then AOA2_c = 8 end
   --if OAT > -40 then AOA_c = 0 end -- new from physics analysis, stops further freezing
   --if FOG > 1000 then AOA2_d = 1 end -- adds another speed of forming ice on AOA by factor
   --if FOG < 1000 then AOA2_d = 2 end
   if FOG > 5000 then AOA2_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then AOA2_d = 1.1 end
   if FOG > 1000 and FOG <= 3000 then AOA2_d = 1.2 end
   if FOG < 1000 then AOA2_d = 1.5 end
   if Rain_on_acf < 0.025 then AOA2_e = 1 end -- adds another speed of forming ice on AOA by factor
   if Rain_on_acf > 0.025 then AOA2_e = 2 end
   if Wind_force < 10 then AOA2_f = 3 end -- AOA gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then AOA2_f = 1 end
   if Wind_force > 30 and speed_true > 200 then AOA2_f = 0.4 end -- AOA is heating a bit from high speeds of wind and movement
   if Wind_dir > 0 and Wind_dir < 90 then AOA2_g = 4 end -- Pitot2 gets colder from direct wind
   if Wind_dir > 90 and Wind_dir < 359 then AOA2_g = 0.4 end -- Pitot2 dont absorb cold air because no wind on left side
   if paused_sim == 1 then step_AOA2 = 0 end --paused sim bug resolver
   ice_on_aoa2 = ice_on_aoa2-step_AOA2*AOA2_a*AOA2_b*AOA2_c*AOA2_d*AOA2_e*AOA2_f*AOA2_g*clearsky_general -- formula for forming ice on AOA
   --play_sound(TWO)
   if ice_on_aoa2 > 0.99995 then 
    ice_on_aoa2 = 1 
	fail_on_AOA = 6 --only one here
   end -- limit value
   if ice_on_aoa2 < 0.000001 then 
    ice_on_aoa2 = 0 
	fail_on_AOA = 0 --only one here
   end -- limit value2
   --if ice_on_aoa < 0.9 then fail_on_AOA = 0 end -- disable failure does not work
   
   end -- end of OAT is below zero
   if OAT < 0 and AOA2_ON ~= 1 and ground_deice == 0 then -- AOA is off and cold outside
   step_AOA2 = dxib_mul -- default coeficient for AOA , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_AOA2 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_AOA2 = 0 end --paused sim bug resolver
   if speed_true > 10 and speed_true < 100 then AOA2_a = 1.1 end -- adds speed of forming ice on AOA by factor
   if speed_true > 100 and speed_true < 200 then AOA2_a = 1.2 end
   if speed_true > 200 then AOA2_a = 1.5 end
   if Altitude > 0 and Altitude < 6000 then AOA2_b = 1.5 end
   if Altitude > 6000 and Altitude < 12000 then AOA2_b = 1.2 end -- adds another speed of forming ice on AOA by factor
   if Altitude > 12000 and Altitude < 30000 then AOA2_b = 1.1 end
   if Altitude > 30000 then AOA2_b = 1 end
   if OAT < 0 and OAT > -20 then  AOA2_c = 1.5 end -- adds another speed of forming ice on AOA by factor
   if OAT < -20 and OAT > -40 then  AOA2_c = 1.2 end
   --if OAT > -40 then AOA_c = 4 end
   --if OAT < -40 then AOA2_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 0 then AOA2_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 1 then AOA2_c = 1 end -- new from physics analysis, in clouds icing
   --if FOG > 1000 then AOA2_d = 1 end -- adds another speed of forming ice on AOA by factor
   --if FOG < 1000 then AOA2_d = 2 end
   if FOG > 5000 then AOA2_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then AOA2_d = 1.5 end
   if FOG > 1000 and FOG <= 3000 then AOA2_d = 1.8 end
   if FOG < 1000 then AOA2_d = 2.2 end
   if Rain_on_acf < 0.025 then AOA2_e = 1 end -- adds another speed of forming ice on AOA by factor
   if Rain_on_acf > 0.025 then AOA2_e = 1.5 end
   if Wind_force < 10 then AOA2_f = 0.9 end -- AOA gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then AOA2_f = 1 end
   if Wind_force > 30 and speed_true > 200 then AOA2_f = 1.2 end -- AOA is heating a bit from high speeds of wind and movement
   if Wind_dir > 0 and Wind_dir < 90 then AOA2_g = 1.2 end -- Pitot2 gets colder from direct wind
   if Wind_dir > 90 and Wind_dir < 359 then AOA2_g = 0.8 end -- Pitot2 dont absorb cold air because no wind on left side
   --new cloud check here
	if Height > Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   if Cloud_type0 == 0 then AOA2_h = 1 end --clear
	   if Cloud_type0 == 1 then AOA2_h = 1.2 end --cirrus
	   if Cloud_type0 == 2 then AOA2_h = 1.5 end --scattered
	   if Cloud_type0 == 3 then AOA2_h = 1.8 end --broken
	   if Cloud_type0 == 4 then AOA2_h = 2 end --overcast
	   if Cloud_type0 == 5 then AOA2_h = 3 end --stratus
	   if Cloud_coverage0 < 1 then AOA2_i = 1 end -- clear sky
	   if Cloud_coverage0 >= 1 and Cloud_coverage0 < 2 then AOA2_i = 1 end -- a few clouds
	   if Cloud_coverage0 >= 2 and Cloud_coverage0 < 3 then AOA2_i = 1.2 end -- normal coverage
	   if Cloud_coverage0 >= 3 and Cloud_coverage0 < 4 then AOA2_i = 1.5 end -- lot of clouds
	   if Cloud_coverage0 >= 4 and Cloud_coverage0 < 5 then AOA2_i = 1.8 end -- very high coverage
	   if Cloud_coverage0 >= 5 then AOA2_i = 2 end -- full coverage
	   --play_sound(ONE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	   --play_sound(TWO) --debug sound
	end
	if Height > Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   if Cloud_type1 == 0 then AOA2_h = 1 end --clear
	   if Cloud_type1 == 1 then AOA2_h = 1.2 end --cirrus
	   if Cloud_type1 == 2 then AOA2_h = 1.4 end --scattered
	   if Cloud_type1 == 3 then AOA2_h = 1.5 end --broken
	   if Cloud_type1 == 4 then AOA2_h = 2 end --overcast
	   if Cloud_type1 == 5 then AOA2_h = 2.5 end --stratus
	   if Cloud_coverage1 < 1 then AOA2_i = 1 end -- clear sky
	   if Cloud_coverage1 >= 1 and Cloud_coverage1 < 2 then AOA2_i = 1 end -- a few clouds
	   if Cloud_coverage1 >= 2 and Cloud_coverage1 < 3 then AOA2_i = 1.5 end -- normal coverage
	   if Cloud_coverage1 >= 3 and Cloud_coverage1 < 4 then AOA2_i = 2 end -- lot of clouds
	   if Cloud_coverage1 >= 4 and Cloud_coverage1 < 5 then AOA2_i = 3 end -- very high coverage
	   if Cloud_coverage1 >= 5 then AOA2_i = 4 end -- full coverage
	   --play_sound(TWO) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if Height > Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   if Cloud_type2 == 0 then AOA2_h = 1 end --clear
	   if Cloud_type2 == 1 then AOA2_h = 1.1 end --cirrus
	   if Cloud_type2 == 2 then AOA2_h = 1.3 end --scattered
	   if Cloud_type2 == 3 then AOA2_h = 1.4 end --broken
	   if Cloud_type2 == 4 then AOA2_h = 1.8 end --overcast
	   if Cloud_type2 == 5 then AOA2_h = 2 end --stratus
	   if Cloud_coverage2 < 1 then AOA2_i = 1 end -- clear sky
	   if Cloud_coverage2 >= 1 and Cloud_coverage2 < 2 then AOA2_i = 1 end -- a few clouds
	   if Cloud_coverage2 >= 2 and Cloud_coverage2 < 3 then AOA2_i = 1.5 end -- normal coverage
	   if Cloud_coverage2 >= 3 and Cloud_coverage2 < 4 then AOA2_i = 2 end -- lot of clouds
	   if Cloud_coverage2 >= 4 and Cloud_coverage2 < 5 then AOA2_i = 3 end -- very high coverage
	   if Cloud_coverage2 >= 5 then AOA2_i = 4 end -- full coverage
	   --play_sound(THREE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if in_clouds ~= 1 and Altitude > 20000 then
    	AOA2_h = 0
		--play_sound(LOOKINGOODTWICE) --debug sound
		--play_sound(THREE)
	end -- not in clouds above FL200? no more ice cumulation
	--end of new cloud check here
   if paused_sim == 1 then step_AOA2 = 0 end --paused sim bug resolver
   ice_on_aoa2 = ice_on_aoa2+step_AOA2*AOA2_a*AOA2_b*AOA2_c*AOA2_d*AOA2_e*AOA2_f*AOA2_g*AOA2_h*AOA2_i*clearsky_general -- formula for forming ice on AOA
   --play_sound(THREE)
   --if played_lowernose == false and ice_on_aoa2 > 0.5 and speed > 10 then
	--   play_sound(LOWERNOSE)
	--   played_lowernose = true --you hear that? dont play it again
   --end
   if ice_on_aoa2 > 0.99995 then 
    ice_on_aoa2 = 1 
	fail_on_AOA = 6 --only one here
	--if played_ohmygod == false then 
	--   play_sound(OHMYGOD)
	--   played_ohmygod = true --you hear that? dont play it again
    --end
   end -- limit value
   if ice_on_aoa2 < 0.000001 then 
    ice_on_aoa2 = 0 
	fail_on_AOA = 0 --only one here
	if played_lookingoodtwice == false and played_wearegoodnow == true then 
	   play_sound(LOOKINGOODTWICE)
	   played_lookingoodtwice = true --you hear that? dont play it again
    end
   end -- limit value2
  
   end -- of AOA2 fail, seems no effect on ACF
  end -- end of AOA2
 
 --now pitot fails
function Pitot1() -- check conditions for Pitot icing
--Pitots fail section
--TAT is below zero
 if TAT < 0 and Pitot1_ON == 1 then -- Pitot1 heat is on and cold outside - no change
   --step_pitot1 = 0 
   step_pitot1 = 0.01
   --if paused_sim == 1 then step_pitot1 = 0 end --paused sim bug resolver
   --play_sound(ONE)
   -- new override formula
   if paused_sim == 1 then step_pitot1 = 0 end --paused sim bug resolver
   ice_on_pitot1 = ice_on_pitot1-step_pitot1
   if ice_on_pitot1 > 0.99995 then ice_on_pitot1 = 1 end -- limit value
   if ice_on_pitot1 < 0.000001 then ice_on_pitot1 = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
 end
  if TAT > 0 then
   step_pitot1 = dxib_mul -- default coeficient for Pitot1 , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_pitot1 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_pitot1 = 0 end --paused sim bug resolver
   if speed_true > 10 and speed_true < 100 then pitot1_a = 2 end -- adds speed of forming ice on Pitot1 by factor
   if speed_true > 100 and speed_true < 200 then pitot1_a = 4 end
   if speed_true > 200 then pitot1_a = 8 end
   if Altitude > 0 and Altitude < 6000 then pitot1_b = 1.2 end
   if Altitude > 6000 and Altitude < 12000 then pitot1_b = 2 end -- adds another speed of forming ice on Pitot1 by factor
   if Altitude > 12000 and Altitude < 30000 then pitot1_b = 6 end
   if Altitude > 30000 then pitot1_b = 8 end
   if OAT < 0 and OAT > -20 then  pitot1_c = 1 end -- adds another speed of forming ice on Pitot1 by factor
   if OAT < -20 and OAT > -40 then  pitot1_c = 6 end
   if OAT < -40 then pitot1_c = 8 end
   --if FOG > 1000 then pitot1_d = 1 end -- adds another speed of forming ice on Pitot1 by factor
   --if FOG < 1000 then pitot1_d = 2 end
   if FOG > 5000 then pitot1_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then pitot1_d = 1.1 end
   if FOG > 1000 and FOG <= 3000 then pitot1_d = 1.2 end
   if FOG < 1000 then pitot1_d = 1.5 end
   if Rain_on_acf < 0.025 then pitot1_e = 1 end -- adds another speed of forming ice on Pitot1 by factor
   if Rain_on_acf > 0.025 then pitot1_e = 2 end
   if Wind_force < 10 then pitot1_f = 3 end -- Pitot1 gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then pitot1_f = 1 end
   if Wind_force > 30 and speed_true > 200 then pitot1_f = 0.4 end -- Pitot1 is heating a bit from high speeds of wind and movement
   if Wind_dir > 270 and Wind_dir < 359 then pitot1_g = 4 end -- Pitot1 gets colder from direct wind
   if Wind_dir > 0 and Wind_dir < 270 then pitot1_g = 1 end -- Pitot1 dont absorb cold air because no wind on left side
   if paused_sim == 1 then step_pitot1 = 0 end --paused sim bug resolver
   ice_on_pitot1 = ice_on_pitot1-step_pitot1*pitot1_a*pitot1_b*pitot1_c*pitot1_d*pitot1_e*pitot1_f*pitot1_g*clearsky_general -- formula for forming ice on Pitot1
   --play_sound(TWO)
   if ice_on_pitot1 > 0.9999 then ice_on_pitot1 = 1 end -- limit value
   if ice_on_pitot1 < 0.000001 then ice_on_pitot1 = 0 end
   --if ice_on_aoa < 0.9 then fail_on_AOA = 0 end -- disable failure does not work

  end -- end of Pitot1 is hot
    if TAT < 0 and Pitot1_ON ~= 1 and ground_deice == 0 then 
     step_pitot1 = dxib_mul
	 --step_pitot1 = (AIRDENS/10000)*math.abs(HUMID/100)
	 --if paused_sim == 1 then step_pitot1 = 0 end --paused sim bug resolver
	 if speed_true > 10 and speed_true < 100 then pitot1_a = 1.1 end -- adds speed of forming ice on Pitot1 by factor
     if speed_true > 100 and speed_true < 200 then pitot1_a = 1.2 end
     if speed_true > 200 then pitot1_a = 1.5 end
	 if Altitude > 0 and Altitude < 6000 then pitot1_b = 1.5 end
     if Altitude > 6000 and Altitude < 12000 then pitot1_b = 1.2 end -- adds another speed of forming ice on Pitot1 by factor
     if Altitude > 12000 and Altitude < 30000 then pitot1_b = 1.1 end
     if Altitude > 30000 then pitot1_b = 1 end
     if OAT < 0 and OAT > -20 then  pitot1_c = 1.5 end -- adds another speed of forming ice on Pitot1 by factor
     if OAT < -20 and OAT > -40 then  pitot1_c = 1.2 end
     --if OAT > -40 then pitot1_c = 4 end
	 --if OAT < -40 then pitot1_c = 0 end -- new from physics analysis, stops further freezing
	 if OAT < -48 and in_clouds == 0 then pitot1_c = 0 end -- new from physics analysis, stops further freezing
     if OAT < -48 and in_clouds == 1 then pitot1_c = 1 end -- new from physics analysis, in clouds icing
     --if FOG > 1000 then pitot1_d = 1 end -- adds another speed of forming ice on Pitot1 by factor
     --if FOG < 1000 then pitot1_d = 2 end
	 if FOG > 5000 then pitot1_d = 1 end -- adds another speed of forming ice on Window by factor
     if FOG > 3000 and FOG <= 5000 then pitot1_d = 1.5 end
     if FOG > 1000 and FOG <= 3000 then pitot1_d = 1.8 end
     if FOG < 1000 then pitot1_d = 2.2 end
     if Rain_on_acf < 0.025 then pitot1_e = 1 end -- adds another speed of forming ice on Pitot1 by factor
     if Rain_on_acf > 0.025 then pitot1_e = 1.5 end
     if Wind_force < 10 then pitot1_f = 0.9 end -- Pitot1 gets colder from low wind force
     if Wind_force > 10 and Wind_force < 30 then pitot1_f = 1 end
     if Wind_force > 30 and speed_true > 200 then pitot1_f = 1.2 end -- Pitot1 is heating a bit from high speeds of wind and movement
     if Wind_dir > 270 and Wind_dir < 359 then pitot1_g = 1.2 end -- Pitot1 gets colder from direct wind
     if Wind_dir > 0 and Wind_dir < 270 then pitot1_g = 0.8 end -- Pitot1 dont absorb cold air because no wind on left side
     --ice_on_pitot1 = 1-(ice_on_pitot1+step_pitot1*pitot1_a*pitot1_b*pitot1_c*pitot1_d*pitot1_e*pitot1_f*pitot1_g) -- formula for forming ice on Pitot1
	 --new cloud check here
	if Height > Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   if Cloud_type0 == 0 then pitot1_h = 1 end --clear
	   if Cloud_type0 == 1 then pitot1_h = 1.2 end --cirrus
	   if Cloud_type0 == 2 then pitot1_h = 1.5 end --scattered
	   if Cloud_type0 == 3 then pitot1_h = 1.8 end --broken
	   if Cloud_type0 == 4 then pitot1_h = 2 end --overcast
	   if Cloud_type0 == 5 then pitot1_h = 3 end --stratus
	   if Cloud_coverage0 < 1 then pitot1_i = 1 end -- clear sky
	   if Cloud_coverage0 >= 1 and Cloud_coverage0 < 2 then pitot1_i = 1 end -- a few clouds
	   if Cloud_coverage0 >= 2 and Cloud_coverage0 < 3 then pitot1_i = 1.2 end -- normal coverage
	   if Cloud_coverage0 >= 3 and Cloud_coverage0 < 4 then pitot1_i = 1.5 end -- lot of clouds
	   if Cloud_coverage0 >= 4 and Cloud_coverage0 < 5 then pitot1_i = 1.8 end -- very high coverage
	   if Cloud_coverage0 >= 5 then pitot1_i = 2 end -- full coverage
	   --play_sound(ONE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	   --play_sound(TWO) --debug sound
	end
	if Height > Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   if Cloud_type1 == 0 then pitot1_h = 1 end --clear
	   if Cloud_type1 == 1 then pitot1_h = 1.2 end --cirrus
	   if Cloud_type1 == 2 then pitot1_h = 1.4 end --scattered
	   if Cloud_type1 == 3 then pitot1_h = 1.5 end --broken
	   if Cloud_type1 == 4 then pitot1_h = 2 end --overcast
	   if Cloud_type1 == 5 then pitot1_h = 2.5 end --stratus
	   if Cloud_coverage1 < 1 then pitot1_i = 1 end -- clear sky
	   if Cloud_coverage1 >= 1 and Cloud_coverage1 < 2 then pitot1_i = 1 end -- a few clouds
	   if Cloud_coverage1 >= 2 and Cloud_coverage1 < 3 then pitot1_i = 1.5 end -- normal coverage
	   if Cloud_coverage1 >= 3 and Cloud_coverage1 < 4 then pitot1_i = 2 end -- lot of clouds
	   if Cloud_coverage1 >= 4 and Cloud_coverage1 < 5 then pitot1_i = 3 end -- very high coverage
	   if Cloud_coverage1 >= 5 then pitot1_i = 4 end -- full coverage
	   --play_sound(TWO) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if Height > Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   if Cloud_type2 == 0 then pitot1_h = 1 end --clear
	   if Cloud_type2 == 1 then pitot1_h = 1.1 end --cirrus
	   if Cloud_type2 == 2 then pitot1_h = 1.3 end --scattered
	   if Cloud_type2 == 3 then pitot1_h = 1.4 end --broken
	   if Cloud_type2 == 4 then pitot1_h = 1.8 end --overcast
	   if Cloud_type2 == 5 then pitot1_h = 2 end --stratus
	   if Cloud_coverage2 < 1 then pitot1_i = 1 end -- clear sky
	   if Cloud_coverage2 >= 1 and Cloud_coverage2 < 2 then pitot1_i = 1 end -- a few clouds
	   if Cloud_coverage2 >= 2 and Cloud_coverage2 < 3 then pitot1_i = 1.5 end -- normal coverage
	   if Cloud_coverage2 >= 3 and Cloud_coverage2 < 4 then pitot1_i = 2 end -- lot of clouds
	   if Cloud_coverage2 >= 4 and Cloud_coverage2 < 5 then pitot1_i = 3 end -- very high coverage
	   if Cloud_coverage2 >= 5 then pitot1_i = 4 end -- full coverage
	   --play_sound(THREE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if in_clouds ~= 1 and Altitude > 20000 then
    	pitot1_h = 0
		--play_sound(LOOKINGOODTWICE) --debug sound
		--play_sound(THREE)
	end -- not in clouds above FL200? no more ice cumulation
	--end of new cloud check here
	if paused_sim == 1 then step_pitot1 = 0 end --paused sim bug resolver
	 ice_on_pitot1 = ice_on_pitot1+step_pitot1*pitot1_a*pitot1_b*pitot1_c*pitot1_d*pitot1_e*pitot1_f*pitot1_g*pitot1_h*pitot1_i*clearsky_general -- formula for forming ice on Pitot1
	 --play_sound(ONE)
	 if ice_on_pitot1 > 0.099 then
 	    if played_icingcondition == false then 
	      play_sound(ICINGCONDITION)
	      played_icingcondition = true --you hear that? dont play it again
        end
	 end	 
     if ice_on_pitot1 > 0.99995 then
    	ice_on_pitot1 = 1
		if played_goddamnit == false and played_ohmygod == false then 
	      play_sound(GODDAMNIT)
	      played_goddamnit = true --you hear that? dont play it again
        end
	 end
	 -- if ice_on_pitot1 > 0.01 and ice_on_pitot1 < 0.200 and played_icingcondition == true then
	  --  if played_wearegoodnow == false and played_lookingoodtwice == false then -- play it before lookingood
	  --    play_sound(WEAREGOODNOW)
	  --    played_wearegoodnow = true --you hear that? dont play it again
      --  end
	 -- end
     if ice_on_pitot1 < 0.000001 then
    	ice_on_pitot1 = 0
	    if played_icingcondition == true then
	     if played_wearegoodnow == false and played_lookingoodtwice == false then -- play it before lookingood
	      play_sound(WEAREGOODNOW)
	      played_wearegoodnow = true --you hear that? dont play it again
         end
	    end
	 end -- limit values
   end -- end if its cold
 
end -- end of Pitot1 function
 
  --second (right) pitot 
function Pitot2() -- check conditions for right Pitot icing
--Pitots fail section
-- 748-i bug resolver here
if ACFTYPE == 748 then ice_on_pitot2 = 0 end
-- end of 748-i bug resolver
--TAT is below zero
 if TAT < 0 and Pitot2_ON == 1 then -- Pitot2 heat is on and cold outside - no change
   --step_pitot2 = 0 
   step_pitot2 = 0.01 
   --if paused_sim == 1 then step_pitot2 = 0 end --paused sim bug resolver
   --play_sound(ONE)
   -- new override formula
   if paused_sim == 1 then step_pitot2 = 0 end --paused sim bug resolver
   ice_on_pitot2 = ice_on_pitot2-step_pitot2
   if ice_on_pitot2 > 0.99995 then ice_on_pitot2 = 1 end -- limit value
   if ice_on_pitot2 < 0.000001 then ice_on_pitot2 = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
 end
   if TAT > 0 then 
     step_pitot2 = dxib_mul
	 --step_pitot2 = (AIRDENS/10000)*math.abs(HUMID/100)
	 --if paused_sim == 1 then step_pitot2 = 0 end --paused sim bug resolver
	 if speed_true > 10 and speed_true < 100 then pitot2_a = 2 end -- adds speed of forming ice on Pitot2 by factor
     if speed_true > 100 and speed_true < 200 then pitot2_a = 4 end
     if speed_true > 200 then pitot2_a = 8 end
	 if Altitude > 0 and Altitude < 6000 then pitot2_b = 1.2 end
     if Altitude > 6000 and Altitude < 12000 then pitot2_b = 2 end -- adds another speed of forming ice on Pitot2 by factor
     if Altitude > 12000 and Altitude < 30000 then pitot2_b = 6 end
     if Altitude > 30000 then pitot2_b = 8 end
     if OAT < 0 and OAT > -20 then  pitot2_c = 1 end -- adds another speed of forming ice on Pitot2 by factor
     if OAT < -20 and OAT > -40 then  pitot2_c = 6 end
     if OAT < -40 then pitot2_c = 8 end
     --if FOG > 1000 then pitot2_d = 1 end -- adds another speed of forming ice on Pitot2 by factor
     --if FOG < 1000 then pitot2_d = 2 end
	 if FOG > 5000 then pitot2_d = 1 end -- adds another speed of forming ice on Window by factor
     if FOG > 3000 and FOG <= 5000 then pitot2_d = 1.1 end
     if FOG > 1000 and FOG <= 3000 then pitot2_d = 1.2 end
     if FOG < 1000 then pitot2_d = 1.5 end
     if Rain_on_acf < 0.025 then pitot2_e = 1 end -- adds another speed of forming ice on Pitot2 by factor
     if Rain_on_acf > 0.025 then pitot2_e = 2 end
     if Wind_force < 10 then pitot2_f = 3 end -- Pitot2 gets colder from low wind force
     if Wind_force > 10 and Wind_force < 30 then pitot2_f = 1 end
     if Wind_force > 30 and speed_true > 200 then pitot2_f = 0.4 end -- Pitot2 is heating a bit from high speeds of wind and movement
     if Wind_dir > 0 and Wind_dir < 90 then pitot2_g = 4 end -- Pitot2 gets colder from direct wind
     if Wind_dir > 90 and Wind_dir < 359 then pitot2_g = 1 end -- Pitot2 dont absorb cold air because no wind on left side
     --ice_on_pitot2 = 1-(ice_on_pitot2+step_pitot2*pitot2_a*pitot2_b*pitot2_c*pitot2_d*pitot2_e*pitot2_f*pitot2_g) -- formula for forming ice on Pitot2
	 if paused_sim == 1 then step_pitot2 = 0 end --paused sim bug resolver
	 ice_on_pitot2 = ice_on_pitot2-step_pitot2*pitot2_a*pitot2_b*pitot2_c*pitot2_d*pitot2_e*pitot2_f*pitot2_g*clearsky_general -- formula for forming ice on Pitot2
	 --play_sound(TWO)
     if ice_on_pitot2 > 0.99995 then ice_on_pitot2 = 1 end
     if ice_on_pitot2 < 0.000001 then ice_on_pitot2 = 0 end -- limit values
   end -- end if its hot
   
   if TAT < 0 and Pitot2_ON ~= 1 and ground_deice == 0 then  -- Pitot2 heat is off and cold outside and deice is not active
   step_pitot2 = dxib_mul -- default coeficient for Pitot2 , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_pitot2 = (AIRDENS/10000)*math.abs(HUMID/100)
  -- if paused_sim == 1 then step_pitot2 = 0 end --paused sim bug resolver
   if speed_true > 10 and speed_true < 100 then pitot2_a = 1.1 end -- adds speed of forming ice on Pitot2 by factor
   if speed_true > 100 and speed_true < 200 then pitot2_a = 1.2 end
   if speed_true > 200 then pitot2_a = 1.5 end
   if Altitude > 0 and Altitude < 6000 then pitot2_b = 1.5 end
   if Altitude > 6000 and Altitude < 12000 then pitot2_b = 1.2 end -- adds another speed of forming ice on Pitot2 by factor
   if Altitude > 12000 and Altitude < 30000 then pitot2_b = 1.1 end
   if Altitude > 30000 then pitot2_b = 1 end
   if OAT < 0 and OAT > -20 then  pitot2_c = 1.5 end -- adds another speed of forming ice on Pitot2 by factor
   if OAT < -20 and OAT > -40 then  pitot2_c = 1.2 end
   --if OAT > -40 then pitot2_c = 4 end
   --if OAT < -40 then pitot2_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 0 then pitot2_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 1 then pitot2_c = 1 end -- new from physics analysis, in clouds icing
   --if FOG > 1000 then pitot2_d = 1 end -- adds another speed of forming ice on Pitot2 by factor
   --if FOG < 1000 then pitot2_d = 2 end
   if FOG > 5000 then pitot2_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then pitot2_d = 1.5 end
   if FOG > 1000 and FOG <= 3000 then pitot2_d = 1.8 end
   if FOG < 1000 then pitot2_d = 2.2 end
   if Rain_on_acf < 0.025 then pitot2_e = 1 end -- adds another speed of forming ice on Pitot2 by factor
   if Rain_on_acf > 0.025 then pitot2_e = 1.5 end
   if Wind_force < 10 then pitot2_f = 0.9 end -- Pitot2 gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then pitot2_f = 1 end
   if Wind_force > 30 and speed_true > 200 then pitot2_f = 1.2 end -- Pitot2 is heating a bit from high speeds of wind and movement
   if Wind_dir > 0 and Wind_dir < 90 then pitot2_g = 1.2 end -- Pitot2 gets colder from direct wind
   if Wind_dir > 90 and Wind_dir < 359 then pitot2_g = 0.8 end -- Pitot2 dont absorb cold air because no wind on left side
   --new cloud check here
	if Height > Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   if Cloud_type0 == 0 then pitot2_h = 1 end --clear
	   if Cloud_type0 == 1 then pitot2_h = 1.2 end --cirrus
	   if Cloud_type0 == 2 then pitot2_h = 1.5 end --scattered
	   if Cloud_type0 == 3 then pitot2_h = 1.8 end --broken
	   if Cloud_type0 == 4 then pitot2_h = 2 end --overcast
	   if Cloud_type0 == 5 then pitot2_h = 3 end --stratus
	   if Cloud_coverage0 < 1 then pitot2_i = 1 end -- clear sky
	   if Cloud_coverage0 >= 1 and Cloud_coverage0 < 2 then pitot2_i = 1 end -- a few clouds
	   if Cloud_coverage0 >= 2 and Cloud_coverage0 < 3 then pitot2_i = 1.2 end -- normal coverage
	   if Cloud_coverage0 >= 3 and Cloud_coverage0 < 4 then pitot2_i = 1.5 end -- lot of clouds
	   if Cloud_coverage0 >= 4 and Cloud_coverage0 < 5 then pitot2_i = 1.8 end -- very high coverage
	   if Cloud_coverage0 >= 5 then pitot2_i = 2 end -- full coverage
	   --play_sound(ONE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	   --play_sound(TWO) --debug sound
	end
	if Height > Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   if Cloud_type1 == 0 then pitot2_h = 1 end --clear
	   if Cloud_type1 == 1 then pitot2_h = 1.2 end --cirrus
	   if Cloud_type1 == 2 then pitot2_h = 1.4 end --scattered
	   if Cloud_type1 == 3 then pitot2_h = 1.5 end --broken
	   if Cloud_type1 == 4 then pitot2_h = 2 end --overcast
	   if Cloud_type1 == 5 then pitot2_h = 2.5 end --stratus
	   if Cloud_coverage1 < 1 then pitot2_i = 1 end -- clear sky
	   if Cloud_coverage1 >= 1 and Cloud_coverage1 < 2 then pitot2_i = 1 end -- a few clouds
	   if Cloud_coverage1 >= 2 and Cloud_coverage1 < 3 then pitot2_i = 1.5 end -- normal coverage
	   if Cloud_coverage1 >= 3 and Cloud_coverage1 < 4 then pitot2_i = 2 end -- lot of clouds
	   if Cloud_coverage1 >= 4 and Cloud_coverage1 < 5 then pitot2_i = 3 end -- very high coverage
	   if Cloud_coverage1 >= 5 then pitot2_i = 4 end -- full coverage
	   --play_sound(TWO) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if Height > Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   if Cloud_type2 == 0 then pitot2_h = 1 end --clear
	   if Cloud_type2 == 1 then pitot2_h = 1.1 end --cirrus
	   if Cloud_type2 == 2 then pitot2_h = 1.3 end --scattered
	   if Cloud_type2 == 3 then pitot2_h = 1.4 end --broken
	   if Cloud_type2 == 4 then pitot2_h = 1.8 end --overcast
	   if Cloud_type2 == 5 then pitot2_h = 2 end --stratus
	   if Cloud_coverage2 < 1 then pitot2_i = 1 end -- clear sky
	   if Cloud_coverage2 >= 1 and Cloud_coverage2 < 2 then pitot2_i = 1 end -- a few clouds
	   if Cloud_coverage2 >= 2 and Cloud_coverage2 < 3 then pitot2_i = 1.5 end -- normal coverage
	   if Cloud_coverage2 >= 3 and Cloud_coverage2 < 4 then pitot2_i = 2 end -- lot of clouds
	   if Cloud_coverage2 >= 4 and Cloud_coverage2 < 5 then pitot2_i = 3 end -- very high coverage
	   if Cloud_coverage2 >= 5 then pitot2_i = 4 end -- full coverage
	   --play_sound(THREE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if in_clouds ~= 1 and Altitude > 20000 then
    	pitot2_h = 0
		--play_sound(LOOKINGOODTWICE) --debug sound
		--play_sound(THREE)
	end -- not in clouds above FL200? no more ice cumulation
	--end of new cloud check here
   if paused_sim == 1 then step_pitot2 = 0 end --paused sim bug resolver
   ice_on_pitot2 = ice_on_pitot2+step_pitot2*pitot2_a*pitot2_b*pitot2_c*pitot2_d*pitot2_e*pitot2_f*pitot2_g*pitot2_h*pitot2_i*clearsky_general -- formula for forming ice on Pitot2
   --play_sound(THREE)
   if ice_on_pitot2 > 0.095 then
 	    if played_icingcondition == false then 
	      play_sound(ICINGCONDITION)
	      played_icingcondition = true --you hear that? dont play it again
        end
	 end
   if ice_on_pitot2 > 0.99995 then ice_on_pitot2 = 1 end
   if ice_on_pitot2 < 0.000001 then ice_on_pitot2 = 0 end -- limit values
   --if ice_on_aoa < 0.9 then fail_on_AOA = 0 end -- disable failure does not work

 end -- end of Pitot2 is below zero
end -- end of Pitot2 function
 
 -- now static port
 
 function Static1() -- check conditions for Static port icing
--Static fail section
--767 bug resolver here
if ACFTYPE == 767 and Window_ON == 1 then ice_on_static1 = 0 end
--end of 767 bug resolver here
--TAT is below zero
 if TAT < 0 and Static1_ON == 1 then -- Static1 heat is on and cold outside - no change
   --step_static1 = 0
   step_static1 = 0.01
   --if paused_sim == 1 then step_static1 = 0 end --paused sim bug resolver
 -- new override formula
   if paused_sim == 1 then step_static1 = 0 end --paused sim bug resolver
   ice_on_static1 = ice_on_static1-step_static1
   if ice_on_static1 > 0.99995 then ice_on_static1 = 1 end -- limit value
   if ice_on_static1 < 0.000001 then ice_on_static1 = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
 end
  if TAT > 0 then
   step_static1 = dxib_mul -- default coeficient for Static1 , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_static1 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_static1 = 0 end --paused sim bug resolver
   if speed_true > 10 and speed_true < 100 then static1_a = 2 end -- adds speed of forming ice on Static1 by factor
   if speed_true > 100 and speed_true < 200 then static1_a = 4 end
   if speed_true > 200 then static1_a = 8 end
   if Altitude > 0 and Altitude < 6000 then static1_b = 1.2 end
   if Altitude > 6000 and Altitude < 12000 then static1_b = 2 end -- adds another speed of forming ice on Static1 by factor
   if Altitude > 12000 and Altitude < 30000 then static1_b = 6 end
   if Altitude > 30000 then static1_b = 8 end
   if OAT < 0 and OAT > -20 then  static1_c = 1 end -- adds another speed of forming ice on Static1 by factor
   if OAT < -20 and OAT > -40 then  static1_c = 6 end
   if OAT < -40 then static1_c = 8 end
   --if FOG > 1000 then static1_d = 1 end -- adds another speed of forming ice on Static1 by factor
   --if FOG < 1000 then static1_d = 2 end
   if FOG > 5000 then static1_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then static1_d = 1.1 end
   if FOG > 1000 and FOG <= 3000 then static1_d = 1.2 end
   if FOG < 1000 then static1_d = 1.5 end
   if Rain_on_acf < 0.025 then static1_e = 1 end -- adds another speed of forming ice on Static1 by factor
   if Rain_on_acf > 0.025 then static1_e = 2 end
   if Wind_force < 10 then static1_f = 3 end -- Static1 gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then static1_f = 1 end
   if Wind_force > 30 and speed_true > 200 then static1_f = 0.4 end -- Static1 is heating a bit from high speeds of wind and movement
   if Wind_dir > 270 and Wind_dir < 359 then static1_g = 5 end -- Static1 gets colder from direct wind
   if Wind_dir > 0 and Wind_dir < 270 then static1_g = 1 end -- Static1 dont absorb cold air because no wind on left side
   if paused_sim == 1 then step_static1 = 0 end --paused sim bug resolver
   ice_on_static1 = ice_on_static1-step_static1*static1_a*static1_b*static1_c*static1_d*static1_e*static1_f*static1_g*clearsky_general -- formula for forming ice on Static1
   --play_sound(TWO)
   if ice_on_static1 > 0.99995 then ice_on_static1 = 1 end -- limit value
   if ice_on_static1 < 0.000001 then ice_on_static1 = 0 end
   --if ice_on_aoa < 0.9 then fail_on_AOA = 0 end -- disable failure does not work

  end -- end of Static1 is hot
    if TAT < 0 and Static1_ON ~= 1 and ground_deice == 0 then 
     step_static1 = dxib_mul
	 --step_static1 = (AIRDENS/10000)*math.abs(HUMID/100)
	 --if paused_sim == 1 then step_static1 = 0 end --paused sim bug resolver
	 if speed_true > 10 and speed_true < 100 then static1_a = 1.1 end -- adds speed of forming ice on Static1 by factor
     if speed_true > 100 and speed_true < 200 then static1_a = 1.2 end
     if speed_true > 200 then static1_a = 1.5 end
	 if Altitude > 0 and Altitude < 6000 then static1_b = 1.5 end
     if Altitude > 6000 and Altitude < 12000 then static1_b = 1.2 end -- adds another speed of forming ice on Static1 by factor
     if Altitude > 12000 and Altitude < 30000 then static1_b = 1.1 end
     if Altitude > 30000 then static1_b = 1 end
     if OAT < 0 and OAT > -20 then  static1_c = 1.5 end -- adds another speed of forming ice on Static1 by factor
     if OAT < -20 and OAT > -40 then  static1_c = 1.2 end
     --if OAT > -40 then pitot1_c = 4 end
	 --if OAT < -40 then static1_c = 0 end -- new from physics analysis, stops further freezing
	 if OAT < -48 and in_clouds == 0 then static1_c = 0 end -- new from physics analysis, stops further freezing
     if OAT < -48 and in_clouds == 1 then static1_c = 1 end -- new from physics analysis, in clouds icing
     --if FOG > 1000 then static1_d = 1 end -- adds another speed of forming ice on Static1 by factor
     --if FOG < 1000 then static1_d = 2 end
	 if FOG > 5000 then static1_d = 1 end -- adds another speed of forming ice on Window by factor
     if FOG > 3000 and FOG <= 5000 then static1_d = 1.5 end
     if FOG > 1000 and FOG <= 3000 then static1_d = 1.8 end
     if FOG < 1000 then static1_d = 2.2 end
     if Rain_on_acf < 0.025 then static1_e = 1 end -- adds another speed of forming ice on Static1 by factor
     if Rain_on_acf > 0.025 then static1_e = 1.5 end
     if Wind_force < 10 then static1_f = 0.9 end -- Static1 gets colder from low wind force
     if Wind_force > 10 and Wind_force < 30 then static1_f = 1 end
     if Wind_force > 30 and speed_true > 200 then static1_f = 1.2 end -- Static1 is heating a bit from high speeds of wind and movement
     if Wind_dir > 270 and Wind_dir < 359 then static1_g = 1.2 end -- Static1 gets colder from direct wind
     if Wind_dir > 0 and Wind_dir < 270 then static1_g = 0.8 end -- Static1 dont absorb cold air because no wind on left side
     --ice_on_pitot1 = 1-(ice_on_pitot1+step_pitot1*pitot1_a*pitot1_b*pitot1_c*pitot1_d*pitot1_e*pitot1_f*pitot1_g) -- formula for forming ice on Pitot1
	 --new cloud check here
	if Height > Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   if Cloud_type0 == 0 then static1_h = 1 end --clear
	   if Cloud_type0 == 1 then static1_h = 1.2 end --cirrus
	   if Cloud_type0 == 2 then static1_h = 1.5 end --scattered
	   if Cloud_type0 == 3 then static1_h = 1.8 end --broken
	   if Cloud_type0 == 4 then static1_h = 2 end --overcast
	   if Cloud_type0 == 5 then static1_h = 3 end --stratus
	   if Cloud_coverage0 < 1 then static1_i = 1 end -- clear sky
	   if Cloud_coverage0 >= 1 and Cloud_coverage0 < 2 then static1_i = 1 end -- a few clouds
	   if Cloud_coverage0 >= 2 and Cloud_coverage0 < 3 then static1_i = 1.2 end -- normal coverage
	   if Cloud_coverage0 >= 3 and Cloud_coverage0 < 4 then static1_i = 1.5 end -- lot of clouds
	   if Cloud_coverage0 >= 4 and Cloud_coverage0 < 5 then static1_i = 1.8 end -- very high coverage
	   if Cloud_coverage0 >= 5 then static1_i = 2 end -- full coverage
	   --play_sound(ONE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	   --play_sound(TWO) --debug sound
	end
	if Height > Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   if Cloud_type1 == 0 then static1_h = 1 end --clear
	   if Cloud_type1 == 1 then static1_h = 1.2 end --cirrus
	   if Cloud_type1 == 2 then static1_h = 1.4 end --scattered
	   if Cloud_type1 == 3 then static1_h = 1.5 end --broken
	   if Cloud_type1 == 4 then static1_h = 2 end --overcast
	   if Cloud_type1 == 5 then static1_h = 2.5 end --stratus
	   if Cloud_coverage1 < 1 then static1_i = 1 end -- clear sky
	   if Cloud_coverage1 >= 1 and Cloud_coverage1 < 2 then static1_i = 1 end -- a few clouds
	   if Cloud_coverage1 >= 2 and Cloud_coverage1 < 3 then static1_i = 1.5 end -- normal coverage
	   if Cloud_coverage1 >= 3 and Cloud_coverage1 < 4 then static1_i = 2 end -- lot of clouds
	   if Cloud_coverage1 >= 4 and Cloud_coverage1 < 5 then static1_i = 3 end -- very high coverage
	   if Cloud_coverage1 >= 5 then static1_i = 4 end -- full coverage
	   --play_sound(TWO) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if Height > Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   if Cloud_type2 == 0 then static1_h = 1 end --clear
	   if Cloud_type2 == 1 then static1_h = 1.1 end --cirrus
	   if Cloud_type2 == 2 then static1_h = 1.3 end --scattered
	   if Cloud_type2 == 3 then static1_h = 1.4 end --broken
	   if Cloud_type2 == 4 then static1_h = 1.8 end --overcast
	   if Cloud_type2 == 5 then static1_h = 2 end --stratus
	   if Cloud_coverage2 < 1 then static1_i = 1 end -- clear sky
	   if Cloud_coverage2 >= 1 and Cloud_coverage2 < 2 then static1_i = 1 end -- a few clouds
	   if Cloud_coverage2 >= 2 and Cloud_coverage2 < 3 then static1_i = 1.5 end -- normal coverage
	   if Cloud_coverage2 >= 3 and Cloud_coverage2 < 4 then static1_i = 2 end -- lot of clouds
	   if Cloud_coverage2 >= 4 and Cloud_coverage2 < 5 then static1_i = 3 end -- very high coverage
	   if Cloud_coverage2 >= 5 then static1_i = 4 end -- full coverage
	   --play_sound(THREE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if in_clouds ~= 1 and Altitude > 20000 then
    	static1_h = 0
		--play_sound(LOOKINGOODTWICE) --debug sound
		--play_sound(THREE)
	end -- not in clouds above FL200? no more ice cumulation
	--end of new cloud check here
	 if paused_sim == 1 then step_static1 = 0 end --paused sim bug resolver
	 ice_on_static1 = ice_on_static1+step_static1*static1_a*static1_b*static1_c*static1_d*static1_e*static1_f*static1_g*static1_h*static1_i*clearsky_general -- formula for forming ice on Static1
	 --play_sound(TWO)
	 --if ice_on_static1 > 0.399 then
 	    --if played_icingcondition == false then 
	    --  play_sound(ICINGCONDITION)
	    --  played_icingcondition = true --you hear that? dont play it again
       -- end
	 --end	 
     if ice_on_static1 > 0.99995 then ice_on_static1 = 1 end
		--if played_goddamnit == false then 
	   --   play_sound(GODDAMNIT)
	    --  played_goddamnit = true --you hear that? dont play it again
       -- end
	 --end
	  --if ice_on_static1 > 0.01 and ice_on_static1 < 0.200 and played_icingcondition == true then
	   -- if played_wearegoodnow == false and played_lookingoodtwice == false then -- play it before lookingood
	   --   play_sound(WEAREGOODNOW)
	   --   played_wearegoodnow = true --you hear that? dont play it again
       -- end
	  --end
     if ice_on_static1 < 0.000001 then ice_on_static1 = 0 end -- limit values
   end -- end if its cold
 
end -- end of Pitot1 function
 
  --second (right) pitot 
function Static2() -- check conditions for right Pitot icing
--Pitots fail section
--767 bug resolver here
if ACFTYPE == 767 and Window_ON == 1 then ice_on_static2 = 0 end
--end of 767 bug resolver here
--TAT is below zero
 if TAT < 0 and Static2_ON == 1 then -- Static2 heat is on and cold outside - no change 
    -- here Static1 works only
	--step_static2 = 0
   step_static2 = 0.01 
   --play_sound(ONE)
    -- new override formula
   if paused_sim == 1 then step_static2 = 0 end --paused sim bug resolver
   ice_on_static2 = ice_on_static2-step_static2
   if ice_on_static2 > 0.99995 then ice_on_static2 = 1 end -- limit value
   if ice_on_static2 < 0.000001 then ice_on_static2 = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
 end
   if TAT > 0 then 
     step_static2 = dxib_mul
	 --step_static2 = (AIRDENS/10000)*math.abs(HUMID/100)
	 --if paused_sim == 1 then step_static2 = 0 end --paused sim bug resolver
	 if speed_true > 10 and speed_true < 100 then static2_a = 2 end -- adds speed of forming ice on Static2 by factor
     if speed_true > 100 and speed_true < 200 then static2_a = 4 end
     if speed_true > 200 then static2_a = 8 end
	 if Altitude > 0 and Altitude < 6000 then static2_b = 1.2 end
     if Altitude > 6000 and Altitude < 12000 then static2_b = 2 end -- adds another speed of forming ice on Static2 by factor
     if Altitude > 12000 and Altitude < 30000 then static2_b = 6 end
     if Altitude > 30000 then static2_b = 8 end
     if OAT < 0 and OAT > -20 then  static2_c = 1 end -- adds another speed of forming ice on Static2 by factor
     if OAT < -20 and OAT > -40 then  static2_c = 6 end
     if OAT < -40 then static2_c = 8 end
     --if FOG > 1000 then static2_d = 1 end -- adds another speed of forming ice on Static2 by factor
     --if FOG < 1000 then static2_d = 2 end
	 if FOG > 5000 then static2_d = 1 end -- adds another speed of forming ice on Window by factor
     if FOG > 3000 and FOG <= 5000 then static2_d = 1.1 end
     if FOG > 1000 and FOG <= 3000 then static2_d = 1.2 end
     if FOG < 1000 then static2_d = 1.5 end
     if Rain_on_acf < 0.025 then static2_e = 1 end -- adds another speed of forming ice on Static2 by factor
     if Rain_on_acf > 0.025 then static2_e = 2 end
     if Wind_force < 10 then static2_f = 3 end -- Static2 gets colder from low wind force
     if Wind_force > 10 and Wind_force < 30 then static2_f = 1 end
     if Wind_force > 30 and speed_true > 200 then static2_f = 0.4 end -- Static2 is heating a bit from high speeds of wind and movement
     if Wind_dir > 0 and Wind_dir < 90 then static2_g = 5 end -- Static2 gets colder from direct wind
     if Wind_dir > 90 and Wind_dir < 359 then static2_g = 1 end -- Static2 dont absorb cold air because no wind on left side
     --ice_on_pitot2 = 1-(ice_on_pitot2+step_pitot2*pitot2_a*pitot2_b*pitot2_c*pitot2_d*pitot2_e*pitot2_f*pitot2_g) -- formula for forming ice on Pitot2
	 if paused_sim == 1 then step_static2 = 0 end --paused sim bug resolver
	 ice_on_static2 = ice_on_static2-step_static2*static2_a*static2_b*static2_c*static2_d*static2_e*static2_f*static2_g*clearsky_general -- formula for forming ice on Pitot2
	 --play_sound(TWO)
     if ice_on_static2 > 0.99995 then ice_on_static2 = 1 end
     if ice_on_static2 < 0.000001 then ice_on_static2 = 0 end -- limit values
   end -- end if its hot
   
   if TAT < 0 and Static2_ON ~= 1 and ground_deice == 0 then  -- Static2 heat is off and cold outside and deice is not active
   step_static2 = dxib_mul -- default coeficient for Static2 , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_static2 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_static2 = 0 end --paused sim bug resolver
   if speed_true > 10 and speed_true < 100 then static2_a = 1.1 end -- adds speed of forming ice on Static2 by factor
   if speed_true > 100 and speed_true < 200 then static2_a = 1.2 end
   if speed_true > 200 then static2_a = 1.5 end
   if Altitude > 0 and Altitude < 6000 then static2_b = 1.5 end
   if Altitude > 6000 and Altitude < 12000 then static2_b = 1.2 end -- adds another speed of forming ice on Static2 by factor
   if Altitude > 12000 and Altitude < 30000 then static2_b = 1.1 end
   if Altitude > 30000 then static2_b = 1 end
   if OAT < 0 and OAT > -20 then  static2_c = 1.5 end -- adds another speed of forming ice on Static2 by factor
   if OAT < -20 and OAT > -40 then  static2_c = 1.2 end
   --if OAT > -40 then pitot2_c = 4 end
   --if OAT < -40 then static2_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 0 then static2_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 1 then static2_c = 1 end -- new from physics analysis, in clouds icing
   --if FOG > 1000 then static2_d = 1 end -- adds another speed of forming ice on Static2 by factor
   --if FOG < 1000 then static2_d = 2 end
   if FOG > 5000 then static2_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then static2_d = 1.5 end
   if FOG > 1000 and FOG <= 3000 then static2_d = 1.8 end
   if FOG < 1000 then static2_d = 2.2 end
   if Rain_on_acf < 0.025 then static2_e = 1 end -- adds another speed of forming ice on Static2 by factor
   if Rain_on_acf > 0.025 then static2_e = 1.5 end
   if Wind_force < 10 then static2_f = 0.9 end -- Static2 gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then static2_f = 1 end
   if Wind_force > 30 and speed_true > 200 then static2_f = 1.2 end -- Static2 is heating a bit from high speeds of wind and movement
   if Wind_dir > 0 and Wind_dir < 90 then static2_g = 1.2 end -- Static2 gets colder from direct wind
   if Wind_dir > 90 and Wind_dir < 359 then static2_g = 0.8 end -- Static2 dont absorb cold air because no wind on left side
   --new cloud check here
	if Height > Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   if Cloud_type0 == 0 then static2_h = 1 end --clear
	   if Cloud_type0 == 1 then static2_h = 1.2 end --cirrus
	   if Cloud_type0 == 2 then static2_h = 1.5 end --scattered
	   if Cloud_type0 == 3 then static2_h = 1.8 end --broken
	   if Cloud_type0 == 4 then static2_h = 2 end --overcast
	   if Cloud_type0 == 5 then static2_h = 3 end --stratus
	   if Cloud_coverage0 < 1 then static2_i = 1 end -- clear sky
	   if Cloud_coverage0 >= 1 and Cloud_coverage0 < 2 then static2_i = 1 end -- a few clouds
	   if Cloud_coverage0 >= 2 and Cloud_coverage0 < 3 then static2_i = 1.2 end -- normal coverage
	   if Cloud_coverage0 >= 3 and Cloud_coverage0 < 4 then static2_i = 1.5 end -- lot of clouds
	   if Cloud_coverage0 >= 4 and Cloud_coverage0 < 5 then static2_i = 1.8 end -- very high coverage
	   if Cloud_coverage0 >= 5 then static2_i = 2 end -- full coverage
	   --play_sound(ONE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	   --play_sound(TWO) --debug sound
	end
	if Height > Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   if Cloud_type1 == 0 then static2_h = 1 end --clear
	   if Cloud_type1 == 1 then static2_h = 1.2 end --cirrus
	   if Cloud_type1 == 2 then static2_h = 1.4 end --scattered
	   if Cloud_type1 == 3 then static2_h = 1.5 end --broken
	   if Cloud_type1 == 4 then static2_h = 2 end --overcast
	   if Cloud_type1 == 5 then static2_h = 2.5 end --stratus
	   if Cloud_coverage1 < 1 then static2_i = 1 end -- clear sky
	   if Cloud_coverage1 >= 1 and Cloud_coverage1 < 2 then static2_i = 1 end -- a few clouds
	   if Cloud_coverage1 >= 2 and Cloud_coverage1 < 3 then static2_i = 1.5 end -- normal coverage
	   if Cloud_coverage1 >= 3 and Cloud_coverage1 < 4 then static2_i = 2 end -- lot of clouds
	   if Cloud_coverage1 >= 4 and Cloud_coverage1 < 5 then static2_i = 3 end -- very high coverage
	   if Cloud_coverage1 >= 5 then static2_i = 4 end -- full coverage
	   --play_sound(TWO) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if Height > Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   if Cloud_type2 == 0 then static2_h = 1 end --clear
	   if Cloud_type2 == 1 then static2_h = 1.1 end --cirrus
	   if Cloud_type2 == 2 then static2_h = 1.3 end --scattered
	   if Cloud_type2 == 3 then static2_h = 1.4 end --broken
	   if Cloud_type2 == 4 then static2_h = 1.8 end --overcast
	   if Cloud_type2 == 5 then static2_h = 2 end --stratus
	   if Cloud_coverage2 < 1 then static2_i = 1 end -- clear sky
	   if Cloud_coverage2 >= 1 and Cloud_coverage2 < 2 then static2_i = 1 end -- a few clouds
	   if Cloud_coverage2 >= 2 and Cloud_coverage2 < 3 then static2_i = 1.5 end -- normal coverage
	   if Cloud_coverage2 >= 3 and Cloud_coverage2 < 4 then static2_i = 2 end -- lot of clouds
	   if Cloud_coverage2 >= 4 and Cloud_coverage2 < 5 then static2_i = 3 end -- very high coverage
	   if Cloud_coverage2 >= 5 then static2_i = 4 end -- full coverage
	   --play_sound(THREE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if in_clouds ~= 1 and Altitude > 20000 then
    	static2_h = 0
		--play_sound(LOOKINGOODTWICE) --debug sound
		--play_sound(THREE)
	end -- not in clouds above FL200? no more ice cumulation
	--end of new cloud check here
   if paused_sim == 1 then step_static2 = 0 end --paused sim bug resolver
   ice_on_static2 = ice_on_static2+step_static2*static2_a*static2_b*static2_c*static2_d*static2_e*static2_f*static2_g*static2_h*static2_i*clearsky_general -- formula for forming ice on Pitot2
   --ice_on_static2 = 0 --temporary disable
   --play_sound(THREE)
   if ice_on_static2 > 0.99995 then ice_on_static2 = 1 end
   if ice_on_static2 < 0.000001 then ice_on_static2 = 0 end -- limit values
   --if ice_on_aoa < 0.9 then fail_on_AOA = 0 end -- disable failure does not work

 end -- end of Static2 is below zero
end -- end of Static2 function
 
 -- end of static ports
   --now window frost 
function Window() -- check conditions for window freezing
--Window heat fail section
--OAT is below zero
--737 bug resolver here
if ACFTYPE == 738 and Pitot1_ON == 1 then ice_on_window = 0 end
--end of 737 bug resolver here
--FF320 bug resolver here
if ACFTYPE == 320 and Pitot1_ON == 1 then ice_on_window = 0 end --eng2 may still fail
--end of FF320 bug resolver here
 if OAT < 0 and Window_ON == 1 then -- Window heat is on and cold outside - no change
   --step_window = 0 
   step_window = 0.01 
   if paused_sim == 1 then step_window = 0 end --paused sim bug resolver
   -- new override formula
   ice_on_window = ice_on_window-step_window
   if ice_on_window > 0.99995 then ice_on_window = 1 end -- limit value
   if ice_on_window < 0.000001 then ice_on_window = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
 end
  if OAT > 0 then
   step_window = dxib_mul -- default coeficient for Window heat , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_window = (AIRDENS/10000)*math.abs(HUMID/100) --testing by airdensity
   --if paused_sim == 1 then step_window = 0 end --paused sim bug resolver
    if speed_true > 10 and speed_true < 100 then window_a = 1 end -- adds speed of forming ice on Window by factor
    if speed_true > 100 and speed_true < 200 then window_a = 1.5 end
    if speed_true > 200 then window_a = 2 end
	if Altitude > 0 and Altitude < 6000 then window_b = 2.5 end
    if Altitude > 6000 and Altitude < 12000 then window_b = 2 end -- adds another speed of forming ice on Window by factor
    if Altitude > 12000 and Altitude < 30000 then window_b = 1 end
    if Altitude > 30000 then window_b = 0.95 end
    if TAT < 0 and TAT > -20 then  window_c = 2 end -- adds another speed of forming ice on Window by factor
    if TAT < -20 and TAT > -40 then  window_c = 1.5 end
    if TAT < -40 then window_c = 1 end
    if FOG > 5000 then window_d = 1 end -- adds another speed of forming ice on Window by factor
	if FOG > 3000 and FOG <= 5000 then window_d = 1.1 end
	if FOG > 1000 and FOG <= 3000 then window_d = 1.2 end
    if FOG < 1000 then window_d = 1.5 end
    if Rain_on_acf < 0.025 then window_e = 1 end -- adds another speed of forming ice on Window by factor
    if Rain_on_acf > 0.025 then window_e = 2 end
    if Wind_force < 10 then window_f = 1 end -- Window gets colder from low wind force
    if Wind_force > 10 and Wind_force < 30 then window_f = 1.1 end
    if Wind_force > 30 and speed_true > 200 then window_f = 1.5 end -- Window is heating a bit from high speeds of wind and movement
    if Wind_dir > 270 and Wind_dir < 359 then window_g = 1.5 end -- Left window gets colder from direct wind
    if Wind_dir > 0 and Wind_dir < 90 then window_g = 1.5 end -- Right window gets colder from direct wind
    if Wind_dir > 90 and Wind_dir < 270 then window_g = 0.8 end -- Window dont absorb cold air because no direct wind
	if paused_sim == 1 then step_window = 0 end --paused sim bug resolver
    ice_on_window  = ice_on_window-step_window*window_a*window_b*window_c*window_d*window_e*window_f*window_g*clearsky_general -- formula for forming ice on Window
    last_stored_ice_on_window = ice_on_window
    if ice_on_window > 0.9991 then ice_on_window = 1 end -- limit values
    if ice_on_window < 0.000001 then ice_on_window = 0 end
  end -- heating if its hot
  
  if OAT < 0 and Window_ON ~= 1 and ground_deice == 0 then-- Window heat is off and cold outside and no ground deice present
   step_window = dxib_mul -- default coeficient for Window heat , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_window = (AIRDENS/10000)*math.abs(HUMID/100) --testing by airdensity
   --clearsky conditions
   --altitude_temp = Altitude
   --if altitude_temp == 0 then altitude_temp = 1 end --divide by zero protection
   ----if altitude_temp > 1 and altitude_temp < 100 then koef_j = 2 end --slow down icing on ground --alternative 15
   ----if altitude_temp >= 100 and altitude_temp < 1000 then koef_j = 3 end --slow down icing on ground --alternative 75
   ----if altitude_temp >= 1000 and altitude_temp < 2000 then koef_j = 5 end --slow down icing on ground --alternative 75
   ----if altitude_temp >= 2000 and altitude_temp < 3000 then koef_j = 6 end --slow down icing on ground --alternative 75
   ----if altitude_temp >= 3000 and altitude_temp < 4000 then koef_j = 8 end --slow down icing on ground --alternative 75
  ---- if altitude_temp >= 4000 and altitude_temp < 5000 then koef_j = 10 end --slow down icing on ground --alternative 75
  ---- if altitude_temp >= 5000 then koef_j = 20 end --slow down icing on ground --alternative 75
  ---- if altitude_temp < 20000 and inbadweather == false then --good but chilly weather and clear sky
   --if altitude_temp > 1 and altitude_temp < 100 then koef_j = 5 end --slow down icing on ground --alternative 15
   --if altitude_temp >= 100 and altitude_temp < 1000 then koef_j = 6 end --slow down icing on ground --alternative 75
   --if altitude_temp >= 1000 and altitude_temp < 2000 then koef_j = 7 end --slow down icing on ground --alternative 75
   --if altitude_temp >= 2000 and altitude_temp < 3000 then koef_j = 8 end --slow down icing on ground --alternative 75
   --if altitude_temp >= 3000 and altitude_temp < 4000 then koef_j = 9 end --slow down icing on ground --alternative 75
   --if altitude_temp >= 4000 and altitude_temp < 5000 then koef_j = 10 end --slow down icing on ground --alternative 75
   --if altitude_temp >= 5000 then koef_j = 25 end --slow down icing on ground --alternative 75
   --if altitude_temp < 20000 and inbadweather == false then --good but chilly weather and clear sky
   -- window_j =koef_j/math.sqrt(altitude_temp) -- in 10.000ft koef 0.2, in 1000ft 0.6, on ground 2.8!, higher 20 higher result
   --end 
   --end of clearsky
    --if paused_sim == 1 then step_window = 0 end --paused sim bug resolver
    if speed_true > 10 and speed_true < 100 then window_a = 1.1 end -- adds speed of forming ice on Window by factor
    if speed_true > 100 and speed_true < 200 then window_a = 1.2 end
    if speed_true > 200 then window_a = 1.5 end
	if Altitude > 0 and Altitude < 6000 then window_b = 1.5 end
    if Altitude > 6000 and Altitude < 12000 then window_b = 1.2 end -- adds another speed of forming ice on Window by factor
    if Altitude > 12000 and Altitude < 30000 then window_b = 1.1 end
    if Altitude > 30000 then window_b = 1 end
    if OAT < 0 and OAT > -20 then  window_c = 1.5 end -- adds another speed of forming ice on Window by factor
    if OAT < -20 and OAT > -40 then  window_c = 1.2 end
   --if OAT > -40 then window_c = 2.5 end
    if OAT < -48 and in_clouds == 0 then window_c = 0 end -- new from physics analysis, stops further freezing
	if OAT < -48 and in_clouds == 1 then window_c = 1 end -- new from physics analysis, in clouds icing
    if FOG > 5000 then window_d = 1 end -- adds another speed of forming ice on Window by factor
	if FOG > 3000 and FOG <= 5000 then window_d = 1.5 end
	if FOG > 1000 and FOG <= 3000 then window_d = 1.8 end
    if FOG < 1000 then window_d = 2.2 end
    if Rain_on_acf < 0.025 then window_e = 1 end -- adds another speed of forming ice on Window by factor
    if Rain_on_acf > 0.025 then window_e = 1.8 end
    if Wind_force < 10 then window_f = 1 end -- Window gets colder from low wind force
    if Wind_force > 10 and Wind_force < 30 then window_f = 1.1 end
    if Wind_force > 30 and speed_true > 200 then window_f = 1.5 end -- Window is heating a bit from high speeds of wind and movement
    if Wind_dir > 270 and Wind_dir < 359 then window_g = 1.2 end -- Left window gets colder from direct wind
    if Wind_dir > 0 and Wind_dir < 90 then window_g = 1.2 end -- Right window gets colder from direct wind
    if Wind_dir > 90 and Wind_dir < 270 then window_g = 1 end -- Window dont absorb cold air because no direct wind
	--new cloud check here
	if Height > Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   if Cloud_type0 == 0 then window_h = 1 end --clear
	   if Cloud_type0 == 1 then window_h = 1.2 end --cirrus
	   if Cloud_type0 == 2 then window_h = 1.5 end --scattered
	   if Cloud_type0 == 3 then window_h = 1.8 end --broken
	   if Cloud_type0 == 4 then window_h = 2 end --overcast
	   if Cloud_type0 == 5 then window_h = 3 end --stratus
	   if Cloud_coverage0 < 1 then window_i = 1 end -- clear sky
	   if Cloud_coverage0 >= 1 and Cloud_coverage0 < 2 then window_i = 1 end -- a few clouds
	   if Cloud_coverage0 >= 2 and Cloud_coverage0 < 3 then window_i = 1.2 end -- normal coverage
	   if Cloud_coverage0 >= 3 and Cloud_coverage0 < 4 then window_i = 1.5 end -- lot of clouds
	   if Cloud_coverage0 >= 4 and Cloud_coverage0 < 5 then window_i = 1.8 end -- very high coverage
	   if Cloud_coverage0 >= 5 then window_i = 2 end -- full coverage
	   --play_sound(ONE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	   --play_sound(TWO) --debug sound
	end
	if Height > Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   if Cloud_type1 == 0 then window_h = 1 end --clear
	   if Cloud_type1 == 1 then window_h = 1.2 end --cirrus
	   if Cloud_type1 == 2 then window_h = 1.4 end --scattered
	   if Cloud_type1 == 3 then window_h = 1.5 end --broken
	   if Cloud_type1 == 4 then window_h = 2 end --overcast
	   if Cloud_type1 == 5 then window_h = 2.5 end --stratus
	   if Cloud_coverage1 < 1 then window_i = 1 end -- clear sky
	   if Cloud_coverage1 >= 1 and Cloud_coverage1 < 2 then window_i = 1 end -- a few clouds
	   if Cloud_coverage1 >= 2 and Cloud_coverage1 < 3 then window_i = 1.5 end -- normal coverage
	   if Cloud_coverage1 >= 3 and Cloud_coverage1 < 4 then window_i = 2 end -- lot of clouds
	   if Cloud_coverage1 >= 4 and Cloud_coverage1 < 5 then window_i = 3 end -- very high coverage
	   if Cloud_coverage1 >= 5 then window_i = 4 end -- full coverage
	   --play_sound(TWO) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if Height > Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   if Cloud_type2 == 0 then window_h = 1 end --clear
	   if Cloud_type2 == 1 then window_h = 1.1 end --cirrus
	   if Cloud_type2 == 2 then window_h = 1.3 end --scattered
	   if Cloud_type2 == 3 then window_h = 1.4 end --broken
	   if Cloud_type2 == 4 then window_h = 1.8 end --overcast
	   if Cloud_type2 == 5 then window_h = 2 end --stratus
	   if Cloud_coverage2 < 1 then window_i = 1 end -- clear sky
	   if Cloud_coverage2 >= 1 and Cloud_coverage2 < 2 then window_i = 1 end -- a few clouds
	   if Cloud_coverage2 >= 2 and Cloud_coverage2 < 3 then window_i = 1.5 end -- normal coverage
	   if Cloud_coverage2 >= 3 and Cloud_coverage2 < 4 then window_i = 2 end -- lot of clouds
	   if Cloud_coverage2 >= 4 and Cloud_coverage2 < 5 then window_i = 3 end -- very high coverage
	   if Cloud_coverage2 >= 5 then window_i = 4 end -- full coverage
	   --play_sound(THREE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if in_clouds ~= 1 and Altitude > 20000 then
    	window_h = 0
		--play_sound(LOOKINGOODTWICE) --debug sound
		--play_sound(THREE)
	end -- not in clouds above FL200? no more ice cumulation
	--end of new cloud check here
	
    --ice_on_window  = ice_on_window+step_window*window_a*window_b*window_c*window_d*window_e*window_f*window_g*window_h*window_i*clearsky_general-- formula for forming ice on Window
	if paused_sim == 1 then step_window = 0 end --paused sim bug resolver
	ice_on_window  = ice_on_window+step_window*window_a*window_b*window_c*window_d*window_e*window_f*window_g*window_h*window_i*clearsky_general
    --last_stored_ice_on_window = ice_on_window -- not used now
    if ice_on_window > 0.99995 then ice_on_window = 1 end -- limit values
    if ice_on_window < 0.000001 then ice_on_window = 0 end
   end -- end of Window is below zero
 
end -- end of Window function
-- now Propeller blades icing
function Prop0() -- check conditions for Propeller blade freezing
--checking if we have Propellers
if ACFTYPE < 1 or ACFTYPE > 4 then ice_on_prop0 = 0 end --we dont have blades
--Prop heat fail section
--OAT is below zero
 if OAT < 0 and Prop0_ON == 1 then -- Prop0 heat is on and cold outside - no risk
   --ice_on_prop0 = 0 
   step_prop0 = 0.01 
   if paused_sim == 1 then step_prop0 = 0 end --paused sim bug resolver
   -- new override formula
   ice_on_prop0 = ice_on_prop0-step_prop0
   if ice_on_prop0 > 0.99995 then ice_on_prop0 = 1 end -- limit value
   if ice_on_prop0 < 0.000001 then ice_on_prop0 = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
   --if engine0_has_failed == 1 then
   -- flameout_eng0 = 0 -- allow engine0 recovery
	--flameout_eng2 = 0
	--delay_eng0 = 0 -- clear offset
  -- end
   --if engine1_has_failed == 1 then
	--flameout_eng1 = 0 -- allow engine2 recovery
	--flameout_eng3 = 0
	----delay_eng1 = 0 -- clear offset
   --end
   --play_sound(ONE)
 end
 
 if OAT > 0 then -- Hot ambients cause heating, lowers icing
   step_prop0 = dxib_mul -- default coeficient for prop heat , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_prop0 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_prop0 = 0 end --paused sim bug resolver
   --delay_eng0 = delay_eng0*(inlet_ratio_left/2) + 1 -- start counting seconds for duration of ice on ENG0
   --delay_eng1 = delay_eng1*(inlet_ratio_right/2) + 1 -- start counting seconds for duration of ice on ENG1
   --if engine0_has_failed == 1 then
   -- flameout_eng0 = 0 -- allow engine0 recovery
	--flameout_eng2 = 0
	--delay_eng0 = 0 -- clear offset
	--if played_enginesarecommingon == false then 
	--   play_sound(ENGINESARECOMMINGON)
	--   played_enginesarecommingon = true --you hear that? dont play it again
	-- end
   --end
  -- if engine1_has_failed == 1 then
	--flameout_eng1 = 0 -- allow engine1 recovery
	--flameout_eng2 = 0
	----delay_eng1 = 0 -- clear offset
   --end
   if speed_true > 10 and speed_true < 100 then prop0_a = 1.0 end -- adds speed of forming ice on prop0 by factor
   if speed_true > 100 and speed_true < 200 then prop0_a = 3 end
   if speed_true > 200 then prop0_a = 4 end
   if Altitude > 0 and Altitude < 6000 then prop0_b = 1.2 end
   if Altitude > 6000 and Altitude < 12000 then prop0_b = 1 end -- adds another speed of forming ice on prop0 by factor
   if Altitude > 12000 and Altitude < 30000 then prop0_b = 4 end
   if Altitude > 30000 then prop0_b = 5 end
   if OAT < 0 and OAT > -20 then  prop0_c = 1 end -- adds another speed of forming ice on Engine by factor
   if OAT < -20 and OAT > -40 then  prop0_c = 4 end
   if OAT < -40 then prop0_c = 5 end
   --if FOG > 1000 then prop0_d = 1 end -- adds another speed of forming ice on prop0 by factor
   --if FOG < 1000 then prop0_d = 2 end
   if FOG > 5000 then prop0_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then prop0_d = 1.1 end
   if FOG > 1000 and FOG <= 3000 then prop0_d = 1.2 end
   if FOG < 1000 then prop0_d = 1.5 end
   if Rain_on_acf < 0.025 then prop0_e = 1 end -- adds another speed of forming ice on prop0 by factor
   if Rain_on_acf > 0.025 then prop0_e = 2 end
   if Wind_force < 10 then prop0_f = 1.6 end -- prop0 gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then prop0_f = 1 end
   if Wind_force > 30 and speed_true > 200 then prop0_f = 0.4 end -- prop0 is heating a bit from high speeds of wind and movement
   if Wind_dir > 270 and Wind_dir < 359 then -- Left prop gets hotter from direct wind
   prop0_g = 2
   prop_ratio_left = 2  
   prop_ratio_right = 1     
   end 
   if Wind_dir > 0 and Wind_dir < 90 then -- Right prop gets hotter from direct wind
   prop0_g = 1.2 
   prop_ratio_left = 1  
   prop_ratio_right = 2
   end
   if Wind_dir > 90 and Wind_dir < 270 then  -- prop dont absorb cold air because no direct wind
   prop0_g = 1
   prop_ratio_left = 1  
   prop_ratio_right = 1
   end 
   if paused_sim == 1 then step_prop0 = 0 end --paused sim bug resolver
   ice_on_prop0 = ice_on_prop0-step_prop0*prop0_a*prop0_b*prop0_c*prop0_d*prop0_e*prop0_f*prop0_g*clearsky_general -- formula for forming ice on prop0
   --last_stored_ice_on_window = ice_on_window
   --play_sound(TWO)
   if ice_on_prop0 > 0.99995 then
    ice_on_prop0 = 1
    --flameout_eng0 = 6 -- maybe not neccessary if inlet fail works
    --flameout_eng1 = 6 -- maybe not neccessary if inlet fail works
   end -- limit values
   if ice_on_prop0 < 0.000001 then
    ice_on_prop0 = 0
    --flameout_eng0 = 0 -- maybe not neccessary if inlet fail works
    --flameout_eng1 = 0 -- maybe not neccessary if inlet fail works
   end
  end -- end of heating if its hot
  
  if OAT < 0 and Prop0_ON ~= 1 and ground_deice == 0 then -- Cold ambients causes freezing, more icing
   step_prop0 = dxib_mul -- default coeficient for Inlet heat , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_prop0 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_prop0 = 0 end --paused sim bug resolver
   if speed_true > 20 then ice_on_prop0 = 0 end -- rotating engine smashes the ice
   --delay_eng0 = delay_eng0*(inlet_ratio_left/2) + 1 -- start counting seconds for duration of ice on ENG0 // dont work
  -- delay_eng1 = delay_eng1*(inlet_ratio_right/2) + 1 -- start counting seconds for duration of ice on ENG1 // dont work
   --delay_eng0 = delay_eng0 + 1 -- start counting seconds for duration of ice on ENG0
   --delay_eng1 = delay_eng1 + 1 -- start counting seconds for duration of ice on ENG1
   --ice_on_window = delay_eng0 --debug value
   --if delay_eng0 > 60 then play_sound(ONE) end
   if speed_true > 10 and speed_true < 100 then prop0_a = 1.1 end -- adds speed of forming ice on prop0 by factor
   if speed_true > 100 and speed_true < 200 then prop0_a = 1.5 end
   if speed_true > 200 then prop0_a = 2 end
   if Altitude > 0 and Altitude < 6000 then prop0_b = 1.5 end
   if Altitude > 6000 and Altitude < 12000 then prop0_b = 1.2 end -- adds another speed of forming ice on prop0 by factor
   if Altitude > 12000 and Altitude < 30000 then prop0_b = 1.1 end
   if Altitude > 30000 then prop0_b = 1 end
   if OAT < 0 and OAT > -20 then  prop0_c = 1.5 end -- adds another speed of forming ice on prop0 by factor
   if OAT < -20 and OAT > -40 then  prop0_c = 1.2 end
   --if OAT > -40 then inlet_c = 2.5 end
   --if OAT < -40 then inlet0_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 0 then prop0_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 1 then prop0_c = 1 end -- new from physics analysis, in clouds icing
   --if FOG > 1000 then prop0_d = 1 end -- adds another speed of forming ice on prop0 by factor
   --if FOG < 1000 then prop0_d = 2 end
   if FOG > 5000 then prop0_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then prop0_d = 1.5 end
   if FOG > 1000 and FOG <= 3000 then prop0_d = 1.8 end
   if FOG < 1000 then prop0_d = 2.2 end
   if Rain_on_acf < 0.025 then prop0_e = 1 end -- adds another speed of forming ice on prop0 by factor
   if Rain_on_acf > 0.025 then prop0_e = 1.8 end
   if Wind_force < 10 then prop0_f = 0.9 end 
   if Wind_force > 10 and Wind_force < 30 then prop0_f = 1 end
   if Wind_force > 30 and speed_true > 200 then prop0_f = 1.2 end -- 
   if Wind_dir > 270 and Wind_dir < 359 then -- Left prop gets hotter from direct wind
   prop0_g = 1.5
   inlet_ratio_left = 1.5 
   inlet_ratio_right = 1   
   end 
   if Wind_dir > 0 and Wind_dir < 90 then -- Right prop gets hotter from direct wind
   prop0_g = 1.2 
   inlet_ratio_left = 1  
   inlet_ratio_right = 1.5
   end
   if Wind_dir > 90 and Wind_dir < 270 then  -- props dont absorb cold air because no direct wind
   prop0_g = 1
   inlet_ratio_left = 1
   inlet_ratio_right = 1
   end 
   
	--no clouds check necessary
   if paused_sim == 1 then step_prop0 = 0 end --paused sim bug resolver
   ice_on_prop0 = ice_on_prop0+step_prop0*prop0_a*prop0_b*prop0_c*prop0_d*prop0_e*prop0_f*prop0_g*clearsky_general -- formula for forming ice on prop0
  
   if ice_on_prop0 > 0.99995 then 
	--see charts from NASA for correct math function/curve
    ice_on_prop0 = 1
   end -- limit values and failure trigger
   -----------------------------------
   if ice_on_prop0 < 0.000001 then
    ice_on_prop0 = 0
	--play_sound(THREE)
   end
   --------------------------------
  end -- end of icing when its cold
end -- end of prop0 icing
--end of Proppeler0

function Prop1() -- check conditions for Propeller blade freezing
--checking if we have Propellers
if ACFTYPE < 1 or ACFTYPE > 4 then ice_on_prop1 = 0 end --we dont have blades
--Prop heat fail section
--OAT is below zero
 if OAT < 0 and Prop1_ON == 1 then -- Prop1 heat is on and cold outside - no risk
   --ice_on_prop0 = 0 
   step_prop1 = 0.01 
   if paused_sim == 1 then step_prop1 = 0 end --paused sim bug resolver
   -- new override formula
   ice_on_prop1 = ice_on_prop1-step_prop1
   if ice_on_prop1 > 0.99995 then ice_on_prop1 = 1 end -- limit value
   if ice_on_prop1 < 0.000001 then ice_on_prop1 = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
   --if engine0_has_failed == 1 then
   -- flameout_eng0 = 0 -- allow engine0 recovery
	--flameout_eng2 = 0
	--delay_eng0 = 0 -- clear offset
  -- end
   --if engine1_has_failed == 1 then
	--flameout_eng1 = 0 -- allow engine2 recovery
	--flameout_eng3 = 0
	----delay_eng1 = 0 -- clear offset
   --end
   --play_sound(ONE)
 end
 
 if OAT > 0 then -- Hot ambients cause heating, lowers icing
   step_prop1 = dxib_mul -- default coeficient for prop heat , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_prop1 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_prop1 = 0 end --paused sim bug resolver
   --delay_eng0 = delay_eng0*(inlet_ratio_left/2) + 1 -- start counting seconds for duration of ice on ENG0
   --delay_eng1 = delay_eng1*(inlet_ratio_right/2) + 1 -- start counting seconds for duration of ice on ENG1
   --if engine0_has_failed == 1 then
   -- flameout_eng0 = 0 -- allow engine0 recovery
	--flameout_eng2 = 0
	--delay_eng0 = 0 -- clear offset
	--if played_enginesarecommingon == false then 
	--   play_sound(ENGINESARECOMMINGON)
	--   played_enginesarecommingon = true --you hear that? dont play it again
	-- end
   --end
  -- if engine1_has_failed == 1 then
	--flameout_eng1 = 0 -- allow engine1 recovery
	--flameout_eng2 = 0
	----delay_eng1 = 0 -- clear offset
   --end
   if speed_true > 10 and speed_true < 100 then prop1_a = 1 end -- adds speed of forming ice on prop1 by factor
   if speed_true > 100 and speed_true < 200 then prop1_a = 3 end
   if speed_true > 200 then prop1_a = 4 end
   if Altitude > 0 and Altitude < 6000 then prop1_b = 1.2 end
   if Altitude > 6000 and Altitude < 12000 then prop1_b = 1 end -- adds another speed of forming ice on prop1 by factor
   if Altitude > 12000 and Altitude < 30000 then prop1_b = 4 end
   if Altitude > 30000 then prop1_b = 5 end
   if OAT < 0 and OAT > -20 then  prop1_c = 1 end -- adds another speed of forming ice on Engine by factor
   if OAT < -20 and OAT > -40 then  prop1_c = 4 end
   if OAT < -40 then prop1_c = 5 end
   --if FOG > 1000 then prop1_d = 1 end -- adds another speed of forming ice on prop1 by factor
   --if FOG < 1000 then prop1_d = 2 end
   if FOG > 5000 then prop1_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then prop1_d = 1.1 end
   if FOG > 1000 and FOG <= 3000 then prop1_d = 1.2 end
   if FOG < 1000 then prop1_d = 1.5 end
   if Rain_on_acf < 0.025 then prop1_e = 1 end -- adds another speed of forming ice on prop1 by factor
   if Rain_on_acf > 0.025 then prop1_e = 2 end
   if Wind_force < 10 then prop1_f = 1.6 end -- prop1 gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then prop1_f = 1 end
   if Wind_force > 30 and speed_true > 200 then prop1_f = 0.4 end -- prop1 is heating a bit from high speeds of wind and movement
   if Wind_dir > 270 and Wind_dir < 359 then -- Left prop gets hotter from direct wind
   prop1_g = 2
   prop_ratio_left = 2  
   prop_ratio_right = 1     
   end 
   if Wind_dir > 0 and Wind_dir < 90 then -- Right prop gets hotter from direct wind
   prop1_g = 1.2 
   prop_ratio_left = 1  
   prop_ratio_right = 2
   end
   if Wind_dir > 90 and Wind_dir < 270 then  -- prop dont absorb cold air because no direct wind
   prop1_g = 1
   prop_ratio_left = 1  
   prop_ratio_right = 1
   end 
   if paused_sim == 1 then step_prop1 = 0 end --paused sim bug resolver
   ice_on_prop1 = ice_on_prop1-step_prop1*prop1_a*prop1_b*prop1_c*prop1_d*prop1_e*prop1_f*prop1_g*clearsky_general -- formula for forming ice on prop1
   --last_stored_ice_on_window = ice_on_window
   --play_sound(TWO)
   if ice_on_prop1 > 0.99995 then
    ice_on_prop1 = 1
    --flameout_eng0 = 6 -- maybe not neccessary if inlet fail works
    --flameout_eng1 = 6 -- maybe not neccessary if inlet fail works
   end -- limit values
   if ice_on_prop1 < 0.000001 then
    ice_on_prop1 = 0
    --flameout_eng0 = 0 -- maybe not neccessary if inlet fail works
    --flameout_eng1 = 0 -- maybe not neccessary if inlet fail works
   end
  end -- end of heating if its hot
  
  if OAT < 0 and Prop1_ON ~= 1 and ground_deice == 0 then -- Cold ambients causes freezing, more icing
   step_prop1 = dxib_mul -- default coeficient for Inlet heat , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_prop1 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_prop1 = 0 end --paused sim bug resolver
   if speed_true > 20 then ice_on_prop1 = 0 end -- rotating engine smashes the ice
   --delay_eng0 = delay_eng0*(inlet_ratio_left/2) + 1 -- start counting seconds for duration of ice on ENG0 // dont work
  -- delay_eng1 = delay_eng1*(inlet_ratio_right/2) + 1 -- start counting seconds for duration of ice on ENG1 // dont work
   --delay_eng0 = delay_eng0 + 1 -- start counting seconds for duration of ice on ENG0
   --delay_eng1 = delay_eng1 + 1 -- start counting seconds for duration of ice on ENG1
   --ice_on_window = delay_eng0 --debug value
   --if delay_eng0 > 60 then play_sound(ONE) end
   if speed_true > 10 and speed_true < 100 then prop1_a = 1.1 end -- adds speed of forming ice on prop1 by factor
   if speed_true > 100 and speed_true < 200 then prop1_a = 1.5 end
   if speed_true > 200 then prop1_a = 2 end
   if Altitude > 0 and Altitude < 6000 then prop1_b = 1.5 end
   if Altitude > 6000 and Altitude < 12000 then prop1_b = 1.2 end -- adds another speed of forming ice on prop0 by factor
   if Altitude > 12000 and Altitude < 30000 then prop1_b = 1.1 end
   if Altitude > 30000 then prop1_b = 1 end
   if OAT < 0 and OAT > -20 then  prop1_c = 1.5 end -- adds another speed of forming ice on prop1 by factor
   if OAT < -20 and OAT > -40 then  prop1_c = 1.2 end
   --if OAT > -40 then inlet_c = 2.5 end
   --if OAT < -40 then inlet0_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 0 then prop1_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 1 then prop1_c = 1 end -- new from physics analysis, in clouds icing
   --if FOG > 1000 then prop1_d = 1 end -- adds another speed of forming ice on prop1 by factor
   --if FOG < 1000 then prop1_d = 2 end
   if FOG > 5000 then prop1_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then prop1_d = 1.5 end
   if FOG > 1000 and FOG <= 3000 then prop1_d = 1.8 end
   if FOG < 1000 then prop1_d = 2.2 end
   if Rain_on_acf < 0.025 then prop1_e = 1 end -- adds another speed of forming ice on prop1 by factor
   if Rain_on_acf > 0.025 then prop1_e = 1.8 end
   if Wind_force < 10 then prop1_f = 0.9 end -- Inlet gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then prop1_f = 1 end
   if Wind_force > 30 and speed_true > 200 then prop1_f = 1.2 end -- Inlet is heating a bit from high speeds of wind and movement
   if Wind_dir > 270 and Wind_dir < 359 then -- Left prop gets hotter from direct wind
   prop1_g = 1.5
   inlet_ratio_left = 1.5 
   inlet_ratio_right = 1   
   end 
   if Wind_dir > 0 and Wind_dir < 90 then -- Right prop gets hotter from direct wind
   prop1_g = 1.2 
   inlet_ratio_left = 1  
   inlet_ratio_right = 1.5
   end
   if Wind_dir > 90 and Wind_dir < 270 then  -- props dont absorb cold air because no direct wind
   prop1_g = 1
   inlet_ratio_left = 1
   inlet_ratio_right = 1
   end 
   
	--no clouds check necessary
   if paused_sim == 1 then step_prop1 = 0 end --paused sim bug resolver
   ice_on_prop1 = ice_on_prop1+step_prop1*prop1_a*prop1_b*prop1_c*prop1_d*prop1_e*prop1_f*prop1_g*clearsky_general -- formula for forming ice on prop0
  
   if ice_on_prop1 > 0.99995 then 
	--see charts from NASA for correct math function/curve
    ice_on_prop1 = 1
   end -- limit values and failure trigger
   -----------------------------------
   if ice_on_prop1 < 0.000001 then
    ice_on_prop1 = 0
	--play_sound(THREE)
   end
   --------------------------------
  end -- end of icing when its cold
end -- end of prop1 icing
--end of Proppeler2
function reset_trick()
--reset
 if Ground_deice_call == 137000 then
  played_fireupthespoolers = false
  played_receivedcoockies = false
  played_lookingforya = false
  count = 0
  counted = 0
  freq_terminated = false
  superhardfail = false -- cannot recover
  hardfail = false -- can recover
  medfail = false  -- recovery possible after crew action
  softfail = false -- recovery after some time
  superhardfail1 = false -- cannot recover
  hardfail1 = false -- can recover
  medfail1 = false  -- recovery possible after crew action
  softfail1 = false -- recovery after some time
  superhardfail = false -- cannot recover
  compstall_eng0 = 0
  compstall_eng1 = 0
  compstall_eng2 = 0
  compstall_eng3 = 0
  flameout_eng0 = 0
  flameout_eng1 = 0
  flameout_eng2 = 0
  flameout_eng3 = 0
 end
end
-- NEW v1 Inlet0 and Inlet1 code
-- now Inlet0 code
function Inlet0() -- check conditions for Engine inlet freezing
--bypass for piston ACFs
if ACFTYPE > 0 and ACFTYPE < 5 then ice_on_inlet0 = 0 end --we dont have big inlet, we are piston
--ENG Inlet heat fail section
--Light jet like Carenado Cessna Citation II  bug resolver here
if ACFTYPE == 0 and Pitot1_ON == 1 then ice_on_inlet0 = 0 end
--end of Light jet like Carenado Cessna Citation II  bug resolver here
--FF320 bug resolver here
if ACFTYPE == 320 and Pitot1_ON == 1 then ice_on_inlet0 = 0 end --eng2 may still fail
--end of FF320 bug resolver here
--OAT is below zero
--general annoucements
if played_enginesarecommingon == false then
 if played_wehavejustlostengineone == true and dowehavepower > 0.5 then 
  play_sound(ENGINESARECOMMINGON)
 end
  played_enginesarecommingon = true --you hear that? dont play it again
end
if played_bothenginesemergency == false then 
       if played_engine2isdown == true and played_wehavejustlostengineone == true then
	      play_sound(BOTHENGINESEMERGENCY)
	   end
	   played_bothenginesemergency = true --you hear that? dont play it again
end
 if OAT < 0 and Inlet0_ON == 1 then -- Inlet0 heat is on and cold outside - no risk
   --step_inlet0 = 0 
   step_inlet0 = 0.01 
   if paused_sim == 1 then step_inlet0 = 0 end --paused sim bug resolver
   -- new override formula
   ice_on_inlet0 = ice_on_inlet0-step_inlet0
   if ice_on_inlet0 > 0.99995 then ice_on_inlet0 = 1 end -- limit value
   if ice_on_inlet0 < 0.000001 then ice_on_inlet0 = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
   if engine0_has_failed == 1 then
    --flameout_eng0 = 0 -- allow engine0 recovery
	--flameout_eng2 = 0
	--new code
	if superhardfail == true then --no recovery possible, engine needs to be shutdown, damaged
	--here add recognition of how many engines
	 if ENGINES < 3 then
	 flameout_eng0 = 6
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 6
	 flameout_eng1 = 6
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- flameout_eng0 = 6
	 -- flameout_eng2 = 6
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if hardfail == true then --no recovery possible now
	 if ENGINES < 3 then
	 flameout_eng0 = 6
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 6
	 flameout_eng1 = 6
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- flameout_eng0 = 6
	 -- flameout_eng2 = 6
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail == true and enginesidle == true then 
	 if ENGINES < 3 then
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail == true and enginesidle == false then 
	 if ENGINES < 3 then
	 compstall_eng0 = 6
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 6
	 compstall_eng1 = 6
	 end
	--  compstall_eng0 = 6
	--  compstall_eng2 = 6
	end
	--new code end
	--delay_eng0 = 0 -- clear offset
   end
   --if engine1_has_failed == 1 then
	--flameout_eng1 = 0 -- allow engine2 recovery
	--flameout_eng3 = 0
	----delay_eng1 = 0 -- clear offset
   --end
   --play_sound(ONE)
 end
 
 if OAT > 0 then -- Hot ambients cause heating, lowers icing
   step_inlet0 = dxib_mul -- default coeficient for Inlet heat , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_inlet0 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_inlet0 = 0 end --paused sim bug resolver
   --delay_eng0 = delay_eng0*(inlet_ratio_left/2) + 1 -- start counting seconds for duration of ice on ENG0
   --delay_eng1 = delay_eng1*(inlet_ratio_right/2) + 1 -- start counting seconds for duration of ice on ENG1
   if engine0_has_failed == 1 then
    --flameout_eng0 = 0 -- allow engine0 recovery
	--flameout_eng2 = 0
	--delay_eng0 = 0 -- clear offset
		--new code here 
	if superhardfail == true then --no recovery possible, engine needs to be shutdown, damaged
	 if ENGINES < 3 then
	 flameout_eng0 = 6
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 6
	 flameout_eng1 = 6
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- flameout_eng0 = 6
	--  flameout_eng2 = 6
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if hardfail == true then --recovery possible now
	 if ENGINES < 3 then
	 flameout_eng0 = 0
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 0
	 flameout_eng1 = 0
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	--  flameout_eng0 = 0
	 -- flameout_eng2 = 0
	 -- compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if medfail == true and enginesidle == true then 
	 if ENGINES < 3 then
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail == true and enginesidle == false then
     if ENGINES < 3 then
	 compstall_eng0 = 6
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 6
	 compstall_eng1 = 6
	 end	
	 -- compstall_eng0 = 6
	 -- compstall_eng2 = 6
	end
	if softfail == true then
	 if ENGINES < 3 then
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if softfail == false then
	 if ENGINES < 3 then
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail == false then
	 if ENGINES < 3 then
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if hardfail == false then
	 if ENGINES < 3 then
	 flameout_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 0
	 flameout_eng1 = 0
	 end
	 -- flameout_eng0 = 0
	--  flameout_eng2 = 0
	end
	if superhardfail == false then
	  if ENGINES < 3 then
	 flameout_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 0
	 flameout_eng1 = 0
	 end
	--  flameout_eng0 = 0
	--  flameout_eng2 = 0
	end
	--end new code
	--if played_enginesarecommingon == false and dowehavepower > 0.5 then 
	--   play_sound(ENGINESARECOMMINGON)
	 --  played_enginesarecommingon = true --you hear that? dont play it again
	 --end
   end
  -- if engine1_has_failed == 1 then
	--flameout_eng1 = 0 -- allow engine1 recovery
	--flameout_eng2 = 0
	----delay_eng1 = 0 -- clear offset
   --end
   if speed_true > 10 and speed_true < 100 then inlet0_a = 1 end -- adds speed of forming ice on Inlet0 by factor
   if speed_true > 100 and speed_true < 200 then inlet0_a = 3 end
   if speed_true > 200 then inlet0_a = 4 end
   if Altitude > 0 and Altitude < 6000 then inlet0_b = 1.2 end
   if Altitude > 6000 and Altitude < 12000 then inlet0_b = 1 end -- adds another speed of forming ice on Inlet0 by factor
   if Altitude > 12000 and Altitude < 30000 then inlet0_b = 4 end
   if Altitude > 30000 then inlet0_b = 5 end
   if OAT < 0 and OAT > -20 then  inlet0_c = 1 end -- adds another speed of forming ice on Engine by factor
   if OAT < -20 and OAT > -40 then  inlet0_c = 4 end
   if OAT < -40 then inlet0_c = 5 end
   --if FOG > 1000 then inlet0_d = 1 end -- adds another speed of forming ice on Inlet by factor
   --if FOG < 1000 then inlet0_d = 2 end
   if FOG > 5000 then inlet0_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then inlet0_d = 1.1 end
   if FOG > 1000 and FOG <= 3000 then inlet0_d = 1.2 end
   if FOG < 1000 then inlet0_d = 1.5 end
   if Rain_on_acf < 0.025 then inlet0_e = 1 end -- adds another speed of forming ice on Inlet by factor
   if Rain_on_acf > 0.025 then inlet0_e = 2 end
   if Wind_force < 10 then inlet0_f = 0.9 end -- Inlet gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then inlet0_f = 1 end
   if Wind_force > 30 and speed_true > 200 then inlet0_f = 1.2 end -- Inlet is heating a bit from high speeds of wind and movement
   if Wind_dir > 270 and Wind_dir < 359 then -- Left Inlet gets hotter from direct wind
   inlet0_g = 2
   if MAXMACH >= 2 then inlet0_g = 1.8 end -- for concorde, inlet antiice covers only 1/4 of inlet surface
   inlet_ratio_left = 2  
   inlet_ratio_right = 1     
   end 
   if Wind_dir > 0 and Wind_dir < 90 then -- Right Inlet gets hotter from direct wind
   inlet0_g = 1.2 
   if MAXMACH >= 2 then inlet0_g = 1.1 end -- for concorde, inlet antiice covers only 1/4 of inlet surface
   inlet_ratio_left = 1  
   inlet_ratio_right = 2
   end
   if Wind_dir > 90 and Wind_dir < 270 then  -- Inlets dont absorb cold air because no direct wind
   inlet0_g = 1
   inlet_ratio_left = 1  
   inlet_ratio_right = 1
   end 
   if paused_sim == 1 then step_inlet0 = 0 end --paused sim bug resolver
   ice_on_inlet0 = ice_on_inlet0-step_inlet0*inlet0_a*inlet0_b*inlet0_c*inlet0_d*inlet0_e*inlet0_f*inlet0_g*clearsky_general -- formula for forming ice on Inlet
   --last_stored_ice_on_window = ice_on_window
   --play_sound(TWO)
   if ice_on_inlet0 > 0.99995 then
    ice_on_inlet0 = 1
    --flameout_eng0 = 6 -- maybe not neccessary if inlet fail works
    --flameout_eng1 = 6 -- maybe not neccessary if inlet fail works
   end -- limit values
   if ice_on_inlet0 < 0.000001 then
    ice_on_inlet0 = 0
    --flameout_eng0 = 0 -- maybe not neccessary if inlet fail works
    --flameout_eng1 = 0 -- maybe not neccessary if inlet fail works
   end
  end -- end of heating if its hot
  
  if OAT < 0 and Inlet0_ON ~= 1 and ground_deice == 0 then -- Cold ambients causes freezing, more icing
   step_inlet0 = dxib_mul -- default coeficient for Inlet heat , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_inlet0 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_inlet0 = 0 end --paused sim bug resolver
   --delay_eng0 = delay_eng0*(inlet_ratio_left/2) + 1 -- start counting seconds for duration of ice on ENG0 // dont work
  -- delay_eng1 = delay_eng1*(inlet_ratio_right/2) + 1 -- start counting seconds for duration of ice on ENG1 // dont work
   --delay_eng0 = delay_eng0 + 1 -- start counting seconds for duration of ice on ENG0
   --delay_eng1 = delay_eng1 + 1 -- start counting seconds for duration of ice on ENG1
   --ice_on_window = delay_eng0 --debug value
   --if delay_eng0 > 60 then play_sound(ONE) end
   if speed_true > 10 and speed_true < 100 then inlet0_a = 1.1 end -- adds speed of forming ice on Inlet0 by factor
   if speed_true > 100 and speed_true < 200 then inlet0_a = 1.2 end
   if speed_true > 200 then inlet0_a = 1.5 end
   if Altitude > 0 and Altitude < 6000 then inlet0_b = 1.5 end
   if Altitude > 6000 and Altitude < 12000 then inlet0_b = 1.2 end -- adds another speed of forming ice on Inlet by factor
   if Altitude > 12000 and Altitude < 30000 then inlet0_b = 1.1 end
   if Altitude > 30000 then inlet0_b = 1 end
   if OAT < 0 and OAT > -20 then  inlet0_c = 1.5 end -- adds another speed of forming ice on Engine by factor
   if OAT < -20 and OAT > -40 then  inlet0_c = 1.2 end
   --if OAT > -40 then inlet_c = 2.5 end
   --if OAT < -40 then inlet0_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 0 then inlet0_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 1 then inlet0_c = 1 end -- new from physics analysis, in clouds icing
   --if FOG > 1000 then inlet0_d = 1 end -- adds another speed of forming ice on Inlet by factor
   --if FOG < 1000 then inlet0_d = 2 end
   if FOG > 5000 then inlet0_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then inlet0_d = 1.5 end
   if FOG > 1000 and FOG <= 3000 then inlet0_d = 1.8 end
   if FOG < 1000 then inlet0_d = 2.2 end
   if Rain_on_acf < 0.025 then inlet0_e = 1 end -- adds another speed of forming ice on Inlet by factor
   if Rain_on_acf > 0.025 then inlet0_e = 2 end
   if Wind_force < 10 then inlet0_f = 0.9 end -- Inlet gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then inlet0_f = 1 end
   if Wind_force > 30 and speed_true > 200 then inlet0_f = 1.2 end -- Inlet is heating a bit from high speeds of wind and movement
   if Wind_dir > 270 and Wind_dir < 359 then -- Left Inlet gets hotter from direct wind
   inlet0_g = 1.7
   if MAXMACH >= 2 then inlet0_g = 1.8 end -- for concorde, inlet antiice covers only 1/4 of inlet surface
   inlet_ratio_left = 1.5 
   inlet_ratio_right = 1   
   end 
   if Wind_dir > 0 and Wind_dir < 90 then -- Right Inlet gets hotter from direct wind
   inlet0_g = 1.1 
   if MAXMACH >= 2 then inlet0_g = 1.3 end -- for concorde, inlet antiice covers only 1/4 of inlet surface
   inlet_ratio_left = 1  
   inlet_ratio_right = 1.5
   end
   if Wind_dir > 90 and Wind_dir < 270 then  -- Inlets dont absorb cold air because no direct wind
   inlet0_g = 1
   inlet_ratio_left = 1
   inlet_ratio_right = 1
   end 
   --new cloud check here
	if Height > Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   if Cloud_type0 == 0 then inlet0_h = 1 end --clear
	   if Cloud_type0 == 1 then inlet0_h = 1.2 end --cirrus
	   if Cloud_type0 == 2 then inlet0_h = 1.5 end --scattered
	   if Cloud_type0 == 3 then inlet0_h = 1.8 end --broken
	   if Cloud_type0 == 4 then inlet0_h = 2 end --overcast
	   if Cloud_type0 == 5 then inlet0_h = 3 end --stratus
	   if Cloud_coverage0 < 1 then inlet0_i = 1 end -- clear sky
	   if Cloud_coverage0 >= 1 and Cloud_coverage0 < 2 then inlet0_i = 1 end -- a few clouds
	   if Cloud_coverage0 >= 2 and Cloud_coverage0 < 3 then inlet0_i = 1.2 end -- normal coverage
	   if Cloud_coverage0 >= 3 and Cloud_coverage0 < 4 then inlet0_i = 1.5 end -- lot of clouds
	   if Cloud_coverage0 >= 4 and Cloud_coverage0 < 5 then inlet0_i = 1.8 end -- very high coverage
	   if Cloud_coverage0 >= 5 then inlet0_i = 2 end -- full coverage
	   --play_sound(ONE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	   --play_sound(TWO) --debug sound
	end
	if Height > Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   if Cloud_type1 == 0 then inlet0_h = 1 end --clear
	   if Cloud_type1 == 1 then inlet0_h = 1.2 end --cirrus
	   if Cloud_type1 == 2 then inlet0_h = 1.4 end --scattered
	   if Cloud_type1 == 3 then inlet0_h = 1.5 end --broken
	   if Cloud_type1 == 4 then inlet0_h = 2 end --overcast
	   if Cloud_type1 == 5 then inlet0_h = 2.5 end --stratus
	   if Cloud_coverage1 < 1 then inlet0_i = 1 end -- clear sky
	   if Cloud_coverage1 >= 1 and Cloud_coverage1 < 2 then inlet0_i = 1 end -- a few clouds
	   if Cloud_coverage1 >= 2 and Cloud_coverage1 < 3 then inlet0_i = 1.5 end -- normal coverage
	   if Cloud_coverage1 >= 3 and Cloud_coverage1 < 4 then inlet0_i = 2 end -- lot of clouds
	   if Cloud_coverage1 >= 4 and Cloud_coverage1 < 5 then inlet0_i = 3 end -- very high coverage
	   if Cloud_coverage1 >= 5 then inlet0_i = 4 end -- full coverage
	   --play_sound(TWO) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if Height > Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   if Cloud_type2 == 0 then inlet0_h = 1 end --clear
	   if Cloud_type2 == 1 then inlet0_h = 1.1 end --cirrus
	   if Cloud_type2 == 2 then inlet0_h = 1.3 end --scattered
	   if Cloud_type2 == 3 then inlet0_h = 1.4 end --broken
	   if Cloud_type2 == 4 then inlet0_h = 1.8 end --overcast
	   if Cloud_type2 == 5 then inlet0_h = 2 end --stratus
	   if Cloud_coverage2 < 1 then inlet0_i = 1 end -- clear sky
	   if Cloud_coverage2 >= 1 and Cloud_coverage2 < 2 then inlet0_i = 1 end -- a few clouds
	   if Cloud_coverage2 >= 2 and Cloud_coverage2 < 3 then inlet0_i = 1.5 end -- normal coverage
	   if Cloud_coverage2 >= 3 and Cloud_coverage2 < 4 then inlet0_i = 2 end -- lot of clouds
	   if Cloud_coverage2 >= 4 and Cloud_coverage2 < 5 then inlet0_i = 3 end -- very high coverage
	   if Cloud_coverage2 >= 5 then inlet0_i = 4 end -- full coverage
	   --play_sound(THREE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if in_clouds ~= 1 and Altitude > 20000 then
    	inlet0_h = 0
		--play_sound(LOOKINGOODTWICE) --debug sound
		--play_sound(THREE)
	end -- not in clouds above FL200? no more ice cumulation
	--end of new cloud check here
   if paused_sim == 1 then step_inlet0 = 0 end --paused sim bug resolver
   ice_on_inlet0 = ice_on_inlet0+step_inlet0*inlet0_a*inlet0_b*inlet0_c*inlet0_d*inlet0_e*inlet0_f*inlet0_g*inlet0_h*inlet0_i*clearsky_general -- formula for forming ice on Inlet
   if inlet0_a == 1 then doom0_a = 20 end --lower doom coef means more fear
   if inlet0_a == 1.5 then doom0_a = 15 end
   if inlet0_a == 2 then doom0_a = 10 end
   if inlet0_b == 1 then doom0_b = 25 end
   if inlet0_b == 2 then doom0_b = 20 end
   if inlet0_b == 2.5 then doom0_b = 10 end
   if inlet0_c == 1 then doom0_c = 10 end
   if inlet0_c == 2 then doom0_c = 20 end
   if inlet0_c == 0 then doom0_c = 100 end
   if inlet0_d == 1 then doom0_d = 30 end
   if inlet0_d == 2 then doom0_d = 10 end
   if inlet0_e == 1 then doom0_e = 10 end
   if inlet0_e == 1.8 then doom0_e = 30 end
   if inlet0_f == 1 then doom0_f = 10 end
   if inlet0_f == 1.6 then doom0_f = 15 end
   if inlet0_f == 0.8 then doom0_f = 30 end
   if inlet_ratio_left == 1 then doom_g0 = 40 end
   if inlet_ratio_left == 1.5 then doom_g0 = 10 end
   if inlet_ratio_right == 1 then doom_g1 = 60 end
   if inlet_ratio_right == 1.5 then doom_g1 = 20 end
   if inlet_ratio_right == 1 and inlet_ratio_left == 1 then doom_g0 = 80 end
   if inlet_ratio_right == 1 and inlet_ratio_left == 1 then doom_g1 = 40 end
   if inlet_ratio_right == 1 and inlet_ratio_left == 1.5 then doom_g0 = 10 end
   if inlet_ratio_right == 1 and inlet_ratio_left == 1.5 then doom_g1 = 5 end
   if inlet_ratio_right == 1.5 and inlet_ratio_left == 1 then doom_g0 = 10 end
   if inlet_ratio_right == 1.5 and inlet_ratio_left == 1 then doom_g1 = 5 end
   
   doom0 = (doom0_a+doom0_b+doom0_c+doom0_d+doom0_e+doom0_f+doom_g0)
   --doom1 = (doom_a+doom_b+doom_c+doom_d+doom_e+doom_f+doom_g1)
   --play_sound(THREE)
   ------------------ ENG fail scenarios ---------------
   if ice_on_inlet0 < 0.9 then -- disable flameout and set extra time for engines flameout
    --ice_on_inlet = 0
    --flameout_eng0 = 0 -- maybe not neccessary if inlet fail works
    ----flameout_eng1 = 0 -- maybe not neccessary if inlet fail works
	--flameout_eng2 = 0 -- maybe not neccessary if inlet fail works
    ----flameout_eng2 = 0 -- maybe not neccessary if inlet fail works
	--new code here 
	if superhardfail == true then
	 if ENGINES < 3 then
	 flameout_eng0 = 6
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 6
	 flameout_eng1 = 6
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	--  flameout_eng0 = 6
	--  flameout_eng2 = 6
	--  compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if hardfail == true then
	 if ENGINES < 3 then
	 flameout_eng0 = 6
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 6
	 flameout_eng1 = 6
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- flameout_eng0 = 6
	 -- flameout_eng2 = 6
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail == true then 
	 if ENGINES < 3 then
	   if throttleno1 > 0.1 then
	   compstall_eng0 = 6
	   enginesidle = false
	   end
	 end
	 if ENGINES >= 3 then
	   if throttleno1 > 0.1 or throttleno4 > 0.1 then
	   compstall_eng0 = 6
	   compstall_eng1 = 6
	   enginesidle = false
	   end
	 end
	   --compstall_eng0 = 6
	  
	 -- end
	 -- if throttleno3 > 0.1 then 
	 --  compstall_eng2 = 6
	 --  enginesidle = false
	 -- end
	end
	if medfail == true then 
	 if ENGINES < 3 then
	   if throttleno1 < 0.1 then
	   compstall_eng0 = 0
	   enginesidle = true --remember safety procedure success
	   end
	 end
	 if ENGINES >= 3 then
	   if throttleno1 < 0.1 or throttleno4 < 0.1 then
	   compstall_eng0 = 0
	   compstall_eng1 = 0
	   enginesidle = true --remember safety procedure success
	   end
	 end
	 --
	 -- if throttleno1 < 0.1 then
	 --  compstall_eng0 = 0
	 --  enginesidle = true --remember safety procedure success
	 -- end
	 -- if throttleno3 < 0.1 then
	 -- compstall_eng2 = 0
	 -- enginesidle = true --remember safety procedure success
	--  end
	end
	if softfail == true then
	 if ENGINES < 3 then
	 compstall_eng0 = 6
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 6
	 compstall_eng1 = 6
	 end
	 -- compstall_eng0 = 6
	 -- compstall_eng2 = 6
	end
	if softfail == false then
	if ENGINES < 3 then
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	--  compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if medfail == false then
	 if ENGINES < 3 then
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
    if hardfail == false then
	 if ENGINES < 3 then
	 flameout_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 0
	 flameout_eng1 = 0
	 end
	 -- flameout_eng0 = 0
	 -- flameout_eng2 = 0
	end
	if superhardfail == false then
	 if ENGINES < 3 then
	 flameout_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 0
	 flameout_eng1 = 0
	 end
	 -- flameout_eng0 = 0
	--  flameout_eng2 = 0
	end
	--end new code
	delay_coef0 = inlet_ratio_left*doom0 --100 can be replaced by factor formula of 1-100% failure possibility
    delay_eng0 = delay_coef0
    --delay_coef1 = inlet_ratio_right*doom1
    --delay_eng1 = delay_coef1
   end
   --last_stored_ice_on_window = ice_on_window
   -----------------------------
   if ice_on_inlet0 > 0.99995 then 
	--see charts from NASA for correct math function/curve
    ice_on_inlet0 = 1
	--ice_on_window = delay_eng0 --debug value
	delay_eng0 = delay_eng0 - 1
	if delay_eng0 < 1 then delay_eng0 = 0 end --limit
	--delay_eng1 = delay_eng1 - 1
	--if delay_eng1 < 1 then delay_eng1 = 0 end --limit
	--delay_coef0 = (inlet_a+inlet_b+inlet_c+inlet_d+inlet_e+inlet_f+inlet_g)*inlet_ratio_left*inlet_g --adds some minutes to failure (static value)
	--delay_coef0 = inlet_ratio_left/inlet_g --adds some minutes to failure (static value)
	--ice_on_window = delay_coef0 --debug value
	--if delay_coef0 > 10 then play_sound(TWO) end
	--delay_coef1 = (inlet_a+inlet_b+inlet_c+inlet_d+inlet_e+inlet_f+inlet_g)*inlet_ratio_right*inlet_g --adds some minutes to failure (static value)
	--play_sound(TWO)
	-------ENG0----------------------------
	--if delay_eng0 > 60 then -- 20 minutes offset to failure (can be half if too much wind)
	 --delay_eng0 = 1-(delay_coef0*delay_eng0) --here counter function to 0 from eng0 and eng1 for seconds as condition IF and the trigger fail 
	 --if delay_coef0 < 0.01 then delay_coef0 = 0 end --limit
	 --delay_coef0 > 1 then delay_coef0 = 1 end --limit
	 --if delay_eng0 > 0.5 then play_sound(TWO) end
	 --if delay_coef0 == 1 then --counter is zero trigger failure
	 if delay_eng0 == 0 and speed_true > 60 then --counter is zero, trigger failure
	  --old code
      --flameout_eng0 = 6 -- 6 means now
	  --flameout_eng2 = 6 -- 6 means now
	  --end old code
	  ----new code -- needs tweaking, randomgenerated needs to be stored or will fluctuate
	   if randomsaved == false then -- save random value once for failure decision
	    randomsaved_value = RANGEN
		randomsaved = true
	   end
	  if randomsaved_value >= 0.5 then --superhard failure
	    if ENGINES < 3 then
	     if flameout_eng0 == 0 then flameout_eng0 = 6 end
		superhardfail = true 
	    end
	    if ENGINES >= 3 then
	    if flameout_eng0 == 0 then flameout_eng0 = 6 end
	    if flameout_eng1 == 0 then flameout_eng1 = 6 end
		superhardfail = true
        --play_sound(ONE)
	    end
	   --flameout_eng0 = 6 -- 6 means now
	   --flameout_eng2 = 6 -- 6 means now
	   --superhardfail = true 
	  end
	  if randomsaved_value >= 0.05 and randomsaved_value < 0.5 then --hard failure
	    if ENGINES < 3 then
	    if flameout_eng0 == 0 then flameout_eng0 = 6 end
		hardfail = true 
	    end
	    if ENGINES >= 3 then
	    if flameout_eng0 == 0 then flameout_eng0 = 6 end
	    if flameout_eng1 == 0 then flameout_eng1 = 6 end
		hardfail = true 
		--play_sound(TWO)
	    end
	  -- flameout_eng0 = 6 -- 6 means now
	   --flameout_eng2 = 6 -- 6 means now
	   --hardfail = true 
	  end
	  if randomsaved_value > 0 and randomsaved_value < 0.05 then --medium failure
	    if ENGINES < 3 then
	    --compstall_eng0 = 6
		if compstall_eng0 == 0 then compstall_eng0 = 6 end
		medfail = true
	    end
	    if ENGINES >= 3 then
	    if compstall_eng0 == 0 then compstall_eng0 = 6 end
		if compstall_eng1 == 0 then compstall_eng1 = 6 end
		medfail = true
		--play_sound(THREE)
	    end
	   --compstall_eng0 = 6
	   --compstall_eng2 = 6
	   --medfail = true 
	  end
	  if randomsaved_value == 0 then --soft failure 
	    if ENGINES < 3 then
	    if compstall_eng0 == 0 then compstall_eng0 = 6 end
		softfail = true 
	    end
	    if ENGINES >= 3 then
	    if compstall_eng0 == 0 then compstall_eng0 = 6 end
	    if compstall_eng1 == 3 then compstall_eng1 = 6 end
		softfail = true 
		--play_sound(FOUR)
	    end
	  -- compstall_eng0 = 6
	  -- compstall_eng2 = 6
	  -- softfail = true 
	  end
	  ----end of new code
	  engine0_has_failed = 1
	  if played_wehavejustlostengineone == false then
       if hardfail == true or superhardfail == true then 
	   play_sound(WEHAVEJUSTLOSTENGINEONE)
	   played_wehavejustlostengineone = true --you hear that? dont play it again
	   end
	  end
	  --delay_eng0 = 0 -- clear offset
	 end -- end of eng0 extra minutes counter
	--end -- end of failure countdown
	-------ENG1--------------------------
	--if delay_eng1 > 60 then -- 20 minutes offset to failure (can be half if too much wind)
	 --delay_coef1 = delay_coef1
	 --if delay_coef1 < 0.01 then delay_coef1 = 0 end --limit
	 --if delay_coef1 == 0 then --counter is zero trigger failure
	 --if delay_eng1 == 0 and speed > 60 then --counter is zero trigger failure
     -- flameout_eng1 = 6 -- 6 means now
	 -- flameout_eng2 = 6 -- 6 means now
	 -- engine1_has_failed = 1
	 -- if played_engine2isdown == false then 
	 --  play_sound(ENGINE2ISDOWN)
	 --  played_engine2isdown = true --you hear that? dont play it again
	 -- end
	  --delay_eng0 = 1 -- clear offset
	 end -- end of eng0 extra minutes counter
	--end -- end of failure countdown  
   --end -- limit values and failure trigger
   -----------------------------------
   if ice_on_inlet0 < 0.000001 then
    ice_on_inlet0 = 0
	--play_sound(THREE)
	--old code start
    --flameout_eng0 = 0 -- maybe not neccessary if inlet fail works
    ----flameout_eng1 = 0 -- maybe not neccessary if inlet fail works
	----flameout_eng3 = 0 -- maybe not neccessary if inlet fail works
    --flameout_eng2 = 0 -- maybe not neccessary if inlet fail works
	--old code end
	--new code here 
	if superhardfail == true then
	 if ENGINES < 3 then
	 flameout_eng0 = 6
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 6
	 flameout_eng1 = 6
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	--  flameout_eng0 = 6
	--  flameout_eng2 = 6
	--  compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if hardfail == true then
	 if ENGINES < 3 then
	 flameout_eng0 = 6
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 6
	 flameout_eng1 = 6
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- flameout_eng0 = 6
	 -- flameout_eng2 = 6
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail == true and enginesidle == true then 
	 if ENGINES < 3 then
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	--  compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if medfail == true and enginesidle == false then 
	 if ENGINES < 3 then
	 compstall_eng0 = 6
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 6
	 compstall_eng1 = 6
	 end
	 -- compstall_eng0 = 6
	 -- compstall_eng2 = 6
	end
	if softfail == true then
	 if ENGINES < 3 then
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if softfail == false then
	 if ENGINES < 3 then
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if medfail == false then
	 if ENGINES < 3 then
	 compstall_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng0 = 0
	 compstall_eng1 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if hardfail == false then
	 if ENGINES < 3 then
	 flameout_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 0
	 flameout_eng1 = 0
	 end
	 -- flameout_eng0 = 0
	 -- flameout_eng2 = 0
	end
	if superhardfail == false then
	 if ENGINES < 3 then
	 flameout_eng0 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng0 = 0
	 flameout_eng1 = 0
	 end
	 -- flameout_eng0 = 0
	 -- flameout_eng2 = 0
	end
	--end new code
   end
   --------------------------------
  end -- end of icing when its cold
end -- end of Engine Inlet icing

function Inlet1() -- check conditions for Engine inlet1 freezing
--bypass for piston ACFs
if ACFTYPE > 0 and ACFTYPE < 5 then ice_on_inlet1 = 0 end --we dont have big inlet, we are piston
-- 748-i bug resolver here
if ACFTYPE == 748 then ice_on_inlet1 = 0 end
-- end of 748-i bug resolver
--FF320 bug resolver here
if ACFTYPE == 320 and Pitot1_ON == 1 then ice_on_inlet1 = 0 end --eng2 may still fail
--end of FF320 bug resolver here
--Light jet like Carenado Cessna Citation II  bug resolver here
if ACFTYPE == 0 and Pitot1_ON == 1 then ice_on_inlet1 = 0 end
--end of Light jet like Carenado Cessna Citation II  bug resolver here
--ENG1 Inlet heat fail section
--OAT is below zero
--general annoucements
if played_enginesarecommingon == false then
 if played_wehavejustlostengineone == true and dowehavepower > 0.5 then 
  play_sound(ENGINESARECOMMINGON)
 end
  played_enginesarecommingon = true --you hear that? dont play it again
end
if played_bothenginesemergency == false then 
       if played_engine2isdown == true and played_wehavejustlostengineone == true then
	      play_sound(BOTHENGINESEMERGENCY)
	   end
	   played_bothenginesemergency = true --you hear that? dont play it again
end
 if OAT < 0 and Inlet1_ON == 1 then -- Inlet1 heat is on and cold outside - no risk
   --step_inlet1 = 0 
   step_inlet1 = 0.01 
   if paused_sim == 1 then step_inlet1 = 0 end --paused sim bug resolver
   -- new override formula
   ice_on_inlet1 = ice_on_inlet1-step_inlet1
   if ice_on_inlet1 > 0.99995 then ice_on_inlet1 = 1 end -- limit value
   if ice_on_inlet1 < 0.000001 then ice_on_inlet1 = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
  -- if engine0_has_failed == 1 then
   -- flameout_eng0 = 0 -- allow engine0 recovery
	--flameout_eng3 = 0
	--delay_eng0 = 0 -- clear offset
   --end
   if engine1_has_failed == 1 then
    --new code
	if superhardfail1 == true then --no recovery possible, engine needs to be shutdown, damaged
	--here add recognition of how many engines
	 if ENGINES < 3 then
	 flameout_eng1 = 6
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 6
	 flameout_eng3 = 6
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- flameout_eng0 = 6
	 -- flameout_eng2 = 6
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if hardfail1 == true then --no recovery possible now
	 if ENGINES < 3 then
	 flameout_eng1 = 6
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 6
	 flameout_eng3 = 6
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- flameout_eng0 = 6
	 -- flameout_eng2 = 6
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail1 == true and enginesidle1 == true then 
	 if ENGINES < 3 then
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail1 == true and enginesidle1 == false then 
	 if ENGINES < 3 then
	 compstall_eng1 = 6
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 6
	 compstall_eng3 = 6
	 end
	--  compstall_eng0 = 6
	--  compstall_eng2 = 6
	end
	--new code end
	--flameout_eng1 = 0 -- allow engine1 recovery
	--flameout_eng3 = 0
	--delay_eng1 = 0 -- clear offset
   end
   --play_sound(ONE)
 end
 
 if OAT > 0 then -- Hot ambients cause heating, lowers icing
   step_inlet1 = dxib_mul -- default coeficient for Inlet heat , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_inlet1 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_inlet1 = 0 end --paused sim bug resolver
   --delay_eng0 = delay_eng0*(inlet_ratio_left/2) + 1 -- start counting seconds for duration of ice on ENG0
   --delay_eng1 = delay_eng1*(inlet_ratio_right/2) + 1 -- start counting seconds for duration of ice on ENG1
   if engine1_has_failed == 1 then
    	--new code here 
	 if superhardfail1 == true then --no recovery possible, engine needs to be shutdown, damaged
	 if ENGINES < 3 then
	 flameout_eng1 = 6
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 6
	 flameout_eng3 = 6
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- flameout_eng0 = 6
	--  flameout_eng2 = 6
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if hardfail1 == true then --recovery possible now
	 if ENGINES < 3 then
	 flameout_eng1 = 0
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 0
	 flameout_eng3 = 0
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	--  flameout_eng0 = 0
	 -- flameout_eng2 = 0
	 -- compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if medfail1 == true and enginesidle1 == true then 
	 if ENGINES < 3 then
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail1 == true and enginesidle1 == false then
     if ENGINES < 3 then
	 compstall_eng1 = 6
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 6
	 compstall_eng3 = 6
	 end	
	 -- compstall_eng0 = 6
	 -- compstall_eng2 = 6
	end
	if softfail1 == true then
	 if ENGINES < 3 then
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if softfail1 == false then
	 if ENGINES < 3 then
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail1 == false then
	 if ENGINES < 3 then
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if hardfail1 == false then
	 if ENGINES < 3 then
	 flameout_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 0
	 flameout_eng3 = 0
	 end
	 -- flameout_eng0 = 0
	--  flameout_eng2 = 0
	end
	if superhardfail1 == false then
	  if ENGINES < 3 then
	 flameout_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 0
	 flameout_eng3 = 0
	 end
	--  flameout_eng0 = 0
	--  flameout_eng2 = 0
	end
	--end new code
    --flameout_eng1 = 0 -- allow engine0 recovery
	--flameout_eng3 = 0
	--delay_eng0 = 0 -- clear offset
	--if played_enginesarecommingon == false and dowehavepower > 0.5 then 
	--   play_sound(ENGINESARECOMMINGON)
	--   played_enginesarecommingon = true --you hear that? dont play it again
	-- end
   end
   --if engine1_has_failed == 1 then
	--flameout_eng1 = 0 -- allow engine1 recovery
	--flameout_eng2 = 0
	--delay_eng1 = 0 -- clear offset
   --end
   if speed_true > 10 and speed_true < 100 then inlet1_a = 1 end -- adds speed of forming ice on Inlet1 by factor
   if speed_true > 100 and speed_true < 200 then inlet1_a = 3 end
   if speed_true > 200 then inlet1_a = 4 end
   if Altitude > 0 and Altitude < 6000 then inlet1_b = 1.2 end
   if Altitude > 6000 and Altitude < 12000 then inlet1_b = 1 end -- adds another speed of forming ice on Inlet by factor
   if Altitude > 12000 and Altitude < 30000 then inlet1_b = 4 end
   if Altitude > 30000 then inlet1_b = 5 end
   if OAT < 0 and OAT > -20 then  inlet1_c = 1 end -- adds another speed of forming ice on Engine by factor
   if OAT < -20 and OAT > -40 then  inlet1_c = 4 end
   if OAT < -40 then inlet1_c = 5 end
   --if FOG > 1000 then inlet1_d = 1 end -- adds another speed of forming ice on Inlet by factor
   --if FOG < 1000 then inlet1_d = 2 end
   if FOG > 5000 then inlet1_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then inlet1_d = 1.1 end
   if FOG > 1000 and FOG <= 3000 then inlet1_d = 1.2 end
   if FOG < 1000 then inlet1_d = 1.5 end
   if Rain_on_acf < 0.025 then inlet1_e = 1 end -- adds another speed of forming ice on Inlet by factor
   if Rain_on_acf > 0.025 then inlet1_e = 2 end
   if Wind_force < 10 then inlet1_f = 1.6 end -- Inlet gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then inlet1_f = 1 end
   if Wind_force > 30 and speed_true > 200 then inlet1_f = 0.4 end -- Inlet is heating a bit from high speeds of wind and movement
   if Wind_dir > 270 and Wind_dir < 359 then -- Left Inlet gets hotter from direct wind
   inlet1_g = 1.2
   if MAXMACH >= 2 then inlet1_g = 1.1 end -- for concorde, inlet antiice covers only 1/4 of inlet surface
   inlet_ratio_left = 2  
   inlet_ratio_right = 1     
   end 
   if Wind_dir > 0 and Wind_dir < 90 then -- Right Inlet gets hotter from direct wind
   inlet1_g = 2 
   if MAXMACH >= 2 then inlet1_g = 1.8 end -- for concorde, inlet antiice covers only 1/4 of inlet surface
   inlet_ratio_left = 1  
   inlet_ratio_right = 2
   end
   if Wind_dir > 90 and Wind_dir < 270 then  -- Inlets dont absorb cold air because no direct wind
   inlet1_g = 1
   inlet_ratio_left = 1  
   inlet_ratio_right = 1
   end 
   if paused_sim == 1 then step_inlet1 = 0 end --paused sim bug resolver
   ice_on_inlet1 = ice_on_inlet1-step_inlet1*inlet1_a*inlet1_b*inlet1_c*inlet1_d*inlet1_e*inlet1_f*inlet1_g*clearsky_general -- formula for forming ice on Inlet
   --last_stored_ice_on_window = ice_on_window
   --play_sound(TWO)
   if ice_on_inlet1 > 0.99995 then
    ice_on_inlet1 = 1
    --flameout_eng0 = 6 -- maybe not neccessary if inlet fail works
    --flameout_eng1 = 6 -- maybe not neccessary if inlet fail works
   end -- limit values
   if ice_on_inlet1 < 0.000001 then
    ice_on_inlet1 = 0
    --flameout_eng0 = 0 -- maybe not neccessary if inlet fail works
    --flameout_eng1 = 0 -- maybe not neccessary if inlet fail works
   end
  end -- end of heating if its hot
  
  if OAT < 0 and Inlet1_ON ~= 1 and ground_deice == 0 then -- Cold ambients causes freezing, more icing
   step_inlet1 = dxib_mul -- default coeficient for Inlet heat , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --step_inlet1 = (AIRDENS/10000)*math.abs(HUMID/100)
   --if paused_sim == 1 then step_inlet1 = 0 end --paused sim bug resolver
   --delay_eng0 = delay_eng0*(inlet_ratio_left/2) + 1 -- start counting seconds for duration of ice on ENG0 // dont work
  -- delay_eng1 = delay_eng1*(inlet_ratio_right/2) + 1 -- start counting seconds for duration of ice on ENG1 // dont work
   --delay_eng0 = delay_eng0 + 1 -- start counting seconds for duration of ice on ENG0
   --delay_eng1 = delay_eng1 + 1 -- start counting seconds for duration of ice on ENG1
   --ice_on_window = delay_eng0 --debug value
   --if delay_eng0 > 60 then play_sound(ONE) end
   if speed_true > 10 and speed_true < 100 then inlet1_a = 1.1 end -- adds speed of forming ice on Inlet by factor
   if speed_true > 100 and speed_true < 200 then inlet1_a = 1.2 end
   if speed_true > 200 then inlet1_a = 1.5 end
   if Altitude > 0 and Altitude < 6000 then inlet1_b = 1.5 end
   if Altitude > 6000 and Altitude < 12000 then inlet1_b = 1.2 end -- adds another speed of forming ice on Inlet by factor
   if Altitude > 12000 and Altitude < 30000 then inlet1_b = 1.1 end
   if Altitude > 30000 then inlet1_b = 1 end
   if OAT < 0 and OAT > -20 then  inlet1_c = 1.5 end -- adds another speed of forming ice on Engine by factor
   if OAT < -20 and OAT > -40 then  inlet1_c = 1.2 end
   --if OAT > -40 then inlet_c = 2.5 end
   --if OAT < -40 then inlet1_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 0 then inlet1_c = 0 end -- new from physics analysis, stops further freezing
   if OAT < -48 and in_clouds == 1 then inlet1_c = 1 end -- new from physics analysis, in clouds icing
   --if FOG > 1000 then inlet1_d = 1 end -- adds another speed of forming ice on Inlet by factor
   --if FOG < 1000 then inlet1_d = 2 end
   if FOG > 5000 then inlet1_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then inlet1_d = 1.5 end
   if FOG > 1000 and FOG <= 3000 then inlet1_d = 1.8 end
   if FOG < 1000 then inlet1_d = 2.2 end
   if Rain_on_acf < 0.025 then inlet1_e = 1 end -- adds another speed of forming ice on Inlet by factor
   if Rain_on_acf > 0.025 then inlet1_e = 2 end
   if Wind_force < 10 then inlet1_f = 0.9 end -- Inlet gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then inlet1_f = 1 end
   if Wind_force > 30 and speed_true > 200 then inlet1_f = 1.2 end -- Inlet is heating a bit from high speeds of wind and movement
   if Wind_dir > 270 and Wind_dir < 359 then -- Left Inlet gets hotter from direct wind
   inlet1_g = 1.7
   if MAXMACH >= 2 then inlet1_g = 1.8 end -- for concorde, inlet antiice covers only 1/4 of inlet surface
   inlet_ratio_left = 1.5 
   inlet_ratio_right = 1   
   end 
   if Wind_dir > 0 and Wind_dir < 90 then -- Right Inlet gets hotter from direct wind
   inlet1_g = 1.1 
   if MAXMACH >= 2 then inlet1_g = 1.3 end -- for concorde, inlet antiice covers only 1/4 of inlet surface
   inlet_ratio_left = 1  
   inlet_ratio_right = 1.5
   end
   if Wind_dir > 90 and Wind_dir < 270 then  -- Inlets dont absorb cold air because no direct wind
   inlet1_g = 1
   inlet_ratio_left = 1
   inlet_ratio_right = 1
   end 
   --new cloud check here
	if Height > Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   if Cloud_type0 == 0 then inlet1_h = 1 end --clear
	   if Cloud_type0 == 1 then inlet1_h = 1.2 end --cirrus
	   if Cloud_type0 == 2 then inlet1_h = 1.5 end --scattered
	   if Cloud_type0 == 3 then inlet1_h = 1.8 end --broken
	   if Cloud_type0 == 4 then inlet1_h = 2 end --overcast
	   if Cloud_type0 == 5 then inlet1_h = 3 end --stratus
	   if Cloud_coverage0 < 1 then inlet1_i = 1 end -- clear sky
	   if Cloud_coverage0 >= 1 and Cloud_coverage0 < 2 then inlet1_i = 1 end -- a few clouds
	   if Cloud_coverage0 >= 2 and Cloud_coverage0 < 3 then inlet1_i = 1.2 end -- normal coverage
	   if Cloud_coverage0 >= 3 and Cloud_coverage0 < 4 then inlet1_i = 1.5 end -- lot of clouds
	   if Cloud_coverage0 >= 4 and Cloud_coverage0 < 5 then inlet1_i = 1.8 end -- very high coverage
	   if Cloud_coverage0 >= 5 then inlet1_i = 2 end -- full coverage
	   --play_sound(ONE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	   --play_sound(TWO) --debug sound
	end
	if Height > Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   if Cloud_type1 == 0 then inlet1_h = 1 end --clear
	   if Cloud_type1 == 1 then inlet1_h = 1.2 end --cirrus
	   if Cloud_type1 == 2 then inlet1_h = 1.4 end --scattered
	   if Cloud_type1 == 3 then inlet1_h = 1.5 end --broken
	   if Cloud_type1 == 4 then inlet1_h = 2 end --overcast
	   if Cloud_type1 == 5 then inlet1_h = 2.5 end --stratus
	   if Cloud_coverage1 < 1 then inlet1_i = 1 end -- clear sky
	   if Cloud_coverage1 >= 1 and Cloud_coverage1 < 2 then inlet1_i = 1 end -- a few clouds
	   if Cloud_coverage1 >= 2 and Cloud_coverage1 < 3 then inlet1_i = 1.5 end -- normal coverage
	   if Cloud_coverage1 >= 3 and Cloud_coverage1 < 4 then inlet1_i = 2 end -- lot of clouds
	   if Cloud_coverage1 >= 4 and Cloud_coverage1 < 5 then inlet1_i = 3 end -- very high coverage
	   if Cloud_coverage1 >= 5 then inlet1_i = 4 end -- full coverage
	   --play_sound(TWO) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if Height > Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   if Cloud_type2 == 0 then inlet1_h = 1 end --clear
	   if Cloud_type2 == 1 then inlet1_h = 1.1 end --cirrus
	   if Cloud_type2 == 2 then inlet1_h = 1.3 end --scattered
	   if Cloud_type2 == 3 then inlet1_h = 1.4 end --broken
	   if Cloud_type2 == 4 then inlet1_h = 1.8 end --overcast
	   if Cloud_type2 == 5 then inlet1_h = 2 end --stratus
	   if Cloud_coverage2 < 1 then inlet1_i = 1 end -- clear sky
	   if Cloud_coverage2 >= 1 and Cloud_coverage2 < 2 then inlet1_i = 1 end -- a few clouds
	   if Cloud_coverage2 >= 2 and Cloud_coverage2 < 3 then inlet1_i = 1.5 end -- normal coverage
	   if Cloud_coverage2 >= 3 and Cloud_coverage2 < 4 then inlet1_i = 2 end -- lot of clouds
	   if Cloud_coverage2 >= 4 and Cloud_coverage2 < 5 then inlet1_i = 3 end -- very high coverage
	   if Cloud_coverage2 >= 5 then inlet1_i = 4 end -- full coverage
	   --play_sound(THREE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if in_clouds ~= 1 and Altitude > 20000 then
    	inlet1_h = 0
		--play_sound(LOOKINGOODTWICE) --debug sound
		--play_sound(THREE)
	end -- not in clouds above FL200? no more ice cumulation
	--end of new cloud check here
   if paused_sim == 1 then step_inlet1 = 0 end --paused sim bug resolver
   ice_on_inlet1 = ice_on_inlet1+step_inlet1*inlet1_a*inlet1_b*inlet1_c*inlet1_d*inlet1_e*inlet1_f*inlet1_g*inlet1_h*inlet1_i*clearsky_general -- formula for forming ice on Inlet
   if inlet1_a == 1 then doom1_a = 20 end --lower doom coef means more fear
   if inlet1_a == 1.5 then doom1_a = 15 end
   if inlet1_a == 2 then doom1_a = 10 end
   if inlet1_b == 1 then doom1_b = 25 end
   if inlet1_b == 2 then doom1_b = 20 end
   if inlet1_b == 2.5 then doom1_b = 10 end
   if inlet1_c == 1 then doom1_c = 10 end
   if inlet1_c == 2 then doom1_c = 20 end
   if inlet1_c == 0 then doom1_c = 100 end
   if inlet1_d == 1 then doom1_d = 30 end
   if inlet1_d == 2 then doom1_d = 10 end
   if inlet1_e == 1 then doom1_e = 10 end
   if inlet1_e == 1.8 then doom1_e = 30 end
   if inlet1_f == 1 then doom1_f = 10 end
   if inlet1_f == 1.6 then doom1_f = 15 end
   if inlet1_f == 0.8 then doom1_f = 30 end
   if inlet_ratio_left == 1 then doom_g0 = 40 end
   if inlet_ratio_left == 1.5 then doom_g0 = 10 end
   if inlet_ratio_right == 1 then doom_g1 = 60 end
   if inlet_ratio_right == 1.5 then doom_g1 = 20 end
   if inlet_ratio_right == 1 and inlet_ratio_left == 1 then doom_g0 = 80 end
   if inlet_ratio_right == 1 and inlet_ratio_left == 1 then doom_g1 = 40 end
   if inlet_ratio_right == 1 and inlet_ratio_left == 1.5 then doom_g0 = 10 end
   if inlet_ratio_right == 1 and inlet_ratio_left == 1.5 then doom_g1 = 5 end
   if inlet_ratio_right == 1.5 and inlet_ratio_left == 1 then doom_g0 = 10 end
   if inlet_ratio_right == 1.5 and inlet_ratio_left == 1 then doom_g1 = 5 end
   
   --doom0 = (doom_a+doom_b+doom_c+doom_d+doom_e+doom_f+doom_g0)
   doom1 = (doom1_a+doom1_b+doom1_c+doom1_d+doom1_e+doom1_f+doom_g1)
   --play_sound(THREE)
   ------------------ ENG fail scenarios ---------------
   if ice_on_inlet1 < 0.9 then -- disable flameout and set extra time for engines flameout
    --ice_on_inlet = 0
    --flameout_eng0 = 0 -- maybe not neccessary if inlet fail works
    --flameout_eng1 = 0 -- maybe not neccessary if inlet fail works
	--flameout_eng2 = 0 -- maybe not neccessary if inlet fail works
    --flameout_eng3 = 0 -- maybe not neccessary if inlet fail works
	--new code here 
	 if superhardfail1 == true then
	 if ENGINES < 3 then
	 flameout_eng1 = 6
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 6
	 flameout_eng3 = 6
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	--  flameout_eng0 = 6
	--  flameout_eng2 = 6
	--  compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if hardfail1 == true then
	 if ENGINES < 3 then
	 flameout_eng1 = 6
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 6
	 flameout_eng3 = 6
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- flameout_eng0 = 6
	 -- flameout_eng2 = 6
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail1 == true then 
	 if ENGINES < 3 then
	   if throttleno2 > 0.1 then
	   compstall_eng1 = 6
	   enginesidle1 = false
	   end
	 end
	 if ENGINES >= 3 then
	   if throttleno1 > 0.1 or throttleno4 > 0.1 then
	   compstall_eng2 = 6
	   compstall_eng3 = 6
	   enginesidle1 = false
	   end
	 end
	   --compstall_eng0 = 6
	  
	 -- end
	 -- if throttleno3 > 0.1 then 
	 --  compstall_eng2 = 6
	 --  enginesidle = false
	 -- end
	end
	if medfail1 == true then 
	 if ENGINES < 3 then
	   if throttleno2 < 0.1 then
	   compstall_eng1 = 0
	   enginesidle1 = true --remember safety procedure success
	   end
	 end
	 if ENGINES >= 3 then
	   if throttleno1 < 0.1 or throttleno4 < 0.1 then
	   compstall_eng2 = 0
	   compstall_eng3 = 0
	   enginesidle1 = true --remember safety procedure success
	   end
	 end
	 --
	 -- if throttleno1 < 0.1 then
	 --  compstall_eng0 = 0
	 --  enginesidle = true --remember safety procedure success
	 -- end
	 -- if throttleno3 < 0.1 then
	 -- compstall_eng2 = 0
	 -- enginesidle = true --remember safety procedure success
	--  end
	end
	if softfail1 == true then
	 if ENGINES < 3 then
	 compstall_eng1 = 6
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 6
	 compstall_eng3 = 6
	 end
	 -- compstall_eng0 = 6
	 -- compstall_eng2 = 6
	end
	if softfail1 == false then
	if ENGINES < 3 then
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	--  compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if medfail1 == false then
	 if ENGINES < 3 then
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
    if hardfail1 == false then
	 if ENGINES < 3 then
	 flameout_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 0
	 flameout_eng3 = 0
	 end
	 -- flameout_eng0 = 0
	 -- flameout_eng2 = 0
	end
	if superhardfail1 == false then
	 if ENGINES < 3 then
	 flameout_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 0
	 flameout_eng3 = 0
	 end
	 -- flameout_eng0 = 0
	--  flameout_eng2 = 0
	end
	--end new code
	--delay_coef0 = inlet_ratio_left*doom0 --100 can be replaced by factor formula of 1-100% failure possibility
    --delay_eng0 = delay_coef0
    delay_coef1 = inlet_ratio_right*doom1
    delay_eng1 = delay_coef1
   end
   --last_stored_ice_on_window = ice_on_window
   -----------------------------
   if ice_on_inlet1 > 0.99995 then 
	--see charts from NASA for correct math function/curve
    ice_on_inlet1 = 1
	--ice_on_window = delay_eng0 --debug value
	--delay_eng0 = delay_eng0 - 1
	--if delay_eng0 < 1 then delay_eng0 = 0 end --limit
	delay_eng1 = delay_eng1 - 1
	if delay_eng1 < 1 then delay_eng1 = 0 end --limit
	--delay_coef0 = (inlet_a+inlet_b+inlet_c+inlet_d+inlet_e+inlet_f+inlet_g)*inlet_ratio_left*inlet_g --adds some minutes to failure (static value)
	--delay_coef0 = inlet_ratio_left/inlet_g --adds some minutes to failure (static value)
	--ice_on_window = delay_coef0 --debug value
	--if delay_coef0 > 10 then play_sound(TWO) end
	--delay_coef1 = (inlet_a+inlet_b+inlet_c+inlet_d+inlet_e+inlet_f+inlet_g)*inlet_ratio_right*inlet_g --adds some minutes to failure (static value)
	--play_sound(TWO)
	-------ENG0----------------------------
	--if delay_eng0 > 60 then -- 20 minutes offset to failure (can be half if too much wind)
	 --delay_eng0 = 1-(delay_coef0*delay_eng0) --here counter function to 0 from eng0 and eng1 for seconds as condition IF and the trigger fail 
	 --if delay_coef0 < 0.01 then delay_coef0 = 0 end --limit
	 --delay_coef0 > 1 then delay_coef0 = 1 end --limit
	 --if delay_eng0 > 0.5 then play_sound(TWO) end
	 --if delay_coef0 == 1 then --counter is zero trigger failure
	 --if delay_eng0 == 0 and speed > 60 then --counter is zero trigger failure
     -- flameout_eng0 = 6 -- 6 means now
	 -- flameout_eng3 = 6 -- 6 means now
	 -- engine0_has_failed = 1
	 -- if played_wehavejustlostengineone == false then 
	 --  play_sound(WEHAVEJUSTLOSTENGINEONE)
	 --  played_wehavejustlostengineone = true --you hear that? dont play it again
	 -- end
	  --delay_eng0 = 0 -- clear offset
	-- end -- end of eng0 extra minutes counter
	--end -- end of failure countdown
	-------ENG1--------------------------
	--if delay_eng1 > 60 then -- 20 minutes offset to failure (can be half if too much wind)
	 --delay_coef1 = delay_coef1
	 --if delay_coef1 < 0.01 then delay_coef1 = 0 end --limit
	 --if delay_coef1 == 0 then --counter is zero trigger failure
	 if delay_eng1 == 0 and speed_true > 60 then --counter is zero trigger failure
      --flameout_eng1 = 6 -- 6 means now
	  --flameout_eng3 = 6 -- 6 means now
	  ----new code -- needs tweaking, randomgenerated needs to be stored or will fluctuate
	  if randomsaved1 == false then -- save random value once for failure decision
	    randomsaved_value1 = RANGEN
		randomsaved1 = true
	   end
	  if randomsaved_value1 >= 0.5 then --superhard failure
	    if ENGINES < 3 then
	    --flameout_eng1 = 6
		if flameout_eng1 == 0 then flameout_eng1 = 6 end
		superhardfail1 = true 
		--play_sound(THREE)
	    end
	    if ENGINES >= 3 then
	    if flameout_eng2 == 0 then flameout_eng2 = 6 end
		if flameout_eng3 == 0 then flameout_eng3 = 6 end
		superhardfail1 = true 
		--play_sound(THREE)
	    end
	   --flameout_eng0 = 6 -- 6 means now
	   --flameout_eng2 = 6 -- 6 means now
	   --superhardfail = true 
	  end
	  if randomsaved_value1 >= 0.05 and randomsaved_value1 < 0.5 then --hard failure
	    if ENGINES < 3 then
	    if flameout_eng1 == 0 then flameout_eng1 = 6 end
		hardfail1 = true 
		--play_sound(TWO)
	    end
	    if ENGINES >= 3 then
	    if flameout_eng2 == 0 then flameout_eng2 = 6 end
		if flameout_eng3 == 0 then flameout_eng3 = 6 end
		hardfail1 = true 
		--play_sound(TWO)
	    end
	  -- flameout_eng0 = 6 -- 6 means now
	   --flameout_eng2 = 6 -- 6 means now
	   --hardfail = true 
	  end
	  if randomsaved_value1 > 0 and randomsaved_value1 < 0.05 then --medium failure
	    if ENGINES < 3 then
	    --compstall_eng1 = 6
		if compstall_eng1 == 0 then compstall_eng1 = 6 end
		medfail1 = true
		--play_sound(ONE)
	    end
	    if ENGINES >= 3 then
	    if compstall_eng2 == 0 then compstall_eng2 = 6 end
		if compstall_eng3 == 0 then compstall_eng3 = 6 end
		medfail1 = true
		--play_sound(ONE)
	    end
	   --compstall_eng0 = 6
	   --compstall_eng2 = 6
	   --medfail = true 
	  end
	  if randomsaved_value1 == 0 then --soft failure 
	    if ENGINES < 3 then
	    if compstall_eng1 == 0 then compstall_eng1 = 6 end
		softfail1 = true 
	    end
	    if ENGINES >= 3 then
	    if compstall_eng2 == 0 then compstall_eng2 = 6 end
		if compstall_eng3 == 0 then compstall_eng3 = 6 end
		softfail1 = true 
	    end
	  -- compstall_eng0 = 6
	  -- compstall_eng2 = 6
	  -- softfail = true 
	  end
	  ----end of new code
	  --if superhardfail1 == true or hardfail1 == true then
	  engine1_has_failed = 1
	   if played_engine2isdown == false and hardfail1 == true or superhardfail1 == true then 
	    play_sound(ENGINE2ISDOWN)
	    played_engine2isdown = true --you hear that? dont play it again
	   end
	  --end
	  --delay_eng0 = 1 -- clear offset
	 end -- end of eng0 extra minutes counter
	--end -- end of failure countdown  
   end -- limit values and failure trigger
   -----------------------------------
   if ice_on_inlet1 < 0.000001 then
    ice_on_inlet1 = 0
	--play_sound(THREE)
    --flameout_eng0 = 0 -- maybe not neccessary if inlet fail works
    --flameout_eng1 = 0 -- maybe not neccessary if inlet fail works
	--flameout_eng2 = 0 -- maybe not neccessary if inlet fail works
    --flameout_eng3 = 0 -- maybe not neccessary if inlet fail works
	--new code here 
	 if superhardfail1 == true then
	 if ENGINES < 3 then
	 flameout_eng1 = 6
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 6
	 flameout_eng3 = 6
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	--  flameout_eng0 = 6
	--  flameout_eng2 = 6
	--  compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if hardfail1 == true then
	 if ENGINES < 3 then
	 flameout_eng1 = 6
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 6
	 flameout_eng3 = 6
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- flameout_eng0 = 6
	 -- flameout_eng2 = 6
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if medfail1 == true and enginesidle1 == true then 
	 if ENGINES < 3 then
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	--  compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if medfail1 == true and enginesidle1 == false then 
	 if ENGINES < 3 then
	 compstall_eng1 = 6
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 6
	 compstall_eng3 = 6
	 end
	 -- compstall_eng0 = 6
	 -- compstall_eng2 = 6
	end
	if softfail1 == true then
	 if ENGINES < 3 then
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if softfail1 == false then
	 if ENGINES < 3 then
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- compstall_eng0 = 0
	--  compstall_eng2 = 0
	end
	if medfail1 == false then
	 if ENGINES < 3 then
	 compstall_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 compstall_eng2 = 0
	 compstall_eng3 = 0
	 end
	 -- compstall_eng0 = 0
	 -- compstall_eng2 = 0
	end
	if hardfail1 == false then
	 if ENGINES < 3 then
	 flameout_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 0
	 flameout_eng3 = 0
	 end
	 -- flameout_eng0 = 0
	 -- flameout_eng2 = 0
	end
	if superhardfail1 == false then
	 if ENGINES < 3 then
	 flameout_eng1 = 0
	 end
	 if ENGINES >= 3 then
	 flameout_eng2 = 0
	 flameout_eng3 = 0
	 end
	 -- flameout_eng0 = 0
	 -- flameout_eng2 = 0
	end
	--end new code
   end
   --------------------------------
  end -- end of icing when its cold
end -- end of Engine Inlet1 icing
 
 -- now Wing1 icing
 function Wing1()
 --Wing has ice fail section
--TAT is below zero
 --DC3 bugfixer starts
 --if ACFTYPE == 47 then
  --Surface_boot_ON = Antiice_boot_ON --works for both wings here temporary disabled
  -- step_wing1 = 0
 --end
 --DC3 bugfixer ends
 if TAT < 0 and Left_ON == 1 or Surface_boot_ON == 1 then -- Wing heat is on and cold outside - no change
   --step_wing1 = 0 
   step_wing1 = 0.01
   if paused_sim == 1 then step_wing1 = 0 end --paused sim bug resolver
   --play_sound(ONE)
   -- new override formula
   ice_on_wing1 = ice_on_wing1-step_wing1
   if ice_on_wing1 > 0.99995 then ice_on_wing1 = 1 end -- limit value
   if ice_on_wing1 < 0.000001 then ice_on_wing1 = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
 end
  if TAT > 0 then
   step_wing1 = dxib_mul -- default coeficient for Wing1 , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --if paused_sim == 1 then step_wing1 = 0 end --paused sim bug resolver
   if speed_true > 10 and speed_true < 100 then wing1_a = 1.5 end -- adds speed of forming ice on Wing1 by factor
   if speed_true > 100 and speed_true < 200 then wing1_a = 2 end
   if speed_true > 200 then wing1_a = 5 end
   if Altitude > 0 and Altitude < 6000 then wing1_b = 1.3 end
   if Altitude > 6000 and Altitude < 12000 then wing1_b = 1.5 end -- adds another speed of forming ice on Wing1 by factor
   if Altitude > 12000 and Altitude < 30000 then wing1_b = 4 end
   if Altitude > 30000 then wing1_b = 6 end
   if OAT < 0 and OAT > -20 then  wing1_c = 1 end -- adds another speed of forming ice on Wing1 by factor
   if OAT < -20 and OAT > -40 then  wing1_c = 6 end
   if OAT < -40 then wing1_c = 9 end
   --if FOG > 1000 then wing1_d = 1 end -- adds another speed of forming ice on Wing1 by factor
   --if FOG < 1000 then wing1_d = 2 end
   if FOG > 5000 then wing1_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then wing1_d = 1.1 end
   if FOG > 1000 and FOG <= 3000 then wing1_d = 1.2 end
   if FOG < 1000 then wing1_d = 1.5 end
   if Rain_on_acf < 0.025 then wing1_e = 1 end -- adds another speed of forming ice on Wing1 by factor
   if Rain_on_acf > 0.025 then wing1_e = 2 end
   if Wind_force < 10 then wing1_f = 0.8 end -- Wing gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then wing1_f = 1 end
   if Wind_force > 30 and speed_true > 200 then wing1_f = 1.5 end -- Wing1 is heating a bit from high speeds of wind and movement
   if Wind_dir > 270 and Wind_dir < 359 then wing1_g = 4 end -- Wing1 gets hotter from direct wind
   if Wind_dir > 0 and Wind_dir < 270 then wing1_g = 0.8 end -- Wing1 dont absorb hot air because no wind on left side
   if paused_sim == 1 then step_wing1 = 0 end --paused sim bug resolver
   ice_on_wing1 = ice_on_wing1-step_wing1*wing1_a*wing1_b*wing1_c*wing1_d*wing1_e*wing1_f*wing1_g*clearsky_general -- formula for forming ice on Wing1
   --play_sound(TWO)
   if ice_on_wing1 > 0.99995 then ice_on_wing1 = 1 end -- limit value
   if ice_on_wing1 < 0.000001 then ice_on_wing1 = 0 end
   --if ice_on_aoa < 0.9 then fail_on_AOA = 0 end -- disable failure does not work

  end -- end of Wing1 is hot
    if TAT < 0 and Left_ON ~= 1 or Surface_boot_ON ~= 1 and ground_deice == 0 then 
     step_wing1 = dxib_mul -- we need here slow speed of forming because wing is large
	 --step_wing1 = (AIRDENS/10000)*math.abs(HUMID/100)*(20/wingarea)
	 --if paused_sim == 1 then step_wing1 = 0 end --paused sim bug resolver
	 if speed_true < 10 and Altitude < 6000 then wing1_a = 1.1 end -- adds speed of forming ice on Wing1 by factor
	 if speed_true > 10 and speed_true < 100 then wing1_a = 1.2 end -- adds speed of forming ice on Wing1 by factor
     if speed_true > 100 and speed_true < 200 then wing1_a = 1.5 end
     if speed_true > 200 then wing1_a = 2 end
	 if Altitude > 0 and Altitude < 6000 then wing1_b = 1.5 end
     if Altitude > 6000 and Altitude < 12000 then wing1_b = 1.2 end -- adds another speed of forming ice on Wing1 by factor
     if Altitude > 12000 and Altitude < 30000 then wing1_b = 1.1 end
     if Altitude > 30000 then wing1_b = 1 end
     if OAT < 0 and OAT > -20 then  wing1_c = 1.5 end -- adds another speed of forming ice on Wing1 by factor
     if OAT < -20 and OAT > -40 then  wing1_c = 1.2 end
     --if OAT > -40 then wing1_c = 4 end
	 --if OAT < -40 then wing1_c = 0 end -- new from physics analysis, stops further freezing
	 if OAT < -48 and in_clouds == 0 then wing1_c = 0 end -- new from physics analysis, stops further freezing
     if OAT < -48 and in_clouds == 1 then wing1_c = 1 end -- new from physics analysis, in clouds icing
     --if FOG > 1000 then wing1_d = 1 end -- adds another speed of forming ice on Wing1 by factor
     --if FOG < 1000 then wing1_d = 2 end
	 if FOG > 5000 then wing1_d = 1 end -- adds another speed of forming ice on Window by factor
     if FOG > 3000 and FOG <= 5000 then wing1_d = 1.5 end
     if FOG > 1000 and FOG <= 3000 then wing1_d = 1.8 end
     if FOG < 1000 then wing1_d = 2.2 end
     if Rain_on_acf < 0.025 then wing1_e = 1.1 end -- adds another speed of forming ice on Wing1 by factor
     if Rain_on_acf > 0.025 then wing1_e = 2 end
     if Wind_force < 10 then wing1_f = 0.8 end -- Wing1 gets colder from low wind force
     if Wind_force > 10 and Wind_force < 30 then wing1_f = 1 end
     if Wind_force > 30 and speed_true > 200 then wing1_f = 1.5 end -- Wing1 is heating a bit from high speeds of wind and movement
     if Wind_dir > 270 and Wind_dir < 359 then wing1_g = 1.2 end -- Wing1 gets colder a bit from direct wind
     if Wind_dir > 0 and Wind_dir < 270 then wing1_g = 0.8 end -- Wing1 dont absorb cold air because no wind on left side
     --ice_on_pitot1 = 1-(ice_on_pitot1+step_pitot1*pitot1_a*pitot1_b*pitot1_c*pitot1_d*pitot1_e*pitot1_f*pitot1_g) -- formula for forming ice on Pitot1
	 --new cloud check here
	if Height > Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   if Cloud_type0 == 0 then wing1_h = 1 end --clear
	   if Cloud_type0 == 1 then wing1_h = 1.2 end --cirrus
	   if Cloud_type0 == 2 then wing1_h = 1.5 end --scattered
	   if Cloud_type0 == 3 then wing1_h = 1.8 end --broken
	   if Cloud_type0 == 4 then wing1_h = 2 end --overcast
	   if Cloud_type0 == 5 then wing1_h = 3 end --stratus
	   if Cloud_coverage0 < 1 then wing1_i = 1 end -- clear sky
	   if Cloud_coverage0 >= 1 and Cloud_coverage0 < 2 then wing1_i = 1 end -- a few clouds
	   if Cloud_coverage0 >= 2 and Cloud_coverage0 < 3 then wing1_i = 1.2 end -- normal coverage
	   if Cloud_coverage0 >= 3 and Cloud_coverage0 < 4 then wing1_i = 1.5 end -- lot of clouds
	   if Cloud_coverage0 >= 4 and Cloud_coverage0 < 5 then wing1_i = 1.8 end -- very high coverage
	   if Cloud_coverage0 >= 5 then wing1_i = 2 end -- full coverage
	   --play_sound(ONE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	   --play_sound(TWO) --debug sound
	end
	if Height > Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   if Cloud_type1 == 0 then wing1_h = 1 end --clear
	   if Cloud_type1 == 1 then wing1_h = 1.2 end --cirrus
	   if Cloud_type1 == 2 then wing1_h = 1.4 end --scattered
	   if Cloud_type1 == 3 then wing1_h = 1.5 end --broken
	   if Cloud_type1 == 4 then wing1_h = 2 end --overcast
	   if Cloud_type1 == 5 then wing1_h = 2.5 end --stratus
	   if Cloud_coverage1 < 1 then wing1_i = 1 end -- clear sky
	   if Cloud_coverage1 >= 1 and Cloud_coverage1 < 2 then wing1_i = 1 end -- a few clouds
	   if Cloud_coverage1 >= 2 and Cloud_coverage1 < 3 then wing1_i = 1.5 end -- normal coverage
	   if Cloud_coverage1 >= 3 and Cloud_coverage1 < 4 then wing1_i = 2 end -- lot of clouds
	   if Cloud_coverage1 >= 4 and Cloud_coverage1 < 5 then wing1_i = 3 end -- very high coverage
	   if Cloud_coverage1 >= 5 then wing1_i = 4 end -- full coverage
	   --play_sound(TWO) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if Height > Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   if Cloud_type2 == 0 then wing1_h = 1 end --clear
	   if Cloud_type2 == 1 then wing1_h = 1.1 end --cirrus
	   if Cloud_type2 == 2 then wing1_h = 1.3 end --scattered
	   if Cloud_type2 == 3 then wing1_h = 1.4 end --broken
	   if Cloud_type2 == 4 then wing1_h = 1.8 end --overcast
	   if Cloud_type2 == 5 then wing1_h = 2 end --stratus
	   if Cloud_coverage2 < 1 then wing1_i = 1 end -- clear sky
	   if Cloud_coverage2 >= 1 and Cloud_coverage2 < 2 then wing1_i = 1 end -- a few clouds
	   if Cloud_coverage2 >= 2 and Cloud_coverage2 < 3 then wing1_i = 1.5 end -- normal coverage
	   if Cloud_coverage2 >= 3 and Cloud_coverage2 < 4 then wing1_i = 2 end -- lot of clouds
	   if Cloud_coverage2 >= 4 and Cloud_coverage2 < 5 then wing1_i = 3 end -- very high coverage
	   if Cloud_coverage2 >= 5 then wing1_i = 4 end -- full coverage
	   --play_sound(THREE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if in_clouds ~= 1 and Altitude > 20000 then
    	wing1_h = 0
		--play_sound(LOOKINGOODTWICE) --debug sound
		--play_sound(THREE)
	end -- not in clouds above FL200? no more ice cumulation
	--end of new cloud check here
	 if paused_sim == 1 then step_wing1 = 0 end --paused sim bug resolver
	 ice_on_wing1 = ice_on_wing1+step_wing1*wing1_a*wing1_b*wing1_c*wing1_d*wing1_e*wing1_f*wing1_g*wing1_h*wing1_i*ACF*clearsky_general  -- formula for forming ice on Wing1
	 --play_sound(THREE)
	 if ice_on_wing1 > 0.11 and played_whatishappening == false and Vertical > 200 then 
	   play_sound(WHATISHAPPENING)
	   played_whatishappening = true --you hear that? dont play it again
	 end
	 if ice_on_wing1 > 0.11 and played_whatishappening == true and Vertical < -200 then 
	   play_sound(WHATISHAPPENING)
	   played_whatishappening = false --you hear that? dont play it again unless you decending
	 end
     if ice_on_wing1 > 0.99995 then ice_on_wing1 = 1 end
     if ice_on_wing1 < 0.000001 then ice_on_wing1 = 0 end -- limit values
   end -- end if its cold
 end -- end of Wing1
 
 function Wing2()
 --Wing has ice fail section
  --DC3 bugfixer starts
 --if ACFTYPE == 47 then
  --Surface_boot_ON = Antiice_boot_ON --works for both wings here temporary disabled
 --  step_wing2 = 0
 --end
 --DC3 bugfixer ends
--TAT is below zero
 if TAT < 0 and Right_ON == 1 or Surface_boot_ON == 1 then -- Wing heat is on and cold outside - no change
   --play_sound(ONE) --debug sound
   --step_wing2 = 0 
   step_wing2 = 0.01
   if paused_sim == 1 then step_wing2 = 0 end --paused sim bug resolver
   -- new override formula
   ice_on_wing2 = ice_on_wing2-step_wing2
   if ice_on_wing2 > 0.99995 then ice_on_wing2 = 1 end -- limit value
   if ice_on_wing2 < 0.000001 then ice_on_wing2 = 0 end
   --play_sound(THREE)
   --RESOLVED BUG here static is growing or lowering by default xplane logic
   --possible cause?
 -- end of override formula
   --play_sound(ONE)
 end
  if TAT > 0 then
   step_wing2 = dxib_mul -- default coeficient for Wing2 , small ice (0.001 step = long (enough to increase ); 0.01 fast step) every second
   --play_sound(TWO) --debug sound
   --if paused_sim == 1 then step_wing2 = 0 end --paused sim bug resolver
   if speed_true > 10 and speed_true < 100 then wing2_a = 1.5 end -- adds speed of forming ice on Wing2 by factor
   if speed_true > 100 and speed_true < 200 then wing2_a = 2 end
   if speed_true > 200 then wing2_a = 5 end
   if Altitude > 0 and Altitude < 6000 then wing2_b = 1.3 end
   if Altitude > 6000 and Altitude < 12000 then wing2_b = 1.5 end -- adds another speed of forming ice on Wing2 by factor
   if Altitude > 12000 and Altitude < 30000 then wing2_b = 4 end
   if Altitude > 30000 then wing2_b = 6 end
   if OAT < 0 and OAT > -20 then  wing2_c = 1 end -- adds another speed of forming ice on Wing2 by factor
   if OAT < -20 and OAT > -40 then  wing2_c = 6 end
   if OAT < -40 then wing2_c = 9 end
   --if FOG > 1000 then wing2_d = 1 end -- adds another speed of forming ice on Wing2 by factor
   --if FOG < 1000 then wing2_d = 2 end
   if FOG > 5000 then wing2_d = 1 end -- adds another speed of forming ice on Window by factor
   if FOG > 3000 and FOG <= 5000 then wing2_d = 1.1 end
   if FOG > 1000 and FOG <= 3000 then wing2_d = 1.2 end
   if FOG < 1000 then wing2_d = 1.5 end
   if Rain_on_acf < 0.025 then wing2_e = 1 end -- adds another speed of forming ice on Wing1 by factor
   if Rain_on_acf > 0.025 then wing2_e = 2 end
   if Wind_force < 10 then wing2_f = 0.8 end -- Wing gets colder from low wind force
   if Wind_force > 10 and Wind_force < 30 then wing2_f = 1 end
   if Wind_force > 30 and speed_true > 200 then wing2_f = 1.5 end -- Wing2 is heating a bit from high speeds of wind and movement
   if Wind_dir > 0 and Wind_dir < 90 then wing2_g = 4 end -- Wing2 gets hotter from direct wind
   if Wind_dir > 90 and Wind_dir < 359 then wing2_g = 0.8 end -- Wing2 dont absorb hot air because no wind on left side
   if paused_sim == 1 then step_wing2 = 0 end --paused sim bug resolver
   ice_on_wing2 = ice_on_wing2-step_wing2*wing2_a*wing2_b*wing2_c*wing2_d*wing2_e*wing2_f*wing2_g*clearsky_general -- formula for forming ice on Wing2
   --play_sound(TWO)
   if ice_on_wing2 > 0.9991 then ice_on_wing2 = 1 end -- limit value
   if ice_on_wing2 < 0.000001 then ice_on_wing2 = 0 end
   --if ice_on_aoa < 0.9 then fail_on_AOA = 0 end -- disable failure does not work

  end -- end of Wing1 is hot
    if TAT < 0 and Right_ON ~= 1 or Surface_boot_ON ~= 1 and ground_deice == 0 then 
	--if TAT < 0 and Right_ON ~= 1 and ground_deice == 0 then 
	 --play_sound(THREE) --debug sound
     step_wing2 = dxib_mul -- we need here slow speed of forming because wing is large
	 --step_wing2 = (AIRDENS/10000)*math.abs(HUMID/100)*(20/wingarea)
	 --if paused_sim == 1 then step_wing2 = 0 end --paused sim bug resolver
	 if speed_true < 10 and Altitude < 6000 then wing2_a = 1.1 end
	 if speed_true > 10 and speed_true < 100 then wing2_a = 1.2 end -- adds speed of forming ice on Wing2 by factor
     if speed_true > 100 and speed_true < 200 then wing2_a = 1.5 end
     if speed_true > 200 then wing2_a = 2 end
	 if Altitude > 0 and Altitude < 6000 then wing2_b = 1.5 end
     if Altitude > 6000 and Altitude < 12000 then wing2_b = 1.2 end -- adds another speed of forming ice on Wing2 by factor
     if Altitude > 12000 and Altitude < 30000 then wing2_b = 1.1 end
     if Altitude > 30000 then wing2_b = 1 end
     if OAT < 0 and OAT > -20 then  wing2_c = 1.5 end -- adds another speed of forming ice on Wing2 by factor
     if OAT < -20 and OAT > -40 then  wing2_c = 1.2 end
     --if OAT > -40 then wing2_c = 4 end
	 --if OAT < -40 then wing2_c = 0 end -- new from physics analysis, stops further freezing
	 if OAT < -48 and in_clouds == 0 then wing2_c = 0 end -- new from physics analysis, stops further freezing
     if OAT < -48 and in_clouds == 1 then wing2_c = 1 end -- new from physics analysis, in clouds icing
     --if FOG > 1000 then wing2_d = 1 end -- adds another speed of forming ice on Wing2 by factor
     --if FOG < 1000 then wing2_d = 2 end
	 if FOG > 5000 then wing2_d = 1 end -- adds another speed of forming ice on Window by factor
     if FOG > 3000 and FOG <= 5000 then wing2_d = 1.5 end
     if FOG > 1000 and FOG <= 3000 then wing2_d = 1.8 end
     if FOG < 1000 then wing2_d = 2.2 end
     if Rain_on_acf < 0.025 then wing2_e = 1.1 end -- adds another speed of forming ice on Wing1 by factor
     if Rain_on_acf > 0.025 then wing2_e = 2 end
     if Wind_force < 10 then wing2_f = 0.8 end -- Wing2 gets colder from low wind force
     if Wind_force > 10 and Wind_force < 30 then wing2_f = 1 end
     if Wind_force > 30 and speed_true > 200 then wing2_f = 1.5 end -- Wing2 is heating a bit from high speeds of wind and movement
     if Wind_dir > 270 and Wind_dir < 359 then wing2_g = 1.2 end -- Wing2 gets colder a bit from direct wind
     if Wind_dir > 0 and Wind_dir < 270 then wing2_g = 0.8 end -- Wing2 dont absorb cold air because no wind on left side
     --ice_on_pitot1 = 1-(ice_on_pitot1+step_pitot1*pitot1_a*pitot1_b*pitot1_c*pitot1_d*pitot1_e*pitot1_f*pitot1_g) -- formula for forming ice on Pitot1
	 --new cloud check here
	if Height > Cloud_base0 and Height < Cloud_top0 then -- detection flying through or close to first layer of clouds   
	   if Cloud_type0 == 0 then wing2_h = 1 end --clear
	   if Cloud_type0 == 1 then wing2_h = 1.2 end --cirrus
	   if Cloud_type0 == 2 then wing2_h = 1.5 end --scattered
	   if Cloud_type0 == 3 then wing2_h = 1.8 end --broken
	   if Cloud_type0 == 4 then wing2_h = 2 end --overcast
	   if Cloud_type0 == 5 then wing2_h = 3 end --stratus
	   if Cloud_coverage0 < 1 then wing2_i = 1 end -- clear sky
	   if Cloud_coverage0 >= 1 and Cloud_coverage0 < 2 then wing2_i = 1 end -- a few clouds
	   if Cloud_coverage0 >= 2 and Cloud_coverage0 < 3 then wing2_i = 1.2 end -- normal coverage
	   if Cloud_coverage0 >= 3 and Cloud_coverage0 < 4 then wing2_i = 1.5 end -- lot of clouds
	   if Cloud_coverage0 >= 4 and Cloud_coverage0 < 5 then wing2_i = 1.8 end -- very high coverage
	   if Cloud_coverage0 >= 5 then wing2_i = 2 end -- full coverage
	   --play_sound(ONE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	   --play_sound(TWO) --debug sound
	end
	if Height > Cloud_base1 and Height < Cloud_top1 then -- detection flying through or close to 2nd layer of clouds
	   if Cloud_type1 == 0 then wing2_h = 1 end --clear
	   if Cloud_type1 == 1 then wing2_h = 1.2 end --cirrus
	   if Cloud_type1 == 2 then wing2_h = 1.4 end --scattered
	   if Cloud_type1 == 3 then wing2_h = 1.5 end --broken
	   if Cloud_type1 == 4 then wing2_h = 2 end --overcast
	   if Cloud_type1 == 5 then wing2_h = 2.5 end --stratus
	   if Cloud_coverage1 < 1 then wing2_i = 1 end -- clear sky
	   if Cloud_coverage1 >= 1 and Cloud_coverage1 < 2 then wing2_i = 1 end -- a few clouds
	   if Cloud_coverage1 >= 2 and Cloud_coverage1 < 3 then wing2_i = 1.5 end -- normal coverage
	   if Cloud_coverage1 >= 3 and Cloud_coverage1 < 4 then wing2_i = 2 end -- lot of clouds
	   if Cloud_coverage1 >= 4 and Cloud_coverage1 < 5 then wing2_i = 3 end -- very high coverage
	   if Cloud_coverage1 >= 5 then wing2_i = 4 end -- full coverage
	   --play_sound(TWO) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if Height > Cloud_base2 and Height < Cloud_top2 then -- detection flying through or close to 3rd layer of clouds
	   if Cloud_type2 == 0 then wing2_h = 1 end --clear
	   if Cloud_type2 == 1 then wing2_h = 1.1 end --cirrus
	   if Cloud_type2 == 2 then wing2_h = 1.3 end --scattered
	   if Cloud_type2 == 3 then wing2_h = 1.4 end --broken
	   if Cloud_type2 == 4 then wing2_h = 1.8 end --overcast
	   if Cloud_type2 == 5 then wing2_h = 2 end --stratus
	   if Cloud_coverage2 < 1 then wing2_i = 1 end -- clear sky
	   if Cloud_coverage2 >= 1 and Cloud_coverage2 < 2 then wing2_i = 1 end -- a few clouds
	   if Cloud_coverage2 >= 2 and Cloud_coverage2 < 3 then wing2_i = 1.5 end -- normal coverage
	   if Cloud_coverage2 >= 3 and Cloud_coverage2 < 4 then wing2_i = 2 end -- lot of clouds
	   if Cloud_coverage2 >= 4 and Cloud_coverage2 < 5 then wing2_i = 3 end -- very high coverage
	   if Cloud_coverage2 >= 5 then wing2_i = 4 end -- full coverage
	   --play_sound(THREE) --debug sound
	   in_clouds = 1
	   --else
	   --in_clouds = 0
	end
	if in_clouds ~= 1 and Altitude > 20000 then
    	wing2_h = 0
		--play_sound(LOOKINGOODTWICE) --debug sound
		--play_sound(THREE)
	end -- not in clouds above FL200? no more ice cumulation
	--end of new cloud check here
	 if paused_sim == 1 then step_wing2 = 0 end --paused sim bug resolver
	 ice_on_wing2 = ice_on_wing2+step_wing2*wing2_a*wing2_b*wing2_c*wing2_d*wing2_e*wing2_f*wing2_g*wing2_h*wing2_i*ACF*clearsky_general -- formula for forming ice on Wing2
	 --play_sound(THREE)
     if ice_on_wing2 > 0.99995 then ice_on_wing2 = 1 end
     if ice_on_wing2 < 0.000001 then ice_on_wing2 = 0 end -- limit values
   end -- end if its cold
 end -- end of Wing2
 

 -- OLD code
--if OAT < 0 and speed < 10 then -- aircraft in winter taxiing or stopped
 -- step_AOA = 0.01 -- small ice every second
 -- ice_on_aoa = ice_on_aoa+step_AOA -- adds little ice on AOA sensor
 -- if AOA_ON == 1 then step_AOA = 0 end -- if sensor is heated no additional ice
 -- end -- end of AOA icing when aircraft is in winter taxiing or stopped
--if OAT > 0 and speed < 10 then -- ACF taxiing in warm conditions
--  step_AOA = 0 -- no ice
-- ice_on_aoa = 0 -- no fail
 -- fail_on_AOA = 0 -- no fail
--end -- end of ACF taxiing in warm conditions
--end --end AOA

-- OLD code
--if oat < -40 and antiiceR == 0 then
--set ( "1-sim/fuel/fuelCutOffRight",    0.0)

--end

--if oat < -40 and antiiceL == 0 then
--set ( "1-sim/fuel/fuelCutOffLeft",    0.0)

--end

--end
do_often("old_datarefs()")
do_often("waitforsim()")
do_often("reset_trick()")
--do_often("test()") -- debug function, remove later
do_often("clearsky()")
do_often("AOA()")
do_often("AOA2()")
do_often("Pitot1()")
do_often("Pitot2()")
do_often("Static1()")
do_often("Static2()")
do_often("Window()") 
--do_often("Inlet()")
do_often("Inlet0()")
do_often("Inlet1()")
do_often("Prop0()")
do_often("Prop1()")
do_often("Wing1()")
do_often("Wing2()")
do_often("General_sounds()")
do_often("Ground()")
--do_often("badweather()")
--AoA has now no effect in X-plane (not well modeled?) 
--Pitot fail increase airspeed indicator or freeze airspeed indicator and VSI done by "ice_on_pitot1"
--Window heat has no effect in X-plane (not modeled or modeled via private datarefs from ACF author)
--Inlet iceing affect engine RPM and EGT, increases when icing. Can cause ENG fail.
--Wing icing makes ACF heavier, here 737-800 Zibo 0.2 is critical

