#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <csgoclassy>
#include <nvault>

#define HUD_TASK 15000

enum _:CVARS 
{
    szRGB[12],
    Float:ypos,
    Float:xpos,
    hud_type,
    show_name
}

enum _:RGB
{
    R,
    G,
    B
}

new g_cvar[CVARS];
new hud_color[RGB]
new g_szName[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new bool:g_bActiveHud[MAX_PLAYERS + 1];

new const g_sznVaultName[] = "hud_data";
new g_nVault;
new g_hudsync;

new const g_szVIPNames[][] =
{
    "None",
    "Silver",
    "Gold"
}

new const g_szNameField[] = "Name: ";

new CHAT_TAG[32]

public plugin_init()
{
    register_plugin("CSGO Classy HUD", "1.0", "lexzor");

    g_nVault = nvault_open(g_sznVaultName);

    if(g_nVault == INVALID_HANDLE)  set_fail_state("Couldn't open nVault file ^"%s^"", g_sznVaultName);

    register_clcmd("say /hud", "hud_toggle");
    register_clcmd("say_team /hud", "hud_toggle");
    register_clcmd("reload_hud_cvars", "get_cvars");

    g_hudsync = CreateHudSyncObj();

    csgo_get_prefixes(CHAT_TAG, charsmax(CHAT_TAG))

    get_cvars(0);
}

public plugin_end()
{
    nvault_close(g_nVault);
}

public user_log_in_post(const id)
{
    get_user_name(id, g_szName[id], charsmax(g_szName[]));
    g_bActiveHud[id] = true;
    set_task(1.0, "ShowUserInfo", id + HUD_TASK, .flags = "b");
    _LoadData(id);
}

public client_disconnected(id)
{
    if(is_user_hltv(id) || is_user_bot(id))
        return PLUGIN_HANDLED;

    if(task_exists(id + HUD_TASK))
    {
        remove_task(id + HUD_TASK);
        ClearSyncHud(id, g_hudsync);
    }

    return PLUGIN_CONTINUE;
}

_LoadData(id)
{
    new szData[5], iTs;
    if(nvault_lookup(g_nVault, g_szName[id], szData, charsmax(szData), iTs))
    {
        g_bActiveHud[id] = bool:str_to_num(szData);
    }
}

_SaveData(id)
{
    new szData[5];
    num_to_str(g_bActiveHud[id] == true ? 1 : 0, szData, charsmax(szData));
    nvault_set(g_nVault, g_szName[id], szData);    
}

public ShowUserInfo(id) 
{ 
    id -= HUD_TASK; 
    
    if(is_user_connected(id) && g_bActiveHud[id] == true)
    {
        static szMessage[256];
        static iCases, iKeys, iScraps, iCapsules, iCommon, iRare, iMythic;
        static iVipLevel;
        
        if(is_user_alive(id))
        {
            iCases = get_user_cases(id);
            iKeys = get_user_keys(id);
            iScraps = get_user_scraps(id);
            iCapsules = get_user_capsules(id);
            iCommon = get_user_common(id);
            iRare = get_user_rare(id);
            iMythic = get_user_mythic(id);

            if(is_user_logged(id))
            {
                if(is_user_gold_vip(id))
                    iVipLevel = 2;
                else if (is_user_silver_vip(id))
                    iVipLevel = 1;
                else 
                    iVipLevel = 0;

                switch(g_cvar[hud_type])
                {
                    case 1:
                    {
                        formatex(szMessage, charsmax(szMessage), "[%s%s%sCase%s: %i|Key%s: %i|Scrap%s: %i|VIP Status: %s]^n[Capsule%s: %i|Common: %i|Rare: %i|Mythic: %i]",
                        g_cvar[show_name] == 1 ? g_szNameField : "", g_cvar[show_name] == 1 ? g_szName[id] : "", g_cvar[show_name] ? "|" : "",
                        iCases > 1 ? "s" : "", iCases, iKeys > 1 ? "s" : "", iKeys, iScraps > 1 ? "s" : "", iScraps, g_szVIPNames[iVipLevel], iCapsules > 1 ? "s" : "", iCapsules,
                        iCommon, iRare, iMythic);
                    }

                    case 2:
                    {
                        formatex(szMessage, charsmax(szMessage), "[Name: %s]^n[Case%s: %i]^n[Key%s: %i]^n[Scrap%s: %i]^n[VIP Status: %s]^n[Capsule%s: %i]^n[Common: %i]^n[Rare: %i]^n[Mythic: %i]",
                        g_szName[id], iCases > 1 ? "s" : "", iCases, iKeys > 1 ? "s" : "", iKeys, iScraps > 1 ? "s" : "", iScraps, g_szVIPNames[iVipLevel], iCapsules > 1 ? "s" : "", iCapsules,
                        iCommon, iRare, iMythic);
                    }
                }
            }
            else 
            {
                formatex(szMessage, charsmax(szMessage), "[You must be logged in]");
            }

            set_hudmessage(hud_color[R], hud_color[G], hud_color[B], g_cvar[xpos], g_cvar[ypos], 0, 1.0, 1.0, 0.1);
            ShowSyncHudMsg(id, g_hudsync, szMessage);
        }
        else 
        {
            static iSpecPlayer;
            iSpecPlayer = entity_get_int(id, EV_INT_iuser2);

            if(g_bActiveHud[iSpecPlayer])
            {
                if(is_user_logged(iSpecPlayer))
                {
                    iCases = get_user_cases(iSpecPlayer);
                    iKeys = get_user_keys(iSpecPlayer);
                    iScraps = get_user_scraps(iSpecPlayer);
                    iCapsules = get_user_capsules(iSpecPlayer);
                    iCommon = get_user_common(iSpecPlayer);
                    iRare = get_user_rare(iSpecPlayer);
                    iMythic = get_user_mythic(iSpecPlayer);

                    if(is_user_gold_vip(iSpecPlayer))
                        iVipLevel = 2;
                    else if (is_user_silver_vip(iSpecPlayer))
                        iVipLevel = 1;
                    else 
                        iVipLevel = 0;

                    switch(g_cvar[hud_type])
                    {
                        case 1:
                        {
                            formatex(szMessage, charsmax(szMessage), "[%s%s%sCase%s: %i|Key%s: %i|Scrap%s: %i|VIP Status: %s]^n[Capsule%s: %i|Common: %i|Rare: %i|Mythic: %i]",
                            g_cvar[show_name] == 1 ? g_szNameField : "", g_cvar[show_name] == 1 ? g_szName[iSpecPlayer] : "", g_cvar[show_name] ? "|" : "",
                            g_szName[iSpecPlayer], iCases > 1 ? "s" : "", iCases, iKeys > 1 ? "s" : "", iKeys, iScraps > 1 ? "s" : "", iScraps, g_szVIPNames[iVipLevel], iCapsules > 1 ? "s" : "", iCapsules,
                            iCommon, iRare, iMythic);
                        }

                        case 2:
                        {
                            formatex(szMessage, charsmax(szMessage), "[Name: %s]^n[Case%s: %i]^n[Key%s: %i]^n[Scrap%s: %i]^n[VIP Status: %s]^n[Capsule%s: %i]^n[Common: %i]^n[Rare: %i]^n[Mythic: %i]",
                            g_szName[iSpecPlayer], iCases > 1 ? "s" : "", iCases, iKeys > 1 ? "s" : "", iKeys, iScraps > 1 ? "s" : "", iScraps, g_szVIPNames[iVipLevel], iCapsules > 1 ? "s" : "", iCapsules,
                            iCommon, iRare, iMythic);
                        }
                    }
                }          
                else if (is_user_logged(id) && is_user_connected(iSpecPlayer))
                {
                    formatex(szMessage, charsmax(szMessage), "[Player %s is not logged in]", g_szName[iSpecPlayer]);
                }
                else if (!is_user_logged(id))
                {
                    formatex(szMessage, charsmax(szMessage), "[You must be logged in]");
                }   
            }
            else 
            {
                formatex(szMessage, charsmax(szMessage), "[Player %s disabled hud informations]", g_szName[iSpecPlayer]);
            }   

            if(is_user_connected(iSpecPlayer))
            {
                set_hudmessage(hud_color[R], hud_color[G], hud_color[B], g_cvar[xpos], g_cvar[ypos], 0, 1.0, 1.0, 0.1);
                ShowSyncHudMsg(id, g_hudsync, szMessage);
            }
            else return PLUGIN_HANDLED;
        }
    }

    return PLUGIN_CONTINUE;
}

public hud_toggle(id)
{
    g_bActiveHud[id] = !g_bActiveHud[id];

    client_print_color(id, print_team_default, "%s You^3 %s ^1hud informations", CHAT_TAG, g_bActiveHud[id] ? "enabled" : "disabled");
    _SaveData(id);
}

public get_cvars(id)
{
    if(id != 0 && !(get_user_flags(id) & ADMIN_IMMUNITY))
    {
        return PLUGIN_HANDLED;
    }

    new data;
    data = register_cvar("hud_rgb", "47 79 79");
    get_pcvar_string(data, g_cvar[szRGB], charsmax(g_cvar[szRGB]));

    new r[4], g[4], b[4];
    parse(g_cvar[szRGB], r, charsmax(r), g, charsmax(g), b, charsmax(b));

    hud_color[R] = str_to_num(r);
    hud_color[G] = str_to_num(g);
    hud_color[B] = str_to_num(b);

    data = register_cvar("hud_x_pos", "0.805");
    g_cvar[xpos] = get_pcvar_float(data);
    
    data = register_cvar("hud_y_pos", "-1.0");
    g_cvar[ypos] = get_pcvar_float(data);

    data = register_cvar("hud_type", "1");
    g_cvar[hud_type] = get_pcvar_num(data);

    data = register_cvar("hud_show_name", "1");
    g_cvar[show_name] = get_pcvar_num(data);

    if(id != 0)
    {
        client_print(id, print_console, "[CSGO Classy] Hud cvars has been reloaded");
    }

    return PLUGIN_HANDLED;
}
