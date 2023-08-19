#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <xs>
#include <updater>
#include <unixtime>
#include <csgoclassy>

#define PLUGIN "CSGO Classy Weapon sounds"
#define VERSION "1.0"
#define AUTHOR "renegade"

#pragma compress 1

#define TASK_PLAYSOUND		31321
#define m_pActiveItem 		373
#define m_iId			43
#define m_pPlayer		41
#define RIGHT_PISTOL 		8
#define LEFT_PISTOL 		6
#define XTRA_OFS_PLAYER 	5
#define XTRA_OFS_WEAPON		4
#define OFFSET_WEAPONSTATE	74
#define WPNSTATE_USP_SILENCED 			(1<<0)
#define WPNSTATE_M4A1_SILENCED 			(1<<2)

enum wWeaponData
{
	szWeaponName[20],
	szFireSound[64],
	iAnimation
}

new const AllWeapons[][wWeaponData] = 
{
	{"", "", ""},
	{"weapon_p228", "weapons/csgo/wp_fire/p250_fire.wav", 2},
	{"", "", ""},
	{"weapon_scout", "weapons/csgo/wp_fire/scout_fire.wav", 1},
	{"", "", ""},
	{"weapon_xm1014", "weapons/csgo/wp_fire/xm1014_fire.wav", 2},
	{"", "", ""},
	{"weapon_mac10", "weapons/csgo/wp_fire/mac10_fire.wav", 3},
	{"weapon_aug", "weapons/csgo/wp_fire/aug_fire.wav", 3},
	{"", "", ""},
	{"weapon_elite", "weapons/csgo/wp_fire/elite_fire.wav", 0},
	{"weapon_fiveseven", "weapons/csgo/wp_fire/fiveseven_fire.wav", 1},
	{"weapon_ump45", "weapons/csgo/wp_fire/ump45_fire.wav", 4},
	{"weapon_sg550", "weapons/csgo/wp_fire/sg550_fire.wav", 1},
	{"weapon_galil", "weapons/csgo/wp_fire/galil_fire.wav", 4},
	{"weapon_famas", "weapons/csgo/wp_fire/famas_fire.wav", 4},
	{"weapon_usp", "weapons/csgo/wp_fire/usps_fire.wav", 3},
	{"weapon_glock18", "weapons/csgo/wp_fire/glock18_fire.wav", 4},
	{"weapon_awp", "weapons/csgo/wp_fire/awp_fire.wav", 2},
	{"weapon_mp5navy", "weapons/csgo/wp_fire/mp7_fire.wav", 3},
	{"weapon_m249", "weapons/csgo/wp_fire/m249_fire.wav", 2},
	{"weapon_m3", "weapons/csgo/wp_fire/nova_fire.wav", 2},
	{"weapon_m4a1", "weapons/csgo/wp_fire/m4a1_fire.wav", 3},
	{"weapon_tmp", "weapons/csgo/wp_fire/mp9_fire.wav", 4},
	{"weapon_g3sg1", "weapons/csgo/wp_fire/g3sg1_fire.wav", 1},
	{"", "", ""},
	{"weapon_deagle", "weapons/csgo/wp_fire/deagle_fire.wav", 2},
	{"weapon_sg552", "weapons/csgo/wp_fire/sg552_fire.wav", 4},
	{"weapon_ak47", "weapons/csgo/wp_fire/ak_fire.wav", 3},
	{"", "", ""},
	{"weapon_p90", "weapons/csgo/wp_fire/p90_fire.wav", 3}
}

new const g_szM4A1FireSoundNoSilencer[] = "weapons/csgo/wp_fire/m4a4_fire.wav"
new const g_szUSPFireSoundNoSilencer[] = "weapons/csgo/wp_fire/uspsno_fire.wav"
new const g_szBurstSound[] = "weapons/csgo/wp_fire/burst.wav"
new const g_szPlantingSound[] = "weapons/csgo/wp_fire/c4_initiate.wav"

new g_iShellModel, g_iSmokeSprite
native is_using_m4a4(id);
public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHam(Ham_TraceAttack, "worldspawn", "Fw_TraceAttack_World")
	RegisterHam(Ham_TraceAttack, "func_breakable", "Fw_TraceAttack_World")
	RegisterHam(Ham_TraceAttack, "func_wall", "Fw_TraceAttack_World")
	RegisterHam(Ham_TraceAttack, "func_door", "Fw_TraceAttack_World")
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "Fw_TraceAttack_World")
	RegisterHam(Ham_TraceAttack, "func_plat", "Fw_TraceAttack_World")
	RegisterHam(Ham_TraceAttack, "func_rotating", "Fw_TraceAttack_World")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_famas", "CBaseWeapon__SecondaryAttack_Pre")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_glock18", "CBaseWeapon__SecondaryAttack_Pre")
	
	register_forward(FM_UpdateClientData, "Fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
}


public plugin_precache()
{
	g_iShellModel = engfunc(EngFunc_PrecacheModel, "models/rshell.mdl")
	g_iSmokeSprite = engfunc(EngFunc_PrecacheModel, "sprites/csgoclassy/csgoclassygun.spr")

	for(new i;i < sizeof AllWeapons;i++)
	{
		if(!AllWeapons[i][szFireSound][0])
			continue

		engfunc(EngFunc_PrecacheSound, AllWeapons[i][szFireSound])
	}

	precache_sound(g_szM4A1FireSoundNoSilencer)
	precache_sound(g_szUSPFireSoundNoSilencer)
	precache_sound(g_szBurstSound)
	precache_sound(g_szPlantingSound)
}

public bomb_planting(id)
{
	emit_sound(id, CHAN_BODY, g_szPlantingSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public CBaseWeapon__SecondaryAttack_Pre(const iWeapon)
{
	static id; id = get_pdata_cbase(iWeapon, m_pPlayer, XTRA_OFS_WEAPON)
	if(is_user_connected(id))
	{
		emit_sound(id, CHAN_WEAPON, g_szBurstSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	return HAM_IGNORED
}

public Fw_TraceAttack_World(victim, attacker, Float:damage, Float:direction[3], prt, damage_bits)
{
	if(!is_user_connected(attacker))
		return HAM_IGNORED
		
	if(get_user_weapon(attacker) == CSW_KNIFE)
		return HAM_IGNORED
		
	static Float:origin[3], Float:vecPlane[3]
	get_tr2(prt, TR_vecEndPos, origin)
	get_tr2(prt, TR_vecPlaneNormal, vecPlane)
	
	makeBulletSmoke(attacker, prt)
	return HAM_IGNORED
}



public Fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED

	set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, id, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if(!is_user_connected(id))
		return FMRES_IGNORED;
	
	static iUserWeapon, iWeaponID;
	iUserWeapon = get_user_weapon(id);
	iWeaponID = get_pdata_cbase(id, m_pActiveItem, XTRA_OFS_PLAYER)

	if(!AllWeapons[iUserWeapon][szFireSound][0])
	{
		return FMRES_IGNORED
	}
	if(iUserWeapon == CSW_M4A1)
	{
		if(is_using_m4a4(id))
		{
			emit_sound(id, CHAN_WEAPON, g_szM4A1FireSoundNoSilencer, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		else {
			if(get_pdata_int(iWeaponID, OFFSET_WEAPONSTATE, XTRA_OFS_WEAPON) & WPNSTATE_M4A1_SILENCED)
				emit_sound(id, CHAN_WEAPON, AllWeapons[iUserWeapon][szFireSound], VOL_NORM, ATTN_NORM, 0, PITCH_NORM); 
			else emit_sound(id, CHAN_WEAPON, g_szM4A1FireSoundNoSilencer, VOL_NORM, ATTN_NORM, 0, PITCH_NORM); 
		}
	}
	else if (iUserWeapon == CSW_USP)
	{
		if(!(get_pdata_int(iWeaponID, OFFSET_WEAPONSTATE, XTRA_OFS_WEAPON) & WPNSTATE_USP_SILENCED))
			emit_sound(id, CHAN_WEAPON, g_szUSPFireSoundNoSilencer, VOL_NORM, ATTN_NORM, 0, PITCH_NORM); 
		else emit_sound(id, CHAN_WEAPON, AllWeapons[iUserWeapon][szFireSound], VOL_NORM, ATTN_NORM, 0, PITCH_NORM); 

	}
	else emit_sound(id, CHAN_WEAPON, AllWeapons[iUserWeapon][szFireSound], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, id, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	makeShells(id)
	return FMRES_SUPERCEDE
}

makeShells(id)
{
	static Float:player_origin[3], Float:origin[3], Float:origin2[3], Float:gunorigin[3], Float:oldangles[3], Float:v_forward[3], Float:v_forward2[3], Float:v_up[3], Float:v_up2[3], Float:v_right[3], Float:v_right2[3], Float:viewoffsets[3];
	
	pev(id,pev_v_angle, oldangles); pev(id,pev_origin,player_origin); pev(id, pev_view_ofs, viewoffsets);

	engfunc(EngFunc_MakeVectors, oldangles)
	
	global_get(glb_v_forward, v_forward); global_get(glb_v_up, v_up); global_get(glb_v_right, v_right);
	global_get(glb_v_forward, v_forward2); global_get(glb_v_up, v_up2); global_get(glb_v_right, v_right2);
	
	xs_vec_add(player_origin, viewoffsets, gunorigin);
	
	xs_vec_mul_scalar(v_forward, 10.3, v_forward); xs_vec_mul_scalar(v_right, 2.9, v_right);
	xs_vec_mul_scalar(v_up, -3.7, v_up);
	xs_vec_mul_scalar(v_forward2, 10.0, v_forward2); xs_vec_mul_scalar(v_right2, 3.0, v_right2);
	xs_vec_mul_scalar(v_up2, -4.0, v_up2);
	
	xs_vec_add(gunorigin, v_forward, origin);
	xs_vec_add(gunorigin, v_forward2, origin2);
	xs_vec_add(origin, v_right, origin);
	xs_vec_add(origin2, v_right2, origin2);
	xs_vec_add(origin, v_up, origin);
	xs_vec_add(origin2, v_up2, origin2);

	static Float:velocity[3]
	getSpeedVector(origin2, origin, random_float(140.0, 160.0), velocity)

	static angle; angle = random_num(0, 360)

	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
	write_byte(TE_MODEL)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord,origin[1])
	engfunc(EngFunc_WriteCoord,origin[2])
	engfunc(EngFunc_WriteCoord,velocity[0])
	engfunc(EngFunc_WriteCoord,velocity[1])
	engfunc(EngFunc_WriteCoord,velocity[2])
	write_angle(angle)
	write_short(g_iShellModel)
	write_byte(1)
	write_byte(20)
	message_end()
}

getSpeedVector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

makeBulletSmoke(id, TrResult)
{
	static Float:vecSrc[3], Float:vecEnd[3], TE_FLAG;
	
	getWeaponAttachment(id, vecSrc);
	global_get(glb_v_forward, vecEnd);
    
	xs_vec_mul_scalar(vecEnd, 8192.0, vecEnd);
	xs_vec_add(vecSrc, vecEnd, vecEnd);

	get_tr2(TrResult, TR_vecEndPos, vecSrc);
	get_tr2(TrResult, TR_vecPlaneNormal, vecEnd);
    
	xs_vec_mul_scalar(vecEnd, 2.5, vecEnd);
	xs_vec_add(vecSrc, vecEnd, vecEnd);
    
	TE_FLAG |= TE_EXPLFLAG_NODLIGHTS;
	TE_FLAG |= TE_EXPLFLAG_NOSOUND;
	TE_FLAG |= TE_EXPLFLAG_NOPARTICLES;
	
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecEnd[0]);
	engfunc(EngFunc_WriteCoord, vecEnd[1]);
	engfunc(EngFunc_WriteCoord, vecEnd[2] - 10.0);
	write_short(g_iSmokeSprite);
	write_byte(5);
	write_byte(50);
	write_byte(TE_FLAG);
	message_end();
}

getWeaponAttachment(id, Float:output[3], Float:fDis = 40.0)
{ 
	static Float:vfEnd[3], viEnd[3] ;
	get_user_origin(id, viEnd, 3);
	IVecFVec(viEnd, vfEnd);
	
	static Float:fOrigin[3], Float:fAngle[3];
	
	pev(id, pev_origin, fOrigin);
	pev(id, pev_view_ofs, fAngle);
	
	xs_vec_add(fOrigin, fAngle, fOrigin);
	
	static Float:fAttack[3];
	
	xs_vec_sub(vfEnd, fOrigin, fAttack);
	xs_vec_sub(vfEnd, fOrigin, fAttack);
	
	static Float:fRate;
	
	fRate = fDis / vector_length(fAttack);
	xs_vec_mul_scalar(fAttack, fRate, fAttack);
	
	xs_vec_add(fOrigin, fAttack, output);
}
