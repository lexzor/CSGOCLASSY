#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < engine >
#include < fakemeta >
#include < fakemeta_util >
#include < fun >
#include <csgoclassy>

#define PLUGIN "BonusBox"
#define VERSION "1.0"
#define AUTHOR "SkepT Jr."

new const iTag[] = "^4[^3CSGO Classy^4]^1"
new const ClassName [ ] = "BonusBox"
new models_box [] = {	
	"models/csgoclassy_case/csgoclassy_case.mdl"
};


const UNIT_SEC = 0x1000;
const FFADE = 0x0000;

#define FFADE_IN			0x0000		
#define FFADE_OUT			0x0001		
#define FFADE_MODULATE		0x0002		
#define FFADE_STAYOUT		0x0004	
#define SPEEDBOX 			600.0	

public plugin_init ( ) {
	
	register_plugin ( PLUGIN, VERSION, AUTHOR );
	register_event ( "DeathMsg", "eDeath", "a" );
	register_forward ( FM_PlayerPreThink, "ForcePlayerSpeed" );
	register_forward ( FM_Touch, "Touch" );
	
	register_event("HLTV", "Event_HLTV_New_Round", "a", "1=0", "2=0")
	// Add your code here...
}

public Event_HLTV_New_Round()
{
    remove_entity_name(ClassName);
} 

public plugin_precache() {
	for(new i; i < sizeof (models_box) ; i++)
		precache_model(models_box)
}

public give_bonus2(id)
{
	bonus_box(id)
}

public eDeath ( ) {
	
	new iKiller = read_data (1);
	new iVictim = read_data (2);
	new iRandom = random_num(1, 10);
	
	if ( iKiller == iVictim ) {
		
		return PLUGIN_HANDLED;
		
	}
	
	if(iRandom > 9)
		bonus_box (iVictim);
	else
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE;
}



public bonus_box ( id ) {
	
	if ( is_user_connected ( id ) && cs_get_user_team ( id ) != CS_TEAM_SPECTATOR ) {
		
		new Ent = fm_create_entity ( "info_target" );
		new Origin [ 3 ];
		get_user_origin ( id, Origin, 0 );
		set_pev ( Ent, pev_classname, ClassName )
		
		engfunc ( EngFunc_SetModel, Ent, models_box [0] );
		
		set_pev ( Ent, pev_mins, Float: { -10.0,-10.0,0.0 } );
		set_pev ( Ent, pev_maxs, Float: { 10.0,10.0,25.0 } );
		set_pev ( Ent, pev_size, Float: { -10.0,-10.0,0.0,10.0,10.0,25.0 } ); 
		engfunc ( EngFunc_SetSize, Ent, Float: { -10.0, -10.0, 0.0 }, Float: { 10.0, 10.0, 25.0 } );
		
		set_pev ( Ent,pev_solid, SOLID_BBOX );
		set_pev ( Ent,pev_movetype, MOVETYPE_TOSS );
		
		new Float: fOrigin [ 3 ];
		IVecFVec ( Origin, fOrigin );
		set_pev ( Ent, pev_origin, fOrigin );
		
	}
	
}

public Touch ( toucher, touched )
{
	
	if ( !is_user_alive( toucher ) || !pev_valid( touched ) )
		return FMRES_IGNORED;
	
	new classname [ 32 ];    
	pev( touched, pev_classname, classname, 31 );
	
	if (!equal( classname, ClassName ) )
		return FMRES_IGNORED;
	
	set_pev ( touched, pev_effects, EF_NODRAW );
	set_pev ( touched, pev_solid, SOLID_NOT );
	
	if (!remove_entity( touched ))
		return FMRES_IGNORED;
	
	if(is_user_logged(toucher) == 1)
	{
		give_bonus( toucher );
	}
	else
	{
		client_print_color(toucher, print_team_default, "%s You have to be logged in to get this bonus!", iTag)
		remove_entity( touched )
	}
	
	return FMRES_IGNORED;  
}

public give_bonus ( id )
{
	new iRandom, iChance
	
	iRandom = random_num(0,5)
	
	new iRandomBonus, iMoney[MAX_PLAYERS + 1], iCases[MAX_PLAYERS + 1], iKeys[MAX_PLAYERS + 1], iScraps[MAX_PLAYERS + 1]
	
	switch(iRandom)
	{
		case 0:
		{
			iMoney[id] = get_user_money(id)			
			
			iChance = random_num(0,10)
			
			iRandomBonus = random_num(0,5)
			
			if (iChance >= 7 && iRandomBonus != 0)
			{
				iRandomBonus *= -1
			}
			
			if (iRandomBonus == 0)
			{
				client_print_color(id, print_team_default, "%s You didn't get anything!", iTag, iRandomBonus)
				return PLUGIN_HANDLED
			}
			else if (iRandomBonus < 0)
			{
				iRandomBonus *= -1
				
				if (iMoney[id] - iRandomBonus <= 0)
				{
					client_print_color(id, print_team_default, "%s You haven't lost anything because you don't have enough^4 money^1.", iTag)
					return PLUGIN_HANDLED
				}
				
				set_user_money(id, iMoney[id] - iRandomBonus)
				client_print_color(id, print_team_default, "%s You lost^4 %i dolar%s^1.", iTag, iRandomBonus, iRandomBonus == 1 ? "" : "s")	
				return PLUGIN_HANDLED
			}
			else if (iRandomBonus > 0)
			{
				set_user_money(id, iMoney[id] + iRandomBonus)
				client_print_color(id, print_team_default, "%s You got^4 %i dolar%s^1.", iTag, iRandomBonus, iRandomBonus == 1 ? "" : "s")		
				return PLUGIN_HANDLED
			}
		}
		
		case 1:	
		{
			iCases[id] = get_user_cases(id)
			
			iChance = random_num(0,10)
			
			iRandomBonus = random_num(0,3)
			
			if (iChance >= 7 && iRandomBonus != 0)
			{
				iRandomBonus *= -1
			}
			
			if (iRandomBonus == 0)
			{
				client_print_color(id, print_team_default, "%s You didn't get anything!", iTag, iRandomBonus)
				return PLUGIN_HANDLED
			}
			else if (iRandomBonus < 0)
			{
				
				iRandomBonus *= -1
				
				if (iCases[id] - iRandomBonus <= 0)
				{
					client_print_color(id, print_team_default, "%s You haven't lost anything because you don't have enough^4 cases^1.", iTag)
					return PLUGIN_HANDLED
				}
				
				set_user_cases(id, iCases[id] - iRandomBonus)
				client_print_color(id, print_team_default, "%s You lost^4 %i case%s^1.", iTag, iRandomBonus, iRandomBonus == 1 ? "" : "s")	
				return PLUGIN_HANDLED
			}
			else if (iRandomBonus > 0)
			{
				set_user_cases(id, iCases[id] + iRandomBonus)
				client_print_color(id, print_team_default, "%s You got^4 %i case%s^1.", iTag, iRandomBonus, iRandomBonus == 1 ? "" : "s")		
				return PLUGIN_HANDLED
			}
		}
		
		case 2:
		{
			iKeys[id] = get_user_keys(id)
			
			iChance = random_num(0,10)
			
			iRandomBonus = random_num(0,5)
			
			if (iChance >= 7 && iRandomBonus != 0)
			{
				iRandomBonus *= -1
			}
			
			if (iRandomBonus == 0)
			{
				client_print_color(id, print_team_default, "%s You didn't get anything!", iTag, iRandomBonus)
				return PLUGIN_HANDLED
			}
			else if (iRandomBonus < 0)
			{
				iRandomBonus *= -1
				
				if (iKeys[id] - iRandomBonus <= 0)
				{
					client_print_color(id, print_team_default, "%s You haven't lost anything because you don't have enough^4 keys^1.", iTag)
					return PLUGIN_HANDLED
				}
				
				set_user_keys(id, iKeys[id] - iRandomBonus)
				client_print_color(id, print_team_default, "%s You lost^4 %i key%s^1.", iTag, iRandomBonus, iRandomBonus == 1 ? "" : "s")	
				return PLUGIN_HANDLED
			}
			else if (iRandomBonus > 0)
			{
				set_user_keys(id, iKeys[id] + iRandomBonus)
				client_print_color(id, print_team_default, "%s You got^4 %i key%s^1.", iTag, iRandomBonus, iRandomBonus == 1 ? "" : "s")		
				return PLUGIN_HANDLED
			}
		}
		
		case 3:
		{
			iScraps[id] = get_user_scraps(id)
			
			iChance = random_num(0,10)
			
			iRandomBonus = random_num(0,8)
			
			if (iChance >= 7 && iRandomBonus != 0)
			{
				iRandomBonus *= -1
			}
			
			if (iRandomBonus == 0)
			{
				client_print_color(id, print_team_default, "%s You didn't get anything!", iTag, iRandomBonus)
				return PLUGIN_HANDLED
			}
			else if (iRandomBonus < 0)
			{
				iRandomBonus *= -1
				
				if (iScraps[id] - iRandomBonus <= 0)
				{
					client_print_color(id, print_team_default, "%s You haven't lost anything because you don't have enough^4 scraps^1.", iTag)
					return PLUGIN_HANDLED
				}
				
				set_user_scraps(id, iScraps[id] - iRandomBonus)
				client_print_color(id, print_team_default, "%s You lost^4 %i scrap%s^1.", iTag, iRandomBonus, iRandomBonus == 1 ? "" : "s")	
				return PLUGIN_HANDLED
			}
			else if (iRandomBonus > 0)
			{
				set_user_scraps(id, iScraps[id] + iRandomBonus)
				client_print_color(id, print_team_default, "%s You got^4 %i scrap%s^1.", iTag, iRandomBonus, iRandomBonus == 1 ? "" : "s")		
				return PLUGIN_HANDLED
			}
		}
		
		case 4:
		{
			if(is_user_alive(id))
			{
				new iRandomHP, iRandomAM
				
				iRandomHP = random_num(1,20)
				iRandomAM = random_num(1,20)
				
				set_user_health(id, get_user_health(id) + iRandomHP)
				set_user_armor(id, get_user_armor(id) + iRandomAM)
				
				client_print_color(id, print_team_default, "%s You got^4 %i Health^1 and^4 %i Armor^1.", iTag,iRandomHP, iRandomAM)
			}
			else
				return PLUGIN_HANDLED
		}
		
		case 5: 
		{
			if(is_user_alive(id))
			{
				set_user_gravity(id, 0.6)
				client_print_color(id, print_team_default, "%s You got^4 lower gravity^1, but only for this round!", iTag)
			}
			else
				return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_CONTINUE
}