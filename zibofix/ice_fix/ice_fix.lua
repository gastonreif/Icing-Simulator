--**********************************************************************--
--** 				        Icing Simulator 1.24 Zibo hotfix          **--
--***********************************************************************--


--**********************************************************************--
--** 				             FIND X-PLANE DATAREFS            	  **--
--**********************************************************************--
--FrontWindows_ice = find_dataref("sim/flightmodel/failures/window_ice_per_window", "array[3]")
FrontWindows_ice = find_dataref("sim/flightmodel/failures/window_ice_per_window")
FrontWindows_heater = find_dataref("sim/cockpit2/ice/ice_window_heat_on") -- inverted
FrontWindows_staticheater = find_dataref("sim/cockpit2/ice/ice_static_heat_on_pilot")

--------------------------------------------------------------------------------------------


function Fix_ice_zibo()
   if FrontWindows_staticheater == 1 then
	if FrontWindows_heater == 1 then
	 FrontWindows_ice[0] = 0
	 FrontWindows_ice[1] = 0
	 FrontWindows_ice[2] = 0
	 FrontWindows_ice[3] = 0
	end
   end
end
function flight_start()
    Fix_ice_zibo() 
end
function after_physics()
	Fix_ice_zibo() 
end