/* Uncomment this line if you want to use only ReAPI Support*/
// Deactivated by Default
#define USE_REAPI

/*Comment the below line if you are not testing the plugin. When testing, debug information will be printed to all players */
// #define TESTING

#define CC_COLORS_TYPE CC_COLORS_NAMED_SHORT

#include <amxmodx>
#include <amxmisc>
#include <cromchat>
#include <csx>
#include <nvault>
#include <csgoclassy>

#if AMXX_VERSION_NUM < 183
#include <dhudmessage>
#endif

#include <sqlx>
#pragma defclasslib sqlite sqlite

#if defined USE_REAPI
#include <reapi>
#else
#include <hamsandwich>

const m_LastHitGroup = 					75
#endif

#if !defined MAX_NAME_LENGTH
#define MAX_NAME_LENGTH 				32
#endif

#if !defined MAX_PLAYERS
#define MAX_PLAYERS 					32
#endif

#define PLUGIN  						"Most Valuable Player"
#define VERSION 						"2.8"
#define AUTHOR  						"Shadows Adi"

#define IsPlayer(%1)					(1 <= %1 <= g_iMaxPlayers)

#define NATIVE_ERROR					-1

#define MAX_TRACK_LENGHT				64

#define MAX_CONNECT_TRY					2

#define MAX_TRACKS						64

new const CHAT_PREFIX[]			=		"CHAT_PREFIX"
new const HUD_PREFIX[]			=		"HUD_PREFIX"
new const MENU_PREFIX[]			=		"MENU_PREFIX"
new const SAVE_TYPE[] 			=		"SAVE_TYPE"
new const SQL_HOSTNAME[]		=		"SQL_HOST"
new const SQL_USERNAME[]		=		"SQL_USER"
new const SQL_PASSWORD[]		=		"SQL_PASS"
new const SQL_DATABASE[]		=		"SQL_DATABASE"
new const SQL_DBTABLE[]			=		"SQL_TABLE"
new const NVAULT_DATABASE[]		=		"NVAULT_DATABASE"
new const AUTH_METHOD[]			=		"AUTH_METHOD"
new const INSTANT_SAVE[]		=		"INSTANT_SAVE"
new const MESSAGE_TYPE[]		=		"MESSAGE_TYPE"
new const HUD_COLOR[]			=		"HUD_COLOR"
new const HUD_POSITION[]		= 		"HUD_POSITION"
new const MENU_COMMANDS[]		=		"MENU_COMMANDS"
new const VIP_ACCESS[]			=		"VIP_ACCESS"
new const LOG_FILE[]			= 		"mvp_errors.log"

static const NO_USER[]			=		"NONE"

new MenuColors[][] 			= {"\r", "\y", "\d", "\w", "\R"}

enum WinScenario
{
	NO_SCENARIO = -1,
	TERO_MVP = 0,
	CT_MVP,
	KILLER_MVP_TERO,
	KILLER_MVP_CT,
	KILLER_MVP
}

enum _:DamageData
{
	iDamage = 0,
	iHSDmg = 1
}

enum
{
	MVP_CHAT_MSG = 0,
	MVP_DHUD_MSG = 1,
	MVP_HUD_MSG = 2
}

enum
{
	TRACKS_SECTION = 1,
	SETTINGS_SECTION = 2
}

enum _:Tracks
{
	szNAME[MAX_TRACK_LENGHT],
	szPATH[MAX_TRACK_LENGHT],
	szUserName[MAX_NAME_LENGTH],
	iPrice,
	iVipOnly
}

enum _:Prefix
{
	PREFIX_CHAT[16],
	PREFIX_HUD[16],
	PREFIX_MENU[16]
}

enum _:HudSettings
{
	Float:HudPosX,
	Float:HudPosY,
	HudColorR,
	HudColorG,
	HudColorB
}

enum _:DBSettings
{
	MYSQL_HOST[32],
	MYSQL_USER[32],
	MYSQL_PASS[48],
	MYSQL_TABLE[32],
	MYSQL_DB[32],
	NVAULT_DB[32]
}

enum
{
	NVAULT = 0,
	SQL = 1,
	SQL_LITE = 2
}

enum _:PlayerType
{
	iPlanter = 0,
	iDefuser,
	iTopKiller
}

enum _:BONUS_TYPE
{
	MONEY,
	KEYS,
	CASES,
	SCRAPS
}

enum _:CVARS
{
	MAX_MONEY,
	MIN_MONEY,
	MAX_CASES,
	MIN_CASES,
	MAX_KEYS,
	MIN_KEYS,
	MAX_SCRAPS,
	MIN_SCRAPS
}

static const CSGO_MVP_CVAR_LIST[][] =
{
	"mvp_max_money",
	"mvp_min_money",
	"mvp_max_cases",
	"mvp_min_cases",
	"mvp_max_keys",
	"mvp_min_keys",
	"mvp_max_scraps",
	"mvp_min_scraps"
}

new g_eMVPCvars[CVARS]

new WinScenario:g_iScenario = NO_SCENARIO
new Array:g_aTracks

new bool:g_bAuthData
new bool:g_bExistTracks
new bool:g_bDisableTracks[MAX_PLAYERS + 1]
new bool:g_bIsBombPlanted
new bool:g_bIsBombDefused

new g_szName[MAX_PLAYERS + 1][MAX_NAME_LENGTH]
new g_szAuthID[MAX_PLAYERS + 1][20]
new g_iDamage[MAX_PLAYERS + 1][DamageData]
new g_iPlayerMVP[MAX_PLAYERS + 1]
new g_iKills[MAX_PLAYERS + 1]
new g_iUserSelectedTrack[MAX_PLAYERS + 1]
new g_eMVPlayer[PlayerType]
new g_szPlayingTrack[MAX_TRACK_LENGHT]

new g_eDBConfig[DBSettings]
new g_iHudColor[HudSettings]
new g_szPrefix[Prefix]
new g_iTracksNum
new g_iSaveType
new g_iSaveInstant
new g_iMessageType
new g_iVipFlag

new g_fHudPos[HudSettings]

new Handle:g_hSqlTuple
new Handle:g_iSqlConnection
new g_szSqlError[512]
new g_hVault

new g_IsConnected
new g_iMaxPlayers
new bool:g_bUserTracks[MAX_PLAYERS + 1][MAX_TRACKS]

new bool:g_bNotOnlyVip

new g_iMenuID
new bool:g_bOpenedFromCSGO[MAX_PLAYERS + 1]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_cvar("mvp_otr", VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)

	register_dictionary("most_valuable_player.txt")

	#if defined USE_REAPI
		RegisterHookChain(RG_CSGameRules_RestartRound, "RG_RestartRound_Post", 1)
		RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_Player_Damage_Post", 1)
		RegisterHookChain(RG_CBasePlayer_Killed, "RG_Player_Killed_Post", 1)
		RegisterHookChain(RG_RoundEnd, "RG_Round_End")
	#else
		register_event("TextMsg", "Event_Game_Restart", "a", "2&#Game_C", "2&#Game_w")
		RegisterHam(Ham_TakeDamage, "player", "Ham_Player_Damage_Post", 1)
		RegisterHam(Ham_Killed, "player", "Ham_Player_Killed_Post", 1)
		register_logevent("Logev_Roundend", 2, "1=Round_End")
		register_event("SendAudio", "Event_Terroristwin", "a", "2&%!MRAD_terwin")
		register_event("SendAudio", "Event_CTwin", "a", "2=%!MRAD_ctwin")
	#endif

	register_logevent("Logev_Roundstart", 2, "1=Round_Start")

	#if defined TESTING
	register_clcmd("say /test", "Clcmd_Say_Test")
	#endif

	g_iMaxPlayers = get_maxplayers()

	g_iMenuID = csgo_register_menu(MenuCode:MENU_INVENTORY, fmt("%l", "MVP_MENU_TITLE"))
}

public csgo_config_executed()
{
	for(new iCvar; iCvar < CVARS; iCvar++)
	{
		g_eMVPCvars[iCvar] = get_cvar_num(CSGO_MVP_CVAR_LIST[iCvar])
	}
}

public csgo_menu_item_selected(const id, const MenuCode:menu_id, const itemid)
{
	if(menu_id != MenuCode:MENU_INVENTORY || g_iMenuID != itemid)
	{
		return 
	}

	g_bOpenedFromCSGO[id] = true

	Clcmd_MVPMenu(id)

	return
}

public user_log_in_post(const id)
{
	LoadPlayerData(id);
	updateInventoryValue(id)
}

updateInventoryValue(const id)
{
	new eTrack[Tracks], iTotalInventoryValue
	
	for(new i; i < ArraySize(g_aTracks); i++)
	{
		if(g_bUserTracks[id][i])
		{
			ArrayGetArray(g_aTracks, i, eTrack)
		
			iTotalInventoryValue += eTrack[iPrice]
		}
	}

	csgo_add_inventory_item_value(id, g_iMenuID, iTotalInventoryValue)
}

public plugin_end()
{
	ArrayDestroy(g_aTracks)

	switch(g_iSaveType)
	{
		case NVAULT:
		{
			nvault_close(g_hVault)
		}
		case SQL, SQL_LITE:
		{
			SQL_FreeHandle(g_hSqlTuple)
			SQL_FreeHandle(g_iSqlConnection)
		}
	}
}

public plugin_precache()
{
	g_aTracks = ArrayCreate(Tracks)

	new szConfigsDir[256], szFileName[256]
	get_configsdir(szConfigsDir, charsmax(szConfigsDir))
	formatex(szFileName, charsmax(szFileName), "%s/MVPTracks.ini", szConfigsDir)

	#if defined TESTING
	server_print("%s", szFileName)
	#endif

	new iFile = fopen(szFileName, "rt")

	if(iFile)
	{
		new szData[256], iSection, szString[64], szValue[64], eTrack[Tracks], szTemp[3], szPrice[11]
		new szErrorMsg[128], szHudColorR[4], szHudColorG[4], szHudColorB[4], szHudPosX[5], szHudPosY[5]

		while(fgets(iFile, szData, charsmax(szData)))
		{
			trim(szData)

			if(szData[0] == '#' || szData[0] == EOS || szData[0] == ';')
				continue

			if(szData[0] == '[')
			{
				iSection += 1
				continue
			}

			switch(iSection)
			{
				case TRACKS_SECTION:
				{
					copy(eTrack[szUserName], charsmax(eTrack[szUserName]), NO_USER)
					parse(szData, eTrack[szNAME], charsmax(eTrack[szNAME]), eTrack[szPATH], charsmax(eTrack[szPATH]), szTemp, charsmax(szTemp), szPrice, charsmax(szPrice), eTrack[szUserName], charsmax(eTrack[szUserName]))

					eTrack[iVipOnly] = str_to_num(szTemp)
					eTrack[iPrice] = str_to_num(szPrice)

					#if defined TESTING
					server_print("Name: %s", eTrack[szNAME])
					server_print("Path: %s", eTrack[szPATH])
					server_print("Vip: %d", eTrack[iVipOnly])
					#endif

					if(!file_exists(eTrack[szPATH]))
					{
						formatex(szErrorMsg, charsmax(szErrorMsg), "Error. Can't precache sound %s, file doesn't exist!", eTrack[szPATH])
						log_to_file(LOG_FILE, szErrorMsg)
						continue
					}
					precache_generic(eTrack[szPATH])

					if(!eTrack[iVipOnly])
					{
						g_bNotOnlyVip = true
					}

					g_iTracksNum += 1

					ArrayPushArray(g_aTracks, eTrack)

					#if defined TESTING
					server_print("Tracks Num: %d", g_iTracksNum)
					#endif
				}
				case SETTINGS_SECTION:
				{
					strtok(szData, szString, charsmax(szString), szValue, charsmax(szValue), '=')
					trim(szString)
					trim(szValue)

					if(equal(szString, CHAT_PREFIX))
					{
						copy(g_szPrefix[PREFIX_CHAT], charsmax(g_szPrefix[PREFIX_CHAT]), szValue)
					}
					else if(equal(szString, HUD_PREFIX))
					{
						copy(g_szPrefix[PREFIX_HUD], charsmax(g_szPrefix[PREFIX_HUD]), szValue)
					}
					else if(equal(szString, MENU_PREFIX))
					{
						copy(g_szPrefix[PREFIX_MENU], charsmax(g_szPrefix[PREFIX_MENU]), szValue)
					}
					else if(equal(szString, SAVE_TYPE))
					{
						if(NVAULT <= str_to_num(szValue) <= SQL_LITE)
						{
							g_iSaveType = str_to_num(szValue)
						}
						else
						{
							g_iSaveType = 0
						}
					}
					else if(equal(szString, SQL_HOSTNAME))
					{
						if(szValue[0] == EOS)
						{
							LogReadingError(SQL_HOSTNAME)
						}
						else
						{
							copy(g_eDBConfig[MYSQL_HOST], charsmax(g_eDBConfig[MYSQL_HOST]), szValue)							
						}
					}
					else if(equal(szString, SQL_USERNAME))
					{
						if(szValue[0] == EOS)
						{
							LogReadingError(SQL_USERNAME)
						}
						else
						{
							copy(g_eDBConfig[MYSQL_USER], charsmax(g_eDBConfig[MYSQL_USER]), szValue)
						}						
					}
					else if(equal(szString, SQL_PASSWORD))
					{
						if(szValue[0] == EOS)
						{
							LogReadingError(SQL_PASSWORD)
						}
						else
						{
							copy(g_eDBConfig[MYSQL_PASS], charsmax(g_eDBConfig[MYSQL_PASS]), szValue)
						}						
					}
					else if(equal(szString, SQL_DATABASE))
					{
						if(szValue[0] == EOS)
						{
							LogReadingError(SQL_DATABASE)
						}
						else
						{
							copy(g_eDBConfig[MYSQL_DB], charsmax(g_eDBConfig[MYSQL_DB]), szValue)
						}						
					}
					else if(equal(szString, SQL_DBTABLE))
					{
						if(szValue[0] == EOS)
						{
							LogReadingError(SQL_DBTABLE)
						}
						else
						{
							copy(g_eDBConfig[MYSQL_TABLE], charsmax(g_eDBConfig[MYSQL_TABLE]), szValue)
						}						
					}
					else if(equal(szString, NVAULT_DATABASE))
					{
						if(szValue[0] == EOS)
						{
							LogReadingError(NVAULT_DATABASE)
						}
						else
						{
							copy(g_eDBConfig[NVAULT_DB], charsmax(g_eDBConfig[NVAULT_DB]), szValue)
						}
					}
					else if(equal(szString, AUTH_METHOD))
					{
						if(szValue[0] == EOS)
						{
							LogReadingError(AUTH_METHOD)
						}
						#pragma unused g_bAuthData
						g_bAuthData = bool:clamp(str_to_num(szValue), 0, 1)
					}
					else if(equal(szString, INSTANT_SAVE))
					{
						g_iSaveInstant = clamp(str_to_num(szValue), 0, 1)
					}
					else if(equal(szString, MESSAGE_TYPE))
					{
						if(MVP_CHAT_MSG <= str_to_num(szValue) <= MVP_HUD_MSG)
						{
							g_iMessageType = str_to_num(szValue)
						}
						else
						{
							g_iMessageType = MVP_DHUD_MSG
						}
					}
					else if(equal(szString, HUD_COLOR))
					{
						parse(szValue, szHudColorR, charsmax(szHudColorR), szHudColorG, charsmax(szHudColorG), szHudColorB, charsmax(szHudColorB))
						g_iHudColor[HudColorR] = str_to_num(szHudColorR)
						g_iHudColor[HudColorG] = str_to_num(szHudColorG)
						g_iHudColor[HudColorB] = str_to_num(szHudColorB)
					}
					else if(equal(szString, HUD_POSITION))
					{
						parse(szValue, szHudPosX, charsmax(szHudPosX), szHudPosY, charsmax(szHudPosY))
						g_fHudPos[HudPosX] = _:str_to_float(szHudPosX)
						g_fHudPos[HudPosY] = _:str_to_float(szHudPosY)
					}
					else if(equal(szString, MENU_COMMANDS))
					{
						while(szValue[0] != EOS && strtok(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ','))
						{
							register_clcmd(szString, "Clcmd_MVPMenu")
						}
					}
					else if(equal(szString, VIP_ACCESS))
					{
						g_iVipFlag = FindCharPos(szValue)
					}
				}
			}
		}
		fclose(iFile)
	}

	CC_SetPrefix(g_szPrefix[PREFIX_CHAT])

	if(g_iTracksNum > 0)
	{
		g_bExistTracks = true
	}

	DetectSaveType()
}

public client_authorized(id)
{
	get_user_name(id, g_szName[id], charsmax(g_szName))
	get_user_authid(id, g_szAuthID[id], charsmax(g_szAuthID))
} 

public client_putinserver(id)
{
	g_IsConnected |= ( 1 << ( id & 31 ) )

	g_iUserSelectedTrack[id] = -1

	g_bDisableTracks[id] = false

	g_iPlayerMVP[id] = 0

	g_bOpenedFromCSGO[id] = false

	for(new i; i < ArraySize(g_aTracks); i++)
	{
		g_bUserTracks[id][i] = false
	}
}

public client_disconnected(id)
{
	if(g_eMVPlayer[iTopKiller] == id && (g_iScenario == KILLER_MVP_TERO || g_iScenario == KILLER_MVP_CT))
	{
		g_eMVPlayer[iTopKiller] = -1
	}
	
	if(g_bIsBombDefused && g_eMVPlayer[iDefuser] == id)
	{
		g_eMVPlayer[iDefuser] = -1
	}
	
	if(g_bIsBombPlanted && g_eMVPlayer[iPlanter] == id)
	{
		g_eMVPlayer[iPlanter] = -1
	}

	SavePlayerData(id)
	
	g_iKills[id] = 0

	arrayset(g_iDamage[id], 0, sizeof(g_iDamage[]))

	g_IsConnected &= ~( 1 << ( id & 31 ) )
}

#if defined USE_REAPI
public RG_RestartRound_Post()
{
	new iPlayers[32], iNum
	get_players(iPlayers, iNum, "ch")

	for(new i; i < iNum; i++)
	{
		arrayset(g_iDamage[iPlayers[i]], 0, sizeof(g_iDamage[]))
	}
	arrayset(g_iKills, 0, charsmax(g_iKills))
	g_eMVPlayer[iTopKiller] = 0
	g_eMVPlayer[iPlanter] = 0
	g_eMVPlayer[iDefuser] = 0
	g_iScenario = NO_SCENARIO
	g_bIsBombDefused = false
	g_bIsBombPlanted = false
}

public RG_Player_Damage_Post(iVictim, iInflictor, iAttacker, Float:fDamage)
{
	if(!IsPlayer(iVictim) || !IsPlayer(iAttacker) || iVictim == iAttacker)
		return HC_CONTINUE

	new iHitzone = get_member(iAttacker , m_LastHitGroup)

	g_iDamage[iAttacker][iDamage] += floatround(fDamage)
	if(iHitzone == HIT_HEAD)
	{
		g_iDamage[iAttacker][iHSDmg] += floatround(fDamage)
	}

	return HC_CONTINUE
}

public RG_Player_Killed_Post(pVictim, pAttacker, iGibs)
{
	if(!IsPlayer(pVictim) || !IsPlayer(pAttacker) || pVictim == pAttacker)
		return HC_CONTINUE

	g_iKills[pAttacker]++

	return HC_CONTINUE
}

public RG_Round_End(WinStatus:status, ScenarioEventEndRound:event, Float:fDelay)
{
	switch(status)
	{
		case WINSTATUS_TERRORISTS:
		{
			if(g_bIsBombPlanted)
			{
				g_iScenario = TERO_MVP
			}
			else
			{
				g_iScenario = KILLER_MVP_TERO
			}
		}
		case WINSTATUS_CTS:
		{
			if(g_bIsBombDefused)
			{
				g_iScenario = CT_MVP
			}
			else
			{
				g_iScenario = KILLER_MVP_CT
			}
		}
	}
	set_task(1.0, "Task_Check_Scenario")

	#if defined TESTING
	client_print(0, print_chat, "rg_round_end() called")
	#endif

	return HC_CONTINUE
}
#else
public Event_Game_Restart()
{
	new iPlayers[32], iNum
	get_players(iPlayers, iNum, "ch")
	
	for(new i; i < iNum; i++)
	{
		arrayset(g_iDamage[iPlayers[i]], 0, sizeof(g_iDamage[]))
	}

	arrayset(g_iKills, 0, charsmax(g_iKills))
	g_eMVPlayer[iTopKiller] = 0
	g_eMVPlayer[iPlanter] = 0
	g_eMVPlayer[iDefuser] = 0

	g_bIsBombDefused = false
	g_bIsBombPlanted = false
}

public Ham_Player_Damage_Post(iVictim, iInflictor, iAttacker, Float:fDamage)
{
	if(!IsPlayer(iVictim) || !IsPlayer(iAttacker) || iVictim == iAttacker)
		return HAM_IGNORED

	new iHitzone = get_pdata_int( iAttacker , m_LastHitGroup )

	g_iDamage[iAttacker][iDamage] += floatround(fDamage)
	if(iHitzone == HIT_HEAD)
	{
		g_iDamage[iAttacker][iHSDmg] += floatround(fDamage)
	}

	return HAM_IGNORED
}

public Ham_Player_Killed_Post(iVictim, iAttacker)
{
	if(!IsPlayer(iVictim) || !IsPlayer(iAttacker) || iVictim == iAttacker)
		return HAM_IGNORED

	g_iKills[iAttacker]++

	return HAM_IGNORED
}

public Logev_Roundend()
{
	set_task(1.0, "Task_Check_Scenario")

	return PLUGIN_CONTINUE
}

public Event_Terroristwin()
{
	if(g_bIsBombPlanted)
	{
		g_iScenario = TERO_MVP
	}
	else
	{
		g_iScenario = KILLER_MVP_TERO
	}

	#if defined TESTING
	client_print(0, print_chat, "Event_Terroristwin called")
	#endif
}

public Event_CTwin()
{
	if(g_bIsBombDefused)
	{
		g_iScenario = CT_MVP
	}
	else
	{
		g_iScenario = KILLER_MVP_CT
	}

	#if defined TESTING
	client_print(0, print_chat, "Event_CTwin called")
	#endif
}
#endif

public Logev_Roundstart()
{
	new iPlayers[32], iNum, iPlayer
	get_players(iPlayers, iNum, "ch")

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		arrayset(g_iDamage[iPlayer], 0, sizeof(g_iDamage[]))
		arrayset(g_iKills[iPlayer], 0, sizeof(g_iKills[]))
	}

	g_eMVPlayer[iTopKiller] = 0
	g_eMVPlayer[iPlanter] = 0
	g_eMVPlayer[iDefuser] = 0
	g_iScenario = NO_SCENARIO
	g_bIsBombDefused = false
	g_bIsBombPlanted = false
}

public Task_Check_Scenario()
{
	g_szPlayingTrack[0] = '^0'
	
	switch(g_iScenario)
	{
		case NO_SCENARIO:
		{
			if(!g_eMVPlayer[iPlanter] || !g_eMVPlayer[iDefuser] || !g_eMVPlayer[iTopKiller])
			{
				ShowMVP(NO_SCENARIO)
			}
		}
		case TERO_MVP:
		{
			if(g_bIsBombPlanted && IsPlayer(g_eMVPlayer[iPlanter]))
			{
				g_iPlayerMVP[g_eMVPlayer[iPlanter]] += 1

				if(g_iUserSelectedTrack[g_eMVPlayer[iPlanter]] != -1)
				{
					PlayTrack(g_eMVPlayer[iPlanter])
				}

				ShowMVP(TERO_MVP)

				#if defined TESTING
				client_print(0, print_chat, "Scenario: TERO_MVP %d", g_iScenario)
				#endif
			}
		}
		case CT_MVP:
		{
			if(g_bIsBombDefused && IsPlayer(g_eMVPlayer[iDefuser]))
			{
				g_iPlayerMVP[g_eMVPlayer[iDefuser]] += 1

				if(g_iUserSelectedTrack[g_eMVPlayer[iDefuser]] != -1)
				{
					PlayTrack(g_eMVPlayer[iDefuser])
				}

				ShowMVP(CT_MVP)

				#if defined TESTING
				client_print(0, print_chat, "Scenario: CT_MVP %d", g_iScenario )
				#endif
			}
		}
		case KILLER_MVP_TERO:
		{
			CalculateTopKiller(KILLER_MVP_TERO)

			#if defined TESTING
			client_print(0, print_chat, "Scenario: KILLER_MVP_TERO %d", g_iScenario)
			#endif
		
		}
		case KILLER_MVP_CT:
		{
			CalculateTopKiller(KILLER_MVP_CT)

			#if defined TESTING
			client_print(0, print_chat, "Scenario: KILLER_MVP_CT %d", g_iScenario)
			#endif
		}
	}
}

public bomb_explode(id)
{
	g_eMVPlayer[iPlanter] = id
	g_bIsBombPlanted = true
	g_iScenario = TERO_MVP

	#if defined TESTING
	client_print(0, print_chat, "bomb_explode forward called")
	#endif
}

public bomb_defused(id)
{
	g_eMVPlayer[iDefuser] = id
	g_bIsBombDefused = true
	g_iScenario = CT_MVP

	#if defined TESTING
	client_print(0, print_chat, "bomb_defused forward called")
	#endif
}

#if defined TESTING
public Clcmd_Say_Test(id)
{
	client_print(id, print_chat, "Scenario: %d", g_iScenario)

	console_print(id, "DB Host: %s", g_eDBConfig[MYSQL_HOST])
	console_print(id, "DB User: %s", g_eDBConfig[MYSQL_USER])
	console_print(id, "DB Pass: %s", g_eDBConfig[MYSQL_PASS])
	console_print(id, "DB Table: %s", g_eDBConfig[MYSQL_TABLE])
	console_print(id, "DB Database: %s", g_eDBConfig[MYSQL_DB])
	console_print(id, "Nvault DB: %s", g_eDBConfig[NVAULT_DB])
	console_print(id, "Save Type: %i", g_iSaveType)
	console_print(id, "Message type: %i", g_iMessageType)
	console_print(id, "Instant Save: %i", g_iSaveInstant)
	console_print(id, "Selected Track: %i", g_iUserSelectedTrack[id])
	console_print(id, "Pushed Track Array: %i", ArraySize(g_aTracks))
	console_print(id, "Total Tracks: %i", g_iTracksNum)
}
#endif

public Clcmd_MVPMenu(id)
{
	new szTemp[128]

	formatex(szTemp, charsmax(szTemp), "\r%s \w%L^n^n\w%L", g_szPrefix[PREFIX_MENU], LANG_PLAYER, "MVP_MENU_TITLE", LANG_PLAYER, "MVP_SHOW_MVP_COUNT", g_iPlayerMVP[id])
	new menu = menu_create(szTemp, "Mvp_Menu_Handle")

	formatex(szTemp, charsmax(szTemp), "\w%L", LANG_PLAYER, "MVP_CHOOSE_TRACK")
	menu_additem(menu, szTemp)

	formatex(szTemp, charsmax(szTemp), "\w%L", LANG_PLAYER, "MVP_SOUNDS_ON_OFF", g_bDisableTracks[id] ? "OFF" : "ON")
	menu_additem(menu, szTemp)

	if(is_user_connected(id))
	{
		menu_display(id, menu)
	}
	else 
	{
		menu_destroy(menu)
	}
}

public Mvp_Menu_Handle(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_connected(id))
	{
		if(g_bOpenedFromCSGO[id])
		{
			g_bOpenedFromCSGO[id] = false
			display_menu(id, MenuCode:MENU_INVENTORY)
		}

		return MenuExit(menu)
	}

	if(!is_user_logged(id))
	{
		CC_SendMessage(id, "You must be^3 logged in^1 to access this menu")
		return MenuExit(menu)
	}

	switch(item)
	{
		case 0:
		{
			Clcmd_ChooseTrack(id)
		}
		case 1:
		{
			g_bDisableTracks[id] = !g_bDisableTracks[id]
			
			Clcmd_MVPMenu(id)
		}
	}
	return MenuExit(menu)
}

public Clcmd_ChooseTrack(id)
{
	new szTemp[128], eTrack[Tracks], szSecTemp[32]

	formatex(szTemp, charsmax(szTemp), "\r%s \w%L", g_szPrefix[PREFIX_MENU], LANG_PLAYER, "MVP_CHOOSE_TRACK_TITLE", AddCommas(get_user_money(id)))
	new menu = menu_create(szTemp, "Choose_Track_Handle")

	if(g_bExistTracks)
	{
		formatex(szSecTemp, charsmax(szSecTemp), "%L", LANG_PLAYER, "MVP_VIP_ONLY")

		for(new i, szPrice[32]; i < g_iTracksNum; i++)
		{
			ArrayGetArray(g_aTracks, i, eTrack)

			if(eTrack[iPrice] > 0)
			{
				formatex(szPrice, charsmax(szPrice), "\r[\d%i\y$\r]", eTrack[iPrice])
			}

			if(equali(eTrack[szUserName], NO_USER) || !eTrack[szUserName][0])
			{
				formatex(szTemp, charsmax(szTemp), "\w%s %s\y%s \r%s", eTrack[szNAME], eTrack[iVipOnly] ? szSecTemp : "", g_bUserTracks[id][i] ? "" : eTrack[iPrice] > 0 ? szPrice : "\r[\dFREE\r]", (i == g_iUserSelectedTrack[id]) ? "#" : "")
			}
			else
			{
				formatex(szTemp, charsmax(szTemp), "\y%s %s\y%s \r%s", eTrack[szNAME], eTrack[iVipOnly] ? szSecTemp : "", g_bUserTracks[id][i] ? "" : eTrack[iPrice] > 0 ? szPrice : "\r[\dFREE\r]", (i == g_iUserSelectedTrack[id]) ? "#" : "")
			}
			menu_additem(menu, szTemp)
		}
	}
	else
	{
		formatex(szTemp, charsmax(szTemp), "\w%L", LANG_PLAYER, "MVP_NO_TRACKS_LOADED")
		menu_additem(menu, szTemp)
	}

	if(is_user_connected(id))
	{
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
		menu_display(id, menu)
	}
	else 
	{
		menu_destroy(menu)
	}
}

public Choose_Track_Handle(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_connected(id) || !g_bExistTracks)
	{
		Clcmd_MVPMenu(id)
		goto __EXIT
	}

	new bool:bSameTrack, eTracks[Tracks]

	if(item == g_iUserSelectedTrack[id])
	{
		bSameTrack = true 
	}

	ArrayGetArray(g_aTracks, item, eTracks)

	if(eTracks[iVipOnly] && !IsUserVip(id))
	{
		CC_SendMessage(id, "^1%L", LANG_PLAYER, "MVP_TRACK_VIP_ONLY")
		goto __EXIT
	}
	
	if(eTracks[szUserName][0] && !equali(eTracks[szUserName], NO_USER))
	{
		if(!equal(g_szName[id], eTracks[szUserName]))
		{
			CC_SendMessage(id, "%L", LANG_PLAYER, "MVP_RESERVED_TRACK_CHAT", eTracks[szUserName])
			Clcmd_ChooseTrack(id)
			goto __EXIT
		}
	}

	if(!g_bUserTracks[id][item])
	{
		new iMoney = get_user_money(id)
		if(iMoney - eTracks[iPrice] < 0)
		{
			CC_SendMessage(id, "%L", LANG_PLAYER, "MVP_NOT_ENOUGH_MONEY", eTracks[iPrice] - iMoney)
			Clcmd_ChooseTrack(id)
			goto __EXIT
		}
		else 
		{
			CC_SendMessage(id, "%L", LANG_PLAYER, "MVP_TRACK_BOUGHT", eTracks[szNAME])
			g_bUserTracks[id][item] = true
			set_user_money(id, iMoney - eTracks[iPrice])
			updateInventoryValue(id)
			Clcmd_ChooseTrack(id)
		}
	}


	if(!bSameTrack)
	{
		g_iUserSelectedTrack[id] = item
		CC_SendMessage(id, "^1%L", LANG_PLAYER, "MVP_TRACK_X_SELECTED", ReplaceMColors(eTracks[szNAME], charsmax(eTracks[szNAME])))
	}
	else
	{
		g_iUserSelectedTrack[id] = -1
		CC_SendMessage(id, "^1%L", LANG_PLAYER, "MVP_TRACK_X_DESELECTED", ReplaceMColors(eTracks[szNAME], charsmax(eTracks[szNAME])))
	}

	if(g_iSaveInstant)
	{ 
		SavePlayerData(id)
	}

	__EXIT:
	return MenuExit(menu)
}

DetectSaveType()
{
	switch(g_iSaveType)
	{
		case NVAULT:
		{
			g_hVault = nvault_open(g_eDBConfig[NVAULT_DB])

			if(g_hVault == INVALID_HANDLE)
			{
				set_fail_state("MVP: Failed to open the vault");
			}
		}
		case SQL, SQL_LITE:
		{
			static iTry
			if(g_iSaveType == SQL_LITE || iTry == MAX_CONNECT_TRY || !CheckValidDatabase())
			{
				SQL_SetAffinity("sqlite")

				if(iTry)
				{
					log_to_file(LOG_FILE, "MVP: Failed to connect to MySql Database, switched to SqLite!")
				}

				if(!CheckValidDatabase())
				{
					log_to_file(LOG_FILE, "MVP: One or more data field for database is empty. Switched to SqLite!")
				}
			}

			g_hSqlTuple = SQL_MakeDbTuple(g_eDBConfig[MYSQL_HOST], g_eDBConfig[MYSQL_USER], g_eDBConfig[MYSQL_PASS], g_eDBConfig[MYSQL_DB])

			new iError
			g_iSqlConnection = SQL_Connect(g_hSqlTuple, iError, g_szSqlError, charsmax(g_szSqlError))

			if(g_iSqlConnection == Empty_Handle)
			{
				log_to_file(LOG_FILE, "MVP: Failed to connect to database. %s", iTry ? "Connecting to SqLite..." : "Retrying!")
				iTry += 1
				DetectSaveType()
				return
			}

			new Handle:iQueries = SQL_PrepareQuery(g_iSqlConnection, "CREATE TABLE IF NOT EXISTS `%s`\
				(`AuthID` VARCHAR(32) NOT NULL,\
				`Player MVP` INT NOT NULL DEFAULT 0 ,\
				`Track` INT NOT NULL DEFAULT -1 ,\
				`Disabled` INT NOT NULL DEFAULT 0,\
				`UserTracks` TEXT NOT NULL DEFAULT '0',\
				PRIMARY KEY(AuthID));", g_eDBConfig[MYSQL_TABLE])
		
			if(!SQL_Execute(iQueries))
			{
				SQL_QueryError(iQueries, g_szSqlError, charsmax(g_szSqlError))
				log_amx(g_szSqlError)
			}

			SQL_FreeHandle(iQueries)
		}
	}
}

LoadPlayerData(id)
{
	if(is_user_bot(id) || is_user_hltv(id) || !is_user_logged(id))
	{
		return
	}

	switch(g_iSaveType)
	{
		case NVAULT:
		{
			new szData[1024], iTimestamp, szBuffer[3][12], szUserTracks[MAX_TRACKS * 2 + 1]

			if(nvault_lookup(g_hVault, g_szName[id], szData, charsmax(szData), iTimestamp))
			{
				#if defined TESTING
				server_print("^n--^nLoad data: %s", szData)
				#endif

				strtok2(szData, szData, charsmax(szData), szUserTracks, charsmax(szUserTracks), '#', TRIM_FULL)

				parse(szData, szBuffer[0], charsmax(szBuffer[]), szBuffer[1], charsmax(szBuffer[]), szBuffer[2], charsmax(szBuffer[]))

				#if defined TESTING
				server_print("^nParsed data: mvp_num: %s selected_track: %s  disabled_tracks: %s", szBuffer[0], szBuffer[1], szBuffer[2])
				#endif

				g_iPlayerMVP[id] = str_to_num(szBuffer[0])
				g_iUserSelectedTrack[id] = str_to_num(szBuffer[1])
				g_bDisableTracks[id] = bool:str_to_num(szBuffer[2])

				#if defined TESTING
				server_print("--^nValues^ng_iPlayerMVP: %i^ng_iUserSelectedTracks: %i^ng_bDisabledTracks: %s", g_iPlayerMVP[id], g_iUserSelectedTrack[id], g_bDisableTracks[id] ? "true" : "false")
				#endif

				ParseUserTracks(id, szUserTracks, charsmax(szUserTracks))
			}
		}
		case SQL, SQL_LITE:
		{
			new Handle:iQuery = SQL_PrepareQuery(g_iSqlConnection, "SELECT * FROM `%s` WHERE `AuthID` = ^"%s^";", g_eDBConfig[MYSQL_TABLE], g_szName[id])
		
			if(!SQL_Execute(iQuery))
			{
				SQL_QueryError(iQuery, g_szSqlError, charsmax(g_szSqlError))
				log_to_file(LOG_FILE, g_szSqlError)
				goto _free_handle
			}

			new szQuery[256]
			new bool:bFoundData = SQL_NumResults( iQuery ) > 0 ? true : false

   			if(!bFoundData)
   			{
   				formatex(szQuery, charsmax(szQuery), "INSERT INTO `%s` (`AuthID`) VALUES (^"%s^");", g_eDBConfig[MYSQL_TABLE], g_szName[id])
   			}
   			else
   			{
   				formatex(szQuery, charsmax(szQuery), "SELECT * FROM %s WHERE `AuthID` = ^"%s^";", g_eDBConfig[MYSQL_TABLE], g_szName[id])
   			}

   			iQuery = SQL_PrepareQuery(g_iSqlConnection, szQuery)

   			if(!SQL_Execute(iQuery))
			{
				SQL_QueryError(iQuery, g_szSqlError, charsmax(g_szSqlError))
				log_to_file(LOG_FILE, g_szSqlError)
				goto _free_handle
			}

			if(bFoundData)
			{
				if(SQL_NumResults(iQuery) > 0)
				{
					new szUserTracks[MAX_TRACKS * 2 + MAX_TRACKS]
					g_iPlayerMVP[id] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Player MVP"))
					g_iUserSelectedTrack[id] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Track"))
					g_bDisableTracks[id] = bool:SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Disabled"))
					SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "UserTracks"), szUserTracks, charsmax(szUserTracks))

					ParseUserTracks(id, szUserTracks, charsmax(szUserTracks))
				}
			}

			_free_handle:
			SQL_FreeHandle(iQuery)
		}
	}
}

ParseUserTracks(const id, szUserTracks[], const iLength)
{

	new i, szHasTrack[3];
	while(i < g_iTracksNum && szUserTracks[0] && strtok2(szUserTracks, szHasTrack, charsmax(szHasTrack), szUserTracks, iLength, ','))
	{
		g_bUserTracks[id][i] = bool:str_to_num(szHasTrack)
		#if defined TESTING
		server_print("Track %i: %i [szHasTrack: %s]", i + 1, g_bUserTracks[id][i] ? 1 : 0, szHasTrack)
		#endif
		i++
	}
}

SavePlayerData(id)
{
	if(is_user_bot(id) || is_user_hltv(id) || !is_user_logged(id))
	{
		return
	}

	new szUserTracks[MAX_TRACKS * 2 + 1]
	
	for(new i = 0, iLen; i < ArraySize(g_aTracks); i++)
	{
		iLen += formatex(szUserTracks[iLen], charsmax(szUserTracks), "%d,", _:g_bUserTracks[id][i])
	}

	switch(g_iSaveType)
	{
		case NVAULT:
		{
			new szData[1024]

			formatex(szData, charsmax(szData), "%d %d %d#%s", g_iPlayerMVP[id], g_iUserSelectedTrack[id], _:g_bDisableTracks[id], szUserTracks)

			#if defined TESTING
			server_print("Saved data: %s", szData)
			#endif

			nvault_set(g_hVault, g_szName[id], szData)
		}
		case SQL, SQL_LITE:
		{
			new szQuery[1024]
			formatex(szQuery, charsmax(szQuery), "UPDATE `%s` SET `Player MVP`='%i', `Track`='%i', `Disabled`='%i', `UserTracks`='%s' WHERE `AuthID`=^"%s^";", g_eDBConfig[MYSQL_TABLE], g_iPlayerMVP[id], g_iUserSelectedTrack[id], g_bDisableTracks[id] ? 1 : 0, szUserTracks, g_szName[id])
			
			new Handle:iQuery = SQL_PrepareQuery(g_iSqlConnection, szQuery)

   			if(!SQL_Execute(iQuery))
			{
				SQL_QueryError(iQuery, g_szSqlError, charsmax(g_szSqlError))
				log_to_file(LOG_FILE, g_szSqlError)
			}

			SQL_FreeHandle(iQuery)
		}
	}
}

CalculateTopKiller(WinScenario:status)
{
	if((g_bIsBombDefused || g_bIsBombPlanted) && (g_eMVPlayer[iDefuser] || g_eMVPlayer[iPlanter]))
		return PLUGIN_HANDLED

	new iPlayers[32], iNum, iPlayer

	get_players(iPlayers, iNum, "ceh", status == KILLER_MVP_TERO ? "TERRORIST" : "CT")

	new iFrags, iTemp, iTempID, bool:bIsValid
	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		iFrags = g_iKills[iPlayer]

		if(iFrags > iTemp)
		{
			iTemp = iFrags
			iTempID = iPlayer
		}
	}

	if(0 < iTempID)
	{
		g_eMVPlayer[iTopKiller] = iTempID
		bIsValid = true
	}
	else
	{
		bIsValid = false
	}

	switch(bIsValid)
	{
		case true:
		{
			g_iPlayerMVP[g_eMVPlayer[iTopKiller]] += 1

			if(g_iUserSelectedTrack[g_eMVPlayer[iTopKiller]] != -1)
			{
				PlayTrack(g_eMVPlayer[iTopKiller])
			}

			ShowMVP(KILLER_MVP)
		}
		case false:
		{
			ShowMVP(NO_SCENARIO)
		}
	}

	return PLUGIN_HANDLED
}

ShowMVP(WinScenario:iScenario)
{
	new iRandomBonus = random(BONUS_TYPE)
	new iBonusValue, szTextMessage[64]

	switch(iRandomBonus)
	{
		case MONEY:
		{
			iBonusValue = random_num(g_eMVPCvars[MIN_MONEY], g_eMVPCvars[MAX_MONEY])

			if(iBonusValue > 0)
			{
				formatex(szTextMessage, charsmax(szTextMessage), "%l$", "MVP_BONUS_TEXT", iBonusValue)
			}
		}

		case CASES:
		{
			iBonusValue = random_num(g_eMVPCvars[MIN_CASES], g_eMVPCvars[MAX_CASES])
			
			if(iBonusValue > 0)
			{
				formatex(szTextMessage, charsmax(szTextMessage), "%l case%s", "MVP_BONUS_TEXT", iBonusValue, iBonusValue > 1 ? "s" : "")
			}
		}

		case KEYS:
		{
			iBonusValue = random_num(g_eMVPCvars[MIN_KEYS], g_eMVPCvars[MAX_KEYS])
			
			if(iBonusValue > 0)
			{
				formatex(szTextMessage, charsmax(szTextMessage), "%l key%s", "MVP_BONUS_TEXT", iBonusValue, iBonusValue > 1 ? "s" : "")
			}
		}

		case SCRAPS:
		{
			iBonusValue = random_num(g_eMVPCvars[MIN_SCRAPS], g_eMVPCvars[MAX_SCRAPS])
		
			if(iBonusValue > 0)
			{
				formatex(szTextMessage, charsmax(szTextMessage), "%l scrap%s", "MVP_BONUS_TEXT", iBonusValue, iBonusValue > 1 ? "s" : "")
			}
		}
	}

	new iMVP

	switch(iScenario)
	{
		case NO_SCENARIO:
		{
			switch(g_iMessageType)
			{
				case MVP_CHAT_MSG:
				{
					CC_SendMessage(0, "^1%L", LANG_SERVER, "NO_MVP_SHOW_CHAT")
				}
				case MVP_DHUD_MSG:
				{
					set_dhudmessage(g_iHudColor[HudColorR], g_iHudColor[HudColorG], g_iHudColor[HudColorB], g_fHudPos[HudPosX], g_fHudPos[HudPosY], 1)
					show_dhudmessage(0, "%s %L", g_szPrefix[PREFIX_HUD], LANG_SERVER, "NO_MVP_SHOW_HUD")
				}
				case MVP_HUD_MSG:
				{
					set_hudmessage(g_iHudColor[HudColorR], g_iHudColor[HudColorG], g_iHudColor[HudColorB], g_fHudPos[HudPosX], g_fHudPos[HudPosY], 1)
					show_hudmessage(0, "%s %L", g_szPrefix[PREFIX_HUD], LANG_SERVER, "NO_MVP_SHOW_HUD")
				}
			}
		}
		case TERO_MVP:
		{
			switch(g_iMessageType)
			{
				case MVP_CHAT_MSG:
				{
					CC_SendMessage(0, "^1%L", LANG_SERVER, "MVP_PLANTER_SHOW_CHAT", g_szName[g_eMVPlayer[iPlanter]])
					CC_SendMessage(0, "%L ^4%s", LANG_SERVER, (g_iUserSelectedTrack[g_eMVPlayer[iPlanter]] == -1) ? "MVP_NO_TRACK_SELECTED" : (g_bExistTracks ? "MVP_PLAYING_TRACK" : "MVP_NO_TRACKS_LOADED"), g_szPlayingTrack)
				}
				case MVP_DHUD_MSG:
				{
					set_dhudmessage(g_iHudColor[HudColorR], g_iHudColor[HudColorG], g_iHudColor[HudColorB], g_fHudPos[HudPosX], g_fHudPos[HudPosY], 1)
					show_dhudmessage(0, "%s %L^n%L %s%s%s", g_szPrefix[PREFIX_HUD], LANG_SERVER, "MVP_PLANTER_SHOW_HUD", g_szName[g_eMVPlayer[iPlanter]], LANG_SERVER, (g_iUserSelectedTrack[g_eMVPlayer[iPlanter]] == -1) ? "MVP_NO_TRACK_SELECTED" : (g_bExistTracks ? "MVP_PLAYING_TRACK" : "MVP_NO_TRACKS_LOADED"), g_szPlayingTrack, g_szPlayingTrack[0] ? ". " : "", szTextMessage)
				}
				case MVP_HUD_MSG:
				{
					set_hudmessage(g_iHudColor[HudColorR], g_iHudColor[HudColorG], g_iHudColor[HudColorB], g_fHudPos[HudPosX], g_fHudPos[HudPosY], 1)
					show_hudmessage(0, "%s %L^n%L %s%s%s", g_szPrefix[PREFIX_HUD], LANG_SERVER, "MVP_PLANTER_SHOW_HUD", g_szName[g_eMVPlayer[iPlanter]], LANG_SERVER, (g_iUserSelectedTrack[g_eMVPlayer[iPlanter]] == -1) ? "MVP_NO_TRACK_SELECTED" : (g_bExistTracks ? "MVP_PLAYING_TRACK" : "MVP_NO_TRACKS_LOADED"), g_szPlayingTrack, g_szPlayingTrack[0] ? ". " : "", szTextMessage)
				}

			}

			iMVP = g_eMVPlayer[iPlanter]
		}
		case CT_MVP:
		{
			switch(g_iMessageType)
			{
				case MVP_CHAT_MSG:
				{
					CC_SendMessage(0, "^1%L", LANG_SERVER, "MVP_DEFUSER_SHOW_CHAT", g_szName[g_eMVPlayer[iDefuser]])
					CC_SendMessage(0, "%L ^4%s", LANG_SERVER, (g_iUserSelectedTrack[g_eMVPlayer[iDefuser]] == -1) ? "MVP_NO_TRACK_SELECTED" : (g_bExistTracks ? "MVP_PLAYING_TRACK" : "MVP_NO_TRACKS_LOADED"), g_szPlayingTrack)
				}
				case MVP_DHUD_MSG:
				{
					set_dhudmessage(g_iHudColor[HudColorR], g_iHudColor[HudColorG], g_iHudColor[HudColorB], g_fHudPos[HudPosX], g_fHudPos[HudPosY], 1)
					show_dhudmessage(0, "%s %L^n%L %s%s%s", g_szPrefix[PREFIX_HUD], LANG_SERVER, "MVP_DEFUSER_SHOW_HUD", g_szName[g_eMVPlayer[iDefuser]], LANG_SERVER, (g_iUserSelectedTrack[g_eMVPlayer[iDefuser]] == -1) ? "MVP_NO_TRACK_SELECTED" : (g_bExistTracks ? "MVP_PLAYING_TRACK" : "MVP_NO_TRACKS_LOADED"), g_szPlayingTrack, g_szPlayingTrack[0] ? ". " : "", szTextMessage)
				}
				case MVP_HUD_MSG:
				{
					set_hudmessage(g_iHudColor[HudColorR], g_iHudColor[HudColorG], g_iHudColor[HudColorB], g_fHudPos[HudPosX], g_fHudPos[HudPosY], 1)
					show_hudmessage(0, "%s %L^n%L %s%s%s", g_szPrefix[PREFIX_HUD], LANG_SERVER, "MVP_DEFUSER_SHOW_HUD", g_szName[g_eMVPlayer[iDefuser]], LANG_SERVER, (g_iUserSelectedTrack[g_eMVPlayer[iDefuser]] == -1) ? "MVP_NO_TRACK_SELECTED" : (g_bExistTracks ? "MVP_PLAYING_TRACK" : "MVP_NO_TRACKS_LOADED"), g_szPlayingTrack, g_szPlayingTrack[0] ? ". " : "", szTextMessage)
				}
			}

			iMVP = g_eMVPlayer[iDefuser]
		}
		case KILLER_MVP:
		{
			switch(g_iMessageType)
			{
				case MVP_CHAT_MSG:
				{
					CC_SendMessage(0, "^1%L", LANG_SERVER, "MVP_KILLER_SHOW_CHAT", g_szName[g_eMVPlayer[iTopKiller]], g_iKills[g_eMVPlayer[iTopKiller]])
					CC_SendMessage(0, "%L ^4%s", LANG_SERVER, (g_iUserSelectedTrack[g_eMVPlayer[iTopKiller]] == -1) ? "MVP_NO_TRACK_SELECTED" : (g_bExistTracks ? "MVP_PLAYING_TRACK" : "MVP_NO_TRACKS_LOADED"), g_szPlayingTrack)
				}
				case MVP_DHUD_MSG:
				{
					set_dhudmessage(g_iHudColor[HudColorR], g_iHudColor[HudColorG], g_iHudColor[HudColorB], g_fHudPos[HudPosX], g_fHudPos[HudPosY], 1)
					show_dhudmessage(0, "%s %L^n%L %s%s%s", g_szPrefix[PREFIX_HUD], LANG_SERVER, "MVP_KILLER_SHOW_HUD", g_szName[g_eMVPlayer[iTopKiller]], g_iKills[g_eMVPlayer[iTopKiller]], LANG_SERVER, (g_iUserSelectedTrack[g_eMVPlayer[iTopKiller]] == -1) ? "MVP_NO_TRACK_SELECTED" : (g_bExistTracks ? "MVP_PLAYING_TRACK" : "MVP_NO_TRACKS_LOADED") , g_szPlayingTrack, g_szPlayingTrack[0] ? ". " : "", szTextMessage)
				}
				case MVP_HUD_MSG:
				{
					set_hudmessage(g_iHudColor[HudColorR], g_iHudColor[HudColorG], g_iHudColor[HudColorB], g_fHudPos[HudPosX], g_fHudPos[HudPosY], 1)
					show_hudmessage(0, "%s %L^n%L %s%s%s", g_szPrefix[PREFIX_HUD], LANG_SERVER, "MVP_KILLER_SHOW_HUD", g_szName[g_eMVPlayer[iTopKiller]], g_iKills[g_eMVPlayer[iTopKiller]], LANG_SERVER, (g_iUserSelectedTrack[g_eMVPlayer[iTopKiller]] == -1) ? "MVP_NO_TRACK_SELECTED" : (g_bExistTracks ? "MVP_PLAYING_TRACK" : "MVP_NO_TRACKS_LOADED"), g_szPlayingTrack, g_szPlayingTrack[0] ? ". " : "", szTextMessage)
				}
			}

			iMVP = g_eMVPlayer[iTopKiller]
		}
	}

	if(!is_user_connected(iMVP))
	{
		return
	}

	if(!is_user_logged(iMVP))
	{
		CC_SendMessage(0, "^1%L", LANG_SERVER, "MVP_USER_NOT_LOGGED_IN", iMVP)
		return
	}
	
	switch(iRandomBonus)
	{
		case MONEY: 	set_user_money(iMVP, get_user_money(iMVP) + iBonusValue)
		case CASES: 	set_user_cases(iMVP, get_user_cases(iMVP) + iBonusValue)
		case KEYS: 		set_user_keys(iMVP, get_user_keys(iMVP) + iBonusValue)
		case SCRAPS: 	set_user_scraps(iMVP, get_user_scraps(iMVP) + iBonusValue)
	}
}

PlayTrack(iIndex)
{
	if(!g_bExistTracks)
	{
		return
	}

	new iPlayers[MAX_PLAYERS], iPlayer, iNum
	get_players(iPlayers, iNum, "ch")

	new eTrack[Tracks], iRandom, Array:aTempArray, bool:bTakeTemp, iTempID
	if(g_bNotOnlyVip)
	{
		aTempArray = ArrayCreate(Tracks)
		for(new i; i < ArraySize(g_aTracks); i++)
		{
			ArrayGetArray(g_aTracks, i, eTrack)

			if(!eTrack[iVipOnly])
			{
				ArrayPushCell(aTempArray, i)
			}
		}
	}

	if(g_iUserSelectedTrack[iIndex] != -1 && g_iUserSelectedTrack[iIndex] <= ArraySize(g_aTracks))
	{
		ArrayGetArray(g_aTracks, g_iUserSelectedTrack[iIndex], eTrack)
		if(eTrack[iVipOnly] && !IsUserVip(iIndex))
		{
			if(g_bNotOnlyVip)
			{
				bTakeTemp = true
			}
			g_iUserSelectedTrack[iIndex] = -1
		}
	}
	else
	{
		if(!IsUserVip(iIndex) && g_bNotOnlyVip)
		{
			bTakeTemp = true
		}

		new iSize = ArraySize(bTakeTemp ? aTempArray : g_aTracks)

		iRandom = iSize > 1 ? random_num(0, iSize - 1) : (iSize - 1)

		if(bTakeTemp)
		{
			iTempID = ArrayGetCell(aTempArray, iRandom)
		}

		ArrayGetArray(g_aTracks, bTakeTemp ? iTempID : iRandom , eTrack)
	}

	if(g_bNotOnlyVip)
	{
		ArrayDestroy(aTempArray)
	}

	copy(g_szPlayingTrack, charsmax(g_szPlayingTrack), eTrack[szNAME])
	ReplaceMColors(g_szPlayingTrack, charsmax(g_szPlayingTrack))

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(!g_bDisableTracks[iPlayer])
		{
			PlaySound(iPlayer, eTrack[szPATH])
		}
	}
}

PlaySound(id, szTrack[])
{
	if(g_IsConnected & ( 1 << ( id & 31 ) ) )
	{
	// Stopping any sound playing.
		client_cmd(id, "stopsound")
		client_cmd(id, "mp3 play ^"%s^"", szTrack)
	}
}

MenuExit(const menu)
{
	menu_destroy(menu)

	return PLUGIN_HANDLED
}

ReplaceMColors(szString[], iLen)
{
	new szTemp[64]
	for(new i; i < sizeof(MenuColors); i++)
	{
		replace_all(szString, iLen, MenuColors[i], "")
	}

	formatex(szTemp, iLen, szString)

	return szTemp
}

IsUserVip(id)
{
	if(g_iVipFlag < 0)
	{
		abort(AMX_ERR_PARAMS, "[MVP] VIP_ACCESS parameter must be an ASCII alphabet character!")
	}

	if(get_user_flags(id) & (1 << (g_iVipFlag - 1)))
		return true

	return false
}

FindCharPos(Char[])
{
	if(isalpha(Char[0]))
	{
		return (Char[0] & 31)
	}
	return -1;
}

LogReadingError(const szError[])
{
	log_to_file(LOG_FILE, "[MVP] You have a missing parameter on line ^"%s^"", szError)
}

bool:CheckValidDatabase()
{
	if(g_eDBConfig[MYSQL_HOST][0] != EOS && g_eDBConfig[MYSQL_USER][0] != EOS && g_eDBConfig[MYSQL_PASS][0] != EOS && g_eDBConfig[MYSQL_DB][0] != EOS)
	{
		return true
	}
	return false
}