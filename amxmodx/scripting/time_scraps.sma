#include <amxmodx>
#include <nvault>
#include <csgoclassy>
#include <reapi>

static const TASK_ADD_TIME = 143

enum _:USER_DATA
{
    TIME,
    TOTAL_BONUS
}

new CHAT_TAG[32]

static const VAULT_NAME[] = "csgoclassy_scraps_bonus"
new g_iVault

new g_CvarTime, g_CvarAmount

new g_eUserData[MAX_PLAYERS + 1][USER_DATA]

public plugin_init()
{
    register_plugin("[CSGO Classy] Scraps Bonus", "0.1", "lexzor")

    g_iVault = nvault_open(VAULT_NAME)

    if(g_iVault == INVALID_HANDLE)
    {
        set_fail_state("Vault %s failed to open", VAULT_NAME)
    }

    register_clcmd("say /scraps", "scrapsCommand")
    register_clcmd("say_team /scraps", "scrapsCommand")

    bind_pcvar_num(
        create_cvar(
            "time_bonus_min",
            "60",
            FCVAR_NONE,
            "Time in minutes when a player should get his bonus",
            true,
            1.0 
        ),
        g_CvarTime
    )

    bind_pcvar_num(
        create_cvar(
            "time_bonus_amount",
            "30",
            FCVAR_NONE,
            "Amount of bonus",
            true,
            1.0 
        ),
        g_CvarAmount
    )

    csgo_get_prefixes(CHAT_TAG, charsmax(CHAT_TAG))
}

public user_log_in_post(const id)
{
    g_eUserData[id][TOTAL_BONUS] = 0
    g_eUserData[id][TIME] = 0

    new szName[MAX_NAME_LENGTH], szData[32], iTs
    get_user_name(id, szName, charsmax(szName))

    if(nvault_lookup(g_iVault, szName, szData, charsmax(szData), iTs))
    {
        new szTotalBonus[16], szTotalTime[16]
        parse(szData, szTotalBonus, charsmax(szTotalBonus), szTotalTime, charsmax(szTotalTime))

        g_eUserData[id][TOTAL_BONUS] = str_to_num(szTotalBonus)
        g_eUserData[id][TIME] = str_to_num(szTotalTime)
    }

    set_task(1.0, "addTime", id + TASK_ADD_TIME, .flags = "b")
}

public client_disconnected(id)
{
    if(!is_user_logged(id))
    {
        return
    }

    new szName[MAX_NAME_LENGTH]
    get_user_name(id, szName, charsmax(szName))

    remove_task(id + TASK_ADD_TIME)

    nvault_set(g_iVault, szName, fmt("%d %d", g_eUserData[id][TOTAL_BONUS], g_eUserData[id][TIME]))

    return
}

public scrapsCommand(const id)
{
    new iMin = g_eUserData[id][TIME] / 60
    new iSec = g_eUserData[id][TIME] % 60

    client_print_color(id, print_team_default, "%s You completed this task^3 %i^4 time%s^1 and you played^3 %s%i^4m^3 %s%i^4s^1 from a total of^3 %i^4m",
    CHAT_TAG, g_eUserData[id][TOTAL_BONUS], g_eUserData[id][TOTAL_BONUS] > 1 ? "s" : "", iMin < 10 ? "0" : "", iMin, iSec < 10 ? "0" : "", iSec, g_CvarTime)

    return PLUGIN_HANDLED
}

public addTime(id)
{
    id -= TASK_ADD_TIME

    if(!shouldCountTime(id))
    {
        return
    }

    g_eUserData[id][TIME]++

    if(g_eUserData[id][TIME] >= g_CvarTime * 60)
    {
        g_eUserData[id][TIME] = 0
    
        client_print_color(0, print_team_default, "%s^3 %n^1 got^3 %i^4 scrap%s^1 for playing^3 %i^4m^1 on our server!", CHAT_TAG, id, g_CvarAmount, g_CvarAmount > 1 ? "s" : "", g_CvarTime)

        set_user_scraps(id, get_user_scraps(id) + g_CvarAmount)

        g_eUserData[id][TOTAL_BONUS]++
    }

    return
}

stock bool:shouldCountTime(const id)
{
    static TeamName:tnTeam
    tnTeam = get_member(id, m_iTeam)

    return bool:(tnTeam == TEAM_TERRORIST || tnTeam == TEAM_CT) 
}