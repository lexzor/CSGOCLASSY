#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <unixtime>
#include <csgoclassy>

#define PLUGIN 		"CSGO Classy Weapon Owner"
#define VERSION 	"1.1"
#define AUTHOR 		"Some author + lexzor"

#pragma compress 1

#if !defined MAX_PLAYERS
	const MAX_PLAYERS = 32
#endif

#define pev_skinId		82
#define g_offsetActiveItem	373

native getSkinName(id, iWeaponId, szWeapon[]);
native getWeaponSkinId(id, iWeaponId);
native updateWeaponSkin(id, iWeaponID, skinID);
native has_skin_tag(id, weaponid);
native get_skin_tag(id, weaponid, buffer[], buffermaxlength);
native get_skin_level(id, weaponid);
native is_in_preview(id);

new R, G, B;

new const WEAPONENTNAMES[][] = 
{   
	"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
    	"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
    	"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
    	"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
    	"weapon_ak47", "weapon_knife", "weapon_p90" 
}

new const g_szSlots[] =
{
	0,
	2,
	0,
	1, 
	4,
	1,
	5,
	1,
	1,
	4,
	2,
	2,
	1,
	1,
	1,
	1,
	2,
	2,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	4,
	2,
	1,
	1,
	3,
	1
}

stock const m_rgpPlayerItems_CBasePlayer[6] = {367,368,...}
new g_iRealOwner[MAX_PLAYERS + 1][60]
new bool:g_bCantPickup[MAX_PLAYERS + 1]

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("drop", "itemDrop")
	register_event("TextMsg", "Event_GameWillRestartIn", "a", "2=#Game_will_restart_in&1=0", "2=0")
	
	register_forward(FM_SetModel, "forward_SetModel")
	register_forward(FM_Touch, "forward_touch")
	RegisterHam(Ham_Killed, "player", "fw_Killed", true);
	
	set_task(1.0, "printOwnerStatus", .flags = "b")
}

public fw_Killed(id) {
	if(!is_user_alive(id))
	{
		resetSkins(id);
	}
}

public plugin_natives()
{
	register_native("isUsingSomeoneElsesWeapon", "_check", 0)
	register_native("getOriginalOwnerID", "_get", 0)
	register_native("isUsingCertainPlayersSkin", "_is", 0)
}

public _is(iPluginID, iParamNum) 
{
	new iPlayer = get_param(1), id = get_param(2), iWeaponID = get_param(3)
	return bool:((g_iRealOwner[iPlayer][iWeaponID] > 0) && (g_iRealOwner[iPlayer][iWeaponID] == id))
}

public _get(iPluginID, iParamNum)
{
	new id = get_param(1), iWeaponID = get_param(2)
	if((g_iRealOwner[id][iWeaponID] > 0) && (g_iRealOwner[id][iWeaponID] != id))
	{
		return g_iRealOwner[id][iWeaponID]
	}
	return 0
}

public _check(iPluginID, iParamNum)
{
	new id = get_param(1), iWeaponID = get_param(2)
	return bool:((g_iRealOwner[id][iWeaponID] > 0) && (g_iRealOwner[id][iWeaponID] != id))
}

public forward_touch(ent, toucher) 
{
	if(!pev_valid(ent))
		return FMRES_IGNORED
		
	new szClassNameTouched[32], iEntityWeaponID
	pev(ent, pev_classname, szClassNameTouched, charsmax(szClassNameTouched))
	if(!equal(szClassNameTouched, "weaponbox"))
		return FMRES_IGNORED
		
	if(is_user_connected(toucher))
	{
		if(g_bCantPickup[toucher])
			return FMRES_SUPERCEDE
			
		for (new i = global_get(glb_maxClients) + 1; i < global_get(glb_maxEntities); ++i) 
		{
			if (!pev_valid(i) || ent != pev(i, pev_owner))
				continue
					
			iEntityWeaponID = cs_get_weapon_id(i)
			if(HasUserWeaponSlot(toucher, g_szSlots[iEntityWeaponID]))
			{
				break
			}
				
			new owner = pev(i, pev_iuser2)
			if(owner)
			{
				if(!is_user_connected(owner))
				{
					set_pev(i, pev_iuser2, 0)
					continue
				}
				
				g_iRealOwner[toucher][iEntityWeaponID] = owner
			}
		}
	}
	return FMRES_IGNORED
}

public forward_SetModel(iEnt, szModel[])
{
	if(!pev_valid(iEnt))
		return FMRES_IGNORED
		
	new iDropperOwner = pev(iEnt, pev_owner)
	if(!is_user_connected(iDropperOwner))
		return FMRES_IGNORED

	static class[MAX_PLAYERS]
	pev(iEnt, pev_classname, class, charsmax(class))
	if(equal(class, "weaponbox"))
	{
		for (new iEntityWeaponID, iRealOwner, i = global_get(glb_maxClients) + 1; i < global_get(glb_maxEntities); ++i) 
		{
			if (!pev_valid(i) || iEnt != pev(i, pev_owner))
				continue
				
			iEntityWeaponID = cs_get_weapon_id(i)
			iRealOwner = pev(i, pev_iuser2)
			if(!iRealOwner)
			{
				if(g_iRealOwner[iDropperOwner][iEntityWeaponID] && is_user_connected(g_iRealOwner[iDropperOwner][iEntityWeaponID]))
				{
					set_pev(i, pev_iuser2, g_iRealOwner[iDropperOwner][iEntityWeaponID])
				}
				else 
				{
					if(is_user_connected(iDropperOwner))
					{
						set_pev(i, pev_iuser2, iDropperOwner)
					}
				}
			}
		}
	}
	return FMRES_IGNORED
}

public Event_GameWillRestartIn()
{
	new iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")
	for(new i;i < iNum;i++)
	{
		resetSkins(iPlayers[i])
	}
}

public CS_OnBuy(id, iItem)
{
	if(!user_has_weapon(id, iItem))
	{
		g_iRealOwner[id][iItem] = 0
	}
}

new g_szLastFormatHud[33][50][32]

public printOwnerStatus()
{   
	new iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ach")
	for(new i, id, iRealOwner, iWeaponID, iKillCount, szHudMessage[192];i < iNum;i++)
	{
		id = iPlayers[i]

		if(!is_user_logged(id))
			continue
			
		iWeaponID = get_user_weapon(id)
		
		new szOwnerName[32], szWeaponName[32]
		if((g_iRealOwner[id][iWeaponID] > 0) && (g_iRealOwner[id][iWeaponID] != id))
		{
			get_user_name((iRealOwner = g_iRealOwner[id][iWeaponID]), szOwnerName, charsmax(szOwnerName))
			iKillCount = getSkinName(iRealOwner, iWeaponID, szWeaponName)
			if(szWeaponName[0])
			{
				new iActiveItem = get_pdata_cbase(id, g_offsetActiveItem, 5, 0)
				if(!pev_valid(iActiveItem))
					continue
					
				if(pev_valid(iActiveItem))
				{
					if(pev(iActiveItem, pev_skinId) != getWeaponSkinId(iRealOwner, iWeaponID))
					{
						set_pev(iActiveItem, pev_skinId, getWeaponSkinId(iRealOwner, iWeaponID) + 1)
					}
				}
				
				if(!equal(g_szLastFormatHud[id][iWeaponID], szWeaponName))
				{
					updateWeaponSkin(id, iWeaponID, getWeaponSkinId(iRealOwner, iWeaponID))
					g_szLastFormatHud[id][iWeaponID] = szWeaponName
				}
				
				if(has_skin_tag(iRealOwner, getWeaponSkinId(iRealOwner, iWeaponID)))
				{
					switch(get_skin_level(iRealOwner, getWeaponSkinId(iRealOwner, iWeaponID)))
					{
						case 1:
						{
							R = 47;
							G = 79;
							B = 79;
						}

						case 2:
						{
							R = 220;
							G = 30;
							B = 0;
						}

						case 3:
						{
							R = 199;
							G = 69;
							B = 255;
						}
					}

					static szSkinTag[17];
					get_skin_tag(iRealOwner, getWeaponSkinId(iRealOwner, iWeaponID), szSkinTag, charsmax(szSkinTag));
					formatex(szHudMessage, charsmax(szHudMessage), "%s (%s's %s)^n%d confirmed kills", szSkinTag, szOwnerName, szWeaponName, iKillCount);
					printForSpecs(id, szHudMessage, get_skin_level(iRealOwner, getWeaponSkinId(iRealOwner, iWeaponID)))	
				}
				else 
				{
					R = 47;
					G = 79;
					B = 79;

					formatex(szHudMessage, charsmax(szHudMessage), "%s's StatTrak (TM) %s^n%d confirmed kills", szOwnerName, szWeaponName, iKillCount)
					printForSpecs(id, szHudMessage, 0)		
				}

				if(!is_in_preview(id))
				{
					set_hudmessage(R, G, B, -1.0, 0.75, 0, 1.0, 1.0)
					show_hudmessage(id, szHudMessage);
				}
			}
			else
			{
				g_szLastFormatHud[id][iWeaponID] = ""
					
				new iActiveItem = get_pdata_cbase(id, g_offsetActiveItem, 5, 0)
				if(pev_valid(iActiveItem))
				{
					set_pev(iActiveItem, pev_skinId, 3812)
					updateWeaponSkin(id, iWeaponID, 3812)
				}
			}
		}
		else
		{
			iKillCount = getSkinName(id, iWeaponID, szWeaponName)
			if(szWeaponName[0])
			{
				new iActiveItem = get_pdata_cbase(id, g_offsetActiveItem, 5, 0)
				if(!pev_valid(iActiveItem))
					continue
					
				if(pev(iActiveItem, pev_skinId) > 0)
				{
					if(pev(iActiveItem, pev_skinId) != getWeaponSkinId(id, iWeaponID))
					{	
						set_pev(iActiveItem, pev_skinId, getWeaponSkinId(id, iWeaponID) + 1)
					}
				}
				
				if(!equal(g_szLastFormatHud[id][iWeaponID], szWeaponName))
				{
					updateWeaponSkin(id, iWeaponID, getWeaponSkinId(id, iWeaponID))
					g_szLastFormatHud[id][iWeaponID] = szWeaponName
				}

				static R, G ,B;
				
				if(has_skin_tag(id, getWeaponSkinId(id, iWeaponID)))
				{
					switch(get_skin_level(id, getWeaponSkinId(id, iWeaponID)))
					{
						case 1:
						{
							R = 47;
							G = 79;
							B = 79;
						}

						case 2:
						{
							R = 220;
							G = 30;
							B = 0;
						}

						case 3:
						{
							R = 199;
							G = 69;
							B = 255;
						}
					}

					static szSkinTag[17];
					get_skin_tag(id, getWeaponSkinId(id, iWeaponID), szSkinTag, charsmax(szSkinTag));
					formatex(szHudMessage, charsmax(szHudMessage), "%s (%s)^n%d confirmed kills", szSkinTag, szWeaponName, iKillCount);
					printForSpecs(id, szHudMessage, get_skin_level(id, getWeaponSkinId(id, iWeaponID)))	
				
				}
				else 
				{	
					R = 47;
					G = 79;
					B = 79;

					formatex(szHudMessage, charsmax(szHudMessage), "StatTrak (TM) %s^n%d confirmed kills", szWeaponName, iKillCount)
					printForSpecs(id, szHudMessage, 0)		
				}

				if(!is_in_preview(id))
				{
					set_hudmessage(R, G, B, -1.0, 0.75, 0, 1.0, 1.0)
					show_hudmessage(id, szHudMessage);
				}
			}
		}
	}

	return PLUGIN_HANDLED;
}

printForSpecs(id, szMessageFmt[], type)
{
	for(new iSpectator= 1, iSpectating;iSpectator <= get_maxplayers();iSpectator++)
	{
		if(!is_user_connected(iSpectator))
			continue
			
		iSpectating = entity_get_int(iSpectator, EV_INT_iuser2)
		if(iSpectating != id)
			continue

		static R, G ,B;

		switch(type)
		{
			case 1:
			{
				R = 47;
				G = 79;
				B = 79;
			}

			case 2:
			{
				R = 220;
				G = 30;
				B = 0;
			}

			case 3:
			{
				R = 199;
				G = 69;
				B = 255;
			}

			default:
			{
				R = 47;
				G = 79;
				B = 79;	
			}
		}

		set_hudmessage(R, G, B, -1.0, 0.75, 0, 1.0, 1.0)
		show_hudmessage(iSpectator, szMessageFmt)
	}
}

public itemDrop(id)
{
	g_bCantPickup[id] = true
	resetSkins(id)
	set_task(0.1, "setData", id)
}

public setData(id)
{
	g_bCantPickup[id] = false
}

HasUserWeaponSlot(id, slot)	
{
	return get_pdata_cbase(id, m_rgpPlayerItems_CBasePlayer[slot]) > 0
}

native cs_set_viewmodel_body(id, weaponId, iBodyPart);
native cs_set_modelformat(id, weaponId, viewModel[]);

resetSkins(id)
{
	if(!is_user_connected(id))
		return

	for (new i = 1, weaponId; i < sizeof WEAPONENTNAMES; i++)
	{
		if(WEAPONENTNAMES[i][0])
		{
			weaponId = get_weaponid(WEAPONENTNAMES[i])
			// if(equali(WEAPONENTNAMES[i], "weapon_ak47"))
			// 	server_print("Owner id: %i", g_iRealOwner[id][weaponId])

			if((g_iRealOwner[id][weaponId] > 0) && (g_iRealOwner[id][weaponId] != id))
			{
				cs_set_viewmodel_body(id, weaponId, -1)
				cs_set_modelformat(id, weaponId, "")
			}
			g_iRealOwner[id][weaponId] = 0
		}
	}
}
