autotakeoff = func {
  ato_start();      # Initiation stuff.
  ato_mode();       # Take-off/Climb-out mode handler.
  ato_spddep();     # Speed dependent actions.

  # Re-schedule the next loop if the Take-Off function is enabled.
  if(getprop("/autopilot/locks/auto-take-off") != "Enabled") {
#    print("Auto Take-Off disabled");
  } else {
    settimer(autotakeoff, 0.5);
  }
}
#--------------------------------------------------------------------
ato_start = func {
  # This script checks that the ground-roll-heading has been reset
  # (< -999) and that the a/c is on the ground.
  if(getprop("/autopilot/settings/ground-roll-heading-deg") < -999) {
    if(getprop("/position/altitude-agl-ft") < 0.01) {
      hdgdeg = getprop("/orientation/heading-deg");
      setprop("/controls/flight/flaps", 1.0);
      setprop("/autopilot/settings/ground-roll-heading-deg", hdgdeg);
      setprop("/autopilot/settings/true-heading-deg", hdgdeg);
      setprop("/autopilot/settings/target-AoA-deg", 0);
      setprop("/autopilot/settings/target-speed-kt", 320);
      setprop("/autopilot/locks/altitude", "ground-roll");
      setprop("/autopilot/locks/speed", "speed-with-throttle");
      setprop("/autopilot/locks/heading", "wing-leveler");
      setprop("/autopilot/locks/rudder-control", "rudder-hold");
    }
  }
}
#--------------------------------------------------------------------
ato_mode = func {
  # This script sets the auto-takeoff mode and handles the switch
  # to climb-out mode.
  agl = getprop("/position/altitude-agl-ft");
  if(agl > 50) {
    setprop("/autopilot/locks/altitude", "climb-out");
    setprop("/controls/gear/gear-down", "false");
    setprop("/autopilot/locks/rudder-control", "reset");
    interpolate("/controls/flight/rudder", 0, 10);
    if(getprop("/controls/flight/flaps") > 0.99) {
      setprop("/controls/flight/flaps", 0.82);
    }
  } else {
    setprop("/autopilot/locks/altitude", "take-off");
  }
}
#--------------------------------------------------------------------
ato_spddep = func {
  # This script controls speed dependent actions.
  airspeed = getprop("/velocities/airspeed-kt");
  if(airspeed < 170) {
    interpolate("/autopilot/settings/climb-out-pitch-deg", 2.5, 4);
  } else {
    if(airspeed < 180) {
      setprop("/controls/flight/flaps", 0.64);
      interpolate("/autopilot/settings/climb-out-pitch-deg", 3, 4);
    } else {
      if(airspeed < 200) {
        setprop("/controls/flight/flaps", 0.48);
        interpolate("/autopilot/settings/climb-out-pitch-deg", 3.5, 4);
      } else {
        if(airspeed < 220) {
          setprop("/controls/flight/flaps", 0.32);
          interpolate("/autopilot/settings/climb-out-pitch-deg", 4, 4);
        } else {
          if(airspeed < 240) {
            setprop("/controls/flight/flaps", 0.16);
            interpolate("/autopilot/settings/climb-out-pitch-deg", 4.5, 4);
          } else {
            if(airspeed < 250) {
              setprop("/controls/flight/flaps", 0.0);
            } else {
              # Switch to true-heading-hold, Mach-Hold throttle
              # mode, mach-hold-climb mode and disable Take-Off mode.
              setprop("/autopilot/locks/heading", "true-heading-hold");
              setprop("/autopilot/locks/speed", "mach-with-throttle");
              setprop("/autopilot/locks/altitude", "mach-climb");
              setprop("/autopilot/locks/auto-take-off", "Disabled");
              setprop("/autopilot/settings/climb-out-pitch-deg", 1.0);
            }
          }
        }
      }
    }
  }
}
#--------------------------------------------------------------------
autoland = func {
  agl = getprop("/position/altitude-agl-ft");
  hdgdeg = getprop("/orientation/heading-deg");
  
  if(agl > 150) {
    # Glide Slope phase.
    atl_heading();
    atl_spddep();
    
  } else {
    # Touch Down phase.
    atl_touchdown();
  }

  # Re-schedule the next loop if the Landing function is enabled.
  if(getprop("/autopilot/locks/auto-landing") != "Enabled") {
#    print("Auto Landing disabled");
  } else {
    settimer(autoland, 0.5);
  }
}
#--------------------------------------------------------------------
atl_spddep = func {
  # This script handles speed related actions.
  if(getprop("/autopilot/locks/speed") != "speed-with-throttle") {
    setprop("/autopilot/locks/speed", "speed-with-throttle");
  }
  if(getprop("/autopilot/settings/target-speed-kt") > 200) {
    setprop("/autopilot/settings/target-speed-kt", 200);
    setprop("/controls/flight/spoilers", 1);
  }
  airspeed = getprop("/velocities/airspeed-kt");
  if(airspeed < 170) {
    setprop("/controls/flight/spoilers", 0.0);
    if(getprop("/controls/flight/flaps") > 0.99) {
      setprop("/autopilot/locks/auto-flap-control", "Manual");
      setprop("/controls/flight/flaps", 1.0);
    }
  } else {
    if(airspeed < 180) {
      setprop("/controls/flight/spoilers", 0.1);
      setprop("/controls/gear/gear-down", "true");
    } else {
      if(airspeed < 190) {
        setprop("/controls/flight/spoilers", 0.2);
      } else {
        if(airspeed < 200) {
          setprop("/controls/flight/spoilers", 0.3);
        } else {
          if(airspeed < 210) {
            setprop("/controls/flight/spoilers", 0.4);
          } else {
            if(airspeed < 220) {
              setprop("/controls/flight/spoilers", 0.6);
              setprop("/autopilot/locks/AoA-lock", "Engaged");
            } else {
              if(airspeed < 230) {
                setprop("/controls/flight/spoilers", 0.8);
                setprop("/autopilot/locks/auto-flap-control", "Engaged");
              } else {
                if(airspeed < 280) {
                  setprop("/autopilot/locks/altitude", "gs1-hold");
                } else {
                  setprop("/controls/flight/spoilers", 1.0);
                }
              }
            }
          }
        }
      }
    }
  }
}
#--------------------------------------------------------------------
atl_touchdown = func {
  # Touch Down phase.
  agl = getprop("/position/altitude-agl-ft");
  vfps = getprop("/velocities/vertical-speed-fps");
  setprop("/autopilot/settings/target-vfps", vfps);
  setprop("/autopilot/locks/AoA-lock", "Off");

  if(agl < 0.01) {
    # Brakes on, Rudder heading hold on & disable IL mode.
    setprop("/controls/gear/brake-left", 0.04);
    setprop("/controls/gear/brake-right", 0.04);
    setprop("/autopilot/settings/ground-roll-heading-deg", -999.9);
    setprop("/autopilot/locks/auto-landing", "Disabled");
    setprop("/autopilot/locks/auto-take-off", "Enabled");
    setprop("/autopilot/locks/altitude", "Off");
    setprop("/autopilot/settings/target-vfps", 0);
    interpolate("/controls/flight/elevator-trim", 0, 10.0);
  }
  if(agl < 1) {
    setprop("/autopilot/settings/target-vfps", -0.1);
  } else {
    if(agl < 2) {
      setprop("/autopilot/settings/target-vfps", -0.5);
    } else {
      if(agl < 4) {
        setprop("/autopilot/settings/target-vfps", -1);
      } else {
        if(agl < 8) {
          setprop("/autopilot/settings/target-vfps", -2);
          setprop("/autopilot/locks/heading", "Off");
          setprop("/controls/flight/spoilers", 1);
          setprop("/autopilot/locks/speed", "Off");
          setprop("/controls/engines/engine[0]/throttle", 0);
          setprop("/controls/engines/engine[1]/throttle", 0);
          setprop("/controls/engines/engine[2]/throttle", 0);
          setprop("/controls/engines/engine[3]/throttle", 0);
          setprop("/controls/engines/engine[4]/throttle", 0);
          setprop("/controls/engines/engine[5]/throttle", 0);
        } else {
          if(agl < 16) {
            setprop("/autopilot/settings/target-vfps", -3);
          } else {
            if(agl < 20) {
              setprop("/autopilot/settings/target-vfps", -4);
              setprop("/autopilot/locks/heading", "wing-leveler");
            } else {
              if(agl < 40) {
                setprop("/autopilot/settings/target-vfps", -6);
              } else {
                if(agl < 80) {
                  setprop("/autopilot/settings/target-vfps", -8);
                } else {
                  setprop("/autopilot/settings/target-vfps", -9);
                  setprop("/autopilot/locks/altitude", "vfps-hold-ls");
                }
              }
            }
          }
        }
      }
    }
  }
}
#--------------------------------------------------------------------
atl_heading = func {
  # This script handles heading dependent actions.
  hdnddf = getprop("/radios/nav[0]/heading-needle-deflection");
  if(hdnddf < 5) {
    if(hdnddf > -5) {
      setprop("/autopilot/locks/heading", "nav1-hold-fa");
    } else {
      setprop("/autopilot/locks/heading", "nav1-hold");
    }
  } else {
    setprop("/autopilot/locks/heading", "nav1-hold");
  }
}
#--------------------------------------------------------------------
toggle_traj_mkr = func {
  if(getprop("ai/submodels/trajectory-markers") < 1) {
    setprop("ai/submodels/trajectory-markers", 1);
  } else {
    setprop("ai/submodels/trajectory-markers", 0);
  }
}
#--------------------------------------------------------------------
