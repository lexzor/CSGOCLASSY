#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <nvault>

static const NO_AMBIENCE_MAPS[][] =
{
    "de_dust2_winter16",
    "de_dust2_winter"
}

static const VAULT_KEY[] = "ambience"

new g_iVault

public plugin_init()
{
    register_plugin("Christmas Ambience", "0.1", "lexzor")

    new szMapName[32]; get_mapname(szMapName, charsmax(szMapName))

    for(new i; i < sizeof(NO_AMBIENCE_MAPS); i++)
    {
        if(equali(NO_AMBIENCE_MAPS[i], szMapName))
        {
            RegisterHam(Ham_Spawn, "ambient_generic", "Ambient_Generic_Spawn_Pre");
            break
        }
    }

    g_iVault = nvault_open("ambience_settings")

    register_clcmd("amx_lights", "lightCmd", ADMIN_IMMUNITY, "Changing server lights")

    if(g_iVault == INVALID_HANDLE)
    {
        log_amx("Couldn't open vault ambience_settings")
    }

    new szLight[8], iTs
    
    if(nvault_lookup(g_iVault, VAULT_KEY, szLight, charsmax(szLight), iTs))    
    {
        set_lights(szLight)
    }

    set_task(125.0, "hudInfo", .flags = "b")

    server_cmd("sv_skyname night");
}

public plugin_precache()
{
    new iEnt = create_entity("env_snow")

    if(!iEnt)
    {
        log_amx("Couldn't create snow entity")
    }

    iEnt = create_entity("env_fog")

    if(iEnt)
    {
        fm_set_kvd(iEnt, "density", "0.00040", "env_fog")
        fm_set_kvd(iEnt, "rendercolor", "0 170 204", "env_fog")
    }
    else 
    {
        log_amx("Couldn't create fog entity")
    }
}

public Ambient_Generic_Spawn_Pre(iEnt)
{
    set_pev(iEnt, pev_message, 0);
    return HAM_HANDLED;
} 

public lightCmd(id, level, cid)
{
    if(!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED;

    new szLight[2]
    read_argv(1, szLight, charsmax(szLight))

    if(szLight[0] < 'a' || szLight[0] > 'z')
    {
        client_print(id, print_console, "Invalid light code [a-z]")
        return PLUGIN_HANDLED;
    }

    set_lights(szLight)

    if(g_iVault != INVALID_HANDLE)
    {
        nvault_set(g_iVault, VAULT_KEY, szLight)
    }

    return PLUGIN_HANDLED;
}

public hudInfo()
{
    new iPlayers[MAX_PLAYERS], iNum
    get_players(iPlayers, iNum)

    for(new i, iPlayer; i < iNum; i++)
    {
        iPlayer = iPlayers[i]

        if(is_user_connected(iPlayer))
        {
            set_hudmessage(42, 255, 85, 0.05, 0.22, 0, 6.0, 12.0)
            show_hudmessage(iPlayer, "Console commands to:^n-Disable fog: gl_fog 0^n-Disable snow: cl_weather 0")
        }
    }
}

stock fm_set_kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}