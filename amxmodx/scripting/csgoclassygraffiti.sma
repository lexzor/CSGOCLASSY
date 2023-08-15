#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <unixtime>
#include <csgoclassy>

#pragma compress 1

#define is_player(%1)	(1 <= %1 <= max_players)
#define GRAFFITI_SOUND "csgoclassy/graffiti.wav"
#define GRAFFITI_MODEL "sprites/csgoclassy/csgoclassy_graffiti.spr"
#define Grafiti_Max_Colour_Client 12
#define Grafiti_Max_Seymbol_Client 38
#define Field_Control_Constant 50.0
new Bot_Player[33]
new Graffiti_Drawing_Second[33]
new Graffiti_Symbol[33]
new Second
new cvar_graffiti_reload_time
new cvar_graffiti_visibility_time
new cvar_graffiti_fade_away_time
new cvar_graffiti_distance

public plugin_init() 
{
	register_plugin("CSGO Classy graffiti", "1.0", "renegade")

	cvar_graffiti_reload_time = register_cvar("graffiti_reload","30")
	cvar_graffiti_visibility_time = register_cvar("graffiti_visible","25")
	cvar_graffiti_fade_away_time = register_cvar("graffiti_fade","30")
	cvar_graffiti_distance = register_cvar("graffiti_distance","120.0")

	register_dictionary("csgoclassy.txt")
	Start_Second_Increase()
	register_cvar("csgo_classy_vip_version", "1.1", 68, 0.00);
	set_cvar_string("csgo_classy_vip_version", "1.1");
	register_cvar("csgo_classy_graffiti_author", "renegade", 68, 0.00);
	set_cvar_string("csgo_classy_graffiti_author", "renegade");
}

public Create_Graffiti(id, Float:Origin[3], Float:Angles[3], Float:vNormal[3])
{
	Graffiti_Drawing_Second[id] = Second
	new MODEL_ent = create_entity("env_sprite")
	if (is_valid_ent(MODEL_ent))
	{
		Origin[0] += (vNormal[0] * 0.5)
		Origin[1] += (vNormal[1] * 0.5)
		Origin[2] += (vNormal[2] * 0.5)
		entity_set_string(MODEL_ent, EV_SZ_classname, "csgoclassygraffiti" )
		entity_set_model(MODEL_ent, GRAFFITI_MODEL)
		entity_set_vector(MODEL_ent, EV_VEC_angles, Angles)
		set_pev( MODEL_ent, pev_rendermode, kRenderTransAlpha)
		new Seymbol
		if(Graffiti_Symbol[id] > Grafiti_Max_Seymbol_Client - 1)
		{
			Seymbol = random_num(0,Grafiti_Max_Seymbol_Client - 1)
		}
		else
		{
			Seymbol = Graffiti_Symbol[id]
		}
		entity_set_float(MODEL_ent, EV_FL_frame, float(Seymbol))
		if (Seymbol == 0) 
		{
			entity_set_float(MODEL_ent, EV_FL_scale, 0.13)
		}
		else
		{
			entity_set_float(MODEL_ent, EV_FL_scale, 0.25)
		}
		set_pev( MODEL_ent, pev_renderamt, 255.0)
		entity_set_origin(MODEL_ent, Origin);
		emit_sound(MODEL_ent, CHAN_ITEM, GRAFFITI_SOUND, 0.70, ATTN_NORM, 0, PITCH_NORM)
		set_task(get_pcvar_float(cvar_graffiti_visibility_time),"Remove_Graffiti",MODEL_ent)
	}
	return PLUGIN_CONTINUE
}

public overflow_graffiti_detect(Float:i_Origin[3], Float:i_Angles[3], Float:vNormal[3])
{
	new Float:Origin[3]
	new Float:Angles[3]
	Angles[0] = i_Angles[0]
	Origin[0] = i_Origin[0] + (vNormal[0] * 0.5)
	Origin[1] = i_Origin[1] + (vNormal[1] * 0.5)
	Origin[2] = i_Origin[2] + (vNormal[2] * 0.5)
	Origin[0] = i_Origin[0] + floatcos(i_Angles[1] , degrees ) * 5.0
	Origin[1] = i_Origin[1] + floatsin(i_Angles[1] , degrees ) * 5.0
	Origin[2] = i_Origin[2] + floatsin(i_Angles[2] , degrees ) * 5.0 * floatpower(2.0,0.5)
	new Status
	Angles[1] = i_Angles[1] + 270.0
	Angles[2] = i_Angles[2] + 45.0
	Status += Spawn_in_wall_detect(Origin,Angles)
	Angles[2] -= 90.0
	Status += Spawn_in_wall_detect(Origin,Angles)
	Angles[1] += 180.0
	Status += Spawn_in_wall_detect(Origin,Angles)
	Angles[2] += 90.0
	Status += Spawn_in_wall_detect(Origin,Angles)
	if(Status != 4)
	{
		return false
	}
	return true
}

public Spawn_in_wall_detect(Float:Origin[3],Float:Angles[3])
{
	new Float:New_Origin[3]
	New_Origin[0] = Origin[0] + floatcos(Angles[1] , degrees ) * Field_Control_Constant / 2.0
	New_Origin[1] = Origin[1] + floatsin(Angles[1] , degrees ) * Field_Control_Constant / 2.0
	New_Origin[2] = Origin[2] + floatsin(Angles[2] , degrees ) * Field_Control_Constant * floatpower(2.0,0.5) / 2.0
	if(engfunc(EngFunc_PointContents, New_Origin) == CONTENTS_EMPTY)
	{
		return false
	}
	return true
}

public plugin_precache()
{
	precache_model(GRAFFITI_MODEL)
	precache_sound(GRAFFITI_SOUND)
}

public client_putinserver(id)
{
	Graffiti_Drawing_Second[id] = Second - get_pcvar_num(cvar_graffiti_reload_time)
	Graffiti_Symbol[id] = Grafiti_Max_Seymbol_Client
	Bot_Player[id] = is_user_bot(id)
}

public Drawing_Graffiti(id)
{
	new Center_Origin[3]
	new Float:vCenter_Origin[3]
	new Float:Angles[3]
	new Float:vNormal[3]
	get_user_origin(id, Center_Origin, 3)
	IVecFVec(Center_Origin, vCenter_Origin)
	new Float:vPlayerCenter_Origin[3]
	new Float:vViewOfs[3]
	entity_get_vector(id, EV_VEC_origin, vPlayerCenter_Origin)
	entity_get_vector(id, EV_VEC_view_ofs, vViewOfs)
	vPlayerCenter_Origin[0] += vViewOfs[0]
	vPlayerCenter_Origin[1] += vViewOfs[1]
	vPlayerCenter_Origin[2] += vViewOfs[2]
	new Float:Player_Aim[3]
	entity_get_vector(id, EV_VEC_v_angle, Angles)
	Player_Aim[0] = vPlayerCenter_Origin[0] + floatcos(Angles[1], degrees ) * get_pcvar_float(cvar_graffiti_distance)
	Player_Aim[1] = vPlayerCenter_Origin[1] + floatsin(Angles[1], degrees) * get_pcvar_float(cvar_graffiti_distance)
	Player_Aim[2] = vPlayerCenter_Origin[2] + floatsin(-Angles[0], degrees) * get_pcvar_float(cvar_graffiti_distance)
	new Intersection_Status = trace_normal(id, vPlayerCenter_Origin, Player_Aim, vNormal)
	vector_to_angle(vNormal, Angles)
	Angles[1] += 180.0
	if(Graffiti_Drawing_Second[id] + get_pcvar_num(cvar_graffiti_reload_time) > Second)
	{
		return PLUGIN_HANDLED
	}
	if(!Intersection_Status)
	{
		return PLUGIN_HANDLED
	}
	if(vNormal[2] != 0.0)
	{
		return PLUGIN_HANDLED
	}
	if(!overflow_graffiti_detect(vCenter_Origin, Angles, vNormal))
	{
		return PLUGIN_HANDLED
	}
	Create_Graffiti(id, vCenter_Origin, Angles, vNormal)
	return PLUGIN_CONTINUE
}

public Remove_Graffiti(ent)
{
	if(pev_valid(ent)) 
	{
		new Float:Transparency
		pev( ent, pev_renderamt, Transparency)
		Transparency -= 2.5
		if ( Transparency <= 2.5 )
		{
			remove_entity(ent)
		}
		else
		{
			set_pev(ent, pev_renderamt, Transparency)
			set_task(get_pcvar_float(cvar_graffiti_fade_away_time)/102.0, "Remove_Graffiti", ent)
		}
	}
}

public Start_Second_Increase()
{
	Second++
	set_task(1.0,"Start_Second_Increase")
}

public client_impulse(id, impulse)
{
	if(impulse == 201)
		if(is_user_alive(id))
		{
		Drawing_Graffiti(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}