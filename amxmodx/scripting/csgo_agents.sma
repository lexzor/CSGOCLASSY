#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <hamsandwich>
#include <nvault>
#include <reapi>
#include <csgoclassy>

#define PLUGIN "CSGO Agents"
#define VERSION "1.6"
#define AUTHOR "lexzor"

#define MAX_SKINS 100
#define NON_USED_SKIN 300

new const PREVIEW_MENU[]				=				"PREVIEW_MENU";
new const MODELS_COUNTER[]				=				"MODELS_COUNTER";
new const VIP_FLAG[]					=				"VIP_FLAG";


//////////
//CONFIG//
//////////
new const g_szFileName[] = "csgo_agents.cfg";
new const g_szMOTDFolder[] = "csgo_agents_motd";
new g_szFile[124];
new const g_szFileInfo[][] =
{
	"#Skinul pentru echipele Terrorists si Counter-Terrorists trebuie puse la sectiunea respectiva.^n",
	"#Model: ^"Nume Skin^", ^"Nume model (fara .mdl)^", ^"Nume fisier preview (cu .html)^", ^"ONLY VIP (1/0)^" ^"Pret^"^n",
	"#In cazul in care nu doriti preview la skin scrieti in ghilimelele unde ar trebui sa fie numele fisierului ^"NOPREVIEW^".^n",
	"#Skinurile fiecarui player se salveaza pe nume.^n^n^n",

	"[SETTINGS]^n^n",
	"PREVIEW_MENU = 1 #Meniul pentru preview (0/1)^n",
	"MODELS_COUNTER = 1  #Textul din meniu care arata cate modele sunt.^n",
	"VIP_FLAG = t #Flag-ul VIP.^n^n^n",

	"[Terrorists]^n^n^n",
	"[Counter-Terrorists]^n^n^n"
};

////////
//ENUM//
////////
enum _:TEROR
{
	szTModelName[64],
	szTModelLocation[64],
	szTModelPreview[64],
	szTSkin[64],
	iTVIPOnly,
	iTID
}

enum _:COUNTER_TERO
{
	szCTModelName[64],
	szCTModelLocation[64],
	szCTModelPreview[64],
	szCTSkin[25],
	iCTVIPOnly,
	iCTID
}

enum _:PREFERENCES
{
	MENU_PREVIEW,
	COUNTER_MODELS,
	FLAG_VIP[26]
}

enum
{ 
	SETTINGS = 1,
	TERRORISTS = 2,
	COUNTER_TERRORISTS = 3
}

enum _:TEAMS
{
	T,
	CT
}

//////////
//PLUGIN//
//////////
new g_szCSGODirectory[64]
new g_szChatTag[64]
new g_szMenuTag[64]
new g_TSkin[MAX_SKINS][TEROR];
new g_CTSkin[MAX_SKINS][COUNTER_TERO];
new g_iCounterTotalSkins;
new g_iTerorristTotalSkins;
new g_iPlayerSkin[MAX_PLAYERS + 1][TEAMS];
new g_iSettings[PREFERENCES];
new g_iTSkinPrice[MAX_SKINS];
new g_iCTSkinPrice[MAX_SKINS];
new g_iCTPlayerSkins[MAX_PLAYERS + 1][MAX_SKINS];
new g_iTPlayerSkins[MAX_PLAYERS + 1][MAX_SKINS];

new const g_szTnVaultName[] = "csgo_agents_t";
new g_TnVault;

new const g_szCTnVaultName[] = "csgo_agents_ct";
new g_CTnVault;

new const g_szSelectedSkinsnVaultName[] = "csgo_agents_selected";
new g_SelectedSkinsnVault;

new g_iMenuID;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_cvar("csgo_agents", VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY);
    RegisterHam(Ham_Spawn, "player", "player_spawn_post", 1);

    g_TnVault = nvault_open(g_szTnVaultName);
    g_CTnVault = nvault_open(g_szCTnVaultName);

    g_SelectedSkinsnVault = nvault_open(g_szSelectedSkinsnVaultName);

    if(g_TnVault == INVALID_HANDLE ||
        g_CTnVault == INVALID_HANDLE ||
            g_SelectedSkinsnVault == INVALID_HANDLE) {
        set_fail_state("[CSGO AGENTS] Error in opening nVault files!");
    }

    csgo_get_prefixes(g_szChatTag, charsmax(g_szChatTag), g_szMenuTag, charsmax(g_szMenuTag))

    g_iMenuID = csgo_register_menu(MenuCode:MENU_INVENTORY, "CSGO Agents")
}

public csgo_menu_item_selected(const id, const MenuCode:menu_code, const itemid)
{
    if(itemid != g_iMenuID || menu_code != MenuCode:MENU_INVENTORY)
    {
        return
    }
    agents_menu(id)

    return
}

updateInventoryValue(const id)
{
    new amount = 0
    getTotalPriceInventory(id, amount)
    csgo_add_inventory_item_value(id, g_iMenuID, amount)
}

stock getTotalPriceInventory(const id, &amount)
{
    for(new i = 0; i < g_iCounterTotalSkins; i++)
    {
        if(g_iCTPlayerSkins[id][i])
        {
            amount += g_iCTSkinPrice[i]
        }

    }
    for(new i = 0; i < g_iTerorristTotalSkins; i++)
    {
        if(g_iTPlayerSkins[id][i])
        {
            amount += g_iTSkinPrice[i]
        }
    }
}

public plugin_end()
{
    nvault_close(g_TnVault);
    nvault_close(g_CTnVault);
}

public plugin_precache()
{
    new szFileDirector[64], iFilePointer;

    csgo_directory(g_szCSGODirectory, charsmax(g_szCSGODirectory))

    get_configsdir(szFileDirector, charsmax(szFileDirector));
    formatex(g_szFile, charsmax(g_szFile), "%s/%s/%s", szFileDirector, g_szCSGODirectory,g_szFileName);
    
    new iFile = file_exists(g_szFile);

    if(!iFile)
    {
        iFilePointer = fopen(g_szFile, "w");
        new szFileData[512];
                
        for(new i; i < sizeof(g_szFileInfo); i++)
        {
            formatex(szFileData, charsmax(szFileData), "%s", g_szFileInfo[i]);
            fputs(iFilePointer, szFileData);
        }

        fclose(iFilePointer);

        server_print(" ");
        server_print("-----------------------------------------");
        server_print("[CSGO AGENTS] Config file has been created succesfully!");
        server_print("[CSGO AGENTS] First of all config the plugin in ^"csgo_agents.cfg^"");
        server_print("-----------------------------------------");
        server_print(" ");
    }

    if (iFile)
    {
        new szData[512];
        new szString[124];
        new szValue[124];
        new szParseData[5][64];
        new iSection;
        new i = 0;
        new z = 0;

        iFilePointer = fopen(g_szFile, "rt");

        while(fgets(iFilePointer, szData, charsmax(szData))) 
        {
            trim(szData);
            
            if(szData[0] == '#' || szData[0] == EOS || szData[0] == ';')
                continue;
                
            if(szData[0] == '[')
            {
                iSection += 1;
                continue;
            }

            switch(iSection)
            {
                case SETTINGS:
                {
                    if(szData[0] != '[')
                    {
                        strtok2(szData, szString, charsmax(szString), szValue, charsmax(szValue), '=', TRIM_INNER);
                        
                        if(szValue[0] == EOS || !szValue[0])
                            continue;
                        
                        if(equal(szString, PREVIEW_MENU))
                        {
                            g_iSettings[MENU_PREVIEW] = str_to_num(szValue); 
                        }

                        if(equal(szString, MODELS_COUNTER))
                        {
                            g_iSettings[COUNTER_MODELS] = str_to_num(szValue);
                        }

                        if(equal(szString, VIP_FLAG))
                        {
                            copy(g_iSettings[FLAG_VIP], charsmax(g_iSettings[FLAG_VIP]), szValue);
                        }
                    }
                }

                case TERRORISTS:
                {
                    if(szData[0] != '[')
                    {	
                        ++i;
                        parse(szData, szParseData[0], charsmax(szParseData[]), szParseData[1], charsmax(szParseData[]), szParseData[2], charsmax(szParseData[]), szParseData[3], charsmax(szParseData[]), szParseData[4], charsmax(szParseData[]));

                        copy(g_TSkin[i-1][szTModelName], charsmax(g_TSkin[][szTModelName]), szParseData[0]);
                        g_iTSkinPrice[i-1] = str_to_num(szParseData[4]);


                        formatex(g_TSkin[i-1][szTModelPreview], charsmax(g_TSkin[][szTModelPreview]), "%s/%s/%s/%s", szFileDirector, g_szCSGODirectory, g_szMOTDFolder, szParseData[2]);
                        formatex(g_TSkin[i-1][szTModelLocation], charsmax(g_TSkin[][szTModelLocation]), "models/player/%s/%s", szParseData[1], szParseData[1]);

                        g_TSkin[i-1][iTVIPOnly] = str_to_num(szParseData[3]);

                        if(g_TSkin[i-1][szTModelLocation][0] != EOS)
                            precache_player_model(g_TSkin[i-1][szTModelLocation]);
                    
                        copy(g_TSkin[i-1][szTModelLocation], charsmax(g_TSkin[][szTModelLocation]), szParseData[1])
                        //replace_all(g_TSkin[i-1][szTModelLocation], charsmax(g_TSkin[][szTModelLocation]), "/", " ");
                        //parse(g_TSkin[i-1][szTModelLocation], szParseData[0], charsmax(szParseData), szParseData[1], charsmax(szParseData), g_TSkin[i-1][szTSkin], charsmax(g_TSkin[][szTSkin]));

                        g_TSkin[i-1][iTID] = i-1;

                        formatex(g_TSkin[i-1][szTModelLocation], charsmax(g_TSkin[][szTModelLocation]), "%s", g_TSkin[i-1][szTModelLocation]);


                        ++g_iTerorristTotalSkins;
                    }
                }

                case COUNTER_TERRORISTS:
                {
                    if(szData[0] != '[')
                    {	
                        ++z;
                        parse(szData, szParseData[0], charsmax(szParseData[]), szParseData[1], charsmax(szParseData[]),  szParseData[2], charsmax(szParseData[]), szParseData[3], charsmax(szParseData[]), szParseData[4], charsmax(szParseData[]));

                        copy(g_CTSkin[z-1][szCTModelName], charsmax(g_CTSkin[][szCTModelName]), szParseData[0]);
                        g_iCTSkinPrice[z-1] = str_to_num(szParseData[4]);

                        formatex(g_CTSkin[z-1][szCTModelPreview], charsmax(g_CTSkin[][szCTModelPreview]), "%s/%s/%s/%s", szFileDirector, g_szCSGODirectory, g_szMOTDFolder, szParseData[2]);
                        formatex(g_CTSkin[z-1][szCTModelLocation], charsmax(g_CTSkin[][szCTModelLocation]), "models/player/%s/%s", szParseData[1], szParseData[1]);
                        formatex(g_CTSkin[z-1][szCTModelLocation], charsmax(g_CTSkin[][szCTModelLocation]), "models/player/%s/%s", szParseData[1], szParseData[1]);

                        g_CTSkin[z-1][iCTVIPOnly] = str_to_num(szParseData[3]);

                        if(g_CTSkin[z-1][szCTModelLocation][0] != EOS)
                            precache_player_model(g_CTSkin[z-1][szCTModelLocation]);
        
                        copy(g_CTSkin[z-1][szCTModelLocation], charsmax(g_CTSkin[][szCTModelLocation]), szParseData[1])
                        //replace_all(g_CTSkin[z-1][szCTModelLocation], charsmax(g_CTSkin[][szCTModelLocation]), "/", " ");
                        //parse(g_CTSkin[z-1][szCTModelLocation], szParseData[0], charsmax(szParseData[]), szParseData[0], charsmax(szParseData[]), g_CTSkin[z-1][szCTSkin], charsmax(g_CTSkin[][szCTSkin]));

                        g_CTSkin[z-1][iCTID] = z-1;

                        formatex(g_CTSkin[z-1][szCTModelLocation], charsmax(g_CTSkin[][szCTModelLocation]), "%s", g_CTSkin[z-1][szCTModelLocation]);

                        ++g_iCounterTotalSkins;
                    }
                }
            }
        }
    }
    fclose(iFilePointer);
}

public client_connect(id)
{
    if(!is_user_bot(id) && !is_user_hltv(id))
    {
        g_iPlayerSkin[id][T] = NON_USED_SKIN;
        g_iPlayerSkin[id][CT] = NON_USED_SKIN;
        
        for(new i; i < g_iTerorristTotalSkins; i++)
        {
            g_iTPlayerSkins[id][i] = 0
        }
        
        for(new i; i < g_iCounterTotalSkins; i++)
        {
            g_iCTPlayerSkins[id][i] = 0
        }
    }
}

public user_log_in_post(const id)
{
    _LoadData(id);
    updateInventoryValue(id)

    if(is_user_alive(id))
    {
        set_player_model_after_spawn(id)
    }

}

_SaveData(id)
{
    static szData[500];
    static szName[MAX_NAME_LENGTH];
    get_user_name(id, szName, charsmax(szName));

    formatex(szData, charsmax(szData), "%i", g_iCTPlayerSkins[id][0]);
    for(new i = 1; i < g_iCounterTotalSkins; i++)
    {
        format(szData, charsmax(szData), "%s,%i", szData, g_iCTPlayerSkins[id][i]);
    }
    nvault_set(g_CTnVault, szName, szData);

    formatex(szData, charsmax(szData), "%i", g_iTPlayerSkins[id][0]);
    for(new i = 1; i < g_iTerorristTotalSkins; i++)
    {
        format(szData, charsmax(szData), "%s,%i", szData, g_iTPlayerSkins[id][i]);
    }
    nvault_set(g_TnVault, szName, szData);

    formatex(szData, charsmax(szData), "%i %i", g_iPlayerSkin[id][T], g_iPlayerSkin[id][CT])
    nvault_set(g_SelectedSkinsnVault, szName, szData);
}

_LoadData(id)
{
    load_skins(id);
}

public load_skins(id)
{
    static szData[500], iTs;
    static szName[MAX_NAME_LENGTH];
    get_user_name(id, szName, charsmax(szName));

    if(nvault_lookup(g_TnVault, szName, szData, charsmax(szData), iTs))
    {
        new i = 0;
        new szSkinBuffer[5];
        while(i < g_iTerorristTotalSkins && szData[0] && strtok2(szData, szSkinBuffer, charsmax(szSkinBuffer), szData, charsmax(szData), ','))
        {
            g_iTPlayerSkins[id][i] = str_to_num(szSkinBuffer);
            i++
        }
    }

    if(nvault_lookup(g_CTnVault, szName, szData, charsmax(szData), iTs))
    {
        new i = 0;
        new szSkinBuffer[5];
        while(i < g_iCounterTotalSkins && szData[0] && strtok2(szData, szSkinBuffer, charsmax(szSkinBuffer), szData, charsmax(szData), ','))
        {
            g_iCTPlayerSkins[id][i] = str_to_num(szSkinBuffer);
            i++
        }
    }

    if(nvault_lookup(g_SelectedSkinsnVault, szName, szData, charsmax(szData), iTs))
    {
        new left[5], right[5];
        parse(szData, left, charsmax(left), right, charsmax(right))

        g_iPlayerSkin[id][T] = str_to_num(left);
        g_iPlayerSkin[id][CT] = str_to_num(right);
    }
}

/////////////////////////////////////////////// SQL ///////////////////////////////////////////////


/////////////////////////////////////////////// MENU ///////////////////////////////////////////////
public agents_menu(id)
{
    new iMenu = menu_create(fmt("%s Agents", g_szMenuTag), "agents_menu_handler");

    menu_additem(iMenu, "Terrorist Agents");
    menu_additem(iMenu, "Counter-Terrorists Agents");

    if(g_iSettings[MENU_PREVIEW] != 0)
    {
        menu_additem(iMenu, "Preview skins");
    }

    if(g_iSettings[COUNTER_MODELS] != 0)
    {
        new skinCounter[36];

        menu_addblank2(iMenu);

        if(g_iCounterTotalSkins != 0 && g_iTerorristTotalSkins != 0)
        {
            formatex(skinCounter, charsmax(skinCounter), "\dTerrorists Agents: %i", g_iTerorristTotalSkins);
            menu_addtext2(iMenu, skinCounter);

            formatex(skinCounter, charsmax(skinCounter), "\dCounter-Terrorists Agents: %i", g_iCounterTotalSkins);
            menu_addtext2(iMenu, skinCounter);

            formatex(skinCounter, charsmax(skinCounter), "\dTotal Agents: %i", g_iCounterTotalSkins + g_iTerorristTotalSkins);
            menu_addtext2(iMenu, skinCounter);
        }
        else
        {
            formatex(skinCounter, charsmax(skinCounter), "\dThere are no skins.");
            menu_addtext2(iMenu, skinCounter);
        }
    }

    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
    
    if(is_user_connected(id))
    {
        menu_display(id, iMenu, 0);
    }
    else 
    {
        menu_destroy(iMenu)
    }
}

public agents_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        display_menu(id, MenuCode:MENU_INVENTORY);
        return PLUGIN_HANDLED;
    }

    switch(item)
    {
        case 0: terrorists_menu(id);
        case 1: counter_terrorists_menu(id);
        case 2: preview_menu(id);
    }

    return PLUGIN_CONTINUE;
}

public terrorists_menu(id)
{
    new szMenuItem[128]
    new iMenu = menu_create(fmt("%s Terrorists Agents^n^n\dMoney: \w%s\y$", g_szMenuTag, AddCommas(get_user_money(id))), "terrorists_agents_menu_handler");
    
    if(g_iTerorristTotalSkins > 0)
    {
        formatex(szMenuItem, charsmax(szMenuItem), "Default Skin -\y [%s]^n", g_iPlayerSkin[id][T] == NON_USED_SKIN ? "ON" : "OFF");
        menu_additem(iMenu, szMenuItem);

        for (new i = 0; i < g_iTerorristTotalSkins; i++)
        {
            if(g_TSkin[i][iTID] == g_iPlayerSkin[id][T])
            {
                formatex(szMenuItem, charsmax(szMenuItem), "%s %s\d-\r [#]", g_TSkin[i][szTModelName], g_TSkin[i][iTVIPOnly] == 1 ? "\y[VIP] " : "");
                menu_additem(iMenu, szMenuItem);
            }
            else if(g_iTPlayerSkins[id][i] == 0)
            {
                formatex(szMenuItem, charsmax(szMenuItem), "%s \r[\w%s\y$\r]%s", g_TSkin[i][szTModelName], AddCommas(g_iTSkinPrice[i]), g_TSkin[i][iTVIPOnly] == 1 ? " \y[VIP]" : "")
                menu_additem(iMenu, szMenuItem);
            }
            else 
            {
                formatex(szMenuItem, charsmax(szMenuItem), "%s %s", g_TSkin[i][szTModelName], g_TSkin[i][iTVIPOnly] == 1 ? "\y[VIP] " : "");
                menu_additem(iMenu, szMenuItem);
            }		
        }
    }
    else 
    {
        formatex(szMenuItem, charsmax(szMenuItem), "\dThere are no models to choose from.");
        menu_addtext2(iMenu, szMenuItem);
    }

    menu_setprop(iMenu, MPROP_SHOWPAGE, false)
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
    
    if(is_user_connected(id))
    {
        menu_display(id, iMenu, 0);
    }
    else 
    {
        menu_destroy(iMenu)
    }
}

public terrorists_agents_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        agents_menu(id);
        return PLUGIN_HANDLED;
    }

    if(item > g_iTerorristTotalSkins || item < 0)
    {
        terrorists_menu(id);
        return PLUGIN_HANDLED;
    }

    if(item == 0)
    {
        if(is_user_alive(id))
        {
            rg_reset_user_model(id)
            client_print_color(id, print_team_default, "%s You choose^4 Default Skin^1!", g_szChatTag);
        }
        else 
        {
            client_print_color(id, print_team_default, "%s You will be respawned with^4 Default Skin^1!", g_szChatTag);
        }

        g_iPlayerSkin[id][T] = NON_USED_SKIN;
        terrorists_menu(id);
        _SaveData(id)
        return PLUGIN_HANDLED;
    }

    item -= 1;

    if(g_TSkin[item][iTVIPOnly] != 0 && !(get_user_flags(id) & read_flags(g_iSettings[FLAG_VIP])))
    {
        if(g_iTPlayerSkins[id][item] == 0)
            client_print_color(id, print_team_default, "%s You can't buy this skin because you are not a ^4VIP^1!", g_szChatTag);
        else 
            client_print_color(id, print_team_default, "%s You can't choose this skin because you are not a ^4VIP^1!", g_szChatTag);

        terrorists_menu(id);
        return PLUGIN_HANDLED;
    }

    if(g_iTPlayerSkins[id][item] == 0)
    {
        if(get_user_money(id) >= g_iTSkinPrice[item])
        {
            g_iTPlayerSkins[id][item] = 1;
            client_print_color(id, print_team_default, "%s You just bought^4 %s^1 agent!", g_szChatTag, g_TSkin[item][szTModelName]);
            set_user_money(id, get_user_money(id) - g_iTSkinPrice[item]);
            updateInventoryValue(id)
            terrorists_menu(id);
            _SaveData(id)
            return PLUGIN_HANDLED;
        }
        else 
        {
            client_print_color(id, print_team_default, "%s You don't have enough money!", g_szChatTag);
            terrorists_menu(id);
            return PLUGIN_CONTINUE;
        }
    }
            
    if(is_user_alive(id))
    {
        if(get_user_team(id) == 1)
        {
            rg_set_user_model(id, g_TSkin[item][szTModelLocation])
        }
        client_print_color(id, print_team_default, "%s You choose^4 %s^1 Agent!", g_szChatTag, g_TSkin[item][szTModelName]);
    }
    else 
    {
        client_print_color(id, print_team_default, "%s You will be respawned with^4 %s^1 Agent Model!", g_szChatTag, g_TSkin[item][szTModelName]);
    }

    g_iPlayerSkin[id][T] = item;
    terrorists_menu(id);
    _SaveData(id)
    return PLUGIN_CONTINUE;
}

public counter_terrorists_menu(id)
{
    new szMenuItem[128]
    new iMenu = menu_create(fmt("%s Counter-Terrorists Agents^n^n\dMoney: \w%s\y$", g_szMenuTag, AddCommas(get_user_money(id))), "counter_terrorists_agents_menu_handler");
    
    if(g_iCounterTotalSkins > 0)
    {
        formatex(szMenuItem[0], charsmax(szMenuItem), "Default Skin -\y [%s]^n", g_iPlayerSkin[id][CT] == NON_USED_SKIN ? "ON" : "OFF");
        menu_additem(iMenu, szMenuItem[0]);

        for (new i; i < g_iCounterTotalSkins; i++)
        {
            if(g_CTSkin[i][iCTID] == g_iPlayerSkin[id][CT])
            {
                formatex(szMenuItem, charsmax(szMenuItem), "%s %s\d-\r [#]", g_CTSkin[i][szCTModelName], g_CTSkin[i][iCTVIPOnly] == 1 ? "\y[VIP] " : "");
                menu_additem(iMenu, szMenuItem);
            }
            else if(g_iCTPlayerSkins[id][i] == 0)
            {
                formatex(szMenuItem, charsmax(szMenuItem), "%s \r[\w%s\y$\r]%s", g_CTSkin[i][szCTModelName], AddCommas(g_iCTSkinPrice[i]), g_CTSkin[i][iCTVIPOnly] == 1 ? " \y[VIP]" : "")
                menu_additem(iMenu, szMenuItem);
            }
            else 
            {
                formatex(szMenuItem, charsmax(szMenuItem), "%s %s", g_CTSkin[i][szCTModelName], g_CTSkin[i][iCTVIPOnly] == 1 ? "\y[VIP] " : "");
                menu_additem(iMenu, szMenuItem);
            }	
        }
    }
    else 
    {
        formatex(szMenuItem, charsmax(szMenuItem), "\dThere are no models to choose from.");
        menu_addtext2(iMenu, szMenuItem);
    }

    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);

    if(is_user_connected(id))
    {
        menu_display(id, iMenu, 0);
    }
    else 
    {
        menu_destroy(iMenu)
    }
}

public counter_terrorists_agents_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        agents_menu(id);
        return PLUGIN_HANDLED;
    }

    if(item == 0)
    {
        if(is_user_alive(id))
        {
            rg_reset_user_model(id)

            client_print_color(id, print_team_default, "%s You choose^4 Default Skin^1!", g_szChatTag);
        }
        else 
        {
            client_print_color(id, print_team_default, "%s You will be respawned with^4 Default Skin^1!", g_szChatTag);
        }

        g_iPlayerSkin[id][CT] = NON_USED_SKIN;
        counter_terrorists_menu(id);
        _SaveData(id)
        return PLUGIN_HANDLED;
    }

    if(item > g_iCounterTotalSkins || item < 0)
    {
        return PLUGIN_HANDLED;
    }

    item -= 1;

    if(g_CTSkin[item][iCTVIPOnly] != 0 && !(get_user_flags(id) & read_flags(g_iSettings[FLAG_VIP])))
    {
        if(g_iCTPlayerSkins[id][item] == 0)
            client_print_color(id, print_team_default, "%s You can't buy this skin because you are not a ^4VIP^1!", g_szChatTag);
        else 
            client_print_color(id, print_team_default, "%s You can't choose this skin because you are not a ^4VIP^1!", g_szChatTag);
        counter_terrorists_menu(id);
        return PLUGIN_HANDLED;
    }

    if(g_iCTPlayerSkins[id][item] == 0)
    {
        if(get_user_money(id) >= g_iCTSkinPrice[item])
        {
            g_iCTPlayerSkins[id][item] = 1;
            client_print_color(id, print_team_default, "%s You just bought^4 %s^1 agent!", g_szChatTag, g_CTSkin[item][szCTModelName]);
            set_user_money(id, get_user_money(id) - g_iCTSkinPrice[item]);
            updateInventoryValue(id)
            counter_terrorists_menu(id);
            _SaveData(id)
            return PLUGIN_HANDLED;
        }
        else 
        {
            client_print_color(id, print_team_default, "%s You don't have enough money!", g_szChatTag);
            counter_terrorists_menu(id);
            return PLUGIN_CONTINUE;
        }
    }
    
    if(is_user_alive(id))
    {
        if(get_user_team(id) == 2)
        {
            rg_set_user_model(id, g_CTSkin[item][szCTModelLocation])
        }
        
        client_print_color(id, print_team_default, "%s You choose^4 %s^1 Agent!", g_szChatTag, g_CTSkin[item][szCTModelName]);
    }
    else
    {
        client_print_color(id, print_team_default, "%s You will be respawned with^4 %s^1 Agent Model!", g_szChatTag, g_CTSkin[item][szCTModelName]);
    }

    g_iPlayerSkin[id][CT] = item;
    counter_terrorists_menu(id);
    _SaveData(id)
    return PLUGIN_CONTINUE;
}

public preview_menu(id)
{
    new iMenu = menu_create(fmt("%s Preview Menu", g_szMenuTag), "preview_menu_handler");

    menu_additem(iMenu, "Terrorist Agents");
    menu_additem(iMenu, "Counter-Terrorists Agents");

    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
    
    if(is_user_connected(id))
    {
        menu_display(id, iMenu, 0);
    }
    else 
    {
        menu_destroy(iMenu)
    }
}

public preview_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        agents_menu(id);
        return PLUGIN_HANDLED;
    }

    switch(item)
    {
        case 0: preview_terrorist_agents(id);
        case 1: preview_counter_terrorist_agents(id);
    }

    return PLUGIN_CONTINUE;
}

public preview_terrorist_agents(id)
{
    new iMenu = menu_create(fmt("%s Terrorists Agents", g_szMenuTag), "terrorists_preview_menu_handler");
    new szMsg[45];

    if(g_iTerorristTotalSkins > 0)
    {
        for (new i; i < g_iTerorristTotalSkins; i++)
        {
            menu_additem(iMenu, g_TSkin[i][szTModelName]);
        }
    }
    else 
    {
        formatex(szMsg, charsmax(szMsg), "\dThere are no models to see preview of.");
        menu_addtext2(iMenu, szMsg);
    }

    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
    
    if(is_user_connected(id))
    {
        menu_display(id, iMenu, 0);
    }
    else 
    {
        menu_destroy(iMenu)
    }
}

public terrorists_preview_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        preview_menu(id);
        return PLUGIN_HANDLED;
    }

    if(contain(g_TSkin[item][szTModelPreview], "NOPREVIEW") != -1)
    {
        client_print_color(id, print_team_default, "%s Agent ^4%s^1 does not have a preview!", g_szChatTag, g_TSkin[item][szTModelName]);
        return PLUGIN_HANDLED;
    }

    show_motd(id, g_TSkin[item][szTModelPreview]);

    preview_terrorist_agents(id);

    return PLUGIN_CONTINUE;
}

public preview_counter_terrorist_agents(id)
{
    new iMenu = menu_create(fmt("%s Counter-Terrorists Agents", g_szMenuTag), "counter_terrorists_preview_menu_handler");
    new szMsg[45];

    if(g_iCounterTotalSkins > 0)
    {
        for (new i; i < g_iCounterTotalSkins; i++)
        {
            menu_additem(iMenu, g_CTSkin[i][szCTModelName]);	
        }
    }
    else 
    {
        formatex(szMsg, charsmax(szMsg), "\dThere are no models to see preview of.");
        menu_addtext2(iMenu, szMsg);
    }

    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
    
    if(is_user_connected(id))
    {
        menu_display(id, iMenu, 0);
    }
    else 
    {
        menu_destroy(iMenu)
    }
}

public counter_terrorists_preview_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        preview_menu(id);
        return PLUGIN_HANDLED;
    }
    
    if(contain(g_CTSkin[item][szCTModelPreview], "NOPREVIEW") != -1)
    {
        client_print_color(id, print_team_default, "%s Agent ^4%s^1 does not have a preview!", g_szChatTag, g_CTSkin[item][szCTModelName]);
        return PLUGIN_HANDLED;
    }

    show_motd(id, g_CTSkin[item][szCTModelPreview]);

    preview_counter_terrorist_agents(id);

    return PLUGIN_CONTINUE;
}

public player_spawn_post(id)
{
    if(is_user_alive(id))
    {
	    set_player_model_after_spawn(id)
    }
}

public set_player_model_after_spawn(const id)
{        
    rg_reset_user_model(id)

    if((g_iPlayerSkin[id][T] == NON_USED_SKIN && g_iPlayerSkin[id][CT] == NON_USED_SKIN) || !is_user_logged(id))
    {
        rg_reset_user_model(id)
        return PLUGIN_HANDLED;
    }

    switch(get_user_team(id))
    {
        case 1:
        {
            if(g_iPlayerSkin[id][T] >= g_iTerorristTotalSkins)
            {
                g_iPlayerSkin[id][T] = NON_USED_SKIN;
                rg_reset_user_model(id)
                return PLUGIN_HANDLED;
            }

            rg_set_user_model(id, g_TSkin[g_iPlayerSkin[id][T]][szTModelLocation]);
        }

        case 2:
        {

            if(g_iPlayerSkin[id][CT] >= g_iCounterTotalSkins)
            {
                g_iPlayerSkin[id][CT] = NON_USED_SKIN;
                rg_reset_user_model(id)
                return PLUGIN_HANDLED;
            }

            rg_set_user_model(id, g_CTSkin[g_iPlayerSkin[id][CT]][szCTModelLocation]);
        }
    }

    return PLUGIN_CONTINUE;
}

precache_player_model(const szModel[])
{
    new model[128];
    formatex(model, charsmax(model), "%sT.mdl", szModel);

    if(file_exists(model))
        precache_generic(model);

    static const extension[] = "T.mdl";
    #pragma unused extension

    copy(model[strlen(model) - charsmax(extension)], charsmax(model), ".mdl");
    if(!file_exists(model))
    {
        set_fail_state("[CSGO Agents] Model ^"%s^" does not exists or the name of the model is wrong!", model);
    }

    precache_model(model);
}