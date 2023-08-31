#include <amxmodx>
#include <amxmisc>
#include <reapi>
#include <csgoclassy>

#define ADMIN_FLAG "c"

new CHAT_PREFIX[32]

static const g_szTeamNames[][] =
{
    "",
    "Terrorist",
    "Counter-Terrorist",
    "Spectator"
}

public plugin_init()
{
    register_plugin("[REAPI] Team Changer", "0.1", "lexzor")

    new iFlags = read_flags(ADMIN_FLAG)
    register_clcmd("say", "sayHook", iFlags)
    register_clcmd("say_team", "sayHook", iFlags)

    register_clcmd("amx_t", "changeTeam", iFlags, "<name>")
    register_clcmd("amx_ct", "changeTeam", iFlags, "<name>")
    register_clcmd("amx_spec", "changeTeam", iFlags, "<name>")

    csgo_get_prefixes(CHAT_PREFIX, charsmax(CHAT_PREFIX))
}

public sayHook(id)
{
    new szArg[192]
    read_args(szArg, charsmax(szArg))
    remove_quotes(szArg)

    if(szArg[0] == '/')
    {
        new szName[MAX_NAME_LENGTH]
        strtok2(szArg, szArg, charsmax(szArg), szName, charsmax(szName), ' ', TRIM_FULL)

        if(!isTeamCmd(szArg))
        {
            return PLUGIN_HANDLED_MAIN
        }

        switch(szArg[1])
        {
            case 't':
            {
                amxclient_cmd(id, "amx_t", szName)
                return PLUGIN_HANDLED
            }

            case 'c':
            {
                amxclient_cmd(id, "amx_ct", szName)
                return PLUGIN_HANDLED            
            }

            case 's':
            {
                amxclient_cmd(id, "amx_spec", szName)
                return PLUGIN_HANDLED
            }
        }
    }

    return PLUGIN_CONTINUE
}

public changeTeam(id, level, cid)
{
    if(!cmd_access(id, level, cid, 2))
    {
        return PLUGIN_HANDLED
    }

    new szCmd[64]
    read_argv(0, szCmd, charsmax(szCmd))
    
    new szName[MAX_NAME_LENGTH]
    read_argv(1, szName, charsmax(szName))
    
    if(!szName[0])
    {
        get_user_name(id, szName, charsmax(szName))
    }

    replace_all(szCmd, charsmax(szCmd), "amx_", "")

    new TeamName:tnTeam

    switch(szCmd[0])
    {
        case 't': tnTeam = TEAM_TERRORIST
        case 'c': tnTeam = TEAM_CT
        case 's': tnTeam = TEAM_SPECTATOR

        default:
        {
            return PLUGIN_HANDLED
        }
    }

    new iTarget = cmd_target(id, szName, CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS)

    if(!iTarget)
    {
        client_print_color(id, print_team_default, "%s User is not online", CHAT_PREFIX)
        return PLUGIN_HANDLED
    }

    new TeamName:tnUserTeam = get_member(iTarget, m_iTeam)

    if(tnUserTeam == tnTeam)
    {
        client_print_color(id, print_team_default, "%s^3 %n^1 is already in^4 %s^1 team", CHAT_PREFIX, iTarget, g_szTeamNames[_:tnTeam])
        return PLUGIN_HANDLED
    }

    new bool:bAlive

    if(is_user_alive(iTarget))
    {
        user_kill(iTarget)
        bAlive = true
    }

    if(tnUserTeam == TEAM_TERRORIST || tnUserTeam == TEAM_CT)
    {
        new iAlivePlayers
        get_players_ex(_, iAlivePlayers, GetPlayers_ExcludeDead | GetPlayers_MatchNameSubstring, tnUserTeam == TEAM_TERRORIST ? "T" : "CT")

        rg_set_user_team(iTarget, tnTeam, .check_win_conditions = bool:(iAlivePlayers == 1))
    }
    else 
    {
        rg_set_user_team(iTarget, tnTeam)
    }

    if(bAlive)
    {
        set_member(iTarget, m_iDeaths, get_member(iTarget, m_iDeaths) - 1)
    }

    if(iTarget == id)
    {
        client_print_color(0, print_team_default, "%s^3 %n^1 moved^3 himself^1 to^4 %s^1 team", CHAT_PREFIX, id, g_szTeamNames[_:tnTeam])
    }
    else 
    {
        client_print_color(0, print_team_default, "%s^3 %n^1 moved^3 %n^1 to^4 %s^1 team", CHAT_PREFIX, id, iTarget, g_szTeamNames[_:tnTeam])
    }

    return PLUGIN_HANDLED
}

stock bool:isTeamCmd(const buffer[])
{
    return (
        bool:(containi(buffer, "/t ") != -1) ||
        bool:(containi(buffer, "/spec ") != -1) ||
        bool:(containi(buffer, "/ct") != -1)
    )
}