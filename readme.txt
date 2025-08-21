

Icing Simulator v1.24 The complete edition for X-Plane 12.00+.


Background:
With introduction of X-Plane 11.30 there are new features which affect aircraft performance when icing conditions occurs.
Here is another math model, more balanced, more sophisticated then default X-Plane model which you can use with all jets and propellers.
Main purpose of creating this was the scenario when you forget to switch anti-ice systems on, usually nothing happens, which is not real.
So it is good for practicing as simulator for icing conditions.

Short description:
This LUA script respond to weather conditions and enhance default x-plane icing logic closer to real one.
You can use ground-de ice by tunning COM2 122.10, it will get rid the ice before takeoff, time frame cca 25 minutes, enough for taxiing etc.
If you forget switch on or have faulty Pitot and static port sensors some of your indicators for speed and altitude just freeze or show wrong values.
Angle of Attack (AoA) sensors and Wing Anti-ice/boot off could cause bad airflow and loss of lift and stall.
Window heats off in well modeled aircrafts causes frozen windows with bad visibility.
Propeller heaters off means not enough power for flight so switch them on before start.
Inlet heaters off during icing conditions could led to engine flameout or compressor stall, some of them are recoverable, some not and must be shutdown.
All aircrafts have some of these systems to be switched on or off so watch them and use them according actual conditions, procedures and checklists.
If you forget to heat, switch the systems on when needed, you can hear warning from copilot (voice of well known youtuber Airforceproud95) and in worse
scenarios get problems to fly and loose the control.

Usage:
copy contents to your x-plane /Resources/plugins/flywithlua/scripts/ except zibofix folder.
If you want to fly with Zibo B737 then copy content of zibofix to \X-Plane 12\Aircraft\B737-800X\plugins\xlua\scripts
Start X-Plane with your favorite plane.
When you found icing conditions turn according airplane checklist the correct heaters or anti-ice systems.
If you forget to switch Window heat you can have frost on windshield, switch it on, after several seconds or minutes will disappear.
If your altitude or speed indicators froze or rapidly increase/decrease regardless of airplane behavior check your Pitot and static port switches.
Soon after powering up the heaters indicators start to show correct.
If you are loosing lift watch for AoA sensor heater and Wing de-ice switches. Switch them on and descend rapidly to get the lift and speed.
Propeller heat is usefull when your propeller aircraft stayed for long during cold weather and gets ice or during heavy snowstorms. 
Turn it on for safe or just rotate the blades high to wipe out some bigger ice in safe area.
Bad scenarios are also if too much ice gets into the engines. During snow, freezing fog is better to turn inlet icing on. If you forget to do so
and icing conditions are here for longer time you may loose engine by damage from ice which causes blades damage in the worse case or have flameout
and engine must be shutdown. Try to restart it, i have created random logic for this so you can have luck to be able to restart it. 
If your engine will loose power but works you have just experienced compressor stall. Follow the procedures, throttle to idle and wait if it recover otherwise
shut it down. For now is made like this: more engines you have less engines likely to fail in this case.
Icing conditions are present also in high clouds. If you avoid them, above 20.000 fts, icing conditions are not present usually so you dont need
some anti-ice systems to be on until approach. 

Long description:
Icing is dangerous cumulating of ice on aircrafts parts like engines, windows and wings when outside temperatures are below zero degrees
celsius. Many aircrafts has some anti-ice systems which can prevent icing. This math model calculates speeds, altitude, temperatures,
and other forces and factors like clouds, snow, fog, rain and wind in combination with anti-ice systems whether they are on or off.
Every aircraft is different in terms of performance. This is model for jet and propeller powered aircrafts.
You can watch icing values in X-Plane built in on screen diagnostic display, same like FPS performance or simply trust your instincts
and included copilot annoucements from well known aviatic youtuber Airforceproud95 which will tell you what is wrong if you forget
to do something for ice protection. In X-plane 11.30 there is Angle of Atack modeled in Xplane. This script trigger it slowly
according other factors and forces. If you will dont have heaters on, aircraft behavior will change. This is similar for another
modeled Pitot icing and static port icing. When not heated, altitude and speed indication will be wrong. Windows heat is modeled too, will freeze usually.
Depends per aircraft, many of the authors do it different way because of visual effects. Wing icing is very good modeled in X-Plane 11.30.
If you will not heat it or get too much ice on wings leading edges flow is changed and performace affected a lot.
Another is inlet icing for engines. Dont let them suck in too much ice or water droplets. You can have flameout or compressor stall.
Last is propeller icing which is easy to solve by anti-ice switch or simply speed up your plane from stand still and
rotation of blades will wipe out the ice which is not the best because somebody gets hit.
Its LUA script and do not cover all payware aircrafts. That means technically it works with all aircrafts but some functions
may not work correctly. For example if aircraft has its own programed anti-ice and not use default X-plane logic, results may be with no effect.
Similar situation when aircraft dont have anti-ice switches at all, then it will go down during icing conditions without protection.
Generaly if you follow standard procedures correctly you will almost dont notice anything. If you forget to switch something on
during climb or approach expect complications. You will hear copilot speaking in some cases. After icing conditions are gone - it is normal and safe flight.
X-Plane uses for failures extra section, which dont need to be turned on in this case. X-Plane default icing method cannot be switched off
so works aside. If you want diagnostics and watch values for icing on screen go to X-Plane settings, page for data output, and
scroll down to Icing and Icing status 2 and mark it as visible on screen.

Ground de-ice usage:
I have created ground de-ice logic. No 3D model or visual icing/deicing is present. However some authors created it (ZiBo 737, FF 767...)
Now to use ground de-ice:
Open x-plane menu plugins -> flywithlua -> flywithlua macros -> icing Simulator to see status.
Tune on COM2 frequency 122.10 while on ground (and not moving) to call ground de-icer. If your aicraft has de-ice truck, move it in. 
There is 5 minutes window for de-icer to become operational. Copilot will announce something when ready. Its fully automatic.
Icing will disappear within some minutes.
After another 10 minutes copilot will announce you can start the engines. Icing will be gone now beacuse of the fluid.
From now on you have cca 10 minutes for roll on and takeoff until ice can build up again and de-ice fluid will lost the effect.
After takeoff or loosing frequency of 122.10 you will also loose the deice protection from the fluid and you must use anti-ice switches.
When use stopover, you need to switch to 136.99 and back to 122.10 to reset the function.


Features:
-works with piston, turboprops and jet aircrafts from light to super heavy A380
-propeller icing modeled
-AoA fail modeled
-Inlet icing modeled
-Wing icing modeled
-Pitot icing modeled
-Static port icing modeled
-Window icing modeled
-LUA script with sounds
-in cloud icing modeled (default weather engine based visuals - Skymaxx Pro, ActiveSky XP, xEnviro sometimes)
-de-icing on ground modeled (tune 122.10 on COM2)
-No need to have default X-Plane random failures set on


FAQ:
Q: What is the difference between this and default x-plane icing?
A: Default x-plane icing is slow, on every part of the aircraft is the same value and on ground has no effect. This one do more.

Q: I see no icing on the plane
A: X-Plane at the moment do not support visual side of the icing sorry. Latest aircrafts already have this on (FF767, Vskylabs DC3, Zibo 737-8..).

Q: Will it work in X-Plane 11.26 or eralier?
A: Partly, effects and behavior for icing is modeled from 11.30b1

Q: Will it work for gliders, turboprops and piston driven planes?
A: Yes, it checks what type of engines and weight have your aircraft and adjust some icing behavior

Q: It seems not working, i did not notice any icing
A: Thats good! You are flying right. To feel something freezing you need to fly through area of icing conditions without anti-ice set on,
     which is dangerous, generaly it is upto 20.000 feets high and from 2°C down to -40°C outside air temperature and in clouds, rain and freezing fog.

Q: Windows is not freezeing
A: Visual side not modeled, should be modeled by aircraft author. If modeled by the author and still no visuals it does not use standart x-plane logic.

Q: Some of mentioned icing failures seems not working
A: All depends on used aircrafts. Usually Pitot and static ports off should do something bad always. List of tested aircrafts below.

Q: It does not work, LUA stopped
A: contact me, you should not see this.

Q: LUA 2.7 says check your quarantine folder
A: disable moving scripts to quarantine in X-Plane Fly With LUA menu, hit also return quarantined items back and try reload the Fly With Lua scripts.

Q: I got stall or wierd behavior of aircraft
A: 2 reasons. You have got ice on aicraft with some anti-ice systems inoperational. Or you used aircraft which is not tested or which
     dont use standard X-Plane switches. You can report it to me for next update.

Q: I fly FL380 at -56°C OAT and airplane dont get any ice
A: Supercooled water which forms in ice is not present below -48°C. Only ice crystals are present, they usually bounce off the plane.


Requirements:
X-Plane 12.00+
FlywithLUA v2.2+


Installation:
Copy all files and folders except zibofix to your x-plane /Resources/plugins/flywithlua/scripts/ folder
Copy folder ice_fix including ice_fix.lua file inside from zibofix folder to your x-plane /aircraft/B737-800X/plugins/xlua/scripts/ folder
Copy soundtrack folder to your x-plane /Resources/plugins/flywithlua/scripts/ folder

Tested aircrafts:
ZIBO 737-800 4.01  Wings no effect, Inlet no effect, Pitot OK, Static OK, Window OK - use zibofix, AoA - no effect - Visual icing on Windshield
LR A330-300	   Wings OK, Pitot OK, Window - no effect, AoA - no effect
FF A320 v1.3.4    Inlet OK, others no effect, that systems have different logic
FF 767 v1.6.12      Wings OK, Inlet OK, Pitot - no effect, Window OK, Static no effect, AoA - no effect - Visual icing on Windshield
FF 777 v1.11.4     Wings OK, Inlet OK, Pitot OK(via wing anti-ice), Window - no effect, Static OK, AoA - no effect, it has its own backup protection
Default Baron      Wings OK, Prop OK, Pitot OK, Window - no effect, AoA - no effect
Default King Air   Wings OK, Prop OK, Pitot OK, Window - no effect, AoA - no effect
Default C172       Wings OK but not have anti-ice, Prop OK, Pitot OK, Window - no effect, AoA - no effect -not recommended for cold weather
VSkylabs DC3 4.06  Wings OK, Prop OK, Pitot OK, Window OK, AoA - no effect - this bird have visual icing on wings
Colimata Concorde FXP 3.50  Wings OK, Pitot OK, AoA OK, Inlet OK, Static OK, Windows OK
                 (use rotary timer in overhead panel section wing and intake anti-ice, pitot switches on are not enough)

Tested Weather Engines (extreme conditions effects):
Default Wether - Rain OK, Clouds OK, Fog OK 
Skymaxx 4 +RWC - Rain OK, Clouds OK, Fog OK
xEnviro - Rain OK, Clouds no effect, Fog no effect

Credits:
Airforceproud95 - well known aviation youtuber for his voice used here with permission

Known bugs: (caused by 3rd party addons)
use of planning in Betterpuhback clears the ice
using xEnviro in fog and clouds does zero effect on aircraft
light snow has zero effect on aircraft

Version 1.24
Gaston 2024
support:
gastonreif@gmail.com