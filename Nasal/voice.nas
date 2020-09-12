# Variation from tu-154b wit own sounds for AN-225 by HerbyW 09/2020
setprop("systems/altitude", 0);

var voice_handler = func{
settimer( voice_handler, 0.0 ); # no need delay for voise

var alt = getprop( "position/gear-agl-m" );
if( alt == nil ) alt = 0.0;

# We count altitude for landing only...
if( getprop( "velocities/speed-down-fps" ) < 0.0 ) { return; }
# ...and for fly
if( getprop( "gear/gear[0]/wow" ) == 1 ) { return; }
if( getprop( "gear/gear[5]/wow" ) == 1 ) { return; }
if( getprop( "gear/gear[10]/wow" ) == 1 ) { return; }


if( alt < 55.0 )
	if( alt > 53.0 )
		setprop( "systems/altitude", 55.0 );
if( alt < 60.0 )
	if( alt > 58.0 )
		setprop( "systems/altitude", 60.0 );

if( alt < 100.0 )
	if( alt > 98.0 )
		setprop( "systems/altitude", 100.0 );

if( alt < 150.0 )
	if( alt > 148.0 )
		setprop( "systems/altitude", 150.0 );

if( alt < 300.0 )
	if( alt > 298.0 )
		setprop( "systems/altitude", 300.0 );
if( alt < 330.0 )
	if( alt > 328.0 )
		setprop( "systems/altitude", 330.0 );

}

voice_handler();
