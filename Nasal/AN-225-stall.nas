## Learjet 35-A, stall and overspeed warning
## PH-JBO 20120130p
# modified by Herbert Wagner for TU-160-Blackjack 12/2015

var aoaStall = 9;
setprop("instrumentation/alerts/aoaStall",9);
setprop("instrumentation/alerts/stall",0);

var warning = func {
  
  ## get variables
  var aoa = getprop("orientation/alpha-deg");
  var spoiler = getprop("controls/flight/spoilers") * -2 ;
  var slats = getprop("controls/flight/slats") * 4;
  var flaps = getprop("controls/flight/flaps") * -4;
  var gear = getprop("controls/gear/gear-down") * -0.75;
  var stalling = "false";
  var gearalt = getprop("position/gear-agl-ft");
  var aoaStall = (7 + spoiler + slats + flaps + gear);
## compare and set warning
  if ((aoa!=nil) and (spoiler !=nil) and (flaps!=nil) and (slats!=nil))
    {
        if (aoa>aoaStall)
	{var stalling="true";}
     }
	if ((gearalt!=nil) and ((getprop("gear/gear[0]/wow")!=1) or (getprop("gear/gear[1]/wow")!=1) or (getprop("gear/gear[2]/wow")!=1)))
	{
	setprop("instrumentation/alerts/stall",stalling);
	setprop("instrumentation/alerts/aoaStall",aoaStall);
	}
	else setprop("instrumentation/alerts/stall",0);
	setprop("instrumentation/alerts/aoaStall",aoaStall);
	settimer (warning,0.5);
}

warning();