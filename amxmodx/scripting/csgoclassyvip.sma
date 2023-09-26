#include <amxmodx> 
#include <amxmisc>
#include <cstrike> 
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <nvault>
#include <fun>
#include <xs>
#include <unixtime>
#include <csgoclassy>

#pragma compress 1

#define PLUGIN "VIP CSGO Classy"
#define VERSION "2.0"
#define AUTHOR "renegade"

#define LOG_FILE "csgoclassyvip.txt"

#define gold_acces ADMIN_LEVEL_H
#define silver_acces ADMIN_LEVEL_B
#define is_gold_vip(%0)	(get_user_flags(%0) & gold_acces)
#define is_silver_vip(%0) (get_user_flags(%0) & silver_acces)
#define XO_PLAYER            5
#define m_flFlashedUntil     514
#define m_flFlashedAt        515
#define m_flFlashHoldTime    516
#define m_flFlashDuration    517
#define m_iFlashAlpha        518
#define ALPHA_FULLBLINDED    255


new const g_VipMaps[] = "blockmaps.ini";
new g_File2[128];
new Float:g_fFreezeSeconds;
new hudsync
new const szCfgFile[] = "vip.cfg"
new bool:vipmenu = true
new bool:silvervipmenu = true
new bool:HasC4[33]
new min_ve
new max_ve

enum(+= 1000)
{
	TASK_HPREGEN,
	TASK_GODMOD,
	TASK_SET_SKILLS
}

static timer[33]

enum _:Pistols
{
	PistolName[200],
	PistolID[32],
	PistolAmmo
}

enum _:Weapons
{
	WeapName[200],
	WeaponID[32],
	BpAmmo
}

enum _:Secondary
{
	SecName[200],
	SecID[32],
	SecAmmo	
}

new const VipWeapons[][Weapons] =
{
	{ "\rAK-47 \wand \rDeagle", "weapon_ak47",90 },
	{ "\rM4A1-S \wor \rM4A4 \wand \rDeagle","weapon_m4a1",90 },
	{ "\rAWP \wand \rDeagle", "weapon_awp",30 }
}

new const VipPistols[][Pistols]=
{
	{ "Deagle", "weapon_deagle", 35 },
	{ "FiveSeven", "weapon_fiveseven", 100},
	{ "P250", "weapon_p228", 52}	
}

new const SecondaryWeapons[][Secondary]=
{
	{ "\rFamas \wand \rDeagle", "weapon_famas", 90 },
	{ "\rGalil-AR \wand \rDeagle", "weapon_galil", 90},
	{ "\rSSG \wand \rDeagle", "weapon_scout", 90}	
}

enum _:SilverPistols
{
	PistolName[200],
	PistolID[32],
	PistolAmmo
}

enum _:SilverWeapons
{
	WeapName[200],
	WeaponID[32],
	BpAmmo
}

enum _:SilverSecondary
{
	SecName[200],
	SecID[32],
	SecAmmo
}

new const SilverVipWeapons[][SilverWeapons] =
{
	{ "\rAK-47 \wand \rDeagle", "weapon_ak47",90 },
	{ "\rM4A1-S \wor \rM4A4 \wand \rDeagle","weapon_m4a1",90 },
	{ "\rAWP \wand \rDeagle", "weapon_awp",30 }
}

new const SilverVipPistols[][SilverPistols]=
{
	{ "Deagle", "weapon_deagle", 35 },
	{ "FiveSeven", "weapon_fiveseven", 100},
	{ "P250", "weapon_p228", 52}	
}

new const SilverSecondaryWeapons[][SilverSecondary]=
{
	{ "\rFamas \wand \rDeagle", "weapon_famas", 90 },
	{ "\rGalil-AR \wand \rDeagle", "weapon_galil", 90},
	{ "\rSSG \wand \rDeagle", "weapon_scout", 90}	
}

new bool:WeaponSelected[33]
new bool:PistolsSelected[33]
new bool:SecondarySelected[33]
new bool:SilverWeaponSelected[33]
new bool:SilverPistolsSelected[33]
new bool:SilverSecondarySelected[33]
native get_user_silver_vip(user_id);
native set_user_silver_vip(user_id, vip_mode);
native is_warmup();
new CVAR_color_Kill[3]
new g_iJumpCount[33]
new CurrentRound
new PcvarVIPMoneyKillBonus
new PcvarMaxRegenHP
new PcvarHpRegenAdd
new PcvarMaxExperience
new VIP[33]
new SilverVIP[33]
new VIPMoney[33]
new Experience[33]
new g_iCvars[3]
new bool:g_bFreeVipTime
new gSmoke
new VIPMj[33]
new VIPBh[33]
new VIPRegen[33] 
new VIPNoDmg[33]
new VIPImm[33]
new bool:g_bActived_Mj[33]
new bool:g_bActived_Bhop[33]
new bool:g_bActived_Imm[33]
new bool:g_bActived_Regen[33]
new bool:g_bActived_NoDmg[33]
new HudsSync[6]
new g_nVault
new g_iSelectedPower[MAX_PLAYERS + 1]

//lexzor
enum _:CVARS (+= 1)
{
	FREEZE_TIME = 0,
	BHOP_SPEED,
	GODMODE_TIME,
	FREE_SILVER_AWP,
	FREE_GOLD_AWP,
	TRIPLE_JUMP_PRICE,
	HP_REGEN_PRICE,
	FREEZE_PRICE,
	BHOP_PRICE,
	GOD_MODE_PRICE,
}

new g_cvar[CVARS];
new g_iGodModeDuration;
new Float:BUNNYJUMP_MAX_SPEED_FACTOR;
//lexzor



public plugin_init()  
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	PcvarVIPMoneyKillBonus = register_cvar("vip_money_per_kill", "15")
	PcvarMaxRegenHP = register_cvar("hp_regeneration_max_hp", "100")
	PcvarHpRegenAdd = register_cvar("hp_regeneration_per_second", "2")
	PcvarMaxExperience = register_cvar("free_vip_experience", "1000000")
	gSmoke = register_cvar("give_smoke", "0")
	min_ve = register_cvar("min_ve_per_kill", "25")
	max_ve = register_cvar("max_ve_per_kill", "80")
	g_cvar[FREEZE_TIME] = register_cvar("freeze_time", "1.2");
	g_cvar[BHOP_SPEED] = register_cvar("bhop_speed", "1.65");
	g_cvar[GODMODE_TIME] = register_cvar("godmode_time", "2");
	g_cvar[FREE_SILVER_AWP] = register_cvar("free_silver_awp", "0");
	g_cvar[FREE_GOLD_AWP] = register_cvar("free_gold_awp", "1");
	//triple. hpregen, freeze, bhop, godmode
	new data;
	data = register_cvar("triple_jump_price", "10000")
	g_cvar[TRIPLE_JUMP_PRICE] = get_pcvar_num(data)

	data = register_cvar("hp_regen_price", "10000")
	g_cvar[TRIPLE_JUMP_PRICE] = get_pcvar_num(data)

	data = register_cvar("freeze_price", "10000")
	g_cvar[TRIPLE_JUMP_PRICE] = get_pcvar_num(data)

	data = register_cvar("bhop_price", "10000")
	g_cvar[TRIPLE_JUMP_PRICE] = get_pcvar_num(data)

	data = register_cvar("god_mode_price", "10000")
	g_cvar[TRIPLE_JUMP_PRICE] = get_pcvar_num(data)

	g_iGodModeDuration = get_pcvar_num(g_cvar[GODMODE_TIME]);
	BUNNYJUMP_MAX_SPEED_FACTOR = get_pcvar_float(g_cvar[BHOP_SPEED]);
	g_fFreezeSeconds = get_pcvar_float(g_cvar[FREEZE_TIME]);
		
	for(new i;i < sizeof HudsSync;i++)
		HudsSync[i] = CreateHudSyncObj()

	register_event("HLTV", "OnNewRound", "a", "1=0", "2=0")
    
	g_iCvars[0] = register_cvar("free_vip", "1")
	g_iCvars[1] = register_cvar("free_vip_start", "22")
	g_iCvars[2] = register_cvar("free_vip_end", "08")
	
	register_forward( FM_CmdStart, "CmdStart")
	register_clcmd("nightvision", "CmdNightvision")
	register_clcmd("say /vmenu", "CmdNightvision")
	register_clcmd("say_team /vmenu", "CmdNightvision")

	register_concmd("amx_givevipmoney", "CmdGiveVipMoney", ADMIN_IMMUNITY, "<name> <amount>")
	register_concmd("amx_givevipexperience", "CmdGiveVipExperience", ADMIN_IMMUNITY, "<name> <amount>")
	
	RegisterHam(Ham_TakeDamage, "player", "ham_Player_TakeDamage_Post", 0)
	RegisterHam(Ham_Player_PostThink, "player", "ham_Player_PostThink_Post", 1 )
	RegisterHam(Ham_Killed,"player","fw_Ham_Player_Killed_Post",1)
	RegisterHam(Ham_Killed,"player","fw_Ham_Player_Killed_Pre")
	RegisterHam(Ham_Spawn,"player","fwSpawn",1)
	register_logevent("LogEvent_RoundStart", 2, "1=Round_Start" );
	register_event("TextMsg","Event_RoundRestart","a","2&#Game_w")
	register_event("TextMsg","Event_RoundRestart","a","2&#Game_C");

	hudsync = CreateHudSyncObj()
	set_task(1.0, "show_hud", 0, "", 0, "b")
	
	LoadCfg()
}

public fw_Ham_Player_Killed_Pre(const iVictim)
{
	if(pev(iVictim, pev_flags) & FL_FROZEN)
	{
		remove_frozen(iVictim)
	}
}

public show_hud(id)
{
	if(g_bFreeVipTime == true && get_pcvar_num(g_iCvars[1]) != get_pcvar_num(g_iCvars[2]))
	{
		set_hudmessage(47, 79, 79, -1.0, 0.01, 0, 1.0, 1.0, 0.1, 0.2, -1)
		ShowSyncHudMsg(id, hudsync, "[Press N] Silver VIP membership is active from %d:00 to %d:00", get_pcvar_num(g_iCvars[1]), get_pcvar_num(g_iCvars[2]))
		// ShowSyncHudMsg(id, hudsync, "[Pressione N]  Silver VIP esta ativo das %d:00 a %d:00", get_pcvar_num(g_iCvars[1]), get_pcvar_num(g_iCvars[2]))
	}
	else if(g_bFreeVipTime == true && get_pcvar_num(g_iCvars[1]) == get_pcvar_num(g_iCvars[2]))
	{
		set_hudmessage(47, 79, 79, -1.0, 0.01, 0, 1.0, 1.0, 0.1, 0.2, -1)
		ShowSyncHudMsg(id, hudsync, "[Press N] Silver VIP membership is active non-stop", get_pcvar_num(g_iCvars[1]), get_pcvar_num(g_iCvars[2]))
		// ShowSyncHudMsg(id, hudsync, "[Pressione N]  Silver VIP esta ativo  gratis sem parar.", get_pcvar_num(g_iCvars[1]), get_pcvar_num(g_iCvars[2]))
	}
}

public CmdNightvision(id)
{
	if(is_warmup())
	{
		client_print_color(id, id, "^4[CSGO Classy]^1 You can't use weapon menu during warmup!", get_pcvar_num(g_iCvars[1]), get_pcvar_num(g_iCvars[2]))
		return PLUGIN_HANDLED;
	}
	if((g_bFreeVipTime == true && !is_gold_vip(id)) || is_silver_vip(id))
   	{
        ShowSilverVipMenu(id)
    }
	if(g_bFreeVipTime == true && is_gold_vip(id))
    {
        ShowVIPMenu(id)
    }
	if(g_bFreeVipTime == false && !is_gold_vip(id) && !is_silver_vip(id))
    {
		client_print_color(id, id, "^4[CSGO Classy] Silver VIP membership^1 event starts at^4 %d:00 ^1 and ends at^4 %d:00", get_pcvar_num(g_iCvars[1]), get_pcvar_num(g_iCvars[2]))
		client_print_color(id, id, "^4[CSGO Classy]^1 You got^4 %d VE^1 out of^4 %s VE^1", Experience[id], AddCommas(get_pcvar_num(PcvarMaxExperience)))
    }
	if(g_bFreeVipTime == false && is_gold_vip(id))
    {
        ShowVIPMenu(id)
    }
	return PLUGIN_HANDLED
}

public LogEvent_RoundStart()
{
    CurrentRound++
}

public Event_RoundRestart()
{
    CurrentRound = 0
}

public LoadCfg()
{
	new text[128]

	new szCSGOConfigDir[64], szConfigDir[64]
	csgo_directory(szCSGOConfigDir, charsmax(szCSGOConfigDir))
	get_configsdir(szConfigDir, charsmax(szConfigDir))

	formatex(text,charsmax(text),"%s/%s/%s", szConfigDir, szCSGOConfigDir, szCfgFile)
	if(!file_exists(text))
	{
		formatex(text,charsmax(text),"Folder ^"%s^" was not found", text)
		set_fail_state(text)
	}
	server_cmd("exec %s",text)
}

public plugin_natives()
{
	register_native("get_user_silver_vip","_get_user_silver_vip")
	register_native("set_user_silver_vip","_set_user_silver_vip")
	register_native("is_free_vip_time", "_is_free_vip_time", 0)
	register_native("is_user_gold_vip", "native_is_user_gold_vip", 0)
	register_native("is_user_silver_vip", "native_is_user_silver_vip", 0)
}

public native_is_user_gold_vip(iPluginID, iParamNum)
{
	return is_gold_vip(get_param(1));
}

public native_is_user_silver_vip(iPluginID, iParamNum)
{
	return is_silver_vip(get_param(1));
}

public _get_user_silver_vip(user_id)
{
	new id = get_param(1)
	if(!is_user_connected(id) || !id)
		return 0
		
	return SilverVIP[id]
}
	
public _set_user_silver_vip(user_id, vip_mode)
{
	new id = get_param(1)
	new MODE = get_param(2)
	
	if(!is_user_connected(id) || !id)
		return 0
		
	SilverVIP[id] = MODE
	return 1
}

public _is_free_vip_time(iPlugin, iParams)
{
    new id = get_param(1)
    
    if(!is_gold_vip(id))
    {
        set_user_silver_vip(id, 1)
    }

    return g_bFreeVipTime;
}

public client_putinserver(id) 
{
	if(g_bFreeVipTime)
	{   
		if(!is_gold_vip(id))
		{
			set_user_silver_vip(id, 1)
		}
	}

	if(is_silver_vip(id))
	{
		set_user_silver_vip(id, 1);
	}

	//set_task(3.0, "HelloVIP", id + 200210)
	return 0
}

public client_authorized(id)
{
	if(g_bFreeVipTime)
	{   
		if(!is_gold_vip(id))
		{
			set_user_silver_vip(id, 1)
		}
	}

	LoadVIP(id)
	return 0
}

// public HelloVIP(id)
// {
// 	id -= 200210
// 	new stats[8]
// 	new body[8]
// 	new rank_pos = get_user_stats(id, stats, body)
// 	new rank_max = get_statsnum()
// 	new szName[32]
// 	get_user_name(id, szName, 31)
// 	set_hudmessage(47, 79, 79, 0.60, 0.35)
// 	ShowSyncHudMsg(id, HudsSync[4], "Welcome, %s^nWe hope you enjoy your stay here^nYour rank is %d out of %d", szName, rank_pos, rank_max )
// 	client_cmd(id, "spk ^"scientist/hellothere letsgo^"")
// }

public client_disconnected(id)
{
	SaveVIP(id)
}

//gold vip menus

public ShowVIPMenu(id)
{
	new MapName[32]
	new szLine[128]
	new iLen
	new Size = file_size(g_File2, 1)
	get_mapname(MapName, sizeof(MapName))
	for(new i = 0; i < Size; i ++)
	{
		read_file(g_File2, i, szLine, charsmax(szLine), iLen);
		if(equali(MapName, szLine))
		{
			client_print_color(id, id, "^4[CSGO Classy]^1 You ^4can not^1 acces ^4this menu^1 because you are ^4playing %s", MapName)
			vipmenu = false
			break;
		}
	}
	if (vipmenu == true && is_user_logged(id))
	{
		if(is_gold_vip(id))
		{
			new temp[96]
			formatex(temp, 95, "\r[CSGO Classy] \wGold VIP membership \r[%d V$]", VIPMoney[id]);
			new menu = menu_create(temp, "vip_menu_handler", 0)
			new szItem[2]
			szItem[1] = 0
			formatex(temp, 95, "\wWeapons")
			menu_additem(menu, temp, szItem, 0, -1)
			formatex(temp, 95, "\rItems")
			menu_additem(menu, temp, szItem, 0, -1)
			formatex(temp, 95, "\wMarket")
			menu_additem(menu, temp, szItem, 0, -1)

			if(is_user_connected(id))
				menu_display(id, menu)
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public vip_menu_handler(id,menu,item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || !is_gold_vip(id))
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	switch(item)
	{
		case 0:
		{
			if (!PistolsSelected[id] && CurrentRound <= 1)
			{
				ShowPistols(id)
			}
			if (!SecondarySelected[id] && CurrentRound == 2)
			{
				ShowSecondary(id)	
			}
			if (!WeaponSelected[id] && CurrentRound >= 3)
			{
				VipWeaponsMenu(id)
			}	
		}
		case 1:
		{
			VipItemsMenu(id)
		}
		case 2:
		{
			Vipshop(id)
		}
	}
	return PLUGIN_HANDLED
}

public ShowPistols(id)
{
	new szMenuW = menu_create("\r[CSGO Classy] \wWeapons","ShowPistols_handler")
	for ( new i; i < sizeof VipPistols; i++ )
		menu_additem( szMenuW, VipPistols[ i ][ PistolName ] )	

	if(is_user_connected(id))
		menu_display(id,szMenuW)
}

public ShowPistols_handler(id,menu,item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || !is_gold_vip(id))
	{
		menu_destroy(menu)
		ShowVIPMenu(id)
		return PLUGIN_HANDLED
	}

	if(user_has_weapon(id, CSW_C4) && get_user_team(id) == 1)
	{
		HasC4[id] = true
	}
	else
	{
		HasC4[id] = false
	}
	
	strip_user_weapons(id)
	give_item(id,"weapon_knife")
	give_item(id,"weapon_hegrenade")
	give_item(id,"weapon_flashbang")
	
	if(get_pcvar_num(gSmoke) > 0)
	{
		give_item(id, "weapon_smokegrenade")
	}

	cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
		
	PistolsSelected[id] = true
		
	give_item( id, VipPistols[ item ][ PistolID ] )
	cs_set_user_bpammo( id, get_weaponid( VipPistols[ item ][ PistolID ] ), VipPistols[ item ][ PistolAmmo ] )
	
	if(get_user_team(id) == 2)
	{
		give_item(id, "item_thighpack")
	}
	
	if (HasC4[id])
    {
        give_item(id, "weapon_c4");
        cs_set_user_plant( id );
    }
	
	return PLUGIN_HANDLED
}

public ShowSecondary(id)
{
	new szMenuW = menu_create("\r[CSGO Classy] \wWeapons","ShowSecondary_handler")
	
	for ( new i; i < sizeof SecondaryWeapons; i++ )
		menu_additem( szMenuW, SecondaryWeapons[ i ][ SecName ] )
		
	if(is_user_connected(id))
		menu_display(id,szMenuW)	
}

public ShowSecondary_handler(id,menu,item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || !is_gold_vip(id))
	{
		menu_destroy(menu)
		ShowVIPMenu(id)
		return PLUGIN_HANDLED
	}
    
	if(user_has_weapon(id, CSW_C4) && get_user_team(id) == 1)
	{
		HasC4[id] = true
	}
	else
	{
		HasC4[id] = false
	}

	strip_user_weapons(id)	
	give_item(id,"weapon_knife")	
	give_item(id,"weapon_hegrenade")
	give_item(id,"weapon_flashbang")

	if(get_pcvar_num(gSmoke) > 0)
	{
		give_item(id, "weapon_smokegrenade")
	}

	cs_set_user_bpammo(id, CSW_FLASHBANG, 2)	
	SecondarySelected[id] = true	
	give_item( id, SecondaryWeapons[ item ][ SecID ] )
	cs_set_user_bpammo( id, get_weaponid( SecondaryWeapons[ item ][ SecID ] ), SecondaryWeapons[ item ][ SecAmmo ] )
	give_item(id,"weapon_deagle")
	cs_set_user_bpammo(id,CSW_DEAGLE,35)

	if(get_user_team(id) == 2)
	{
		give_item(id, "item_thighpack")
	}

	if (HasC4[id])
    {
        give_item(id, "weapon_c4");
        cs_set_user_plant( id );
    }
	
	return PLUGIN_HANDLED
}

public VipWeaponsMenu(id)
{
	new szMenuW = menu_create("\r[CSGO Classy] \wWeapons", "vip_weapons_handler")
	for(new i; i < sizeof VipWeapons; i++)
	{
		if(equal(VipWeapons[i][WeaponID], "weapon_awp") && !get_pcvar_num(g_cvar[FREE_GOLD_AWP]))
			continue;
		else
		menu_additem(szMenuW, VipWeapons[i][WeapName])
	}

	if(is_user_connected(id))
		menu_display(id, szMenuW)
}

public vip_weapons_handler(id,menu,item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || !is_gold_vip(id) || CurrentRound == 1)
	{
		menu_destroy(menu)
		ShowVIPMenu(id)
		return PLUGIN_HANDLED
	}
	if(user_has_weapon(id, CSW_C4) && get_user_team(id) == 1)
	{
		HasC4[id] = true
	}
	else
	{
		HasC4[id] = false
	}
	
	strip_user_weapons(id)
	give_item(id,"weapon_knife")
	give_item(id,"weapon_hegrenade")
	give_item(id,"weapon_flashbang")

	if(get_pcvar_num(gSmoke) > 0)
	{
		give_item(id, "weapon_smokegrenade")
	}
	cs_set_user_bpammo(id, CSW_FLASHBANG, 2)	
	WeaponSelected[id] = true
	SecondarySelected[id] = true
	PistolsSelected[id] = true
	give_item( id, VipWeapons[ item ][ WeaponID ] )
	cs_set_user_bpammo( id, get_weaponid( VipWeapons[ item ][ WeaponID ] ), VipWeapons[ item ][ BpAmmo ] )
	give_item(id,"weapon_deagle")
	cs_set_user_bpammo(id,CSW_DEAGLE,35)

	if(get_user_team(id) == 2)
	{
		give_item(id, "item_thighpack")
	}

	if (HasC4[id])
    {
        give_item(id, "weapon_c4")
        cs_set_user_plant( id )
    }

	return PLUGIN_HANDLED
}

public VipItemsMenu(id)
{
	new szTittle = menu_create("\r[CSGO Classy] \wItems", "vip_items_handler")
		
	if(VIPMj[id] == 0)
	{
		menu_additem(szTittle, "Double jump \r[1000 V$]")
	}	
	else
	{
		menu_additem(szTittle, !g_bActived_Mj[id] ? "Double jump \r[OFF]" : "Double jump \y[ON]")
	}
			
	if(VIPRegen[id] == 0)
	{
		menu_additem(szTittle, "HP Regeneration \r[2500 V$]")
	}		
	else
	{
		menu_additem(szTittle, !g_bActived_Regen[id] ? "HP Regeneration \r[OFF]" : "HP Regeneration \y[ON]")
	}
			
	if(VIPImm[id] == 0)
	{
		menu_additem(szTittle, "Freeze \r[3500 V$]")
	}	
	else
	{
		menu_additem(szTittle, !g_bActived_Imm[id] ? "Freeze \r[OFF]" : "Freeze \y[ON]")
	}
			
	if(VIPBh[id] == 0)
	{
		menu_additem(szTittle, "BunnyHop \r[5000 V$]")
	}		
	else
	{
		menu_additem(szTittle, !g_bActived_Bhop[id] ? "BunnyHop \r[OFF]" : "BunnyHop \y[ON]")
	}			

	if(VIPNoDmg[id] == 0)
	{
		menu_additem(szTittle, "God mode \r[10000 V$]")
	}		
	else
	{
		menu_additem(szTittle, !g_bActived_NoDmg[id] ? "God mode \r[OFF]" : "God mode \y[ON]")
	}		

	if(is_user_connected(id))
		menu_display(id, szTittle)		
}

public vip_items_handler(id,menu,item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || !is_gold_vip(id))
	{
		menu_destroy(menu)
		ShowVIPMenu(id)
		return PLUGIN_HANDLED
	}

	switch(item)
	{
		case 0:
		{
			if(VIPMj[id] == 0)
			{
				if(VIPMoney[id] >= 1000)
				{
					VIPMj[id] = 1
					VIPMoney[id] -= 1000
					VipItemsMenu(id)
				}
				else
				{
					client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough ^4V$^1, you need ^4%d more", 1000 - VIPMoney[id])
					VipItemsMenu(id)
				}
			}
			else
			{
				if(!g_bActived_NoDmg[id])
				{
					if(!g_bActived_Mj[id])
					{
						g_bActived_Mj[id] = true
						
						if(task_exists(id+TASK_GODMOD))
							remove_task(id+TASK_GODMOD)
							
						if(task_exists(id+TASK_HPREGEN))
							remove_task(id+TASK_HPREGEN)
						
						g_bActived_Bhop[id] = false
						g_bActived_Imm[id] = false
						g_bActived_Regen[id] = false
						g_iSelectedPower[id] = 0;
						VipItemsMenu(id)
					}
					else
					{
						g_bActived_Mj[id] = false
						VipItemsMenu(id)
					}
				}
				else
				{
					client_print_color(id, id, "^4[CSGO Classy]^1 You can not use any ^4items^1 this round because you used ^4God mode")
					VipItemsMenu(id)
				}
			}
		}
		case 1:
		{
			if(VIPRegen[id] == 0)
			{
				if(VIPMoney[id] >= 2500)
				{
					VIPRegen[id] = 1
					VIPMoney[id] -= 2500
					VipItemsMenu(id)
				}
				else
				{
					client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough ^4V$^1, you need ^4%d more", 2500 - VIPMoney[id])
					VipItemsMenu(id)
				}
			}
			else
			{
				if(!g_bActived_NoDmg[id])
				{
					if(!g_bActived_Regen[id])
					{
						g_bActived_Regen[id] = true
						
						g_bActived_Bhop[id] = false
						g_bActived_Imm[id] = false
						g_bActived_Mj[id] = false
						
						if(task_exists(id+TASK_GODMOD))
							remove_task(id+TASK_GODMOD)
						
						if(task_exists(id + TASK_HPREGEN))
						{
							remove_task(id + TASK_HPREGEN)
						}
						set_task(0.5, "HPRegen", id + TASK_HPREGEN, .flags = "b")
						g_iSelectedPower[id] = 1;
						VipItemsMenu(id)
					}
					else
					{
						remove_task(id + TASK_HPREGEN)
						g_bActived_Regen[id] = false
						VipItemsMenu(id)
					}
				}
				else
				{
					client_print_color(id, id, "^4[CSGO Classy]^1 You can not use any ^4items^1 this round because you used ^4God mode")
					VipItemsMenu(id)
				}
			}
		}
		case 2:
		{
			if(VIPImm[id] == 0)
			{
				if(VIPMoney[id] >= 3500)
				{
					VIPImm[id] = 1
					VIPMoney[id] -= 3500
					VipItemsMenu(id)
				}
				else
				{
					client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough ^4V$^1, you need ^4%d more", 3500 - VIPMoney[id])
					VipItemsMenu(id)
				}
			}
			else
			{
				if(!g_bActived_NoDmg[id])
				{
					if(!g_bActived_Imm[id])
					{
						g_bActived_Imm[id] = true
						
						if(task_exists(id+TASK_GODMOD))
							remove_task(id+TASK_GODMOD)
							
						if(task_exists(id+TASK_HPREGEN))
							remove_task(id+TASK_HPREGEN)
						
						g_bActived_Bhop[id] = false
						g_bActived_Mj[id] = false
						g_bActived_Regen[id] = false
						g_iSelectedPower[id] = 2;
						VipItemsMenu(id)
					}
					else
					{
						g_bActived_Imm[id] = false
						VipItemsMenu(id)
					}
				}
				else
				{
					client_print_color(id, id, "^4[CSGO Classy]^1 You can not use any ^4items^1 this round because you used ^4God mode")
					VipItemsMenu(id)
				}
			}
		}
		case 3:
		{
			if(VIPBh[id] == 0)
			{
				if(VIPMoney[id] >= 5000)
				{
					VIPBh[id] = 1
					VIPMoney[id] -= 5000
					VipItemsMenu(id)
				}
				else
				{
					client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough ^4V$^1, you need ^4%d more", 5000 - VIPMoney[id])
					VipItemsMenu(id)
				}
			}
			else
			{
				if(!g_bActived_NoDmg[id])
				{
					if(!g_bActived_Bhop[id])
					{
							
						g_bActived_Bhop[id] = true
						
						if(task_exists(id+TASK_GODMOD))
							remove_task(id+TASK_GODMOD)
							
						if(task_exists(id+TASK_HPREGEN))
							remove_task(id+TASK_HPREGEN)
						
						g_bActived_Imm[id] = false
						g_bActived_Mj[id] = false
						g_bActived_Regen[id] = false
						g_iSelectedPower[id] = 3;
						VipItemsMenu(id)
					}
					else
					{
						g_bActived_Bhop[id] = false
						VipItemsMenu(id)
					}
				}
				else
				{
					client_print_color(id, id, "^4[CSGO Classy]^1 You can not use any ^4items^1 this round because you used ^4God mode")
					VipItemsMenu(id)
				}
			}
		}
		case 4:
		{
			if(VIPNoDmg[id] == 0)
			{
				if(VIPMoney[id] >= 10000)
				{
					VIPNoDmg[id] = 1
					VIPMoney[id] -= 10000
					set_pev(id,pev_takedamage,DAMAGE_NO)
					set_task(0.5,"GodMod_CountDown",id+TASK_GODMOD,_,_,"a", 3)
					VipItemsMenu(id)
				}
				else
				{
					client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough ^4V$^1, you need ^4%d more", 10000 - VIPMoney[id])
					VipItemsMenu(id)
				}
			}
			else
			{
				if(!g_bActived_NoDmg[id])
				{
					g_bActived_NoDmg[id] = true
					
					if(task_exists(id+TASK_GODMOD))
						remove_task(id+TASK_GODMOD)
						
					if(task_exists(id+TASK_HPREGEN))
						remove_task(id+TASK_HPREGEN)
					
					g_bActived_Bhop[id] = false
					g_bActived_Imm[id] = false
					g_bActived_Mj[id] = false
					g_bActived_Regen[id] = false
					g_iSelectedPower[id] = 4;
					set_pev(id,pev_takedamage,DAMAGE_NO)
					set_task(0.5, "GodMod_CountDown", id+TASK_GODMOD, _, _, "a", 3)
				}
				else
				{
					client_print_color(id, id, "^4[CSGO Classy]^1 You can not use any ^4items^1 this round because you used ^4God mode")
					VipItemsMenu(id)
				}
			}
		}
		case 5: ShowVIPMenu(id)
	}
	return PLUGIN_HANDLED
}

public Vipshop(id)
{
	new menu, szText[128];
	formatex(szText, charsmax(szText), "\r[CSGO Classy] \wMarket \r[%d V$]", VIPMoney[id])
	menu = menu_create(szText, "menuHandler");
	menu_additem(menu, "Keys market^n\dBuy keys using\d V$");
	menu_additem(menu, "Cases market^n\dBuy cases using\d V$");  
	menu_additem(menu, "Scraps market^n\dBuy scraps using\d V$");
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	if(is_user_connected(id))
		menu_display(id, menu, 0);
}

public menuHandler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        ShowVIPMenu(id)
        return PLUGIN_HANDLED;
    }
   
    switch(item)
    {
        case 0: Keys(id)
        case 1: Chest(id)
        case 2: Scrap(id)
    }
     
    return PLUGIN_HANDLED;
}

public Keys(id)
{
	new menu
	new szText[128]
	formatex(szText, charsmax(szText), "\r[CSGO Classy] \wKeys market \r[%d V$]", VIPMoney[id])
	menu = menu_create(szText, "KeysHandler")
	menu_additem(menu, "Buy 1 key \r[50 V$]")
	menu_additem(menu, "Buy 5 keys \r[250 V$]")
	menu_additem(menu, "Buy 10 keys \r[500 V$]")

	if(is_user_connected(id))
		menu_display(id, menu, 0)
    
}

public KeysHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		Vipshop(id)
		return PLUGIN_HANDLED
	}
	switch(item)
	{
		case 0:
		{
			if(VIPMoney[id] >= 50)
			{
				VIPMoney[id] -= 50
				set_user_keys(id, get_user_keys(id) + 1)
				Keys(id)
			}
			else
			{
				client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough V$, you need ^4%d more", 50 - VIPMoney[id])
				Keys(id)
			}
		}
		case 1:
		{
			if(VIPMoney[id] >= 250)
			{
				VIPMoney[id] -= 250
				set_user_keys(id,get_user_keys(id) + 5)	
				Keys(id)
			}
			else
			{
				client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough V$, you need ^4%d more",250 - VIPMoney[id])
				Keys(id)
			}
		}
		case 2:
		{
			if(VIPMoney[id] >= 500)
			{
				VIPMoney[id] -= 500
				set_user_keys(id,get_user_keys(id) + 10)	
				Keys(id)
			}
			else
			{
				client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough V$, you need ^4%d more",500 - VIPMoney[id])
				Keys(id)
			}
		}
	}
	return PLUGIN_HANDLED
}

public Chest(id)
{
	new menu
	new szText[128]
	formatex(szText, charsmax(szText), "\r[CSGO Classy] \wCases market \r[%d V$]", VIPMoney[id])
	menu = menu_create(szText, "ChestHandler")
	menu_additem(menu, "Buy 1 case \r[50 V$]")
	menu_additem(menu, "Buy 5 cases \r[250 V$]")
	menu_additem(menu, "Buy 10 cases \r[500 V$]")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)

	if(is_user_connected(id))
		menu_display(id, menu, 0)
}

public ChestHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		Vipshop(id)
		return PLUGIN_HANDLED
	}
	switch(item)
	{
		case 0:
		{
			if(VIPMoney[id] >= 50)
			{
				VIPMoney[id] -= 50
				set_user_cases(id,get_user_cases(id) + 1)		
				Chest(id)
			}
			else
			{
				client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough V$, you need ^4%d more",50 - VIPMoney[id])
				Chest(id)
			}
		}
		case 1:
		{
			if(VIPMoney[id] >= 250)
			{
				VIPMoney[id] -= 250
				set_user_cases(id,get_user_cases(id) + 5)	
				Chest(id)
			}
			else
			{
				client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough V$, you need ^4%d more", 250 - VIPMoney[id])
				Chest(id)
			}
		}
		case 2:
		{
			if(VIPMoney[id] >= 500)
			{
				VIPMoney[id] -= 500
				set_user_cases(id,get_user_cases(id) + 10)	
				Chest(id)
			}
			else
			{
				client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough V$, you need ^4%d more", 500 - VIPMoney[id])
				Chest(id)
			}
		}
	}
	return PLUGIN_HANDLED
}

public Scrap(id)
{
	new menu
	new szText[128]
	formatex(szText, charsmax(szText), "\r[CSGO Classy] \wScraps market \r[%d V$]", VIPMoney[id])
	menu = menu_create(szText, "ScrapsHandler")
	menu_additem(menu, "Buy 1 scrap \r[50 V$]")
	menu_additem(menu, "Buy 5 scraps \r[250 V$]")
	menu_additem(menu, "Buy 10 scraps \r[500 V$]")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)

	if(is_user_connected(id))
		menu_display(id, menu, 0)
}

public ScrapsHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		Vipshop(id)
		return PLUGIN_HANDLED
	}
	switch(item)
	{
		case 0:
		{
			if(VIPMoney[id] >= 50)
			{
				VIPMoney[id] -= 50
				set_user_scraps(id, get_user_scraps(id) + 1)	
				Scrap(id)
			}
			else
			{
				client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough V$, you need ^4%d more", 50 - VIPMoney[id])
				Scrap(id)
			}
		}
		case 1:
		{
			if(VIPMoney[id] >= 250)
			{
				VIPMoney[id] -= 250
				set_user_scraps(id, get_user_scraps(id) + 5)	
				Scrap(id)
			}
			else
			{
				client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough V$, you need ^4%d more", 250 - VIPMoney[id])
				Scrap(id)
			}
		}
		case 2:
		{
			if(VIPMoney[id] >= 500)
			{
				VIPMoney[id] -= 500
				set_user_scraps(id,get_user_scraps(id) + 10)	
				Scrap(id)
			}
			else
			{
				client_print_color(id, id, "^4[CSGO Classy]^1 You do not have enough V$, you need ^4%d more", 500 - VIPMoney[id])
				Scrap(id)
			}
		}	
	}
	return PLUGIN_HANDLED
}

//silver vip menus

public ShowSilverVipMenu(id)
{
	new MapName[32]
	new szLine[128]
	new iLen
	new Size = file_size(g_File2, 1)
	get_mapname(MapName, sizeof(MapName))
	for(new i = 0; i < Size; i ++)
	{
		read_file(g_File2, i, szLine, charsmax(szLine), iLen)
		if(equali(MapName, szLine))
		{
			client_print_color(id, id, "^4[CSGO Classy]^1 You ^4can not^1 acces ^4this menu^1 because you are ^4playing %s", MapName)
			silvervipmenu = false
		}
	}
	if(silvervipmenu == true && is_user_logged(id))
	{
		if(get_user_silver_vip(id) == 1)
		{
			new temp[96]
			formatex(temp, 95, "\r[CSGO Classy] \wSilver VIP membership \r[%d VE]", Experience[id])
			new menu = menu_create(temp, "silvervip_menu_handler", 0)

			new szItem[2]
			szItem[1] = 0

			formatex(temp, 95, "\wWeapons");
			menu_additem(menu, temp, szItem, 0, -1)

			formatex(temp, 95, "\dItems");
			menu_additem(menu, temp, szItem, 0, -1)

			formatex(temp, 95, "\dMarket");
			menu_additem(menu, temp, szItem, 0, -1)

			if(is_user_connected(id))	
				menu_display(id, menu)
		}

	}
	return PLUGIN_CONTINUE
}

public silvervip_menu_handler(id,menu,item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || get_user_silver_vip(id) == 0)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	switch(item)
	{
		case 0:
		{
			if (!SilverPistolsSelected[id] && CurrentRound <= 1)
			{
				SilverShowPistols(id)
			}
			if (!SilverSecondarySelected[id] && CurrentRound == 2)
			{
				SilverShowSecondary(id)	
			}
			if (!SilverWeaponSelected[id] && CurrentRound >= 3)
			{
				SilverVipWeaponsMenu(id)
			}	
		}

		case 1:
		{
			ShowSilverVipMenu(id);
			client_print_color(id, id, "^4[CSGO Classy]^1 Only players with ^4Gold VIP membership^1 can acces this ^4menu")
		}

		case 2:
		{
			ShowSilverVipMenu(id);
			client_print_color(id, id, "^4[CSGO Classy]^1 Only players with ^4Gold VIP membership^1 can acces this ^4menu")
		}
	}
	return PLUGIN_HANDLED
}

public SilverShowPistols(id)
{
	new szMenuW = menu_create("\r[CSGO Classy] \wWeapons","SilverShowPistols_handler")
	for ( new i; i < sizeof SilverVipPistols; i++)
		menu_additem( szMenuW, SilverVipPistols[ i ][ PistolName ] )	

	if(is_user_connected(id))
		menu_display(id,szMenuW)
}

public SilverShowPistols_handler(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || get_user_silver_vip(id) == 0)
	{
		menu_destroy(menu)
		ShowSilverVipMenu(id)
		return PLUGIN_HANDLED
	}

	if(user_has_weapon(id, CSW_C4) && get_user_team(id) == 1)
	{
		HasC4[id] = true
	}
	else
	{
		HasC4[id] = false
	}
	
	strip_user_weapons(id)
		
	give_item(id,"weapon_knife")
	give_item(id,"weapon_hegrenade")
	give_item(id,"weapon_flashbang")
	
	if(get_pcvar_num(gSmoke) > 0)
	{
		give_item(id, "weapon_smokegrenade")
	}

	cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
		
	SilverPistolsSelected[id] = true
		
	give_item( id, SilverVipPistols[ item ][ PistolID ] )
	cs_set_user_bpammo( id, get_weaponid( SilverVipPistols[ item ][ PistolID ] ), SilverVipPistols[ item ][ PistolAmmo ] )
	
	if(get_user_team(id) == 2)
	{
		give_item(id, "item_thighpack")
	}
	
	if (HasC4[id])
    {
        give_item(id, "weapon_c4");
        cs_set_user_plant( id );
    }

	return PLUGIN_HANDLED
}

public SilverShowSecondary(id)
{
	new szMenuW = menu_create("\r[CSGO Classy] \wWeapons","SilverShowSecondary_handler")
	
	for ( new i; i < sizeof SilverSecondaryWeapons; i++ )
		menu_additem( szMenuW, SilverSecondaryWeapons[ i ][ SecName ] )	

	if(is_user_connected(id))
		menu_display(id,szMenuW)
}

public SilverShowSecondary_handler(id,menu,item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || get_user_silver_vip(id) == 0)
	{
		menu_destroy(menu)
		ShowSilverVipMenu(id)
		return PLUGIN_HANDLED
	}

	if(user_has_weapon(id, CSW_C4) && get_user_team(id) == 1)
	{
		HasC4[id] = true
	}
	else
	{
		HasC4[id] = false
	}
	strip_user_weapons(id)	
	give_item(id,"weapon_knife")	
	give_item(id,"weapon_hegrenade")
	give_item(id,"weapon_flashbang")

	if(get_pcvar_num(gSmoke) > 0)
	{
		give_item(id, "weapon_smokegrenade")
	}

	cs_set_user_bpammo(id, CSW_FLASHBANG, 2)	
	SilverSecondarySelected[id] = true	
	give_item( id, SilverSecondaryWeapons[ item ][ SecID ] )
	cs_set_user_bpammo( id, get_weaponid( SilverSecondaryWeapons[ item ][ SecID ] ), SilverSecondaryWeapons[ item ][ SecAmmo ] )
	give_item(id,"weapon_deagle")
	cs_set_user_bpammo(id,CSW_DEAGLE,35)

	if(get_user_team(id) == 2)
	{
		give_item(id, "item_thighpack")
	}

	if (HasC4[id])
    {
        give_item(id, "weapon_c4");
        cs_set_user_plant( id );
    }

	return PLUGIN_HANDLED
}

public SilverVipWeaponsMenu(id)
{
	new szMenuW = menu_create("\r[CSGO Classy] \wWeapons","Silvervip_weapons_handler")
	
	for ( new i; i < sizeof SilverVipWeapons; i++ )
	{
		if(equali(SilverVipWeapons[i][WeaponID], "weapon_awp") && g_bFreeVipTime  && !is_user_silver_vip(id) && !get_pcvar_num(g_cvar[FREE_SILVER_AWP])) continue; else 
		menu_additem( szMenuW, SilverVipWeapons[ i ][ WeapName ] )
	}	

	if(is_user_connected(id))
		menu_display(id,szMenuW)
}

public Silvervip_weapons_handler(id,menu,item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || get_user_silver_vip(id) == 0)
	{
		menu_destroy(menu)
		ShowSilverVipMenu(id)
		return PLUGIN_HANDLED
	}

	if(user_has_weapon(id, CSW_C4) && get_user_team(id) == 1)
	{
		HasC4[id] = true
	}
	else
	{
		HasC4[id] = false
	}
	
	strip_user_weapons(id)
		
	give_item(id,"weapon_knife")
	give_item(id,"weapon_hegrenade")
	give_item(id,"weapon_flashbang")
	
	if(get_pcvar_num(gSmoke) > 0)
	{
		give_item(id, "weapon_smokegrenade")
	}
	
	cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
		
	SilverWeaponSelected[id] = true
	SilverSecondarySelected[id] = true
	SilverPistolsSelected[id] = true
		
	give_item( id, SilverVipWeapons[ item ][ WeaponID ] )
	cs_set_user_bpammo( id, get_weaponid( SilverVipWeapons[ item ][ WeaponID ] ), SilverVipWeapons[ item ][ BpAmmo ] )
		
	give_item(id,"weapon_deagle")
	cs_set_user_bpammo(id,CSW_DEAGLE,35)
	
	if(get_user_team(id) == 2)
	{
		give_item(id, "item_thighpack")
	}
	
	if (HasC4[id])
    {
        give_item(id, "weapon_c4");
        cs_set_user_plant( id );
    }

	return PLUGIN_HANDLED
}

public fwSpawn(id)
{ 
	if(!is_user_alive(id))
	{
		return HAM_IGNORED
	}

	if(is_gold_vip(id))
	{
		PistolsSelected[id] = false
		SecondarySelected[id] = false
		WeaponSelected[id] = false
		g_bActived_NoDmg[id] = false
		set_pev(id,pev_takedamage,DAMAGE_AIM)
		timer[id] = 3
			
		if(g_bActived_Regen[id])
		{
			set_task(1.0, "HPRegen", id+TASK_HPREGEN, .flags = "b")
		}
			
		if(task_exists(id+TASK_GODMOD))
		{
			remove_task(id+TASK_GODMOD)
		}

		new MapName[32]
		new szLine[128]
		new iLen
		new Size = file_size(g_File2, 1)
		get_mapname(MapName, sizeof(MapName));
		for(new i = 0; i < Size; i ++)
		{
			read_file(g_File2, i, szLine, charsmax(szLine), iLen);
			if(equali(MapName, szLine))
			{
				return HAM_IGNORED;
			}
			else if(!equali(MapName, szLine))
			{
				cs_set_user_armor(id, 100, CsArmorType:2)
			}
		}

		if(get_user_team(id) == 2)
		{
			give_item(id, "item_thighpack")
		}
	}

	if(get_user_silver_vip(id) == 1)
	{
		SilverPistolsSelected[id] = false
		SilverSecondarySelected[id] = false
		SilverWeaponSelected[id] = false

		new MapName[32]
		new szLine[128]
		new iLen
		new Size = file_size(g_File2, 1)
		get_mapname(MapName, sizeof(MapName));
		for(new i = 0; i < Size; i ++)
		{
			read_file(g_File2, i, szLine, charsmax(szLine), iLen);
			if(equali(MapName, szLine))
			{
				return 0
			}
			else if(!equali(MapName, szLine))
			{
				cs_set_user_armor(id, 100, CsArmorType:2)
			}
		}

		if(get_user_team(id) == 2)
		{
			give_item(id, "item_thighpack")
		}
	}

	return HAM_IGNORED 
}

public fw_Ham_Player_Killed_Post(const iVictim, const iAttacker)
{
	if(!iVictim || !iAttacker && !is_user_alive(iVictim) || !is_user_alive(iAttacker))
		return HAM_IGNORED
		
	if(task_exists(iVictim+TASK_HPREGEN))
		remove_task(iVictim+TASK_HPREGEN)
		
	if(task_exists(iVictim+TASK_GODMOD))
		remove_task(iVictim+TASK_GODMOD)
		
	if(is_gold_vip(iAttacker))
	{	
		VIPMoney[iAttacker] += get_pcvar_num(PcvarVIPMoneyKillBonus)
		
		static color[12],parts[3][4]
		switch( CsTeams:cs_get_user_team( iAttacker ) )
		{
			case CS_TEAM_CT:
			{	
				CVAR_color_Kill[0] = 47;
				CVAR_color_Kill[1] = 79;
				CVAR_color_Kill[2] = 79;

				if(!get_user_flashed(iAttacker))	
				{
					message_begin(MSG_ONE,get_user_msgid("ScreenFade"),_,iAttacker);
					write_short(400 * 14);
					write_short(0);
					write_short(0);
					write_byte(CVAR_color_Kill[0]);
					write_byte(CVAR_color_Kill[1]);
					write_byte(CVAR_color_Kill[2]);
					write_byte(75) ;
					message_end();
						
					parse(color,parts[0],3,parts[1],3,parts[2],3);
					CVAR_color_Kill[0] = str_to_num(parts[0]);
					CVAR_color_Kill[1] = str_to_num(parts[1]);
					CVAR_color_Kill[2] = str_to_num(parts[2]);
				}
			}
			case CS_TEAM_T:
			{		
				CVAR_color_Kill[0] = 47;
				CVAR_color_Kill[1] = 79;
				CVAR_color_Kill[2] = 79;
						
				if(!get_user_flashed(iAttacker))	
				{
					message_begin(MSG_ONE,get_user_msgid("ScreenFade"),_,iAttacker);
					write_short(400 * 14);
					write_short(0);
					write_short(0);
					write_byte(CVAR_color_Kill[0]);
					write_byte(CVAR_color_Kill[1]);
					write_byte(CVAR_color_Kill[2]);
					write_byte(75) ;
					message_end();
						
					parse(color,parts[0],3,parts[1],3,parts[2],3);
					CVAR_color_Kill[0] = str_to_num(parts[0]);
					CVAR_color_Kill[1] = str_to_num(parts[1]);
					CVAR_color_Kill[2] = str_to_num(parts[2]);
				}
			}
		}
	}

	if(is_silver_vip(iAttacker))
	{			
		VIPMoney[iAttacker] += get_pcvar_num(PcvarVIPMoneyKillBonus)
		
		static color[12],parts[3][4];
			
		switch( CsTeams:cs_get_user_team( iAttacker ) )
		{
			case CS_TEAM_CT:
			{	
				CVAR_color_Kill[0] = 47;
				CVAR_color_Kill[1] = 79;
				CVAR_color_Kill[2] = 79;

				if(!get_user_flashed(iAttacker))	
				{
					message_begin(MSG_ONE,get_user_msgid("ScreenFade"),_,iAttacker);
					write_short(400 * 14);
					write_short(0);
					write_short(0);
					write_byte(CVAR_color_Kill[0]);
					write_byte(CVAR_color_Kill[1]);
					write_byte(CVAR_color_Kill[2]);
					write_byte(75) ;
					message_end();
						
					parse(color,parts[0],3,parts[1],3,parts[2],3);
					CVAR_color_Kill[0] = str_to_num(parts[0]);
					CVAR_color_Kill[1] = str_to_num(parts[1]);
					CVAR_color_Kill[2] = str_to_num(parts[2]);
				}
			}
			case CS_TEAM_T:
			{		
				CVAR_color_Kill[0] = 47;
				CVAR_color_Kill[1] = 79;
				CVAR_color_Kill[2] = 79;
						
				if(!get_user_flashed(iAttacker))	
				{
					message_begin(MSG_ONE,get_user_msgid("ScreenFade"),_,iAttacker);
					write_short(400 * 14);
					write_short(0);
					write_short(0);
					write_byte(CVAR_color_Kill[0]);
					write_byte(CVAR_color_Kill[1]);
					write_byte(CVAR_color_Kill[2]);
					write_byte(75) ;
					message_end();
						
					parse(color,parts[0],3,parts[1],3,parts[2],3);
					CVAR_color_Kill[0] = str_to_num(parts[0]);
					CVAR_color_Kill[1] = str_to_num(parts[1]);
					CVAR_color_Kill[2] = str_to_num(parts[2]);
				}
			}
		}
	}
	else
	{
		Experience[iAttacker] += random_num(get_pcvar_num(min_ve), get_pcvar_num(max_ve))
		if(Experience[iAttacker] >= get_pcvar_num(PcvarMaxExperience))
		{
			new Name[32]
			get_user_name(iAttacker, Name, 31)
			client_print_color(0, 0, "^4%s %s^1 has reached^4 %d VE^1, get in touch with a ^4founder^1 to receive your ^4free permanent Gold VIP membership", "[CSGO Classy]", Name, get_pcvar_num(PcvarMaxExperience))
			client_cmd(0,"spk buttons/bell1")
			Experience[iAttacker] = 0
		}
	}
	return HAM_IGNORED
}

public GodMod_CountDown(id)
{
	id -= TASK_GODMOD
	if(task_exists(id+TASK_GODMOD))
	{		
		timer[id]--	
		if(timer[id] == 0)
		{
			remove_task(id+TASK_GODMOD)
			set_pev(id, pev_takedamage, DAMAGE_AIM)
			timer[id] = g_iGodModeDuration;
		}
	}
}

public HPRegen(id)
{
    id -= TASK_HPREGEN
    if(!is_user_alive(id))
	{
		return PLUGIN_HANDLED
	}
    else
	{
		if(get_user_health(id) >= get_pcvar_num(PcvarMaxRegenHP))
    	{
        	set_user_health(id, get_pcvar_num(PcvarMaxRegenHP))
       		return PLUGIN_HANDLED
    	}
		else
    	{
        	set_user_health(id, get_user_health(id) + get_pcvar_num(PcvarHpRegenAdd))
    	}
	}
    return PLUGIN_CONTINUE
}

public ham_Player_TakeDamage_Post(iVictim, iInfictor, iAttacker, Float:fDamage, iDmgBits)
{
	if(!is_user_connected(iVictim) || !is_user_connected(iAttacker) || iVictim == iAttacker)
		return HAM_IGNORED

	if(g_bActived_Imm[iAttacker])
	{
		if(cs_get_user_team(iAttacker) != cs_get_user_team(iVictim))
		{
			if(iDmgBits & DMG_BULLET || iDmgBits & (1<<24) || iDmgBits & DMG_SLASH)
			{
				new random = random_num(0, 10)
				
				if(is_user_alive(iVictim) && random == 3 && !g_bActived_NoDmg[iVictim])
				{
					set_pev(iVictim, pev_velocity, {0.0 , 0.0 , 0.0})
					set_pev(iVictim, pev_flags, pev(iVictim, pev_flags) | FL_FROZEN)
					set_task(g_fFreezeSeconds, "remove_frozen", iVictim)
				}
			}
		}
	}
	return HAM_IGNORED
}

public remove_frozen(Victim)
{
	set_pev(Victim, pev_flags, pev(Victim, pev_flags) & ~FL_FROZEN);
}

SaveVIP(id)
{
	new szAuthid[32] 
	get_user_authid( id, szAuthid, charsmax( szAuthid ) ) 
	
	new szVaultKey[128], szVaultData[512] 
	
	formatex( szVaultKey, 127, "vip_%s", szAuthid ) 
	formatex( szVaultData, 511, "%i %i %i %i %i %i %i %i %i", VIP[id],VIPMoney[id],VIPBh[id],VIPMj[id],VIPNoDmg[id],VIPRegen[id],VIPImm[id], Experience[id], g_iSelectedPower[id]) 
	nvault_set( g_nVault, szVaultKey, szVaultData ) 
} 

LoadVIP(id) 
{
	g_iSelectedPower[id] = 0;
	new szAuthid[32] 
	get_user_authid( id, szAuthid, charsmax( szAuthid ) ) 
	new szVaultKey[128], szVaultData[512] 
	formatex( szVaultKey, 127, "vip_%s", szAuthid ) 
	nvault_get( g_nVault, szVaultKey, szVaultData, 511 ) 
	new vp[32],vpm[32],vpmj[32],vpbhop[32],vpnodmg[32],vpregen[32],vpimm[32],exp[32], szSelectedPower[32]
	parse(szVaultData, vp, charsmax(vp), vpm, charsmax(vpm), vpbhop, charsmax(vpbhop), vpmj, charsmax(vpmj), vpnodmg, charsmax(vpnodmg), vpregen, charsmax(vpregen),vpimm, charsmax(vpimm), exp, charsmax(exp), szSelectedPower, charsmax(szSelectedPower))
	VIP[id] = str_to_num(vp)
	VIPMoney[id] = str_to_num(vpm) 
	VIPBh[id] = str_to_num(vpbhop)
	VIPMj[id] = str_to_num(vpmj)
	VIPNoDmg[id] = str_to_num(vpnodmg)
	VIPRegen[id] = str_to_num(vpregen)
	VIPImm[id] = str_to_num(vpimm)
	Experience[id] = str_to_num(exp)
	g_iSelectedPower[id] = str_to_num(szSelectedPower);

	g_bActived_Mj[id] = false
	g_bActived_Bhop[id] = false
	g_bActived_Imm[id] = false
	g_bActived_Regen[id] = false
	g_bActived_NoDmg[id] = false

	set_task(1.0, "set_skills", id + TASK_SET_SKILLS);

	return PLUGIN_CONTINUE;
}

public set_skills(id)
{
	id -= TASK_SET_SKILLS;
	new bool:g_bStopped, szLine[50], iLen;
	new Size = file_size(g_File2, 1);
	new  MapName[50];
	get_mapname(MapName, charsmax(MapName));
	for(new i = 0; i < Size; i ++)
	{
		read_file(g_File2, i, szLine, charsmax(szLine), iLen);
		if(equali(MapName, szLine))
		{
			g_bStopped = true;
			return PLUGIN_HANDLED;
		}
	}

	if(g_bStopped == true)
		return PLUGIN_HANDLED;

	if(is_gold_vip(id))
	{
		switch(g_iSelectedPower[id])
		{
			case 0: { if(VIPMj[id] != 0) g_bActived_Mj[id] = true; }  
			case 1: { if(VIPRegen[id] != 0) g_bActived_Regen[id] = true; }
			case 2: { if(VIPNoDmg[id] != 0) g_bActived_NoDmg[id] = true; }
			case 3: { if(VIPBh[id] != 0) g_bActived_Bhop[id] = true; }
			case 4: { if(VIPImm[id] != 0) g_bActived_Imm[id] = true; }
		}
	}

	return PLUGIN_CONTINUE;
}

public plugin_end() 
{ 
	nvault_close(g_nVault)
	return PLUGIN_CONTINUE 
} 

public plugin_cfg() 
{ 
	new File[64];
	new szCSGOConfigDir[64]
	csgo_directory(szCSGOConfigDir, charsmax(szCSGOConfigDir))
	get_configsdir(File, charsmax(File));
	formatex(g_File2, charsmax(g_File2), "%s/%s/%s", File, szCSGOConfigDir, g_VipMaps);

	if(!file_exists(g_File2))
	{
		write_file(g_File2, ";Syntax: map name");
		write_file(g_File2, ";Example: awp_india");
	}

	g_nVault = nvault_open("csgoclassyvip")

	if( g_nVault == INVALID_HANDLE )
		set_fail_state("Error opening VIP nVault, file does not exist") 
}

public CmdStart(id, uc_handle)
{
	if( !is_user_alive( id ))
		return FMRES_IGNORED
		
	new flags = pev( id, pev_flags )
	
	if( ( get_uc( uc_handle, UC_Buttons ) & IN_JUMP ) && !( flags & FL_ONGROUND ) && !( pev( id, pev_oldbuttons ) & IN_JUMP ) && g_iJumpCount[ id ] )
	{
		g_iJumpCount[ id ]--
		new Float:velocity[ 3 ]
		pev( id, pev_velocity, velocity )
		velocity[ 2 ] = random_float( 265.0,285.0 )
		set_pev( id, pev_velocity, velocity )
	}
	else if( flags & FL_ONGROUND )
	{
		g_iJumpCount[ id ] = g_bActived_Mj[id] ? 1 : 0
	}
	return FMRES_IGNORED
}

public ham_Player_PostThink_Post( id )
{
	if( !is_user_alive( id ) )
		return HAM_IGNORED
		
	if( g_bActived_Bhop[id])
	{
		if( pev( id, pev_button) & IN_JUMP )
		{
			new flags = pev( id, pev_flags )
			
			if( flags & FL_WATERJUMP )
				return HAM_IGNORED
				
			if( pev( id, pev_waterlevel ) >= 2 )
				return HAM_IGNORED
				
			if( !( flags & FL_ONGROUND ) )
				return HAM_IGNORED
				
			new Float:velocity[3]
			pev(id, pev_velocity, velocity)
			velocity[2] = 250.0
			
			static Float:fMaxScaledSpeed
			pev(id, pev_maxspeed, fMaxScaledSpeed)
			if(fMaxScaledSpeed > 0.0)
			{
				fMaxScaledSpeed *= BUNNYJUMP_MAX_SPEED_FACTOR
				static Float:fSpeed
				fSpeed = floatsqroot(velocity[0]*velocity[0] + velocity[1]*velocity[1] + velocity[2]*velocity[2])
				if(fSpeed > fMaxScaledSpeed)
				{
					static Float:fFraction
					fFraction = ( fMaxScaledSpeed / fSpeed ) * 1.0
					velocity[0] *= fFraction
					velocity[1] *= fFraction
					velocity[2] *= fFraction
				}
			}
			set_pev(id, pev_velocity, velocity)
			entity_set_int(id, EV_INT_gaitsequence, 6)
		}
	}
	return HAM_IGNORED
}

public CmdGiveVipMoney(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new g_szName[32]  
	get_user_name(id, g_szName, charsmax(g_szName))

	new arg1[32];
	new arg2[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 15);
	new target;

	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "[CSGO Classy] %s was not found", arg1);
		return 1;
	}
	new amount = str_to_num(arg2);
	if (0 < amount)
	{
		VIPMoney[target] += amount;
		console_print(id, "[CSGO Classy] You gave %s %d V$", arg1, amount);
	}

	SaveVIP(target)
	return 1;
}

public CmdGiveVipExperience(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new g_szName[32]  
	get_user_name(id, g_szName, charsmax(g_szName))

	new arg1[32];
	new arg2[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 15);
	new target;

	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "[CSGO Classy] %s was not found", arg1);
		return 1;
	}
	new amount = str_to_num(arg2);
	if (0 < amount)
	{
		Experience[target] += amount;
		console_print(id, "[CSGO Classy] You gave %s %d VE", arg1, amount);
	}

	SaveVIP(target)
	return 1;
}

get_user_flashed( id, &iPercent=0 ) 
{ 
    new Float:flFlashedAt = get_pdata_float( id, m_flFlashedAt, XO_PLAYER ) 

    if( !flFlashedAt ) 
    { 
        return 0 
    }

    new Float:flGameTime = get_gametime( ) 
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
            iPercent = 100-floatround( ( ( flGameTime - ( flFlashedAt + flFlashHoldTime ) )*100.0 )/flFlashDuration ) 
        } 
    } 
    else 
    { 
        iPercent = 100-floatround( ( ( flGameTime - flFlashedAt )*100.0 )/flTotalTime ) 
    } 
    
    return iFlashAlpha 
}

public client_PostThink(id)
{
    if(g_bFreeVipTime)
    {
        if(!is_gold_vip(id))
        {
            set_user_silver_vip(id, 1)
        }
    }
}

public OnNewRound(id)
{
	if(!get_pcvar_num(g_iCvars[0]))
		return PLUGIN_CONTINUE;

	if(IsVipHour(get_pcvar_num(g_iCvars[1]), get_pcvar_num(g_iCvars[2])))
	{
		g_bFreeVipTime = true;
		if(!is_gold_vip(id))
		{
			set_user_silver_vip(id, 1)
		}
	}
	else
	{
		g_bFreeVipTime = false;

		if(!is_silver_vip(id))
			set_user_silver_vip(id, 0)
	}
	
	return PLUGIN_CONTINUE;
}

bool:IsVipHour(iStart, iEnd)
{
    new iHour; time( iHour );
    return bool:( iStart < iEnd ? ( iStart <= iHour < iEnd ) : ( iStart <= iHour || iHour < iEnd ))
}