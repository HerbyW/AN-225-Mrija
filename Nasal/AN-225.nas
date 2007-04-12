autotakeoff = func {
  ato_start();      # Initiation stuff.
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
      setprop("/autopilot/settings/target-climb-rate-fps", 30);
      setprop("/autopilot/settings/target-speed-kt", 320);
      setprop("/autopilot/locks/auto-take-off", "engaged");
      setprop("/autopilot/locks/altitude", "pitch-hold");
      setprop("/autopilot/locks/speed", "speed-with-throttle");
      setprop("/autopilot/locks/rudder-control", "rudder-hold");
      setprop("/autopilot/internal/target-roll-deg-unfiltered", 0);

      # Initialise the climb-out settings.
      toiptdeg = getprop("/autopilot/settings/take-off-initial-pitch-deg");
      setprop("/autopilot/settings/target-pitch-deg", toiptdeg);
      ato_mainloop();   # Main loop
    }
  }
}
#--------------------------------------------------------------------
ato_mainloop = func {
  ato_mode();
  ato_spddep();

  # Re-schedule the next loop if the Take-Off function is engaged.
  if(getprop("/autopilot/locks/auto-take-off") != "engaged") {
#    print("Auto Take-Off disabled");
  } else {
    settimer(ato_mainloop, 0.2);
  }
}
#--------------------------------------------------------------------
ato_mode = func {
  # This script sets the auto-takeoff mode and handles the switch
  # to climb-out mode.
  agl = getprop("/position/altitude-agl-ft");
  if(agl > 50) {
    tofptdeg = getprop("/autopilot/settings/take-off-final-pitch-deg");
    copttsec = getprop("/autopilot/settings/climb-out-pitch-trans-time-sec");
    interpolate("/autopilot/settings/target-pitch-deg", tofptdeg, copttsec);
    setprop("/controls/gear/gear-down", "false");
    setprop("/autopilot/locks/rudder-control", "reset");

    interpolate("/controls/flight/rudder", 0, 10);

    if(getprop("/controls/flight/flaps") > 0.99) {
      setprop("/controls/flight/flaps", 0.82);
    }
  }
}
#--------------------------------------------------------------------
ato_spddep = func {
  # This script controls speed dependent actions.
  airspeed = getprop("/velocities/airspeed-kt");
  if(airspeed < 50) {
    # Do nothing until airspeed > 50 kts
  } else {
    if(airspeed < 180) {
      setprop("/autopilot/locks/heading", "wing-leveler");
    } else {
      if(airspeed < 190) {
        setprop("/controls/flight/flaps", 0.64);
      } else {
        if(airspeed < 200) {
          setprop("/controls/flight/flaps", 0.48);
        } else {
          if(airspeed < 220) {
            setprop("/controls/flight/flaps", 0.32);
          } else {
            if(airspeed < 240) {
              setprop("/controls/flight/flaps", 0.16);
            } else {
              if(airspeed < 250) {
                setprop("/controls/flight/flaps", 0.0);
              } else {
                setprop("/autopilot/locks/heading", "true-heading-hold");
                setprop("/autopilot/locks/speed", "mach-with-throttle");
                setprop("/autopilot/locks/altitude", "mach-climb");
                setprop("/autopilot/locks/auto-take-off", "disabled");
              }
            }
          }
        }
      }
    }
  }
}
#--------------------------------------------------------------------
autoland = func {
  atl_initiation();
  atl_mainloop();
}
#--------------------------------------------------------------------
atl_initiation = func {

  if(getprop("/autopilot/locks/auto-landing") == "enabled") {
    setprop("/autopilot/locks/auto-landing", "engaged");
  }
}
#--------------------------------------------------------------------
atl_mainloop = func {
  agl = getprop("/position/altitude-agl-ft");
  
  if(agl > 300) {
    # Glide Slope phase.
    atl_heading();
    atl_spddep();
    atl_glideslope();
    
  } else {
    # Touch Down phase.
    atl_touchdown();
  }

  if(getprop("/autopilot/locks/auto-landing") == "engaged") {
    settimer(atl_mainloop, 0.2);
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
  }

  airspeed = getprop("/velocities/airspeed-kt");
  if(airspeed < 170) {
    setprop("/controls/flight/spoilers", 0.0);
    if(getprop("/controls/flight/flaps") > 0.99) {
      setprop("/autopilot/locks/auto-flap-control", "manual");
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
          setprop("/controls/flight/spoilers", 0.4);
        } else {
          if(airspeed < 210) {
            setprop("/controls/flight/spoilers", 0.6);
            tgtaoadeg = getprop("/autopilot/settings/approach-aoa-deg");
            setprop("/autopilot/settings/target-aoa-deg", tgtaoadeg);
            setprop("/autopilot/locks/aoa", "aoa-with-speed");
          } else {
            if(airspeed < 220) {
              setprop("/controls/flight/spoilers", 1.0);
            } else {
              if(airspeed < 230) {
                setprop("/controls/flight/spoilers", 1.0);
                setprop("/autopilot/locks/auto-flap-control", "engaged");
              } else {
                if(airspeed < 280) {
                  setprop("/autopilot/settings/target-climb-rate-fps", 0);
                } else {
                  setprop("/controls/flight/spoilers", 0.4);
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
atl_glideslope = func {
  # This script handles glide slope interception.
  setprop("/autopilot/locks/altitude", "vfps-hold");
  if(getprop("/position/altitude-agl-ft") > 300) {
    if(getprop("/instrumentation/nav[0]/gs-rate-of-climb") < 0) {
      gsvfps = getprop("/instrumentation/nav[0]/gs-rate-of-climb");
      setprop("/autopilot/settings/target-climb-rate-fps", gsvfps);
    } else {
      setprop("/autopilot/settings/target-climb-rate-fps", 2);
    }
  }
}
#--------------------------------------------------------------------
atl_touchdown = func {
  # Touch Down phase.
  agl = getprop("/position/altitude-agl-ft");
  vfps = getprop("/velocities/vertical-speed-fps");
  setprop("/autopilot/locks/heading", "");
  setprop("/autopilot/locks/aoa", "off");

  if(agl < 0.01) {
    # Brakes on, Rudder heading hold on & disable IL mode.
    setprop("/controls/gear/brake-left", 0.04);
    setprop("/controls/gear/brake-right", 0.04);
    setprop("/autopilot/settings/ground-roll-heading-deg", -999.9);
    setprop("/autopilot/locks/auto-landing", "disabled");
    setprop("/autopilot/locks/auto-take-off", "enabled");
    setprop("/autopilot/locks/altitude", "Off");
    setprop("/autopilot/settings/target-climb-rate-fps", -1.0);
    interpolate("/controls/flight/elevator-trim", 0, 10.0);
  }
  if(agl < 1) {
    setprop("/autopilot/settings/target-climb-rate-fps", -1);
  } else {
    if(agl < 5) {
      setprop("/autopilot/settings/target-climb-rate-fps", -2);
    } else {
      if(agl < 10) {
        setprop("/autopilot/settings/target-climb-rate-fps", -3);
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
        if(agl < 20) {
          setprop("/autopilot/settings/target-climb-rate-fps", -4);
        } else {
          if(agl < 30) {
            setprop("/autopilot/settings/target-climb-rate-fps", -5);
          } else {
            if(agl < 60) {
              if(vfps < -9) {
                setprop("/autopilot/settings/target-climb-rate-fps", -6);
              }
            } else {
              if(agl < 100) {
                if(vfps < -10) {
                  setprop("/autopilot/settings/target-climb-rate-fps", -8);
                }
              } else {
                if(agl < 140) {
                  if(vfps < -11) {
                    setprop("/autopilot/settings/target-climb-rate-fps", -10);
                  }
                } else {
                  if(vfps < -13) {
                    setprop("/autopilot/settings/target-climb-rate-fps", -13);
                  }
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
  hdnddf = getprop("/autopilot/internal/heading-needle-deflection-filtered[1]");
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
ap_common_elevator_monitor = func {
  curr_ah_state = getprop("/autopilot/locks/altitude");

  if(curr_ah_state == "altitude-hold") {
    setprop("/autopilot/locks/common-elevator-control", "engaged");
    setprop("/autopilot/locks/ce-altitude-hold", "engaged");
    setprop("/autopilot/locks/ce-aoa-hold", "off");
    setprop("/autopilot/locks/ce-mach-climb-hold", "off");
    setprop("/autopilot/locks/ce-pitch-hold", "off");
    setprop("/autopilot/locks/ce-agl-hold", "off");
    setprop("/autopilot/locks/ce-vfps-hold", "engaged");
  } else {
    if(curr_ah_state == "agl-hold") {
      setprop("/autopilot/locks/common-elevator-control", "engaged");
      setprop("/autopilot/locks/ce-altitude-hold", "off");
      setprop("/autopilot/locks/ce-aoa-hold", "off");
      setprop("/autopilot/locks/ce-mach-climb-hold", "off");
      setprop("/autopilot/locks/ce-pitch-hold", "off");
      setprop("/autopilot/locks/ce-agl-hold", "engaged");
      setprop("/autopilot/locks/ce-vfps-hold", "engaged");
    } else {
      if(curr_ah_state == "mach-climb") {
        setprop("/autopilot/locks/common-elevator-control", "engaged");
        setprop("/autopilot/locks/ce-altitude-hold", "off");
        setprop("/autopilot/locks/ce-aoa-hold", "off");
        setprop("/autopilot/locks/ce-mach-climb-hold", "engaged");
        setprop("/autopilot/locks/ce-pitch-hold", "off");
        setprop("/autopilot/locks/ce-agl-hold", "off");
        setprop("/autopilot/locks/ce-vfps-hold", "engaged");
      } else {
        if(curr_ah_state == "vfps-hold") {
          setprop("/autopilot/locks/common-elevator-control", "engaged");
          setprop("/autopilot/locks/ce-altitude-hold", "off");
          setprop("/autopilot/locks/ce-aoa-hold", "off");
          setprop("/autopilot/locks/ce-mach-climb-hold", "off");
          setprop("/autopilot/locks/ce-pitch-hold", "off");
          setprop("/autopilot/locks/ce-agl-hold", "off");
          setprop("/autopilot/locks/ce-vfps-hold", "engaged");
        } else {
          if(curr_ah_state == "pitch-hold") {
            setprop("/autopilot/locks/common-elevator-control", "engaged");
            setprop("/autopilot/locks/ce-altitude-hold", "off");
            setprop("/autopilot/locks/ce-aoa-hold", "off");
            setprop("/autopilot/locks/ce-mach-climb-hold", "off");
            setprop("/autopilot/locks/ce-pitch-hold", "engaged");
            setprop("/autopilot/locks/ce-agl-hold", "off");
            setprop("/autopilot/locks/ce-vfps-hold", "off");
          } else {
            setprop("/autopilot/locks/common-elevator-control", "off");
            setprop("/autopilot/locks/ce-altitude-hold", "off");
            setprop("/autopilot/locks/ce-aoa-hold", "off");
            setprop("/autopilot/locks/ce-mach-climb-hold", "off");
            setprop("/autopilot/locks/ce-pitch-hold", "off");
            setprop("/autopilot/locks/ce-agl-hold", "off");
            setprop("/autopilot/locks/ce-vfps-hold", "off");
          }
        }
      }
    }
  } 
  settimer(ap_common_elevator_monitor, 0.5);
}
#--------------------------------------------------------------------
ap_common_aileron_monitor = func {
  curr_hd_state = getprop("/autopilot/locks/heading");

  if(curr_hd_state == "wing-leveler") {
    setprop("/autopilot/locks/common-aileron-control", "engaged");
    setprop("/autopilot/internal/target-roll-deg-unfiltered", 0);
  } else {
    if(curr_hd_state == "true-heading-hold") {
      setprop("/autopilot/locks/common-aileron-control", "engaged");
    } else {
      if(curr_hd_state == "dg-heading-hold") {
        setprop("/autopilot/locks/common-aileron-control", "engaged");
      } else {
        if(curr_hd_state == "nav1-hold") {
          setprop("/autopilot/locks/common-aileron-control", "engaged");
        } else {
          if(curr_hd_state == "nav1-hold-fa") {
            setprop("/autopilot/locks/common-aileron-control", "engaged");
          } else {
            setprop("/autopilot/locks/common-aileron-control", "off");
          }
        }
      }
    }
  } 
  settimer(ap_common_aileron_monitor, 0.5);
}
#--------------------------------------------------------------------
toggle_traj_mkr = func {
  if(getprop("/ai/submodels/trajectory-markers") == nil) {
    setprop("/ai/submodels/trajectory-markers", 0);
  }
  if(getprop("/ai/submodels/trajectory-markers") < 1) {
    setprop("/ai/submodels/trajectory-markers", 1);
  } else {
    setprop("/ai/submodels/trajectory-markers", 0);
  }
}
#--------------------------------------------------------------------
initialise_drop_view_pos = func {
  eyelatdeg = getprop("/position/latitude-deg");
  eyelondeg = getprop("/position/longitude-deg");
  eyealtft = getprop("/position/altitude-ft") + 20;
  setprop("/sim/view[6]/latitude-deg", eyelatdeg);
  setprop("/sim/view[6]/longitude-deg", eyelondeg);
  setprop("/sim/view[6]/altitude-ft", eyealtft);
}
#--------------------------------------------------------------------
update_drop_view_pos = func {
  eyelatdeg = getprop("/position/latitude-deg");
  eyelondeg = getprop("/position/longitude-deg");
  eyealtft = getprop("/position/altitude-ft") + 20;
  interpolate("/sim/view[6]/latitude-deg", eyelatdeg, 5);
  interpolate("/sim/view[6]/longitude-deg", eyelondeg, 5);
  interpolate("/sim/view[6]/altitude-ft", eyealtft, 5);
}
#--------------------------------------------------------------------
start_up = func {
  settimer(initialise_drop_view_pos, 5);
  settimer(ap_common_elevator_monitor, 0.5);
  settimer(ap_common_aileron_monitor, 0.5);
}
#--------------------------------------------------------------------
