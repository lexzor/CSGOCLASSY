#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <csgoclassy>

#define AUTO_LOGIN_RETRY_TASK 5000
#define MAX_AUTO_LOGIN_TRY 3

new g_nVault;
new const g_nVaultName[] = "autologindata";

new g_szName[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new g_szAuthID[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH];
new bool:g_bAutoLogin[MAX_PLAYERS + 1];
new g_iAutoLoginRetry[MAX_PLAYERS + 1];

new g_iMenuID
new CHAT_TAG[32]

public plugin_init()
{
    register_plugin("Auto Login", "2.3", "lexzor");
    register_event("TeamInfo", "func_teaminfo", "a");

    g_nVault = nvault_open(g_nVaultName);

    csgo_get_prefixes(CHAT_TAG, charsmax(CHAT_TAG))

    if(g_nVault == INVALID_HANDLE)
    {
        set_fail_state("[AUTOLOGIN] Couldn't open ^"%s^" file", g_nVaultName);
    }

    g_iMenuID = csgo_register_menu(MenuCode:MENU_SETTINGS, "Auto login")
}

public csgo_menu_item_selected(const id, const MenuCode:menu_code, const itemid)
{
    if(menu_code != MenuCode:MENU_SETTINGS && g_iMenuID != itemid)
    {
        return
    }

    g_bAutoLogin[id] = !g_bAutoLogin[id]

    client_print_color(id, print_team_default, "%s Auto login is ^4%s", CHAT_TAG, g_bAutoLogin[id] ? "enabled" : "disabled");
    _SaveData(id);
    csgo_additional_menu_name(MenuCode:MENU_SETTINGS, g_iMenuID, id, fmt("%s^n\dYou will be\y logged in\d every time you join the server^n", g_bAutoLogin[id] ? "\r[ON]" : "\r[OFF]"))
    
    display_menu(id, MenuCode:MENU_SETTINGS);

    return 
}

public user_log_in_post(const id)
{
    csgo_additional_menu_name(MenuCode:MENU_SETTINGS, g_iMenuID, id, fmt("%s^n\dYou will be\y logged in\d every time you join the server^n", g_bAutoLogin[id] ? "\r[ON]" : "\r[OFF]"))
}

public plugin_end()
{
    nvault_close(g_nVault);
}

public func_teaminfo()
{
    static id
    id = read_data(1);
    
    static szTeam[2];
    read_data(2, szTeam, charsmax(szTeam));
    
    if(szTeam[0] != 'U')
        autologin(id);     
}

public autologin(id)
{
    if(id > MAX_PLAYERS)
        id -= AUTO_LOGIN_RETRY_TASK;
        
    if(g_iAutoLoginRetry[id] > 1)
    {
        client_print_color(id, print_team_default, "%s Retrying auto login for^4 %i^1 time.", CHAT_TAG, g_iAutoLoginRetry[id]);
        client_print_color(id, print_team_default, "%s This can be caused from^4 no response^1 from our database.", CHAT_TAG, g_iAutoLoginRetry[id]);
    }
    else if(g_iAutoLoginRetry[id] == MAX_AUTO_LOGIN_TRY)
    {
        client_print_color(id, print_team_default, "%s Auto login failed", CHAT_TAG);
        return PLUGIN_HANDLED;
    }

    new szData[50], szAutoLoginTime[12], iTs;

    if(!is_user_logged(id) && nvault_lookup(g_nVault, g_szName[id], szData, charsmax(szData), iTs) && is_user_connected(id))
    {
        new szLastAuthID[MAX_AUTHID_LENGTH], szAutoLogin[3];

        parse(szData, szLastAuthID, charsmax(szLastAuthID), szAutoLogin, charsmax(szAutoLogin), szAutoLoginTime, charsmax(szAutoLoginTime));

        g_bAutoLogin[id] = bool:str_to_num(szAutoLogin);

        if(equali(g_szAuthID[id], szLastAuthID) && g_bAutoLogin[id])
        {
            if(set_user_login_value(id, true) != -1)
            {
                client_print_color(id, print_team_default, "%l", "AUTO_LOGGED_IN_SUCCESFULLY");
            }
            else
            {
                set_task(1.0, "autologin", id + AUTO_LOGIN_RETRY_TASK);
                g_iAutoLoginRetry[id]++;
                log_amx("Error on receiving player data with SteamID ^"%s^". Retry: %i", g_szAuthID[id], g_iAutoLoginRetry[id]);
            }
        }

        csgo_additional_menu_name(MenuCode:MENU_SETTINGS, g_iMenuID, id, fmt("%s^n\dYou will be\y logged in\d every time you join the server^n", g_bAutoLogin[id] ? "\r[ON]" : "\r[OFF]"))
    }

    return PLUGIN_CONTINUE;
}

public client_authorized(id)
{
    if(is_user_bot(id) || is_user_hltv(id))
        return PLUGIN_HANDLED;

    get_user_authid(id, g_szAuthID[id], charsmax(g_szAuthID[]));
    get_user_name(id, g_szName[id], charsmax(g_szName[]));
    g_iAutoLoginRetry[id] = 0;
    g_bAutoLogin[id] = false;

    return PLUGIN_CONTINUE;
}

_SaveData(id)
{
    new szData[128];
    formatex(szData, charsmax(szData), "^"%s^" ^"%d^" ^"%i^"", g_szAuthID[id], g_bAutoLogin[id], get_systime());
    nvault_set(g_nVault, g_szName[id], szData);
}