
#    ###################################################################################
#    Antonov-Aircrafts and SpaceShuttle :: Herbert Wagner November2014-March2015
#    Development is ongoing, see latest version: www.github.com/HerbyW
#    This file is licenced under the terms of the GNU General Public Licence V3 or later
#    
#    Firefly: 3D model improvment: ruder, speedbreak, ailerions, all gears and doors
#    Eagel: Liveries
#    ###################################################################################


 var oilTempTimer = maketimer(5.0, func { 
var factor = 2;
interpolate("engines/engine/oil-temperature-degf", getprop("engines/engine/fuel-flow-gph")*factor, 5.0);
interpolate("engines/engine[1]/oil-temperature-degf", getprop("engines/engine[1]/fuel-flow-gph")*factor, 5.0);
interpolate("engines/engine[2]/oil-temperature-degf", getprop("engines/engine[2]/fuel-flow-gph")*factor, 5.0);
interpolate("engines/engine[3]/oil-temperature-degf", getprop("engines/engine[3]/fuel-flow-gph")*factor, 5.0);
}
);

oilTempTimer.start(); 
