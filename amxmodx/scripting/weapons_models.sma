#include <amxmodx>
#include <fakemeta>
#include <reapi>

enum HOOKCHAINS
{
    HookChain:HC_SET_MODEL
}

enum _:FAKEMETA_HOOKS
{
	FM_SET_MODEL,
	PRECACHE_MODEL_PRE,
	PRECACHE_MODEL_POST
}

static const W_WEAPONS_MODEL[] = "models/w_weapons.mdl"

static const MODEL_TO_UNPRECACHE[][] = 
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
	"models/p_g3sg1.mdl",
	"models/w_g3sg1.mdl",
	"models/v_g3sg1.mdl",
	"models/p_m249.mdl",
	"models/w_m249.mdl",
	"models/v_m249.mdl",
	"models/p_sg550.mdl",
	"models/w_sg550.mdl",
	"models/v_sg550.mdl",
	"models/w_smokegrenade.mdl",
	"models/p_smokegrenade.mdl",
	"models/w_ak47.mdl",
	"models/w_aug.mdl",
	"models/w_awp.mdl",
	"models/w_deagle.mdl",
	"models/w_elite.mdl",
	"models/w_famas.mdl",
	"models/w_fiveseven.mdl",
	"models/w_galil.mdl",
	"models/w_glock18.mdl",
	"models/w_m3.mdl",
	"models/w_m4a1.mdl",
	"models/w_mac10.mdl",
	"models/w_mp5.mdl",
	"models/w_p90.mdl",
	"models/w_p228.mdl",
	"models/w_scout.mdl",
	"models/w_sg552.mdl",
	"models/w_tmp.mdl",
	"models/w_ump45.mdl",
	"models/w_usp.mdl",
	"models/w_xm1014.mdl"
}

static const W_MODEL_TO_REPLACE[][] =
{
	"models/w_awp.mdl",
	"models/w_galil.mdl",
	"models/w_famas.mdl",
	"models/w_ak47.mdl",
	"models/w_aug.mdl",
	"models/w_deagle.mdl",
	"models/w_elite.mdl",
	"models/w_fiveseven.mdl",
	"models/w_glock18.mdl",
	"models/w_m3.mdl",
	"models/w_m4a1.mdl",
	"models/w_mac10.mdl",
	"models/w_mp5.mdl",
	"models/w_p90.mdl",
	"models/w_p228.mdl",
	"models/w_scout.mdl",
	"models/w_sg552.mdl",
	"models/w_tmp.mdl",
	"models/w_ump45.mdl",
	"models/w_usp.mdl",
	"models/w_xm1014.mdl"
}
// TODO:
// - add
// hegrenade,
// smoke,
// flash,
// c4,
// sg550,
// m249,
// g3sg1,
// knife

new g_eHookChain[HOOKCHAINS]
new g_eFMHooks[FAKEMETA_HOOKS]

public plugin_init()
{
    register_plugin("Weapons Models", "0.1", "lexzor")

    if(!EnableHookChain((g_eHookChain[HC_SET_MODEL] = RegisterHookChain(RG_CWeaponBox_SetModel, "RG_SetModel_Pre"))))
    {
        set_fail_state("RG_SetModel_Pre failed")
    }

    g_eFMHooks[FM_SET_MODEL] = register_forward(FM_SetModel, "FM_SetModel_Pre");
    g_eFMHooks[PRECACHE_MODEL_PRE] = register_forward(FM_PrecacheModel, "FM_PrecacheModel_Pre") 
    g_eFMHooks[PRECACHE_MODEL_POST] = register_forward(FM_PrecacheModel, "FM_PrecacheModel_Post", _:true) 
}

public plugin_end()
{
	DisableHookChain(g_eHookChain[HC_SET_MODEL])

	unregister_forward(FM_SetModel, g_eFMHooks[FM_SET_MODEL])
	unregister_forward(FM_PrecacheModel, g_eFMHooks[PRECACHE_MODEL_PRE])
	unregister_forward(FM_PrecacheModel, g_eFMHooks[PRECACHE_MODEL_POST], _:true) 
}

public plugin_precache()
{
    if(file_exists(W_WEAPONS_MODEL))
    {
        precache_model(W_WEAPONS_MODEL)
    }
    else 
    {
        set_fail_state("Model %s does not exist", W_WEAPONS_MODEL)
    }
}

public FM_PrecacheModel_Pre(const szModel[]) 
{ 
	for(new i; i < sizeof(MODEL_TO_UNPRECACHE); i++) 
	{ 
		if(equal(szModel, MODEL_TO_UNPRECACHE[i])) 
        {
			return FMRES_SUPERCEDE 
        }
    }

	return FMRES_IGNORED 
}

public FM_PrecacheModel_Post(const szModel[])
{
	for(new i ; i < sizeof(MODEL_TO_UNPRECACHE); i++) 
	{ 
		if(equal(szModel, MODEL_TO_UNPRECACHE[i]))
		{
			return FMRES_IGNORED 
		}
	} 

	return FMRES_IGNORED 
}

public FM_SetModel_Pre(const iWeaponEnt, const szModel[]) 
{        
    for(new i; i < sizeof(W_MODEL_TO_REPLACE); i++)
    {
        if(equal(szModel, W_MODEL_TO_REPLACE[i]))
        {
            return FMRES_SUPERCEDE
        }
    }

    return FMRES_IGNORED
} 

public RG_SetModel_Pre(const iWeaponEnt, const szModel[])
{
    new iBodyIndex = -1

    for(new i; i < sizeof(W_MODEL_TO_REPLACE); i++)
    {
        if(equal(szModel, W_MODEL_TO_REPLACE[i]))
        {
            iBodyIndex = i
            break
        }
    }

    if(iBodyIndex == -1)
    {
        return HC_CONTINUE
    }

    SetHookChainArg(2, ATYPE_STRING, W_WEAPONS_MODEL)
    set_entvar(iWeaponEnt, var_body, iBodyIndex)
    
    return HC_CONTINUE
}