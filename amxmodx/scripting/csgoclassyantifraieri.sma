#include <amxmodx>
#include <amxmisc>

new Array:g_aRes;
new szFile[64];
new szAuthID[MAX_PLAYERS+1][MAX_AUTHID_LENGTH];
new bool:g_bRemovingSteamID;

#define FILE_NAME "anti_fraieri.ini"
#define ADMIN_FLAG "a"
#define KICK_REASON "iesi du-te-n plm :))"
#define LOG_FILE "antifraieri.log"
#define TAG "[ANTI-FRAIERI]"

#if !defined MAX_AUTHID_LENGTH
    #define MAX_AUTHID_LENGTH 64
#endif

#if !defined MAX_NAME_LENGTH
    #define MAX_NAME_LENGTH 32
#endif

public plugin_init()
{
    register_plugin("Anti Fraieri", "69.2", "lexzor");
    
    new szConfigsDir[64];
    get_configsdir(szConfigsDir, charsmax(szConfigsDir));
    formatex(szFile, charsmax(szFile), "%s/%s", szConfigsDir, FILE_NAME);
    
    g_aRes = ArrayCreate(64);
    read_steamid_file();
    set_task(5.0, "read_steamid_file", .flags = "b");
    new iFlag = read_flags(ADMIN_FLAG);
    register_clcmd("add_steamid", "add_steamid", iFlag, "<steamid> [doar clasa, nu tot]");
    register_clcmd("remove_steamid", "remove_steamid", iFlag, "<steamid> [trebuie sa se regaseasca in fisier]");
    register_clcmd("restricted_steamids", "restricted_steamid", iFlag, "<>");
}

public plugin_end()
{
    ArrayDestroy(g_aRes)
}

public restricted_steamid(id, level, cid)
{
    if(!cmd_access(id, level, cid, 1)) 
        return PLUGIN_HANDLED;

    new szSteamid[MAX_AUTHID_LENGTH], szHostName[64], iCount;
    get_cvar_string("hostname", szHostName, charsmax(szHostName));

    client_print(id, print_console, "^n%s BANNED STEAMIDS ON [%s]^n", TAG, szHostName);

    for(new i; i < ArraySize(g_aRes); i++)
    {
        ArrayGetString(g_aRes, i, szSteamid, charsmax(szSteamid));
        client_print(id, print_console, "[%i] %s", i, szSteamid);
        iCount++;
    }

    client_print(id, print_console, "^n[COUNT] There is a total of %i banned steamids^n", iCount);

    client_print(id, print_console, "^n%s BANNED STEAMIDS ON [%s]^n^n", TAG, szHostName);

    return PLUGIN_HANDLED;
}

public remove_steamid(id, level, cid)
{
    if(!cmd_access(id, level, cid, 2)) 
        return PLUGIN_HANDLED;

    new szSteamid[MAX_AUTHID_LENGTH], iFile;
    read_argv(1, szSteamid, charsmax(szSteamid));

    new iPos = ArrayFindString(g_aRes, szSteamid);

    if(iPos != -1 && delete_file(szFile) && (iFile = fopen(szFile, "w")))
    {
        g_bRemovingSteamID = true;
        new szData[MAX_AUTHID_LENGTH];
        ArrayDeleteItem(g_aRes, iPos);
    
        for(new i; i < ArraySize(g_aRes); i++)
        {
            ArrayGetString(g_aRes, i, szData, charsmax(szData));
            add(szData, charsmax(szData), "^n");
            fputs(iFile, szData);
        }

        fclose(iFile);

        new szName[MAX_NAME_LENGTH];
        get_user_name(id, szName, charsmax(szName));

        log_to_file(LOG_FILE, "%s Clasa SteamID ^"%s^" a fost stearsa din lista de catre adminul %s", TAG, szSteamid, szName);
        client_print(id, print_console, "%s Clasa SteamID ^"%s^" a fost stearsa din lista", TAG, szSteamid);

        g_bRemovingSteamID = false;
    }
    else    client_print(id, print_console, "%s Clasa SteamID ^"%s^" nu se afla in lista", TAG, szSteamid);

    return PLUGIN_HANDLED;
}

public add_steamid(id, level, cid)
{
    if(!cmd_access(id, level, cid, 2)) 
        return PLUGIN_HANDLED;

    new szSteamid[MAX_AUTHID_LENGTH], iFile;
    read_argv(1, szSteamid, charsmax(szSteamid));

    if(file_exists(szFile) && (iFile = fopen(szFile, "a")))
    {
        new szAuthID[MAX_AUTHID_LENGTH], szName[MAX_NAME_LENGTH];
        check_players(id, szSteamid);
        client_print(id, print_console, "%s Clasa SteamID ^"%s^" a fost adaugata in lista", TAG, szSteamid);
        get_user_authid(id, szAuthID, charsmax(szAuthID));
        get_user_name(id, szName, charsmax(szName));
        log_to_file(LOG_FILE, "%s Clasa SteamID ^"%s^" a fost adaugata in lista de catre adminul %s [%s]", TAG, szSteamid, szName, szName, szAuthID);
        add(szSteamid, charsmax(szSteamid), "^n");
        fputs(iFile, szSteamid);
        fclose(iFile);
    } else log_to_file(LOG_FILE, "Fisierul %s nu exista", szFile);

    return PLUGIN_HANDLED
}

check_players(const id, const steamid[])
{
    new iPlayers[MAX_PLAYERS], iNum;
    get_players(iPlayers, iNum, "ch");

    for(new i, iPlayer; i < iNum; i++)
    {
        iPlayer = iPlayers[i];
        if(containi(szAuthID[iPlayer], steamid) != -1)
        {
            server_cmd("kick #%i ^"%s^"", get_user_userid(iPlayer), KICK_REASON);
            server_exec();
            client_print(id, print_console, "%s Jucatorul care are clasa SteamID ^"%s^" a primit kick (%s)", TAG, steamid, szAuthID[iPlayer]);
            log_to_file(LOG_FILE, "%s Jucatorul care are clasa SteamID ^"%s^" a primit kick (%s)", TAG, steamid, szAuthID[iPlayer]);
        }
    } 
}

public read_steamid_file()
{
    if(g_bRemovingSteamID)  return PLUGIN_HANDLED;

    if(file_exists(szFile))
    {
        ArrayClear(g_aRes);
        static iFile, szData[64];
        iFile = fopen(szFile, "r");

        while(fgets(iFile, szData, charsmax(szData)))
        {
            trim(szData);
            if(!szData[0] || szData[0] == ';' || szData[0] == '#')  continue;

            remove_quotes(szData);
            ArrayPushString(g_aRes, szData);
        }

        fclose(iFile);
    }

    return PLUGIN_CONTINUE;
}

public client_authorized(id)
{
    new szData[MAX_AUTHID_LENGTH];
    get_user_authid(id, szAuthID[id], charsmax(szAuthID[]));

    for(new i; i < ArraySize(g_aRes); i++)
    {
        ArrayGetString(g_aRes, i, szData, charsmax(szData));
        if(containi(szAuthID[id], szData) != -1)
        {
            server_cmd("kick #%i ^"%s^"", get_user_userid(id), KICK_REASON);
            server_exec();
        }
    }
}