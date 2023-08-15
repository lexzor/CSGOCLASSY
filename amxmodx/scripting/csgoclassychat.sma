#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <amxmisc>
#include <fakemeta>
#include <nvault>
#include <unixtime>
#include <csgoclassy>

#pragma compress 1

#define ADMIN_CHAT_FLAG "c"
#define ADMIN_ACCESS			ADMIN_IMMUNITY
#define isAdmin(%0) (get_user_flags(%0) & read_flags(ADMIN_CHAT_FLAG))

new g_maxplayers;
new g_saytxt;
new g_ghost;
new szFile[128];

new PlayerTag[33][32];
new bool: PlayerHasTag[33];

#define LOG_FILE "restricted_words_logs.ini"
#define CHAT_PREFIX "^4[CSGO Classy]^1"
#define UNGAG_TASK 13212

enum _:SETTINGS
{
	CVAR_MISTAKES,
	CVAR_MINUTES,
	CVAR_MONEY,
	CVAR_IMMUNITY_FLAG[2]
}

new Array:g_ArrayWords;

new g_File[256];
new const g_szFileName[] = "restricted_words.ini";

new g_eCvars[SETTINGS];
new g_iMistakes[MAX_PLAYERS + 1];
new g_szAuthid[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH]
new bool:g_bHasGag[MAX_PLAYERS + 1];
new g_iUngagTime[MAX_PLAYERS + 1];

new g_nVault;
new const g_sznVaultName[] = "restricted_word_gags";

public plugin_init() 
{
	register_plugin("CSGO Classy Chat", "1.1", "lexzor");
	g_ghost = register_cvar("amx_chatfix_ghostchat", "1")
	g_saytxt = get_user_msgid("SayText");
	g_maxplayers=get_maxplayers();
	register_clcmd("say", "HookSay")
	register_clcmd("say_team", "HookSay")
	//register_forward(FM_ClientUserInfoChanged, "fwClientUserInfoChanged" );

	new data;
	data = register_cvar("resword_mistakes", "3");
	g_eCvars[CVAR_MISTAKES] = get_pcvar_num(data);

	data = register_cvar("resword_gag_minutes", "30");
	g_eCvars[CVAR_MINUTES] = get_pcvar_num(data) * 60;

	data = register_cvar("resword_money_punishment", "500");
	g_eCvars[CVAR_MONEY] = get_pcvar_num(data);

	data = register_cvar("rewsword_immunity_flag", "c");
	get_pcvar_string(data, g_eCvars[CVAR_IMMUNITY_FLAG], charsmax(g_eCvars[CVAR_IMMUNITY_FLAG]));

	register_clcmd("resword_unmute", "resword_unmute", read_flags(g_eCvars[CVAR_IMMUNITY_FLAG]), "<name>", -1, false);

	g_nVault = nvault_open(g_sznVaultName);

	if(g_nVault == INVALID_HANDLE)
		set_fail_state("Couldn't open nvault file %s", g_sznVaultName);

	read_words();
}

public plugin_precache( ) 
{
	get_configsdir( szFile, sizeof ( szFile ) -1 );
	new szCSGOConfigDir[64]
	csgo_directory(szCSGOConfigDir, charsmax(szCSGOConfigDir))
	format( szFile, sizeof ( szFile ) -1, "%s/%s/tags.ini", szFile, szCSGOConfigDir );
	
	if( !file_exists( szFile ) ) write_file( szFile, ";Syntax: ^"name^" ^"tag^"", -1 );
}

public plugin_end(){ nvault_close(g_nVault); }

public resword_unmute(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED;

	new szUserName[MAX_NAME_LENGTH];
	read_argv(1, szUserName, charsmax(szUserName));
	new iPlayer = find_player_ex(FindPlayer_MatchNameSubstring, szUserName);

	if(iPlayer)
	{
		if(g_bHasGag[iPlayer])
		{
			g_bHasGag[iPlayer] = false;
			g_iMistakes[iPlayer] = 0;
			g_iUngagTime[iPlayer] = -1;
			if(task_exists(iPlayer + UNGAG_TASK))
				remove_task(iPlayer + UNGAG_TASK)
			nvault_remove(g_nVault, g_szAuthid[iPlayer]);
			get_user_name(id, szUserName, charsmax(szUserName));
			client_print_color(iPlayer, print_team_default, "%s You have been unmuted by^4 %s", CHAT_PREFIX, szUserName);
			get_user_name(iPlayer, szUserName, charsmax(szUserName));
			client_print(id, print_console, "[CSGO Classy] You unmuted %s", szUserName);
		}
	} else client_print(id, print_console, "[CSGO Classy] User is not connected");

	return PLUGIN_HANDLED;
}

public client_connect(id)
{
	g_iMistakes[id] = 0;
	g_bHasGag[id] = false;
}

public client_putinserver(id)
{
	if( is_user_bot(id) || is_user_hltv( id ) ) return PLUGIN_HANDLED;
	PlayerHasTag[id] = false;
	LoadPlayerTag(id);

	new iTs, szData[12];
	get_user_authid(id, g_szAuthid[id], charsmax(g_szAuthid[]))
	if(nvault_lookup(g_nVault, g_szAuthid[id], szData, charsmax(szData), iTs))
	{
		g_iUngagTime[id] = str_to_num(szData);
		g_bHasGag[id] = true;
		set_task(30.0, "check_ungag", id + UNGAG_TASK, .flags = "b");
	}

	return PLUGIN_CONTINUE;
}
public client_disconnected(id)
{
	if(g_bHasGag[id])
		remove_task(id + UNGAG_TASK);
}

public check_ungag(id)
{
	id -= UNGAG_TASK;

	if(g_iUngagTime[id] <= get_systime())
	{
		g_bHasGag[id] = false;
		g_iMistakes[id] = 0;
		remove_task(id + UNGAG_TASK);
		nvault_remove(g_nVault, g_szAuthid[id]);
		client_print_color(id, print_team_default, "%s You have been^3 unmuted^1.", CHAT_PREFIX);
	} else g_bHasGag[id] = true;
}

// public fwClientUserInfoChanged( id, buffer )
// {
// 	if ( !is_user_connected( id ) )
// 	return FMRES_IGNORED;
	
// 	static newname[ 32 ];
// 	static name[ 32 ];
	
// 	get_user_name( id, name, sizeof ( name ) -1 );
// 	engfunc( EngFunc_InfoKeyValue, buffer, "name", newname, sizeof ( newname ) -1 );
	
// 	if ( equal( newname, name ) || (containi(newname, g_eCvars[CVAR_ALLOW_KEY]) == -1))
// 		return FMRES_IGNORED;
	
	
// 	set_task( 0.1, "LoadPlayerTag", id );
	
// 	return FMRES_SUPERCEDE;
// }

public HookSay(id)
{
	static g_typed[192], g_message[192], g_name[32];	
	read_args(g_typed, charsmax(g_typed))
	remove_quotes(g_typed)
	trim(g_typed);

	if(g_bHasGag[id] == true)
	{
		static iYear, iMonth, iDay, iHour, iMinute, iSecond;
		UnixToTime((g_iUngagTime[id] + 10800), iYear, iMonth, iDay, iHour, iMinute, iSecond);
		client_print_color(id, print_team_default, "%s You are^4 muted^1 until^4 %i/%i/%i^1 at^4 %i:%i:%i",
		CHAT_PREFIX, iDay, iMonth, iYear, iHour, iMinute, iSecond);
		return PLUGIN_HANDLED_MAIN;
	}

	static szRestrictedWord[64], iPos, szNewString[192];
	for(new i; i < ArraySize(g_ArrayWords); i++)
	{
		ArrayGetString(g_ArrayWords, i, szRestrictedWord, charsmax(szRestrictedWord));
		iPos = containi(g_typed, szRestrictedWord);

		if(iPos != -1)
		{
			formatex(szNewString, charsmax(szNewString), "%s", g_typed[iPos])
			replace_all(szNewString, charsmax(szNewString), g_typed[iPos + strlen(szRestrictedWord)], "");
			
			if(equali(szNewString, szRestrictedWord))
			{
				client_print_color(id, print_team_default, "%s Restricted word^3 detected^1!", CHAT_PREFIX);

				if(g_eCvars[CVAR_MISTAKES] != 0 && !(get_user_flags(id) & read_flags(g_eCvars)))
				{
					g_iMistakes[id]++;
					
					if(g_iMistakes[id] == g_eCvars[CVAR_MISTAKES])
					{
						gag_player(id);
					}
				}

				return PLUGIN_HANDLED_MAIN;
			}
		}
	}

	// if(ArrayFindString(g_ArrayWords, g_typed) != -1)
	// {
	// 	client_print_color(id, print_team_default, "%s Restricted word^3 detected^1!", CHAT_PREFIX);

	// 	if(g_eCvars[CVAR_MISTAKES] != 0)
	// 	{
	// 		g_iMistakes[id]++;
	// 		if(g_iMistakes[id] == g_eCvars[CVAR_MISTAKES])
	// 			gag_player(id);
	// 	}
	// 	return PLUGIN_HANDLED_MAIN;
	// }
	
	if(equal(g_typed, "") || !is_user_connected(id) || !id)
	return PLUGIN_HANDLED;
	
	get_user_name(id, g_name, charsmax(g_name));
	
	new szArg[10], szTeamP[32]
	new bool:isTeam;
	read_argv(0,szArg,charsmax(szArg))
	new CsTeams:iTeam = cs_get_user_team(id);
	if(equali(szArg, "say_team"))
	{
			switch(iTeam)
			{
				case CS_TEAM_CT: formatex(szTeamP, charsmax(szTeamP), "(Counter-Terrorists) ");
				case CS_TEAM_T: formatex(szTeamP, charsmax(szTeamP), "(Terrorists) ");
				case CS_TEAM_SPECTATOR: formatex(szTeamP, charsmax(szTeamP), "(Spectators) ");
			}
			isTeam = true;
	}
	
	if(PlayerHasTag[id] && is_user_logged(id))
	{
		new prefix[64]
		get_user_rank(id, prefix, charsmax(prefix));
		formatex(g_message, charsmax(g_message), "^4%s^3[^4%s^3] [^4%s^3] %s^4 :%s %s", isTeam ? szTeamP : "", PlayerTag[id], prefix, g_name, isAdmin(id) ? "" : "^1", g_typed);
	}
	
	if((!PlayerHasTag[id] && !is_user_logged(id)) || (PlayerHasTag[id] && !is_user_logged(id)))
	{
		formatex(g_message, charsmax(g_message), "^4%s^3[^4Logged out^3] %s^4 :%s %s", isTeam ? szTeamP : "", g_name, isAdmin(id) ? "" : "^1", g_typed);
	}

	if(!PlayerHasTag[id] && is_user_logged(id))
	{
		new prefix[64]
		get_user_rank(id, prefix, charsmax(prefix));
		formatex(g_message, charsmax(g_message), "^3%s^3[^4%s^3] %s^4 :%s %s", isTeam ? szTeamP : "", prefix, g_name, isAdmin(id) ? "" : "^1", g_typed);
	}

	new iCvar = get_pcvar_num(g_ghost)

	for(new i = 1; i <= g_maxplayers; i++)
	{
		if(!is_user_connected(i))
		continue
		
		if(isTeam && cs_get_user_team(i) != iTeam)
		continue
		
		if(!iCvar)
		{
			if(is_user_alive(id) && is_user_alive(i) || !is_user_alive(id) && !is_user_alive(i) || get_user_flags(i) & ADMIN_KICK)
			{
				send_message(g_message, id, i)
			}
		}
		else
		{	
			send_message(g_message, id, i)
		}
	}

	server_print("%s", g_message);
	
	return PLUGIN_HANDLED_MAIN;
}

public LoadPlayerTag( id )
{
	PlayerHasTag[ id ] = false;
	
	if( !file_exists( szFile ) ) 
	{
		write_file( szFile, ";Syntax: ^"name^" ^"tag^"", -1 );
	}
	
	new f = fopen( szFile, "rt" );
	
	if( !f ) return 0;
	
	new data[ 512 ], buffer[ 2 ][ 32 ] ;
	
	while( !feof( f ) ) 
	{
		fgets( f, data, sizeof ( data ) -1 );
		
		if( !data[ 0 ] || data[ 0 ] == ';' || ( data[ 0 ] == '/' && data[ 1 ] == '/' ) ) 
			continue;
		
		parse(data,\
		buffer[ 0 ], sizeof ( buffer[ ] ) - 1,\
		buffer[ 1 ], sizeof ( buffer[ ] ) - 1
		);
		
		new name[ 32 ]
		get_user_name( id, name, sizeof (name) -1 );
		
		if( equal(name, buffer[0]))
		{
			PlayerHasTag[id] = true;
			copy( PlayerTag[id], sizeof (PlayerTag[]) -1, buffer[1]);
			break;
		}
	}
	
	return 0;
}

gag_player(id)
{
	g_bHasGag[id] = true;
	g_iUngagTime[id] = get_systime(g_eCvars[CVAR_MINUTES])
	new szData[12];
	num_to_str(g_iUngagTime[id], szData, charsmax(szData));
	nvault_set(g_nVault, g_szAuthid[id], szData);
	client_print_color(id, print_team_default, "%s You have been^4 muted^1 for^3 %i minute%s.", CHAT_PREFIX, g_eCvars[CVAR_MINUTES] / 60, (g_eCvars[CVAR_MINUTES] / 60) > 1 ? "s" : "")
	if(is_user_logged(id) && g_eCvars[CVAR_MONEY] != 0)
	{
		set_user_money(id, (get_user_money(id) - g_eCvars[CVAR_MONEY]) < 0 ? 0 : (get_user_money(id) - g_eCvars[CVAR_MONEY]));
		client_print_color(id, print_team_default, "%s You lost^4 %i$^1.", CHAT_PREFIX, g_eCvars[CVAR_MONEY]);
	}
}

public read_words()
{
	g_ArrayWords = ArrayCreate(64);

	new iFilePointer, szConfigsDir[64];
	get_configsdir(szConfigsDir, charsmax(szConfigsDir));
	new szCSGOConfigDir[64]
	csgo_directory(szCSGOConfigDir, charsmax(szCSGOConfigDir))
	formatex(g_File, charsmax(g_File), "%s/%s/%s", szConfigsDir, szCSGOConfigDir, g_szFileName);

	if(!file_exists(g_File))
	{
		iFilePointer = fopen(g_File, "w");
		fputs(iFilePointer, "# Cuvintele trebuie scrise unele sub altele^n^n");
		fclose(iFilePointer);
		log_to_file(LOG_FILE, "File ^"%s^" has been created", g_File);
		read_words()
	}
	else 
	{
		iFilePointer = fopen(g_File, "r");

		new szData[192];
		
		while(fgets(iFilePointer, szData, charsmax(szData)))
		{
			trim(szData);

			if(szData[0] == '#' || szData[0] == ';' || szData[0] == EOS)
				continue;

			ArrayPushString(g_ArrayWords, szData);
		}

		fclose(iFilePointer);
	}
}

send_message(const message[], const id, const i)
{
	message_begin(MSG_ONE, g_saytxt, {0, 0, 0}, i)
	write_byte(id)
	write_string(message)
	message_end()
}