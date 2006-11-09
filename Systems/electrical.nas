# Electrical subsystem for AN-2

UPDATE_PERIOD = 2.0;
MAX_STARTER_CONSUMPTION = 80.0;
rpm_minlimit = 1000;
bus_27 = 0;
bus_115 = 0;

update_electric = func {

power_consumption = 0;
bus_27 = 0;
bus_115 = 0;

starter_flag = 0;

# check for property exist
if( getprop("/engines/engine/rpm" ) == nil ) { 
	return (settimer( update_electric, UPDATE_PERIOD ));}
# Battery switch
	setprop("/an2/systems/electrical/bus-27", bus_27);
if( getprop("/an2/controls/switches/battery_switch") == 1 )
{
	bus_27 = getprop ("/systems/electrical/suppliers/battery[0]");
	setprop("/an2/systems/electrical/bus-27", bus_27);
}

# generator procedure
if( getprop("/engines/engine/rpm") > rpm_minlimit ){
	if( getprop("/an2/controls/switches/generator") == 1 ){
 	bus_27 = getprop ("/systems/electrical/suppliers/battery[0]");
 	setprop("/an2/systems/electrical/bus-27", bus_27);
	}
	}
# generator lamp 
if( bus_27 > 1 )
	{
		if( getprop("/engines/engine/rpm") > rpm_minlimit ) 
		{
			if( getprop("/an2/controls/switches/generator") == 1 )
			{
			setprop("/an2/systems/electrical/generator_lamp", 0);
			}
			else { setprop("/an2/systems/electrical/generator_lamp", 1); }
		}
		else { setprop("/an2/systems/electrical/generator_lamp", 1); }
	}
	else { setprop("/an2/systems/electrical/generator_lamp", 0); }
	
# bus 36 V 400 Hz PT-125 (GIK-1)
if( getprop("/an2/controls/switches/gik_switch") == 1 )
	{
	if( bus_27 > 1.0 )	
		{
		power_consumption += 1;
		setprop("/an2/instrumentation/gik/serviceable", 1);
		}
		else {
		setprop("/an2/instrumentation/gik/serviceable", 0);
		}
	}
	else {
	setprop("/an2/instrumentation/gik/serviceable", 0);
	}
# bus 36 V 400 Hz PAG-1 (AGK-47B, GPK-48)
if( getprop("/an2/controls/switches/agk_switch") == 1 )
	{
	if( bus_27 > 1.0 )	
		{
		power_consumption += 2;
		setprop("/instrumentation/attitude-indicator/serviceable", 1);
		setprop("/instrumentation/heading-indicator/serviceable", 1);
		setprop("/instrumentation/turn-indicator/serviceable", 1);
		# gyro spin
		interpolate("/instrumentation/attitude-indicator/spin", 1, 5);
		interpolate("/instrumentation/heading-indicator/spin", 1, 5);
			}
		else {
		setprop("/instrumentation/attitude-indicator/serviceable", 0);
		setprop("/instrumentation/heading-indicator/serviceable", 0);
		setprop("/instrumentation/turn-indicator/serviceable", 0);
			}
			}
	else {
	setprop("/instrumentation/attitude-indicator/serviceable", 0);
	setprop("/instrumentation/heading-indicator/serviceable", 0);
	}
# bus 115 V 400 Hz PO-500
if( getprop("/an2/controls/switches/po_500_switch") == 1 )
	{
	if( bus_27 > 1.0 ) { bus_115 = 115; power_consumption += 0.5; } }
	else {bus_115 = 0;}
	setprop("/an2/systems/electrical/bus-115", bus_115);
# Proceed devices, powered by 115 V
if( bus_115 > 100 )
	{
		if( getprop("/an2/controls/switches/arp_switch") == 1 )
		{	# ADF
		power_consumption += 1;
		setprop("/instrumentation/adf/serviceable", 1);
		}
		else { setprop("/instrumentation/adf/serviceable", 0); }
		if( getprop("/an2/controls/switches/rv_switch") == 1 )
		{	# Radio altimeter
		power_consumption += 1;
		setprop("/an2/instrumentation/rv-um/serviceable", 1);
		}
		else { setprop("/an2/instrumentation/rv-um/serviceable", 0); }
		if( getprop("/an2/controls/switches/ukv_switch") == 1 )
		{	# NAV radio
		power_consumption += 1;
		setprop("/instrumentation/nav/serviceable", 1);
		}
		else { setprop("/instrumentation/nav/serviceable", 0); }
		
	}
	else {	# stop 
	setprop("/instrumentation/adf/serviceable", 0);
	setprop("/an2/instrumentation/rv-um/serviceable", 0);
	setprop("/instrumentation/nav/serviceable", 0);
	}
# common switches
if( bus_27 > 10.0 )	
	{ 
	if( getprop("/an2/controls/switches/sbess_switch") == 1 )
		{ # Fuel meter SBESS
		power_consumption += 1;
		setprop("/an2/instrumentation/sbess/serviceable", 1);
		}
		else { setprop("/an2/instrumentation/sbess/serviceable", 0);}
	if( getprop("/an2/controls/switches/emi_switch") == 1 )
		{ # Engine gauge EMI-3K
		power_consumption += 1;
		setprop("/an2/instrumentation/emi-3k/serviceable", 1);
		}
		else { setprop("/an2/instrumentation/emi-3k/serviceable", 0);}
	if( getprop("/an2/controls/switches/flaps_power_switch") == 1 )
		{ # Flaps indicator switch
		power_consumption += 1;
		setprop("/an2/instrumentation/flaps/serviceable", 1);
		}
		else { setprop("/an2/instrumentation/flaps/serviceable", 0);}
	if( getprop("/an2/controls/switches/temp_switch") == 1 )
		{ # TUE gauge switch
		power_consumption += 1;
		setprop("/an2/instrumentation/tue-48/serviceable", 1);
		}
		else { setprop("/an2/instrumentation/tue-48/serviceable", 0);}
	if( getprop("/an2/controls/switches/pvd_switch") == 1 )
		{ # PVD switch, not implemented yet
		power_consumption += 1;
		}
	if( getprop("/an2/controls/switches/uv_switch") == 1 )
		{ # Panel lighting switch
		power_consumption += 1;
		setprop("/an2/controls/switches/uv_light", 1);
		}
	if( getprop("/an2/controls/switches/mrv_switch") == 1 )
		{ # Marker beacon switch
		power_consumption += 1;
		setprop("/instrumentation/marker-beacon/serviceable", 1);
		}
		else { setprop("/instrumentation/marker-beacon/serviceable", 0);}
	
	if( getprop("/an2/controls/switches/landing_light_switch") == 1 )
		{ # Landing light
		power_consumption += 1;
		setprop("/controls/switches/landing-light", 1);
		}
		else { setprop("/controls/switches/landing-light", 0);}
	if( getprop("/an2/controls/switches/taxi_light_switch") == 1 )
		{ # Taxi light
		power_consumption += 1;
		setprop("/controls/switches/taxi-light", 1);
		}
		else { setprop("/controls/switches/taxi-light", 0);}
	if( getprop("/an2/controls/switches/nav_light_switch") == 1 )
		{ # Nav light
		power_consumption += 1;
		setprop("/controls/switches/nav-light", 1);
		}
		else { setprop("/controls/switches/nav-light", 0);}
	if( getprop("/an2/controls/switches/heat_switch") == 1 )
		{ # Window heat
		power_consumption += 10;
		setprop("/controls/anti-ice/window-heat", 1);
		}
		else { setprop("/controls/switches/pilot-heat", 0);}
	if( getprop("/an2/controls/switches/starter_switch") == 1 )
		{ # starter subsystem
		power_consumption += 0.5;
		setprop("/an2/instrumentation/starter/serviceable", 1);
		}
		else { setprop("/an2/instrumentation/starter/serviceable", 0);}
	if( getprop("/an2/controls/switches/starter_selector" ) == 1 )
		{
		if( getprop("/an2/instrumentation/starter/spin") != nil ){
		power_consumption += 
( 1.0 - getprop("/an2/instrumentation/starter/spin") ) * MAX_STARTER_CONSUMPTION;
		}}
			
	}
	else {	# stop 
	setprop("/an2/instrumentation/sbess/serviceable", 0);
	setprop("/an2/instrumentation/emi-3k/serviceable", 0);
	setprop("/an2/instrumentation/flaps/serviceable", 0);
	setprop("/an2/instrumentation/tue-48/serviceable", 0);
	setprop("/an2/controls/switches/uv_light", 0);
	setprop("/controls/switches/landing-light", 0);
	setprop("/controls/switches/taxi-light", 0);
	setprop("/controls/switches/nav-light", 0);
	setprop("/controls/anti-ice/window-heat", 0);
	setprop("/an2/instrumentation/starter/serviceable", 0);
	setprop("/instrumentation/marker-beacon/serviceable", 0);
	}
interpolate("/an2/instrumentation/electrical/amps", power_consumption*5, 0.3);
settimer( update_electric, UPDATE_PERIOD );
} # end electric_handler	

update_electric ();


light_switch = func {
if( arg[0] == 1 )
	{
	setprop("/an2/controls/switches/uv_switch", 1);
	if( bus_27 > 10.0 )
	{ setprop("/an2/controls/switches/uv_light", 1);}
	else { setprop("/an2/controls/switches/uv_light", 0);}
	}
else {
	setprop("/an2/controls/switches/uv_switch", 0);
	setprop("/an2/controls/switches/uv_light", 0);}
}

# starter procedure
spinup = func {
setprop("/an2/controls/switches/starter_selector", 1 );
if( getprop("/an2/instrumentation/starter/serviceable") == 1 )
 	{
 	interpolate("/an2/instrumentation/starter/spin", 1, 4);
 	update_electric();
 	}
}

starter_idle = func {
	interpolate("/an2/instrumentation/starter/spin", 0, 5);
	setprop("/an2/controls/switches/starter_selector", 0 );
	setprop("/controls/engines/engine/starter", 0 );
}

starter_on = func {
if( getprop("/an2/instrumentation/starter/serviceable") == 1 ){
	interpolate("/an2/instrumentation/starter/spin", 0, 1);
	setprop("/an2/controls/switches/starter_selector", 2 );
	if( getprop("/an2/instrumentation/starter/spin") > 0.01 ){
	setprop("/controls/engines/engine/starter", 1 );
	}
	else { setprop("/controls/engines/engine/starter", 0 ); }
	}

}

# # Intake temperature
# 
# intake_temp = func {
# 	if( getprop ("/an2/instrumentation/tue-48/serviceable") == 1 )
# 	{
# 	temp = getprop
# 	interpolate("/an2/instrumentation/tue-48/intake_temp", 0, 1);
# 	}
# }
