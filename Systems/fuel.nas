# Fuel subsystem for AN-2

# AN-2 have 2 fuel tank, engine can use 1,or 2,or both. Engine consumes 
# more fuel from 1-st tank, than 2-nd. To avoid bank, pilot must take care 
# about fuel level per tank.

# Fuel handler

min_cap = 0.01;
delta = 0.05;
fcc = 6.65; #fuel consumption coefficient

fuel_handler = func {
tank_selector = getprop("/an2/instrumentation/fuel-select/position");
if( tank_selector == 1)	{ # proceed left tank
	level_left = getprop("/consumables/fuel/tank[1]/level-gal_us");
	if( level_left <= 0 ){ # left tank empty
		setprop("/consumables/fuel/tank[1]/level-gal_us", 0 );
		return ( settimer( fuel_handler, UPDATE_PERIOD ) );
		}
	current_level = getprop("/consumables/fuel/tank[0]/level-gal_us");
	consumed = (min_cap - current_level)*fcc;
	setprop("/consumables/fuel/tank[1]/level-gal_us", level_left - consumed);
	setprop("/consumables/fuel/tank[0]/level-gal_us", min_cap );
	}
if( tank_selector == 3)	{ # proceed right tank
	level_right = getprop("/consumables/fuel/tank[2]/level-gal_us");
	if( level_right <= 0 ){ # right tank empty
		setprop("/consumables/fuel/tank[2]/level-gal_us", 0 );
		return ( settimer( fuel_handler, UPDATE_PERIOD ) );
	}
	current_level = getprop("/consumables/fuel/tank[0]/level-gal_us");
	consumed = (min_cap - current_level)*fcc;
	setprop("/consumables/fuel/tank[2]/level-gal_us", level_right - consumed);
	setprop("/consumables/fuel/tank[0]/level-gal_us", min_cap );
}
if( tank_selector == 2)	{ # proceed both
	level_left = getprop("/consumables/fuel/tank[1]/level-gal_us");
	level_right = getprop("/consumables/fuel/tank[2]/level-gal_us");
	if( level_left <= 0 ){ # left tank empty
		setprop("/consumables/fuel/tank[1]/level-gal_us", 0 );
		return ( settimer( fuel_handler, UPDATE_PERIOD ) );
	}
	if( level_right <= 0 ){ # right tank empty
		setprop("/consumables/fuel/tank[2]/level-gal_us", 0 );
		return ( settimer( fuel_handler, UPDATE_PERIOD ) );
	}
	current_level = getprop("/consumables/fuel/tank[0]/level-gal_us");
	consumed = (min_cap - current_level)*fcc;
setprop("/consumables/fuel/tank[1]/level-gal_us", level_left - consumed*(0.5 + delta) );
setprop("/consumables/fuel/tank[2]/level-gal_us", level_right - consumed*(0.5 - delta) );
	setprop("/consumables/fuel/tank[0]/level-gal_us", min_cap );
}
return ( settimer( fuel_handler, UPDATE_PERIOD ) );
} # end fuel_handler	
fuel_handler ();