#include <   amxmodx   >
#include <   amxmisc   >
#include <   cstrike   >
#include < hamsandwich > 
#include <   sqlx    >
#include <  fakemeta   >
#include <    fun      >


// CS:GO Infinity - Natives !!!
native csgo_set_user_points ( Index, Amount );

native csgo_get_user_points ( Index );

native csgo_set_user_dusts ( Index, Amount );

native csgo_get_user_dusts ( Index );

native csgo_set_user_chests ( Index, id, Amount );

native csgo_get_user_chests ( Index, id );

native csgo_set_user_keys ( Index, id, Amount );

native csgo_get_user_keys ( Index, id );

native csgo_is_user_logged ( Index );

// CS:GO Infinity - Forwards !!!

forward fw_csgo_open_capsule ( Index );

forward fw_csgo_spray ( Index );

forward fw_csgo_save_log ( Index );

#define CHAT_PREFIX  "^1[^3Advanced^4 Quests^1]"

new SQL_TABLE [ ] = "csgo_quests";

new SQL_HOST [ ] = "188.212.101.119";

new SQL_USER [ ] = "u1327_kwhzVuCecA";

new SQL_PASSWORD [ ] = "@gdgIk7jHf1R!fVqGhm!3Z4k";

new SQL_DATABASE [ ] = "s1327_go16";

new Name [33] [32], iSelectedChapter [33], iSelectedQuest [33], 

iMissionPassed [33] [36], iMissionProgress [33] [36], iCurrentZoom [33], MapName [32],

SqlLine [512], MysqlFormat [512], SqlError [512], Handle: iSqlTuple;

public plugin_natives (  )
{
	register_native ( "show_quests_menu", "NativeQuestsMenu", 0 );
}

public NativeQuestsMenu (  ) ShowQuestsMenu ( get_param ( 1 ) );

public plugin_init (  )
{
	register_plugin ( "[CS:GO] Quests", "1.0", "EnTeR_" );

	register_event ( "DeathMsg", "EventDeathMsg", "a" );

	register_logevent ( "leHostageRescued", 3, "2=Rescued_A_Hostage" );

	register_event ( "TextMsg", "bomb_planted", "a", "2&%!MRAD_BOMBPL" );
	
	register_event ( "TextMsg", "bomb_defused", "a", "2&%!MRAD_BOMBDEF" );
	
	//register_event ( "TextMsg", "bomb_explode", "a", "2&#Target_B" );

	register_event ( "CurWeapon" , "EventCurWeapon" , "b" , "1=1" , "2=3" );

	register_menucmd ( register_menuid ( "BuyItem", 1 ), ( 1 << 4 ), "BuyMolotov" ); 

	register_clcmd ( "drop", "CmdDrop" );
}

public plugin_cfg (  ) 
{
	iSqlTuple = SQL_MakeDbTuple ( SQL_HOST, SQL_USER, SQL_PASSWORD, SQL_DATABASE );

	if ( iSqlTuple == Empty_Handle )
	{
		set_fail_state ( "Database connection error!" );

		return;
	}

	MysqlInit (  );
}

public plugin_end (  )
{
	if ( iSqlTuple != Empty_Handle )
	{
		SQL_FreeHandle ( iSqlTuple );
	}
}

public client_putinserver ( id )
{
	get_user_name ( id, Name [id], charsmax ( Name [ ] ) );

	iSelectedChapter [id] = 0;

	iSelectedQuest [id] = 0;

	for ( new i = 1; i < 36; i ++ )
	{
		iMissionPassed [id] [i] = 0;

		iMissionProgress [id] [i] = 0
	}

	LoadData ( id );
}

public client_disconnected ( id )
{
	SaveData ( id );
}

DisplayMenu ( id, Menu )
{
	if ( is_user_connected ( id ) )
	{
		set_pdata_int ( id, 205, 0, 5 );
	
		menu_display ( id, Menu, 0 );
	}
	
	return PLUGIN_CONTINUE;
}

DestroyMenu ( Menu )
{
	menu_destroy ( Menu );
    
	return PLUGIN_HANDLED;
}

public ShowQuestsMenu ( id )
{
	new Temp [512];

	if ( iSelectedChapter [id] == 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "\d[\wAdvanced\r Quests\d]\y Select Chapter:" );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "\d[\wAdvanced\r Quests\d]\y Your Progress:" );
	}

	new Menu = menu_create ( Temp, "QuestsMenuHandler", 0 );

	if ( iSelectedChapter [id] == 0 && iSelectedQuest [id] == 0 )
	{
		if ( iMissionPassed [id] [1] > 0 && iMissionPassed [id] [2] > 0 && iMissionPassed [id] [3] > 0 && iMissionPassed [id] [4] > 0 && \
		iMissionPassed [id] [5] > 0 && iMissionPassed [id] [6] > 0 && iMissionPassed [id] [7] > 0 )
		{
				formatex ( Temp, charsmax ( Temp ), "\dChapter 1\y [Completed]" );
		}
		else
		{
			formatex ( Temp, charsmax ( Temp ), "Chapter 1" );
		}

		menu_additem ( Menu, Temp, "1", 0, -1 );

		if ( iMissionPassed [id] [8] > 0&& iMissionPassed [id] [9] > 0 && iMissionPassed [id] [10] > 0 && iMissionPassed [id] [11] > 0\
		&& iMissionPassed [id] [12] > 0 && iMissionPassed [id] [13]  > 0 && iMissionPassed [id] [14] > 0 && iMissionPassed [id] [15] > 0 )
		{
				formatex ( Temp, charsmax ( Temp ), "\dChapter 2\y [Completed]" );
		}
		else
		{
			formatex ( Temp, charsmax ( Temp ), "Chapter 2" );
		}

		menu_additem ( Menu, Temp, "2", 0, -1 );

		if ( iMissionPassed [id] [16] > 0 && iMissionPassed [id] [17] > 0 && iMissionPassed [id] [18] > 0 && iMissionPassed [id] [19] > 0\
		&& iMissionPassed [id] [20] > 0 && iMissionPassed [id] [21] > 0 && iMissionPassed [id] [22] > 0 )
		{
				formatex ( Temp, charsmax ( Temp ), "\dChapter 3\y [Completed]" );
		}
		else
		{
			formatex ( Temp, charsmax ( Temp ), "Chapter 3" );
		}

		menu_additem ( Menu, Temp, "3", 0, -1 );
		
		if ( iMissionPassed [id] [23] > 0 && iMissionPassed [id] [24] > 0 && iMissionPassed [id] [25] > 0 && iMissionPassed [id] [26] > 0\
		&& iMissionPassed [id] [27] > 0 && iMissionPassed [id] [28] > 0 && iMissionPassed [id] [29] > 0 && iMissionPassed [id] [30] > 0\
		&& iMissionPassed [id] [31] > 0 && iMissionPassed [id] [32] > 0 && iMissionPassed [id] [33] > 0 && iMissionPassed [id] [34] > 0\
		&& iMissionPassed [id] [35] > 0 )
		{
				formatex ( Temp, charsmax ( Temp ), "\dChapter 4\y [Completed]" );
		}
		else
		{
			formatex ( Temp, charsmax ( Temp ), "Chapter 4" );
		}

		menu_additem ( Menu, Temp, "4", 0, -1 );
	}
	else
	{
		switch ( iSelectedChapter [id] )
		{
			case 1: formatex ( Temp, charsmax ( Temp ), "Current Chapter:\r Chapter 1" );

			case 2: formatex ( Temp, charsmax ( Temp ), "Current Chapter:\r Chapter 2" );

			case 3: formatex ( Temp, charsmax ( Temp ), "Current Chapter:\r Chapter 3" );

			case 4: formatex ( Temp, charsmax ( Temp ), "Current Chapter:\r Chapter 4" );
		}
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );

		switch ( iSelectedQuest [id] )
		{
			case 1: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 100 players with AWP\d [\r%d/100\d]^n", iMissionProgress [id] [1] );

			case 2: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Make 500 Kills with M4A1\d [\r%d/500\d]^n", iMissionProgress [id] [2] );

			case 3: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 10 Players with Knife\d [\r%d/10\d]^n", iMissionProgress [id] [3] );

			case 4: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Defuse bomb 25 times\d [\r%d/25\d]^n", iMissionProgress [id] [4] );

			case 5: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Plant bomb 30 times\d [\r%d/30\d]^n", iMissionProgress [id] [5] );

			case 6: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Save hostages 15 times\d [\r%d/15\d]^n", iMissionProgress [id] [6] );

			case 7: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Make 25 kills with hegrenade\d [\r%d/25\d]^n", iMissionProgress [id] [7] );

			case 8: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 50 players with P228\d [\r%d/50\d]^n", iMissionProgress [id] [8] );

			case 9: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Make 25 no scope kill with Scout\d [\r%d/25\d]^n", iMissionProgress [id] [9] );

			case 10: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Make 500 Kills with Ak47\d [\r%d/500\d]^n", iMissionProgress [id] [10] );

			case 11: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Do 250 Headshot with any weapon\d [\r%d/250\d]^n", iMissionProgress [id] [11] );

			case 12: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Drop a weapon 100 times\d [\r%d/100\d]^n", iMissionProgress [id] [12] );

			case 13: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Open 100 Capsules\d [\r%d/100\d]^n", iMissionProgress [id] [13] );

			case 14: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 10 player's on\r 35hp_2_css\w map\d [\r%d/10\d]^n", iMissionProgress [id] [14] );

			case 15: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Spray 100 times\d [\r%d/100\d]^n", iMissionProgress [id] [15] );

			case 16: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 75 players with Deagle\d [\r%d/75\d]^n", iMissionProgress [id] [16] );

			case 17: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Plant bomb 5 times on\r css_overpass\w map\d [\r%d/5\d]^n", iMissionProgress [id] [17] );

			case 18: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Defuse bomb 5 times on\r css_cache\w map\d [\r%d/5\d]^n", iMissionProgress [id] [18] );

			case 19: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 100 player's with USP\d [\r%d/100\d]^n", iMissionProgress [id] [19] );

			case 20: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Open 200 Capsules\r 35hp_2_css\w map\d [\r%d/200\d]^n", iMissionProgress [id] [20] );

			case 21: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Spray 200 times\d [\r%d/200\d]^n", iMissionProgress [id] [21] );

			case 22: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Buy He Nade\d [\r%d/1\d]^n", iMissionProgress [id] [22] );

			case 23: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 550 players with AK47\d [\r%d/550\d]^n", iMissionProgress [id] [23] );

			case 24: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 550 players with M4A1\d [\r%d/550\d]^n", iMissionProgress [id] [24] );

			case 25: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 200 players with Famas\d [\r%d/200\d]^n", iMissionProgress [id] [25] );

			case 26: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 200 players with Galil\d [\r%d/200\d]^n", iMissionProgress [id] [26] );

			case 27: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 200 players with Mp5Navy\d [\r%d/200\d]^n", iMissionProgress [id] [27] );

			case 28: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 200 players with P90\d [\r%d/200\d]^n", iMissionProgress [id] [28] );

			case 29: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 200 players with G3SG1\d [\r%d/200\d]^n", iMissionProgress [id] [29] );

			case 30: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 200 players with SG550\d [\r%d/200\d]^n", iMissionProgress [id] [30] );

			case 31: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 50 players with Scout\d [\r%d/50\d]^n", iMissionProgress [id] [31] );

			case 32: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 300 players with USP\d [\r%d/300\d]^n", iMissionProgress [id] [32] );

			case 33: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 300 players with Glock18\d [\r%d/300\d]^n", iMissionProgress [id] [33] );

			case 34: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 300 players with Deagle\d [\r%d/300\d]^n", iMissionProgress [id] [34] );

			case 35: formatex ( Temp, charsmax ( Temp ), "Current Mission:\y Kill 50 players with HeGrenade\d [\r%d/50\d]^n", iMissionProgress [id] [35] );
		}

		menu_additem ( Menu, Temp, "-10", 0, -1 );

		formatex ( Temp, charsmax ( Temp ), "\rPress for change mission!" );

		menu_additem ( Menu, Temp, "-9", 0, -1 );
	}

	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public QuestsMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		return DestroyMenu ( Menu );
	}

	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );

	switch ( Index)
	{
		case -10:
		{
			client_print_color ( id, id, "%s Nu poti schimba^4 chapterul^1 pana nu termini misiunea!", CHAT_PREFIX );

			ShowQuestsMenu ( id );

			return DestroyMenu ( Menu );
		}
		case -9:
		{
			if ( iSelectedChapter [id] > 0 )
			{
				QuestsChapter ( id, iSelectedChapter [id] )
			}
		}
		case 1: 
		{
			QuestsChapter ( id, 1 );
		}
		case 2: 
		{
			QuestsChapter ( id, 2 );
		}
		case 3: 
		{
			QuestsChapter ( id, 3 );
		}
		case 4: 
		{
			QuestsChapter ( id, 4 );
		}
	}

	return DestroyMenu ( Menu );
}

public QuestsChapter ( id, Num )
{
	new Temp [512];

	formatex ( Temp, charsmax ( Temp ), "\d[\wAdvanced\r Quests\d]\y Select Mission:\d" );

	new Menu = menu_create ( Temp, "ChapterHandler", 0 );

	switch ( Num )
	{
		case 1:
		{
			formatex ( Temp, charsmax ( Temp ), "%sKill 100 players with AWP%s", iSelectedChapter [id] == 1 && iSelectedQuest [id] == 1 || iMissionPassed [id] [1] > 0 ? "\d" : "", iMissionPassed [id] [1] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "1", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sMake 500 Kills with M4A1%s", iSelectedChapter [id] == 2 && iSelectedQuest [id] == 2 || iMissionPassed [id] [2] > 0 ? "\d" : "", iMissionPassed [id] [2] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "2", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 10 Players with Knife%s", iSelectedChapter [id] == 3 && iSelectedQuest [id] == 3 || iMissionPassed [id] [3] > 0 ? "\d" : "", iMissionPassed [id] [3] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "3", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sDefuse bomb 25 times%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 4 || iMissionPassed [id] [4] > 0 ? "\d" : "", iMissionPassed [id] [4] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "4", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sPlant bomb 30 times%s", iSelectedChapter [id] == 5 && iSelectedQuest [id] == 5 || iMissionPassed [id] [5] > 0 ? "\d" : "", iMissionPassed [id] [5] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "5", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sSave hostages 15 times%s", iSelectedChapter [id] == 6 && iSelectedQuest [id] == 6 || iMissionPassed [id] [6] > 0 ? "\d" : "", iMissionPassed [id] [6] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "6", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sMake 25 kills with hegrenade%s", iSelectedChapter [id] == 7 && iSelectedQuest [id] == 7 || iMissionPassed [id] [7] > 0 ? "\d" : "", iMissionPassed [id] [7] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "7", 0, -1 );
		}
		case 2:
		{
			formatex ( Temp, charsmax ( Temp ), "%sKill 50 players with P228%s", iSelectedChapter [id] == 2 && iSelectedQuest [id] == 8 || iMissionPassed [id] [8] > 0 ? "\d" : "", iMissionPassed [id] [8] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "8", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sMake 25 no scope kill with Scout%s",iSelectedChapter [id] == 2 && iSelectedQuest [id] == 9 || iMissionPassed [id] [9] > 0 ? "\d" : "", iMissionPassed [id] [9] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "9", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sMake 500 Kills with Ak47%s", iSelectedChapter [id] == 2 && iSelectedQuest [id] == 10 || iMissionPassed [id] [10] > 0 ? "\d" : "", iMissionPassed [id] [10] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "10", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sDo 250 Headshot with any weapon%s", iSelectedChapter [id] == 2 && iSelectedQuest [id] == 11 || iMissionPassed [id] [11] > 0 ? "\d" : "", iMissionPassed [id] [11] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "11", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sDrop a weapon 100 times%s", iSelectedChapter [id] == 2 && iSelectedQuest [id] == 12 || iMissionPassed [id] [12] > 0 ? "\d" : "", iMissionPassed [id] [12] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "12", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sOpen 100 Capsules%s", iSelectedChapter [id] == 2 && iSelectedQuest [id] == 13 || iMissionPassed [id] [13] > 0 ? "\d" : "", iMissionPassed [id] [13] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "13", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 10 player's on\r 35hp_2_css\w map%s", iSelectedChapter [id] == 2 && iSelectedQuest [id] == 14 || iMissionPassed [id] [14] > 0 ? "\d" : "", iMissionPassed [id] [14] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "14", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sSpray 100 times%s", iSelectedChapter [id] == 2 && iSelectedQuest [id] == 15 || iMissionPassed [id] [15] > 0 ? "\d" : "", iMissionPassed [id] [15] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "15", 0, -1 );
		}
		case 3:
		{
			formatex ( Temp, charsmax ( Temp ), "%sKill 75 players with Deagle%s", iSelectedChapter [id] == 3 && iSelectedQuest [id] == 16 || iMissionPassed [id] [16] > 0 ? "\d" : "", iMissionPassed [id] [16] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "16", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sPlant bomb 5 times on\r css_overpass\w map%s", iSelectedChapter [id] == 3 && iSelectedQuest [id] == 17 || iMissionPassed [id] [17] > 0 ? "\d" : "", iMissionPassed [id] [17] > 0 ? "\y [Completed]" : "");

			menu_additem ( Menu, Temp, "17", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sDefuse bomb 5 times on\r css_cache\w map%s", iSelectedChapter [id] == 3 && iSelectedQuest [id] == 18 || iMissionPassed [id] [18] > 0 ? "\d" : "", iMissionPassed [id] [18] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "18", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 100 player's with USP%s", iSelectedChapter [id] == 3 && iSelectedQuest [id] == 19 || iMissionPassed [id] [19] > 0 ? "\d" : "", iMissionPassed [id] [19] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "19", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sOpen 200 Capsules\r 35hp_2_css\w map%s", iSelectedChapter [id] == 3 && iSelectedQuest [id] == 20 || iMissionPassed [id] [20] > 0 ? "\d" : "", iMissionPassed [id] [20] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "20", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sSpray 200 times%s", iSelectedChapter [id] == 3 && iSelectedQuest [id] == 21 || iMissionPassed [id] [21] > 0 ? "\d" : "", iMissionPassed [id] [21] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "21", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sBuy He Nade%s", iSelectedChapter [id] == 3 && iSelectedQuest [id] == 22 || iMissionPassed [id] [22] > 0 ? "\d" : "", iMissionPassed [id] [22] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "22", 0, -1 );
		}
		case 4:
		{
			formatex ( Temp, charsmax ( Temp ), "%sKill 550 players with AK47%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 23 || iMissionPassed [id] [23] > 0 ? "\d" : "", iMissionPassed [id] [23] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "23", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 550 players with M4A1%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 24 || iMissionPassed [id] [24] > 0 ? "\d" : "", iMissionPassed [id] [24] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "24", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 200 players with Famas%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 25 || iMissionPassed [id] [25] > 0 ? "\d" : "", iMissionPassed [id] [25] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "25", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 200 players with Galil%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 26 || iMissionPassed [id] [26] > 0 ? "\d" : "", iMissionPassed [id] [26] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "26", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 200 players with Mp5Navy%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 27 || iMissionPassed [id] [27] > 0 ? "\d" : "", iMissionPassed [id] [27] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "27", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 200 players with P90%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 28 || iMissionPassed [id] [28] > 0 ? "\d" : "", iMissionPassed [id] [28] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "28", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 200 players with G3SG1%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 29 || iMissionPassed [id] [29] > 0 ? "\d" : "", iMissionPassed [id] [29] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "29", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 200 players with SG550%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 30 || iMissionPassed [id] [30] > 0 ? "\d" : "", iMissionPassed [id] [30] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "30", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 50 players with Scout%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 31 || iMissionPassed [id] [31] > 0 ? "\d" : "", iMissionPassed [id] [31] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "31", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 300 players with USP%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 32 || iMissionPassed [id] [32] > 0 ? "\d" : "", iMissionPassed [id] [32] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "32", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 300 players with Glock18%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 33 || iMissionPassed [id] [33] > 0 ? "\d" : "", iMissionPassed [id] [33] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "33", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 300 players with Deagle%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 34 || iMissionPassed [id] [34] > 0 ? "\d" : "", iMissionPassed [id] [34] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "34", 0, -1 );

			formatex ( Temp, charsmax ( Temp ), "%sKill 50 players with HeGrenade%s", iSelectedChapter [id] == 4 && iSelectedQuest [id] == 35 || iMissionPassed [id] [35] > 0 ? "\d" : "", iMissionPassed [id] [35] > 0 ? "\y [Completed]" : "" );

			menu_additem ( Menu, Temp, "35", 0, -1 );
		}
	}

	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public ChapterHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		return DestroyMenu ( Menu );
	}

	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );

	if ( iMissionPassed [id] [Index] > 0 )
	{
		client_print_color ( id, id, "%s You completed this mission.!", CHAT_PREFIX );

		ShowQuestsMenu ( id );

		return DestroyMenu ( Menu );
	}

	switch ( Index )
	{
		case 1:
		{
			iSelectedChapter [id] = 1;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 50k Euro +25 Fragments +1x key +1x Primary Weapon Chest", CHAT_PREFIX );
		}
		case 2:
		{
			iSelectedChapter [id] = 1;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 50x Fragments +50k Euro", CHAT_PREFIX );
		}
		case 3:
		{
			iSelectedChapter [id] = 1;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 25x Fragments +25k Euro", CHAT_PREFIX );
		}
		case 4:
		{
			iSelectedChapter [id] = 1;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 100k Euro +25 Fragments", CHAT_PREFIX );
		}
		case 5:
		{
			iSelectedChapter [id] = 1;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 100k Euro +50 Fragments", CHAT_PREFIX );
		}
		case 6:
		{
			iSelectedChapter [id] = 1;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 250k Euro", CHAT_PREFIX );
		}
		case 7:
		{
			iSelectedChapter [id] = 1;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 50k Euro +25 Fragments", CHAT_PREFIX );
		}
		case 8:
		{
			iSelectedChapter [id] = 2;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 80k Euro +50 Fragments +1x key +1x Primary Weapon Chest", CHAT_PREFIX );
		}
		case 9:
		{
			iSelectedChapter [id] = 2;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 100k Euro +1x key +1x Knife Chest", CHAT_PREFIX );
		}
		case 10:
		{
			iSelectedChapter [id] = 2;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 50x Fragments +50k Euro", CHAT_PREFIX );
		}
		case 11:
		{
			iSelectedChapter [id] = 2;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 100k Euro +Secondary Weapon Chest +1x Key", CHAT_PREFIX );
		}
		case 12:
		{
			iSelectedChapter [id] = 2;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 1x random key", CHAT_PREFIX );
		}
		case 13:
		{
			iSelectedChapter [id] = 2;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 50x Fragments +50k Euro +Primary Weapon Chest", CHAT_PREFIX );
		}
		case 14:
		{
			iSelectedChapter [id] = 2;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 250k Euro", CHAT_PREFIX );
		}
		case 15:
		{
			iSelectedChapter [id] = 2;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 1x Secondary Chest +1x Key +100k Euro", CHAT_PREFIX );
		}	
		case 16:
		{
			iSelectedChapter [id] = 3;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 120k Euro +50 Fragments + 1x key +1x Primary Weapon Chest", CHAT_PREFIX );
		}
		case 17:
		{
			iSelectedChapter [id] = 3;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 30k Euro +1x Key +10 Fragments", CHAT_PREFIX );
		}
		case 18:
		{
			iSelectedChapter [id] = 3;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 30k Euro +1x Key +10 Fragments", CHAT_PREFIX );
		}
		case 19:
		{
			iSelectedChapter [id] = 3;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 75k Euro +1x key +25 Fragments", CHAT_PREFIX );
		}
		case 20:
		{
			iSelectedChapter [id] = 3;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 75x Fragments +75k Euro +Secondary Weapon Chest", CHAT_PREFIX );
		}
		case 21:
		{
			iSelectedChapter [id] = 3;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 1x Knife Chest +1x Key +125k Euro", CHAT_PREFIX );
		}
		case 22:
		{
			iSelectedChapter [id] = 3;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 +1x key", CHAT_PREFIX );
		}
		case 23:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 150k Euro +50 Fragments +1x Primary Weapon Chest", CHAT_PREFIX );
		}
		case 24:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 150k Euro +50 Fragments +1x Primary Weapon Chest", CHAT_PREFIX );
		}
		case 25:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 120k Euro +25 Fragments +1x Primary Weapon Chest", CHAT_PREFIX );
		}
		case 26:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 150k Euro +25 Fragments +1x Primary Weapon Chest", CHAT_PREFIX );
		}
		case 27:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 75k Euro +25 Fragments + 1xPrimary Weapon Chest", CHAT_PREFIX );
		}
		case 28:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 75k Euro +25 Fragments + 1xPrimary Weapon Chest", CHAT_PREFIX );
		}
		case 29:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 75k Euro +1x Key +Primary Weapon Chest", CHAT_PREFIX );
		}
		case 30:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 75k Euro +1x Key +Primary Weapon Chest", CHAT_PREFIX );
		}
		case 31:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 1x Primary Weapon Chest +50 Fragments +35k Euro", CHAT_PREFIX );
		}
		case 32:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 50k Euro +15 Fragments +1x Secondary Weapon Chest", CHAT_PREFIX );
		}
		case 33:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 50k Euro +15 Fragments +1x Secondary Weapon Chest", CHAT_PREFIX );
		}
		case 34:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 75k Euro +15 Fragments +1x Key Secondary Weapon Chest", CHAT_PREFIX );
		}
		case 35:
		{
			iSelectedChapter [id] = 4;

			iSelectedQuest [id] = Index;

			client_print_color ( id, id, "%s After complete the mission you will get^3 :^4 500k Euro", CHAT_PREFIX );
		}
	}

	SaveData ( id );

	return DestroyMenu ( Menu );
}

public EventDeathMsg (  )
{
	new Killer = read_data ( 1 );
	
	new Victim = read_data ( 2 );
	
	new Head = read_data ( 3 );
	
	new Weapon [24]; read_data ( 4, Weapon, charsmax ( Weapon ) );

	if ( !is_user_alive ( Killer )|| Killer == Victim || !csgo_is_user_logged ( Killer ) ) 

		return PLUGIN_CONTINUE;

	switch ( iSelectedChapter [Killer] )
	{
		case 1:
		{
			switch ( iSelectedQuest [Killer] )
			{
				case 1:
				{
					if ( equal ( Weapon, "awp" ) )
					{
						iMissionProgress [Killer] [1] ++;

						if ( iMissionProgress [Killer] [1] >= 100 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 50000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 25 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [1] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );
						}

						SaveData ( Killer );
					}
				}
				case 2:
				{
					if ( equal ( Weapon, "m4a1" ) )
					{
						iMissionProgress [Killer] [2] ++;

						if ( iMissionProgress [Killer] [2] >= 500 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 50000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 25 );

							iMissionPassed [Killer] [2] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;	

							ClearQuestsData ( Killer );		
						}

						SaveData ( Killer );
					}
				}
				case 3:
				{
					if ( equal ( Weapon, "knife" ) )
					{
						iMissionProgress [Killer] [3] ++;

						if ( iMissionProgress [Killer] [3] >= 10 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 25000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 25 );

							iMissionPassed [Killer] [3] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );		
						}

						SaveData ( Killer );
					}
				}
				case 7:
				{
					if ( equal ( Weapon, "grenade" ) )
					{
						iMissionProgress [Killer] [7] ++;

						if ( iMissionProgress [Killer] [7] >= 25 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 50000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 25 );

							iMissionPassed [Killer] [7] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;	

							ClearQuestsData ( Killer );	
						}

						SaveData ( Killer );
					}
				}
				default:
				{
					return PLUGIN_CONTINUE;
				}
			}
		}
		case 2:
		{
			switch ( iSelectedQuest [Killer] )
			{
				case 8:
				{
					if ( equal ( Weapon, "p228" ) )
					{
						iMissionProgress [Killer] [8] ++;

						if ( iMissionProgress [Killer] [8] >= 50 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 80000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts( Killer ) + 50 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							csgo_set_user_keys ( Killer, 1, csgo_get_user_keys ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [8] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );
						}

						SaveData ( Killer );
					}
				}
				case 9:
				{
					if ( equal ( Weapon, "scout" ) && ( iCurrentZoom [Killer] == CS_SET_NO_ZOOM ) )
					{
						iMissionProgress [Killer] [9] ++;

						if ( iMissionProgress [Killer] [9] >= 25 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 100000 );

							csgo_set_user_chests ( Killer, 3, csgo_get_user_chests ( Killer, 3 ) + 1 );

							csgo_set_user_keys ( Killer, 3, csgo_get_user_keys ( Killer, 3 ) + 1 );

							iMissionPassed [Killer] [9] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );
						}

						SaveData ( Killer );
					}
				}
				case 10: 
				{
					if ( equal ( Weapon, "ak47" ) )
					{
						iMissionProgress [Killer] [10] ++;

						if ( iMissionProgress [Killer] [10] >= 500 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 50000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts( Killer ) + 50 );

							iMissionPassed [Killer] [10] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );
						}

						SaveData ( Killer );
					}
				}
				case 11:
				{
					if ( Head )
					{
						iMissionProgress [Killer] [11] ++;

						if ( iMissionProgress [Killer] [11] >= 250 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 100000 );

							csgo_set_user_chests ( Killer, 2, csgo_get_user_chests ( Killer, 2 ) + 1 );

							csgo_set_user_keys ( Killer, 2, csgo_get_user_keys ( Killer, 2 ) + 1 );

							iMissionPassed [Killer] [11] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );
						}

						SaveData ( Killer );
					}
				}
				case 14:
				{
					get_mapname ( MapName, charsmax ( MapName ) );

					if ( equali ( MapName, "35hp_2_css" ) )
					{
						iMissionProgress [Killer] [14] ++;

						if ( iMissionProgress [Killer] [14] >= 10 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 250000 );

							iMissionPassed [Killer] [14] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );
						}

						SaveData ( Killer );
					}
				}
				default:
				{
					return PLUGIN_CONTINUE;
				}
			}
		}
		case 3:
		{
			switch ( iSelectedQuest [Killer] )
			{
				case 16:
				{
					if ( equal ( Weapon, "deagle" ) )
					{
						iMissionProgress [Killer] [16] ++;

						if ( iMissionProgress [Killer] [16] >= 75 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 120000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 50 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							csgo_set_user_keys ( Killer, 1, csgo_get_user_keys ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [16] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );
						}

						SaveData ( Killer );
					}
				}
				case 19:
				{
					if ( equal ( Weapon, "usp" ) )
					{
						iMissionProgress [Killer] [19] ++;

						if ( iMissionProgress [Killer] [19] >= 100 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 75000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 25 );

							new Num = random_num ( 1, 3 );

							csgo_set_user_chests ( Killer, Num, csgo_get_user_chests ( Killer, Num ) + 1 );

							iMissionPassed [Killer] [19] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );
						}

						SaveData ( Killer );
					}
				}
				default:
				{
					return PLUGIN_CONTINUE;
				}
			}
		}
		case 4:
		{
			switch ( iSelectedQuest [Killer] )
			{
				case 23:
				{
					if ( equal ( Weapon, "ak47" ) )
					{
						iMissionProgress [Killer] [23] ++;

						if ( iMissionProgress [Killer] [23] >= 550 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 150000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 50 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [23] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );		
						}

						SaveData ( Killer );
					}
				}
				case 24:
				{
					if ( equal ( Weapon, "m4a1" ) )
					{
						iMissionProgress [Killer] [24] ++;

						if ( iMissionProgress [Killer] [24] >= 550 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 150000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 50 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [24] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );		
						}

						SaveData ( Killer );
					}	
				}
				case 25:
				{
					if ( equal ( Weapon, "famas" ) )
					{
						iMissionProgress [Killer] [25] ++;

						if ( iMissionProgress [Killer] [25] >= 200 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 120000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 25 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [25] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );		
						}

						SaveData ( Killer );
					}					
				}
				case 26:
				{
					if ( equal ( Weapon, "galil" ) )
					{
						iMissionProgress [Killer] [26] ++;

						if ( iMissionProgress [Killer] [26] >= 200 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 150000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 50 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [26] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );		
						}

						SaveData ( Killer );
					}		
				}
				case 27:
				{
					if ( equal ( Weapon, "mp5navy" ) )
					{
						iMissionProgress [Killer] [27] ++;

						if ( iMissionProgress [Killer] [27] >= 200 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 75000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 25 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [27] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );		
						}

						SaveData ( Killer );
					}			
				}
				case 28:
				{
					if ( equal ( Weapon, "p90" ) )
					{
						iMissionProgress [Killer] [28] ++;

						if ( iMissionProgress [Killer] [28] >= 200 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 75000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 25 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [28] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;	

							ClearQuestsData ( Killer );	
						}

						SaveData ( Killer );
					}
				}
				case 29:
				{
					if ( equal ( Weapon, "g3sg1" ) )
					{
						iMissionProgress [Killer] [29] ++;

						if ( iMissionProgress [Killer] [29] >= 200 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 75000 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							csgo_set_user_keys ( Killer, 1, csgo_get_user_keys ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [29] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );		
						}

						SaveData ( Killer );
					}
				}
				case 30:
				{
					if ( equal ( Weapon, "sg550" ) )
					{
						iMissionProgress [Killer] [30] ++;

						if ( iMissionProgress [Killer] [30] >= 200 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 75000 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							csgo_set_user_keys ( Killer, 1, csgo_get_user_keys ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [30] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );		
						}

						SaveData ( Killer );
					}
				}
				case 31:
				{
					if ( equal ( Weapon, "scout" ) )
					{
						iMissionProgress [Killer] [31] ++;

						if ( iMissionProgress [Killer] [31] >= 50 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 36000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 50 );

							csgo_set_user_chests ( Killer, 1, csgo_get_user_chests ( Killer, 1 ) + 1 );

							iMissionPassed [Killer] [31] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );		
						}

						SaveData ( Killer );
					}	
				}
				case 32:
				{
					if ( equal ( Weapon, "usp" ) )
					{
						iMissionProgress [Killer] [32] ++;

						if ( iMissionProgress [Killer] [32] >= 300 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 50000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 15 );

							csgo_set_user_chests ( Killer, 2, csgo_get_user_chests ( Killer, 2 ) + 1 );

							iMissionPassed [Killer] [32] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;	

							ClearQuestsData ( Killer );
						}

						SaveData ( Killer );
					}	
				}
				case 33:
				{
					if ( equal ( Weapon, "glock18" ) )
					{
						iMissionProgress [Killer] [33] ++;

						if ( iMissionProgress [Killer] [33] >= 300 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 50000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 15 );

							csgo_set_user_chests ( Killer, 2, csgo_get_user_chests ( Killer, 2 ) + 1 );

							iMissionPassed [Killer] [33] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;	

							ClearQuestsData ( Killer );
						}

						SaveData ( Killer );
					}
				}
				case 34:
				{
					if ( equal ( Weapon, "deagle" ) )
					{
						iMissionProgress [Killer] [34] ++;

						if ( iMissionProgress [Killer] [34] >= 300 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 75000 );

							csgo_set_user_dusts ( Killer, csgo_get_user_dusts ( Killer ) + 15 );

							csgo_set_user_chests ( Killer, 2, csgo_get_user_chests ( Killer, 2 ) + 1 );

							csgo_set_user_keys ( Killer, 2, csgo_get_user_keys ( Killer, 2 ) + 1 );

							iMissionPassed [Killer] [34] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;

							ClearQuestsData ( Killer );	
						}

						SaveData ( Killer );
					}	
				}
				case 35:
				{
					if ( equal ( Weapon, "grenade" ) )
					{
						iMissionProgress [Killer] [35] ++;

						if ( iMissionProgress [Killer] [35] >= 50 )
						{
							csgo_set_user_points ( Killer, csgo_get_user_points ( Killer ) + 500000 );

							iMissionPassed [Killer] [35] = 1;

							client_print_color ( Killer, Killer, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

							iSelectedChapter [Killer] = 0;

							iSelectedQuest [Killer] = 0;	

							ClearQuestsData ( Killer );
						}

						SaveData ( Killer );
					}	
				}
			}
		}
	}

	return PLUGIN_HANDLED;
}

public leHostageRescued (  )
{
    static LogUser [80], UserName [32], id;

    read_logargv ( 0, LogUser, charsmax ( LogUser ) );

    parse_loguser ( LogUser, UserName, charsmax ( UserName ) );

    id = get_user_index ( UserName );

    if ( iSelectedChapter [id] == 1 && iSelectedQuest [id] == 6 && csgo_is_user_logged ( id ) )
    {
    	iMissionProgress [id] [6] ++;

    	if ( iMissionProgress [id] [6] >= 15 )
    	{
    		csgo_set_user_points ( id, csgo_get_user_points ( id ) + 250000 );

    		iMissionPassed [id] [6] = 1;

    		client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

		iSelectedChapter [id] = 0;

		iSelectedQuest [id] = 0;

		ClearQuestsData ( id )
    	}

    	SaveData ( id );
    }
}

public bomb_planted ( id )
{
	{
		if ( !csgo_is_user_logged ( id ) )
		{
			return;
		}

		if ( iSelectedChapter [id] == 1 && iSelectedQuest [id] == 5 )
		{
			iMissionProgress [id] [5] ++;

			if ( iMissionProgress [id] [5] >= 30 )
			{
				csgo_set_user_points ( id, csgo_get_user_points ( id ) + 100000 );

				csgo_set_user_dusts ( id, csgo_get_user_dusts ( id ) + 50 );

				iMissionPassed [id] [5] = 1;

    				client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

				iSelectedChapter [id] = 0;

				iSelectedQuest [id] = 0;

				ClearQuestsData ( id )
			}

			SaveData ( id );
		}

		get_mapname ( MapName, charsmax ( MapName ) );

		if ( iSelectedChapter [id] == 3 && iSelectedQuest [id] == 17 && equali ( MapName, "css_overpass" ) )
		{
			iMissionProgress [id] [17] ++;

			if ( iMissionProgress [id] [17] >= 5 )
			{
				csgo_set_user_points ( id, csgo_get_user_points ( id ) + 30000 );

				csgo_set_user_dusts ( id, csgo_get_user_dusts ( id ) + 10 );

				new Num = random_num ( 1, 3 );

				csgo_set_user_keys ( id, Num, csgo_get_user_keys ( id, Num ) + 1 );

				iMissionPassed [id] [17] = 1;

    				client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

				iSelectedChapter [id] = 0;

				iSelectedQuest [id] = 0;

				ClearQuestsData ( id )
			}

			SaveData ( id );
		}
	}
}

public bomb_defused ( id )
{
	{
		if ( !csgo_is_user_logged ( id ) )
		{
			return;
		}

		if ( iSelectedChapter [id] == 1 && iSelectedQuest [id] == 4 )
		{
			iMissionProgress [id] [4] ++;

			if ( iMissionProgress [id] [4] >= 25 )
			{
				csgo_set_user_points ( id, csgo_get_user_points ( id ) + 100000 );

				csgo_set_user_dusts ( id, csgo_get_user_dusts ( id ) + 25 );

				iMissionPassed [id] [4] = 1;

    				client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

				iSelectedChapter [id] = 0;

				iSelectedQuest [id] = 0;

				ClearQuestsData ( id )
			}

			SaveData ( id );
		}

		get_mapname ( MapName, charsmax ( MapName ) );

		if ( iSelectedChapter [id] == 3 && iSelectedQuest [id] == 18 && equali ( MapName, "css_cache" ) )
		{
			iMissionProgress [id] [18] ++;

			if ( iMissionProgress [id] [18] >= 5 )
			{
				csgo_set_user_points ( id, csgo_get_user_points ( id ) + 30000 );

				csgo_set_user_dusts ( id, csgo_get_user_dusts ( id ) + 10 );

				new Num = random_num ( 1, 3 );

				csgo_set_user_keys ( id, Num, csgo_get_user_keys ( id, Num ) + 1 );

				iMissionPassed [id] [18] = 1;

    				client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

				iSelectedChapter [id] = 0;

				iSelectedQuest [id] = 0;

				ClearQuestsData ( id )
			}

			SaveData ( id );
		}
	}
}

public EventCurWeapon ( id )
{
	iCurrentZoom [id] = cs_get_user_zoom ( id );
}

public CmdDrop ( id )
{
	if ( iSelectedChapter [id] == 2 && iSelectedQuest [id] == 12 && csgo_is_user_logged ( id ) &&
	get_user_weapon ( id ) != CSW_KNIFE && get_user_weapon ( id ) != CSW_HEGRENADE && get_user_weapon ( id ) != CSW_FLASHBANG &&
	get_user_weapon ( id ) != CSW_SMOKEGRENADE && get_user_weapon ( id ) != CSW_C4 )
	{
		iMissionProgress [id] [12] ++;

		if ( iMissionProgress [id] [12] >= 100 )
		{
			new Num = random_num ( 1, 3 );

			csgo_set_user_keys ( id, Num, csgo_get_user_keys ( id, Num ) + 1 );

			iMissionPassed [id] [12] = 1;

    			client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

			iSelectedChapter [id] = 0;

			iSelectedQuest [id] = 0;

			ClearQuestsData ( id )
		}

		SaveData ( id );
	}
}

public fw_csgo_open_capsule ( id )
{
	if ( iSelectedChapter [id] == 2 && iSelectedQuest [id] == 13 )
	{
		iMissionProgress [id] [13] ++;

		if ( iMissionProgress [id] [13] >= 100 )
		{
			csgo_set_user_points ( id, csgo_get_user_points ( id ) + 50000 );

			csgo_set_user_dusts ( id, csgo_get_user_dusts ( id ) + 50 );

			csgo_set_user_chests ( id, 1, csgo_get_user_chests ( id, 1 ) + 1 );

			iMissionPassed [id] [13] = 1;

    			client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

			iSelectedChapter [id] = 0;

			iSelectedQuest [id] = 0;

			ClearQuestsData ( id )
		}

		SaveData ( id );
	}

	get_mapname ( MapName, charsmax ( MapName ) );

	if ( iSelectedChapter [id] == 3 && iSelectedQuest [id] == 20 && equali ( MapName, "35hp_2_css" ) )
	{
		iMissionProgress [id] [20] ++;

		if ( iMissionProgress [id] [20] >= 200 )
		{
			csgo_set_user_points ( id, csgo_get_user_points ( id ) + 75000 );

			csgo_set_user_dusts ( id, csgo_get_user_dusts ( id ) + 75 );

			csgo_set_user_chests ( id, 2, csgo_get_user_chests ( id, 2 ) + 1 );

			iMissionPassed [id] [20] = 1;

    			client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

			iSelectedChapter [id] = 0;

			iSelectedQuest [id] = 0;

			ClearQuestsData ( id )
		}

		SaveData ( id );
	}
}

public fw_csgo_spray ( id )
{
	if ( iSelectedChapter [id] == 2 && iSelectedQuest [id] == 15 )
	{
		iMissionProgress [id] [15] ++;

		if ( iMissionProgress [id] [15] >= 100 )
		{
			csgo_set_user_points ( id, csgo_get_user_points ( id ) + 100000 );

			csgo_set_user_chests ( id, 2, csgo_get_user_chests ( id, 2 ) + 1 );

			csgo_set_user_keys ( id, 2, csgo_get_user_keys ( id, 2 ) + 1 );

			iMissionPassed [id] [15] = 1;

    			client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

			iSelectedChapter [id] = 0;

			iSelectedQuest [id] = 0;

			ClearQuestsData ( id )
		}

		SaveData ( id );
	}

	if ( iSelectedChapter [id] == 3 && iSelectedQuest [id] == 21 )
	{
		iMissionProgress [id] [21] ++;

		if ( iMissionProgress [id] [21] >= 200 )
		{
			csgo_set_user_points ( id, csgo_get_user_points ( id ) + 125000 );

			csgo_set_user_chests ( id, 3, csgo_get_user_chests ( id, 3 ) + 1 );

			csgo_set_user_keys ( id, 3, csgo_get_user_keys ( id, 3 ) + 1 );

			iMissionPassed [id] [21] = 1;

    			client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

			iSelectedChapter [id] = 0;

			iSelectedQuest [id] = 0;

			ClearQuestsData ( id )		
		}

		SaveData ( id );
	}	
}

public BuyMolotov ( id )
{
	if ( iSelectedChapter [id] == 3 && iSelectedQuest [id] == 22 && csgo_is_user_logged ( id ) )
	{
		iMissionProgress [id] [22] ++;

		if ( iMissionProgress [id] [22] >= 1 )
		{
			new Num = random_num ( 1, 3 );

			csgo_set_user_keys ( id, Num, csgo_get_user_keys ( id, Num ) + 1 );

			iMissionPassed [id] [22] = 1;

    			client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

			iSelectedChapter [id] = 0;

			iSelectedQuest [id] = 0;

			ClearQuestsData ( id )		
		}

		SaveData ( id );
	}
}

public client_command ( id ) 
{ 
	static Command [7]; 
	
	if ( read_argv ( 0, Command, charsmax ( Command ) ) == 5 && equal ( Command, "hegren" ) ) 
	{ 
		if ( iSelectedChapter [id] == 3 && iSelectedQuest [id] == 22 && csgo_is_user_logged ( id ) )
		{
			iMissionProgress [id] [22] ++;

			if ( iMissionProgress [id] [22] >= 1 )
			{
				new Num = random_num ( 1, 3 );

				csgo_set_user_keys ( id, Num, csgo_get_user_keys ( id, Num ) + 1 );

				iMissionPassed [id] [22] = 1;

	    			client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

				iSelectedChapter [id] = 0;

				iSelectedQuest [id] = 0;

				ClearQuestsData ( id )		
			}

			SaveData ( id );
		}
	}
} 

public CS_InternalCommand ( id, const Command [ ] ) 
{
	if ( equal ( Command, "hegren" ) ) 
	{
		if ( iSelectedChapter [id] == 3 && iSelectedQuest [id] == 22 && csgo_is_user_logged ( id ) )
		{
			iMissionProgress [id] [22] ++;

			if ( iMissionProgress [id] [22] >= 1 )
			{
				new Num = random_num ( 1, 3 );

				csgo_set_user_keys ( id, Num, csgo_get_user_keys ( id, Num ) + 1 );

				iMissionPassed [id] [22] = 1;

	    			client_print_color ( id, id, "%s You got a reward for finishing this mission.", CHAT_PREFIX );

				iSelectedChapter [id] = 0;

				iSelectedQuest [id] = 0;

				ClearQuestsData ( id )		
			}

			SaveData ( id );
		}
	}
} 

ClearQuestsData ( id )
{
	if ( iMissionPassed [id] [1] > 0 && iMissionPassed [id] [2] > 0 && iMissionPassed [id] [3] > 0 && iMissionPassed [id] [4] > 0 &&\
	iMissionPassed [id] [5] > 0 && iMissionPassed [id] [6] > 0 && iMissionPassed [id] [7] > 0 && iMissionPassed [id] [8] > 0 &&\
	iMissionPassed [id] [9] > 0 && iMissionPassed [id] [10] > 0 && iMissionPassed [id] [11] > 0 && iMissionPassed [id] [12] > 0 &&\
	iMissionPassed [id] [13] > 0 && iMissionPassed [id] [14] > 0 && iMissionPassed [id] [15] > 0 && iMissionPassed [id] [16] > 0 &&\
	iMissionPassed [id] [17] > 0 && iMissionPassed [id] [18] > 0 && iMissionPassed [id] [19] > 0 && iMissionPassed [id] [20] > 0 &&\
	iMissionPassed [id] [21] > 0 && iMissionPassed [id] [22] > 0 && iMissionPassed [id] [23] > 0 && iMissionPassed [id] [24] > 0 &&\
	iMissionPassed [id] [25] > 0 && iMissionPassed [id] [26] > 0 && iMissionPassed [id] [27] > 0 && iMissionPassed [id] [28] > 0 &&\
	iMissionPassed [id] [29] > 0 && iMissionPassed [id] [30] > 0 && iMissionPassed [id] [31] > 0 && iMissionPassed [id] [32] > 0 &&\
	iMissionPassed [id] [33] > 0 && iMissionPassed [id] [34] > 0 && iMissionPassed [id] [35] > 0 )
	{
		for ( new i = 1; i < 36; i ++ )
		{
			iMissionPassed [id] [i] = 0;

			iMissionProgress [id] [i] = 0;
		}
	}

	SaveData ( id );
}

public SaveData ( id )
{
	if ( !csgo_is_user_logged ( id ) )
	{
		return PLUGIN_HANDLED;
	}

	formatex ( SqlLine, charsmax ( SqlLine ), "" );

	formatex ( MysqlFormat, charsmax ( MysqlFormat ), "UPDATE `%s` SET `chapter` = '%i', `quest` = '%i', `progress` = '", SQL_TABLE, iSelectedChapter [id], iSelectedQuest [id] );

	new auxString [32];

	for ( new i = 1; i < 36; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "^"%i^" ", iMissionProgress [id] [i] );

		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );
	}

	add ( MysqlFormat, charsmax ( MysqlFormat ),"', `passed` = '" )

	for ( new i = 1; i < 36; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "^"%i^" ", iMissionPassed [id] [i] );

		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );
	}

	new SafeName [100];

	MakeStringSQLSafe ( Name [id], SafeName, charsmax ( SafeName ) );

	formatex(auxString, charsmax(auxString), "' WHERE `name`='" );

	add ( MysqlFormat, charsmax ( MysqlFormat), auxString );

	add ( MysqlFormat,charsmax ( MysqlFormat ), SafeName );

	formatex ( auxString, charsmax ( auxString ), "';" )

	add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );

	SQL_ThreadQuery ( iSqlTuple, "IgnoreHandle", MysqlFormat )

	return PLUGIN_CONTINUE;
}

public IgnoreHandle ( FailState, Handle: Query, Error [ ], Errcode, Data [ ], DataSize )
{
  	if ( FailState == TQUERY_CONNECT_FAILED )
        {
		log_amx ( "[SQL] Could not connect to SQL database.  [%d] %s",Errcode, Error)
	}
    	else if ( FailState == TQUERY_QUERY_FAILED )
	{
		log_amx ( "[SQL] - Query failed. [%d] %s", Errcode, Error)
	}

	SQL_FreeHandle ( Query );
	
	return PLUGIN_HANDLED;
}

public LoadData ( id )
{
	if ( !is_user_connected ( id ) )
	{
		return PLUGIN_HANDLED;
	}

	new Data [2], SafeName [100];

	MakeStringSQLSafe ( Name [id], SafeName, charsmax ( SafeName ) );

	Data [0] = id;

	formatex ( SqlLine, charsmax ( SqlLine ), "SELECT * FROM `%s` WHERE (`name` = '%s') LIMIT 1", SQL_TABLE, SafeName );

	SQL_ThreadQuery ( iSqlTuple, "register_client", SqlLine, Data, sizeof ( Data ) );

	return PLUGIN_CONTINUE;
}

public register_client(FailState,Handle:Query,Error[],Errcode, Data [ ], DataSize )
{
  	if ( FailState == TQUERY_CONNECT_FAILED )
        {
		log_amx ( "[SQL] Could not connect to SQL database.  [%d] %s",Errcode, Error)
	}
    	else if ( FailState == TQUERY_QUERY_FAILED )
	{
		log_amx ( "[SQL] - Query failed. [%d] %s", Errcode, Error)
	}
	
	new id = Data [0]

	if ( !is_user_connected ( id ) )
	{
		return PLUGIN_HANDLED;
	}

	if ( SQL_NumResults ( Query ) >= 1 ) 
	{
		iSelectedChapter [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "chapter" ) );

		iSelectedQuest [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "quest" ) );

		new Data [36] [17], i;

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "progress" ), SqlLine, charsmax ( SqlLine ) );

		parse ( SqlLine, Data [1], 7, Data [2], 7, 
		Data [3], 7, Data [4], 7, Data [5], 7, Data [6], 7, Data [7], 7,\ 
		Data [8], 7, Data [9], 7, Data [10], 7, Data [11], 7, Data [12], 7,\ 
		Data [13], 7, Data [14], 7, Data [15], 7, Data [16], 7, Data [17], 7,\ 
		Data [18], 7, Data [19], 7, Data [20], 7, Data [21], 7, Data [22], 7, \
		Data [23], 7, Data [24], 7, Data [25], 7, Data [26], 7, Data [27], 7,\ 
		Data [28], 7, Data [29], 7, Data [30], 7, Data [31], 7, Data [32], 7,\
		Data [33], 7, Data [34], 7, Data [35], 7 );

		for ( i = 1; i < 36; i ++ )
		{
			iMissionProgress [id] [i] = str_to_num ( Data [i] );

			formatex ( Data [i], charsmax ( Data [ ] ), "" );
		}

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "passed" ), SqlLine, charsmax ( SqlLine ) );

		parse ( SqlLine, Data [1], 7, Data [2], 7, 
		Data [3], 7, Data [4], 7, Data [5], 7, Data [6], 7, Data [7], 7, \
		Data [8], 7, Data [9], 7, Data [10], 7, Data [11], 7, Data [12], 7,\ 
		Data [13], 7, Data [14], 7, Data [15], 7, Data [16], 7, Data [17], 7,\ 
		Data [18], 7, Data [19], 7, Data [20], 7, Data [21], 7, Data [22], 7,\ 
		Data [23], 7, Data [24], 7, Data [25], 7, Data [26], 7, Data [27], 7,\ 
		Data [28], 7, Data [29], 7, Data [30], 7, Data [31], 7, Data [32], 7,\ 
		Data [33], 7, Data [34], 7, Data [35], 7 );

		for ( i = 1; i < 36; i ++ )
		{
			iMissionPassed [id] [i] = str_to_num ( Data [i] );

			formatex ( Data [i], charsmax ( Data [ ] ), "" );
		}
	}

	return PLUGIN_HANDLED
}

public MysqlInit (  )
{
	new ErrorCode, Handle: SqlConnection = SQL_Connect ( iSqlTuple, ErrorCode, SqlError, charsmax ( SqlError ) )
	
	if ( SqlConnection == Empty_Handle )

		set_fail_state ( SqlError );

	new Handle: Queries;

	formatex ( MysqlFormat, charsmax ( MysqlFormat ), "CREATE TABLE IF NOT EXISTS `%s` (`name` VARCHAR(32) NOT NULL PRIMARY KEY COLLATE 'utf8_unicode_ci',`chapter` INT (11) DEFAULT ^"0^",", SQL_TABLE );

	add ( MysqlFormat, charsmax ( MysqlFormat ), " `quest` INT(11) DEFAULT ^"0^", `progress` varchar (260) DEFAULT ^"0^", `passed` varchar (260) DEFAULT ^"0^");" );

	Queries = SQL_PrepareQuery ( SqlConnection, MysqlFormat )

	if ( !SQL_Execute ( Queries ) )
	{
		SQL_QueryError ( Queries, SqlError, charsmax ( SqlError ) );

		set_fail_state ( SqlError );
	}

	SQL_FreeHandle ( Queries );
	
	SQL_FreeHandle ( SqlConnection );
}

public fw_csgo_save_log ( id )
{
	new Query [256], Data [2], SafeName [100];

	Data [0] = id;

	MakeStringSQLSafe ( Name [id], SafeName, charsmax ( SafeName ) );

	formatex ( Query, charsmax ( Query ), "INSERT INTO `%s` (`name`) VALUES (^"%s^");", SQL_TABLE, SafeName );

	SQL_ThreadQuery ( iSqlTuple, "QuerySetData", Query, Data, sizeof ( Data ) );
}

public QuerySetData ( FailState, Handle: Query, Error [ ], Errcode, Data [ ], DataSize, Float:Queuetime ) 
{
  	if ( FailState == TQUERY_CONNECT_FAILED )
        {
		log_amx ( "[SQL] Could not connect to SQL database.  [%d] %s",Errcode, Error)
	}
    	else if ( FailState == TQUERY_QUERY_FAILED )
	{
		log_amx ( "[SQL] - Query failed. [%d] %s", Errcode, Error)
	}
	
	new id = Data [0];

	LoadData ( id );

	SQL_FreeHandle ( Query );
}

MakeStringSQLSafe ( const Input [ ], Output [ ], Len )
{
	copy ( Output, Len, Input );

	replace_all ( Output, Len, "\", "\\" );
	replace_all ( Output, Len, "'", "\'" );
	replace_all ( Output, Len, "^"", "\^"" );
	replace_all ( Output, Len, "^n", "\n" );
	replace_all ( Output, Len, "^x00", "\x00" );
	replace_all ( Output, Len, "^x1a", "\x1a" );
}
