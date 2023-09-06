#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>


#define PLUGIN "[CSGO Classy] Unprecacher Lite"
#define VERSION "0.1"
#define AUTHOR "lexzor"

#pragma compress 1


new Array:ArModel, Array:ArSound
new GTempData[64]

new const UnPrecache_ModelList[][] = 
{ 
	"models/w_antidote.mdl",
	"models/w_security.mdl",
	"models/w_longjump.mdl",
	"models/w_battery.mdl",
	"models/p_shield.mdl",
	"models/w_shield.mdl",
	"models/shield/p_shield_deagle.mdl", 
	"models/shield/p_shield_fiveseven.mdl", 
	"models/shield/p_shield_flashbang.mdl", 
	"models/shield/p_shield_glock18.mdl", 
	"models/shield/p_shield_hegrenade.mdl", 
	"models/shield/p_shield_knife.mdl", 
	"models/shield/p_shield_p228.mdl", 
	"models/shield/p_shield_smokegrenade.mdl", 
	"models/shield/p_shield_usp.mdl",
	"models/shield/v_shield_deagle.mdl", 
	"models/shield/v_shield_fiveseven.mdl", 
	"models/shield/v_shield_flashbang.mdl", 
	"models/shield/v_shield_glock18.mdl", 
	"models/shield/v_shield_hegrenade.mdl", 
	"models/shield/v_shield_knife.mdl", 
	"models/shield/v_shield_p228.mdl", 
	"models/shield/v_shield_smokegrenade.mdl", 
	"models/shield/v_shield_usp.mdl",
	"models/w_smokegrenade.mdl",
	"models/p_smokegrenade.mdl",
}
new const UnPrecache_SoundList[][] =
{
	"items/suitcharge1.wav",
	"items/suitchargeno1.wav",
	"items/suitchargeok1.wav",
	"common/wpn_hudoff.wav",
	"common/wpn_hudon.wav",
	"common/wpn_moveselect.wav",
	"player/geiger6.wav",
	"player/geiger5.wav",
	"player/geiger4.wav",
	"player/geiger3.wav",
	"player/geiger2.wav",
	"player/geiger1.wav  ",
	"sprites/zerogxplode.spr",
	"sprites/WXplo1.spr",
	"sprites/steam1.spr",
	"sprites/bubble.spr",
	"sprites/bloodspray.spr",
	"sprites/blood.spr",
	"sprites/smokepuff.spr",
	"sprites/eexplo.spr",
	"sprites/fexplo.spr",
	"sprites/fexplo1.spr",
	"sprites/b-tele1.spr",
	"sprites/c-tele1.spr",
	"sprites/ledglow.spr",
	"sprites/laserdot.spr",
	"sprites/explode1.spr",
	"weapons/bullet_hit1.wav",
	"weapons/bullet_hit2.wav",
	"items/weapondrop1.wav",
	"weapons/generic_reload.wav",
	"sprites/smoke.spr",
	"buttons/latchunlocked2.wav",
	"buttons/lightswitch2.wav",
	"ambience/quail1.wav",
	"events/tutor_msg.wav",
	"events/enemy_died.wav",
	"events/friend_died.wav",
	"events/task_complete.wav"
}

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	ArModel = ArrayCreate(128)
	ArSound = ArrayCreate(128)

	register_forward( FM_PrecacheModel, "fw_PrecacheModel" ) 
	register_forward( FM_PrecacheSound, "fw_PrecacheSound" ) 
	register_forward( FM_PrecacheModel, "fw_PrecacheModel_Post", 1 ) 
	register_forward( FM_PrecacheSound, "fw_PrecacheSound_Post", 1 ) 
}


public fw_PrecacheModel( const Model[ ] ) 
{ 
	for( new i = 0; i < sizeof( UnPrecache_ModelList ); i++ ) 
	{ 
		if( equal( Model, UnPrecache_ModelList[ i ] ) ) 
			return FMRES_SUPERCEDE 
	} 
	return FMRES_IGNORED 
}

public fw_PrecacheModel_Post( const Model[ ] )
{
	for( new i = 0; i < sizeof( UnPrecache_ModelList ); i++ ) 
	{ 
		if( equal( Model, UnPrecache_ModelList[ i ] ) ) 
			return FMRES_IGNORED 
	} 
	
	new Precached = 0 
	
	for( new i = 0; i < ArraySize( ArModel ); i++ ) 
	{ 
		ArrayGetString( ArModel, i, GTempData, sizeof( GTempData ) ) 
		if( equal( GTempData, Model ) ) { Precached = 1; break; } 
	} 
	
	if( !Precached ) ArrayPushString( ArModel, Model ) 
	return FMRES_IGNORED 
}

public fw_PrecacheSound( const Sound[ ] )
{
	if( Sound[ 0 ] == 'h' && Sound[1] == 'o' ) 
	{
		return FMRES_SUPERCEDE 
	}
	
	for( new i = 0; i < sizeof(UnPrecache_SoundList); i++ )
	{ 
		if( equal( Sound, UnPrecache_SoundList[ i ] ) ) 
		{
			return FMRES_SUPERCEDE 
		}
	} 
	 
	return FMRES_HANDLED 
} 

public fw_PrecacheSound_Post( const Sound[ ] ) 
{
	if( Sound[ 0 ] == 'h' && Sound[1] == 'o' ) 
	{
		return FMRES_SUPERCEDE 
	}

	for( new i = 0; i < sizeof( UnPrecache_SoundList ); i++ ) 
	{
		if( equal( Sound, UnPrecache_SoundList[ i ] ) ) 
		{
			return FMRES_SUPERCEDE 
		}
	} 
	
	new Precached = 0 
	
	for( new i = 0; i < ArraySize( ArSound ); i++ ) 
	{ 
		ArrayGetString( ArSound, i, GTempData, sizeof( GTempData ) ) 
		if( equal( GTempData, Sound ) ) { Precached = 1; break; } 
	} 
	
	static Line 
	
	if( !Precached ) 
	{ 
		ArrayPushString( ArSound, Sound )
		Line++ 
	} 
	
	return FMRES_HANDLED 
}