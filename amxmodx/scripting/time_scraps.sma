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
            "bonus_time_min",
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
            "bonus_amount",
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
    new szName[MAX_NAME_LENGTH], szData[16], iTs
    get_user_name(id, szName, charsmax(szName))

    if(nvault_lookup(g_iVault, szName, szData, charsmax(szData), iTs))
    {
        new szTotalBonus[10], szTotalTime[6]
        strtok2(szData, szTotalBonus, charsmax(szTotalBonus), szTotalTime, charsmax(szTotalTime), '#', TRIM_FULL)

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

    nvault_set(g_iVault, szName, fmt("%i#%i", g_eUserData[TOTAL_BONUS], g_eUserData[TIME]))

    return
}

public scrapsCommand(const id)
{
    new iMin = g_eUserData[id][TIME] % 60
    new iSec = g_eUserData[id][TIME]

    client_print_color(id, print_team_default, "%s You completed this task^3 %i^4 time%s^1 and now you played^4 %s%im %s%is^4 from a total of^4 %im",
    CHAT_TAG, g_eUserData[id][TOTAL_BONUS], g_eUserData[id][TOTAL_BONUS] > 1 ? "s" : "", iMin < 10 ? "0" : "", iMin, iSec < 10 ? "0" : "", g_CvarTime)
}

public addTime(const id)
{
    if(!shouldCountTime(id))
    {
        return
    }

    g_eUserData[id][TIME]++

    if(g_eUserData[id][TIME] >= g_CvarTime * 60)
    {
        g_eUserData[id][TIME] = 0
    
        client_print_color(id, print_team_default, "%s You got^3 %i^4 scrap%s^1 for playing!", CHAT_TAG, g_CvarAmount, g_CvarAmount > 1 ? "s" : "")

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