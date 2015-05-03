#
# Autostart for AN-225
#
#    ###################################################################################
#    Antonov-Aircrafts and SpaceShuttle :: Herbert Wagner November2014-March2015
#    Development is ongoing, see latest version: www.github.com/HerbyW
#    This file is licenced under the terms of the GNU General Public Licence V3 or later
#    
#    Firefly: 3D model improvment: ruder, speedbreak, ailerions, all gears and doors
#    Eagel: Liveries
#    ###################################################################################


setlistener("/controls/autostart", func 

  { if(getprop("/controls/autostart") > 0.5)
      {
	
	setprop("/controls/electric/battery-switch", 1);
        setprop("/controls/switches/gauge-light", 1);
        setprop("/controls/lighting/nav-lights", 1);
	
	setprop("sim/messages/copilot", "Main power and lights are on");
	
	setprop("/instrumentation/adf[0]/power-btn", 1);
	setprop("/instrumentation/adf[1]/power-btn", 1);
	setprop("/instrumentation/heading-indicator[0]/serviceable", 1);
	setprop("/instrumentation/nav[0]/power-btn", 1);
	setprop("/instrumentation/nav[1]/power-btn", 1);
	setprop("/instrumentation/transponder/serviceable", 1);
	
	setprop("sim/messages/copilot", "Instruments are powered");
	
	setprop("/controls/switches/fuel", 1);
        setprop("/consumables/fuel/tank[0]/selected", 1);
        setprop("/consumables/fuel/tank[1]/selected", 1);
        setprop("/consumables/fuel/tank[2]/selected", 1);
        setprop("/consumables/fuel/tank[3]/selected", 1);
	setprop("/consumables/fuel/tank[4]/selected", 1);
        
	interpolate("controls/engines/engine[0]/throttle", 0.1, 17);
	interpolate("controls/engines/engine[5]/throttle", 0.1, 34);
	interpolate("controls/engines/engine[1]/throttle", 0.1, 51);
	interpolate("controls/engines/engine[4]/throttle", 0.1, 68);
	interpolate("controls/engines/engine[2]/throttle", 0.1, 85);
	interpolate("controls/engines/engine[3]/throttle", 0.1, 102);
	
	interpolate("controls/engines/engine[0]/condition", 1, 1);
	interpolate("controls/engines/engine[5]/condition", 1, 17);
	interpolate("controls/engines/engine[1]/condition", 1, 34);
	interpolate("controls/engines/engine[4]/condition", 1, 51);
	interpolate("controls/engines/engine[2]/condition", 1, 68);
	interpolate("controls/engines/engine[3]/condition", 1, 85);
	
	interpolate("/engines/engine[0]/running", 1, 1);
	interpolate("/engines/engine[5]/running", 1, 17);
	interpolate("/engines/engine[1]/running", 1, 34);
	interpolate("/engines/engine[4]/running", 1, 51);
	interpolate("/engines/engine[2]/running", 1, 68);
	interpolate("/engines/engine[3]/running", 1, 85);
	
	setprop("sim/messages/copilot", "Engines 1-6 starting up, wait 102 seconds till idle position");
	setprop("sim/messages/copilot", "Press < to control all engine lamps going to green");
      }  
  }
  );
