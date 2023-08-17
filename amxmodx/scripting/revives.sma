#include <amxmodx>
#include <hamsandwich>
#include <csgoclassy>
#include <nvault>


#define CHAT_COMMAND "/revive"

enum _:SETTINGS
{
    REVIVES,
    MONEY
}

enum _:TEAMS 
{
    TERRORIST = 1,
    COUNTER_TERRORIST = 2
}

new g_eCvar[SETTINGS]
new g_iRevives[MAX_PLAYERS + 1]
new g_iTotalRevives[MAX_PLAYERS + 1]

new g_iMenuID

static const g_szVaultName[] = "saved_revives"
new g_iVault

new CHAT_PREFIX[32]

public plugin_init()
{
    register_plugin("[CSGO Classy] Revive", "lexzor", "0.1")

    new data;
    data = register_cvar("csgo_revives", "1")
    g_eCvar[REVIVES] = get_pcvar_num(data)

    data = register_cvar("csgo_money", "350")
    g_eCvar[MONEY] = get_pcvar_num(data)

    register_clcmd("say", "sayHook")
    register_clcmd("say_team", "sayHook")

    register_logevent("fwRoundStart", 2, "1=Round_Start")

    g_iVault = nvault_open(g_szVaultName)

    if(g_iVault == INVALID_HANDLE)
    {
        set_fail_state("Could opened vault file %s", g_szVaultName)
    }

    g_iMenuID = csgo_register_menu(MenuCode:MENU_INVENTORY, "Bought revives")

    csgo_get_prefixes(CHAT_PREFIX, charsmax(CHAT_PREFIX))
}

public csgo_menu_item_selected(const id, const MenuCode:menu_code, const itemid)
{
    if(menu_code != MenuCode:MENU_INVENTORY || itemid != g_iMenuID)
    {
        return
    }

    client_print_color(id, print_team_default, "%s You have been revived^3 %i time%s^1", CHAT_PREFIX, g_iTotalRevives[id], g_iTotalRevives[id] > 1 ? "s" : "")
    display_menu(id, MenuCode:MENU_INVENTORY)

    return
}

public fwRoundStart()
{
    new iPlayers[MAX_PLAYERS], iNum
    get_players(iPlayers, iNum, "ch")

    for(new i = 0, iPlayer; i < iNum; i++)
    {
        iPlayer = iPlayers[i]

        if(is_user_connected(iPlayer))
        {
            g_iRevives[iPlayer] = 0
        }
    }
}

public sayHook(id)
{
    static szArg[192]
    read_args(szArg, charsmax(szArg))
    remove_quotes(szArg)

    if(equal(szArg, CHAT_COMMAND))
    {
        new TEAMS:iTeam = TEAMS:get_user_team(id)

        if(!is_user_logged(id))
        {
            client_print_color(id, print_team_default, "%s You be^4 logged in^1 to perform this action", CHAT_PREFIX)
            return PLUGIN_HANDLED_MAIN
        }

        if(is_user_alive(id))
        {
            client_print_color(id, print_team_default, "%s You must be^4 dead^1 to perform this action", CHAT_PREFIX)
            return PLUGIN_HANDLED_MAIN
        }

        if(iTeam != TEAMS:COUNTER_TERRORIST && iTeam != TEAMS:TERRORIST)
        {
            client_print_color(id, print_team_default, "%s You can't^4 perform^1 this action", CHAT_PREFIX)
            return PLUGIN_HANDLED_MAIN
        }

        if(g_iRevives[id] >= g_eCvar[REVIVES] && g_eCvar[REVIVES] > 0)
        {
            client_print_color(id, print_team_default, "%s Maximum number of^3 revives^1 has been reached", CHAT_PREFIX)
            return PLUGIN_HANDLED_MAIN
        }

        new iMoney;
        iMoney = get_user_money(id)

        if(iMoney < g_eCvar[MONEY])
        {
            client_print_color(id, print_team_default, "%s You don't have enough^4 money^1! You need^3 %i$^1 more", CHAT_PREFIX, g_eCvar[MONEY] - iMoney)
            return PLUGIN_HANDLED_MAIN
        }

        ExecuteHamB(Ham_CS_RoundRespawn, id)
        
        g_iRevives[id]++
        set_user_money(id, iMoney - g_eCvar[MONEY])

        client_print_color(id, print_team_default, "%s You have been^4 revived^1 for^3 %i$", CHAT_PREFIX, g_eCvar[MONEY])

        g_iTotalRevives[id]++

        csgo_add_inventory_item_value(id, g_iMenuID, g_iTotalRevives[id] * g_eCvar[MONEY])

        new szName[MAX_NAME_LENGTH]
        get_user_name(id, szName, charsmax(szName))
        
        nvault_set(g_iVault, szName, fmt("%i", g_iTotalRevives[id]))
    }

    return PLUGIN_CONTINUE
}

public user_log_in_post(const id)
{
    static szName[MAX_NAME_LENGTH], szData[10], iTs
    get_user_name(id, szName, charsmax(szName))

    if(nvault_lookup(g_iVault, szName, szData, charsmax(szData), iTs))
    {
        g_iTotalRevives[id] = str_to_num(szData)
    }

    csgo_add_inventory_item_value(id, g_iMenuID, g_iTotalRevives[id] * g_eCvar[MONEY])
}

public client_connect(id)
{
    g_iRevives[id] = 0;
    g_iTotalRevives[id] = 0;
}