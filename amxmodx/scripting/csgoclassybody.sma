#include <amxmodx>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <unixtime>
#include <csgoclassy>

#define PLUGIN	"CSGO Classy Enhanced Models Rendering"
#define VERSION	"1.1"
#define AUTHOR	"lexzor"

#pragma compress 1

#define XO_WEAPON 4
#define XO_PLAYER 5
#define m_pPlayer 41

#define NULLENT -1
#define OBS_IN_EYE 4

#define TRUE 1
#define FALSE 0

#define WPNSTATE_GLOCK18_BURST_MODE (1<<1)
#define WPNSTATE_FAMAS_BURST_MODE (1<<4)
#define WPNSTATE_M4A1_SILENCED (1<<2)
#define WPNSTATE_USP_SILENCED (1<<0)
#define WPNSTATE_ELITE_LEFT (1<<3)
#define UNSIL 0
#define SILENCED 1

#define FLASHLIGHT_IMPULSE		100

#define WEAPONTYPE_ELITE 1
#define WEAPONTYPE_GLOCK18 2
#define WEAPONTYPE_FAMAS 3
#define WEAPONTYPE_OTHER 4
#define WEAPONTYPE_M4A1 5
#define WEAPONTYPE_USP 6

#define IDLE_ANIM 0
#define GLOCK18_SHOOT2 4
#define GLOCK18_SHOOT3 5
#define AK47_SHOOT1 3
#define AUG_SHOOT1 3
#define AWP_SHOOT2 2
#define DEAGLE_SHOOT1 2
#define ELITE_SHOOTLEFT5 6
#define ELITE_SHOOTRIGHT5 12
#define CLARION_SHOOT2 4
#define CLARION_SHOOT3 3
#define FIVESEVEN_SHOOT1 1
#define G3SG1_SHOOT 1
#define GALIL_SHOOT3 5
#define M3_FIRE2 2
#define XM1014_FIRE2 2
#define M4A1_SHOOT3 3
#define M4A1_UNSIL_SHOOT3 10
#define M249_SHOOT2 2
#define MAC10_SHOOT1 3
#define MP5N_SHOOT1 3
#define P90_SHOOT1 3
#define P228_SHOOT2 2
#define SCOUT_SHOOT 1
#define SG550_SHOOT 1
#define SG552_SHOOT2 4
#define TMP_SHOOT3 5
#define UMP45_SHOOT2 4
#define USP_UNSIL_SHOOT3 11
#define USP_SHOOT3 3

#define PDATA_SAFE						2
#define OFFSET_WEAPON_IN_RELOAD       	54

#define OFFSET_WEAPON_IDLE 48

#define SHELL_MODEL	"models/pshell.mdl"
#define SHOTGUN_SHELL_MODEL "models/shotgunshell.mdl"

#define DRYFIRE_PISTOL "weapons/dryfire_pistol.wav"
#define DRYFIRE_RIFLE "weapons/dryfire_rifle.wav"

#define WEAPON_STRING(%0,%1) (pev(%0, pev_classname, %1, charsmax(%1)))
#define WEAPON_ENT(%0) (get_pdata_int(%0, m_iId, XO_WEAPON))
#define CLIENT_DATA(%0,%1,%2) (get_user_info(%0, %1, %2, charsmax(%2)))
#define HOOK_DATA(%0,%1,%2) (set_user_info(%0, %1, %2))

new static TASK_DELAY = 5224;

stock m_iId = 43

stock m_flNextPrimaryAttack = 46
stock m_iClip = 51
stock m_iShellId = 57
stock m_iShotsFired = 64
stock m_iWeaponState = 74
stock m_flLastEventCheck = 38

stock m_flEjectBrass = 111
stock m_pActiveItem = 373

new g_szUserModel[33][50][64]

new bool:deagleDisable[MAX_PLAYERS + 1];

new const weaponsWithoutInspect = (1<<CSW_C4) | (1<<CSW_HEGRENADE) | (1<<CSW_FLASHBANG) | (1<<CSW_SMOKEGRENADE);
new inspectAnimation[] =
{
	0,	//null
	7,	//p228
	0,	//shield
	5,	//scout
	0,	//hegrenade
	7,	//xm1014
	0,	//c4
	6,	//mac10
	6,	//aug
	0,	//smoke grenade
	16,	//elites
	6,	//fiveseven
	6,	//ump45
	5,	//sg550
	6,	//galil
	6,	//famas
	16,	//usp
	13,	//glock
	6,	//awp
	6,	//mp5
	5,	//m249
	7,	//m3
	14,	//m4a1
	6,	//tmp
	5,	//g3sg1
	0,	//flashbang
	6,	//deagle
	6,	//sg552
	6,	//ak47
	8,	//knife
	6	//p90
};

new WeaponNames[][] = { "weapon_knife", "weapon_glock18", "weapon_ak47", "weapon_aug", "weapon_awp", "weapon_c4", "weapon_deagle", "weapon_elite", "weapon_famas", 
	"weapon_fiveseven", "weapon_flashbang", "weapon_g3sg1", "weapon_galil", "weapon_hegrenade", "weapon_m3", "weapon_xm1014", "weapon_m4a1", "weapon_m249", "weapon_mac10", 
	"weapon_mp5navy", "weapon_p90", "weapon_p228", "weapon_scout", "weapon_sg550", "weapon_sg552", "weapon_smokegrenade", "weapon_tmp", "weapon_ump45", "weapon_usp" }

new iBodyIndex[MAX_PLAYERS + 1][50]
new g_lasttime[MAX_PLAYERS + 1]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for (new i; i < sizeof WeaponNames; i++)
	{
		RegisterHam(Ham_Item_Deploy, WeaponNames[i], "HamF_Item_Deploy_Post", TRUE)
		RegisterHam(Ham_CS_Weapon_SendWeaponAnim, WeaponNames[i], "HamF_CS_Weapon_SendWeaponAnim_Post", TRUE);
		RegisterHam(Ham_Weapon_PrimaryAttack, WeaponNames[i], "HamF_Weapon_PrimaryAttack")
	}
	
	new iEnt
	iEnt = create_entity("info_target")
	set_pev(iEnt, pev_classname, "check_spectator")
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.0001)
	register_think("check_spectator", "checkSpectatingPlayers")
	
	RegisterHam(Ham_Weapon_Reload, "weapon_deagle", "deagle_reload");
	RegisterHam(Ham_Item_Deploy, "weapon_deagle", "deagle_override");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "deagle_override");
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "knife_override");
	
	register_impulse(100, "inspect_weapon")
	register_clcmd("inspect", "inspect_weapon")
	
	register_forward(FM_UpdateClientData, "FM_Hook_UpdateClientData_Post", TRUE);
	register_forward(FM_PlaybackEvent, "Forward_PlaybackEvent");
	register_forward(FM_ClientUserInfoChanged, "Forward_ClientUserInfoChanged");
}

public HamF_Item_Deploy_Post(iEnt)
{
	new iPlayer = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)
	if(is_user_connected(iPlayer))
	{
		g_lasttime[iPlayer] = 0
		
		if(!g_szUserModel[iPlayer][cs_get_weapon_id(iEnt)][0] || !is_user_logged(iPlayer))
			return HAM_IGNORED
		
		if(task_exists(iPlayer + TASK_DELAY))
		{
			remove_task(iPlayer + TASK_DELAY)
		}
	
		set_pev(iPlayer, pev_viewmodel2, "")
		set_task(0.1, "DeployWeaponSwitch", iPlayer + TASK_DELAY);
	}
	return HAM_IGNORED
}

public HamF_Weapon_PrimaryAttack(iEnt)
{
	switch(WEAPON_ENT(iEnt))
	{
		case CSW_C4, CSW_HEGRENADE, CSW_FLASHBANG, CSW_SMOKEGRENADE:
			return HAM_IGNORED;
			
		default: 
		{
			g_lasttime[get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)] = 0
			PrimaryAttackEmulation(iEnt);
		}
	}
	
	return HAM_IGNORED;
}

stock PrimaryAttackEmulation(iEnt)
{
	switch(WEAPON_ENT(iEnt))
	{
		case CSW_GLOCK18: 			WeaponShootInfo(iEnt, GLOCK18_SHOOT3, DRYFIRE_PISTOL, FALSE, WEAPONTYPE_GLOCK18);
		case CSW_AK47: 				WeaponShootInfo(iEnt, AK47_SHOOT1, DRYFIRE_RIFLE,  TRUE, WEAPONTYPE_OTHER);
		case CSW_AUG: 				WeaponShootInfo(iEnt, AUG_SHOOT1, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_AWP: 				WeaponShootInfo(iEnt, AWP_SHOOT2, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_DEAGLE: 			WeaponShootInfo(iEnt, DEAGLE_SHOOT1, DRYFIRE_PISTOL, FALSE, WEAPONTYPE_OTHER);
		case CSW_ELITE: 			WeaponShootInfo(iEnt, ELITE_SHOOTRIGHT5, DRYFIRE_PISTOL,  FALSE, WEAPONTYPE_ELITE);
		case CSW_FAMAS: 			WeaponShootInfo(iEnt, CLARION_SHOOT3, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_FAMAS);
		case CSW_FIVESEVEN: 		WeaponShootInfo(iEnt, FIVESEVEN_SHOOT1, DRYFIRE_PISTOL,  FALSE, WEAPONTYPE_OTHER);
		case CSW_G3SG1: 			WeaponShootInfo(iEnt, G3SG1_SHOOT, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_GALIL: 			WeaponShootInfo(iEnt, GALIL_SHOOT3, DRYFIRE_RIFLE,  TRUE, WEAPONTYPE_OTHER);
		case CSW_M3: 				WeaponShootInfo(iEnt, M3_FIRE2, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_XM1014: 			WeaponShootInfo(iEnt, XM1014_FIRE2, DRYFIRE_RIFLE,  TRUE, WEAPONTYPE_OTHER);
		case CSW_M4A1: 				WeaponShootInfo(iEnt, M4A1_UNSIL_SHOOT3, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_M4A1);
		case CSW_M249: 				WeaponShootInfo(iEnt, M249_SHOOT2, DRYFIRE_RIFLE,  TRUE, WEAPONTYPE_OTHER);
		case CSW_MAC10: 			WeaponShootInfo(iEnt, MAC10_SHOOT1, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_MP5NAVY: 			WeaponShootInfo(iEnt, MP5N_SHOOT1, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_P90: 				WeaponShootInfo(iEnt, P90_SHOOT1, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_P228: 				WeaponShootInfo(iEnt, P228_SHOOT2, DRYFIRE_PISTOL, FALSE, WEAPONTYPE_OTHER);
		case CSW_SCOUT: 			WeaponShootInfo(iEnt, SCOUT_SHOOT, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_SG550: 			WeaponShootInfo(iEnt, SG550_SHOOT, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_SG552: 			WeaponShootInfo(iEnt, SG552_SHOOT2, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_TMP: 				WeaponShootInfo(iEnt, TMP_SHOOT3, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_UMP45: 			WeaponShootInfo(iEnt, UMP45_SHOOT2, DRYFIRE_RIFLE, TRUE, WEAPONTYPE_OTHER);
		case CSW_USP: 				WeaponShootInfo(iEnt, USP_UNSIL_SHOOT3, DRYFIRE_PISTOL, FALSE, WEAPONTYPE_USP);	
	}
	
	return HAM_IGNORED;
}

stock WeaponShootInfo(iEnt, iAnim, const szSoundEmpty[], iAutoShoot, iWeaponType)
{
	static iPlayer, iClip; 
	
	iPlayer = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON);	 
	iClip = get_pdata_int(iEnt, m_iClip, XO_WEAPON);	
	
	if(!iClip) 
	{	
		emit_sound(iPlayer, CHAN_AUTO, szSoundEmpty, 0.8, ATTN_NORM, 0, PITCH_NORM);
		
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.2, XO_WEAPON);
		
		return HAM_SUPERCEDE;		
	}
	
	if(get_pdata_int(iEnt, m_iShotsFired, XO_WEAPON) && !iAutoShoot)
		return HAM_SUPERCEDE;
	
	switch(iWeaponType)
	{
		case WEAPONTYPE_ELITE:
		{
			if(get_pdata_int(iEnt, m_iWeaponState, XO_WEAPON) & WPNSTATE_ELITE_LEFT)
				PlayWeaponState(iPlayer, ELITE_SHOOTLEFT5);
		}	
		case WEAPONTYPE_GLOCK18:
		{
			if(get_pdata_int(iEnt, m_iWeaponState, XO_WEAPON) & WPNSTATE_GLOCK18_BURST_MODE)
				PlayWeaponState(iPlayer, GLOCK18_SHOOT2);	
		}
		case WEAPONTYPE_FAMAS:
		{
			if(get_pdata_int(iEnt, m_iWeaponState, XO_WEAPON) & WPNSTATE_FAMAS_BURST_MODE)
				PlayWeaponState(iPlayer, CLARION_SHOOT2);	
		}
		case WEAPONTYPE_M4A1:
		{
			if(get_pdata_int(iEnt, m_iWeaponState, XO_WEAPON) & WPNSTATE_M4A1_SILENCED)
				PlayWeaponState(iPlayer, M4A1_SHOOT3);	
		}
		case WEAPONTYPE_USP:
		{
			if(get_pdata_int(iEnt, m_iWeaponState, XO_WEAPON) & WPNSTATE_USP_SILENCED)
				PlayWeaponState(iPlayer, USP_SHOOT3);	
		}		
	}

	if(!(get_pdata_int(iEnt, m_iWeaponState, XO_WEAPON)))
		PlayWeaponState(iPlayer, iAnim);	
	
	EjectBrass(iPlayer, iEnt);
	
	return HAM_IGNORED;	
}

stock PlayWeaponState(iPlayer, iWeaponAnim)
{	
	SendWeaponAnim(iPlayer, iWeaponAnim, iBodyIndex[iPlayer][get_user_weapon(iPlayer)])	
}

public HamF_CS_Weapon_SendWeaponAnim_Post(iEnt, iAnim, Skiplocal)
{
	static iPlayer;
	iPlayer = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON);
	
	SendWeaponAnim(iPlayer, iAnim, iBodyIndex[iPlayer][cs_get_weapon_id(iEnt)]);
	return HAM_IGNORED
}

public checkSpectatingPlayers(iEnt)
{	
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.0001)

	static iPlayers[MAX_PLAYERS]
	new iNum
	get_players(iPlayers, iNum, "b")
	if(!iNum)
		return FMRES_IGNORED
		
	enum
	{
		SPEC_MODE,
		SPEC_TARGET,
		SPEC_END
	}; 
	
	static aSpecInfo[33][SPEC_END];
	static iSpecMode;
	static iTarget
	static iUserWeapon
	static iPlayer
	
	for(new i; i < iNum; i++)
	{
		iTarget = (iSpecMode = pev((iPlayer = iPlayers[i]), pev_iuser1)) ? pev(iPlayer, pev_iuser2) : iPlayer
		
		if(iSpecMode)
		{
			if(aSpecInfo[iPlayer][SPEC_MODE] != iSpecMode)
			{
				aSpecInfo[iPlayer][SPEC_MODE] = iSpecMode;
				aSpecInfo[iPlayer][SPEC_TARGET] = FALSE;
			}

			if(iSpecMode == OBS_IN_EYE && aSpecInfo[iPlayer][SPEC_TARGET] != iTarget)
			{
				aSpecInfo[iPlayer][SPEC_TARGET] = iTarget;

				screenFade(true, iPlayer)
				screenFade(false, iPlayer)
				
				if(!g_szUserModel[iTarget][(iUserWeapon = get_user_weapon(iTarget))][0])
					continue
				
				new iTaskData[2];
				iTaskData[0] = iBodyIndex[iTarget][iUserWeapon];
				iTaskData[1] = IDLE_ANIM;
				
				set_task(0.1, "SPEC_OBS_IN_EYE", iPlayer, iTaskData, sizeof(iTaskData))
			}
		}
	}
	return FMRES_IGNORED
}

screenFade(bool:bResetFade, iPlayer)
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), .player = iPlayer)
	if(bResetFade)
	{
		write_short(0)
		write_short(0)
		write_short(0)
	}
	else
	{
		write_short(4096)
		write_short(2048)
		write_short(2)
	}
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(bResetFade ? 0 : 255)
	message_end()
}

public FM_Hook_UpdateClientData_Post(iPlayer, SendWeapons, CD_Handle)
{			
	static iTarget
	if(!is_user_alive(iPlayer) && (pev(iPlayer, pev_iuser1) == OBS_IN_EYE))
	{
		iTarget = pev(iPlayer, pev_iuser2)
	}
	else iTarget = iPlayer
	
	if(!is_user_logged(iTarget))
		return FMRES_IGNORED
			
	if(!g_szUserModel[iTarget][get_user_weapon(iTarget)][0])
		return FMRES_IGNORED
			
	static iActiveItem
	iActiveItem = get_pdata_cbase(iTarget, m_pActiveItem, XO_PLAYER)
	if(pev_valid(iActiveItem))
	{
		if(get_pdata_int(iActiveItem, m_iId, XO_WEAPON))
		{
			if(!get_pdata_float(iActiveItem, m_flLastEventCheck, XO_WEAPON))
			{
				set_cd(CD_Handle, CD_flNextAttack, get_gametime() + 0.001)
				set_cd(CD_Handle, CD_WeaponAnim, IDLE_ANIM)
				return FMRES_HANDLED
			}
		}
	}
	return FMRES_IGNORED
}

public deagle_reload(weapon)
{
	static id; id = get_pdata_cbase(weapon, 41, 4);

	remove_task(id);

	if (!is_user_alive(id)) return;

	deagleDisable[id] = true;

	set_task(2.5, "deagle_enable", id);
}

public deagle_override(weapon)
{
	static id; id = get_pdata_cbase(weapon, 41, 4);

	remove_task(id);

	if (!is_user_alive(id)) return;

	deagleDisable[id] = true;

	set_task(0.8, "deagle_enable", id);
}

public deagle_enable(id)
	deagleDisable[id] = false;

public knife_override(weapon)
	set_pdata_float(weapon, 48, 0.8, 4);

public inspect_weapon(id)
{
	if (!is_user_alive(id) || cs_get_user_shield(id) || cs_get_user_zoom(id) > 1 || pev_valid(id) != PDATA_SAFE || csgo_is_using_default_skin(id)) 
		return PLUGIN_HANDLED;

	new weaponId = get_user_weapon(id);
	new weapon = get_pdata_cbase(id, m_pActiveItem, XO_PLAYER)
	if(weapon == NULLENT)
		return PLUGIN_HANDLED;

	if(pev_valid(weapon) != PDATA_SAFE || get_pdata_int(weapon, OFFSET_WEAPON_IN_RELOAD, XO_WEAPON) || weaponsWithoutInspect & (1<<weaponId))
		return PLUGIN_HANDLED
	
	if(differentWeapon(weaponId))
	{
		if((get_systime() - g_lasttime[id]) < 5.0)
			return PLUGIN_HANDLED;
		
		g_lasttime[id] = get_systime()
	}

	new animation = inspectAnimation[weaponId]//, currentAnimation = pev(get_pdata_cbase(weapon, 41, 4), pev_weaponanim);
	set_pdata_float(weapon, OFFSET_WEAPON_IDLE, 6.5, XO_WEAPON);
	switch (weaponId)
	{
		case CSW_M4A1:
		{
			if (!cs_get_weapon_silen(weapon)) animation = 15;

			//if (!currentAnimation || currentAnimation == 7 || currentAnimation == animation)
			SendWeaponAnim(id, animation, iBodyIndex[id][weaponId]);
		}
		case CSW_USP:
		{
			if (!cs_get_weapon_silen(weapon)) animation = 17;

			//if (!currentAnimation || currentAnimation == 8 || currentAnimation == animation)
			SendWeaponAnim(id, animation, iBodyIndex[id][weaponId]);
		}
		case CSW_DEAGLE:
		{
			//if (!deagleDisable[id])
			SendWeaponAnim(id, animation, iBodyIndex[id][weaponId]);
		}
		case CSW_GLOCK18:
		{
			//if (!currentAnimation || currentAnimation == 1 || currentAnimation == 2 || currentAnimation == 9 || currentAnimation == 10 || currentAnimation == animation)
			SendWeaponAnim(id, animation, iBodyIndex[id][weaponId]);
		} default: {
			//if (!currentAnimation || currentAnimation == animation)
			SendWeaponAnim(id, animation, iBodyIndex[id][weaponId]);
		}
	}

	return PLUGIN_HANDLED;
}

bool:differentWeapon(weaponId)
{
	return bool:((weaponId == CSW_GLOCK18) || (weaponId == CSW_P228) || (weaponId == CSW_FIVESEVEN))
}

public Forward_PlaybackEvent(iFlags, pPlayer, iEvent, Float:fDelay, Float:vecOrigin[3], Float:vecAngle[3], Float:flParam1, Float:flParam2, iParam1, iParam2, bParam1, bParam2)
{	
	static i, iCount, iSpectator, iszSpectators[32];

	get_players(iszSpectators, iCount, "bch");

	for(i = 0; i < iCount; i++)
	{
		iSpectator = iszSpectators[i];

		if(pev(iSpectator, pev_iuser1) != OBS_IN_EYE || pev(iSpectator, pev_iuser2) != pPlayer) 
			continue;
		
		return FMRES_SUPERCEDE;
	}		
	
	return FMRES_IGNORED;	
}

public Forward_ClientUserInfoChanged(iPlayer)
{
	static iUserInfo[6] = "cl_lw", iClientValue[2], iServerValue[2] = "1";
	
	if(CLIENT_DATA(iPlayer, iUserInfo, iClientValue))
	{
		HOOK_DATA(iPlayer, iUserInfo, iServerValue);
				
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public plugin_natives()
{
	register_native("cs_set_viewmodel_body", "ViewBodySwitch", TRUE);
	register_native("cs_set_modelformat", "changeModelFormat");
	register_native("cs_set_bodypart_animation", "setBodyPartAnimation");
}

public setBodyPartAnimation()
{
	new id = get_param(1)		
	SendWeaponAnim(id, get_param(3), iBodyIndex[id][get_param(2)])
}

public changeModelFormat()
{
	new id = get_param(1)
	if(!is_user_logged(id))
		return
		
	new szModelParam[64]
	get_string(3, szModelParam, charsmax(szModelParam))
	if(!szModelParam[0])
		return
		
	copy(g_szUserModel[id][get_param(2)], charsmax(g_szUserModel[][]), szModelParam)
		
	if(task_exists(id + TASK_DELAY))
	{
		remove_task(id + TASK_DELAY)
	}
	
	set_pev(id, pev_viewmodel2, "")
	set_task(0.1, "DeployWeaponSwitch", id + TASK_DELAY)
}

public ViewBodySwitch(iPlayer, iWeapon, iValue)
{	
	iBodyIndex[iPlayer][iWeapon] = iValue;
	if(iValue == -1)
	{
		g_szUserModel[iPlayer][iWeapon] = ""
	}
}

stock GetWeaponDrawAnim(iEntity)
{
	static DrawAnim, iWeaponState;
	
	if(get_pdata_int(iEntity, m_iWeaponState, XO_WEAPON) & WPNSTATE_USP_SILENCED || get_pdata_int(iEntity, m_iWeaponState, XO_WEAPON) & WPNSTATE_M4A1_SILENCED)
		iWeaponState = SILENCED
	else
		iWeaponState = UNSIL	
	
	switch(WEAPON_ENT(iEntity))
	{
		case CSW_P228, CSW_XM1014, CSW_M3: DrawAnim = 6;
		case CSW_SCOUT, CSW_SG550, CSW_M249, CSW_G3SG1: DrawAnim = 4;
		case CSW_MAC10, CSW_AUG, CSW_UMP45, CSW_GALIL, CSW_FAMAS, CSW_MP5NAVY, CSW_TMP, CSW_SG552, CSW_AK47, CSW_P90: DrawAnim = 2;
		case CSW_ELITE: DrawAnim = 15;
		case CSW_FIVESEVEN, CSW_AWP, CSW_DEAGLE: DrawAnim = 5;
		case CSW_USP:
		{
			switch(iWeaponState)
			{
				case SILENCED: DrawAnim = 6;
				case UNSIL: DrawAnim = 14;
			}
		}
		case CSW_M4A1:
		{
			switch(iWeaponState)
			{
				case SILENCED: DrawAnim = 5;
				case UNSIL: DrawAnim = 12;
			}
		}	
		case CSW_GLOCK18: DrawAnim = 8;
		case CSW_KNIFE, CSW_HEGRENADE, CSW_FLASHBANG, CSW_SMOKEGRENADE: DrawAnim = 3;
		case CSW_C4: DrawAnim = 1;	
	}
		
	return DrawAnim;
}

SendWeaponAnim(iPlayer, iAnim, iBody)
{
	set_pev(iPlayer, pev_weaponanim, iAnim);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, iPlayer);
	write_byte(iAnim);
	write_byte(iBody);
	message_end();
	
	for(new iSpectator = 1, iSpectating;iSpectator <= get_maxplayers();iSpectator++)
	{
		if(!is_user_connected(iSpectator))
			continue
			
		iSpectating = entity_get_int(iSpectator, EV_INT_iuser2)
		if(iSpectating != iPlayer)
			continue

		set_pev(iSpectator, pev_weaponanim, iAnim);

		message_begin(MSG_ONE, SVC_WEAPONANIM, _, iSpectator);
		write_byte(iAnim);
		write_byte(iBody);
		message_end();
	}	
}

stock EjectBrass(iPlayer, iEnt)
{
	static iShellRifle, iShellShotgun;
	
	if(!iShellRifle || !iShellShotgun)
	{
		iShellRifle = engfunc(EngFunc_PrecacheModel, SHELL_MODEL);
		iShellShotgun = engfunc(EngFunc_PrecacheModel, SHOTGUN_SHELL_MODEL);
	}	
	
	switch(WEAPON_ENT(iEnt))
	{
		case CSW_M3, CSW_XM1014: set_pdata_int(iEnt, m_iShellId, iShellShotgun, XO_WEAPON);
		case CSW_ELITE: return;
		default: set_pdata_int(iEnt, m_iShellId, iShellRifle, XO_WEAPON);	
	}
	
	if(get_pdata_int(iEnt, m_iWeaponState, XO_WEAPON) & WPNSTATE_FAMAS_BURST_MODE || get_pdata_int(iEnt, m_iWeaponState, XO_WEAPON) & WPNSTATE_GLOCK18_BURST_MODE)
		set_task(0.1, "EjectAdditionalBurstShell", iPlayer)
	
	set_pdata_float(iPlayer, m_flEjectBrass, get_gametime(), XO_PLAYER);	
}
	
public DeployWeaponSwitch(iPlayer)
{
	iPlayer -= TASK_DELAY
		
	new iWeaponInfo = get_user_weapon(iPlayer)
	if(!g_szUserModel[iPlayer][iWeaponInfo][0])
		return
		
	static iEnt		
	iEnt = get_pdata_cbase(iPlayer, m_pActiveItem, XO_PLAYER);
	
	if(!iEnt || !pev_valid(iEnt))
		return;	
	
	set_pev(iPlayer, pev_viewmodel2, g_szUserModel[iPlayer][iWeaponInfo]);
	// set_pdata_float(iEnt, m_flLastEventCheck, 0.0, XO_WEAPON)
	SendWeaponAnim(iPlayer, GetWeaponDrawAnim(iEnt), iBodyIndex[iPlayer][iWeaponInfo]);
}	
		
public SPEC_OBS_IN_EYE(iTaskData[], iPlayer)
{
	if(iTaskData[0] == -1)
		return
		
	SendWeaponAnim(iPlayer, iTaskData[1], iTaskData[0])
}

public EjectAdditionalBurstShell(iPlayer)
{
	set_pdata_float(iPlayer, m_flEjectBrass, get_gametime(), XO_PLAYER);
}