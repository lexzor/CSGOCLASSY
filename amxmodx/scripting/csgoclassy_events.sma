/*
    BONUS TYPE:

    0: Money
    1: Keys
    2: Skin cases
    3: Scraps 
    4: Nametag Capsule 
    5: Common Nametag 
    6: Rare Nametag 
    7: Mythic Nametag 
    8: Multiple Nametags 
    9: Glove Cases 
    10: GloveID 
    11: SkinID 
    12: Multiple Skins ID
*/

#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <hamsandwich>
#include <csgoclassy>

//UNCOMMENT BELOW LINE TO ENABLE DEBUG MODE
//#define DEBUG_MODE

#define CHAT_COMMAND "/events"

#define CONSOLE_PREFIX                  "[CSGO Classy EVENTS]"

#define CONFIG_FILE                     "events.cfg"
#define LOG_FILE                        "csgoclassy_events.log"

#define EVENTS_CHECKING_FLOAT           20.0
#define ACCES_FLAG                      "a"
#define MAX_EVENTS                      30
#define MAX_DESCRIPTION_LENGTH          100
#define MENU_ITEMS_PER_PAGE             2
#define MIN_ONEDAY_LENGTH               11 + 2
#define MAX_EVENT_NAME_LENGTH           36

#if !defined MAX_PLAYERS
    #define MAX_PLAYERS                 32
#endif 

#if !defined client_disconnected
    #define client_disconnected         client_disconnect
#endif 

#if !defined MAX_NAME_LENGTH
    #define MAX_NAME_LENGTH             32
#endif

#define MAX_KEY_LENGTH                  MAX_NAME_LENGTH + 10

#define isValidPlayer(%0)               (0 < %0 < (MAX_PLAYERS + 1))

const DAY_IN_SEC = 87000;

enum _:EVDATA
{
    ID,
    DIFFICULTY,
    EVENT_NAME[MAX_EVENT_NAME_LENGTH],
    EVENT_TYPE[5],
    EVENT_TOTAL_SCORE,
    BONUS_TYPE[8],
    BONUS_AMOUNT,
    START_DAY[10],
    END_DAY[10],
    START_HOUR[12],
    END_HOUR[12],
    STATE,
    bool:ENABLED,
    bool:ONEDAY,
    bool:NEWEVENT,
    bool:SAVED,
    JOINED_PLAYERS,
    DESCRIPTION[MAX_DESCRIPTION_LENGTH],
    JPLAYERS_NAME[MAX_NAME_LENGTH * 500]
}

enum (+= 1000)
{
    SEND_MESSAGE_TASK = 1000,
    START_EVENT_CHECKING_TASK,
    UNUSED_IDS_TASK,
    HOURS_TASK
}

enum _:SETTINGS
{
    ADMIN_FLAG
}

enum (+=1)
{
    EASY = 1,
    MEDIUM,
    HARD
}

enum 
{
    NOT_JOINED = -1,
    JOINED = -2,
    FINISHED = -3
}

enum
{
    NO_STATE = -1,
    STARTED_STATE = 0,
    ENDED_STATE = 1,
    DISABLED_STATE = 2
}

enum 
{
    START = 0,
    END = 1,
    NEW = 2
}



enum (+=1)
{
    TYPE_KILLS = 0,
    TYPE_HOURS
}


enum 
{
    GET_DATA = 0,
    SAVE_DATA = 1
}

enum 
{
    NO_SCORE = -1
}

enum (+=1)
{
    TYPE_MONEY = 0,
    TYPE_KEYS,
    TYPE_SKIN_CASES,
    TYPE_SCRAPS,
    TYPE_NAMETAG_CAPSULE,
    TYPE_COMMON,
    TYPE_RARE,
    TYPE_MYTHIC,
    TYPE_MULTIPLE_NAMETAGS,
    TYPE_GLOVE_CASES,
    TYPE_GLOVE_ID,
    TYPE_SKIN_ID,
    TYPE_MULTIPLE_SKINS
}

/* 
 0 - Money
 1 - Keys
 2 - Skin Cases
 3 - Scraps
 4 - NameTag Capsule
 5 - NameTag Common
 6 - NameTag Rare
 7 - NameTag Mythic
 8 - Multiple name tags COMMON, RARE, MYTHIC Exemplu (0, 3, 1) -> va primii doar 3 Rare si 1 Mythic
 9 - Glove Cases
 10 - Glove ID (0-4)
 11 - Skin ID
 12 - Multiple Skins  skinid, skinid, skinid exemplu 0,132,328 (va primii skinidurile respective)
*/

enum _:BTYPE
{
    TMONEY,
    KEYS,
    SKIN_CASES,
    SCRAPS,
    NAMETAG_CAPSULE,
    COMMON,
    RARE,
    MYTHIC,
    MULTIPLE_NAMETAGS[50],
    GLOVE_CASES,
    GLOVE_ID[2],
    SKIN_ID,
    MULTIPLE_SKINS[50]
}

enum _:USERDATA
{
    szName[MAX_NAME_LENGTH],
    iUserEvent[MAX_EVENTS],
    iEventScore[MAX_EVENTS],
    iTotalJoinedEvents,
    iTotalWinEvents,
    bool:bMenuOpenedFromMain
}

new const g_szAlphabet[] = "abcdefghijklmnopqrstuvxyz";
new g_EventsnVault;
new const g_EventsnVaultName[] = "events";
new g_PlayersnVault;
new const g_PlayersnVaultName[] = "player_events";
new g_eUserData[MAX_PLAYERS + 1][USERDATA];
new bool:g_bCheckEventsID[MAX_EVENTS];
new Array:g_aEvents;
new g_eSettings[SETTINGS];
new BACKNAME[25];
new EXITNAME[25];

new CHAT_PREFIX[32];                     
new MENU_PREFIX[32];                    

new g_iMenuID;

public plugin_init()
{
    register_plugin("[CSGO Classy] Events", "1.0", "lexzor");

    register_dictionary("csgoclassy_events.txt");
    RegisterHam(Ham_Killed, "player", "playerKilledPost", true);
    register_clcmd("say", "sayCmd");
    register_clcmd("say_team", "sayCmd");

    //register_clcmd("se", "se")

    g_EventsnVault = nvault_open(g_EventsnVaultName);

    if(g_EventsnVault == INVALID_HANDLE)
        set_fail_state("Error! Couldn't open nvault ^"%s^"", g_EventsnVault);

    g_PlayersnVault = nvault_open(g_PlayersnVaultName);

    if(g_PlayersnVault == INVALID_HANDLE)
        set_fail_state("Error! Couldn't open nvault ^"%s^"", g_PlayersnVaultName);

    csgo_get_prefixes(CHAT_PREFIX, charsmax(CHAT_PREFIX), MENU_PREFIX, charsmax(MENU_PREFIX));

    g_iMenuID = csgo_register_menu(MenuCode:MENU_MAIN, fmt("%l", "CSGO_MENU_ITEM_NAME"));

    ConfigurePlugin();
}

public csgo_menu_item_selected(const id, const MenuCode:menu_code, const menuid)
{
    if(menu_code != MenuCode:MENU_MAIN && menuid != g_iMenuID)
    {
        return
    }

    open_menu(id)
    g_eUserData[id][bMenuOpenedFromMain] = true

    return
}

public plugin_end()
{
    ArrayDestroy(g_aEvents);
    nvault_close(g_EventsnVault);
    nvault_close(g_PlayersnVault);
}

public ConfigurePlugin()
{
    g_eSettings[ADMIN_FLAG] = read_flags(ACCES_FLAG);

    register_clcmd("display_events", "displayEventsCmd", g_eSettings[ADMIN_FLAG], "Display events from .cfg file", -1, false);

    ReadEvents();

    formatex(BACKNAME, charsmax(BACKNAME), "%l", "MENU_BACK_NAME");
    formatex(EXITNAME, charsmax(EXITNAME), "%l", "MENU_EXIT_NAME");
}

public sayCmd(id)
{
    static szArg[192];
    read_args(szArg, charsmax(szArg));
    remove_quotes(szArg);
    trim(szArg);

    if(equali(szArg, CHAT_COMMAND))
    {
        open_menu(id);
    }
}
/////////////////////////////
/////////// USER ///////////
////////////////////////////

public client_putinserver(id)
{
    
    if(is_user_bot(id) || is_user_hltv(id) || !isValidPlayer(id))
        return PLUGIN_HANDLED;


    get_user_name(id, g_eUserData[id][szName], charsmax(g_eUserData[][szName]));

    g_eUserData[id][iTotalJoinedEvents]     =       0;
    g_eUserData[id][iTotalWinEvents]        =       0;
    g_eUserData[id][bMenuOpenedFromMain]    =       false;

    for(new i; i < MAX_EVENTS; i++)
    {
        g_eUserData[id][iEventScore][i]     =       NO_SCORE;
        g_eUserData[id][iUserEvent][i]      =       NOT_JOINED;
    }

    return PLUGIN_CONTINUE;
}

public client_disconnected(id)
{
    if(is_user_bot(id) || is_user_hltv(id) || !isValidPlayer(id))
        return PLUGIN_HANDLED;

    _SaveUserData(id);

    if(task_exists(id + HOURS_TASK)) remove_task(id + HOURS_TASK);

    return PLUGIN_CONTINUE;
}

_SaveUserData(id)
{
    static eEvent[EVDATA];
    for(new i; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvent);
        ManipulatePlayerData(id, eEvent[ID], SAVE_DATA);
    }
}

public user_log_in_post(const id)
{
    new eEvent[EVDATA];
    for(new i; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvent);

        if(eEvent[STATE] == STARTED_STATE)
            ManipulatePlayerData(id, eEvent[ID], GET_DATA);
    }   
}

/////////////////////////////
///////////MENU//////////////
/////////////////////////////

public open_menu(id)
{
    if(!is_user_logged(id) || !isValidPlayer(id))
    {
        client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "MUST_BE_LOGGED_IN")
        return PLUGIN_HANDLED;
    }

    new szTitle[256], szItem[64];
    formatex(szTitle, charsmax(szTitle), "%s %l^n^n%l^n%l", MENU_PREFIX, "MAIN_MENU_TITLE",
    "MAIN_MENU_JOINED_EVENTS", g_eUserData[id][iTotalJoinedEvents],
    "MAIN_MENU_WINNED_EVENTS", g_eUserData[id][iTotalWinEvents])
    new iMenu = menu_create(szTitle, "main_menu_handler");

    formatex(szItem, charsmax(szItem), "%l", "RUNNING_EVENTS_OPTION", GetRunningEvents());
    menu_additem(iMenu, szItem);

    formatex(szItem, charsmax(szItem), "%l", "ENDED_EVENTS_OPTION", GetEndedEvents());
    menu_additem(iMenu, szItem);

    formatex(szItem, charsmax(szItem), "%l", "UPCOMING_EVENTS_OPTION", GetUpcomingEvents());
    menu_additem(iMenu, szItem);
   
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);

    if(is_user_connected(id))
        menu_display(id, iMenu, 0, -1);

    return PLUGIN_CONTINUE;
}

public main_menu_handler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);

        if(g_eUserData[id][bMenuOpenedFromMain])
        {
            display_menu(id, MenuCode:MENU_MAIN);
            g_eUserData[id][bMenuOpenedFromMain] = false;
        }

        return PLUGIN_HANDLED;
    }

    switch(item)
    {
        case 0: open_running_events_menu(id, 0);
        case 1: open_ended_events_menu(id, 0);
        case 2: open_upcoming_events_menu(id, 0);
    }

    return PLUGIN_CONTINUE;
}

open_ended_events_menu(id, page)
{
    new szTitle[256], szItem[256], szParseData[5], iCount;
    static eEvent[EVDATA];
    formatex(szTitle, charsmax(szTitle), "%s %l", MENU_PREFIX, "ENDED_EVENTS_MENU_TITLE")
    new iMenu = menu_create(szTitle, "events_handler");

    for(new i; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvent);

        if(eEvent[STATE] == ENDED_STATE)
        {
            formatex(szItem, charsmax(szItem), "%s %s^n%s^n%l^n%l^n^n",
            eEvent[EVENT_NAME], EventDifficultyMenu(eEvent[DIFFICULTY]),
            eEvent[DESCRIPTION],
            "START_TIME", eEvent[START_DAY], eEvent[START_HOUR],
            "END_TIME", eEvent[END_DAY], eEvent[END_HOUR]);
            num_to_str(eEvent[STATE], szParseData, charsmax(szParseData));
            menu_additem(iMenu, szItem, szParseData);
            iCount++;
        }
    }

    if(iCount == 0)
    {
        formatex(szItem, charsmax(szItem), "\d%l", "MENU_NO_ITEMS");
        menu_additem(iMenu, szItem, "NO_ITEMS");
    }

    menu_setprop(iMenu, MPROP_EXITNAME, EXITNAME);
    menu_setprop(iMenu, MPROP_BACKNAME, BACKNAME);
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
    menu_setprop(iMenu, MPROP_PERPAGE, MENU_ITEMS_PER_PAGE);
    menu_setprop(iMenu, MPROP_SHOWPAGE, false);

    if(is_user_connected(id))
        menu_display(id, iMenu, page, -1);
}

open_upcoming_events_menu(id, page)
{
    new szTitle[256], szItem[256], szParseData[5], iCount;
    static eEvent[EVDATA];
    formatex(szTitle, charsmax(szTitle), "%s %l", MENU_PREFIX, "UPCOMING_EVENTS_MENU_TITLE")
    new iMenu = menu_create(szTitle, "events_handler");

    for(new i; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvent);

        if(eEvent[STATE] == NO_STATE)
        {
            formatex(szItem, charsmax(szItem), "%s %s^n%s^n%l^n%l^n^n",
            eEvent[EVENT_NAME], EventDifficultyMenu(eEvent[DIFFICULTY]),
            eEvent[DESCRIPTION],
            "START_TIME", eEvent[START_DAY], eEvent[START_HOUR],
            "END_TIME", eEvent[END_DAY], eEvent[END_HOUR]);
            num_to_str(eEvent[STATE], szParseData, charsmax(szParseData));
            menu_additem(iMenu, szItem, szParseData);
            iCount++;
        }
    }

    if(iCount == 0)
    {
        formatex(szItem, charsmax(szItem), "\d%l", "MENU_NO_ITEMS");
        menu_additem(iMenu, szItem, "NO_ITEMS");
    }

    menu_setprop(iMenu, MPROP_EXITNAME, EXITNAME);
    menu_setprop(iMenu, MPROP_BACKNAME, BACKNAME);
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
    menu_setprop(iMenu, MPROP_PERPAGE, MENU_ITEMS_PER_PAGE);
    menu_setprop(iMenu, MPROP_SHOWPAGE, false);

    if(is_user_connected(id))
        menu_display(id, iMenu, page, -1);
}

public events_handler(id, menu, item)
{
    new szParsedEventType[5];
    menu_item_getinfo(menu, item, _, szParsedEventType, charsmax(szParsedEventType), _, _, _);

    switch(str_to_num(szParsedEventType))
    {
        case ENDED_STATE:
        {
            open_ended_events_menu(id, 0);
        }

        case NO_STATE:
        {
            open_upcoming_events_menu(id, 0);
        }
    }
}

open_running_events_menu(id, page)
{
    new szTitle[256], szItem[256], szParseData[5], iCount;
    static eEvent[EVDATA];
    formatex(szTitle, charsmax(szTitle), "%s %l^n^n%l", MENU_PREFIX, "RUNNING_EVENTS_MENU_TITLE", "MENU_RUNNING_EVENTS_INFO")
    new iMenu = menu_create(szTitle, "running_events_handler");

    for(new i; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvent);

        if(eEvent[STATE] == STARTED_STATE)
        {
            formatex(szItem, charsmax(szItem), "%s %s%l^n%s^n%l^n%l^n%s^n^n",
            eEvent[EVENT_NAME], EventDifficultyMenu(eEvent[DIFFICULTY]),
            g_eUserData[id][iUserEvent][eEvent[ID]] == JOINED ? "MENU_EVENT_JOINED_TEXT" : g_eUserData[id][iUserEvent][eEvent[ID]] == FINISHED ? "MENU_FINISHED" : "MENU_NO_TEXT", eEvent[DESCRIPTION],
            "JOINED_PLAYERS", eEvent[JOINED_PLAYERS], "END_TIME", eEvent[END_DAY], eEvent[END_HOUR], calculatePercentage(id, eEvent[ID], eEvent[EVENT_TOTAL_SCORE]));
            num_to_str(eEvent[ID], szParseData, charsmax(szParseData));
            menu_additem(iMenu, szItem, szParseData);
            iCount++;
        }
    }

    if(iCount == 0)
    {
        formatex(szItem, charsmax(szItem), "\d%l", "MENU_NO_ITEMS");
        menu_additem(iMenu, szItem, "NO_ITEMS");
    }

    menu_setprop(iMenu, MPROP_EXITNAME, EXITNAME);
    menu_setprop(iMenu, MPROP_BACKNAME, BACKNAME);
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
    menu_setprop(iMenu, MPROP_PERPAGE, MENU_ITEMS_PER_PAGE);
    menu_setprop(iMenu, MPROP_SHOWPAGE, false);

    if(is_user_connected(id))
        menu_display(id, iMenu, page, -1);
}

public running_events_handler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        open_menu(id);
        return PLUGIN_HANDLED;
    }

    new szData[15];
    menu_item_getinfo(menu, item, _, szData, charsmax(szData), _, _, _);

    if(equal(szData, "NO_ITEMS"))
    {
        menu_destroy(menu);
        open_running_events_menu(id, 0);
        return PLUGIN_HANDLED
    }

    new iEventID = str_to_num(szData);

    if(!CheckIfEventExists(iEventID))
    {
        log_to_file(LOG_FILE, "Invalid event ID: %i", iEventID);
        return PLUGIN_HANDLED;
    }

    switch(iEventID)
    {
        case -MAX_EVENTS..(MAX_EVENTS+1):
        {
            static eEvent[EVDATA]; eEvent[ID] = iEventID;
         
            ArrayGetArray(g_aEvents, ArrayFindArray(g_aEvents, eEvent), eEvent);

            if(g_eUserData[id][iUserEvent][eEvent[ID]] == JOINED || g_eUserData[id][iUserEvent][eEvent[ID]] == FINISHED)
            {
                menu_destroy(menu);
                new iPage, iTemp;
                player_menu_info(id, iTemp, menu, iPage);
                ShowJoinedPlayersMenu(id, iPage, eEvent);
                return PLUGIN_HANDLED;
            }

            if(getEventType(eEvent[EVENT_TYPE]) == TYPE_HOURS)
                startUserHoursTask(id);

            g_eUserData[id][iTotalJoinedEvents]++;
            g_eUserData[id][iUserEvent][eEvent[ID]] = JOINED;
            g_eUserData[id][iEventScore][eEvent[ID]] = 0;
            eEvent[JOINED_PLAYERS]++;
            ArraySetArray(g_aEvents, ArrayFindArray(g_aEvents, eEvent), eEvent);
            client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "JOINED_EVENT", eEvent[EVENT_NAME], EventDifficultyChat(eEvent[DIFFICULTY]), eEvent[START_DAY], eEvent[START_HOUR], eEvent[END_DAY], eEvent[END_HOUR]);
            SaveEventPlayers(eEvent, g_eUserData[id]);
            ManipulatePlayerData(id, eEvent[ID], SAVE_DATA);
            open_running_events_menu(id, 0);
        }

        default:
        {
            log_to_file(LOG_FILE, "Invalid running events (ID: %i) item menu", iEventID);
            menu_destroy(menu);
            return PLUGIN_HANDLED;
        }
    }

    return PLUGIN_HANDLED;
}

ShowJoinedPlayersMenu(const id, const iPage, eEvent[EVDATA])
{
    new szTitle[64], szItem[64], szParseData[10];
    static szData[MAX_NAME_LENGTH * 500];
    formatex(szTitle, charsmax(szTitle), "%s %l \d", MENU_PREFIX, "MENU_TITLE_JOINED_PLAYERS", eEvent[EVENT_NAME])
    new iMenu = menu_create(szTitle, "joined_players_handler");
    formatex(szParseData, charsmax(szParseData), "%i %i", eEvent[ID], iPage);
    copy(szData, charsmax(szData), eEvent[JPLAYERS_NAME]);

    if(!eEvent[JPLAYERS_NAME][0])
    {
        formatex(szItem, charsmax(szItem), "%l", "MENU_NO_PLAYERS");
        menu_additem(iMenu, szItem, szParseData);
    }

    if(containi(szData, ",") != -1)
    {
        new i;
        while(strtok2(szData, szItem, charsmax(szItem), szData, charsmax(szData), ',') && i < eEvent[JOINED_PLAYERS])
        {
            menu_additem(iMenu, szItem, szParseData);
            i++
        }
    } else menu_additem(iMenu, szData, szParseData);

    menu_setprop(iMenu, MPROP_EXITNAME, EXITNAME);
    menu_setprop(iMenu, MPROP_BACKNAME, BACKNAME);
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);

    if(is_user_connected(id))
        menu_display(id, iMenu, 0, -1);

}

ManipulatePlayerData(const id, const iEventID, const iType)
{
    new szKey[MAX_KEY_LENGTH], szSecondKey[MAX_KEY_LENGTH], szData[MAX_EVENTS], iTs, szPassData[64];
    formatex(szKey, charsmax(szKey), "%s_%i_JEVENTS", g_eUserData[id][szName], iEventID);
    CheckPlayerKey(szKey, charsmax(szKey), (iType == SAVE_DATA) ? 0 : 1);

    switch(iType)
    {
        case SAVE_DATA:
        {
            formatex(szSecondKey, charsmax(szSecondKey), "%s_EVENTSDATA", g_eUserData[id][szName]);
            formatex(szPassData, charsmax(szPassData), "^"%i^" ^"%i^"", g_eUserData[id][iTotalJoinedEvents], g_eUserData[id][iTotalWinEvents]);
            nvault_set(g_PlayersnVault, szSecondKey, szPassData);
            
            formatex(szKey, charsmax(szKey), "%s_%i_JEVENTS", g_eUserData[id][szName], iEventID);

            if(!CheckIfEventExists(iEventID) )
            {
                nvault_remove(g_PlayersnVault, szKey);   
                return PLUGIN_HANDLED;
            }

            if(g_eUserData[id][iUserEvent][iEventID] == JOINED)
            {
                num_to_str(g_eUserData[id][iEventScore][iEventID], szPassData, charsmax(szPassData));
                nvault_set(g_PlayersnVault, szKey, szPassData);
            }
            else if(g_eUserData[id][iUserEvent][iEventID] == FINISHED)
            {
                num_to_str(FINISHED, szPassData, charsmax(szPassData));
                nvault_set(g_PlayersnVault, szKey, szPassData);
            }
        }

        case GET_DATA: 
        {
            if(nvault_lookup(g_PlayersnVault, szKey, szData, charsmax(szData), iTs))
            {
                new iSavedData = str_to_num(szData);
                switch(iSavedData)
                {
                    case FINISHED:
                    {   
                        static eEvent[EVDATA];

                        for(new i; i < ArraySize(g_aEvents); i++)
                        {
                            ArrayGetArray(g_aEvents, i, eEvent);
                        
                            if(eEvent[ID] == iEventID)
                            {        
                                if(eEvent[STATE] == ENDED_STATE)    nvault_remove(g_PlayersnVault, szKey);
                                else                                g_eUserData[id][iUserEvent][iEventID] = FINISHED;
                                break;
                            }
                        }                                
                    }

                    default:
                    {
                        g_eUserData[id][iUserEvent][iEventID]    =   JOINED;
                        g_eUserData[id][iEventScore][iEventID]   =   iSavedData;

                        static eEvent[EVDATA];
                        eEvent[ID] = iEventID;

                        if(CheckIfEventExists(eEvent[ID]))
                        {
                            ArrayGetArray(g_aEvents, ArrayFindArray(g_aEvents, eEvent), eEvent);

                            if(eEvent[STATE] == ENDED_STATE)
                            {
                                nvault_remove(g_PlayersnVault, szKey);
                            }

                            if(getEventType(eEvent[EVENT_TYPE]) == TYPE_HOURS && eEvent[STATE] == STARTED_STATE)
                            {
                                startUserHoursTask(id);
                            }
                        } else nvault_remove(g_PlayersnVault, szKey);
                    }
                }
            }

            formatex(szSecondKey, charsmax(szSecondKey), "%s_EVENTSDATA", g_eUserData[id][szName]);

            if(nvault_lookup(g_PlayersnVault, szSecondKey, szData, charsmax(szData), iTs))
            {
                new szTemp[2][15];
                parse(szData, szTemp[0], charsmax(szTemp[]), szTemp[1], charsmax(szTemp[]));
                g_eUserData[id][iTotalJoinedEvents]     = str_to_num(szTemp[0]);
                g_eUserData[id][iTotalWinEvents]        = str_to_num(szTemp[1]);
            }
        }
    }

    return PLUGIN_CONTINUE;
}

startUserHoursTask(id)
{
    set_task(1.0, "addPlayerTime", id + HOURS_TASK, .flags = "b");
}

public addPlayerTime(id)
{
    id -= HOURS_TASK;
    static eEvent[EVDATA];

    for(new i; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvent);

        if(getEventType(eEvent[EVENT_TYPE]) == TYPE_HOURS && g_eUserData[id][iUserEvent][eEvent[ID]] == JOINED && eEvent[STATE] == STARTED_STATE)
        {
            g_eUserData[id][iEventScore][eEvent[ID]]++;
            if(g_eUserData[id][iEventScore][eEvent[ID]] >= eEvent[EVENT_TOTAL_SCORE])
            {
                giveBonus(id, eEvent[BONUS_TYPE], eEvent[BONUS_AMOUNT], eEvent[EVENT_NAME]);
                g_eUserData[id][iUserEvent][eEvent[ID]]     =   FINISHED;
                g_eUserData[id][iEventScore][eEvent[ID]]    =   NO_SCORE;
                remove_task(id + HOURS_TASK);
                ManipulatePlayerData(id, eEvent[ID], SAVE_DATA);
            }
        }
    }
    
    return PLUGIN_CONTINUE;
}

stock CheckPlayerKey(szKey[], iLen, iType)
{
    switch(iType)
    {
        case 0: replace_all(szKey, iLen, ",", "{3!3]");
        case 1: replace_all(szKey, iLen, "{3!3]", ",");
    }
}

public joined_players_handler(id, menu, item)
{
    new szData[10];
    menu_item_getinfo(menu, item, _, szData, charsmax(szData), _, _);

    new szEventID[5], szPage[5], szCheck[10];
    parse(szData, szEventID, charsmax(szEventID), szPage, charsmax(szPage), szCheck, charsmax(szCheck));

    new iPage = str_to_num(szPage);

    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        open_running_events_menu(id, iPage);
        return PLUGIN_HANDLED;
    }

    new iEventID = str_to_num(szEventID);
    static eEvent[EVDATA];
    
    for(new i; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvent);
        
        if(eEvent[ID] == iEventID)
            break
    }

    ShowJoinedPlayersMenu(id, iPage, eEvent);

    return PLUGIN_HANDLED;
}

stock bool:CheckIfEventExists(const iEventID)
{
    static eEvent[EVDATA];
    eEvent[ID] = iEventID;

    if(ArrayFindArray(g_aEvents, eEvent) == -1)
        return false;
    else
        return true;
}

GetRunningEvents()
{
    new iCount;
    static eEvents[EVDATA];

    for(new i = 0; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvents);

        if(eEvents[STATE] == STARTED_STATE)
            iCount++
    }

    return iCount;
}

GetEndedEvents()
{
    new iCount;
    static eEvents[EVDATA];

    for(new i = 0; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvents);

        if(eEvents[STATE] == ENDED_STATE)
            iCount++
    }

    return iCount;
}

GetUpcomingEvents()
{
    new iCount;
    static eEvents[EVDATA];

    for(new i = 0; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvents);

        if(eEvents[STATE] == NO_STATE)
            iCount++
    }

    return iCount;
}

/////////////////////////////
////////// EVENTS //////////
////////////////////////////

public playerKilledPost(id, attacker)
{
    if(is_user_connected(attacker) && is_user_logged(attacker) && (id != attacker))
    {
        checkUserEvents(attacker);
    }
}

checkUserEvents(id)
{
    static eEvent[EVDATA];
    for(new i; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvent);

        if(CheckIfEventExists(eEvent[ID]) && g_eUserData[id][iUserEvent][eEvent[ID]] == JOINED)
        {
            static iEventType;
            iEventType = getEventType(eEvent[EVENT_TYPE]);
            if(iEventType != -1 && iEventType == TYPE_KILLS)
            {
                g_eUserData[id][iEventScore][eEvent[ID]]++;

                if(g_eUserData[id][iEventScore][eEvent[ID]] >= eEvent[EVENT_TOTAL_SCORE])
                {
                    g_eUserData[id][iUserEvent][eEvent[ID]] = FINISHED;
                    giveBonus(id, eEvent[BONUS_TYPE], eEvent[BONUS_AMOUNT], eEvent[EVENT_NAME]);
                }

                ManipulatePlayerData(id, eEvent[ID], SAVE_DATA);
            }
        }
    }
}

giveBonus(const id, const iBonusType[], const iBonusAmount, const eEventName[])
{
    new szUserName[MAX_NAME_LENGTH];
    get_user_name(id, szUserName, charsmax(szUserName));
    client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "FINISHED_EVENT_CHAT", szUserName, eEventName);

    g_eUserData[id][iTotalWinEvents]++;

    if(is_user_logged(id) && is_user_connected(id))
    {
        switch(str_to_num(iBonusType))
        {
            case TYPE_MONEY:
            {
                set_user_money(id, get_user_money(id) + iBonusAmount);
                client_print_color(id, print_team_default, "%s %l $", CHAT_PREFIX, "GIVE_BONUS_CHAT", iBonusAmount);
            }

            case TYPE_SKIN_CASES:
            {
                set_user_cases(id, get_user_cases(id) + iBonusAmount);
                client_print_color(id, print_team_default, "%s %l cases", CHAT_PREFIX, "GIVE_BONUS_CHAT", iBonusAmount);
            }
            
            case TYPE_KEYS:
            {
                set_user_keys(id, get_user_keys(id) + iBonusAmount);
                client_print_color(id, print_team_default, "%s %l keys", CHAT_PREFIX, "GIVE_BONUS_CHAT", iBonusAmount);
            }

            case TYPE_SCRAPS:
            {
                set_user_scraps(id, get_user_scraps(id) + iBonusAmount);
                client_print_color(id, print_team_default, "%s %l dusts", CHAT_PREFIX, "GIVE_BONUS_CHAT", iBonusAmount);
            }
        }
    }
}



public displayEventsCmd(id, level, cid)
{
    if(!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    new iSize = ArraySize(g_aEvents);

    if(iSize == 0)
        client_print(id, print_console, "%s %l", CONSOLE_PREFIX, "ZERO_EVENTS");
    else 
    {
        static eEvent[EVDATA];

        client_print(id, print_console, "^n---------%s---------^n", CONSOLE_PREFIX);

        for(new i; i < iSize; i++)
        {
            ArrayGetArray(g_aEvents, i, eEvent)

            client_print(id, print_console, "[%s] [ID: %i] Name: %s; BonusType: %s; Amount: %i; Start: %s at %s:00; End: %s at %s:00",
            EventStateString(eEvent[STATE]), eEvent[ID], eEvent[EVENT_NAME],
            EventBonusType(eEvent[BONUS_TYPE]),
            eEvent[BONUS_AMOUNT],
            eEvent[START_DAY],
            eEvent[START_HOUR],
            eEvent[END_DAY],
            eEvent[END_HOUR])
        }
        client_print(id, print_console, "^n---------%s---------^n", CONSOLE_PREFIX);
    }

    return PLUGIN_HANDLED;
}

public ReadEvents()
{
    server_print("[CSGO CLASSY EVENTS] Reading events from config file...");
    g_aEvents = ArrayCreate(EVDATA);

    new szConfigDir[64], szFile[128], szCSGODir[64], iFile;
    get_configsdir(szConfigDir, charsmax(szConfigDir));

    csgo_directory(szCSGODir, charsmax(szCSGODir))

    formatex(szFile, charsmax(szFile), "%s/%s/%s", szConfigDir, szCSGODir, CONFIG_FILE);

    new szDiff[7];
    static eEvent[EVDATA];

    if(file_exists(szFile))
    {
        new szData[512], szBonusAmount[15], szID[11], i, szEnabled[4], szDescription[256], szEventTotal[11];

        iFile = fopen(szFile, "r");

        while(fgets(iFile, szData, charsmax(szData)))
        {
            trim(szData);

            if(!szData[0] || szData[0] == '#' || szData[0] == ';')
                continue;

            parse(szData,
            szID, charsmax(szID),
            szEnabled, charsmax(szEnabled),
            szDiff, charsmax(szDiff),
            eEvent[EVENT_NAME], charsmax(eEvent[EVENT_NAME]),
            eEvent[EVENT_TYPE], charsmax(eEvent[EVENT_TYPE]),
            szEventTotal, charsmax(szEventTotal),
            eEvent[BONUS_TYPE], charsmax(eEvent[BONUS_TYPE]),
            szBonusAmount, charsmax(szBonusAmount),
            eEvent[START_DAY], charsmax(eEvent[START_DAY]),
            eEvent[END_DAY], charsmax(eEvent[END_DAY]),
            eEvent[START_HOUR], charsmax(eEvent[START_HOUR]),
            eEvent[END_HOUR], charsmax(eEvent[END_HOUR]),
            szDescription, charsmax(szDescription));

            eEvent[EVENT_TOTAL_SCORE] = str_to_num(szEventTotal);
            eEvent[ID] = str_to_num(szID);

            if(eEvent[ID] >= MAX_EVENTS - 1)
            {
                log_to_file(LOG_FILE, "Invalid event ID: %i. Must be lower than %i", eEvent[ID], MAX_EVENTS - 1);
                continue;
            }           

            if(strlen(szDescription) > MAX_DESCRIPTION_LENGTH)
            {
                log_to_file(LOG_FILE, "Description of event ID: %i is too long! Max length: %i", eEvent[ID], MAX_DESCRIPTION_LENGTH);
                formatex(eEvent[DESCRIPTION], charsmax(eEvent[DESCRIPTION]), "\dDescription of this must be changed^nbecause exceed max number of characters");
            } else copy(eEvent[DESCRIPTION], charsmax(eEvent[DESCRIPTION]), szDescription);

            g_bCheckEventsID[eEvent[ID]] = true;

            if(equali(szDiff, "easy")){ eEvent[DIFFICULTY] = EASY;} else if(equali(szDiff, "medium")){ eEvent[DIFFICULTY] = MEDIUM;} else if(equali(szDiff, "hard")){ eEvent[DIFFICULTY] = HARD;} else{ log_to_file(LOG_FILE, "%l", "DIFFICULTY_ERROR", eEvent[EVENT_NAME]); continue;}
            
            eEvent[BONUS_AMOUNT] = str_to_num(szBonusAmount);
            eEvent[STATE] = str_to_num(szEnabled) == 1 ? NO_STATE : DISABLED_STATE;
            eEvent[ENABLED] = bool:str_to_num(szEnabled);

            if(equali(eEvent[START_DAY], eEvent[END_DAY]))
                eEvent[ONEDAY] = true;

            ArrayPushArray(g_aEvents, eEvent);

            i++

            if(i == MAX_EVENTS)
            {
                log_to_file(LOG_FILE, "Max number of events has been reached! Maximum events %i", MAX_EVENTS - 1);
                break;
            }
        }
        //set_task(10.0, "DeleteChacheUnusedIDS", UNUSED_IDS_TASK);
        set_task(EVENTS_CHECKING_FLOAT, "StartEventsChecking", START_EVENT_CHECKING_TASK, .flags = "b");
        StartEventsChecking(-1);
    } else log_to_file(LOG_FILE, "%s File ^"%s^" does not exists", CONSOLE_PREFIX, szFile);
}

public StartEventsChecking(TASK_ID)
{
    if(TASK_ID == -1) { server_print("[CSGO CLASSY EVENTS] Checking events state..."); }
    static eEvent[EVDATA];

    for(new i; i < ArraySize(g_aEvents); i++)
    {
        ArrayGetArray(g_aEvents, i, eEvent);

        if(eEvent[ENABLED])
        {
            CheckEventsState(eEvent);
        }
    }

    if(TASK_ID == -1) { server_print("[CSGO CLASSY EVENTS] Events state has been updated!"); }
}

public CheckEventsState(eEvent[EVDATA])
{
    static szKey[15], szData[64], iTs;
    num_to_str(eEvent[ID], szKey, charsmax(szKey));

    if(nvault_lookup(g_EventsnVault, szKey, szData, charsmax(szData), iTs))
    {
        if(strlen(szData) > 5)
        {
            static szState[5], szTemp[1];
            parse(szData, szState, charsmax(szState), szTemp, charsmax(szTemp));
            eEvent[STATE] = str_to_num(szState);
        }
        else eEvent[STATE] = str_to_num(szData)
        
        #if defined DEBUG_MODE
        server_print("Event with id [%i] has been found in events vault file", eEvent[ID])
        #endif

        if(!CheckIfEventShouldStart(eEvent, szData) && eEvent[STATE] == ENDED_STATE)
        {
            eEvent[STATE] = ENDED_STATE;
            #if defined DEBUG_MODE
                server_print("[CSGO CLASSY EVENTS] One day event with id [%i] state has been changed in END state.", eEvent[ID]);
            #endif
            ArraySetArray(g_aEvents, ArrayFindArray(g_aEvents, eEvent), eEvent);
            return PLUGIN_HANDLED;
        }

        ArraySetArray(g_aEvents, ArrayFindArray(g_aEvents, eEvent), eEvent);

        switch(eEvent[STATE])
        {
            case STARTED_STATE: CheckIfEventEnd(eEvent);
            case ENDED_STATE: CheckIfEventStart(eEvent);
        }
    }
    else
    {
        if(eEvent[STATE] == NO_STATE)
        {
            eEvent[STATE] = EventState(eEvent);

            if(eEvent[STATE] == STARTED_STATE)
            {
                SaveEventState(eEvent);
                AnnounceEvent(eEvent, NEW);
            }
        }
        else
        {
            log_to_file(LOG_FILE, "Error in adding event with ID %i in nvault list. Current state: %s", eEvent[ID], EventStateString(eEvent[STATE]));
        }
    }
    
    return PLUGIN_CONTINUE;
}

GetEventPlayers(eEvent[EVDATA])
{
    new szKey[15], iTs;
    static szData[MAX_NAME_LENGTH * 500];

    formatex(szKey, charsmax(szKey), "%i_PLAYERS", eEvent[ID]);
    if(nvault_lookup(g_EventsnVault, szKey, szData, charsmax(szData), iTs))
    {
        copy(eEvent[JPLAYERS_NAME], charsmax(eEvent[JPLAYERS_NAME]), szData);
    }

    formatex(szKey, charsmax(szKey), "%i_PLAYERSN", eEvent[ID]);
    if(nvault_lookup(g_EventsnVault, szKey, szData, charsmax(szData), iTs))
    {
        eEvent[JOINED_PLAYERS] = str_to_num(szData);
    }

    ArraySetArray(g_aEvents, ArrayFindArray(g_aEvents, eEvent), eEvent);
}

stock bool:CheckIfEventShouldStart(const eEvent[EVDATA], const szData[])
{
    if(strlen(szData) > MIN_ONEDAY_LENGTH && eEvent[ONEDAY])
    {
        new szEventState[4], szParseData[15];
    
        parse(szData, szEventState, charsmax(szEventState), szParseData, charsmax(szParseData));

        new iTime = str_to_num(szParseData);

        if(iTime <= get_systime())
            return true;
        else return false; 
    }

    return true;
}

public SaveEventState(eEvent[EVDATA])
{
    static szKey[10], szData[64];

    num_to_str(eEvent[ID], szKey, charsmax(szKey));

    if(eEvent[STATE] == ENDED_STATE && eEvent[ONEDAY])
        formatex(szData, charsmax(szData), "^"%i^" ^"%i^"", eEvent[STATE], get_systime(DAY_IN_SEC));
    else 
        num_to_str(eEvent[STATE], szData, charsmax(szData));

    nvault_set(g_EventsnVault, szKey, szData);

    ArraySetArray(g_aEvents, ArrayFindArray(g_aEvents, eEvent), eEvent);
}

public SaveEventPlayers(eEvent[EVDATA], const eUserData[USERDATA])
{
    new szUserNameTemp[MAX_NAME_LENGTH];
    if(containi(eUserData[szName], ",") != -1)
    {
        copy(szUserNameTemp, charsmax(szUserNameTemp), eUserData[szName]);
        replace_all(szUserNameTemp, charsmax(szUserNameTemp), ",", ".");
    } else copy(szUserNameTemp, charsmax(szUserNameTemp), eUserData[szName]);

    if(eEvent[JPLAYERS_NAME][0])
    {
        format(eEvent[JPLAYERS_NAME], charsmax(eEvent[JPLAYERS_NAME]), "%s,%s", eEvent[JPLAYERS_NAME], szUserNameTemp);
    } else formatex(eEvent[JPLAYERS_NAME], charsmax(eEvent[JPLAYERS_NAME]), "%s", szUserNameTemp);

    new szKey[15];
    formatex(szKey, charsmax(szKey), "%i_PLAYERS", eEvent[ID]);
    nvault_set(g_EventsnVault, szKey, eEvent[JPLAYERS_NAME]);

    new szData[10];
    formatex(szKey, charsmax(szKey), "%i_PLAYERSN", eEvent[ID]);
    num_to_str(eEvent[JOINED_PLAYERS], szData, charsmax(szData));
    nvault_set(g_EventsnVault, szKey, szData);

    ArraySetArray(g_aEvents, ArrayFindArray(g_aEvents, eEvent), eEvent);
}

stock EventState(eEvent[EVDATA])
{
    if(!eEvent[ENABLED])
        return DISABLED_STATE;

    static szTime[17], szCurrDay[9], szCurrHour[3];
    get_time("%A/%H", szTime, charsmax(szTime))

    strtok2(szTime, szCurrDay, charsmax(szCurrDay), szCurrHour, charsmax(szCurrHour), '/');

    if(equali(szCurrDay, eEvent[END_DAY]) && (eEvent[STATE] == STARTED_STATE))
    {
        if(str_to_num(szCurrHour) >= str_to_num(eEvent[END_HOUR]))
            return ENDED_STATE;
    }

    if(equali(szCurrDay, eEvent[START_DAY]) && (eEvent[STATE] == NO_STATE || eEvent[STATE] == ENDED_STATE))
    {
        if(str_to_num(szCurrHour) >= str_to_num(eEvent[START_HOUR]))
            return STARTED_STATE;
    }

    return NO_STATE;
}

CheckIfEventEnd(eEvent[EVDATA])
{
    new iEventState = EventState(eEvent);

    if(iEventState == ENDED_STATE && eEvent[STATE] == STARTED_STATE)
    {
        eEvent[STATE] = iEventState;
        AnnounceEvent(eEvent, END);
        ArraySetArray(g_aEvents, ArrayFindArray(g_aEvents, eEvent), eEvent);
        SaveEventState(eEvent);
        static szData[MAX_NAME_LENGTH * 500];
        new i, szUserName[MAX_NAME_LENGTH], iTs, szKey[MAX_KEY_LENGTH], szData2[1];
        while(strtok2(szData, szUserName, charsmax(szUserName), szData, charsmax(szData), ',') && i <= eEvent[JOINED_PLAYERS] && szData[0])
        {
            formatex(szKey, charsmax(szKey), "%s_%i_JEVENTS", szUserName, eEvent[ID]);

            if(nvault_lookup(g_PlayersnVault, szKey, szData2, charsmax(szData2), iTs))
            {
                nvault_remove(g_PlayersnVault, szKey);
                #if defined DEBUG_MODE
                    log_to_file(LOG_FILE, "nVault key ^"%s^" has been deleted for event with id [%i]", szKey, eEvent[ID]);
                #endif
            }
            else 
            {
                replace_all(szUserName, charsmax(szUserName), ".", ",");
                formatex(szKey, charsmax(szKey), "%s_%i_JEVENTS", szUserName, eEvent[ID]);
                CheckPlayerKey(szKey, charsmax(szKey), GET_DATA);

                if(nvault_lookup(g_PlayersnVault, szKey, szData2, charsmax(szData2), iTs))
                {
                    nvault_remove(g_PlayersnVault, szKey);
                    #if defined DEBUG_MODE
                        log_to_file(LOG_FILE, "nVault key ^"%s^" has been deleted for event with id [%i]", szKey, eEvent[ID]);
                    #endif
                } else log_to_file("nVault key ^"%s^" has not been found", szKey);
            }
        }
    }
    
    if(!eEvent[JPLAYERS_NAME][0])
        GetEventPlayers(eEvent);
}

CheckIfEventStart(eEvent[EVDATA])
{
    new iEventState = EventState(eEvent);

    if(iEventState == STARTED_STATE && eEvent[STATE] == ENDED_STATE)
    {
        eEvent[STATE] = iEventState
        AnnounceEvent(eEvent, START);
        ArraySetArray(g_aEvents, ArrayFindArray(g_aEvents, eEvent), eEvent);
        SaveEventState(eEvent);
    }
}

public AnnounceEvent(const eEvent[EVDATA], iType)
{
    new szMessage[256];
    switch(iType)
    {
        case NEW:       formatex(szMessage, charsmax(szMessage), "%s %l", CHAT_PREFIX, "NEW_EVENT_STARTED", eEvent[EVENT_NAME], EventDifficultyChat(eEvent[DIFFICULTY]));
        case START:     formatex(szMessage, charsmax(szMessage), "%s %l", CHAT_PREFIX, "EVENT_START", eEvent[EVENT_NAME]);
        case END:       formatex(szMessage, charsmax(szMessage), "%s %l", CHAT_PREFIX, "EVENT_END", eEvent[EVENT_NAME]);
    }

    set_task(15.0, "SendMessage", SEND_MESSAGE_TASK, szMessage, charsmax(szMessage));
}

public SendMessage(szMessage[], taskid)
{
    client_print_color(0, print_team_default, "%s", szMessage);
}

stock EventBonusType(const iBonus[])
{
    new szString[25];
    new iLen = charsmax(szString);

    switch(str_to_num(iBonus))
    {
        case TYPE_MONEY:                    formatex(szString, iLen, "Money");
        case TYPE_KEYS:                     formatex(szString, iLen, "Keys");
        case TYPE_SKIN_CASES:               formatex(szString, iLen, "Cases");
        case TYPE_SCRAPS:                   formatex(szString, iLen, "Scraps");
        // case TYPE_NAMETAG_CAPSULE:          formatex(szString, iLen, "Nametag Capsule");
        // case TYPE_COMMON:                   formatex(szString, iLen, "Common Nametag");
        // case TYPE_RARE:                     formatex(szString, iLen, "Rare Nametag");
        // case TYPE_MYTHIC:                   formatex(szString, iLen, "Mythic Nametag");
        // case TYPE_MULTIPLE_NAMETAGS:        formatex(szString, iLen, "Nametags:");
        // case TYPE_GLOVE_CASES:              formatex(szString, iLen, "Glove Cases");
        // case TYPE_GLOVE_ID:                 formatex(szString, iLen, "Glove");
        // case TYPE_MULTIPLE_SKINS:           formatex(szString, iLen, "Skins:");
    }

    return szString;
}

stock EventDifficultyMenu(const iDifficulty)
{
    new szString[25];
    new iLen = charsmax(szString);

    switch(iDifficulty)
    {
        case EASY:      formatex(szString, iLen, "%l", "CSGO_MENU_EASY");
        case MEDIUM:    formatex(szString, iLen, "%l", "CSGO_MENU_MEDIUM");
        case HARD:      formatex(szString, iLen, "%l", "CSGO_MENU_HARD");
    }

    return szString;
}

stock EventDifficultyChat(const iDifficulty)
{
    new szString[32];
    new iLen = charsmax(szString);

    switch(iDifficulty)
    {
        case EASY:      formatex(szString, iLen, "%l", "CSGO_CHAT_EASY");
        case MEDIUM:    formatex(szString, iLen, "%l", "CSGO_CHAT_MEDIUM");
        case HARD:      formatex(szString, iLen, "%l", "CSGO_CHAT_HARD");
    }

    return szString;
}

stock EventStateString(iState)
{
    new szString[10]
    new iLen = charsmax(szString);

    switch(iState)
    {
        case NO_STATE:          formatex(szString, iLen, "NOT STARTED");
        case STARTED_STATE:     formatex(szString, iLen, "RUNNING");
        case ENDED_STATE:       formatex(szString, iLen, "ENDED");
        case DISABLED_STATE:    formatex(szString, iLen, "DISABLED");
    }

    return szString;
}

stock ArrayFindArray(Array:aArray, eEvent[EVDATA])
{
    new bool:Found, i;
    static szTemp[EVDATA];
    for(i = 0; i < ArraySize(aArray); i++)
    {
        ArrayGetArray(aArray, i, szTemp);

        if(szTemp[ID] == eEvent[ID])
        {
            Found = true;
            break;
        }
    }

    if(Found)
    {
        return i;
    }

    return -1;
}

stock bool:JoinedEvent(const id ,const iEventID)
{
    if(g_eUserData[id][bJoinedEvents][iEventID])
        return true;

    return false;
}

stock getEventType(const iEventType[])
{
    return containi(g_szAlphabet, iEventType);
}


calculatePercentage(const id, const iEventID, const iCurrentEventScore)
{
    new szString[64];

    if(g_eUserData[id][iUserEvent][iEventID] == NOT_JOINED || g_eUserData[id][iUserEvent][iEventID] == FINISHED) return szString;

    new Float:percent = floatdiv(floatmul(100.0, float(g_eUserData[id][iEventScore][iEventID])), float(iCurrentEventScore));

    formatex(szString, charsmax(szString), "%l", "MENU_PERCENTAGE", percent, "%");
    return szString;
}