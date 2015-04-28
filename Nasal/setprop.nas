

#    ###################################################################################
#    Antonov-Aircrafts and SpaceShuttle :: Herbert Wagner November2014-March2015
#    Development is ongoing, see latest version: www.github.com/HerbyW
#    This file is licenced under the terms of the GNU General Public Licence V3 or later
#    
#    Firefly: 3D model improvment: ruder, speedbreak, ailerions, all gears and doors
#    Eagel: Liveries
#    ###################################################################################


#UVID-15 Control for Pressure in mmhg and inhg
# create listener

setlistener("/instrumentation/altimeter/setting-inhg", func(v)
{
  if(v.getValue())
  
    setprop("/instrumentation/altimeter/mmhg", getprop("/instrumentation/altimeter/setting-inhg") * 25.4);
    setprop("/instrumentation/altimeter/setting-inhgN", getprop("/instrumentation/altimeter/setting-inhg") + 0.005);
    setprop("/instrumentation/altimeter/setting-hapa", getprop("/instrumentation/altimeter/setting-inhg") * 33.8682715);
});

#####################################################################################################################

#UVPD Control
# create timer with 0.5 second interval
var timerDiff = maketimer(0.5, func

{ 
    setprop("/controls/pressurization/diffdruck", (1 / getprop("/environment/atmosphere/density-tropo-avg") - 1.58));    
  }
);

# start the timer (with 0.5 second inverval)
timerDiff.start();

######################################################################################################################

#
#Paratroopers
#
setlistener("/controls/paratroopers/jump-signal", func(v) {
  if(v.getValue()){
    interpolate("/controls/paratroopers/jump-signal-pos", 1, 0.25);
  }else{
    interpolate("/controls/paratroopers/jump-signal-pos", 0, 0.25);
  }
});

######################################################################################################################

#
# Air and Groundspeed selector for USVP-Instrument
#
setlistener("/controls/switches/usvp-selector-trans", func 

  { if(getprop("/controls/switches/usvp-selector-trans") > 0.5)
      {
        setprop("/instrumentation/usvp/air_ground_speed_kt", getprop("/velocities/groundspeed-kt"));
      }
      else
      {
        setprop("/instrumentation/usvp/air_ground_speed_kt", getprop("/velocities/airspeed-kt"));
      }
  
  }
  );
 
#####################################################################################################################

#Lights
setprop("controls/switches/headlight-mode", 1);

######################################################################################################################

#
#Fuel and Condition Control
#
setprop("/consumables/fuel/tank[0]/selected", 0);
setprop("/consumables/fuel/tank[1]/selected", 0);
setprop("/consumables/fuel/tank[2]/selected", 0);
setprop("/consumables/fuel/tank[3]/selected", 0);
setprop("/consumables/fuel/tank[4]/selected", 0);
setprop("/controls/switches/fuel", 0);

setlistener("/controls/switches/fuel", func 

  { if(getprop("/controls/switches/fuel") > 0.5)
      {
        setprop("/consumables/fuel/tank[0]/selected", 1);
        setprop("/consumables/fuel/tank[1]/selected", 1);
        setprop("/consumables/fuel/tank[2]/selected", 1);
        setprop("/consumables/fuel/tank[3]/selected", 1);
	setprop("/consumables/fuel/tank[4]/selected", 1);
      }
      else
      {
        setprop("/consumables/fuel/tank[0]/selected", 0);
        setprop("/consumables/fuel/tank[1]/selected", 0);
        setprop("/consumables/fuel/tank[2]/selected", 0);
        setprop("/consumables/fuel/tank[3]/selected", 0);
	setprop("/consumables/fuel/tank[4]/selected", 0);
	setprop("/controls/engines/engine[0]/condition", 0);
	setprop("/controls/engines/engine[1]/condition", 0);
	setprop("/controls/engines/engine[2]/condition", 0);
	setprop("/controls/engines/engine[3]/condition", 0);
	setprop("/controls/engines/engine[4]/condition", 0);
	setprop("/controls/engines/engine[5]/condition", 0);
      }
  
  }
  );
 
##########################################################
#      ALS Control by HerbyW 03/2015
##########################################################

setlistener("/controls/ALS/setting", func(v) {
  if(v.getValue()){
    interpolate("/controls/ALS/setting-pos", 1, 0.25);
  }else{
    interpolate("/controls/ALS/setting-pos", 0, 0.25);
  }
});


setlistener("controls/ALS/setting", func

 { 
   if(getprop("sim/rendering/rembrandt/enabled") == 1)
    {
      setprop("sim/messages/copilot", "ALS is not working with Rembrandt");
    }
    else
    { 
      if(getprop("controls/ALS/setting") == 1)
      {
      setprop("sim/rendering/shaders/skydome", 1);
      setprop("sim/rendering/als-secondary-lights/landing-light1-offset-deg", -12);
      setprop("sim/rendering/als-secondary-lights/landing-light2-offset-deg", 12);
      setprop("sim/rendering/als-secondary-lights/use-alt-landing-light", 1);
      setprop("sim/rendering/als-secondary-lights/use-landing-light", 1);
      setprop("sim/rendering/als-secondary-lights/use-searchlight", 1);
      }
      else
      {
      setprop("sim/rendering/als-secondary-lights/use-alt-landing-light", 0);
      setprop("sim/rendering/als-secondary-lights/use-landing-light", 0);
      setprop("sim/rendering/als-secondary-lights/use-searchlight", 0);
      }
    }   

 }
);

#######################################################################################################

# SKAWK support

setlistener("instrumentation/transponder/inputs/mode", func

{
  
  var mode_handle = getprop("/instrumentation/transponder/inputs/mode" );
  var mode = 1;

  if( mode_handle == 0 ) mode = 4;
  if( mode_handle == 2 ) mode = 5;
  if( mode_handle == 1 ) mode = 1;
  if( mode_handle == 3 ) mode = 3;

  setprop("/instrumentation/transponder/inputs/knob-mode", mode );
  
});

setprop("/instrumentation/transponder/serviceable", 0);
########################################################################################################

# Parking Chokes and Brake Control

setlistener("controls/gear/brake-parking", func

{ if (getprop("/sim/replay/replay-state") == 0)

{
   if (getprop("/controls/gear/brake-parking") == 0)
    {
      if (getprop("/controls/chokes/activ") == 1)
        {
	  setprop("sim/messages/copilot", "Parking Chokes are at the wheels! Parking Brake can not be lift");
          setprop("/controls/gear/brake-parking", 1);
        }
      else
        {
	  setprop("sim/messages/copilot", "Parking Brake off, aircraft is moving!");
	  setprop("/controls/gear/brake-parking", 0);  
	}
     }
    else
     {
       if (getprop("/position/gear-agl-m") > 2)
        {
	 setprop("sim/messages/copilot", "We are in the air, Brakes have no sense...");
	 setprop("/controls/gear/brake-parking", 0);
        }
       else
        {
	  setprop("sim/messages/copilot", "Parking Brake on, check if chokes are needed!");
	}
     } 
}});  

setlistener("/controls/chokes/activ", func

{ if (getprop("/sim/replay/replay-state") == 0)
{
   if (getprop("/controls/chokes/activ") == 1)
   if (getprop("/controls/gear/brake-parking") == 0)
        {
	  setprop("sim/messages/copilot", "Parking Brake off, Chokes can not be set!");
	  setprop("/controls/chokes/activ", 0);  
	}
    if (getprop("/controls/chokes/activ") == 1)
    if (getprop("/controls/gear/brake-parking") == 1)
        {
	  setprop("sim/messages/copilot", "Parking Brake and Chokes are set, enjoy your day!");
	}
}});

########################################################################################################

# Landing Gears Control with help from: 707 Hangar of Constance

# prevent retraction of the landing gear when any of the wheels are compressed
setlistener("controls/gear/gear-down", func
 {
 var down = props.globals.getNode("controls/gear/gear-down").getBoolValue();
 var crashed = getprop("sim/crashed") or 0;
 if (!down and (getprop("gear/gear[0]/wow") or getprop("gear/gear[1]/wow") or getprop("gear/gear[2]/wow")))
  {
    if(!crashed){
  		props.globals.getNode("controls/gear/gear-down").setBoolValue(1);
    }else{
  		props.globals.getNode("controls/gear/gear-down").setBoolValue(0);
    }
  }
 });
 


#############################################################################################################
#
# wind drift angle calculations, with help from: D-LEON
#
# wind direction:  environment/metar/base wind-dir-deg
# wind speed:      environment/metar/base wind-speed-kt
# heading:         orientation/heading-deg
# speed:           instrumentation/airspeed-indicator/indicated-speed-kt

#
#Calculate Ground Speed, Course & Wind Correction Angle
# create timer with 0.7 second interval
setprop("/autopilot/settings/heading-bug-deg", 0.001);

var TODEG = 180/math.pi;
var TORAD = math.pi/180;
var deg = func(rad){ return rad*TODEG; }
var rad = func(deg){ return deg*TORAD; }

var calc = maketimer(0.7, func

{ 
 
  var TWD 	= rad(getprop("/environment/wind-from-heading-deg"));
  var WS 	= getprop("/environment/wind-speed-kt");
  var TC 	= rad(getprop("/autopilot/settings/heading-bug-deg"));

  var TAS	= getprop("/instrumentation/airspeed-indicator/true-speed-kt");
  var MD 	= rad(getprop("/environment/magnetic-variation-deg"));  
  
  var x = WS * math.sin((TC-TWD));
  var y = TAS - (WS * math.cos((TC-TWD))); 
  
  DA = math.atan2(x,y);  
    
  if  
    (getprop("/instrumentation/airspeed-indicator/true-speed-kt") < 25 )
    { setprop("/instrumentation/drift",0 );}
  else
  { setprop("/instrumentation/drift",deg(DA)); }
  
}
);

# start the timer (with 0.7 second inverval)
calc.start();

#############################################################################################################


setprop("sim/messages/copilot", "Hello");
setprop("sim/messages/copilot", getprop("sim/multiplay/generic/string[0]"));
setprop("sim/messages/copilot", "Have fun with the Antonov-225");
setprop("sim/messages/copilot", "For Autostart hit the s key!");


####################################################################################################################

#
# Reverser
#

setlistener("/controls/engines/engine[0]/reverser", func
 {
if
(  getprop("/controls/engines/engine[0]/reverser") == 0) 
{
setprop("/controls/reverser", 0);

}
else
{  
setprop("/controls/reverser", 1);
}
 }
);


setlistener("/controls/reverser", func
 {
if
(  getprop("/controls/reverser") == 0) 
{
setprop("/controls/engines/engine[0]/reverser", 0);
setprop("/controls/engines/engine[1]/reverser", 0);
setprop("/controls/engines/engine[2]/reverser", 0);
setprop("/controls/engines/engine[3]/reverser", 0);
setprop("/controls/engines/engine[4]/reverser", 0);
setprop("/controls/engines/engine[5]/reverser", 0);

}
else
{  
setprop("/controls/engines/engine[0]/reverser", 1);
setprop("/controls/engines/engine[1]/reverser", 1);
setprop("/controls/engines/engine[2]/reverser", 1);
setprop("/controls/engines/engine[3]/reverser", 1);
setprop("/controls/engines/engine[4]/reverser", 1);
setprop("/controls/engines/engine[5]/reverser", 1);
}
 }
);
