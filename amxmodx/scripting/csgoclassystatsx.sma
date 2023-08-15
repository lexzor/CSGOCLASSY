#include <amxmodx>
#include <amxmisc>
#include <csx>

#define HUD_DURATION_CVAR   "amx_statsx_duration"
#define HUD_DURATION        "12.0"

#define HUD_FREEZE_LIMIT_CVAR   "amx_statsx_freeze"
#define HUD_FREEZE_LIMIT        "-2.0"

#define HUD_MIN_DURATION    0.2

#define MODE_HUD_DELAY      0 

public KillerChat           = 0

public ShowAttackers        = 0
public ShowVictims          = 0
public ShowKiller           = 0
public ShowTeamScore        = 0
public ShowTotalStats       = 0
public ShowBestScore        = 0
public ShowMostDisruptive   = 0

public EndPlayer            = 0
public EndTop15             = 0

public SayHP                = 0
public SayStatsMe           = 0
public SayRankStats         = 0
public SayMe                = 0
public SayRank              = 0
public SayReport            = 0
public SayScore             = 0
public SayTop15             = 0
public SayStatsAll          = 0

public ShowStats            = 1
public ShowDistHS           = 0

public ShowFullStats        = 0

public SpecRankInfo         = 0

#define MAX_TEAMS               2

#define MAX_WEAPON_LENGTH       31
#define MAX_TEXT_LENGTH         255
#define MAX_BUFFER_LENGTH       2047

#define STATS_KILLS             0
#define STATS_DEATHS            1
#define STATS_HS                2
#define STATS_TKS               3
#define STATS_SHOTS             4
#define STATS_HITS              5
#define STATS_DAMAGE            6

new BODY_PART[8][] =
{
	"WHOLEBODY", 
	"HEAD", 
	"CHEST", 
	"STOMACH", 
	"LEFTARM", 
	"RIGHTARM", 
	"LEFTLEG", 
	"RIGHTLEG"
}

#define KILLED_KILLER_ID        0 
#define KILLED_KILLER_HEALTH    1 
#define KILLED_KILLER_ARMOUR    2
#define KILLED_TEAM             3
#define KILLED_KILLER_STATSFIX  4

new g_izKilled[MAX_PLAYERS + 1][5]

#define MAX_PPL_MENU_ACTIONS    2
#define PPL_MENU_OPTIONS        7

new g_iPluginMode                                   = 0

new g_izUserMenuPosition[MAX_PLAYERS + 1]               = {0, ...}
new g_izUserMenuAction[MAX_PLAYERS + 1]                 = {0, ...}
new g_izUserMenuPlayers[MAX_PLAYERS + 1][32]

new g_izSpecMode[MAX_PLAYERS + 1]                       = {0, ...}

new g_izShowStatsFlags[MAX_PLAYERS + 1]                 = {0, ...}
new g_izStatsSwitch[MAX_PLAYERS + 1]                    = {0, ...}
new Float:g_fzShowUserStatsTime[MAX_PLAYERS + 1]        = {0.0, ...}
new Float:g_fShowStatsTime                          = 0.0
new Float:g_fFreezeTime                             = 0.0
new Float:g_fFreezeLimitTime                        = 0.0
new Float:g_fHUDDuration                            = 0.0

new g_iRoundEndTriggered                            = 0
new g_iRoundEndProcessed                            = 0

new Float:g_fStartGame                              = 0.0
new g_izTeamScore[MAX_TEAMS]                        = {0, ...}
new g_izTeamEventScore[MAX_TEAMS]                   = {0, ...}
new g_izTeamRndStats[MAX_TEAMS][8]
new g_izTeamGameStats[MAX_TEAMS][8]
new g_izUserUserID[MAX_PLAYERS + 1]                     = {0, ...}
new g_izUserAttackerDistance[MAX_PLAYERS + 1]           = {0, ...}
new g_izUserVictimDistance[MAX_PLAYERS + 1][MAX_PLAYERS + 1]
new g_izUserRndName[MAX_PLAYERS + 1][MAX_NAME_LENGTH + 1]
new g_izUserRndStats[MAX_PLAYERS + 1][8]
new g_izUserGameStats[MAX_PLAYERS + 1][8]

new g_sBuffer[MAX_BUFFER_LENGTH + 1]                = ""
new g_sScore[MAX_TEXT_LENGTH + 1]                   = ""
new g_sAwardAndScore[MAX_BUFFER_LENGTH + 1]         = ""

new t_sText[MAX_TEXT_LENGTH + 1]                    = ""
new t_sName[MAX_NAME_LENGTH + 1]                    = ""
new t_sWpn[MAX_WEAPON_LENGTH + 1]                   = ""

new g_HudSync_EndRound
new g_HudSync_SpecInfo


public plugin_init()
{
	register_plugin("CSGO Classy StatsX", AMXX_VERSION_STR, "renegade")
	register_dictionary("statsx.txt")

	register_event("TextMsg", "eventStartGame", "a", "2=#Game_Commencing", "2=#Game_will_restart_in")
	register_event("ResetHUD", "eventResetHud", "be")
	register_event("RoundTime", "eventStartRound", "bc")
	register_event("SendAudio", "eventEndRound", "a", "2=%!MRAD_terwin", "2=%!MRAD_ctwin", "2=%!MRAD_rounddraw")
	register_event("TeamScore", "eventTeamScore", "a")
	register_event("30", "eventIntermission", "a")
	register_event("TextMsg", "eventSpecMode", "bd", "2&ec_Mod")
	register_event("StatusValue", "eventShowRank", "bd", "1=2")

	register_clcmd("say /hp", "cmdHp", 0, "- display info. about your killer (chat)")
	register_clcmd("say /statsme", "cmdStatsMe", 0, "- display your stats (MOTD)")
	register_clcmd("say /rankstats", "cmdRankStats", 0, "- display your server stats (MOTD)")
	register_clcmd("say /me", "cmdMe", 0, "- display current round stats (chat)")
	register_clcmd("say /score", "cmdScore", 0, "- display last score (chat)")
	register_clcmd("say /rank", "cmdRank", 0, "- display your rank (chat)")
	register_clcmd("say /report", "cmdReport", 0, "- display weapon status (say_team)")
	register_clcmd("say /top15", "cmdTop15", 0, "- display top 15 players (MOTD)")
	register_clcmd("say /stats", "cmdStats", 0, "- display players stats (menu/MOTD)")
	register_clcmd("say /switch", "cmdSwitch", 0, "- switch client's stats on or off")
	register_clcmd("say_team /hp", "cmdHp", 0, "- display info. about your killer (chat)")
	register_clcmd("say_team /statsme", "cmdStatsMe", 0, "- display your stats (MOTD)")
	register_clcmd("say_team /rankstats", "cmdRankStats", 0, "- display your server stats")
	register_clcmd("say_team /me", "cmdMe", 0, "- display current round stats (chat)")
	register_clcmd("say_team /score", "cmdScore", 0, "- display last score (chat)")
	register_clcmd("say_team /rank", "cmdRank", 0, "- display your rank (chat)")
	register_clcmd("say_team /report", "cmdReport", 0, "- display weapon status (say_team_team)")
	register_clcmd("say_team /top15", "cmdTop15", 0, "- display top 15 players (MOTD)")
	register_clcmd("say_team /stats", "cmdStats", 0, "- display players stats (menu/MOTD)")
	register_clcmd("say_team /switch", "cmdSwitch", 0, "- switch client's stats on or off")

	register_menucmd(register_menuid("Server Stats"), 1023, "actionStatsMenu")

	register_srvcmd("amx_statsx_mode", "cmdPluginMode", ADMIN_CFG, "<flags> - sets plugin options")

	register_cvar(HUD_DURATION_CVAR, HUD_DURATION)
	register_cvar(HUD_FREEZE_LIMIT_CVAR, HUD_FREEZE_LIMIT)

	g_sBuffer[0] = 0
	save_team_chatscore()
	
	g_HudSync_EndRound = CreateHudSyncObj()
	g_HudSync_SpecInfo = CreateHudSyncObj()
}

public plugin_cfg()
{
	new addStast[] = "amx_statscfg add ^"%s^" %s"

	server_cmd(addStast, "ST_SHOW_KILLER_CHAT", "KillerChat")
	server_cmd(addStast, "ST_SHOW_ATTACKERS", "ShowAttackers")
	server_cmd(addStast, "ST_SHOW_VICTIMS", "ShowVictims")
	server_cmd(addStast, "ST_SHOW_KILLER", "ShowKiller")
	server_cmd(addStast, "ST_SHOW_TEAM_SCORE", "ShowTeamScore")
	server_cmd(addStast, "ST_SHOW_TOTAL_STATS", "ShowTotalStats")
	server_cmd(addStast, "ST_SHOW_BEST_SCORE", "ShowBestScore")
	server_cmd(addStast, "ST_SHOW_MOST_DISRUPTIVE", "ShowMostDisruptive")
	server_cmd(addStast, "ST_SHOW_HUD_STATS_DEF", "ShowStats")
	server_cmd(addStast, "ST_SHOW_DIST_HS_HUD", "ShowDistHS")
	server_cmd(addStast, "ST_STATS_PLAYER_MAP_END", "EndPlayer")
	server_cmd(addStast, "ST_STATS_TOP15_MAP_END", "EndTop15")
	server_cmd(addStast, "ST_SAY_HP", "SayHP")
	server_cmd(addStast, "ST_SAY_STATSME", "SayStatsMe")
	server_cmd(addStast, "ST_SAY_RANKSTATS", "SayRankStats")
	server_cmd(addStast, "ST_SAY_ME", "SayMe")
	server_cmd(addStast, "ST_SAY_RANK", "SayRank")
	server_cmd(addStast, "ST_SAY_REPORT", "SayReport")
	server_cmd(addStast, "ST_SAY_SCORE", "SayScore")
	server_cmd(addStast, "ST_SAY_TOP15", "SayTop15")
	server_cmd(addStast, "ST_SAY_STATS", "SayStatsAll")
	server_cmd(addStast, "ST_SPEC_RANK", "SpecRankInfo")

	get_config_cvars()
}

set_hudtype_killer(Float:fDuration)
	set_hudmessage(47, 79, 79, 0.05, 0.15, 0, 6.0, fDuration, (fDuration >= g_fHUDDuration) ? 1.0 : 0.0, 1.0, -1)

set_hudtype_endround(Float:fDuration)
{
	set_hudmessage(47, 79, 79, 0.05, 0.55, 0, 6.0, fDuration, (fDuration >= g_fHUDDuration) ? 1.0 : 0.0, 1.0, -1)
}

set_hudtype_attacker(Float:fDuration)
{
	set_hudmessage(47, 79, 79, 0.75, 0.35, 0, 6.0, fDuration, (fDuration >= g_fHUDDuration) ? 1.0 : 0.0, 1.0, -1)
}
set_hudtype_victim(Float:fDuration)
{
	set_hudmessage(47, 79, 79, 0.75, 0.60, 0, 6.0, fDuration, (fDuration >= g_fHUDDuration) ? 1.0 : 0.0, 1.0, -1)
}
set_hudtype_specmode()
{
	set_hudmessage(47, 79, 79, 0.02, 0.96, 2, 0.05, 0.1, 0.01, 3.0, -1)
}

Float:accuracy(izStats[8])
{
	if (!izStats[STATS_SHOTS])
		return (0.0)
	
	return (100.0 * float(izStats[STATS_HITS]) / float(izStats[STATS_SHOTS]))
}

Float:effec(izStats[8])
{
	if (!izStats[STATS_KILLS])
		return (0.0)
	
	return (100.0 * float(izStats[STATS_KILLS]) / float(izStats[STATS_KILLS] + izStats[STATS_DEATHS]))
}

Float:distance(iDistance)
{
	return float(iDistance) * 0.0254
}

set_plugin_mode(id, sFlags[])
{
	if (sFlags[0])
		g_iPluginMode = read_flags(sFlags)
	
	get_flags(g_iPluginMode, t_sText, MAX_TEXT_LENGTH)
	console_print(id, "%L", id, "MODE_SET_TO", t_sText)
	
	return g_iPluginMode
}

get_config_cvars()
{
	g_fFreezeTime = get_cvar_float("mp_freezetime")
	
	if (g_fFreezeTime < 0.0)
		g_fFreezeTime = 0.0

	g_fHUDDuration = get_cvar_float(HUD_DURATION_CVAR)
	
	if (g_fHUDDuration < 1.0)
		g_fHUDDuration = 1.0

	g_fFreezeLimitTime = get_cvar_float(HUD_FREEZE_LIMIT_CVAR)
}

get_attackers(id, sBuffer[MAX_BUFFER_LENGTH + 1])
{
	new izStats[8], izBody[8]
	new iAttacker
	new iFound, iLen
	new iMaxPlayer = get_maxplayers()

	iFound = 0
	sBuffer[0] = 0

	izStats[STATS_SHOTS] = 0
	iAttacker = g_izKilled[id][KILLED_KILLER_ID]
	
	if (iAttacker)
		get_user_astats(id, iAttacker, izStats, izBody)
	
	if (izStats[STATS_SHOTS] && ShowFullStats)
	{
		get_user_name(iAttacker, t_sName, MAX_NAME_LENGTH)
		iLen = format(sBuffer, MAX_BUFFER_LENGTH, "%L -- %s -- %0.2f%% %L:^n", id, "ATTACKERS", t_sName, accuracy(izStats), id, "ACC")
	}
	else
		iLen = format(sBuffer, MAX_BUFFER_LENGTH, "%L^n", id, "ATTACKERS")

	for (iAttacker = 1; iAttacker <= iMaxPlayer; iAttacker++)
	{
		if (get_user_astats(id, iAttacker, izStats, izBody, t_sWpn, MAX_WEAPON_LENGTH))
		{
			iFound = 1
			get_user_name(iAttacker, t_sName, MAX_NAME_LENGTH)
			
			if (izStats[STATS_KILLS])
			{
				if (!ShowDistHS)
					iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%s [%d %L | %d %L | %s]^n", t_sName, izStats[STATS_HITS], id, "HIT_S", 
									izStats[STATS_DAMAGE], id, "DMG", t_sWpn)
				else if (izStats[STATS_HS])
					iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%s [%d %L | %d %L | %s | %0.0f m | HS]^n", t_sName, izStats[STATS_HITS], id, "HIT_S", 
									izStats[STATS_DAMAGE], id, "DMG", t_sWpn, distance(g_izUserAttackerDistance[id]))
				else
					iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%s [%d %L | %d %L | %s | %0.0f m]^n", t_sName, izStats[STATS_HITS], id, "HIT_S", 
									izStats[STATS_DAMAGE], id, "DMG", t_sWpn, distance(g_izUserAttackerDistance[id]))
			}
			else
				iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%s [%d %L | %d %L]^n", t_sName, izStats[STATS_HITS], id, "HIT_S", izStats[STATS_DAMAGE], id, "DMG")
		}
	}
	
	if (!iFound)
		sBuffer[0] = 0
	
	return iFound
}

get_victims(id, sBuffer[MAX_BUFFER_LENGTH + 1])
{
	new izStats[8], izBody[8]
	new iVictim
	new iFound, iLen
	new iMaxPlayer = get_maxplayers()

	iFound = 0
	sBuffer[0] = 0

	izStats[STATS_SHOTS] = 0
	get_user_vstats(id, 0, izStats, izBody)
	
	if (izStats[STATS_SHOTS])
		iLen = format(sBuffer, MAX_BUFFER_LENGTH, "%L [%0.2f%% %L]^n", id, "VICTIMS", accuracy(izStats), id, "ACC")
	else
		iLen = format(sBuffer, MAX_BUFFER_LENGTH, "%L^n", id, "VICTIMS")

	for (iVictim = 1; iVictim <= iMaxPlayer; iVictim++)
	{
		if (get_user_vstats(id, iVictim, izStats, izBody, t_sWpn, MAX_WEAPON_LENGTH))
		{
			iFound = 1
			get_user_name(iVictim, t_sName, MAX_NAME_LENGTH)
			
			if (izStats[STATS_DEATHS])
			{
				if (!ShowDistHS)
					iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%s [%d %L | %d %L | %s]^n", t_sName, izStats[STATS_HITS], id, "HIT_S", 
									izStats[STATS_DAMAGE], id, "DMG", t_sWpn)
				else if (izStats[STATS_HS])
					iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%s [%d %L | %d %L | %s | %0.0f m | HS]^n", t_sName, izStats[STATS_HITS], id, "HIT_S", 
									izStats[STATS_DAMAGE], id, "DMG", t_sWpn, distance(g_izUserVictimDistance[id][iVictim]))
				else
					iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%s [%d %L | %d %L | %s | %0.0f m]^n", t_sName, izStats[STATS_HITS], id, "HIT_S", 
									izStats[STATS_DAMAGE], id, "DMG", t_sWpn, distance(g_izUserVictimDistance[id][iVictim]))
			}
			else
				iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%s [%d %L | %d %L]^n", t_sName, izStats[STATS_HITS], id, "HIT_S", izStats[STATS_DAMAGE], id, "DMG")
		}
	}
	
	if (!iFound)
		sBuffer[0] = 0

	return iFound
}

get_kill_info(id, iKiller, sBuffer[MAX_BUFFER_LENGTH + 1])
{
	new iFound, iLen

	iFound = 0
	sBuffer[0] = 0

	if (iKiller && iKiller != id)
	{
		new izAStats[8], izABody[8], izVStats[8], iaVBody[8]

		iFound = 1
		get_user_name(iKiller, t_sName, MAX_NAME_LENGTH)

		izAStats[STATS_HITS] = 0
		izAStats[STATS_DAMAGE] = 0
		t_sWpn[0] = 0
		get_user_astats(id, iKiller, izAStats, izABody, t_sWpn, MAX_WEAPON_LENGTH)

		izVStats[STATS_HITS] = 0
		izVStats[STATS_DAMAGE] = 0
		get_user_vstats(id, iKiller, izVStats, iaVBody)

		iLen = format(sBuffer, MAX_BUFFER_LENGTH, "%L^n", id, "KILLED_YOU_DIST", t_sName, t_sWpn, distance(g_izUserAttackerDistance[id]))
		iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%L^n", id, "DID_DMG_HITS", izAStats[STATS_DAMAGE], izAStats[STATS_HITS], g_izKilled[id][KILLED_KILLER_HEALTH], g_izKilled[id][KILLED_KILLER_ARMOUR])
		iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%L^n", id, "YOU_DID_DMG", izVStats[STATS_DAMAGE], izVStats[STATS_HITS])
	}
	
	return iFound
}
add_most_disruptive(sBuffer[MAX_BUFFER_LENGTH + 1])
{
	new id, iMaxDamageId, iMaxDamage, iMaxHeadShots

	iMaxDamageId = 0
	iMaxDamage = 0
	iMaxHeadShots = 0

	for (id = 1; id < MAX_PLAYERS; id++)
	{
		if (g_izUserRndStats[id][STATS_DAMAGE] >= iMaxDamage && (g_izUserRndStats[id][STATS_DAMAGE] > iMaxDamage || g_izUserRndStats[id][STATS_HS] > iMaxHeadShots))
		{
			iMaxDamageId = id
			iMaxDamage = g_izUserRndStats[id][STATS_DAMAGE]
			iMaxHeadShots = g_izUserRndStats[id][STATS_HS]
		}
	}
	if (iMaxDamageId)
	{
		id = iMaxDamageId
		
		new Float:fGameEff = effec(g_izUserGameStats[id])
		new Float:fRndAcc = accuracy(g_izUserRndStats[id])
		
		format(t_sText, MAX_TEXT_LENGTH, "%L: %s^n%d %L / %d %L -- %0.2f%% %L / %0.2f%% %L^n", LANG_SERVER, "MOST_DMG", g_izUserRndName[id], 
				g_izUserRndStats[id][STATS_HITS], LANG_SERVER, "HIT_S", iMaxDamage, LANG_SERVER, "DMG", fGameEff, LANG_SERVER, "EFF", fRndAcc, LANG_SERVER, "ACC")
		add(sBuffer, MAX_BUFFER_LENGTH, t_sText)
	}
	
	return iMaxDamageId
}

add_best_score(sBuffer[MAX_BUFFER_LENGTH + 1])
{
	new id, iMaxKillsId, iMaxKills, iMaxHeadShots

	iMaxKillsId = 0
	iMaxKills = 0
	iMaxHeadShots = 0

	for (id = 1; id < MAX_PLAYERS; id++)
	{
		if (g_izUserRndStats[id][STATS_KILLS] >= iMaxKills && (g_izUserRndStats[id][STATS_KILLS] > iMaxKills || g_izUserRndStats[id][STATS_HS] > iMaxHeadShots))
		{
			iMaxKillsId = id
			iMaxKills = g_izUserRndStats[id][STATS_KILLS]
			iMaxHeadShots = g_izUserRndStats[id][STATS_HS]
		}
	}
	if (iMaxKillsId)
	{
		id = iMaxKillsId
		
		new Float:fGameEff = effec(g_izUserGameStats[id])
		new Float:fRndAcc = accuracy(g_izUserRndStats[id])
		
		format(t_sText, MAX_TEXT_LENGTH, "%L: %s^n%d %L / %d hs -- %0.2f%% %L / %0.2f%% %L^n", LANG_SERVER, "BEST_SCORE", g_izUserRndName[id], 
				iMaxKills, LANG_SERVER, "KILL_S", iMaxHeadShots, fGameEff, LANG_SERVER, "EFF", fRndAcc, LANG_SERVER, "ACC")
		add(sBuffer, MAX_BUFFER_LENGTH, t_sText)
	}
	
	return iMaxKillsId
}

add_team_score(sBuffer[MAX_BUFFER_LENGTH + 1])
{
	new Float:fzMapEff[MAX_TEAMS], Float:fzMapAcc[MAX_TEAMS], Float:fzRndAcc[MAX_TEAMS]

	for (new iTeam = 0; iTeam < MAX_TEAMS; iTeam++)
	{
		fzMapEff[iTeam] = effec(g_izTeamGameStats[iTeam])
		fzMapAcc[iTeam] = accuracy(g_izTeamGameStats[iTeam])
		fzRndAcc[iTeam] = accuracy(g_izTeamRndStats[iTeam])
	}

	format(t_sText, MAX_TEXT_LENGTH, "TERRORIST %d / %0.2f%% %L / %0.2f%% %L^nCT %d / %0.2f%% %L / %0.2f%% %L^n", g_izTeamScore[0], 
			fzMapEff[0], LANG_SERVER, "EFF", fzRndAcc[0], LANG_SERVER, "ACC", g_izTeamScore[1], fzMapEff[1], LANG_SERVER, "EFF", fzRndAcc[1], LANG_SERVER, "ACC")
	add(sBuffer, MAX_BUFFER_LENGTH, t_sText)
}

save_team_chatscore()
{
	new Float:fzMapEff[MAX_TEAMS], Float:fzMapAcc[MAX_TEAMS], Float:fzRndAcc[MAX_TEAMS]

	for (new iTeam = 0; iTeam < MAX_TEAMS; iTeam++)
	{
		fzMapEff[iTeam] = effec(g_izTeamGameStats[iTeam])
		fzMapAcc[iTeam] = accuracy(g_izTeamGameStats[iTeam])
		fzRndAcc[iTeam] = accuracy(g_izTeamRndStats[iTeam])
	}

	format(g_sScore, MAX_BUFFER_LENGTH, "TERRORIST %d / %0.2f%% %L / %0.2f%% %L  --  CT %d / %0.2f%% %L / %0.2f%% %L", g_izTeamScore[0], 
			fzMapEff[0], LANG_SERVER, "EFF", fzMapAcc[0], LANG_SERVER, "ACC", g_izTeamScore[1], fzMapEff[1], LANG_SERVER, "EFF", fzMapAcc[1], LANG_SERVER, "ACC")
}

add_total_stats(sBuffer[MAX_BUFFER_LENGTH + 1])
{
	format(t_sText, MAX_TEXT_LENGTH, "%L: %d %L / %d hs -- %d %L / %d %L^n", LANG_SERVER, "TOTAL", g_izUserRndStats[0][STATS_KILLS], LANG_SERVER, "KILL_S", 
			g_izUserRndStats[0][STATS_HS], g_izUserRndStats[0][STATS_HITS], LANG_SERVER, "HITS", g_izUserRndStats[0][STATS_SHOTS], LANG_SERVER, "SHOT_S")
	add(sBuffer, MAX_BUFFER_LENGTH, t_sText)
}

add_attacker_hits(id, iAttacker, sBuffer[MAX_BUFFER_LENGTH + 1])
{
	new iFound = 0
	
	if (iAttacker && iAttacker != id)
	{
		new izStats[8], izBody[8], iLen

		izStats[STATS_HITS] = 0
		get_user_astats(id, iAttacker, izStats, izBody)

		if (izStats[STATS_HITS])
		{
			iFound = 1
			iLen = strlen(sBuffer)
			get_user_name(iAttacker, t_sName, MAX_NAME_LENGTH)
			
			iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%L:^n", id, "HITS_YOU_IN", t_sName)
			
			for (new i = 1; i < 8; i++)
			{
				if (!izBody[i])
					continue
				
				iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%L: %d^n", id, BODY_PART[i], izBody[i])
			}
		}
	}
	
	return iFound
}

format_kill_ainfo(id, iKiller, sBuffer[MAX_BUFFER_LENGTH + 1])
{
	new iFound = 0
	
	if (iKiller && iKiller != id)
	{
		new izStats[8], izBody[8]
		new iLen
		
		iFound = 1
		get_user_name(iKiller, t_sName, MAX_NAME_LENGTH)
		izStats[STATS_HITS] = 0
		get_user_astats(id, iKiller, izStats, izBody, t_sWpn, MAX_WEAPON_LENGTH)

		iLen = format(sBuffer, MAX_BUFFER_LENGTH, "%L (%dhp, %dap) >>", id, "KILLED_BY_WITH", t_sName, t_sWpn, distance(g_izUserAttackerDistance[id]), 
						g_izKilled[id][KILLED_KILLER_HEALTH], g_izKilled[id][KILLED_KILLER_ARMOUR])

		if (izStats[STATS_HITS])
		{
			for (new i = 1; i < 8; i++)
			{
				if (!izBody[i])
					continue
				
				iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, " %L: %d", id, BODY_PART[i], izBody[i])
			}
		}
		else
			iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, " %L", id, "NO_HITS")
	}
	else
		format(sBuffer, MAX_BUFFER_LENGTH, "%L", id, "YOU_NO_KILLER")
	
	return iFound
}

format_kill_vinfo(id, iKiller, sBuffer[MAX_BUFFER_LENGTH + 1])
{
	new iFound = 0
	new izStats[8]
	new izBody[8]
	new iLen

	izStats[STATS_HITS] = 0
	izStats[STATS_DAMAGE] = 0
	get_user_vstats(id, iKiller, izStats, izBody)

	if (iKiller && iKiller != id)
	{
		iFound = 1
		get_user_name(iKiller, t_sName, MAX_NAME_LENGTH)
		iLen = format(sBuffer, MAX_BUFFER_LENGTH, "%L >>", id, "YOU_HIT", t_sName, izStats[STATS_HITS], izStats[STATS_DAMAGE])
	}
	else
		iLen = format(sBuffer, MAX_BUFFER_LENGTH, "%L >>", id, "LAST_RES", izStats[STATS_HITS], izStats[STATS_DAMAGE])

	if (izStats[STATS_HITS])
	{
		for (new i = 1; i < 8; i++)
		{
			if (!izBody[i])
				continue
			
			iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, " %L: %d", id, BODY_PART[i], izBody[i])
		}
	}
	else
		iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, " %L", id, "NO_HITS")
	
	return iFound
}

format_top15(sBuffer[MAX_BUFFER_LENGTH + 1])
{
	new iMax = get_statsnum()
	new izStats[8], izBody[8]
	new iLen = 0

	if (iMax > 15)
		iMax = 15

	new lKills[16], lDeaths[16], lHits[16], lShots[16], lEff[16], lAcc[16]
	
	format(lKills, 15, "%L", LANG_SERVER, "KILLS")
	format(lDeaths, 15, "%L", LANG_SERVER, "DEATHS")
	format(lHits, 15, "%L", LANG_SERVER, "HITS")
	format(lShots, 15, "%L", LANG_SERVER, "SHOTS")
	format(lEff, 15, "%L", LANG_SERVER, "EFF")
	format(lAcc, 15, "%L", LANG_SERVER, "ACC")
	
	ucfirst(lEff)
	ucfirst(lAcc)

	iLen = format(sBuffer, MAX_BUFFER_LENGTH, "<body bgcolor=#000000><font color=#FFB000><pre>")
	iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%2s %-22.22s %6s %6s %6s %6s %4s %4s %4s^n", "#", "Nick", lKills, lDeaths, lHits, lShots, "HS", lEff, lAcc)
	
	for (new i = 0; i < iMax && MAX_BUFFER_LENGTH - iLen > 0; i++)
	{
		get_stats(i, izStats, izBody, t_sName, MAX_NAME_LENGTH)
		replace_all(t_sName, MAX_NAME_LENGTH, "<", "[")
		replace_all(t_sName, MAX_NAME_LENGTH, ">", "]")
		iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%2d %-22.22s %6d %6d %6d %6d %4d %3.0f%% %3.0f%%^n", i + 1, t_sName, izStats[STATS_KILLS], 
						izStats[STATS_DEATHS], izStats[STATS_HITS], izStats[STATS_SHOTS], izStats[STATS_HS], effec(izStats), accuracy(izStats))
	}
}

format_rankstats(id, sBuffer[MAX_BUFFER_LENGTH + 1], iMyId = 0)
{
	new izStats[8] = {0, ...}
	new izBody[8]
	new iRankPos, iLen
	new lKills[16], lDeaths[16], lHits[16], lShots[16], lDamage[16], lEff[16], lAcc[16]
	
	format(lKills, 15, "%L", id, "KILLS")
	format(lDeaths, 15, "%L", id, "DEATHS")
	format(lHits, 15, "%L", id, "HITS")
	format(lShots, 15, "%L", id, "SHOTS")
	format(lDamage, 15, "%L", id, "DAMAGE")
	format(lEff, 15, "%L", id, "EFF")
	format(lAcc, 15, "%L", id, "ACC")
	
	ucfirst(lEff)
	ucfirst(lAcc)
	
	iRankPos = get_user_stats(id, izStats, izBody)
	iLen = format(sBuffer, MAX_BUFFER_LENGTH, "<body bgcolor=#000000><font color=#FFB000><pre>")
	iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%L %L^n^n", id, (!iMyId || iMyId == id) ? "YOUR" : "PLAYERS", id, "RANK_IS", iRankPos, get_statsnum())
	iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%6s: %d  (%d with hs)^n%6s: %d^n%6s: %d^n%6s: %d^n%6s: %d^n%6s: %0.2f%%^n%6s: %0.2f%%^n^n", 
					lKills, izStats[STATS_KILLS], izStats[STATS_HS], lDeaths, izStats[STATS_DEATHS], lHits, izStats[STATS_HITS], lShots, izStats[STATS_SHOTS], 
					lDamage, izStats[STATS_DAMAGE], lEff, effec(izStats), lAcc, accuracy(izStats))
	
	new L_BODY_PART[8][32]
	
	for (new i = 1; i < 8; i++)
	{
		format(L_BODY_PART[i], 31, "%L", id, BODY_PART[i])
	}
	
	iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%10s:^n%10s: %d^n%10s: %d^n%10s: %d^n%10s: %d^n%10s: %d^n%10s: %d^n%10s: %d", "HITS", 
					L_BODY_PART[1], izBody[1], L_BODY_PART[2], izBody[2], L_BODY_PART[3], izBody[3], L_BODY_PART[4], izBody[4], L_BODY_PART[5], 
					izBody[5], L_BODY_PART[6], izBody[6], L_BODY_PART[7], izBody[7])
}

format_stats(id, sBuffer[MAX_BUFFER_LENGTH + 1])
{
	new izStats[8] = {0, ...}
	new izBody[8]
	new iWeapon, iLen
	new lKills[16], lDeaths[16], lHits[16], lShots[16], lDamage[16], lEff[16], lAcc[16], lWeapon[16]
	
	format(lKills, 15, "%L", id, "KILLS")
	format(lDeaths, 15, "%L", id, "DEATHS")
	format(lHits, 15, "%L", id, "HITS")
	format(lShots, 15, "%L", id, "SHOTS")
	format(lDamage, 15, "%L", id, "DAMAGE")
	format(lEff, 15, "%L", id, "EFF")
	format(lAcc, 15, "%L", id, "ACC")
	format(lWeapon, 15, "%L", id, "WEAPON")
	
	ucfirst(lEff)
	ucfirst(lAcc)
	
	get_user_wstats(id, 0, izStats, izBody)
	
	iLen = format(sBuffer, MAX_BUFFER_LENGTH, "<body bgcolor=#000000><font color=#FFB000><pre>")
	iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%6s: %d  (%d with hs)^n%6s: %d^n%6s: %d^n%6s: %d^n%6s: %d^n%6s: %0.2f%%^n%6s: %0.2f%%^n^n", 
					lKills, izStats[STATS_KILLS], izStats[STATS_HS], lDeaths, izStats[STATS_DEATHS], lHits, izStats[STATS_HITS], lShots, izStats[STATS_SHOTS], 
					lDamage, izStats[STATS_DAMAGE], lEff, effec(izStats), lAcc, accuracy(izStats))
	iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%-12.12s  %6s  %6s  %6s  %6s  %6s  %4s^n", lWeapon, lKills, lDeaths, lHits, lShots, lDamage, lAcc)
	
	for (iWeapon = 1; iWeapon < xmod_get_maxweapons() && MAX_BUFFER_LENGTH - iLen > 0 ; iWeapon++)
	{
		if (get_user_wstats(id, iWeapon, izStats, izBody))
		{
			xmod_get_wpnname(iWeapon, t_sWpn, MAX_WEAPON_LENGTH)
			iLen += format(sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%-12.12s  %6d  %6d  %6d  %6d  %6d  %3.0f%%^n", t_sWpn, izStats[STATS_KILLS], izStats[STATS_DEATHS], 
							izStats[STATS_HITS], izStats[STATS_SHOTS], izStats[STATS_DAMAGE], accuracy(izStats))
		}
	}
}

show_roundend_hudstats(id, Float:fGameTime)
{
	if (!g_izStatsSwitch[id]) return
	if (!g_sAwardAndScore[0]) return

	if (g_fShowStatsTime == 0.0)
	{
		ClearSyncHud(id, g_HudSync_EndRound)
	}

	new Float:fDuration
	
	if (fGameTime == 0.0)
		fDuration = g_fHUDDuration
	else
	{
		fDuration = g_fShowStatsTime + g_fHUDDuration - fGameTime
		
		if (fDuration > g_fFreezeTime + g_fFreezeLimitTime)
			fDuration = g_fFreezeTime + g_fFreezeLimitTime
	}

	if (fDuration >= HUD_MIN_DURATION)
	{
		set_hudtype_endround(fDuration)
		ShowSyncHudMsg(id, g_HudSync_EndRound, "%s", g_sAwardAndScore)
	}
}

show_user_hudstats(id, Float:fGameTime)
{
	if (!g_izStatsSwitch[id]) return
	if (g_fzShowUserStatsTime[id] == 0.0) return

	new Float:fDuration
	
	if (fGameTime == 0.0)
		fDuration = g_fHUDDuration
	else
	{
		fDuration = g_fzShowUserStatsTime[id] + g_fHUDDuration - fGameTime
		
		if (fDuration > g_fFreezeTime + g_fFreezeLimitTime)
			fDuration = g_fFreezeTime + g_fFreezeLimitTime
	}

	if (fDuration >= HUD_MIN_DURATION)
	{
		if (ShowKiller)
		{
			new iKiller
			
			iKiller = g_izKilled[id][KILLED_KILLER_ID]
			get_kill_info(id, iKiller, g_sBuffer)
			add_attacker_hits(id, iKiller, g_sBuffer)
			set_hudtype_killer(fDuration)
			show_hudmessage(id, "%s", g_sBuffer)
		}
		
		if (ShowVictims)
		{
			get_victims(id, g_sBuffer)
			set_hudtype_victim(fDuration)
			show_hudmessage(id, "%s", g_sBuffer)
		}
		
		if (ShowAttackers)
		{
			get_attackers(id, g_sBuffer)
			set_hudtype_attacker(fDuration)
			show_hudmessage(id, "%s", g_sBuffer)
		}
	}
}

public cmdPluginMode(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1)) 
		return PLUGIN_HANDLED
	
	if (read_argc() > 1)
		read_argv(1, g_sBuffer, MAX_BUFFER_LENGTH)
	else
		g_sBuffer[0] = 0
	
	set_plugin_mode(id, g_sBuffer)
	
	return PLUGIN_HANDLED
}

public cmdStatsMe(id)
{
	if (!SayStatsMe)
	{
		client_print(id, print_chat, "%L", id, "DISABLED_MSG")
		return PLUGIN_HANDLED
	}

	format_stats(id, g_sBuffer)
	get_user_name(id, t_sName, MAX_NAME_LENGTH)
	show_motd(id, g_sBuffer, t_sName)
	
	return PLUGIN_CONTINUE
}

public cmdRankStats(id)
{
	if (!SayRankStats)
	{
		client_print(id, print_chat, "%L", id, "DISABLED_MSG")
		return PLUGIN_HANDLED
	}
	
	format_rankstats(id, g_sBuffer)
	get_user_name(id, t_sName, MAX_NAME_LENGTH)
	show_motd(id, g_sBuffer, t_sName)
	
	return PLUGIN_CONTINUE
}

public cmdTop15(id)
{
	if (!SayTop15)
	{
		client_print(id, print_chat, "%L", id, "DISABLED_MSG")
		return PLUGIN_HANDLED
	}
	
	format_top15(g_sBuffer)
	show_motd(id, g_sBuffer, "Top 15")
	
	return PLUGIN_CONTINUE
}

public cmdHp(id)
{
	if (!SayHP)
	{
		client_print(id, print_chat, "%L", id, "DISABLED_MSG")
		return PLUGIN_HANDLED
	}
	
	new iKiller = g_izKilled[id][KILLED_KILLER_ID]
	
	format_kill_ainfo(id, iKiller, g_sBuffer)
	client_print(id, print_chat, "%s", g_sBuffer)
	
	return PLUGIN_CONTINUE
}

public cmdMe(id)
{
	if (!SayMe)
	{
		client_print(id, print_chat, "%L", id, "DISABLED_MSG")
		return PLUGIN_HANDLED
	}
	
	format_kill_vinfo(id, 0, g_sBuffer)
	client_print(id, print_chat, "%s", g_sBuffer)
	
	return PLUGIN_CONTINUE
}

public cmdRank(id)
{
	if (!SayRank)
	{
		client_print(id, print_chat, "%L", id, "DISABLED_MSG")
		return PLUGIN_HANDLED
	}

	new izStats[8], izBody[8]
	new iRankPos, iRankMax
	new Float:fEff, Float:fAcc
	
	iRankPos = get_user_stats(id, izStats, izBody)
	iRankMax = get_statsnum()
	
	fEff = effec(izStats)
	fAcc = accuracy(izStats)
	
	client_print(id, print_chat, "%L", id, "YOUR_RANK_IS", iRankPos, iRankMax, izStats[STATS_KILLS], izStats[STATS_HITS], fEff, fAcc)
	
	return PLUGIN_CONTINUE
}

public cmdReport(id)
{
	if (!SayReport)
	{
		client_print(id, print_chat, "%L", id, "DISABLED_MSG")
		return PLUGIN_HANDLED
	}
	
	new iWeapon, iClip, iAmmo, iHealth, iArmor
	
	iWeapon = get_user_weapon(id, iClip, iAmmo) 
	
	if (iWeapon != 0)
		xmod_get_wpnname(iWeapon, t_sWpn, MAX_WEAPON_LENGTH)
	
	iHealth = get_user_health(id) 
	iArmor = get_user_armor(id)
	
	new lWeapon[16]
	
	format(lWeapon, 15, "%L", id, "WEAPON")
	strtolower(lWeapon)
	
	if (iClip >= 0)
	{
		format(g_sBuffer, MAX_BUFFER_LENGTH, "%s: %s, %L: %d/%d, %L: %d, %L: %d", lWeapon, t_sWpn, LANG_SERVER, "AMMO", iClip, iAmmo, LANG_SERVER, "HEALTH", iHealth, LANG_SERVER, "ARMOR", iArmor) 
	}
	else
		format(g_sBuffer, MAX_BUFFER_LENGTH, "%s: %s, %L: %d, %L: %d", lWeapon, t_sWpn[7], LANG_SERVER, "HEALTH", iHealth, LANG_SERVER, "ARMOR", iArmor) 
	
	engclient_cmd(id, "say_team", g_sBuffer)
	
	return PLUGIN_CONTINUE
} 

public cmdScore(id)
{
	if (!SayScore)
	{
		client_print(id, print_chat, "%L", id, "DISABLED_MSG")
		return PLUGIN_HANDLED
	}
	
	client_print(id, print_chat, "%L: %s", id, "GAME_SCORE", g_sScore)
	
	return PLUGIN_CONTINUE
}

public cmdSwitch(id)
{
	g_izStatsSwitch[id] = (g_izStatsSwitch[id]) ? 0 : -1 
	num_to_str(g_izStatsSwitch[id], t_sText, MAX_TEXT_LENGTH)
	client_cmd(id, "setinfo _amxstatsx %s", t_sText)
	
	new lEnDis[32]
	
	format(lEnDis, 31, "%L", id, g_izStatsSwitch[id] ? "ENABLED" : "DISABLED")
	client_print(id, print_chat, "%L", id, "STATS_ANNOUNCE", lEnDis)
	
	return PLUGIN_CONTINUE
}

public cmdStats(id)
{
	if (!SayStatsAll)
	{
		client_print(id, print_chat, "%L", id, "DISABLED_MSG")
		return PLUGIN_HANDLED
	}
	
	showStatsMenu(id, g_izUserMenuPosition[id] = 0)
	
	return PLUGIN_CONTINUE
}

public actionStatsMenu(id, key)
{
	switch (key)
	{
		case 0..6:
		{
			new iOption, iIndex
			iOption = (g_izUserMenuPosition[id] * PPL_MENU_OPTIONS) + key
			
			if (iOption >= 0 && iOption < 32)
			{
				iIndex = g_izUserMenuPlayers[id][iOption]
			
				if (is_user_connected(iIndex))
				{
					switch (g_izUserMenuAction[id])
					{
						case 0: format_stats(iIndex, g_sBuffer)
						case 1: format_rankstats(iIndex, g_sBuffer, id)
						default: g_sBuffer[0] = 0
					}
					
					if (g_sBuffer[0])
					{
						get_user_name(iIndex, t_sName, MAX_NAME_LENGTH)
						show_motd(id, g_sBuffer, t_sName)
					}
				}
			}
			
			showStatsMenu(id, g_izUserMenuPosition[id])
		}
		case 7:
		{
			g_izUserMenuAction[id]++
			
			if (g_izUserMenuAction[id] >= MAX_PPL_MENU_ACTIONS)
				g_izUserMenuAction[id] = 0
			
			showStatsMenu(id, g_izUserMenuPosition[id])
		}
		case 8: showStatsMenu(id, ++g_izUserMenuPosition[id])
		case 9:
		{
			if (g_izUserMenuPosition[id] > 0)
				showStatsMenu(id, --g_izUserMenuPosition[id])
		}
	}
	
	return PLUGIN_HANDLED
}

new g_izUserMenuActionText[MAX_PPL_MENU_ACTIONS][] = {"Show stats", "Show rank stats"}

showStatsMenu(id, iMenuPos)
{
	new iLen, iKeyMask, iPlayers
	new iUserIndex, iMenuPosMax, iMenuOption, iMenuOptionMax
	
	get_players(g_izUserMenuPlayers[id], iPlayers)
	iMenuPosMax = ((iPlayers - 1) / PPL_MENU_OPTIONS) + 1
	
	if (iMenuPos >= iMenuPosMax)
		iMenuPos = iMenuPosMax - 1

	iUserIndex = iMenuPos * PPL_MENU_OPTIONS
	iLen = format(g_sBuffer, MAX_BUFFER_LENGTH, "\y%L\R%d/%d^n\w^n", id, "SERVER_STATS", iMenuPos + 1, iMenuPosMax)
	iMenuOptionMax = iPlayers - iUserIndex
	
	if (iMenuOptionMax > PPL_MENU_OPTIONS) 
		iMenuOptionMax = PPL_MENU_OPTIONS
	
	for (iMenuOption = 0; iMenuOption < iMenuOptionMax; iMenuOption++)
	{
		get_user_name(g_izUserMenuPlayers[id][iUserIndex++], t_sName, MAX_NAME_LENGTH)
		iKeyMask |= (1<<iMenuOption)
		iLen += format(g_sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "%d. %s^n\w", iMenuOption + 1, t_sName)
	}
	
	iKeyMask |= MENU_KEY_8|MENU_KEY_0
	iLen += format(g_sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "^n8. %s^n\w", g_izUserMenuActionText[g_izUserMenuAction[id]])
	
	if (iPlayers > iUserIndex)
	{
		iLen += format(g_sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "^n9. %L...", id, "MORE")
		iKeyMask |= MENU_KEY_9
	}
	
	if (iMenuPos > 0)
		iLen += format(g_sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "^n0. %L", id, "BACK")
	else
		iLen += format(g_sBuffer[iLen], MAX_BUFFER_LENGTH - iLen, "^n0. %L", id, "EXIT")
	
	show_menu(id, iKeyMask, g_sBuffer, -1, "Server Stats")
	
	return PLUGIN_HANDLED
}

public eventStartGame()
{
	read_data(2, t_sText, MAX_TEXT_LENGTH)
	
	if (t_sText[6] == 'w')
	{
		read_data(3, t_sText, MAX_TEXT_LENGTH)
		g_fStartGame = get_gametime() + float(str_to_num(t_sText))
	}
	else
		g_fStartGame = get_gametime()
	
	return PLUGIN_CONTINUE
}

public eventStartRound()
{
	new iTeam, id, i
	
	new Float:roundtime = get_cvar_float("mp_roundtime");
	if (read_data(1) >= floatround(roundtime * 60.0,floatround_floor) || (roundtime == 2.3 && read_data(1) == 137))
	{
		
		if (g_fStartGame > 0.0 && g_fStartGame <= get_gametime())
		{
			g_fStartGame = 0.0

			for (iTeam = 0; iTeam < MAX_TEAMS; iTeam++)
			{
				g_izTeamEventScore[iTeam] = 0
				
				for (i = 0; i < 8; i++)
					g_izTeamGameStats[iTeam][i] = 0
			}
			for (id = 0; id < MAX_PLAYERS; id++)
			{
				for (i = 0; i < 8; i++)
					g_izUserGameStats[id][i] = 0
			}
		}

		for (iTeam = 0; iTeam < MAX_TEAMS; iTeam++)
		{
			g_izTeamScore[iTeam] = g_izTeamEventScore[iTeam]
			
			for (i = 0; i < 8; i++)
				g_izTeamRndStats[iTeam][i] = 0
		}
		for (id = 0; id < MAX_PLAYERS; id++)
		{
			g_izUserRndName[id][0] = 0
			
			for (i = 0; i < 8; i++)
				g_izUserRndStats[id][i] = 0
			
			g_fzShowUserStatsTime[id] = 0.0
		}

		g_iRoundEndTriggered = 0
		g_iRoundEndProcessed = 0
		g_fShowStatsTime = 0.0

		get_config_cvars()
	}

	return PLUGIN_CONTINUE
}

public eventResetHud(id)
{
	new args[1]
	args[0] = id
	
	if (g_iPluginMode & MODE_HUD_DELAY)
		set_task(0.01, "delay_resethud", 200 + id, args, 1)
	else
		delay_resethud(args)
	
	return PLUGIN_CONTINUE
}

public delay_resethud(args[])
{
	new id = args[0]
	new Float:fGameTime

	fGameTime = get_gametime()
	show_user_hudstats(id, fGameTime)
	show_roundend_hudstats(id, fGameTime)

	g_izKilled[id][KILLED_KILLER_ID] = 0
	g_izKilled[id][KILLED_KILLER_STATSFIX] = 0
	g_izShowStatsFlags[id] = -1
	g_fzShowUserStatsTime[id] = 0.0
	g_izUserAttackerDistance[id] = 0
	
	for (new i = 0; i < MAX_PLAYERS; i++)
		g_izUserVictimDistance[id][i] = 0
	
	return PLUGIN_CONTINUE
}

public client_death(killer, victim, wpnindex, hitplace, TK)
{
	if (!killer)
		return PLUGIN_CONTINUE

	if (killer != victim)
	{
		new iaVOrigin[3], iaKOrigin[3]
		new iDistance
		
		get_user_origin(victim, iaVOrigin)
		get_user_origin(killer, iaKOrigin)
		
		g_izKilled[victim][KILLED_KILLER_ID] = killer
		g_izKilled[victim][KILLED_KILLER_HEALTH] = get_user_health(killer)
		g_izKilled[victim][KILLED_KILLER_ARMOUR] = get_user_armor(killer)
		g_izKilled[victim][KILLED_KILLER_STATSFIX] = 0

		iDistance = get_distance(iaVOrigin, iaKOrigin)
		g_izUserAttackerDistance[victim] = iDistance
		g_izUserVictimDistance[killer][victim] = iDistance
	}
	
	g_izKilled[victim][KILLED_TEAM] = get_user_team(victim)
	g_izKilled[victim][KILLED_KILLER_STATSFIX] = 1

	if (!g_iRoundEndProcessed)
		kill_stats(victim)

	return PLUGIN_CONTINUE
}

kill_stats(id)
{
	if (g_fzShowUserStatsTime[id] > 0.0)
	{
		return
	}
		
	new team = get_user_team(id)
	if (team < 1 || team > 2)
	{
		return
	}

	g_fzShowUserStatsTime[id] = get_gametime()

	new izStats[8], izBody[8]
	new iTeam, i
	new iKiller

	iKiller = g_izKilled[id][KILLED_KILLER_ID]

	if (iKiller)
		iTeam = g_izKilled[id][KILLED_TEAM] - 1
	else
		iTeam = get_user_team(id) - 1

	get_user_name(id, g_izUserRndName[id], MAX_NAME_LENGTH)

	if (get_user_rstats(id, izStats, izBody))
	{
		if (iTeam >= 0 && iTeam < MAX_TEAMS)
		{
			for (i = 0; i < 8; i++)
			{
				g_izTeamRndStats[iTeam][i] += izStats[i]
				g_izTeamGameStats[iTeam][i] += izStats[i]
				g_izUserRndStats[0][i] += izStats[i]
				g_izUserGameStats[0][i] += izStats[i]
			}
		}

		if (g_izUserUserID[id] == get_user_userid(id))
		{
			for (i = 0; i < 8; i++)
			{
				g_izUserRndStats[id][i] += izStats[i]
				g_izUserGameStats[id][i] += izStats[i]
			}
		} else {
			g_izUserUserID[id] = get_user_userid(id)
			
			for (i = 0; i < 8; i++)
			{
				g_izUserRndStats[id][i] = izStats[i]
				g_izUserGameStats[id][i] = izStats[i]
			}
		}

	}

	if (KillerChat && iKiller && iKiller != id)
	{
		if (format_kill_ainfo(id, iKiller, g_sBuffer))
		{
			client_print(id, print_chat, "%s", g_sBuffer)
			format_kill_vinfo(id, iKiller, g_sBuffer)
		}
		
		client_print(id, print_chat, "%s", g_sBuffer)
	}
	show_user_hudstats(id, 0.0)
}

public eventEndRound()
{
	get_config_cvars()

	if (!g_iRoundEndTriggered)
	{
		read_data(2, t_sText, MAX_TEXT_LENGTH)
		
		if (t_sText[7] == 't')
			g_izTeamScore[0]++
		else if (t_sText[7] == 'c')
			g_izTeamScore[1]++
	}

	set_task(0.3, "ERTask", 997)
	
	return PLUGIN_CONTINUE
}

public ERTask()
{
	g_iRoundEndTriggered = 1
	endround_stats()
}

endround_stats()
{
	if (g_iRoundEndProcessed || !g_iRoundEndTriggered)
		return

	new iaPlayers[32], iPlayer, iPlayers, id

	get_players(iaPlayers, iPlayers)
	
	for (iPlayer = 0; iPlayer < iPlayers; iPlayer++)
	{
		id = iaPlayers[iPlayer]
		
		if (g_fzShowUserStatsTime[id] == 0.0)
		{
			kill_stats(id)
		}
	}

	g_sAwardAndScore[0] = 0

	if (ShowMostDisruptive)
		add_most_disruptive(g_sAwardAndScore)
	if (ShowBestScore)
		add_best_score(g_sAwardAndScore)

	if (ShowTeamScore || ShowTotalStats)
	{
		if (ShowMostDisruptive && ShowBestScore)
			add(g_sAwardAndScore, MAX_BUFFER_LENGTH, "^n^n")
		else if (ShowMostDisruptive || ShowBestScore)
			add(g_sAwardAndScore, MAX_BUFFER_LENGTH, "^n^n^n^n")
		else
			add(g_sAwardAndScore, MAX_BUFFER_LENGTH, "^n^n^n^n^n^n")

		if (ShowTeamScore)
			add_team_score(g_sAwardAndScore)
		
		if (ShowTotalStats)
			add_total_stats(g_sAwardAndScore)
	}

	save_team_chatscore()

	g_fShowStatsTime = get_gametime()

	for (iPlayer = 0; iPlayer < iPlayers; iPlayer++)
	{
		id = iaPlayers[iPlayer]
		show_roundend_hudstats(id, 0.0)
	}
	g_iRoundEndProcessed = 1
}

public eventTeamScore()
{
	new sTeamID[1 + 1], iTeamScore
	read_data(1, sTeamID, 1)
	iTeamScore = read_data(2)
	g_izTeamEventScore[(sTeamID[0] == 'C') ? 1 : 0] = iTeamScore
	
	return PLUGIN_CONTINUE
}

public eventIntermission()
{
	if (EndPlayer || EndTop15)
		set_task(1.0, "end_game_stats", 900)
}

public end_game_stats()
{
	new iaPlayers[32], iPlayer, iPlayers, id

	if (EndPlayer)
	{
		get_players(iaPlayers, iPlayers)
		
		for (iPlayer = 0; iPlayer < iPlayers; iPlayer++)
		{
			id = iaPlayers[iPlayer]
			
			if (!g_izStatsSwitch[id])
				continue
			
			cmdStatsMe(iaPlayers[iPlayer])
		}
	}
	else if (EndTop15)
	{
		get_players(iaPlayers, iPlayers)
		format_top15(g_sBuffer)
		
		for (iPlayer = 0; iPlayer < iPlayers; iPlayer++)
		{
			id = iaPlayers[iPlayer]
			
			if (!g_izStatsSwitch[id])
				continue
			
			show_motd(iaPlayers[iPlayer], g_sBuffer, "Top 15")
		}
	}
	
	return PLUGIN_CONTINUE
}

public eventSpecMode(id)
{
	new sData[12]
	read_data(2, sData, 11)
	g_izSpecMode[id] = (sData[10] == '2')
	
	return PLUGIN_CONTINUE
} 

public eventShowRank(id)
{
	if (SpecRankInfo && g_izSpecMode[id])
	{
		new iPlayer = read_data(2)
		
		if (is_user_connected(iPlayer))
		{
			new izStats[8], izBody[8]
			new iRankPos, iRankMax
			
			get_user_name(iPlayer, t_sName, MAX_NAME_LENGTH)
			
			iRankPos = get_user_stats(iPlayer, izStats, izBody)
			iRankMax = get_statsnum()
			
			set_hudtype_specmode()
			ShowSyncHudMsg(id, g_HudSync_SpecInfo, "%L", id, "X_RANK_IS", t_sName, iRankPos, iRankMax)
		}
	}
	
	return PLUGIN_CONTINUE
}

public client_connect(id)
{
	if (ShowStats)
	{
		get_user_info(id, "_amxstatsx", t_sText, MAX_TEXT_LENGTH)
		g_izStatsSwitch[id] = (t_sText[0]) ? str_to_num(t_sText) : -1
	}
	else
		g_izStatsSwitch[id] = 0

	g_izKilled[id][KILLED_KILLER_ID] = 0
	g_izKilled[id][KILLED_KILLER_STATSFIX] = 0
	g_izShowStatsFlags[id] = 0
	g_fzShowUserStatsTime[id] = 0.0

	return PLUGIN_CONTINUE
}
