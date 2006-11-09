############################################################################
#    Copyright 								   #
#									   #
#    (C) 2005 by Anton Nikolaev aka Xomer - original model for 		   #
#	MS Flight Simulator, sounds, visual model and textures.		   #
#     	xomer@yandex.ru							   #
#									   #
#	Model published under GPL with his permission. 			   #
#									   #
#	Original model you can get there: 				   #
#	http://www.avsim.ru/files.phtml?action=download&id=3333		   #
#									   #
#    (C) 2006 by Yurik V. Nikiforoff - port for FGFS, 2d-panel, FDM, 	   #
#	instruments, animations, systems and over.		 	   #
#    	yurik@megasignal.com						   #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################		  
# Instrumentation for AN-2 
# Gyro with cage
gpk_helper = func{
caged = getprop("/an2/instrumentation/gpk-48/caged-flag");
if( caged == 1 ) { 
#print("+++");
	heading = getprop("/an2/instrumentation/gpk-48/true-heading-deg");
	offset = getprop("/instrumentation/heading-indicator/offset-deg");
	if( heading == nil) { settimer(gpk_helper, 0); return; }
	if( offset == nil) { settimer(gpk_helper, 0); return; }
	setprop("/an2/instrumentation/gpk-48/indicated-heading-deg", heading+offset ); 
	}
if( caged == 0 ) { 
	heading = getprop("/instrumentation/heading-indicator/indicated-heading-deg");
	if( heading == nil) { settimer(gpk_helper, 0); return; }
	setprop("/an2/instrumentation/gpk-48/indicated-heading-deg", heading ); 
	}
settimer(gpk_helper, 0);	
}

gpk_caged = func{
caged = getprop("/an2/instrumentation/gpk-48/caged-flag");
if( caged == 1 ) { 
	setprop("/an2/instrumentation/gpk-48/caged-flag", 0); 
	return;
	}
if( caged == 0 ) {
	heading = getprop("/instrumentation/heading-indicator/indicated-heading-deg");
	offset = getprop("/instrumentation/heading-indicator/offset-deg");
	if( heading == nil) { return; }
	if( offset == nil) { return; }
	setprop("/an2/instrumentation/gpk-48/true-heading-deg", heading-offset ); 
	setprop("/an2/instrumentation/gpk-48/caged-flag", 1); 
	return;
	}
}

gpk_helper();

# Compass 
gik = func {
heading = getprop("/orientation/heading-magnetic-deg");
if( heading != nil ){
	if(getprop("/an2/instrumentation/gik/serviceable") == 1 )
	{
	gik_offset = getprop("/an2/instrumentation/gik/offset");
	setprop("/an2/instrumentation/gik/indicated-heading-deg", heading+gik_offset );
	}}
settimer(gik, 0);
}

gik();

gik_adjust = func {
	if(getprop("/an2/instrumentation/gik/serviceable") == 1 )
	{
	if( getprop("/an2/instrumentation/gik/offset") > 0 ) {
		controls.slewProp ("/an2/instrumentation/gik/offset", -30 ); }
	}
}

# Radio Altimeter

# helper 
stop_rv = func {
	setprop("/an2/instrumentation/rv-um/lamp", 0);
	interpolate("/an2/instrumentation/rv-um/rv-altitude-m", 0, 1);
}

rv_um = func {
# check power
if( getprop("/an2/instrumentation/rv-um/serviceable" ) != 1 ){
	stop_rv();
 	return ( settimer(rv_um, 0.3) ); 
	}
# check selector position
limit = getprop("/an2/instrumentation/rv-um/control");
if( limit == nil ){
	stop_rv();
 	return ( settimer(rv_um, 0.3) ); 
}

if( limit < 1 ){ 
	stop_rv();
 	return ( settimer(rv_um, 0.3) ); 
}

altitude=getprop("/position/altitude-ft");
elevation=getprop("/position/ground-elev-ft");
rv_altitude_m = 0.3048*altitude;
  if( elevation != nil ){ rv_altitude_m = 0.3048*(altitude-elevation);}
  interpolate("/an2/instrumentation/rv-um/rv-altitude-m", rv_altitude_m, 0.3);
# convert from position to meters
	
	if(limit == 2){ limit = 50; }
	
if(limit == 3){ limit = 100; }
	if(limit == 4){ limit = 150; }
	if(limit == 5){ limit = 200; }
	if(limit == 6){ limit = 250; }
	if(limit == 7){ limit = 300; }
	if(limit == 8){ limit = 400; }
	if( rv_altitude_m < limit )
	{
 	setprop("/an2/instrumentation/rv-um/lamp", 1);
	}
	else { setprop("/an2/instrumentation/rv-um/lamp", 0); }
# control position
	if(limit == 1){ setprop("/an2/instrumentation/rv-um/lamp", 1); }
  settimer(rv_um, 0.3);
   }
rv_um ();	# start process first time




# Fuel meter SBESS-1447
# Gallon US: 3.785 l
sbess_handler = func {
	if( getprop("/an2/instrumentation/sbess/serviceable" ) != 1 ){
	interpolate("/an2/instrumentation/sbess/indicated-fuel-l", 0, 1 );
	return ( settimer(sbess_handler, 1) ); 
	}
    	mode = getprop("/an2/controls/switches/fuel_selector");
	if( mode == 0 ){	
		gallons = getprop("/consumables/fuel/tank[1]/level-gal_us");
		gallons = gallons + getprop("/consumables/fuel/tank[2]/level-gal_us");
	if( gallons != nil ){
	interpolate("/an2/instrumentation/sbess/indicated-fuel-l", gallons*3.785, 1 );
		}
	}
settimer(sbess_handler, 1);
}
sbess_handler ();

# show fuel level of left tank
left_tank = func{
	if( getprop("/an2/instrumentation/sbess/serviceable" ) == 1 ){
	gallons = getprop("/consumables/fuel/tank[1]/level-gal_us");
	if( gallons != nil ){
	interpolate("/an2/instrumentation/sbess/indicated-fuel-l", gallons*3.785, 1 );
	}}
setprop("/an2/controls/switches/fuel_selector", 1 );
}

# show fuel level of right tank
right_tank = func{
	if( getprop("/an2/instrumentation/sbess/serviceable" ) == 1 ){
	gallons = getprop("/consumables/fuel/tank[2]/level-gal_us");
	if( gallons != nil ){
	interpolate("/an2/instrumentation/sbess/indicated-fuel-l", gallons*3.785, 1 );
	}}
setprop("/an2/controls/switches/fuel_selector", 2 );
}

# show left + right
total_fuel = func{
	if( getprop("/an2/instrumentation/sbess/serviceable" ) == 1 ){
	gallons = getprop("/consumables/fuel/tank[1]/level-gal_us");
	if( gallons != nil ){
	gallons = gallons + getprop("/consumables/fuel/tank[2]/level-gal_us");
	interpolate("/an2/instrumentation/sbess/indicated-fuel-l", gallons*3.785, 1 );
	settimer(sbess_handler, 1); # rewind timer
	}}
setprop("/an2/controls/switches/fuel_selector", 0 );
}
#    End fuel meter stuff


# Air speed indicator US-450
# 1 knots = 1.852 km/h
us = func {
    knots=getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
    if( knots != nil ){
    setprop("/an2/instrumentation/us-450/indicated-speed-kmh", knots*1.852 );
    }
    settimer(us, 0);	# count speed every frame
   }
us ();

# Volt-ampermeter VA-3
va_handler = func {
mode = getprop("/an2/instrumentation/va-3/volts");
ampers = getprop("/an2/instrumentation/electrical/amps");
# battery charge current
if("/an2/systems/electrical/generator_lamp" == 0 ) {ampers = 1;}
    	if( mode == 0 ){
    		if( ampers != nil ){
		interpolate("/an2/instrumentation/va-3/indicated-value", ampers, 1 );
		}
	}
	settimer(va_handler, 1);	
}
va_handler ();

va_volts = func {
    volts = getprop("/systems/electrical/volts");
	if( volts != nil ){
	interpolate("/an2/instrumentation/va-3/indicated-value", volts*12, 1 );
	}
	setprop("/an2/instrumentation/va-3/volts", 1);
}

va_ampers = func {
    	ampers = getprop("/an2/instrumentation/electrical/amps");
    	if("/an2/systems/electrical/generator_lamp" == 0 ) {ampers = 1;}
	if( ampers != nil ){
		interpolate("/an2/instrumentation/va-3/indicated-value", ampers, 1 );
	}
	setprop("/an2/instrumentation/va-3/volts", 0 );
	settimer(va_handler, 2);	
}


# Door
# Thanks to BF109 autors :)
toggle_door = func
{
  if(getprop("/an2/controls/door-pos-norm") > 0) 
	{
    	interpolate("/an2/controls/door-pos-norm", 0, 2);
	} 
	else {
    	interpolate("/an2/controls/door-pos-norm", 1, 2);
	}
}

# Dampers 

oil_damper = func {
if( arg[0] > 0 ) { 
	if( getprop ("/an2/systems/dampers/oil-damper") < 0.995 )
	{
	controls.slewProp ("/an2/systems/dampers/oil-damper", 0.5); 
	}}
else 	{ 
	if( getprop ("/an2/systems/dampers/oil-damper") > 0.005 )
	{
	controls.slewProp ("/an2/systems/dampers/oil-damper", -0.5); 
	}}

}


air_damper = func {
if( arg[0] > 0 ) { 
	if( getprop ("/an2/systems/dampers/air-damper") < 0.995 )
{
	controls.slewProp ("/an2/systems/dampers/air-damper", 0.5); 
}}
else 	{ 
	if( getprop ("/an2/systems/dampers/air-damper") > 0.005 )
{
	controls.slewProp ("/an2/systems/dampers/air-damper", -0.5); 
}}

}

# TCT-2 cylinder head termometer

# engine_temp = func {
# 	heat = getprop("/engines/engine/cht-degf");
# 	if ( heat != nil )
# 	{
# 	# find abs val of temperature
# 	env_temp = getprop("/environment/temperature-degc");
# 	env_temp = env_temp + 273; #to Kelvin
# 	# cool factor
# 	damper_position = getprop("/an2/systems/dampers/air-damper");
# 	damper_position = damper_position + 0.3;
# 	damper_position = damper_position * 0.77;
# 	
# 	}
# }
# 
# engine_temp();

# Livres
change_livreas = func
{
selector = getprop("/an2/livreas/selector");
log = screen.window.new( nil, -100, 1, 2 );

if( selector != nil ) 
   {
	if( selector < 0 ) { selector = 0; }
	if( selector >= 8 ) { selector = 0;}
	selector = selector + 1;
	if( selector == 1 )
	{
	log.write("Aeroflot-60", 0.0, 1.0, 1.0 );
	setprop("/an2/livreas/fuselage","afl60_fuse_1_t.rgb");
	setprop("/an2/livreas/wings","afl60_wings_1_t.rgb");
	setprop("/an2/livreas/selector", selector );
	return;
	}
	if( selector == 2 )
	{
	log.write("Aeroflot-70", 0.0, 1.0, 1.0 );
	setprop("/an2/livreas/fuselage","afl70_fuse_1_t.rgb");
	setprop("/an2/livreas/wings","afl70_wings_1_t.rgb");
	setprop("/an2/livreas/selector", selector );
	return;
	}
	if( selector == 3 )
	{
	log.write("Aeroflot-80", 0.0, 1.0, 1.0 );
	setprop("/an2/livreas/fuselage","afl80_fuse_1_t.rgb");
	setprop("/an2/livreas/wings","afl80_wings_1_t.rgb");
	setprop("/an2/livreas/selector", selector );
	return;
	}
	if( selector == 4 )
	{
	log.write("Aeroflot-90", 0.0, 1.0, 1.0 );
	setprop("/an2/livreas/fuselage","afl90_fuse_1_t.rgb");
	setprop("/an2/livreas/wings","afl90_wings_1_t.rgb");
	setprop("/an2/livreas/selector", selector );
	return;
	}
	if( selector == 5 )
	{
	log.write("Agricultural", 0.0, 1.0, 1.0 );
	setprop("/an2/livreas/fuselage","agri_fuse_1_t.rgb");
	setprop("/an2/livreas/wings","agri_wings_1_t.rgb");
	setprop("/an2/livreas/selector", selector );
	return;
	}
	if( selector == 6 )
	{
	log.write("Military", 0.0, 1.0, 1.0 );
	setprop("/an2/livreas/fuselage","mil_fuse_1_t.rgb");
	setprop("/an2/livreas/wings","mil_wings_1_t.rgb");
	setprop("/an2/livreas/selector", selector );
	return;
	}
	if( selector == 7 )
	{
	log.write("Aeroclub Rzhevka", 0.0, 1.0, 1.0 );
	setprop("/an2/livreas/fuselage","rzhevka_fuse_1_t.rgb");
	setprop("/an2/livreas/wings","rzhevka_wings_1_t.rgb");
	setprop("/an2/livreas/selector", selector );
	return;
	}
	if( selector == 8 )
	{
	log.write("USA First :)", 0.0, 1.0, 1.0 );
	setprop("/an2/livreas/fuselage","usa_fuse_1_t.rgb");
	setprop("/an2/livreas/wings","usa_wings_1_t.rgb");
	setprop("/an2/livreas/selector", selector );
	}	
    }
}


# starter help
starter_help = func
{
help_win = screen.window.new( nil, -100, 8, 10 );

sw_win = screen.window.new( 380, 430, 1, 10 );
sel_win = screen.window.new( 680, 430, 1, 10 );
magn_win = screen.window.new( 430, 450, 1, 10 );
fuel_win = screen.window.new( 90, 60, 1, 10 );
alt_win = screen.window.new( 90, 185, 1, 10 );
batt_win = screen.window.new( 830, 250, 1, 10 );
line_1_win = screen.window.new( 740, 480, 1, 10 );
line_2_win = screen.window.new( 800, 280, 1, 10 );

help_win.write("Before start, turn on main battery switch, set magneto selector to (1+2) position,", 0.0, 1.0, 1.0 );
help_win.write("set fuel tank selector to up position, and turn throttle to idle.", 0.0, 1.0, 1.0 );
help_win.write("For start engine, turn on starter switch,", 0.0, 1.0, 1.0 );
help_win.write("spin inertial starter by turn starter selector to left position,", 0.0, 1.0, 1.0 );
help_win.write("hold until spinup - see to ampermeter, listen sound of gyro. ", 0.0, 1.0, 1.0 );
help_win.write("After spinup, turn starter selector to right and hold until engine started.", 0.0, 1.0, 1.0 );
help_win.write("Turn on all switches on line 1 & 2, except panel lighting. Turn on PO-500 alternator.", 0.0, 1.0, 1.0 );
help_win.write("Turn on radio altimeter and set warning to desired altitude. Turn off starter switch.", 0.0, 1.0, 1.0 );


sw_win.write("Starter switch ->", 0.0, 1.0, 1.0 );
sel_win.write("<- Starter selector", 0.0, 1.0, 1.0 );
magn_win.write("Magneto selector ->", 0.0, 1.0, 1.0 );
fuel_win.write("<- Fuel tank selector", 0.0, 1.0, 1.0 );
alt_win.write("<- Radio altimeter selector", 0.0, 1.0, 1.0 );
batt_win.write("<- Main battery switch", 0.0, 1.0, 1.0 );
line_1_win.write("<-   Line 1 switches   ->", 0.0, 1.0, 1.0 );
line_2_win.write("<-   Line 2 switches   ->", 0.0, 1.0, 1.0 );
}
