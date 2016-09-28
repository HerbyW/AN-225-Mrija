# from CitationX: modified for 6 engines AN-225 by Herbert Wagner 09/2016

#Jet Engine Helper class 
# ie: var Eng = JetEngine.new(engine number);

var JetEngine = {
    new : func(eng_num){
        m = { parents : [JetEngine]};
        m.fdensity = getprop("consumables/fuel/tank/density-ppg") or 6.72;
        m.eng = props.globals.getNode("engines/engine["~eng_num~"]",1);
        m.running = m.eng.initNode("running",0,"BOOL");
        m.n1 = m.eng.getNode("n1",1);
        m.n2 = m.eng.getNode("n2",1);
        m.fan = m.eng.initNode("fan",0,"DOUBLE");
        m.cycle_up = 0;
        m.engine_off=1;
        m.turbine = m.eng.initNode("turbine",0,"DOUBLE");
        m.throttle_lever = props.globals.initNode("controls/engines/engine["~eng_num~"]/throttle-lever",0,"DOUBLE");
        m.throttle = props.globals.initNode("controls/engines/engine["~eng_num~"]/throttle",0,"DOUBLE");
        m.ignition = props.globals.initNode("controls/engines/engine["~eng_num~"]/ignition",0,"DOUBLE");
        m.cutoff = props.globals.initNode("controls/engines/engine["~eng_num~"]/cutoff",1,"BOOL");
        m.fuel_out = props.globals.initNode("engines/engine["~eng_num~"]/out-of-fuel",0,"BOOL");
        m.starter = props.globals.initNode("controls/engines/engine["~eng_num~"]/starter",0,"BOOL");
        m.fuel_pph=m.eng.initNode("fuel-flow_pph",0,"DOUBLE");
        m.fuel_gph=m.eng.initNode("fuel-flow-gph");

        m.Lfuel = setlistener(m.fuel_out, func m.shutdown(m.fuel_out.getValue()),0,0);
        m.CutOff = setlistener(m.cutoff, func (ct){m.engine_off=ct.getValue()},1,0);
    return m;
    },
#### update ####
    update : func{
        var thr = me.throttle.getValue();
        if(!me.engine_off){
            me.fan.setValue(me.n1.getValue());
            me.turbine.setValue(me.n2.getValue());
            if(getprop("controls/engines/grnd_idle"))thr *=0.92;
            me.throttle_lever.setValue(thr);
        }else{
            me.throttle_lever.setValue(0);
            if(me.starter.getBoolValue()){
                if(me.cycle_up == 0)me.cycle_up=1;
            }
            if(me.cycle_up>0){
                me.spool_up(15);
            }else{
                var tmprpm = me.fan.getValue();
                if(tmprpm > 0.0){
                    tmprpm -= getprop("sim/time/delta-sec") * 2;
                    me.fan.setValue(tmprpm);
                    me.turbine.setValue(tmprpm);
                }
            }
        }
        
        me.fuel_pph.setValue(me.fuel_gph.getValue()*me.fdensity);
    },

    spool_up : func(scnds){
        if(me.engine_off){
        var n1=me.n1.getValue() ;
        var n1factor = n1/scnds;
        var n2=me.n2.getValue() ;
        var n2factor = n2/scnds;
        var tmprpm = me.fan.getValue();
            tmprpm += getprop("sim/time/delta-sec") * n1factor;
            var tmprpm2 = me.turbine.getValue();
            tmprpm2 += getprop("sim/time/delta-sec") * n2factor;
            me.fan.setValue(tmprpm);
            me.turbine.setValue(tmprpm2);
            if(tmprpm >= me.n1.getValue()){
                var ign=1-me.ignition.getValue();
                me.cutoff.setBoolValue(ign);
                me.cycle_up=0;
            }
        }
    },

    shutdown : func(b){
        if(b!=0){
            me.cutoff.setBoolValue(1);
        }
    }

};

var FDM="";
var Grd_Idle=props.globals.initNode("controls/engines/grnd-idle",1,"BOOL");
var Annun = props.globals.getNode("instrumentation/annunciators",1);
var MstrWarn =Annun.getNode("master-warning",1);
var MstrCaution = Annun.getNode("master-caution",1);
var PWR2 =0;
#                                                                                         aircraft.livery.init("Aircraft/CitationX/Models/Liveries");
aircraft.light.new("instrumentation/annunciators", [0.5, 0.5], MstrCaution);
var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 10,1);
var LOHeng= JetEngine.new(0);
var LIHeng= JetEngine.new(1);
var RIHeng= JetEngine.new(2);
var ROHeng= JetEngine.new(3);
var LOMeng= JetEngine.new(4);
var ROMeng= JetEngine.new(5);
#                                                                                         var tire=TireSpeed.new(3,0.430,0.615,0.615);

#######################################

var fdm_init = func(){
    MstrWarn.setBoolValue(0);
    MstrCaution.setBoolValue(0);
    FDM=getprop("/sim/flight-model");
    setprop("controls/engines/N1-limit",95.0);
}

setlistener("/sim/signals/fdm-initialized", func {
    fdm_init();
    settimer(update_systems,2);
});

setlistener("/sim/signals/reinit", func {
    fdm_init();
},0,0);

setlistener("/sim/crashed", func(cr){
    if(cr.getBoolValue()){
    }
},1,0);

setlistener("sim/model/autostart", func(strt){
    if(strt.getBoolValue()){
        Startup();
    }else{
        Shutdown();
    }
},0,0);


setlistener("/sim/freeze/fuel", func(ffr){
    var test=ffr.getBoolValue();
    if(test){
    MstrCaution.setBoolValue(1 * PWR2);
    Annun.getNode("fuel-gauge").setBoolValue(1 * PWR2);
    }else{
    Annun.getNode("fuel-gauge").setBoolValue(0);
    }
},0,0);


var Startup = func{
        setprop("/controls/electric/inverter-switch", 0);
        setprop("/controls/electric/avionics-switch", 0);
	setprop("/controls/switches/fuel", 0);
	setprop("/controls/electric/engine[0]/generator", 0);
	setprop("/controls/electric/engine[1]/generator", 0);
	setprop("/controls/electric/engine[2]/generator", 0);
	setprop("/controls/electric/engine[3]/generator", 0);
	setprop("/controls/electric/engine[4]/generator", 0);
	setprop("/controls/electric/engine[5]/generator", 0);
	setprop("/controls/engines/engine[0]/starter", 0);
	setprop("/controls/engines/engine[1]/starter", 0);
	setprop("/controls/engines/engine[2]/starter", 0);
	setprop("/controls/engines/engine[3]/starter", 0);
	setprop("/controls/engines/engine[4]/starter", 0);
	setprop("/controls/engines/engine[5]/starter", 0);
	setprop("/controls/engines/engine[0]/throttle", 0);
	setprop("/controls/engines/engine[1]/throttle", 0);
	setprop("/controls/engines/engine[2]/throttle", 0);
	setprop("/controls/engines/engine[3]/throttle", 0);
	setprop("/controls/engines/engine[4]/throttle", 0);
	setprop("/controls/engines/engine[5]/throttle", 0);
	setprop("/engines/engine[0]/running", 0);
	setprop("/engines/engine[1]/running", 0);
	setprop("/engines/engine[2]/running", 0);
	setprop("/engines/engine[3]/running", 0);
	setprop("/engines/engine[4]/running", 0);
	setprop("/engines/engine[5]/running", 0);
	setprop("/controls/gear/brake-parking", 1);

	setprop("/controls/electric/battery-switch", 1);
	setprop("/controls/electric/battery-switch[1]", 1);
	setprop("/controls/electric/inverter-switch", 1);
	setprop("/controls/electric/avionics-switch", 1);
	setprop("/controls/electric/engine[0]/generator", 1);
	setprop("/controls/electric/engine[1]/generator", 1);
	setprop("/controls/electric/engine[2]/generator", 1);
	setprop("/controls/electric/engine[3]/generator", 1);
	setprop("/controls/electric/engine[4]/generator", 1);
	setprop("/controls/electric/engine[5]/generator", 1);
        setprop("/controls/switches/gauge-light", 1);
        setprop("/controls/lighting/nav-lights", 1);
	setprop("/controls/lighting/beacon", 1);
	
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
	
	setprop("/controls/engines/engine[0]/ignition", 1);
	setprop("/controls/engines/engine[3]/ignition", 1);
	setprop("/controls/engines/engine[1]/ignition", 1);
	setprop("/controls/engines/engine[2]/ignition", 1);
	setprop("/controls/engines/engine[4]/ignition", 1);
	setprop("/controls/engines/engine[5]/ignition", 1);
        
	interpolate("/controls/engines/engine[0]/starter", 1, 16, 0, 1);
	interpolate("/controls/engines/engine[5]/starter", 0, 16, 1, 16, 0, 1);
	interpolate("/controls/engines/engine[1]/starter", 0, 33, 1, 16, 0, 1);
	interpolate("/controls/engines/engine[4]/starter", 0, 50, 1, 16, 0, 1);
	interpolate("/controls/engines/engine[2]/starter", 0, 67, 1, 16, 0, 1);
	interpolate("/controls/engines/engine[3]/starter", 0, 84, 1, 16, 0, 1);
	
	interpolate("controls/engines/engine[0]/throttle", 0.13, 17);
	interpolate("controls/engines/engine[5]/throttle", 0, 17, 0.13, 17);
	interpolate("controls/engines/engine[1]/throttle", 0, 34, 0.13, 17);
	interpolate("controls/engines/engine[4]/throttle", 0, 51, 0.13, 17);
	interpolate("controls/engines/engine[2]/throttle", 0, 68, 0.13, 17);
	interpolate("controls/engines/engine[3]/throttle", 0, 85, 0.13, 17);
	
	setprop("sim/messages/copilot", "Engines 1-6 starting up, wait 102 seconds till idle position");
	setprop("sim/messages/copilot", "Press < to control all engine lamps going to green");
}

var Shutdown = func{
    setprop("sim/messages/copilot", "Shuting down everyting!");
    setprop("controls/electric/engine[0]/generator",0);
    setprop("controls/electric/engine[1]/generator",0);
    setprop("controls/electric/engine[2]/generator",0);
    setprop("controls/electric/engine[3]/generator",0);
    setprop("controls/electric/engine[4]/generator",0);
    setprop("controls/electric/engine[5]/generator",0);
    setprop("controls/electric/avionics-switch",0);
    setprop("controls/electric/battery-switch",0);
    setprop("controls/electric/battery-switch[1]",0);
    setprop("controls/electric/inverter-switch",0);
    setprop("controls/lighting/instrument-lights",0);
    setprop("controls/lighting/nav-lights",0);
    setprop("controls/lighting/beacon",0);
    setprop("controls/lighting/strobe",0);
    setprop("/controls/switches/gauge-light", 0);
    setprop("/instrumentation/adf[0]/power-btn", 0);
    setprop("/instrumentation/adf[1]/power-btn", 0);
    setprop("/instrumentation/heading-indicator[0]/serviceable", 0);
    setprop("/instrumentation/nav[0]/power-btn", 0);
    setprop("/instrumentation/nav[1]/power-btn", 0);
    setprop("/instrumentation/transponder/serviceable", 0);
    setprop("controls/switches/fuel",0);
    setprop("controls/engines/engine[0]/cutoff",1);
    setprop("controls/engines/engine[1]/cutoff",1);
    setprop("controls/engines/engine[2]/cutoff",1);
    setprop("controls/engines/engine[3]/cutoff",1);
    setprop("controls/engines/engine[4]/cutoff",1);
    setprop("controls/engines/engine[5]/cutoff",1);
    setprop("controls/engines/engine[0]/ignition",0);
    setprop("controls/engines/engine[1]/ignition",0);
    setprop("controls/engines/engine[2]/ignition",0);
    setprop("controls/engines/engine[3]/ignition",0);
    setprop("controls/engines/engine[4]/ignition",0);
    setprop("controls/engines/engine[5]/ignition",0);
    setprop("engines/engine[0]/running",0);
    setprop("engines/engine[1]/running",0);
    setprop("engines/engine[2]/running",0);
    setprop("engines/engine[3]/running",0);
    setprop("engines/engine[4]/running",0);
    setprop("engines/engine[5]/running",0);
}

var FHupdate = func(tenths){
        var fmeter = getprop("/instrumentation/clock/flight-meter-sec");
        var fhour = fmeter/3600;
        setprop("instrumentation/clock/flight-meter-hour",fhour);
        var fmin = fhour - int(fhour);
        if(tenths !=0){
            fmin *=100;
        }else{
            fmin *=60;
        }
        setprop("instrumentation/clock/flight-meter-min",int(fmin));
    }

########## MAIN ##############

var update_systems = func{
    LOHeng.update();
    LIHeng.update();        
    RIHeng.update();
    ROHeng.update();
    LOMeng.update();
    ROMeng.update();
    FHupdate(0);

settimer(update_systems,0);
}

#################################################################################
