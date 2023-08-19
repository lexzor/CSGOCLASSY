#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <csgoclassy>

#define ADMIN_FLAG "d"

#define MAX_PROMOCODE_LENGTH 64

new Array:g_ArrayPromocodes;
new Array:g_ArrayType;
new Array:g_ArrayAmount;
new Array:g_ArrayAdminsOnly;

new const g_szFileName[] = "promocodes.ini";
new const g_szFileData[][] =
{
    "#Model promocode: ^"promocode^" ^"tip premiu^" ^"cantitate^" ^"adminsonly 1/0^"^n",
    "#Tipuri premiu: 1 - cases, 2 - keys, 3 - scraps, 4 - money, 5 - keys and cases^n^n^n"
};

new const g_sznVaultName[] = "promocodes";
new g_nVault;

new g_szPlayerPromocodes[MAX_PLAYERS + 1][2048];
new g_szCurrentPromocode[MAX_PLAYERS + 1][32];
new g_szChatTag[32]
new g_szMenuTag[32]

new g_iMenuID

public plugin_init()
{
    register_plugin("CSGO Classy Promocodes", "1.0", "lexzor");

    register_dictionary("promocodes.txt");

    register_concmd("Promocode", "get_promocode", -1, "", -1, false);

    g_nVault = nvault_open(g_sznVaultName);

    if(g_nVault == INVALID_HANDLE)
    {
        set_fail_state("[CSGO Classy] Couldn't open nvault file %s!", g_sznVaultName);
    }

    csgo_get_prefixes(g_szChatTag, charsmax(g_szChatTag), g_szMenuTag, charsmax(g_szMenuTag))

    g_iMenuID = csgo_register_menu(MenuCode:MENU_MAIN, "\yPromocode")
}

public csgo_menu_item_selected(const id, const MenuCode:menu_code, const itemid)
{
    if(menu_code != MenuCode:MENU_MAIN || itemid != g_iMenuID)
    {
        return 
    }

    promocode_menu(id)

    return
}

public plugin_end()
{
    ArrayDestroy(g_ArrayPromocodes);
    ArrayDestroy(g_ArrayType);
    ArrayDestroy(g_ArrayAmount);
    ArrayDestroy(g_ArrayAdminsOnly);

    nvault_close(g_nVault);
}

public plugin_precache()
{
    g_ArrayPromocodes = ArrayCreate(32);
    g_ArrayType = ArrayCreate(1);
    g_ArrayAmount = ArrayCreate(1);
    g_ArrayAdminsOnly = ArrayCreate(1);

    new szFile[256], szFileDirector[124], iFilePointer, szCSGOConfigDir[64];
    
    get_configsdir(szFileDirector, charsmax(szFileDirector));
    csgo_directory(szCSGOConfigDir, charsmax(szCSGOConfigDir))
    formatex(szFile, charsmax(szFile), "%s/%s/%s", szFileDirector, szCSGOConfigDir, g_szFileName);

    new bool:bFileExists = bool:file_exists(szFile);

    if(!bFileExists)
    {
        iFilePointer = fopen(szFile, "w");

        for(new i; i < sizeof(g_szFileData); i++)
            fputs(iFilePointer, g_szFileData[i]);

        fclose(iFilePointer);
        set_fail_state("[CSGO Classy] File ^"%s^" has been created", szFile);
    }
    else 
    {
        iFilePointer = fopen(szFile, "r");
        new szData[256];
        new szPromocode[32], szType[5], szAmount[5], szAdminsOnly[5];
        
        while(fgets(iFilePointer, szData, charsmax(szData)))
        {
            if(szData[0] == ';' || szData[0] == '#' || szData[0] == EOS)
                continue;

            parse(szData, szPromocode, charsmax(szPromocode), szType, charsmax(szType), szAmount, charsmax(szAmount), szAdminsOnly, charsmax(szAdminsOnly));
            ArrayPushString(g_ArrayPromocodes, szPromocode);
            ArrayPushCell(g_ArrayType, str_to_num(szType));
            ArrayPushCell(g_ArrayAmount, str_to_num(szAmount));
            ArrayPushCell(g_ArrayAdminsOnly, str_to_num(szAdminsOnly));
        }

        fclose(iFilePointer);
    }
}

public client_disconnected(id)
{
    if(is_user_bot(id) || is_user_hltv(id))
        return PLUGIN_HANDLED;

    static szName[MAX_NAME_LENGTH];
    get_user_name(id, szName, charsmax(szName));

    nvault_set(g_nVault, szName, g_szPlayerPromocodes[id]);

    return PLUGIN_CONTINUE;
}

public client_authorized(id)
{
    if(is_user_bot(id) || is_user_hltv(id))
        return PLUGIN_HANDLED;

    static szName[MAX_NAME_LENGTH];
    get_user_name(id, szName, charsmax(szName));

    new iTs;
    
    if(!nvault_lookup(g_nVault, szName, g_szPlayerPromocodes[id], charsmax(g_szPlayerPromocodes[]), iTs))
        formatex(g_szPlayerPromocodes[id], charsmax(g_szPlayerPromocodes[]), "");

    return PLUGIN_CONTINUE;
}

public promocode_menu(id)
{
    new szTitle[64], szItem[64];
    formatex(szTitle, charsmax(szTitle), "%s %l", g_szMenuTag, "MAIN_MENU_PROMO_TITLE");
    new iMenu = menu_create(szTitle, "promocode_menu_handler");

    formatex(szItem, charsmax(szItem), "%l", "TYPE_PROMOCODE_OPTION", g_szCurrentPromocode[id]);
    menu_additem(iMenu, szItem);

    menu_addblank2(iMenu);

    formatex(szItem, charsmax(szItem), "%l", "MENU_OPTION_CONFIRM");
    menu_additem(iMenu, szItem);

    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, iMenu, 0, -1);
}

public promocode_menu_handler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        display_menu(id, MenuCode:MENU_MAIN)
        return PLUGIN_HANDLED;
    }

    switch(item)
    {
        case 0: client_cmd(id, "messagemode Promocode");
        
        case 2: check_promocode(id);
    }

    return PLUGIN_CONTINUE;
}

public get_promocode(id)
{
    new szPromocode[32];
    read_args(szPromocode, charsmax(szPromocode));
    remove_quotes(szPromocode);

    if(strlen(szPromocode) < 1)
    {
        client_print_color(id, print_team_default, "%s %l", g_szChatTag, "TYPE_PROMOCODE");
        return PLUGIN_HANDLED;
    }

    copy(g_szCurrentPromocode[id], charsmax(g_szCurrentPromocode[]), szPromocode);

    promocode_menu(id);

    return PLUGIN_CONTINUE;
}

public check_promocode(id)
{
    new index = ArrayFindString(g_ArrayPromocodes, g_szCurrentPromocode[id])
    new szPromocode[MAX_PROMOCODE_LENGTH]

    if(index > -1)
    {
        ArrayGetString(g_ArrayPromocodes, index, szPromocode, charsmax(szPromocode))
    
        if(!equal(g_szCurrentPromocode[id], szPromocode))
        {
            client_print_color(id, print_team_default, "%s %l", g_szChatTag, "INVALID_PROMOCODE", g_szCurrentPromocode[id]);
            return
        }
    }
    else 
    {
        client_print_color(id, print_team_default, "%s %l", g_szChatTag, "INVALID_PROMOCODE", g_szCurrentPromocode[id]);
        return
    }

    if(containi(g_szPlayerPromocodes[id], g_szCurrentPromocode[id]) != -1)
    {
        client_print_color(id, print_team_default, "%s %l", g_szChatTag, "USED_PROMOCODE", g_szCurrentPromocode[id]);
        promocode_menu(id);
        return;
    }

    if((ArrayGetCell(g_ArrayAdminsOnly, index) == 1) && !(get_user_flags(id) & read_flags(ADMIN_FLAG)))
    {
        client_print_color(id, print_team_default, "%s %l", g_szChatTag, "MUST_BE_ADMIN");
        promocode_menu(id);
        return;
    }

    new iType = ArrayGetCell(g_ArrayType, index);
    new iBonus = ArrayGetCell(g_ArrayAmount, index);

    switch(iType)
    {
        case 1: 
        {
            set_user_cases(id, get_user_cases(id) + iBonus);
            client_print_color(id, print_team_default, "%s You got^4 %i case%s^1 for using promocode^4 %s^1.", g_szChatTag, iBonus, iBonus > 1 ? "s" : "", g_szCurrentPromocode[id]);
        }
        case 2: 
        {
            set_user_keys(id, get_user_keys(id) + iBonus);
            client_print_color(id, print_team_default, "%s You got^4 %i key%s^1 for using promocode^4 %s^1.", g_szChatTag, iBonus, iBonus > 1 ? "s" : "", g_szCurrentPromocode[id]);
        }
        case 3:
        {
            set_user_scraps(id, get_user_scraps(id) + iBonus);
            client_print_color(id, print_team_default, "%s You got^4 %i scrap%s^1 for using promocode^4 %s^1.", g_szChatTag, iBonus, iBonus > 1 ? "s" : "", g_szCurrentPromocode[id]);
        }
        case 4:
        {
            set_user_money(id, get_user_money(id) + iBonus);
            client_print_color(id, print_team_default, "%s You got^4 %i$^1 for using promocode^4 %s^1.", g_szChatTag, AddCommas(iBonus), g_szCurrentPromocode[id]);
        }
        case 5:
        {
            set_user_cases(id, get_user_cases(id) + iBonus);
            set_user_keys(id, get_user_keys(id) + iBonus);
            client_print_color(id, print_team_default, "%s You got^4 %i case%s and key%s^1 for using promocode^4 %s^1.", g_szChatTag, iBonus, iBonus > 1 ? "s" : "", iBonus > 1 ? "s" : "", g_szCurrentPromocode[id]);
        }
    }

    if(g_szPlayerPromocodes[id][0] == EOS)
        formatex(g_szPlayerPromocodes[id], charsmax(g_szPlayerPromocodes[]), "^"%s^"", g_szCurrentPromocode[id]);
    else 
        formatex(g_szPlayerPromocodes[id], charsmax(g_szPlayerPromocodes[]), "%s ^"%s^"", g_szPlayerPromocodes[id], g_szCurrentPromocode[id])

    arrayset(g_szCurrentPromocode[id], EOS, charsmax(g_szCurrentPromocode[]));

    return;
}