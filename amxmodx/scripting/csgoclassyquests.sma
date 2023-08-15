#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <nvault>
#include <csx>
#include <fun>
#include <xs>
#include <nvault>
#include <unixtime>
#include <csgoclassy>

#pragma compress 1

#define XO_PLAYER           5
#define m_pPlayer	     	41
#define m_flTimeWeaponIdle  48
#define m_fInReload         54
#define m_fInSpecialReload  55
#define m_flFlashedUntil    514
#define m_flFlashedAt       515
#define m_flFlashHoldTime   516
#define m_flFlashDuration   517
#define m_iFlashAlpha       518
#define ALPHA_FULLBLINDED   255
#define INTERVAL 60
new g_iMaxPlayers
#define FIRST_PLAYER_ID	1
#define IsPlayer(%1) (FIRST_PLAYER_ID <= %1 <= g_iMaxPlayers)
new g_iVault
const MAX_WEAPONS = CSW_P90
new g_iBombTime
new g_iPlanter
new g_iGetBombPlanted
new g_fwid
new const Float:vecNullOrigin[3]
new Float:flDistance[MAX_PLAYERS + 1]
new Float:vecOldOrigin[MAX_PLAYERS + 1][3]
new Float:g_iFeet = 35.0	
new g_iTeamKills[33]
new g_iRoundSparys[33]
new g_iKills[33]
new g_iShotKills[33]
new g_iGrenadeKills[33]
new bool:g_iBombPlant
new bool:is_dead[33]
new bool:StandAlone[33]
new bool:OneHpHero[33]
new bool:is_VictimInAir[33]
new bool:iKillerHasNotMoved[33]
new bool:iKillerShot[33]
new bool:is_Alive[33]
new bool:g_iDeathMessages[33]
new bool:is_Connected[MAX_PLAYERS + 1]
new bool:g_iGetBombDown

enum _:g_iAchCount
{
	CONNECTIONS,
	HEAD_SHOTS,
	DISTANCE_KILLED,
	DISTANCE_WALKED,
	BOMB,
	PLANT_BOMB,
	PLANT_BOMB_COUNT,
	DEFUSED_BOMB,
	TOTAL_KILLS,
	PISTOL_MASTER,
	RIFLE_MASTER,
	SHOTGUN_MASTER,
	SPRAY_N_PRAY,
	MASTER_AT_ARMS,
	PLAY_AROUND,
	STAND_ALONE,
	ONE_HP_HERO,
	BAD_FRIEND,
	URBAN_DESIGNER,
	GRAFFITI,
	AMMO_CONSERVATION,
	FLY_AWAY,
	RELOADER,
	CAMP_FIRE,
	HAT_TRICK,
	COWBOY_DIPLOMACY,
	TOTAL_DAMAGE
}

new const g_iAchsMaxPoints[g_iAchCount] =
{
	1000,
	300,
	4,
	3,
	1,
	1,
	100,
	400,
	10000,
	6,
	10,
	2,
	1,
	25,
	60, 
	15,
	1,
	5,
	300,
	1,
	1,
	1,
	1000,
	1,
	1,
	100,
	50000
}

new g_iAuthID[ 33 ][ 36 ]
new g_pCvarC4Timer

new const g_szWeaponNames[][] =
{
	"p228",
	"scout",              
	"hegrenade",              
	"xm1014",
	"c4",                    
	"mac10",             
	"aug", 
	"smokegrenade",            
	"elite",          
	"fiveseven",
	"ump45",               
	"sg550",
	"galil",  
	"famas",
	"usp",   
	"glock18",   
	"awp",  
	"mp5navy",     
	"m249",            
	"m3",  
	"m4a1",                
	"tmp",      
	"g3sg1",    
	"flashbang",            
	"deagle",
	"sg552", 
	"ak47",      
	"knife",                   
	"p90"
}

#define WEAPON_SIZE sizeof(g_szWeaponNames)

new const g_iWeaponIDs[WEAPON_SIZE] =
{
	CSW_P228,
	CSW_SCOUT,
	CSW_HEGRENADE,
	CSW_XM1014,
	CSW_C4,
	CSW_MAC10,
	CSW_AUG,
	CSW_SMOKEGRENADE,
	CSW_ELITE,
	CSW_FIVESEVEN,
	CSW_UMP45,
	CSW_SG550,
	CSW_GALIL,
	CSW_FAMAS,
	CSW_USP,
	CSW_GLOCK18,
	CSW_AWP,
	CSW_MP5NAVY,
	CSW_M249,
	CSW_M3,
	CSW_M4A1,
	CSW_TMP,
	CSW_G3SG1,
	CSW_FLASHBANG,
	CSW_DEAGLE,
	CSW_SG552,
	CSW_AK47,
	CSW_KNIFE,
	CSW_P90
}

new const g_iAchsWeaponMaxKills[] =
{
	200,
	1000,
	300,
	200,
	30,
	500,
	500,
	150,
	100,
	100,
	1000,
	500,
	500,
	500,
	200,
	200,
	1000,
	1000,
	500,
	200,
	1000,
	1000,
	500,
	150,
	200,
	500,
	1000,
	200,
	1000
}

new const g_iGunEvents[][] = 
{
	"events/awp.sc",
	"events/g3sg1.sc",
	"events/ak47.sc",
	"events/scout.sc",
	"events/m249.sc",
	"events/m4a1.sc",
	"events/sg552.sc",
	"events/aug.sc",
	"events/sg550.sc",
	"events/m3.sc",
	"events/xm1014.sc",
	"events/usp.sc",
	"events/mac10.sc",
	"events/ump45.sc",
	"events/fiveseven.sc",
	"events/p90.sc",
	"events/deagle.sc",
	"events/p228.sc",
	"events/glock18.sc",
	"events/mp5n.sc",
	"events/tmp.sc",
	"events/elite_left.sc",
	"events/elite_right.sc",
	"events/galil.sc",
	"events/famas.sc"
}

new g_iPlayersKills[MAX_PLAYERS + 1][MAX_WEAPONS + 1]
new g_iAchLevel[MAX_PLAYERS + 1][g_iAchCount]
new g_iTimerEntity
new g_iJoinTime[MAX_PLAYERS + 1]
new Trie:g_tWeaponNameToID
new iWeaponID
new g_iGunEvent_IDsBitsum

public plugin_init() 
{
	register_plugin("CSGO Classy quests", "1.0", "renegade")

	g_pCvarC4Timer = get_cvar_pointer("mp_c4timer")
	register_event("DeathMsg", "Event_PlayerKilled", "a")
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_event("StatusIcon", "Event_GotBomb", "be", "1=1", "1=2", "2=c4")
	register_event("ResetHUD", "Event_ResetHud", "be")
	g_iTimerEntity = create_entity( "info_target")
	entity_set_string(g_iTimerEntity, EV_SZ_classname, "hud_entity")
	register_think("hud_entity", "FwdHUDThink")
	entity_set_float(g_iTimerEntity, EV_FL_nextthink, get_gametime() + 1.0)
	g_iMaxPlayers = get_maxplayers()
	g_tWeaponNameToID = TrieCreate()
	for(new i = 0; i < WEAPON_SIZE; i++)
	{
		TrieSetCell(g_tWeaponNameToID, g_szWeaponNames[i], g_iWeaponIDs[i])
	}
	new const NO_RELOAD = (1 << 2) | (1 << CSW_KNIFE) | (1 << CSW_C4) | (1 << CSW_M3) | (1 << CSW_XM1014) | (1 << CSW_HEGRENADE) | (1 << CSW_FLASHBANG) | (1 << CSW_SMOKEGRENADE)
	new szWeaponName[20]
	for(new i = CSW_P228; i <= CSW_P90; i++) 
	{
		if( NO_RELOAD & ( 1 << i ) )
			continue;
			
		get_weaponname(i, szWeaponName, 19)
		RegisterHam(Ham_Weapon_Reload, szWeaponName, "FwdHamWeaponReload", 1)
	}
	RegisterHam(Ham_Weapon_Reload, "weapon_m3",     "FwdHamShotgunReload", 1)
	RegisterHam(Ham_Weapon_Reload, "weapon_xm1014", "FwdHamShotgunReload", 1)
	RegisterHam(Ham_TraceAttack, "player", "FwdHamTraceAttack")
	RegisterHam(Ham_Spawn, "player", "FwdPlayerSpawn", 1)
	unregister_forward(FM_PrecacheEvent, g_fwid, 1)
	register_forward(FM_PlaybackEvent, "FwdPlaybackEvent")
	register_forward(FM_CmdStart, "FwdCmdStart")
	g_iVault = nvault_open("csgoclassyquests")
	if(g_iVault == INVALID_HANDLE)
		set_fail_state("Error opening nVault")
	
	register_cvar("csgo_classy_vip_version", "1.1", 68, 0.00);
	set_cvar_string("csgo_classy_vip_version", "1.1");
	register_cvar("csgo_classy_quests_author", "renegade", 68, 0.00);
	set_cvar_string("csgo_classy_quests_author", "renegade");
}

public client_damage(iAttacker, iVictim, gDamage, iWeapon, iHitplace, TA)
{
	new szName[ 32 ]
	get_user_name( iAttacker, szName, charsmax( szName ) )
	new id = iAttacker
	new iPreviousLevel = g_iAchLevel[ iAttacker ][ TOTAL_DAMAGE ] / g_iAchsMaxPoints[ TOTAL_DAMAGE ]
	new iNewLevel = ( g_iAchLevel[ iAttacker ][ TOTAL_DAMAGE ] += gDamage ) / g_iAchsMaxPoints[ TOTAL_DAMAGE ]
	if( iNewLevel > iPreviousLevel)
	{
		set_user_scraps(id, get_user_scraps(id) + 250)
		set_user_money(id, get_user_money(id) + 500)
		client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1You've Made Your Damage Points^3'^4 quest", szName)
		client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 250 scraps and 500$ ^1for completing ^3'^1You've Made Your Damage Points^3'^4 quest")
	}
}

public FwdHamWeaponReload( const iWeapon) 
{
	new iPlayers[ 32 ], iNum, iPlayer
	get_players(iPlayers, iNum, "ah")
	for( new i = 0; i < iNum; i++ ) 
	{
		 iPlayer = iPlayers[ i ]
	}
	
	new szName[32]
	get_user_name( iPlayer, szName, charsmax( szName ) )
	if( get_pdata_int( iWeapon, m_fInReload, 4 ) ) 
	{
		g_iAchLevel[iPlayer][RELOADER]++
		switch(g_iAchLevel[iPlayer][RELOADER])
		{
			case 1000:
			{
				set_user_scraps(iPlayer, get_user_scraps(iPlayer) + 150)
				set_user_money(iPlayer, get_user_money(iPlayer) + 250)
				g_iAchLevel[iPlayer][RELOADER]++
				client_print_color(0, 0, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1Reloader^3'^4 quest", szName) 
				client_print_color(iPlayer, iPlayer, "^4[CSGO Classy]^1 You got^4 150 scraps and 250$ ^1for completing ^3'^1Reloader^3'^4 quest")
			}
		}
	}
}

public FwdHamShotgunReload( const iWeapon) 
{
	
	if( get_pdata_int( iWeapon, m_fInSpecialReload, 4 ) != 1 )
		return
	new Float:flTimeWeaponIdle = get_pdata_float( iWeapon, m_flTimeWeaponIdle, 4 )
    
	if( flTimeWeaponIdle != 0.55 )
		return
	
	new iPlayers[ 32 ], iNum, iPlayer
	get_players(iPlayers, iNum, "ah")
	for( new i = 0; i < iNum; i++ ) 
	{
		 iPlayer = iPlayers[ i ]
	}
	
	new szName[ 32 ]
	get_user_name( iPlayer, szName, charsmax( szName ) )
	g_iAchLevel[ iPlayer ][ RELOADER ]++
	switch( g_iAchLevel[ iPlayer ][ RELOADER ] )
	{
		case 1000:
		{
			set_user_scraps(iPlayer, get_user_scraps(iPlayer) + 150)
			set_user_money(iPlayer, get_user_money(iPlayer) + 250)
			g_iAchLevel[ iPlayer ][ RELOADER ]++
			client_print_color(0, 0, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1Reloader^3'^4 quest", szName ) 
			client_print_color(iPlayer, iPlayer, "^4[CSGO Classy]^1 You got^4 150 scraps and 250$ ^1for completing ^3'^1Reloader^3'^4 quest")
		}
	}
}

public FwdHUDThink( iEntity )
{
	if ( iEntity != g_iTimerEntity )
		return
		
	static id
	new szName[ 32 ]
	for ( id = 1; id <= MAX_PLAYERS; id++ )
	{
		if ( is_user_connected( id ) && ( ( get_systime() - g_iJoinTime[ id ] ) >= INTERVAL ) )
		{
			get_user_name( id, szName, charsmax( szName ) )
			g_iJoinTime[ id ] = get_systime()
			g_iAchLevel[ id ][ PLAY_AROUND ]++
			switch( g_iAchLevel[ id ][ PLAY_AROUND ] )
			{
				case 60:
				{
					g_iAchLevel[ id ][ PLAY_AROUND ]++
					set_user_scraps(id, get_user_scraps(id) + 25)
					set_user_money(id, get_user_money(id) + 50)
					client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1Play Around^3'^4 quest", szName ) 
					client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 25 scraps and 50$ ^1for completing ^3'^1Play Around^3'^4 quest")
				}
			}
		}
	}
	entity_set_float(g_iTimerEntity, EV_FL_nextthink, get_gametime() + 1.0)
}

public plugin_precache()
{
	g_fwid = register_forward(FM_PrecacheEvent, "FwdPrecacheEvent", 1)
}

public FwdPrecacheEvent(type, const name[]) 
{
	for(new i = 0; i < sizeof g_iGunEvents; ++i ) 
	{
		if(equal( g_iGunEvents[i], name)) 
		{
			g_iGunEvent_IDsBitsum |= (1<<get_orig_retval())
			return FMRES_HANDLED
		}
	}
	return FMRES_IGNORED
}

public FwdPlaybackEvent( flags, id, eventid ) 
{
	if( !( g_iGunEvent_IDsBitsum & ( 1<<eventid) ) || !(1 <= id <= g_iMaxPlayers ) )
		return FMRES_IGNORED
		
	iKillerShot[ id ] = false
	g_iShotKills[ id ] = 0

	return FMRES_HANDLED
}

public FwdHamTraceAttack( this, iAttacker, Float:damage, Float:direction[ 3 ], traceresult, damagebits )
{
	if( is_Connected[ iAttacker ] && is_Alive[ iAttacker ] )
	{
		static g_iWeapon; g_iWeapon = get_user_weapon( iAttacker )
		if( g_iWeapon == CSW_KNIFE || g_iWeapon == CSW_HEGRENADE )
		{
			return PLUGIN_HANDLED
		}
		iKillerShot[ iAttacker ] = true
	}

	return PLUGIN_HANDLED
}

public plugin_end()
{
	TrieDestroy( g_tWeaponNameToID )
	nvault_close( g_iVault )
}

public FwdPlayerSpawn(id)
{
	if( !is_user_alive( id ) )
	{
		return HAM_IGNORED
	}
	is_Alive[ id ] = true
	
	return HAM_IGNORED
}

public client_connect( id )
{
	is_dead[ id ] = false
	ResetStats( id )
}

public client_authorized( id )
{
	if( !is_user_bot( id ) && !is_user_hltv( id ) )
	{
		get_user_authid( id, g_iAuthID[ id ], charsmax( g_iAuthID[] ) )
		g_iLoadStats( id )
	}
}

public client_putinserver( id )
{
	is_Connected[ id ] = true
	if(is_Connected[ id ] )
	{
		g_iJoinTime[ id ] = get_systime()
		is_Alive[ id ] = false
		g_iDeathMessages[ id ] = true
		g_iAchLevel[ id ][ CONNECTIONS ]++   
		new szName[ 32 ]
		get_user_name( id, szName, charsmax( szName ) )

		switch( g_iAchLevel[ id ][ CONNECTIONS ] )
		{
			case 100:
			{
				set_user_scraps(id, get_user_scraps(id) + 50)
				set_user_money(id, get_user_money(id) + 100)
				client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1I'll Be Back^3'^4 quest", szName )
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 50 scraps and 100$ ^1for completing ^3'^1I'll Be Back^3'^4 quest")
			}
            
			case 250:
			{
				set_user_scraps(id, get_user_scraps(id) + 75)
				set_user_money(id, get_user_money(id) + 125)
				client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1I Like This Server^3'^4 quest", szName )
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 75 scraps and 125$ ^1for completing ^3'^1I Like This Server^3'^4 quest")
			}
            
			case 500:
			{
				set_user_scraps(id, get_user_scraps(id) + 100)
				set_user_money(id, get_user_money(id) + 150)
				client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1Half Way There^3'^4 quest", szName )
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 100 scraps and 150$ ^1for completing ^3'^1Half Way There^3'^4 quest")
			}
            
			case 1000:
			{
				set_user_scraps(id, get_user_scraps(id) + 125)
				set_user_money(id, get_user_money(id) + 175)
				client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1Ultimate Server Lover^3'^4 quest", szName )
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 125 scraps and 175$ ^1for completing ^3'^1Ultimate Server Lover^3'^4 quest")
			}
		}
	}
	
	return PLUGIN_HANDLED
}

public client_disconnected(id)
{
	g_iSaveStats(id)
	g_iJoinTime[id] = 0
	is_Connected[id] = false
	is_Alive[id] = false
}

public FwdCmdStart( id, handle )
{
	if ( !is_Connected[ id ] && !is_Alive[ id ] ) 
	{
		return FMRES_IGNORED
	}

	if( g_iAchLevel[ id ][ CAMP_FIRE ] <= 1 )
	{
		if( entity_get_int( id, EV_INT_button ) & ( IN_MOVELEFT | IN_MOVERIGHT | IN_BACK | IN_FORWARD ) )
		{
			iKillerHasNotMoved[ id ] = false
			g_iKills[ id ] = 0
		}
		else 
		{
			iKillerHasNotMoved[ id ] = true
		}
	}
	
	if( g_iAchLevel[ id ][ FLY_AWAY ] <= 1 )
	{
		if( entity_get_int( id, EV_INT_flags ) & FL_ONGROUND )
		{
			is_VictimInAir[ id ] = false
		}
		else
		{
			is_VictimInAir[ id ] = true
		}
	}
	
	if( g_iAchLevel[ id ][ DISTANCE_WALKED ] <= 2 && iKillerHasNotMoved[ id ] == false )
	{
		new Float:vecOrigin[ 3 ]
		entity_get_vector( id, EV_VEC_origin, vecOrigin )
	
		if( !xs_vec_equal( vecOldOrigin[ id ], vecNullOrigin ) )
		{
			flDistance[ id ] += get_distance_f( vecOrigin, vecOldOrigin[ id ] )
		}

		xs_vec_copy( vecOrigin, vecOldOrigin[ id ] )
		new szName[ 32 ]
		get_user_name( id, szName, charsmax( szName ) )
		switch( g_iAchLevel[ id ][ DISTANCE_WALKED ] )
		{
			case 0:
			{
				if( flDistance[ id ]/g_iFeet >= 1)
				{
					g_iAchLevel[ id ][ DISTANCE_WALKED ]++
					set_user_scraps(id, get_user_scraps(id) + 25)
					set_user_money(id, get_user_money(id) + 50)
					client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1Baby Foot Steps^3'^4 quest", szName)
					client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 25 scraps and 50$ ^1for completing ^3'^1Baby Foot Steps^3'^4 quest")	
				}
			}
			case 1:
			{
				if(flDistance[ id ]/g_iFeet >= 5280)
				{
					set_user_scraps(id, get_user_scraps(id) + 30)
					set_user_money(id, get_user_money(id) + 75)
					g_iAchLevel[id][DISTANCE_WALKED]++
					client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed the ^3'^1I'm Half Way There^3'^4 quest", szName )	
					client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 30 scraps and 75$ ^1for completing ^3'^1I'm Half Way There^3'^4 quest")
				}
			}
			case 2:
			{
				if(flDistance[id]/g_iFeet >= 52800)
				{
					set_user_scraps(id, get_user_scraps(id) + 35)
					set_user_money(id, get_user_money(id) + 100)
					g_iAchLevel[ id ][ DISTANCE_WALKED ]++
					client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed the ^3'^1Long Run^3'^4 quest", szName )
					client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 35 scraps and 100$ ^1for completing ^3'^1Long Run^3'^4 quest")
				}
			}
		}
	}
	
	new iPlayers[ 32 ], iNum, iPlayer, ctCount, tCount
	get_players( iPlayers, iNum, "ah" )
	for( new i = 0; i < iNum; i++ ) 
	{
		iPlayer = iPlayers[ i ]
		static CsTeams:iTeam
		iTeam = cs_get_user_team( iPlayers[ i ] )
		
		switch( iTeam )
		{
			case CS_TEAM_CT:
			{
				ctCount++
			}
			
			case CS_TEAM_T:
			{
				tCount++
			}
		}
	}
	
	if( ctCount == 1 || tCount == 1 )
	{
		StandAlone[ iPlayer ] = true
	}
	
	return FMRES_IGNORED
}

ResetStats( id )
{
	flDistance[ id ] = 0.0
	xs_vec_copy( vecNullOrigin, vecOldOrigin[ id ] )
}

public Event_NewRound()
{
	remove_task(0)
	
	for( new i = 0; i < g_iMaxPlayers; i++ ) 
	{
		g_iTeamKills[ i ] = 0
		g_iRoundSparys[ i ] = 0
		StandAlone[ i ] = false
	}
	g_iBombPlant = false
	g_iGetBombPlanted = 26
	
	set_task( 1.0, "CheckBombPlantedTimer", 0, _, _, "a", g_iGetBombPlanted )
}

public CheckBombPlantedTimer( )
{ 
	g_iGetBombPlanted--
	if( g_iGetBombPlanted >= 1 )
	{
		g_iGetBombDown = true	
	} 
	else 
	{	
		g_iGetBombDown = false
		remove_task(0)
	}
}

public bomb_defused(iDefuser)
{
	new szName[ 32 ]
	get_user_name( iDefuser, szName, charsmax( szName ) )
	new id = iDefuser
	
	switch( g_iAchLevel[ iDefuser ][ BOMB ] )
	{
		case 0:
		{
			if( g_iBombPlant == true )
			{
				set_user_scraps(id, get_user_scraps(id) + 125)
				set_user_money(id, get_user_money(id) + 150)
				client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1OMFG! That was close^3'^4 quest", szName ) 
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 125 scraps and 150$ ^1for completing ^3'^1OMFG! That was close^3'^4 quest")
			}

			g_iAchLevel[ iDefuser ][ BOMB ]++
		}
	}
	
	g_iAchLevel[ iDefuser ][ DEFUSED_BOMB ]++
	switch( g_iAchLevel[ iDefuser ][ DEFUSED_BOMB ])
	{
		case 50: 
		{	
			set_user_scraps(id, get_user_scraps(id) + 25)
			set_user_money(id, get_user_money(id) + 50)
			client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1C4 Defuser^3'^4 quest", szName ) 
			client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 25 scraps and 50$ ^1for completing ^3'^1C4 Defuser^3'^4 quest")	
		}

		case 100: 
		{
			set_user_scraps(id, get_user_scraps(id) + 35)
			set_user_money(id, get_user_money(id) + 65)
			client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1That Was Easy^3'^4 quest", szName ) 
			client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 35 scraps and 65$ ^1for completing ^3'^1That Was Easy^3'^4 quest")
		}

		case 150: 
		{
			set_user_scraps(id, get_user_scraps(id) + 50)
			set_user_money(id, get_user_money(id) + 70)
			client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Like a Game^3'^4 quest", szName ) 
			client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 50 scraps and 70$ ^1for completing ^3'^1Like a Game^3'^4 quest")
		}
		case 200: 
		{
			set_user_scraps(id, get_user_scraps(id) + 65)
			set_user_money(id, get_user_money(id) + 85)
			client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Master of C4^3'^4 quest!", szName )
			client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 85$ ^1for completing ^3'^1Master of C4^3'^4 quest")	
		}

		case 400: 
		{
			set_user_scraps(id, get_user_scraps(id) + 85)
			set_user_money(id, get_user_money(id) + 115)
			client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Nothing Can Blow Up^3'^4 quest", szName ) 
			client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 85 scraps and 115$ ^1for completing ^3'^1Nothing Can Blow Up^3'^4 quest")	
		}
	}
}

public bomb_planted( iPlanter )
{
	new szName[ 32 ]
	get_user_name( iPlanter, szName, charsmax( szName ) )
	new id = iPlanter
	
	g_iBombTime = get_pcvar_num( g_pCvarC4Timer )
	set_task( 1.0, "CheckC4Timer", 0, _, _, "a", g_iBombTime )
	
	g_iAchLevel[ iPlanter ][ PLANT_BOMB_COUNT ]++

	if(is_Connected[iPlanter] && is_Alive[iPlanter])
	{
		switch( g_iAchLevel[ iPlanter ][ PLANT_BOMB ] )
		{
			case 0:
			{
				if( g_iGetBombDown == true )
				{
					set_user_scraps(id, get_user_scraps(id) + 100)
					set_user_money(id, get_user_money(id) + 125)
					g_iAchLevel[ iPlanter ][ PLANT_BOMB ]++
					client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Short Fuse^3'^4 quest", szName ) 
					client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 100 scraps and 125$ ^1for completing ^3'^1Short Fuse^3'^4 quest")
				}
			}
		}
	
		switch( g_iAchLevel[ iPlanter ][ PLANT_BOMB_COUNT ]++ )
		{
			case 100:
			{
				set_user_scraps(id, get_user_scraps(id) + 45)
				set_user_money(id, get_user_money(id) + 75)
				client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Boomala, Boomala!^3'^4 quest", szName ) 
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 45 scraps and 75$ ^1for completing ^3'^1Boomala, Boomala!^3'^4 quest")
			}
		}
	}
}

public CheckC4Timer()
{ 
	g_iBombTime --
	if(g_iBombTime <= 1)
	{
		g_iBombPlant = true
		remove_task(0)
	}
}

public Event_ResetHud(id)
{
	is_dead[ id ] = false
}

public Event_GotBomb(id)
{
	g_iPlanter = id
}

public bomb_explode(g_iPlayer)
{
	if(g_iPlanter <= 0)
	{
		return PLUGIN_CONTINUE
	}
	set_task(0.5, "check_dead", 9743248)

	return PLUGIN_CONTINUE
}

public check_dead()
{
	new frags = 0
	new kname[32]
	new kteam[10]
	new kauthid[32]
	get_user_name(g_iPlanter, kname, 31)
	get_user_team(g_iPlanter, kteam, 9)
	get_user_authid(g_iPlanter, kauthid, 31)
	new id = g_iPlanter

	new players[32]
	new inum
	get_players(players, inum)
	for(new i = 0; i < inum; i++)
	{
		new team = get_user_team(players[i])
		if(is_Connected[players[i]] && !is_Alive[players[i] ] && team != 0 && team != 3)
		{
			if(!is_dead[players[i]] && team != get_user_team(g_iPlanter) && players[i] != g_iPlanter)
			{
				++frags
				message_begin(MSG_BROADCAST, 83, {0,0,0}, 0)
				write_byte(g_iPlanter)
				write_byte(players[i])
				write_byte(0)
				write_string("c4")
				message_end()

				new vname[32]
				new vteam[10]
				new vauthid[32]
				get_user_name(players[i], vname, 31)
				get_user_team(players[i], vteam, 9)
				get_user_authid(players[i], vauthid, 31)
		
				g_iPlayersKills[g_iPlanter][CSW_C4]++
				if(g_iPlayersKills[g_iPlanter][CSW_C4] == 30)
				{
					set_user_scraps(id, get_user_scraps(id) + 50)
					set_user_money(id, get_user_money(id) + 75)
					client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1C4 Killer^3'^4 quest", kname)
					client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 50 scraps and 75$ ^1for completing ^3'^1C4 Killer^3'^4 quest")
				}
			}
		}
	}

	if(frags)
	{
		frags += get_user_frags(g_iPlanter)
		set_user_frags(g_iPlanter, frags)
	}
}

public client_death(iKiller, iVictim, iWeapon, iHitplace, TK)
{
	new g_iKiller[32]
	new id = iKiller
	get_user_name(iKiller, g_iKiller, charsmax(g_iKiller))
	if((iWeapon == CSW_HEGRENADE) && !TK && is_Alive[iKiller])
	{
		g_iPlayersKills[ iKiller ][ CSW_HEGRENADE ]++
		if( g_iPlayersKills[ iKiller ][ CSW_HEGRENADE ] == 300 )
		{
			set_user_scraps(id, get_user_scraps(id) + 100)
			set_user_money(id, get_user_money(id) + 125)
			client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Grenade Expert^3'^4 quest", g_iKiller )
			client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 100 scraps and 125$ ^1for completing ^3'^1Grenade Expert^3'^4 quest")
		}
		
		g_iGrenadeKills[ iKiller ]++
		if( g_iGrenadeKills[ iKiller ] == 3 )
		{
			g_iAchLevel[ iKiller ][ HAT_TRICK ]++
			switch( g_iAchLevel[ iKiller ][ HAT_TRICK ] )
			{
				case 1:
				{
					set_user_scraps(id, get_user_scraps(id) + 35)
					set_user_money(id, get_user_money(id) + 40)
					g_iAchLevel[ iKiller ][ HAT_TRICK ]++
					client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Hat Trick^3'^4 quest", g_iKiller ) 
					client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 35 scraps and 40$ ^1for completing ^3'^1Hat Trick^3'^4 quest")
				}
			}
			g_iGrenadeKills[ iKiller ] = 0
		}

		set_task( 0.3, "ResetGrenadeKills" )
	}
}

public ResetGrenadeKills( )
{
	new iPlayers[ 32 ], iNum, iPlayer
	get_players( iPlayers, iNum, "ah" )
	
	for( new i = 0; i < iNum; i++ ) 
	{
		iPlayer = iPlayers[ i ]
	}

	g_iGrenadeKills[ iPlayer ] = 0
}

public grenade_throw( id, grenadeIndex, weaponId )
{
	new g_iName[ 32 ]
	get_user_name( id, g_iName, charsmax( g_iName ) )
	
	switch( weaponId )
	{
		case CSW_FLASHBANG:
		{
			g_iPlayersKills[ id ][ CSW_FLASHBANG ]++
			
			if( g_iPlayersKills[ id ][ CSW_FLASHBANG ] == 150 )
			{
				set_user_scraps(id, get_user_scraps(id) + 15)
				set_user_money(id, get_user_money(id) + 25)
				client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Can You See?^3'^4 quest", g_iName ) 
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 15 scraps and 25$ ^1for completing ^3'^1Can You See?^3'^4 quest")
			}
		}
	}
}

get_user_flashed( id, &iPercent=0 )
{
	new Float:flFlashedAt = get_pdata_float( id, m_flFlashedAt, XO_PLAYER )
	
	if( !flFlashedAt )
	{
		return 0
	}
	
	new Float:flGameTime = get_gametime()
	new Float:flTimeLeft = flGameTime - flFlashedAt
	new Float:flFlashDuration = get_pdata_float( id, m_flFlashDuration, XO_PLAYER )
	new Float:flFlashHoldTime = get_pdata_float( id, m_flFlashHoldTime, XO_PLAYER )
	new Float:flTotalTime = flFlashHoldTime + flFlashDuration
	
	if( flTimeLeft > flTotalTime )
	{
		return 0
	}
	
	new iFlashAlpha = get_pdata_int( id, m_iFlashAlpha, XO_PLAYER )
	
	if( iFlashAlpha == ALPHA_FULLBLINDED )
	{
		if( get_pdata_float( id, m_flFlashedUntil, XO_PLAYER) - flGameTime > 0.0 )
		{
			iPercent = 100
		}
		else
		{
			iPercent = 100-floatround( ( ( flGameTime - ( flFlashedAt + flFlashHoldTime ) ) * 100.0 )/flFlashDuration )
		}
	}
	else
	{
		iPercent = 100-floatround( ( ( flGameTime - flFlashedAt ) * 100.0 ) / flTotalTime )
	}
	
	return iFlashAlpha
}

public Event_PlayerKilled()
{	
		new iKiller = read_data( 1 )
		new iVictim = read_data( 2 )
		is_dead[ iVictim ] = true
		is_Alive[ iKiller ] = bool:is_user_alive( iKiller )
	
		if( !IsPlayer( iKiller ) || iKiller == iVictim )
		{
			return PLUGIN_HANDLED
		}

		new headshot = read_data( 3 )
		new g_iKiller[ 32 ], g_iVictim[ 32 ], g_iWeapon[ 16 ], g_iOrigin[ 3 ], g_iOrigin2[ 3 ]
		new id = iKiller
		read_data(4, g_iWeapon, 15)

		get_user_origin( iKiller, g_iOrigin )
		get_user_origin( iVictim, g_iOrigin2 )
		new flDistance = get_distance( g_iOrigin, g_iOrigin2 )
	
		get_user_name( iKiller, g_iKiller, charsmax( g_iKiller ) )
		get_user_name( iVictim, g_iVictim, charsmax( g_iVictim ) )
	
		if( iKillerShot[iKiller] == true)
		{
			g_iShotKills[ iKiller ]++
			if( g_iShotKills[ iKiller ] >= 2 )
			{
				g_iAchLevel[ iKiller ][ AMMO_CONSERVATION ]++
				switch( g_iAchLevel[ iKiller ][ AMMO_CONSERVATION ] )
				{
					case 1:
					{
						set_user_scraps(id, get_user_scraps(id) + 35)
						set_user_money(id, get_user_money(id) + 40)
						g_iAchLevel[ iKiller ][ AMMO_CONSERVATION ]++
						client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1Ammo Conservation^3'^4 quest", g_iKiller ) 
						client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 35 scraps and 40$ ^1for completing ^3'^1Ammo Conservation^3'^4 quest")					
					}
				}
				g_iShotKills[iKiller] = 0 
			}
		}

		if(headshot)
		{
			g_iAchLevel[iKiller][HEAD_SHOTS]++
			switch(g_iAchLevel[iKiller][HEAD_SHOTS])
			{
				case 300: 
				{
					set_user_scraps(id, get_user_scraps(id) + 65)
					set_user_money(id, get_user_money(id) + 100)
					client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1BOOM! Headshot^3'^4 quest", g_iKiller )
					client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 65 scraps and 100$ ^1for completing ^3'^1BOOM! Headshot^3'^4 quest")	
				}
			}
		}

		if( TrieGetCell( g_tWeaponNameToID, g_iWeapon, iWeaponID ) )
		{
			g_iPlayersKills[ iKiller ][ iWeaponID ]++
			switch( iWeaponID )
			{
				case CSW_P228:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 200: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ PISTOL_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1P250 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1P250 Expert^3'^4 quest")
						}
					}
				}

				case CSW_SCOUT:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 1000: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ RIFLE_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1SSG Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1SSG Expert^3'^4 quest")
						}
					}
				}

				case CSW_XM1014:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 200: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							g_iAchLevel[ iKiller ][ SHOTGUN_MASTER ]++
							client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1XM-1014 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1XM-1014 Expert^3'^4 quest")
						}
					}
				}

				case CSW_MAC10:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 500: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1MAC-10 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1MAC-10 Expert^3'^4 quest")	
						}
					}
				}

				case CSW_AUG:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 500:
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ RIFLE_MASTER ]++	
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1AUG Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1AUG Expert^3'^4 quest")	
						}
					}	
				}
			
				case CSW_ELITE:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 100:
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ PISTOL_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Dual Berettas Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Dual Berettas Expert^3'^4 quest")
						}
					}
				}

				case CSW_FIVESEVEN:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 100: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ PISTOL_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 %s^1 has completed ^3'^1FiveSeven Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1FiveSeven Expert^3'^4 quest")
						}
					}
				}

				case CSW_UMP45:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 1000: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1UMP-45 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1UMP-45 Expert^3'^4 quest")	
						}
					}
				}

				case CSW_SG550:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 500: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ RIFLE_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1SG-550 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1SG-550 Expert^3'^4 quest")	
						}
					}
				}

				case CSW_GALIL:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 500: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ RIFLE_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Galil-AR Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Galil-AR Expert^3'^4 quest")
						}
					}
				}

				case CSW_FAMAS:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 500: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ RIFLE_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Famas Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Famas Expert^3'^4 quest")	
						}
					}
				}

				case CSW_USP:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 200:
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ PISTOL_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1USP-S Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1USP-S Expert^3'^4 quest")
						}
					}
				}
				
				case CSW_GLOCK18:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 200:
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ PISTOL_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Glock Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Glock Expert^3'^4 quest")	
						}
					}
				}

				case CSW_AWP:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 1000:
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ RIFLE_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1AWP Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1AWP Expert^3'^4 quest")	
						}
					}
				}

				case CSW_MP5NAVY:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 1000: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1MP7 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1MP7 Expert^3'^4 quest")
						}
					}
				}

				case CSW_M249:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 500:
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1M249 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1M249 Expert^3'^4 quest")	
						}
					}
				}

				case CSW_M3:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 200: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							g_iAchLevel[ iKiller ][ SHOTGUN_MASTER ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Nova Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Nova Expert^3'^4 quest")	
						}
					}
				}

				case CSW_M4A1:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 1000:
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ RIFLE_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1M4A1-S/M4A4 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1M4A1-S/M4A4 Expert^3'^4 quest")
						}
					}
				}

				case CSW_TMP:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 1000: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1MP9 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1MP9 Expert^3'^4 quest")
						}
					}
				}

				case CSW_G3SG1:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 500:
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ RIFLE_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1SG-553 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1SG-553 Expert^3'^4 quest")
						}
					}
				}

				case CSW_DEAGLE:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 200: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ PISTOL_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Deagle Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Deagle Expert^3'^4 quest")	
						}
					}
				}

				case CSW_SG552:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 500: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ RIFLE_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1SG-552 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1SG-552 Expert^3'^4 quest")	
						}
					}
				}

				case CSW_AK47:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 1000:
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ RIFLE_MASTER ]++
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1AK-47 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1AK-47 Expert^3'^4 quest")	
						}
					}
				}

				case CSW_KNIFE:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 200: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Knife Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Knife Expert^3'^4 quest")
						}
					}
				}

				case CSW_P90:
				{
					switch( g_iPlayersKills[ iKiller ][ iWeaponID ] )
					{
						case 1000: 
						{
							set_user_scraps(id, get_user_scraps(id) + 65)
							set_user_money(id, get_user_money(id) + 80)
							g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ]++
							client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1P90 Expert^3'^4 quest", g_iKiller )
							client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1P90 Expert^3'^4 quest")	
						}
					}
				}
			}
		}

		switch( g_iAchLevel[ iKiller ][ DISTANCE_KILLED ] )
		{
			case 0:
			{
				if( floatround( flDistance/g_iFeet ) <= 5 )
				{
					set_user_scraps(id, get_user_scraps(id) + 65)
					set_user_money(id, get_user_money(id) + 80)
					g_iAchLevel[ iKiller ][ DISTANCE_KILLED ]++
					client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Short Range Kill^3'^4 quest", g_iKiller )
					client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Short Range Kill^3'^4 quest")
				}
			}
		
			case 1:
			{
				if( 6 <= floatround( flDistance/g_iFeet ) <= 50 )
				{
					set_user_scraps(id, get_user_scraps(id) + 65)
					set_user_money(id, get_user_money(id) + 80)
					g_iAchLevel[ iKiller ][ DISTANCE_KILLED ]++
					client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Nice Aim^3'^4 quest", g_iKiller )
					client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Nice Aim^3'^4 quest")
				}	
			}
		
			case 2:
			{
				if( 51 <= floatround( flDistance/g_iFeet ) <= 99 )
				{
					set_user_scraps(id, get_user_scraps(id) + 65)
					set_user_money(id, get_user_money(id) + 80)
					g_iAchLevel[ iKiller ][ DISTANCE_KILLED ]++
					client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Long Range Kill^3'^4 quest", g_iKiller )
					client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Long Range Kill^3'^4 quest")
				}
			}
	
			case 3:
			{
				if( 100 <= floatround( flDistance/g_iFeet ) <= 150 )
				{
					set_user_scraps(id, get_user_scraps(id) + 65)
					set_user_money(id, get_user_money(id) + 80)
					g_iAchLevel[ iKiller ][ DISTANCE_KILLED ]++
					client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Aim-Bot Time^3'^4 quest", g_iKiller )
					client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Aim-Bot Time^3'^4 quest")
				}
			}

			case 4:
			{
				if( 151 <= floatround( flDistance/g_iFeet ) <= 300 )
				{
					set_user_scraps(id, get_user_scraps(id) + 65)
					set_user_money(id, get_user_money(id) + 80)
					client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1I Got The Power^3'^4 quest", g_iKiller )
					client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1I Got The Power^3'^4 quest")	
				}
			}
		}
	
		g_iAchLevel[ iKiller ][ TOTAL_KILLS ]++
		switch( g_iAchLevel[ iKiller ][ TOTAL_KILLS ] )
		{
			case 5000:
			{
				set_user_scraps(id, get_user_scraps(id) + 150)
				set_user_money(id, get_user_money(id) + 250)
				client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Killer Master3'^4 quest", g_iKiller ) 
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 150 scraps and 250$ ^1for completing ^3'^1Killer Master3'^4 quest")
			}

			case 10000:
			{
				set_user_scraps(id, get_user_scraps(id) + 250)
				set_user_money(id, get_user_money(id) + 450)
				client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1God of War^3'^4 quest", g_iKiller ) 
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 250 scraps and 450$ ^1for completing ^3'^1God of War^3'^4 quest")
			}
		}
	
		switch( g_iAchLevel[ iKiller ][ PISTOL_MASTER ] )
		{
			case 6:
			{
				set_user_scraps(id, get_user_scraps(id) + 65)
				set_user_money(id, get_user_money(id) + 80)
				client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Pistol Master^3'^4 quest", g_iKiller ) 
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Pistol Master^3'^4 quest")
			}
		}

		switch( g_iAchLevel[ iKiller ][ RIFLE_MASTER ] )
		{
			case 10:
			{
				set_user_scraps(id, get_user_scraps(id) + 65)
				set_user_money(id, get_user_money(id) + 80)
				client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Rifle Master^3'^4 quest", g_iKiller ) 
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Rifle Master^3'^4 quest")
			}
		}
	
		switch( g_iAchLevel[ iKiller ][ SHOTGUN_MASTER ] )
		{
			case 2:
			{
				set_user_scraps(id, get_user_scraps(id) + 65)
				set_user_money(id, get_user_money(id) + 80)
				client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Shotgun Master^3'^4 quest", g_iKiller ) 
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Shotgun Master^3'^4 quest")
			}
		}

		switch( g_iAchLevel[ iKiller ][ MASTER_AT_ARMS ] )
		{
			case 25:
			{
				set_user_scraps(id, get_user_scraps(id) + 65)
				set_user_money(id, get_user_money(id) + 80)
				client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Master at Arms^3'^4 quest", g_iKiller ) 
				client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Master at Arms^3'^4 quest")
			}
		}
	
		if( is_VictimInAir[ iVictim ] == true )
		{
			g_iAchLevel[ iKiller ][ FLY_AWAY ]++
			switch( g_iAchLevel[ iKiller ][ FLY_AWAY ] )
			{
				case 1:
				{
					set_user_scraps(id, get_user_scraps(id) + 65)
					set_user_money(id, get_user_money(id) + 80)
					g_iAchLevel[ iKiller ][ FLY_AWAY ]++
					client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Fly Away^3'^4 quest", g_iKiller ) 
					client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Fly Away^3'^4 quest")	
				}
			}
		}

		new iPercent
		if (iPercent == 100 && get_user_flashed(id))
		{
			g_iAchLevel[ iKiller ][ SPRAY_N_PRAY ]++
			switch( g_iAchLevel[ iKiller ][ SPRAY_N_PRAY ] )
			{
				case 1:
				{
					set_user_scraps(id, get_user_scraps(id) + 65)
					set_user_money(id, get_user_money(id) + 80)
					client_print_color(0, id, "^4[CSGO Classy]^1 ^4%s^1 has completed ^3'^1Spray and Pray^3'^4 quest", g_iKiller ) 
					client_print_color(id, id,"^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Spray and Pray^3'^4 quest")	
				}
			}
		}

		if( StandAlone[ iVictim ] == true )
		{
			g_iAchLevel[ iVictim ][ STAND_ALONE ]++
			switch( g_iAchLevel[ iVictim ][ STAND_ALONE ] )
			{
				case 15:
				{
					set_user_scraps(iVictim, get_user_scraps(iVictim) + 65)
					set_user_money(iVictim, get_user_money(iVictim) + 80)
					g_iAchLevel[ iVictim ][ STAND_ALONE ]++
					client_print_color(0, iVictim, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Stand Alone^3'^4 quest", g_iVictim ) 
					client_print_color(iVictim, iVictim, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Stand Alone^3'^4 quest")	
				}
			}
		}
	
		if( get_user_health( iKiller ) == 1 )
		{
			OneHpHero[ iKiller ] = true
		}

		if(OneHpHero[ iKiller] == true)
		{
			g_iAchLevel[ iKiller ][ ONE_HP_HERO ]++
			switch( g_iAchLevel[ iKiller ][ ONE_HP_HERO ] )
			{
				case 1:
				{
					set_user_scraps(id, get_user_scraps(id) + 65)
					set_user_money(id, get_user_money(id) + 80)
					g_iAchLevel[ iKiller ][ ONE_HP_HERO ]++
					client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1One Hp Hero^3'^4 quest", g_iKiller ) 
					client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1One Hp Hero^3'^4 quest")
				}
			}
		}
	
		if( iKillerHasNotMoved[ iKiller ] == true )
		{
			g_iKills[ iKiller ]++
			if( g_iKills[ iKiller ] == 3 )
			{
				g_iAchLevel[ iKiller ][ CAMP_FIRE ]++
				switch( g_iAchLevel[ iKiller ][ CAMP_FIRE ] )
				{
					case 1:
					{
						set_user_scraps(id, get_user_scraps(id) + 65)
						set_user_money(id, get_user_money(id) + 80)
						g_iAchLevel[ iKiller ][ CAMP_FIRE ]++
						client_print_color(0, id, "^4[CSGO Classy]^3 ^4%s^1 has completed ^3'^1Camp Fire^3'^4 quest", g_iKiller ) 
						client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 65 scraps and 80$ ^1for completing ^3'^1Camp Fire^3'^4 quest")	
					}
				}
			}
		}

		return PLUGIN_HANDLED
}

public g_iLoadStats(id)
{
	static data[256]
	static timestamp
	if(nvault_lookup( g_iVault, g_iAuthID[ id ], data, sizeof( data ) - 1, timestamp))
	{
		ParseLoadData(id, data)
		return
	}

	else
	{
		NewUser(id)
	}
}

public NewUser(id)
{
	for( new iLevel = 0; iLevel < g_iAchCount; iLevel++ )
	{
		g_iAchLevel[ id ][ iLevel ] = 0
	}

	for( new i = 0; i < WEAPON_SIZE; i++ )
	{
		g_iPlayersKills[ id ][ g_iWeaponIDs[ i ] ] = 0
	}
}

ParseLoadData(id, data[256])
{
	new num[6]
	for(new i = 0; i < WEAPON_SIZE; i++)
	{
		argbreak( data, num, sizeof( num ) - 1, data, sizeof( data ) - 1 )
		g_iPlayersKills[ id ][ g_iWeaponIDs[ i ] ] = clamp( str_to_num( num ), 0, g_iAchsWeaponMaxKills[ i ] )
	}
	
	for( new iLevel = 0; iLevel < g_iAchCount; iLevel++ )
	{
		argbreak( data, num, sizeof( num ) - 1, data, sizeof( data ) - 1 )
		g_iAchLevel[ id ][ iLevel ] = clamp( str_to_num( num ), 0, g_iAchsMaxPoints[ iLevel ] )
	}
}

public g_iSaveStats(id)
{
	static data[256]
	new len
	for(new i = 0; i < WEAPON_SIZE; i++)
	{
		len += formatex( data[ len ], sizeof( data ) - len - 1, " %i", g_iPlayersKills[ id ][ g_iWeaponIDs[ i ] ] )
	}
	
	for( new iLevel = 0; iLevel < g_iAchCount; iLevel++ )
	{
		len += formatex( data[ len ], sizeof( data ) - len - 1, " %i", g_iAchLevel[ id ][ iLevel ] )
	}

	nvault_set( g_iVault, g_iAuthID[ id ], data )
}