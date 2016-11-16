###########################################################################################
#  Copyright (C) Herbert Wagner Dec2014-2016

#  extract from 707 by Mark Kraus
#  see Read-Me.txt for all copyrights in the base folder of this aircraft
###########################################################################################

var LightBeacon = props.globals.initNode("/controls/lighting/switches/beacon",0,"BOOL");
var LightStrobe = props.globals.initNode("/controls/lighting/switches/strobe",0,"BOOL");
var strobe_switch = props.globals.getNode("/controls/lighting/strobe", 1);
aircraft.light.new("/controls/lighting/strobe-state", [0.05, 1.20], strobe_switch);
var beacon_switch = props.globals.getNode("/controls/lighting/beacon", 1);
aircraft.light.new("/controls/lighting/beacon-state", [0.05, 1.8], beacon_switch);
