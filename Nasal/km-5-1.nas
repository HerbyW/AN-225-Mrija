#
# NASAL instruments for TU-154B
# Yurik V. Nikiforoff, yurik.nsk@gmail.com
# Novosibirsk, Russia
# jun 2007, dec 2013
#
#    ###################################################################################
#    Antonov-Aircrafts and SpaceShuttle :: Herbert Wagner November2014-March2015
#    Development is ongoing, see latest version: www.github.com/HerbyW
#    This file is licenced under the terms of the GNU General Public Licence V3 or later
#    
#    Firefly: 3D model improvment: ruder, speedbreak, ailerions, all gears and doors
#    Eagel: Liveries
#    ###################################################################################

######################################################################


#
# UShDB
#
#
# Utility classes and functions.
#

# Before anything else change random seed.
srand();


# Chase() works like interpolate(), but tracks value changes, supports
# wraparound, and allows cancellation.
var Chase = {
    _active: {},
    deactivate: func(src) {
        var m = Chase._active[src];
        if (m != nil)
            m.del();
    },
    new: func(src, dst, delay, wrap=nil) {
        var m = {
            parents: [Chase],
            src: src,
            dst: dst,
            left: delay,
            wrap: wrap,
            ts: systime()
        };
        Chase.deactivate(src);
        Chase._active[src] = m;
        m.t = maketimer(0, m, Chase._update);
        m.t.start();
        return m;
    },
    active: func {
        return (Chase._active[me.src] == me);
    },
    del: func {
        Chase._active[me.src] = nil;
        me.t.stop();
    },
    _update: func {
        var ts = systime();
        var passed = ts - me.ts;
        var dv = (num(me.dst) == nil ? getprop(me.dst) : me.dst);
        if (me.left > passed) {
            var sv = getprop(me.src);
            if (dv == nil)
                dv = sv;
            var delta = dv - sv;
            var w = (me.wrap != nil
                     and abs(delta) > (me.wrap[1] - me.wrap[0]) / 2.0);
            if (w) {
                if (sv < dv)
                    delta -= me.wrap[1] - me.wrap[0];
                else
                    delta += me.wrap[1] - me.wrap[0];
            }
            var nsv = sv + delta * passed / me.left;
            if (w) {
                if (sv < dv)
                    nsv += (nsv < me.wrap[0] ? me.wrap[1] : 0);
                else
                    nsv -= (nsv >= me.wrap[1] ? me.wrap[1] : 0);
            }
            setprop(me.src, nsv);
            me.ts = ts;
            me.left -= passed;
        } else {
            setprop(me.src, dv);
            me.t.stop();
        }
    }
};

# Smooth property re-aliasing.
var realias = func(src, dst, delay, wrap=nil) {
    if (src == dst)
        return;

    var obj = props.globals.getNode(src, 1);
    var v = getprop(src);
    obj.unalias();
    if (v != nil and delay > 0) {
        setprop(src, v);
        var c = Chase.new(src, dst, delay, wrap);
        settimer(func {
            if (c.active()) {
                c.del();
                if (num(dst) == nil)
                    obj.alias(dst);
                else
                    setprop(src, dst);setprop("instrumentation/ushdb/heading-deg-"~b, bearing);
                    setprop("instrumentation/iku/heading-deg-"~b,  bearing);
            }
        }, delay);
    } else {
        Chase.deactivate(src);
        if (num(dst) == nil)
            obj.alias(dst);
        else
            setprop(src, dst);
    }
}






var ushdb_mode_update = func(b) {
    var sel = getprop("controls/switches/ushdb-sel-"~b);
    if (int(sel) != sel) # The switch is in transition.
        return;
    var bearing = 90;
    
    var bearing1 = 0;
    var bearing2 = 0;
    
    var j = b - 1;
    if (sel) {
        if (getprop("instrumentation/nav["~j~"]/in-range"))
            var bearing1 = getprop("instrumentation/nav["~j~"]/radials/reciprocal-radial-deg");
	    var bearing2 = getprop("orientation/heading-deg");
	    bearing = bearing1 - bearing2;

    } else {
        if (getprop("instrumentation/adf["~j~"]/in-range"))
            bearing = getprop("instrumentation/adf["~j~"]/indicated-bearing-deg");

    }

    setprop("instrumentation/ushdb/heading-deg-"~b, bearing);
    setprop("instrumentation/iku/heading-deg-"~b,  bearing);
    
#    realias("instrumentation/ushdb/heading-deg-"~b, bearing, 0.1, [0, 360]);
#    realias("instrumentation/iku/heading-deg-"~b, bearing, 0.1, [0, 360]);
}


var ushdb_mode1_update = func {
    ushdb_mode_update(1);
}

var ushdb_mode2_update = func {
    ushdb_mode_update(2);
}


setlistener("instrumentation/adf[0]/in-range", ushdb_mode1_update, 0, 0);
setlistener("instrumentation/nav[0]/in-range", ushdb_mode1_update, 0, 0);
setlistener("instrumentation/nav[0]/nav-loc", ushdb_mode1_update, 0, 0);
setlistener("instrumentation/adf[1]/in-range", ushdb_mode2_update, 0, 0);
setlistener("instrumentation/nav[1]/in-range", ushdb_mode2_update, 0, 0);
setlistener("instrumentation/nav[1]/nav-loc", ushdb_mode2_update, 0, 0);
setlistener("instrumentation/nav[0]/radials/reciprocal-radial-deg", ushdb_mode1_update, 1);
setlistener("instrumentation/nav[1]/radials/reciprocal-radial-deg", ushdb_mode2_update, 1);
setlistener("instrumentation/adf[0]/indicated-bearing-deg", ushdb_mode1_update, 1);
setlistener("instrumentation/adf[1]/indicated-bearing-deg", ushdb_mode2_update, 1);
setlistener("controls/switches/ushdb-sel-1", ushdb_mode1_update, 1);
setlistener("controls/switches/ushdb-sel-2", ushdb_mode2_update, 1);






# ************************* TKS staff ***********************************

# TKS power support

# setprop("controls/switches/TKC-power-1", 1);
# setprop("controls/switches/TKC-power-2", 1);
# setprop("controls/switches/TKC-BGMK-1", 1);
# setprop("controls/switches/TKC-BGMK-2", 1);

# auto corrector for GA-3 and BGMK
var tks_corr = func{
var mk1 = getprop("fdm/jsbsim/instrumentation/km-5-1");
if( mk1 == nil ) return;
var mk2 = getprop("fdm/jsbsim/instrumentation/km-5-2");
if( mk2 == nil ) return;
help.tks();	# show help string
if( getprop("controls/switches/pu-11-gpk") == 1 ) { # GA-3 correction
# parameters GA-3
   var gpk_1 = getprop("fdm/jsbsim/instrumentation/ga3-corrected-1");
   var gpk_2 = getprop("fdm/jsbsim/instrumentation/ga3-corrected-2");
   if( gpk_1 == nil ) return;
   if( gpk_2 == nil ) return;
   if( getprop("controls/switches/pu-11-corr") == 0 ) # kontr
	{
	if( getprop("instrumentation/heading-indicator[1]/serviceable" ) != 1 ) return;
	var delta = gpk_2 - mk2;
	if( abs( delta ) < 0.5 ) return; 		# not adjust small values
	if( delta > 360.0 ) delta = delta - 360.0;	# bias control
	if( delta < 0.0 ) delta = delta + 360.0;
	if( delta > 180 ) delta = 0.5; else delta = -0.5;# find short way	
	var offset = getprop("instrumentation/heading-indicator[1]/offset-deg");
	if( offset == nil ) return;
	setprop("instrumentation/heading-indicator[1]/offset-deg", offset+delta );
	return;
	}
else	{ # osn
	if( getprop("instrumentation/heading-indicator[0]/serviceable" ) != 1 ) return;
	var delta = gpk_1 - mk1;
	if( abs( delta ) < 1.0 ) return; 		# not adjust small values
	if( delta > 360.0 ) delta = delta - 360.0;	# bias control
	if( delta < 0.0 ) delta = delta + 360.0;
	if( delta > 180 ) delta = 0.5; else delta = -0.5;# find short way	
	var offset = getprop("instrumentation/heading-indicator[0]/offset-deg");
	if( offset == nil ) return;
	setprop("instrumentation/heading-indicator[0]/offset-deg", offset+delta );
	return;
	}
   } # end GA-3 correction
   if( getprop("controls/switches/pu-11-gpk") == 0 ) { # BGMK correction
# parameters BGMK
   if( getprop("controls/switches/pu-11-corr") == 0 ) # BGMK-2
	{
        setprop("fdm/jsbsim/instrumentation/bgmk-corrector-2",1);
	}
else	{ # BGMK-1
        setprop("fdm/jsbsim/instrumentation/bgmk-corrector-1",1);
	} 
   } # end BGMK correction
}

# manually adjust gyro heading - GA-3 only
tks_adj = func{
if( getprop("controls/switches/pu-11-gpk") != 0 ) return;
help.tks();	# show help string
var delta = 0.1;
if( getprop("controls/switches/pu-11-corr") == 0 ) # kontr
	{
	if( getprop("instrumentation/heading-indicator[1]/serviceable" ) != 1 ) return;
	if( arg[0] == 1 ) # to right
		{
		var offset = getprop("instrumentation/heading-indicator[1]/offset-deg");
		if( offset == nil ) return;
		setprop("instrumentation/heading-indicator[1]/offset-deg", offset+delta );
		return;
		}
	else	{ # to left
		var offset = getprop("instrumentation/heading-indicator[1]/offset-deg");
		if( offset == nil ) return;
		setprop("instrumentation/heading-indicator[1]/offset-deg", offset-delta );
		return;
		}
	}
else	{	# osn
	 if( getprop("instrumentation/heading-indicator[0]/serviceable" ) != 1 ) return;
	if( arg[0] == 1 ) # to right
		{
		var offset = getprop("instrumentation/heading-indicator[0]/offset-deg");
		if( offset == nil ) return;
		setprop("instrumentation/heading-indicator[0]/offset-deg", offset+delta );
		return;
		}
	else	{ # to left
		var offset = getprop("instrumentation/heading-indicator[0]/offset-deg");
		if( offset == nil ) return;
		setprop("instrumentation/heading-indicator[0]/offset-deg", offset-delta );
		return;
		}

	}
}


# Aug 2009
# Azimuthal error for gyroscope

var last_point = geo.Coord.new();
var current_point = geo.Coord.new();

# Initialise
last_point = geo.aircraft_position();
current_point = last_point;
setprop("/fdm/jsbsim/instrumentation/az-err", 0.0 );

# Azimuth error handler
var tks_az_handler = func{
settimer(tks_az_handler, 60.0 );
current_point = geo.aircraft_position();
if( last_point.distance_to( current_point ) < 1000.0 ) return; # skip small distance

az_err = getprop("/fdm/jsbsim/instrumentation/az-err" );
var zipu = last_point.course_to( current_point );
var ozipu = current_point.course_to( last_point );
az_err += zipu - (ozipu - 180.0);
if( az_err > 180.0 ) az_err -= 360.0;
if( -180.0 > az_err ) az_err += 360.0;
setprop("/fdm/jsbsim/instrumentation/az-err", az_err );
last_point = current_point;
}

settimer(tks_az_handler, 60.0 );


# ********************************* End TKS staff ***********************************


#
#  KURS-MP frequency support
#

# setprop("controls/switches/KURS-MP-1", 1);
# setprop("controls/switches/KURS-MP-2", 1);
setprop("/instrumentation/nav[0]/power-btn", 0);
setprop("/instrumentation/nav[1]/power-btn", 0);


var kursmp_sync = func{
var frequency = 0.0;
var heading = 0.0;
if( arg[0] == 0 )	# proceed captain panel
	{ #frequency
	var freq_hi = getprop("instrumentation/kurs-mp-1/digit-f-hi");
	if( freq_hi == nil ) return;
	var freq_low = getprop("instrumentation/kurs-mp-1/digit-f-low");
	if( freq_low == nil ) return;
	frequency = freq_hi + freq_low/100.0;
	setprop("instrumentation/nav[0]/frequencies/selected-mhz", frequency );
	# heading
	var hdg_ones = getprop("instrumentation/kurs-mp-1/digit-h-ones");
	if( hdg_ones == nil ) return;
	var hdg_dec = getprop("instrumentation/kurs-mp-1/digit-h-dec");
	if( hdg_dec == nil ) return;
	var hdg_hund = getprop("instrumentation/kurs-mp-1/digit-h-hund");
	if( hdg_hund == nil ) return;
	heading = hdg_hund * 100 + hdg_dec * 10 + hdg_ones;
	if( heading > 359.0 ) { 
		heading = 0.0;
                setprop("instrumentation/kurs-mp-1/digit-h-hund", 0.0 );
                setprop("instrumentation/kurs-mp-1/digit-h-dec", 0.0 );
                setprop("instrumentation/kurs-mp-1/digit-h-ones", 0.0 );
		}
	setprop("instrumentation/nav[0]/radials/selected-deg", heading );
	return;
	}
if( arg[0] == 1 ) # co-pilot
	{ #frequency
	var freq_hi = getprop("instrumentation/kurs-mp-2/digit-f-hi");
	if( freq_hi == nil ) return;
	var freq_low = getprop("instrumentation/kurs-mp-2/digit-f-low");
	if( freq_low == nil ) return;
	frequency = freq_hi + freq_low/100.0;
	setprop("instrumentation/nav[1]/frequencies/selected-mhz", frequency );
	# heading
	var hdg_ones = getprop("instrumentation/kurs-mp-2/digit-h-ones");
	if( hdg_ones == nil ) return;
	var hdg_dec = getprop("instrumentation/kurs-mp-2/digit-h-dec");
	if( hdg_dec == nil ) return;
	var hdg_hund = getprop("instrumentation/kurs-mp-2/digit-h-hund");
	if( hdg_hund == nil ) return;
	heading = hdg_hund * 100 + hdg_dec * 10 + hdg_ones;
		if( heading > 359.0 ) { 
		heading = 0.0;
                setprop("instrumentation/kurs-mp-2/digit-h-hund", 0.0 );
                setprop("instrumentation/kurs-mp-2/digit-h-dec", 0.0 );
                setprop("instrumentation/kurs-mp-2/digit-h-ones", 0.0 );
		}
	setprop("instrumentation/nav[1]/radials/selected-deg", heading );
	}
}

# initialize KURS-MP frequencies & headings
var kursmp_init = func{
var freq = getprop("instrumentation/nav[0]/frequencies/selected-mhz");
if( freq == nil ) { settimer( kursmp_init, 1.0 ); return; } # try until success
setprop("instrumentation/kurs-mp-1/digit-f-hi", int(freq) );
setprop("instrumentation/kurs-mp-1/digit-f-low", (freq - int(freq) ) * 100 );
var hdg = getprop("instrumentation/nav[0]/radials/selected-deg");
if( hdg == nil ) { settimer( kursmp_init, 1.0 ); return; }
setprop("instrumentation/kurs-mp-1/digit-h-hund", int(hdg/100) );
setprop("instrumentation/kurs-mp-1/digit-h-dec", int( (hdg/10.0)-int(hdg/100.0 )*10.0) );
setprop("instrumentation/kurs-mp-1/digit-h-ones", int(hdg-int(hdg/10.0 )*10.0) );
# second KURS-MP
freq = getprop("instrumentation/nav[1]/frequencies/selected-mhz");
if( freq == nil ) { settimer( kursmp_init, 1.0 ); return; } # try until success
setprop("instrumentation/kurs-mp-2/digit-f-hi", int(freq) );
setprop("instrumentation/kurs-mp-2/digit-f-low", (freq - int(freq) ) * 100 );
hdg = getprop("instrumentation/nav[1]/radials/selected-deg");
if( hdg == nil ) { settimer( kursmp_init, 1.0 ); return; }
setprop("instrumentation/kurs-mp-2/digit-h-hund", int( hdg/100) );
setprop("instrumentation/kurs-mp-2/digit-h-dec",int( ( hdg / 10.0 )-int( hdg / 100.0 ) * 10.0 ) );
setprop("instrumentation/kurs-mp-2/digit-h-ones", int( hdg-int( hdg/10.0 )* 10.0 ) );

}

var kursmp_watchdog_1 = func{
#settimer( kursmp_watchdog_1, 0.5 );
if( getprop("instrumentation/nav[0]/in-range" ) == 1 ) return;
 if( getprop("instrumentation/pn-5/gliss" ) == 1.0 ) absu.absu_reset();
 if( getprop("instrumentation/pn-5/az-1" ) == 1.0 ) absu.absu_reset();
 if( getprop("instrumentation/pn-5/zahod" ) == 1.0 ) absu.absu_reset();
}

var kursmp_watchdog_2 = func{
#settimer( kursmp_watchdog_2, 0.5 );
if( getprop("instrumentation/nav[1]/in-range" ) == 1 ) return;
if( getprop("instrumentation/pn-5/az-2" ) == 1.0 ) absu.absu_reset();
}

setlistener( "instrumentation/nav[0]/in-range", kursmp_watchdog_1, 0,0 );
setlistener( "instrumentation/nav[1]/in-range", kursmp_watchdog_2, 0,0 );

#kursmp_watchdog_1();
#kursmp_watchdog_2();

kursmp_init();

# ******************************** end KURS-MP *******************************



# ARK support setprop("instrumentation/ark-15[0]/powered", 1 );

ark_1_2_handler = func {
	var ones = getprop("instrumentation/ark-15[0]/digit-2-1");
	if( ones == nil ) ones = 0.0;
	var dec = getprop("instrumentation/ark-15[0]/digit-2-2");
	if( dec == nil ) dec = 0.0;
	var hund = getprop("instrumentation/ark-15[0]/digit-2-3");
	if( hund == nil ) hund = 0.0;
	var freq = hund * 100 + dec * 10 + ones;
	if( getprop("controls/switches/adf-1-selector") == 1 )
		setprop("instrumentation/adf[0]/frequencies/selected-khz", freq );
}

ark_1_1_handler = func {
	var ones = getprop("instrumentation/ark-15[0]/digit-1-1");
	if( ones == nil ) ones = 0.0;
	var dec = getprop("instrumentation/ark-15[0]/digit-1-2");
	if( dec == nil ) dec = 0.0;
	var hund = getprop("instrumentation/ark-15[0]/digit-1-3");
	if( hund == nil ) hund = 0.0;
	var freq = hund * 100 + dec * 10 + ones;
	if( getprop("controls/switches/adf-1-selector") == 0 )
		setprop("instrumentation/adf[0]/frequencies/selected-khz", freq );
}

ark_2_2_handler = func {
	var ones = getprop("instrumentation/ark-15[1]/digit-2-1");
	if( ones == nil ) ones = 0.0;
	var dec = getprop("instrumentation/ark-15[1]/digit-2-2");
	if( dec == nil ) dec = 0.0;
	var hund = getprop("instrumentation/ark-15[1]/digit-2-3");
	if( hund == nil ) hund = 0.0;
	var freq = hund * 100 + dec * 10 + ones;
	if( getprop("controls/switches/adf-2-selector") == 1 )
		setprop("instrumentation/adf[1]/frequencies/selected-khz", freq );
}

ark_2_1_handler = func {
	var ones = getprop("instrumentation/ark-15[1]/digit-1-1");
	if( ones == nil ) ones = 0.0;
	var dec = getprop("instrumentation/ark-15[1]/digit-1-2");
	if( dec == nil ) dec = 0.0;
	var hund = getprop("instrumentation/ark-15[1]/digit-1-3");
	if( hund == nil ) hund = 0.0;
	var freq = hund * 100 + dec * 10 + ones;
	if( getprop("controls/switches/adf-2-selector") == 0 )
		setprop("instrumentation/adf[1]/frequencies/selected-khz", freq );
}


ark_1_power = func{
    if( getprop("instrumentation/adf[0]/power-btn") == 1 )
	{
    	if( getprop("controls/switches/gauge-light") > 0 )
		{
	     
	     setprop("instrumentation/adf[0]/serviceable", 1 );
		}
 	else {
	     
	     setprop("instrumentation/adf[0]/serviceable", 0 );
	     }
	} 
   else {
	
	setprop("instrumentation/adf[0]/serviceable", 0 );
	}
}

ark_2_power = func{
    if( getprop("instrumentation/adf[1]/power-btn") == 1 )
	{
    	if( getprop("controls/switches/gauge-light") > 0 )
		{
	     
	     setprop("instrumentation/adf[1]/serviceable", 1 );
		}
 	else {
	     
	     setprop("instrumentation/adf[1]/serviceable", 0 );
		}
	} 
   else {
	
	setprop("instrumentation/adf[1]/serviceable", 0 );
	}
}

nav_1_power = func{
    if( getprop("instrumentation/nav[0]/power-btn") == 1 )
	{
    	if( getprop("controls/switches/gauge-light") > 0 )
		{
	     
	     setprop("instrumentation/nav[0]/serviceable", 1 );
		}
 	else {
	     
	     setprop("instrumentation/nav[0]/serviceable", 0 );
	     }
	} 
   else {
	
	setprop("instrumentation/nav[0]/serviceable", 0 );
	}
}

nav_2_power = func{
    if( getprop("instrumentation/nav[1]/power-btn") == 1 )
	{
    	if( getprop("controls/switches/gauge-light") > 0 )
		{
	     
	     setprop("instrumentation/nav[1]/serviceable", 1 );
		}
 	else {
	     
	     setprop("instrumentation/nav[1]/serviceable", 0 );
		}
	} 
   else {
	
	setprop("instrumentation/nav[1]/serviceable", 0 );
	}
}



# read selected and standby ADF frequencies and copy it to ARK
ark_init = func{
var freq = getprop("instrumentation/adf[0]/frequencies/selected-khz");
if( freq == nil ) freq = 0.0;
setprop("instrumentation/ark-15[0]/digit-1-3", 
int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
setprop("instrumentation/ark-15[0]/digit-1-2", 
int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
setprop("instrumentation/ark-15[0]/digit-1-1", 
int( freq - int( freq/10.0 )*10.0 ) );

freq = getprop("instrumentation/adf[0]/frequencies/standby-khz");
if( freq == nil ) freq = 0.0;
setprop("instrumentation/ark-15[0]/digit-2-3", 
int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
setprop("instrumentation/ark-15[0]/digit-2-2", 
int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
setprop("instrumentation/ark-15[0]/digit-2-1", 
int( freq - int( freq/10.0 )*10.0 ) );

freq = getprop("instrumentation/adf[1]/frequencies/selected-khz");
if( freq == nil ) freq = 0.0;
setprop("instrumentation/ark-15[1]/digit-1-3", 
int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
setprop("instrumentation/ark-15[1]/digit-1-2", 
int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
setprop("instrumentation/ark-15[1]/digit-1-1", 
int( freq - int( freq/10.0 )*10.0 ) );

freq = getprop("instrumentation/adf[1]/frequencies/standby-khz");
if( freq == nil ) freq = 0.0;
setprop("instrumentation/ark-15[1]/digit-2-3", 
int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
setprop("instrumentation/ark-15[1]/digit-2-2", 
int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
setprop("instrumentation/ark-15[1]/digit-2-1", 
int( freq - int( freq/10.0 )*10.0 ) );

}

ark_init();

setlistener("controls/switches/gauge-light", ark_1_power ,0,0);
setlistener("controls/switches/gauge-light", ark_2_power ,0,0);
setlistener("controls/switches/gauge-light", nav_1_power ,0,0);
setlistener("controls/switches/gauge-light", nav_2_power ,0,0);
setlistener("instrumentation/adf[0]/power-btn", ark_1_power ,0,0);
setlistener("instrumentation/adf[1]/power-btn", ark_2_power ,0,0);
setlistener("instrumentation/nav[0]/power-btn", nav_1_power ,0,0);
setlistener("instrumentation/nav[1]/power-btn", nav_2_power ,0,0);

setlistener( "controls/switches/adf-1-selector", ark_1_1_handler ,0,0);
setlistener( "controls/switches/adf-1-selector", ark_1_2_handler ,0,0);

setlistener( "controls/switches/adf-2-selector", ark_2_1_handler ,0,0);
setlistener( "controls/switches/adf-2-selector", ark_2_2_handler ,0,0);

setlistener( "instrumentation/ark-15[0]/digit-1-1", ark_1_1_handler ,0,0);
setlistener( "instrumentation/ark-15[0]/digit-1-2", ark_1_1_handler ,0,0);
setlistener( "instrumentation/ark-15[0]/digit-1-3", ark_1_1_handler ,0,0);

setlistener( "instrumentation/ark-15[0]/digit-2-1", ark_1_2_handler ,0,0);
setlistener( "instrumentation/ark-15[0]/digit-2-2", ark_1_2_handler ,0,0);
setlistener( "instrumentation/ark-15[0]/digit-2-3", ark_1_2_handler ,0,0);

setlistener( "instrumentation/ark-15[1]/digit-1-1", ark_2_1_handler ,0,0);
setlistener( "instrumentation/ark-15[1]/digit-1-2", ark_2_1_handler ,0,0);
setlistener( "instrumentation/ark-15[1]/digit-1-3", ark_2_1_handler ,0,0);

setlistener( "instrumentation/ark-15[1]/digit-2-1", ark_2_2_handler ,0,0);
setlistener( "instrumentation/ark-15[1]/digit-2-2", ark_2_2_handler ,0,0);
setlistener( "instrumentation/ark-15[1]/digit-2-3", ark_2_2_handler ,0,0);

