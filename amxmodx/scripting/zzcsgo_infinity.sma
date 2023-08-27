/* 
	"CSGO Infinity" by EnTeR_

	Discord: EyeKon#3230
*/

#include 		      <    amxmodx    >  
#include 		      <    amxmisc    >     
#include 		      <    cstrike    >
#include 		      <      csx      >      
#include 		      <  hamsandwich  > 
#include		      <     reapi     >
#include 		      <       xs      > 
#include 		      <    fakemeta   >
#include              <      fun      >
#include 		      <     engine    >  
#include 		      <      sqlx     >    
#include 		      <     nvault    >
#include 	       	  < cs_player_models_api >

#pragma compress 1

#define PLUGIN_NAME       "CS:GO Infinity"
#define PLUGIN_VERSION         "3x+"
#define PLUGIN_AUTHOR        "EnTeR_"

native show_quests_menu ( Index );

native csgo_get_user_clan_name(id, szData[], iLen)

native csgo_show_clan_menu(id)
native csgo_show_achievments_menu(id)

#define CHAT_PREFIX  "^1[^4CS:GO^3 Infinity^1]"

#define SKINS_LIMIT 730
#define MAX_MVPS	50

enum
{
	OVERRIDE_MENU,
	PASSWORD_FIELD,
	CONTRACT_COST,
	CHAT_TAG_COST,
	DUST_FOR_TRANSFORM,
	SPRAY_COOLDOWN,
	RANG_UP_BONUS,
	HS_MIN_POINTS,
	HS_MAX_POINTS,
	KILL_MIN_POINTS,
	KILL_MAX_POINTS,
	COMPETITIVE_MODE,
	WARMUP_DURATION,
	BEST_POINTS,
	DROP_CHANCE,
	WAIT_FOR_PLACE,
	TOMBOLA_COST,
	TOMBOLA_TIMER,
	JACKPOT_TIMER,
	BATTLE_TIMER,
	SET_SKIN_TAG_PRICE,
	RENAME_SKIN_TAG_PRICE,
	GIVEAWAY_LIMIT,
	LOG_SCREEN_FADE,
	DERANK_COUNT,
	BUY_CK_MULTIPLIER,
	UPGRADE_MULTIPLIER,
	VIP_BONUS_MULTIPLIER,
	TAG_STATTRAK_COST_MULTIPLIER,
	TAG_COST_MULTIPLIER,
	STATTRAK_COST_MULTIPLIER,
	ROULETTE_BET_LIMIT,
	VIP_INJECTOR_AMMO,
	VIP_INJECTOR_HEAL,
	REWARD_HOURS_PLAYED,
	PREVIEW_DELAY,
	OPEN_CHESTS_DELAY,
	DROP_STATTRAK_CHANCE,
	UPGRADE_CHANCE,
	GUESS_NUMBER_DELAY,
	GUESS_NUMBER_COST,
	GUESS_NUMBER_EARN,
	BET_TEAM_MULTIPLIER,
	BET_TEAM_LIMIT,
	BET_MIN_PLAYERS_REQ,
	ITEM_TRANSFORM_REST,
	MAX_CVARS
}


new const WEAPON_NAMES [ ] [ ] = 
{ 
	"weapon_p228", 
	"weapon_scout", 
	"weapon_hegrenade", 
	"weapon_xm1014", 
	"weapon_c4", 
	"weapon_mac10",
	"weapon_aug", 
	"weapon_smokegrenade", 
	"weapon_elite", 
	"weapon_fiveseven", 
	"weapon_ump45", 
	"weapon_sg550",
	"weapon_galil", 
	"weapon_famas", 
	"weapon_usp", 
	"weapon_glock18", 
	"weapon_awp", 
	"weapon_mp5navy", 
	"weapon_m249",
	"weapon_m3", 
	"weapon_m4a1", 
	"weapon_tmp", 
	"weapon_g3sg1", 
	"weapon_flashbang", 
	"weapon_deagle", 
	"weapon_sg552",
	"weapon_ak47", 
	"weapon_knife", 
	"weapon_p90"
}

new const WEAPON_ARGS [ ] [ ] = 
{ 
	"!p228", 
	"!scout", 
	"!xm1014", 
	"!mac10",
	"!aug",  
	"!elite", 
	"!fiveseven", 
	"!ump45", 
	"!sg550",
	"!galil", 
	"!famas", 
	"!usp", 
	"!glock18", 
	"!awp", 
	"!mp5navy", 
	"!m249",
	"!m3", 
	"!m4a1", 
	"!tmp", 
	"!g3sg1", 
	"!deagle", 
	"!sg552",
	"!ak47", 
	"!knife", 
	"!p90"
}

new AnimationIds [ ] =
{
	0,  //null
	7,  //p228
	0,  //shield
	5,  //scout
	0,  //hegrenade
	7,  //xm1014
	0,  //c4
	6,  //mac10
	6,  //aug
	0,  //smoke grenade
	16, //elites
	6,  //fiveseven
	6,  //ump45
	5,  //sg550
	6,  //galil
	6,  //famas
	16, //usp
	13, //glock
	6,  //awp
	6,  //mp5
	5,  //m249
	7,  //m3
	14, //m4a1
	6,  //tmp
	5,  //g3sg1
	0,  //flashbang
	6,  //deagle
	6,  //sg552
	6,  //ak47
	8,  //knife
	6   //p90
}

new Float: IdleCallTime [ ] = 
{
    0.0,    //null
    5.2,    //p228
    0.0,    //shield
    5.0,    //scout
    0.0,    //hegrenade
    4.4,    //xm1014
    0.0,    //c4
    5.1,    //mac10
    3.4,    //aug
    0.0,    //smoke grenade
    4.5,    //elites
    5.2,    //fiveseven
    5.3,    //ump45
    5.2,    //sg550
    3.7,    //galil
    3.4,    //famas
    6.1,    //usp
    5.2,    //glock
    5.0,    //awp
    7.7,    //mp5
    5.5,    //m249
    4.5,    //m3
    4.8,    //m4a1
    5.8,    //tmp
    3.5,    //g3sg1
    0.0,    //flashbang
    5.7,    //deagle
    3.7,    //sg552
    4.4,    //ak47
    4.9,    //knife
    4.2 //p90
}

new const MAX_BP_AMMO [  ] = 
{
	0,
	30,
	90,
	200,
	90,
	32,
	100,
	100,
	35,
	52,
	120
}

new FRAG_SPRITES [11] [ ] =
{
	"number_0",
	"number_1",
	"number_2",
	"number_3",
	"number_4",
	"number_5",
	"number_6",
	"number_7",
	"number_8",
	"number_9",
	"dmg_rad"
};


new const BlockTexts [ ] [ ]  = { "#", "$", "%" };


const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

new const m_rgpPlayerItems_CWeaponBox [6] = {34, 35, ...};


new GrenadeName [3] [ ] =
{
	"weapon_hegrenade",
	"weapon_flashbang",
	"weapon_smokegrenade"
};


new const ANTI_UNCOMPRESS [ ] = "no_amxx_uncompress";

	
new SQL_TABLE [ ] = "csgo_infinity";

new SQL_HOST [ ] = "188.212.101.119";

new SQL_USER [ ] = "u1327_kwhzVuCecA";

new SQL_PASSWORD [ ] = "@gdgIk7jHf1R!fVqGhm!3Z4k";

new SQL_DATABASE [ ] = "s1327_go16";

/*new SQL_TABLE [ ] = "teste_csgo";

new SQL_HOST [ ] = "188.212.101.119";

new SQL_USER [ ] = "u525_JjiDMCuEUM";

new SQL_PASSWORD [ ] = "khubv+JW16Jfig5NV.qnd@Ee";

new SQL_DATABASE [ ] = "s525_testecsgo";*/


new const T_WIN                  [ ] =  "csgo/twin.wav";

new const CT_WIN                 [ ] =  "csgo/ctwin.wav"

new const SPRAY_SOUND	         [ ] =  "csgo/ultimatex_sprayer.wav";

new const COMMON_CLASS  	[ ] = "csgo/common.wav";

new const RARE_CLASS  		[ ] = "csgo/rare.wav";

new const MYTHICAL_CLASS  	[ ] = "csgo/mythical.wav";

new const LEGENDARY_CLASS  	[ ] = "csgo/legendary.wav";

new const VIP_V_INJECTOR    [ ]	= "models/v_healtshoot_new.mdl";

new const VIP_P_INJECTOR    [ ]	= "models/p_healthshot.mdl"; 


new Name [33] [32], Director [48], File [10] [48], GoSettings [MAX_CVARS], RangName [32] [48], RangKills [32], 

RangsNum, iUserRang [33], iUserKills [33], ChestName [32] [30], ChestChance [11],

ChestMinPrice [11], ChestMaxPrice [11], ChestsNum = 1, iUserChests [33] [32], iUserCaps [33],

iUserKeys [33] [32], iLastOpenCraft [33], iUserSkins [33] [SKINS_LIMIT + 1],

SkinID [SKINS_LIMIT + 1], SkinName[SKINS_LIMIT + 1] [128], SkinMdl[SKINS_LIMIT + 1] [128], 

SkinChance [SKINS_LIMIT + 1], SkinMinPrice [SKINS_LIMIT + 1], SkinMaxPrice [SKINS_LIMIT + 1],

SkinChest [SKINS_LIMIT + 1], g_iSkinBody[SKINS_LIMIT + 1], SkinsNum = 1, iUserSTs [33] [SKINS_LIMIT + 1], 

iUserSelectedSkin [33] [25], iUserSelectedSound [33], TrackName[MAX_MVPS + 1] [32], TrackUrl[MAX_MVPS + 1] [48], TrackCost [MAX_MVPS + 1],

TrackLeft [MAX_MVPS + 1], TrackRemaining [33] [MAX_MVPS + 1], TracksNum, iUserSavedTag [33] [16], bool: PlayerHasTag [33],

TagFile [128], iMvpKills [33], iMvpHead [33], Float: fMvpDamage [33], iUserMVP [33],

iUserPoints [33], iUserDusts [33], STKills [33] [SKINS_LIMIT + 1], wPickUp [801] [3], 

wPickUp1 [801] [96], wPickUp2 [801] [96], sDustForTransform,

bool: iLogged [33], iUserSavedPass [33] [16], iUserPassword [33] [16], iUserPassFail [33], iLastPreview [33],

Handle: iSqlTuple, bool: InspectToggle [33], MaxGrf [10], SprayCount, SprayCooldown [33], 

iUserSelectedSpray [33], SpraysNum, SprayRemaining [33] [21], SprayName [32] [21], 

SprayLeft [21], sSprayCooldown, 

sOverrideMenu, sPasswordField [9], sContractCost, sBuyChatTag, ItemName [33], TypeName [33], Quantity [33],

SyncHud1, SyncHud2, WeaponDropped, SkinInfo [33],/* pAmxMode, iAmxMode = 1, iMostDamage [33], iDamage [33] [33],

bool: IsChangeAllowed [33], MsgDeathMsg, MsgSayText, */ UserMaxRang [33], sHMinPoints, sHMaxPoints, 

sKMinPoints, sKMaxPoints, iScore [2], sCompetitiveMode, sWarmTimer, bool: WarmUp = false, bool: TeamSwap = false,

iRoundNum = 0, MaxPlayers, sMVPBonus, sDropChance, sWaitForPlace, iLastPlace [33], iUserSellItem [33], 

bool: iUserSell [33], iUserItemPrice [33], iGiftTarget [33], iGiftItem [33],

SkinTagN [33] [SKINS_LIMIT + 1] [33], SkinTag [33] [SKINS_LIMIT + 1], SkinTagS [33], TagInput [33] [17],

iTradeTarget [33], iTradeItem [33], iTradeRequest [33], bool: bTradeActive [33], 

bool: bTradeAccept [33], bool: bTradeSecond [33], bool: iFirstSpawn [33],

bool: ShortThrow [33], iDay [33], Array: aTombola, sTombolaCost, sTombolaTimer, iNextTombolaStart, 

iTombolaPlayers, iTombolaPrize, bool: bUserPlay [33], iDigit [33],

SqlLine [2520], MysqlFormat [25000], SqlError [512], sRenameSkinTagPrice,

Array: aJackpotSkins, Array: aJackpotUsers, bool: bJackpotWork, iUserJackpotItem [33], bool: bUserPlayJackpot [33],

iJackpotClose, sJackpotTimer, iUserUpgradeItem [33], Array: aBattleUsers, Array: aBattleCases, sSkinTagPrice,

bool: bUserPlayBattle [33], iBattleClose, sBattleTimer, bool: bBattleWork, iBattleItem [33], bool: HasTrade [33],

iForwards [8], iForwardResult, sID, sTime, bool: GiveAwayRound = false, sGiveAwayLimit, bool: IsGiveAway = false,

bRouletteWork = true, iRouletteType [33], iRouletteBet [33] [3], iRouletteNr [7] [8], iRoulettePlayers, 

iRouletteTimer = 60, sRouletteBetLimit, PromoNums, PromoCode [32] [100], PromoPoints [100], PromoUse [33] [100], PromoName [100], sLogFade,

DerankCount [33], sDerankCount, sBuyCKMultiplier, sUpgradeMultiplier, sVipBonusMultiplier, sDropStatTrakChance, sUpgradeChance,

sTagStatTrakCostMultiplier, sTagCostMultiplier, sStatTrakCostMultiplier, sPreviewDelay, sOpenChestsDelay,
 
LastModelV [33] [50], LastModelP [33] [50], InjectorAmmo [33], sInjectorAmmo, sInjectorHeal, MapName [16] [16],

MapFlag [16] [16], MapsNum, VipStopped [2], iHoursPlayed [33], sRewardHoursPlayed, HoursVault, 

bool: MVPAllowed [33], SendQuantity [33], sGuessNumberCost, sGuessNumberEarn, sGuessNumberDelay,

bool: bGuessNumWork, bool: bUserBet [33], SelectBetTeam [33], bool: BetWork, BetValue [33], sBetTeamLimit, sBetTeamMultiplier,

sBetMinPlayersReq, TFactionName [32] [32], CTFactionName [32] [32], TFactionMdl [32] [32], CTFactionMdl [32] [32],

FactionKills [32], FactionsNum = 1, iUserSelectedFaction [33] [2], sGrfModel [120],

g_iUserSelectedGlove [33], g_iUserSelectedSkin[MAX_PLAYERS + 1][31], g_iUserViewBody[MAX_PLAYERS + 1], iSpectatorTarget [33], iUserGloveBoxes [33], iUserGloves [33] [21],

GloveName [32] [21], GloveMinPrice [11], GloveMaxPrice [11], GloveChance [11], GloveIndex[11], GlovesNum = 1, iMenuType [33], sTransformRest,

bool: Checked [33];

new g_Data [SKINS_LIMIT + 1] [17];

stock bool: is_user_vip ( id ) 
{
    if ( get_user_flags ( id ) & ADMIN_LEVEL_F )
        
        return true;
    
    return false;
}

public plugin_precache (  )
{
	new Line [1048], Data [8] [64], Len, Loaded, sz = charsmax ( Data [ ] );

	get_configsdir ( Director, charsmax ( Director ) );

	server_cmd ( ANTI_UNCOMPRESS );

	server_print ( ANTI_UNCOMPRESS );

	formatex ( File [0], charsmax ( File [ ] ), "%s/csgo/rangs.cfg", Director );

	formatex ( File [1], charsmax ( File [ ] ), "%s/csgo/chests.cfg", Director );

	formatex ( File [2], charsmax ( File [ ] ), "%s/csgo/skins.cfg", Director );

	formatex ( File [3], charsmax ( File [ ] ), "%s/csgo/sprays.cfg", Director );

	formatex ( File [4], charsmax ( File [ ] ), "%s/csgo/tracks.cfg", Director );

	formatex ( File [5], charsmax ( File [ ] ), "%s/csgo/factions.cfg", Director );

	formatex ( File [6], charsmax ( File [ ] ), "%s/csgo/promocodes.cfg", Director );

	formatex ( File [7], charsmax ( File [ ] ), "%s/csgo/vb_maps.cfg", Director );

	formatex ( File [8], charsmax ( File [ ] ), "%s/csgo/precache.cfg", Director );

	formatex ( File [9], charsmax ( File [ ] ), "%s/csgo/gloves.cfg", Director );

	formatex ( iRouletteNr [0], charsmax ( iRouletteNr [ ] ), "\w-");
	formatex ( iRouletteNr [1], charsmax ( iRouletteNr [ ] ), "\w-");
	formatex ( iRouletteNr [2], charsmax ( iRouletteNr [ ] ), "\w-");
	formatex ( iRouletteNr [3], charsmax ( iRouletteNr [ ] ), "\w-");
	formatex ( iRouletteNr [4], charsmax ( iRouletteNr [ ] ), "\w-");
	formatex ( iRouletteNr [5], charsmax ( iRouletteNr [ ] ), "\w-");
	formatex ( iRouletteNr [6], charsmax ( iRouletteNr [ ] ), "\w-");

	if ( file_exists ( "addons/amxmodx/configs/plugins.ini" ) )
	{
		for ( new i; i < file_size ( "addons/amxmodx/configs/plugins.ini", 1); i ++ )
		{
			read_file ( "addons/amxmodx/configs/plugins.ini", i, Line, charsmax ( Line ), Len );
			
			if ( strlen ( Line ) < 5 || Line [0] == ';' )

				continue;
			
			parse ( Line, Data [0], sz, Data [1], sz, Data [2], sz, Data [3], sz, Data [4], sz, Data [5], sz );
			
			for ( new z; z < 6; z ++ )
			{
				if ( equal ( Data [z], "csgo_infinity.amxx" ) )
				{
					Loaded = 1
				}
			}
		}
		if ( !Loaded )
		{
			set_fail_state ( "* Pluginul ^"csgo_infinity.amxx^" nu a fost gasit in lista!" );
		}
	}

	if ( file_exists ( File [0] ) )
	{
		for ( new i = 0; i < file_size ( File [0], 1 ); i ++ )
		{
			read_file ( File [0], i, Line, charsmax ( Line ), Len );

			if ( Line [0] == ';' || strlen ( Line ) < 5 )
				
				continue;

			parse ( Line, Data [0], sz, Data [1], sz );
			
			copy ( RangName [RangsNum], charsmax ( RangName [ ] ), Data [0] );

			RangKills [RangsNum] = str_to_num ( Data [1] );

			RangsNum ++;
		}

		if ( RangsNum == 0 )
		{
			LogToFile ( "|CS:GO Infinity| No rang was not found in the file!" );

			server_print ( "|CS:GO Infinity| No rang was not found in the file!" );
		}
	}

	if ( file_exists ( File [1] ) )
	{
		for ( new i = 0; i < file_size ( File [1], 1 ); i ++ )
		{
			read_file ( File [1], i, Line, charsmax ( Line ), Len );

			if ( strlen ( Line ) < 5 || Line [0] == ';' || ChestsNum > 10 )

				continue;

			parse ( Line, Data [0], sz, Data [1], sz, Data [2], sz, Data [3], sz );

			copy ( ChestName [ChestsNum], charsmax ( ChestName [ ] ), Data [0] );

			ChestChance [ChestsNum] = str_to_num ( Data [1] );

			ChestMinPrice [ChestsNum] = str_to_num ( Data [2] );

			ChestMaxPrice [ChestsNum] = str_to_num ( Data [3] );

			ChestsNum ++;
		}

		if ( ChestsNum == 1 )
		{
			LogToFile ( "|CS:GO Infinity| No chest was not found in the file!" );

			server_print ( "|CS:GO Infinity| No chest was not found in the file!" );
		}
	}

	if ( file_exists ( File [2] ) )
	{
		for ( new i = 0; i < file_size ( File [2], 1 ); i ++ )
		{
			read_file ( File [2], i, Line, charsmax ( Line ), Len );

			if ( strlen ( Line ) < 5 || Line [0] == ';' || SkinsNum > SKINS_LIMIT )
			{
				continue;
			}

			parse ( Line, Data [0], sz, Data [1], sz, Data [2], sz, Data [3], sz, Data [4], sz, Data [5], sz, Data [6], sz, Data[7], sz );

			SkinID [SkinsNum] = str_to_num ( Data [0] );

			copy ( SkinName [SkinsNum], charsmax ( SkinName [ ] ), Data [1] );

			if ( ValidMdl ( Data [2] ) )
			{
				precache_model ( Data [2] );

				copy ( SkinMdl [SkinsNum], charsmax ( SkinMdl [ ] ), Data [2] );
			}

			SkinChance [SkinsNum] = str_to_num ( Data [3] );

			SkinMinPrice [SkinsNum] = str_to_num ( Data [4] );

			SkinMaxPrice [SkinsNum]= str_to_num ( Data [5] );

			SkinChest [SkinsNum] = str_to_num ( Data [6] );

			g_iSkinBody[SkinsNum] = str_to_num(Data[7]);

			SkinsNum ++;
		}

		if ( SkinsNum == 1 )
		{
			LogToFile ( "|CS:GO Infinity| No skin was not found in the file!" );

			server_print ( "|CS:GO Infinity| No skin was not found in the file!" );
		}
	}

	if ( file_exists ( File [3] ) )
	{
		for ( new i = 0; i < file_size ( File [3], 1 ); i ++ )
		{
			read_file ( File [3], i, Line, charsmax ( Line ), Len );

			if ( strlen ( Line ) < 5 || Line [0] == ';' || SpraysNum > 20 )

				continue;

			parse ( Line, Data [0], sz, Data [1], sz );

			copy ( SprayName [SpraysNum], charsmax ( SprayName [ ] ), Data [0] );

			SprayLeft [SpraysNum] = str_to_num ( Data [1] );

			SpraysNum ++;
		}

		if ( !SpraysNum )
		{
			LogToFile ( "|CS:GO Infinity| No spray was not found in the file!" );

			server_print ( "|CS:GO Infinity| No spray was not found in the file!" );
		}
	}

	if ( file_exists ( File [4] ) )
	{
		for ( new i = 0; i < file_size ( File [4], 1 ); i ++ )
		{
			read_file ( File [4], i, Line, charsmax ( Line ), Len );

			if ( strlen ( Line ) < 5 || Line [0] == ';' || TracksNum > MAX_MVPS )

				continue;

			parse ( Line, Data [0], sz, Data [1], sz, Data [2], sz, Data [3], sz );

			copy ( TrackName [TracksNum], charsmax ( TrackName [ ] ), Data [0] );

			if ( ValidSnd ( Data [1] ) )
			{
				if ( equal ( Data [1] [strlen ( Data [1] ) - 4], ".mp3" ) )
				{
					new fUrl [32];

					formatex ( fUrl, charsmax ( fUrl ), "sound/%s", Data [1] );

					precache_generic ( fUrl );
				}
				else
				{
					precache_sound ( Data [1] );
				}

				copy ( TrackUrl [TracksNum], charsmax ( TrackUrl [ ] ), Data [1] );
			}

			TrackCost [TracksNum] = str_to_num ( Data [2] );

			TrackLeft [TracksNum] = str_to_num ( Data [3] );

			TracksNum ++;
		}

		if ( TracksNum == 0 )
		{
			LogToFile ( "|CS:GO Infinity| No track was not found in the file!" );

			server_print ( "|CS:GO Infinity| No track was not found in the file!" );
		}
	}

	if ( file_exists ( File [5] ) )
	{
		for ( new i = 0; i < file_size ( File [5], 1 ); i ++ )
		{
			read_file ( File [5], i, Line, charsmax ( Line ), Len );

			if ( strlen ( Line ) < 5 || Line [0] == ';' || FactionsNum > 10 )
			
				continue;

			new Temp [96];

			// "Nume T" "model T" "Nume CT" "model CT" "Kill-uri"
			parse ( Line, Data [0], sz, Data [1], sz, Data [2], sz, Data [3], sz, Data [4], sz );

			copy ( TFactionName [FactionsNum], charsmax ( TFactionName [ ] ), Data [0] );

			//if ( ValidMdl ( Data [1] ) )
			//{
			formatex ( Temp, charsmax ( Temp ), "models/player/%s/%s.mdl", Data [1], Data [1] );

			precache_model ( Temp );

			copy ( TFactionMdl [FactionsNum], charsmax ( TFactionMdl [ ] ), Data [1] );
			//}

			copy ( CTFactionName [FactionsNum], charsmax ( TFactionName [ ] ), Data [2] );

			//if ( ValidMdl ( Data [3] ) )
			//{
			formatex ( Temp, charsmax ( Temp ), "models/player/%s/%s.mdl", Data [3], Data [3] );

			precache_model ( Temp );

			copy ( CTFactionMdl [FactionsNum], charsmax ( CTFactionMdl [ ] ), Data [3] );
			//}

			FactionKills [FactionsNum] = str_to_num ( Data [4] );

			FactionsNum ++;
		}

		if ( FactionsNum == 1 )
		{
			LogToFile ( "|CS:GO Infinity| No faction was not found in the file!" );

			server_print ( "|CS:GO Infinity| No faction was not found in the file!" );
		}
	}

	if ( file_exists ( File [6] ) )
	{
		for ( new i; i < file_size ( File [6], 1 ); i ++ )
		{
			read_file ( File [6], i, Line, charsmax ( Line ), Len );

			if ( Line [0] == ';' || strlen ( Line ) < 5 || PromoNums == 99 )

				continue;

			parse ( Line, Data [0], sz, Data [1], sz );
			
			copy ( PromoCode [PromoNums], charsmax ( PromoCode [ ] ), Data [0] );

			PromoName [PromoNums] = nvault_open ( PromoCode [PromoNums]);

			PromoPoints [PromoNums] = str_to_num ( Data [1] );

			PromoNums ++;
		}
	}

	if ( file_exists ( File [7] ) )
	{
		for ( new i; i < file_size ( File [7], 1 ); i ++ )
		{
			read_file ( File [7], i, Line, charsmax ( Line ), Len );

			if ( Line [0] == ';' || strlen ( Line ) < 5 )

				continue;

			parse ( Line, Data [0], sz, Data [1], sz );
			
			copy ( MapName [MapsNum], charsmax ( MapName [ ] ), Data [0] );

			copy ( MapFlag [MapsNum], charsmax ( MapFlag [ ] ), Data [1] );

			MapsNum ++;
		}
	}

	if ( file_exists ( File [8] ) )
	{
		for ( new i; i < file_size ( File [8], 1 ); i ++ )
		{
			read_file ( File [8], i, Line, charsmax ( Line ), Len );

			if ( Line [0] == ';' || strlen ( Line ) < 5 )

				continue;

			//parse ( Line, Data [0], 7 );

			if ( ValidMdl ( Line ) )
			{
				precache_model ( Line );

				copy ( sGrfModel, charsmax ( sGrfModel ), Line );
			}
		}
	}

	if ( file_exists ( File [9] ) )
	{
		for ( new i = 0; i < file_size ( File [9], 1 ); i ++ )
		{
			read_file ( File [9], i, Line, charsmax ( Line ), Len );

			if ( strlen ( Line ) < 5 || Line [0] == ';' || GlovesNum > 10 )

				continue;

			parse ( Line, Data [0], sz, Data [1], sz, Data [2], sz, Data [3], sz, Data[4], sz );

			copy ( GloveName [GlovesNum], charsmax ( GloveName [ ] ), Data [0] );

			GloveMinPrice [GlovesNum] = str_to_num ( Data [1] );

			GloveMaxPrice [GlovesNum] = str_to_num ( Data [2] );

			GloveChance [GlovesNum] = str_to_num ( Data [3] );

			GloveIndex [GlovesNum] = str_to_num( Data[4] );

			GlovesNum ++;
		}

		if ( GlovesNum == 1 )
		{
			LogToFile ( "|CS:GO Infinity| No glove was not found in the file!" );

			server_print ( "|CS:GO Infinity| No glove was not found in the file!" );
		}
	}

	precache_sound ( T_WIN );
	
	precache_sound ( CT_WIN );

	precache_sound ( SPRAY_SOUND );

	precache_model ( sGrfModel );

	precache_sound ( COMMON_CLASS );

	precache_sound ( RARE_CLASS );

	precache_sound ( MYTHICAL_CLASS );

	precache_sound ( LEGENDARY_CLASS );

	precache_model ( VIP_V_INJECTOR );

	precache_model ( VIP_P_INJECTOR );
}

public plugin_end (  ) 
{
	ArrayDestroy ( aTombola );

	ArrayDestroy ( aJackpotSkins );
	
	ArrayDestroy ( aJackpotUsers );

	ArrayDestroy ( aBattleCases );
	
	ArrayDestroy ( aBattleUsers );

	for ( new i = 0;i < PromoNums; i ++ )
	{
		nvault_close ( PromoName [i] )
	}

	nvault_close ( HoursVault );

	if ( iSqlTuple != Empty_Handle )
	{
		SQL_FreeHandle ( iSqlTuple );
	}
}

public plugin_init (  )
{
	register_plugin ( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );

	if ( !is_regamedll (  ) || !is_rehlds (  ) ) 
	{
       		set_fail_state ( "* Needs CS ReGameDLL and ReHLDS" );
    }

	register_cvar ( "csgo_infinity_version", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY );
	
	set_cvar_string ( "csgo_infinity_version", PLUGIN_VERSION );
	
	register_cvar ( "csgo_infinity_author", PLUGIN_AUTHOR, FCVAR_SERVER | FCVAR_SPONLY );

	set_cvar_string ( "csgo_infinity_author", PLUGIN_AUTHOR );

	register_dictionary ( "csgo_infinity.txt" );

	new CurrentMap [32]; get_mapname ( CurrentMap, charsmax ( CurrentMap ) );

	for ( new i = 0; i < MapsNum; i ++ )
	{
		if ( equali ( CurrentMap, MapName [i] ) )
		{
			if ( equali ( MapFlag [i], "a" ) )
			{
				VipStopped [0] = true;

				server_print ( "[CS:GO Infinity] Functia ^"HP Injection^" a fost oprita pe harta: %s", CurrentMap );
			}
			else if ( equali ( MapFlag [i], "b" ) )
			{
				VipStopped [1] = true;

				server_print ( "[CS:GO Infinity] Functia ^"Multi Points^" a fost oprita pe harta: %s", CurrentMap );
			}
			else if ( equali ( MapFlag [i], "ab" ) )
			{
				VipStopped [0] = true;

				VipStopped [1] = true;

				server_print ( "[CS:GO Infinity] Functiile VIP au fost oprite pe harta: %s", CurrentMap );
			}
		}
	}

	register_event ( "DeathMsg", "EventDeathMsg", "a" );

	//register_event ( "Damage", "EventDamage", "be", "2!0", "3=0", "4!0" )

	register_event ( "HLTV", "EventNewRound", "a", "1=0", "2=0" );

	register_event ( "CurWeapon" , "CurrentWeapon" , "be" , "1=1" );

	register_event ( "SendAudio", "EventRoundWonT" , "a", "2&%!MRAD_terwin" );
	
	register_event ( "SendAudio", "EventRoundWonCT", "a", "2&%!MRAD_ctwin" );

	register_event ( "SendAudio", "EventRoundDraw", "a", "2&%!MRAD_ROUNDDRAW" );

	//register_event ( "ScreenFade", "EventFlash", "b", "4=255", "5=255", "6=255", "7>199" );

	register_logevent ( "leRoundEnd", 2, "1=Round_End" );

	register_logevent ( "leGameCommencing", 2, "1&Game_Commencing" );

	register_logevent ( "leRestartRound", 2, "1&Restart_Round" );

	RegisterHam ( Ham_Killed, "player", "HamPlayerKilledPost", 1 );

	RegisterHam ( Ham_Spawn, "player", "HamPlayerSpawnPre", 0 );

	RegisterHam ( Ham_Spawn, "player", "HamPlayerSpawnPost", 1 );

	RegisterHam ( Ham_TakeDamage, "player", "HamPlayerTakeDamage" );

	RegisterHam ( Ham_Item_Holster, "weapon_knife", "HamKnifeHolstered", 1 );

	for ( new i = 0; i < sizeof ( GrenadeName ); i ++ )
	{
		RegisterHam ( Ham_Weapon_PrimaryAttack, GrenadeName [i], "HamGrenadePA", 1 );
        
		RegisterHam ( Ham_Weapon_SecondaryAttack, GrenadeName [i], "HamGrenadeSA", 1 );
	}

	for ( new i; i < sizeof ( WEAPON_NAMES ); i ++ )
	{
		if ( WEAPON_NAMES [i] [0] )
		{
			RegisterHam ( Ham_Item_Kill, WEAPON_NAMES [i], "RemoveWeapons", 0 );
		}

		RegisterHam ( Ham_CS_Weapon_SendWeaponAnim, WEAPON_NAMES [i], "HamCSWeaponSendWeaponAnimPost", true );
	}
	
	register_forward ( FM_PlaybackEvent, "ForwardPlaybackEvent" );

	register_event ( "StatusValue", "iSpectatorViewBody", "bd", "1=2" );
	
	register_event ( "SpecHealth2", "iSpectatorViewBody", "bd" );	

	RegisterHam ( Ham_Killed, "player", "HamPlayerKilledPre", 0 );

	RegisterHookChain ( RG_CBasePlayer_DropPlayerItem, "PlayerDropItemPost", 1 );

	iForwards [0] = CreateMultiForward ( "fw_csgo_user_logout", ET_IGNORE, FP_CELL );

	iForwards [1] = CreateMultiForward ( "fw_csgo_open_capsule", ET_IGNORE, FP_CELL );

	iForwards [2] = CreateMultiForward ( "fw_csgo_spray", ET_IGNORE, FP_CELL );

	iForwards [3] = CreateMultiForward ( "fw_csgo_save_log", ET_IGNORE, FP_CELL );

	iForwards [4] = CreateMultiForward ( "fw_csgo_user_mvp", ET_IGNORE, FP_CELL );

	iForwards [5] = CreateMultiForward ( "fw_csgo_user_login", ET_IGNORE, FP_CELL );

	iForwards [6] = CreateMultiForward ( "fw_csgo_user_make_kills", ET_IGNORE, FP_CELL, FP_CELL );

	iForwards [7] = CreateMultiForward ( "fw_csgo_dropped_chest", ET_IGNORE, FP_CELL, FP_CELL );

	//MsgDeathMsg = get_user_msgid ( "DeathMsg" );

	//MsgSayText = get_user_msgid ( "SayText" );

	//register_message ( MsgDeathMsg, "MessageDeathMsg" );

	register_message ( get_user_msgid ( "SendAudio" ),"MessageSendAudio" );

	register_forward ( FM_ClientUserInfoChanged, "ClientUserInfoChanged", 0 );

	register_touch ( "weaponbox", "player", "fwTouch" );

	register_impulse ( 201, "PutGraffiti" );

	register_impulse ( 100, "InspectWeapon" );

	register_clcmd ( "inspect", "InspectWeapon" );

	register_clcmd ( "radio3", "UserInjector" );

	GoSettings [OVERRIDE_MENU] = register_cvar ( "csgo_override_menu", "1" );

	GoSettings [PASSWORD_FIELD] = register_cvar ( "csgo_password_field", "_csgo" );

	GoSettings [CONTRACT_COST] = register_cvar ( "csgo_contract_cost", "10" );

	GoSettings [CHAT_TAG_COST] = register_cvar ( "csgo_chattag_cost", "20" );

	GoSettings [DUST_FOR_TRANSFORM] = register_cvar ( "csgo_dust_for_transform", "1" ); 
	
	GoSettings [SPRAY_COOLDOWN] = register_cvar ( "csgo_graffiti_cooldown", "10" ); 

	GoSettings [RANG_UP_BONUS] = register_cvar ( "csgo_rangup_bonus", "kc|100" );

	GoSettings [HS_MIN_POINTS] = register_cvar ( "csgo_head_min_points", "3" );

	GoSettings [HS_MAX_POINTS] = register_cvar ( "csgo_head_max_points", "4" );

	GoSettings [KILL_MIN_POINTS] = register_cvar ( "csgo_kill_min_points", "1" );

	GoSettings [KILL_MAX_POINTS] = register_cvar ( "csgo_kill_max_points", "2" );

	GoSettings [COMPETITIVE_MODE] = register_cvar ( "csgo_competitive_mode", "1" );

	GoSettings [WARMUP_DURATION] = register_cvar ( "csgo_warmup_duration", "10" );

	GoSettings [BEST_POINTS] = register_cvar ( "csgo_bestmvp_points", "20" );

	GoSettings [DROP_CHANCE] = register_cvar ( "csgo_drop_chance", "10" );

	GoSettings [WAIT_FOR_PLACE] = register_cvar ( "csgo_wait_for_place", "30" );

	GoSettings [TOMBOLA_COST] = register_cvar ( "csgo_tombola_cost", "50" );

	GoSettings [TOMBOLA_TIMER] = register_cvar ( "csgo_tombola_timer", "180" );

	GoSettings [JACKPOT_TIMER] = register_cvar ( "csgo_jackpot_timer", "120" );

	GoSettings [BATTLE_TIMER] = register_cvar ( "csgo_battle_timer", "80" );

	GoSettings [SET_SKIN_TAG_PRICE] = register_cvar ( "csgo_skintag_price", "150000" );

	GoSettings [RENAME_SKIN_TAG_PRICE] = register_cvar ( "csgo_rename_skintag_price", "50000" );

	GoSettings [GIVEAWAY_LIMIT] = register_cvar ( "csgo_giveaway_logreq", "6" );

	GoSettings [LOG_SCREEN_FADE] = register_cvar ( "csgo_log_screenfade", "1" );

	GoSettings [DERANK_COUNT] = register_cvar ( "csgo_derank_count", "3" );

	GoSettings [BUY_CK_MULTIPLIER] = register_cvar ( "csgo_buy_ck_multiplier", "2" );

	GoSettings [UPGRADE_MULTIPLIER] = register_cvar ( "csgo_upgrade_multiplier", "2" );

	GoSettings [VIP_BONUS_MULTIPLIER] = register_cvar ( "csgo_vip_bonus_multiplier", "2" );

	GoSettings [TAG_STATTRAK_COST_MULTIPLIER] = register_cvar ( "csgo_tag_stattrak_cost_multiplier", "4" );

	GoSettings [TAG_COST_MULTIPLIER] = register_cvar ( "csgo_tag_cost_multiplier", "3" );

	GoSettings [STATTRAK_COST_MULTIPLIER] = register_cvar ( "csgo_stattrak_cost_multiplier", "2" );

	GoSettings [ROULETTE_BET_LIMIT] = register_cvar ( "csgo_bet_limit", "1000" );

	GoSettings [VIP_INJECTOR_AMMO] = register_cvar ( "csgo_injector_ammo", "2" );

	GoSettings [VIP_INJECTOR_HEAL] = register_cvar ( "csgo_injector_heal", "25" );

	GoSettings [REWARD_HOURS_PLAYED] = register_cvar ( "csgo_reward_hours_played", "1" );

	GoSettings [PREVIEW_DELAY] = register_cvar ( "csgo_preview_delay", "10" );

	GoSettings [OPEN_CHESTS_DELAY] = register_cvar ( "csgo_open_chests_delay", "5" );

	GoSettings [DROP_STATTRAK_CHANCE] = register_cvar ( "csgo_drop_stattrak_chance", "1" );

	GoSettings [UPGRADE_CHANCE] = register_cvar ( "csgo_upgrade_chance", "50" );

	GoSettings [GUESS_NUMBER_COST] = register_cvar ( "csgo_guessthenumber_price", "2500" );

	GoSettings [GUESS_NUMBER_EARN] = register_cvar ( "csgo_guessthenumber_earn", "22500" );

	GoSettings [GUESS_NUMBER_DELAY] = register_cvar ( "csgo_guessthenumber_delay", "120" );

	GoSettings [BET_TEAM_MULTIPLIER] = register_cvar ( "csgo_bet_team_multiplier", "2" );

	GoSettings [BET_TEAM_LIMIT] = register_cvar ( "csgo_bet_team_limit", "100000" );

	GoSettings [BET_MIN_PLAYERS_REQ] = register_cvar ( "csgo_bet_minplayers_req", "3" );

	GoSettings [ITEM_TRANSFORM_REST] = register_cvar ( "csgo_item_transform_rest", "4" );

	//pAmxMode = get_cvar_pointer ( "amx_mode" );

	register_menucmd ( register_menuid ( "DCT_BuyItem", 1 ), (1<<7), "BuyShield" );

	register_clcmd ( "csgo_giveaway", "ClCmdGiveAway", ADMIN_IMMUNITY, "<SkinID> <SkinType> <Time in seconds>" );

	register_clcmd ( "csgo_setpointselders", "ClCmdGivePoints", ADMIN_IMMUNITY, "<Name> <Amount>", -1 );

	register_clcmd ( "csgo_setcaps", "ClCmdGiveCaps", ADMIN_IMMUNITY, "<Name> <Amount>", -1 );
	
	register_clcmd ( "csgo_setcases", "ClCmdGiveCases", ADMIN_IMMUNITY, "<Name> <CaseID> <Amount>", -1 );
	
	register_clcmd ( "csgo_setkeys", "ClCmdGiveKeys", ADMIN_IMMUNITY, "<Name> <KeyID> <Amount>", -1 );

	register_clcmd ( "csgo_setdusts", "ClCmdGiveDusts", ADMIN_IMMUNITY, "<Name> <Amount>", -1 );
	
	register_clcmd ( "csgo_setrang", "ClCmdSetRang", ADMIN_IMMUNITY, "<Name> <RangID>", -1 );

	register_clcmd ( "csgo_setskins", "ClCmdGiveSkins", ADMIN_IMMUNITY, "<Name> <SkinID> <SkinType> <Amount>", -1 );

	register_clcmd ( "csgo_giveskins", "ClCmdGiveAllSkins", ADMIN_IMMUNITY, "<Name> <SkinType>", -1 );

	register_clcmd ( "csgo_set_glovebox", "ClCmdGiveGloveBox", ADMIN_IMMUNITY, "<Name> <Amount>", -1 );

	register_clcmd ( "chooseteam", "ClCmdChooseTeam" );

	register_clcmd ( "drop", "WeaponPickUp" );

	register_clcmd ( "UserPassword", "PlayerPassword" );

	register_clcmd ( "UserTag", "PlayerTag" );

	register_clcmd ( "NameTag", "SetSkinTag" );

	register_clcmd ( "ReNameTag", "ReNameSkinTag" );

	register_clcmd ( "ItemPrice", "CmdItemPrice")

	register_clcmd ( "Bet", "BetRoulette" );

	register_clcmd ( "TypeCode", "TypePromoCode" );

	register_clcmd ( "InputValue", "GiftValue" );

	register_clcmd ( "GuessTheNumber", "InputNumber" );

	register_clcmd ( "BetTeam", "InputValueBetTeam" );

	register_clcmd ( "radio2", "ImpulsePickUp" );

	register_clcmd ( "say /accept", "ClCmdSayAccept" );

	register_clcmd ( "say /deny", "ClCmdSayDeny" );

	register_clcmd ( "say /reg", "ShowRegMenu", -1 );

	register_clcmd ( "say /menu", "ShowMainMenu", -1 );

	register_clcmd ( "say /skin", "ClCmdSaySkin" );

	register_clcmd ( "say /gloves", "ClCmdSayGloves" );

	register_clcmd ( "say", "CheckSay" ); 
	
	register_clcmd ( "say_team", "CheckSayTeam" );

	HoursVault = nvault_open ( "PlayedTime" );

	if ( HoursVault == INVALID_HANDLE )
	{
		set_fail_state ( "Eroare la deschiderea bazei de date din folderul vault." );
	} 

	SyncHud1 = CreateHudSyncObj (  );

	SyncHud2 = CreateHudSyncObj (  );

	MaxPlayers = get_maxplayers (  );

	if ( file_exists ( "addons/amxmodx/configs/csgo_infinity.cfg" ) )
	{
		server_cmd ( "exec %s/csgo_infinity.cfg", Director );

		server_print ( "* Fisierul ^"csgo_infinity.cfg^" a fost executat cu succes!" );
	}
	else
	{
		server_print ( "* Fisierul ^"csgo_infinity.cfg^" nu a fost gasit! Incarc setarile default!" );
	}


	set_task ( 1.0, "CacheSettings" );
}

public UserInjector ( id )
{
	if ( !is_user_alive ( id ) || !is_user_vip ( id ) || !InjectorAmmo [id] || VipStopped [0] )
	{
		return PLUGIN_HANDLED;
	}

	if ( get_user_health ( id ) >= 100 )
	{
		return PLUGIN_HANDLED;
	}

	InjectorAmmo [id] --;
			
	remove_task ( id + 25071973 );

	set_pdata_float ( id, 83, 2.0 + 0.1, 5 );

	pev ( id, pev_viewmodel2, LastModelV [id], 49 );

	pev ( id, pev_weaponmodel2, LastModelP [id], 49 );

	set_pev ( id, pev_viewmodel2, VIP_V_INJECTOR );

	set_pev ( id, pev_weaponmodel2, VIP_P_INJECTOR );

	SendWeaponAnim ( id, 0 );

	set_task ( 2.0, "UseInjector2", id + 25071973 );

	return PLUGIN_HANDLED;
}

public UseInjector2 ( id )
{
	id -= 25071973;

	if ( is_user_alive ( id ) )
	{
		set_pev ( id, pev_viewmodel2, LastModelV [id] );

		set_pev ( id, pev_weaponmodel2, LastModelP [id] );

		set_pdata_float ( id, 83, 1.1, 5 );

		SendWeaponAnim ( id, 3 );

		set_hp ( id );
	}
}

public plugin_natives (  )
{
	aTombola = ArrayCreate ( 1, 1 );

	aJackpotSkins = ArrayCreate ( 1, 1 );

	aJackpotUsers = ArrayCreate ( 1, 1 );

	aBattleCases = ArrayCreate ( 1, 1 );

	aBattleUsers = ArrayCreate ( 1, 1 );

	register_native ( "csgo_is_user_logged", "NativeIsUserLogged", 0 );
	register_native ( "csgo_get_user_points", "NativeGetUserPoints", 0 );
	register_native ( "csgo_set_user_points", "NativeSetUserPoints", 0 );
	register_native ( "csgo_get_user_dusts", "NativeGetUserDusts", 0 );
	register_native ( "csgo_set_user_dusts", "NativeSetUserDusts", 0 );
	register_native ( "csgo_get_user_chests", "NativeGetUserChests", 0 );
	register_native ( "csgo_set_user_chests", "NativeSetUserChests", 0 );
	register_native ( "csgo_get_user_keys", "NativeGetUserKeys", 0 );
	register_native ( "csgo_set_user_keys", "NativeSetUserKeys", 0 );
	register_native ( "csgo_get_user_skins", "NativeGetUserSkins", 0 );
	register_native ( "csgo_set_user_skins", "NativeSetUserSkins", 0 );
	register_native ( "csgo_get_user_stattrak", "NativeGetUserSTSkins", 0 );
	register_native ( "csgo_set_user_stattrak", "NativeSetUserSTSkins", 0 );
	register_native ( "csgo_get_user_rang", "NativeGetUserRang", 0 );
	register_native ( "csgo_set_user_rang", "NativeSetUserRang", 0 );
	register_native ( "csgo_is_warmup", "NativeIsWarmup", 0 );
	register_native ( "csgo_get_user_hands", "NativeGetUserHands", 0 );
	register_native ( "csgo_set_user_hands", "NativeSetUserHands");
}

public CacheSettings (  )
{
	sOverrideMenu = get_pcvar_num ( GoSettings [OVERRIDE_MENU] );

	get_pcvar_string ( GoSettings [PASSWORD_FIELD], sPasswordField, charsmax ( sPasswordField ) );

	sContractCost = get_pcvar_num ( GoSettings [CONTRACT_COST] );

	sBuyChatTag = get_pcvar_num ( GoSettings [CHAT_TAG_COST] );

	sDustForTransform = get_pcvar_num ( GoSettings [DUST_FOR_TRANSFORM] );
   
	sSprayCooldown = get_pcvar_num ( GoSettings [SPRAY_COOLDOWN] );

	sHMinPoints = get_pcvar_num ( GoSettings [HS_MIN_POINTS] );

	sHMaxPoints = get_pcvar_num ( GoSettings [HS_MAX_POINTS] );

	sKMinPoints = get_pcvar_num ( GoSettings [KILL_MIN_POINTS] );

	sKMaxPoints = get_pcvar_num ( GoSettings [KILL_MAX_POINTS] );

	sCompetitiveMode = get_pcvar_num ( GoSettings [COMPETITIVE_MODE] );

	sWarmTimer = get_pcvar_num ( GoSettings [WARMUP_DURATION] );

	sMVPBonus = get_pcvar_num ( GoSettings [BEST_POINTS] );

	sDropChance = get_pcvar_num ( GoSettings [DROP_CHANCE] );

	sWaitForPlace = get_pcvar_num ( GoSettings [WAIT_FOR_PLACE] );

	sTombolaTimer = get_pcvar_num ( GoSettings [TOMBOLA_TIMER] );

	sTombolaCost = get_pcvar_num ( GoSettings [TOMBOLA_COST] );

	sJackpotTimer = get_pcvar_num ( GoSettings [JACKPOT_TIMER] );

	sBattleTimer = get_pcvar_num ( GoSettings [BATTLE_TIMER] );

	sSkinTagPrice = get_pcvar_num ( GoSettings [SET_SKIN_TAG_PRICE] );

	sRenameSkinTagPrice = get_pcvar_num ( GoSettings [RENAME_SKIN_TAG_PRICE] );

	sGiveAwayLimit = get_pcvar_num ( GoSettings [GIVEAWAY_LIMIT] );

	sLogFade = get_pcvar_num ( GoSettings [LOG_SCREEN_FADE] );

	sDerankCount = get_pcvar_num ( GoSettings [DERANK_COUNT] );

	sBuyCKMultiplier = get_pcvar_num ( GoSettings [BUY_CK_MULTIPLIER] );

	sUpgradeMultiplier = get_pcvar_num ( GoSettings [UPGRADE_MULTIPLIER] );

	sVipBonusMultiplier = get_pcvar_num ( GoSettings [VIP_BONUS_MULTIPLIER] );

	sTagStatTrakCostMultiplier = get_pcvar_num ( GoSettings [TAG_STATTRAK_COST_MULTIPLIER] );

	sTagCostMultiplier = get_pcvar_num ( GoSettings [TAG_COST_MULTIPLIER] );

	sStatTrakCostMultiplier = get_pcvar_num ( GoSettings [STATTRAK_COST_MULTIPLIER] );

	sRouletteBetLimit = get_pcvar_num ( GoSettings [ROULETTE_BET_LIMIT] );

	sInjectorAmmo = get_pcvar_num ( GoSettings [VIP_INJECTOR_AMMO] );

	sInjectorHeal = get_pcvar_num ( GoSettings [VIP_INJECTOR_HEAL] );

	sRewardHoursPlayed = get_pcvar_num ( GoSettings [REWARD_HOURS_PLAYED] );

	sPreviewDelay = get_pcvar_num ( GoSettings [PREVIEW_DELAY] );

	sOpenChestsDelay = get_pcvar_num ( GoSettings [OPEN_CHESTS_DELAY] );

	sDropStatTrakChance = get_pcvar_num ( GoSettings [DROP_STATTRAK_CHANCE] );

	sUpgradeChance = get_pcvar_num ( GoSettings [UPGRADE_CHANCE] );

	sGuessNumberCost = get_pcvar_num ( GoSettings [GUESS_NUMBER_COST] );

	sGuessNumberEarn = get_pcvar_num ( GoSettings [GUESS_NUMBER_EARN] );

	sGuessNumberDelay = get_pcvar_num ( GoSettings [GUESS_NUMBER_DELAY] );

	sBetTeamMultiplier = get_pcvar_num ( GoSettings [BET_TEAM_MULTIPLIER] );

	sBetTeamLimit = get_pcvar_num ( GoSettings [BET_TEAM_LIMIT] );

	sBetMinPlayersReq = get_pcvar_num ( GoSettings [BET_MIN_PLAYERS_REQ] );

	sTransformRest = get_pcvar_num ( GoSettings [ITEM_TRANSFORM_REST] );

	new Timer1 = sTombolaTimer;
		
	set_task ( float ( Timer1 ), "TaskTombolaRun", 2000, "", 0, "b", 0 );

	iNextTombolaStart = Timer1 + get_systime ( );

	bJackpotWork = true;

	new Timer2 = sJackpotTimer;

	set_task ( float ( Timer2 ), "TaskJackpotRun", 10000, "", 0, "b", 0 );
	
	iJackpotClose = Timer2 + get_systime (  );

	bBattleWork = true;

	new Timer3 = sBattleTimer;

	set_task ( float ( Timer3 ), "TaskBattleRun", 20000, "", 0, "b", 0 );
	
	iBattleClose = Timer3 + get_systime (  );

	bGuessNumWork = true;

	set_task ( float ( sGuessNumberDelay ), "TaskGuessNumberWork", 22334, "", 0, "b", 0 );
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

public MysqlInit()
{
	new ErrorCode, Handle: SqlConnection = SQL_Connect ( iSqlTuple, ErrorCode, SqlError, charsmax ( SqlError ) )
	
	if ( SqlConnection == Empty_Handle )

		set_fail_state ( SqlError );

	new Handle: Queries;

	formatex ( MysqlFormat, charsmax ( MysqlFormat ), "CREATE TABLE IF NOT EXISTS `%s` (`name` VARCHAR(32) NOT NULL PRIMARY KEY COLLATE 'utf8_unicode_ci',`password` varchar(100) NOT NULL,", SQL_TABLE );

	add ( MysqlFormat, charsmax ( MysqlFormat ), " `points` INT(11), `dusts` INT (11), `capsule` INT (11), `glove_boxes` INT (11), `keys` varchar (260), `chests` varchar(260), `rank` INT (3), `max_rank` INT (3), `kills` INT (11)," );

	add ( MysqlFormat, charsmax ( MysqlFormat ), " `skins` varchar (3500), `st_skins` varchar (3500), `s_tags` varchar (5240), `w_tags` varchar (5000), `skin_applied` varchar (1290), `index_applied` varchar(1290),")

	add ( MysqlFormat, charsmax ( MysqlFormat ), " `sprays` varchar (260), `spray_applied` varchar (64), `tracks` varchar (260), `track_applied` varchar (11), `gloves` varchar (260), `glove_applied` varchar (64), `faction_applied` varchar (11), `last_reward` INT (11));")

	Queries = SQL_PrepareQuery ( SqlConnection, MysqlFormat )

	if ( !SQL_Execute ( Queries ) )
	{
		SQL_QueryError ( Queries, SqlError, charsmax ( SqlError ) );

		set_fail_state ( SqlError );
	}

	SQL_FreeHandle ( Queries );
	
	SQL_FreeHandle ( SqlConnection );
}

public LoadData ( id )
{
	if ( !is_user_connected ( id ) )
	{
		return PLUGIN_HANDLED;
	}

	new Data [2], SafeName [100];

	Data [0] = id;

	MakeStringSQLSafe ( Name [id], SafeName, charsmax ( SafeName ) );

	formatex ( SqlLine, charsmax ( SqlLine ), "SELECT * FROM `%s` WHERE (`name` = '%s') LIMIT 1", SQL_TABLE, SafeName );

	SQL_ThreadQuery ( iSqlTuple, "register_client", SqlLine, Data, sizeof ( Data ) );

	for ( new i = 0; i < PromoNums; i ++ )
	{
		if ( nvault_get ( PromoName [i], Name [id], SqlLine, 2 ) ) 
		{
			PromoUse [id] [i] = 1;
		}
	}

	return PLUGIN_CONTINUE;
}

public register_client(FailState,Handle:Query,Error[],Errcode, Data [ ], DataSize )
{
  	if ( FailState == TQUERY_CONNECT_FAILED )
        {
		LogToFile ( "[SQL] Could not connect to SQL database.  [%d] %s",Errcode, Error)

		return set_fail_state ( "Could not connect to SQL database." );
	}
    	else if ( FailState == TQUERY_QUERY_FAILED )
	{
		LogToFile ( "[SQL] - Query failed. [%d] %s", Errcode, Error)

        	return set_fail_state ( "Query failed." );
	}
	
	
	new id = Data [0]

	if ( !is_user_connected ( id ) )
	{
		return PLUGIN_HANDLED;
	}

	if ( SQL_NumResults ( Query ) >= 1 ) 
	{
		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "password"), iUserSavedPass [id], charsmax ( iUserSavedPass [ ] ) );

		iUserPoints [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "points" ) );

		iUserDusts [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "dusts" ) );

		iUserCaps [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "capsule" ) );

		iUserGloveBoxes [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "glove_boxes" ) );
 		
 		// aici e i
		new i;

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "keys" ), SqlLine, charsmax ( SqlLine ) );

		parse ( SqlLine, g_Data [1], 7, g_Data [2], 7, 
		g_Data [3], 7, g_Data [4], 7, g_Data [5], 7, g_Data [6], 7, g_Data [7], 7, 
		g_Data [8], 7, g_Data [9], 7, g_Data [10], 7 );

		for ( i = 1; i < 11; i ++ )
		{
			iUserKeys [id] [i] = str_to_num ( g_Data [i] );

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "chests" ), SqlLine, charsmax ( SqlLine ) );

		parse ( SqlLine, g_Data [1], 7, g_Data [2], 7, 
		g_Data [3], 7, g_Data [4], 7, g_Data [5], 7, g_Data [6], 7, g_Data [7], 7, 
		g_Data [8], 7, g_Data [9], 7, g_Data [10], 7 );

		for ( i = 1; i < 11; i ++ )
		{
			iUserChests [id] [i] = str_to_num ( g_Data [i] );

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		iUserRang [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "rank" ) );

		UserMaxRang [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "max_rank" ) );

		iUserKills [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "kills" ) );

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "skins" ), MysqlFormat, charsmax ( MysqlFormat ) );

		for ( i = 1; i < SkinsNum; i ++ )
		{
			strtok ( MysqlFormat, g_Data [i], charsmax ( g_Data [ ] ), MysqlFormat, charsmax ( MysqlFormat ), '#' );
			
			iUserSkins [id] [i] = str_to_num ( g_Data [i] );

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "st_skins" ), MysqlFormat, charsmax ( MysqlFormat ) );

		new dData [2] [8];

		for ( i = 1; i < SkinsNum; i ++ )
		{
			strtok ( MysqlFormat, g_Data [i], charsmax ( g_Data [ ] ), MysqlFormat, charsmax ( MysqlFormat ), '#' );

			parse ( g_Data [i], dData [0], charsmax ( dData [ ] ), dData [1], charsmax ( dData [ ] ) );

			iUserSTs [id] [i] = str_to_num ( dData [0] );

			iUserSkins [id] [i] += str_to_num ( dData [0] );

			STKills [id] [i] = str_to_num ( dData [1] );

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		formatex ( dData [0], charsmax ( g_Data [ ] ), "" );

		formatex ( dData [1], charsmax ( g_Data [ ] ), "" );

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "s_tags" ), MysqlFormat, charsmax ( MysqlFormat ) );

		for ( i = 1; i < SkinsNum; i ++ )
		{
			strtok ( MysqlFormat, g_Data [i], charsmax ( g_Data [ ] ), MysqlFormat, charsmax ( MysqlFormat ), '#' );

			copy ( SkinTagN [id] [i], charsmax ( SkinTagN [ ] ), g_Data [i] );

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "w_tags" ), MysqlFormat, charsmax ( MysqlFormat ) );

		for ( i = 1; i < SkinsNum; i ++ )
		{
			strtok ( MysqlFormat, g_Data [i], charsmax ( g_Data [ ] ), MysqlFormat, charsmax ( MysqlFormat ), '#' );

			SkinTag [id] [i] = str_to_num ( g_Data [i] )

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "skin_applied" ), SqlLine, charsmax ( SqlLine ) );

		parse ( SqlLine, g_Data [0], 7, g_Data [1], 7, g_Data [2], 7, g_Data [3], 7, g_Data [4], 7,\
		g_Data [5], 7, g_Data [6], 7, g_Data [7], 7, g_Data [8], 7, g_Data [9], 7, g_Data [10], 7,\
		g_Data [11], 7, g_Data [12], 7, g_Data [13], 7, g_Data [14], 7, g_Data[15], 7, g_Data [16], 7,\
		g_Data [17], 7, g_Data [18], 7, g_Data [19], 7, g_Data [20], 7 );

		for ( i = 0; i < 25; i ++ )
		{
			iUserSelectedSkin [id] [i] = str_to_num ( g_Data [i] );

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "sprays" ), SqlLine, charsmax ( SqlLine ) );

		parse ( SqlLine, g_Data [0], 7, g_Data [1], 7, g_Data [2], 7, g_Data [3], 7, g_Data [4], 7,\
		g_Data [5], 7, g_Data [6], 7, g_Data [7], 7, g_Data [8], 7, g_Data [9], 7, g_Data [10], 7,\
		g_Data [11], 7, g_Data [12], 7, g_Data [13], 7, g_Data [14], 7, g_Data[15], 7, g_Data [16], 7,\
		g_Data [17], 7, g_Data [18], 7, g_Data [19], 7, g_Data [20], 7 );

		for ( i = 0; i < SpraysNum; i ++ )
		{
			SprayRemaining [id] [i] = str_to_num ( g_Data [i] );

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		iUserSelectedSpray [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "spray_applied" ) );

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "tracks" ), SqlLine, charsmax ( SqlLine ) );

		parse ( SqlLine, g_Data [0], 7, g_Data [1], 7, g_Data [2], 7, g_Data [3], 7, g_Data [4], 7,\
		g_Data [5], 7, g_Data [6], 7, g_Data [7], 7, g_Data [8], 7, g_Data [9], 7, g_Data [10], 7,\
		g_Data [11], 7, g_Data [12], 7, g_Data [13], 7, g_Data [14], 7, g_Data[15], 7, g_Data [16], 7,\
		g_Data [17], 7, g_Data [18], 7, g_Data [19], 7, g_Data [20], 7 );

		for ( i = 0; i < TracksNum; i ++ )
		{
			TrackRemaining [id] [i] = str_to_num ( g_Data [i] );

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "gloves" ), SqlLine, charsmax ( SqlLine ) );

		parse ( SqlLine, g_Data [1], 7, g_Data [2], 7, g_Data [3], 7, g_Data [4], 7,\
		g_Data [5], 7, g_Data [6], 7, g_Data [7], 7, g_Data [8], 7, g_Data [9], 7, g_Data [10], 7,\
		g_Data [11], 7, g_Data [12], 7, g_Data [13], 7, g_Data [14], 7, g_Data[15], 7, g_Data [16], 7,\
		g_Data [17], 7, g_Data [18], 7, g_Data [19], 7, g_Data [20], 7 );

		for ( i = 1; i < GlovesNum; i ++ )
		{
			iUserGloves [id] [i] = str_to_num ( g_Data [i] );

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		g_iUserSelectedGlove [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "glove_applied" ) );

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "index_applied" ), SqlLine, charsmax ( SqlLine ) );

		parse ( SqlLine, g_Data [0], 7, g_Data [1], 7, g_Data [2], 7, g_Data [3], 7, g_Data [4], 7,\
		g_Data [5], 7, g_Data [6], 7, g_Data [7], 7, g_Data [8], 7, g_Data [9], 7, g_Data [10], 7,\
		g_Data [11], 7, g_Data [12], 7, g_Data [13], 7, g_Data [14], 7, g_Data[15], 7, g_Data [16], 7,\
		g_Data [17], 7, g_Data [18], 7, g_Data [19], 7, g_Data [20], 7, g_Data[21], 7,  g_Data[22], 7,\
		g_Data[23], 7,  g_Data[24], 7,  g_Data[25], 7,  g_Data[26], 7,  g_Data[27], 7,  g_Data[28], 7,\
		g_Data[29], 7,  g_Data[30], 7 );

		for ( i = 0; i <= 30; i ++ )
		{
			g_iUserSelectedSkin [id] [i] = str_to_num ( g_Data [i] );

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "faction_applied" ), SqlLine, charsmax ( SqlLine ) );

		parse ( SqlLine, g_Data [0], 7, g_Data [1], 7 );

		for ( i = 0; i < 2; i ++ )
		{
			iUserSelectedFaction [id] [i] = str_to_num ( g_Data [i] );

			formatex ( g_Data [i], charsmax ( g_Data [ ] ), "" );
		}

		iUserSelectedSound [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "track_applied" ) );

		iDay [id] = SQL_ReadResult ( Query, SQL_FieldNameToNum ( Query, "last_reward" ) );
	}

	return PLUGIN_HANDLED
}

public SaveData ( id )
{
	if ( !iLogged [id] )
	{
		return PLUGIN_HANDLED;
	}

	formatex ( SqlLine, charsmax ( SqlLine ), "" );

	formatex ( MysqlFormat, charsmax ( MysqlFormat ), "UPDATE `%s` SET `points` = '%i', `dusts` = '%i', `capsule` = '%i', `glove_boxes` = '%i', `rank`= '%i', `max_rank` = '%i', `kills` = '%i',", SQL_TABLE, iUserPoints [id], iUserDusts [id], iUserCaps [id], iUserGloveBoxes [id], iUserRang [id], UserMaxRang [id], iUserKills [id] );

	format ( MysqlFormat, charsmax ( MysqlFormat ), "%s`spray_applied` = '%i', `track_applied` = '%i', `glove_applied` = '%i', `skin_applied` = '%i', `index_applied` = '%i', `last_reward` = '%i', `keys` = '", MysqlFormat, iUserSelectedSpray [id], iUserSelectedSound [id], g_iUserSelectedGlove [id], iUserSelectedSkin[id], g_iUserSelectedSkin[id], iDay [id] );

	new auxString [32], a;

	//add ( MysqlFormat, charsmax ( MysqlFormat ),", `keys` = '" )

	for ( new i = 1; i < 11; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "^"%i^" ", iUserKeys [id] [i] );

		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );
	}

	add ( MysqlFormat, charsmax ( MysqlFormat ),"', `chests` = '" )

	for ( new i = 1; i < 11; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "^"%i^" ", iUserChests [id] [i] );

		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );
	}

	add ( MysqlFormat, charsmax ( MysqlFormat ), "', `skins` = '")

	for ( new i = 1; i < SKINS_LIMIT + 1; i ++ )
	{
		a = iUserSkins [id] [i] - iUserSTs [id] [i];

		if ( a < 0 )
		{
			iUserSkins [id] [i] = 0;

			a = 0;
		}

		formatex ( auxString, charsmax ( auxString ), "%i#", a );

		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );
	} 

	add ( MysqlFormat, charsmax ( MysqlFormat ), "', `st_skins` = '" );

	for ( new i = 1; i < SKINS_LIMIT + 1; i ++ )
	{
		if ( iUserSTs [id] [i] < 0 )

			iUserSTs [id] [i] = 0;

		formatex ( auxString, charsmax ( auxString ), "%i %i#", iUserSTs [id] [i], STKills [id] [i] );
		
		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );
	}

	add ( MysqlFormat, charsmax ( MysqlFormat ),"', `s_tags` = '" )

	for ( new i = 1; i < SKINS_LIMIT + 1; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "%s#", SkinTagN [id] [i] );

		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );
	}

	add ( MysqlFormat, charsmax ( MysqlFormat ), "', `w_tags` = '" )

	for ( new i = 1; i < SKINS_LIMIT + 1; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "%i#", SkinTag [id] [i] );

		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );
	}

	add ( MysqlFormat, charsmax ( MysqlFormat ), "', `skin_applied` = '" )

	for ( new i = 0; i < 25; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "^"%i^" ", iUserSelectedSkin [id] [i] );

		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );
	}

	add ( MysqlFormat, charsmax ( MysqlFormat ), "', `index_applied` = '" )

	for ( new i = 0; i <= 30; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "^"%i^" ", g_iUserSelectedSkin [id] [i] );

		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );
	}

	add ( MysqlFormat, charsmax ( MysqlFormat ), "', `sprays` = '")

	for ( new i = 0; i < 20; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "^"%i^" ", SprayRemaining [id] [i] );

		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString );
	}

	add ( MysqlFormat, charsmax ( MysqlFormat ), "', `tracks` = '")

	for ( new i = 0; i < MAX_MVPS; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "^"%i^" ", TrackRemaining [id] [i] );
		
		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString	);
	}

	add ( MysqlFormat, charsmax ( MysqlFormat ), "', `gloves` = '")

	for ( new i = 1; i <= 10; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "^"%i^" ", iUserGloves [id] [i] );
		
		add ( MysqlFormat, charsmax ( MysqlFormat ), auxString	);
	}

	add ( MysqlFormat, charsmax ( MysqlFormat ), "', `faction_applied` = '")

	for ( new i = 0; i < 2; i ++ )
	{
		formatex ( auxString, charsmax ( auxString ), "^"%i^" ", iUserSelectedFaction [id] [i] );

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
		LogToFile ( "[SQL] Could not connect to SQL database.  [%d] %s",Errcode, Error)

		return set_fail_state ( "Could not connect to SQL database." );
	}
    	else if ( FailState == TQUERY_QUERY_FAILED )
	{
		LogToFile ( "[SQL] - Query failed. [%d] %s", Errcode, Error)

        	return set_fail_state ( "Query failed." );
	}
	
	SQL_FreeHandle ( Query );
	
	return PLUGIN_HANDLED;
}

public CheckSay ( id ) 
{ 
	new Args [194]; read_args ( Args, charsmax ( Args ) ) 
	
	remove_quotes ( Args );

	trim ( Args );
	
	if ( equal ( Args, "" ) || !is_user_connected ( id ) || !id )
	
		return PLUGIN_HANDLED;
	
	for ( new i = 0; i < sizeof ( BlockTexts ); i ++ )
	{
		if ( containi ( Args, BlockTexts [i]) != -1 )
			
			return PLUGIN_HANDLED;
	}

	new sTemp [32];

	if ( iLogged [id] )
	{
		for ( new i = 0; i < sizeof ( WEAPON_ARGS );  i ++ )
		{
			if ( equal ( Args, WEAPON_ARGS [i], strlen ( WEAPON_ARGS [i] ) ) )
			{
				replace ( Args, charsmax ( Args ), "!", "" );

				formatex ( sTemp, charsmax ( sTemp ), "weapon_%s", Args );

				ShowSkinsFromID ( id, get_weaponid ( sTemp ) );

				return PLUGIN_HANDLED;
			}
		}
	}
	
	new iAlive = is_user_alive ( id ); 
	
	new CsTeams:iTeam = cs_get_user_team ( id );
	
	new iPlayers [32], iNum; 
	
	get_players ( iPlayers, iNum ); 
	
	new const Prefixes [2] [CsTeams] [ ] = 
	{
		{
			"^1*DEAD* ",
			"^1*DEAD* ",
			"^1*DEAD* ",
			"^1*SPEC* "
		},
		{
			"",
			"",
			"",
			""
		}
	};

	new Message [193];

	if ( PlayerHasTag [id] )

		formatex ( Message, charsmax ( Message ), "%s^3[^4%s^3] [^4%s^3] %s^4 :^1 %s", Prefixes [iAlive] [iTeam], iUserSavedTag [id], iLogged [id] ? RangName [iUserRang [id]] : "UnRanked", Name [id], Args ); 
	else
		formatex ( Message, charsmax ( Message ), "%s^3[^4%s^3] %s^4 :^1 %s", Prefixes [iAlive] [iTeam], iLogged [id] ? RangName [iUserRang [id]] : "UnRanked", Name [id], Args ); 
	
	new iTarget;

	log_amx ( "SAY: %s: %s", Name [id], Args ); 

	for ( new i = 0; i < iNum; i ++ ) 
	{ 
		iTarget = iPlayers [i]; 
	
		if ( iTarget == id || ( iAlive || is_user_connected ( iTarget ) ) )
		{
			switch ( cs_get_user_team ( id ) )
			{
				case CS_TEAM_T: client_print_color ( iTarget, id, Message );
					
				case CS_TEAM_CT: client_print_color ( iTarget, id, Message );
						
				case CS_TEAM_SPECTATOR: client_print_color ( iTarget, id, Message );
			}
		}
	}
	
	return PLUGIN_HANDLED_MAIN; 
} 

public CheckSayTeam ( id ) 
{ 
	new Args [194]; read_args ( Args, charsmax ( Args ) ) 
	
	remove_quotes ( Args );

	trim ( Args );
	
	if ( equal ( Args, "" ) || !is_user_connected ( id ) || !id )
	
		return PLUGIN_HANDLED;
	
	for ( new i = 0; i < sizeof ( BlockTexts ); i ++ )
	{
		if ( containi ( Args, BlockTexts [i]) != -1 )
			
			return PLUGIN_HANDLED;
	}
	
	new iAlive = is_user_alive ( id ); 
	
	new CsTeams: iTeam = CsTeams:( ( _:cs_get_user_team ( id ) ) % 3 );  
	
	new iPlayers [32], iNum; 
	
	get_players ( iPlayers, iNum ); 

	new const Prefixes [2] [CsTeams] [  ] = 
	{
		{
			"^4(^3SPEC^4)^1 ",
			"^1*DEAD*^4 (^3T^4)^1 ",
			"^1*DEAD*^4 (^3CT^4)^1 ",
			""
		},
		{
			"^4(^3SPEC^4) ",
			"^4(^3T^4) ",
			"^4(^3CT^4) ",
			""
		}
	}; 

	new Message [192]; 

	formatex ( Message, charsmax ( Message ), "%s^3 %s^4 :^1 %s", Prefixes [iAlive] [iTeam], Name [id], Args ); 

	log_amx ( "SAY_TEAM: %s: %s", Name [id], Args ); 

	for ( new i = 0, iTeamMate; i < iNum; i ++ ) 
	{ 
		iTeamMate = iPlayers [i]; 
	
		if ( iTeamMate == id || ( iAlive || is_user_connected ( iTeamMate ) ) && CsTeams:( ( _:cs_get_user_team ( iTeamMate ) ) % 3 ) == iTeam || get_user_flags ( iTeamMate ) & ADMIN_IMMUNITY ) 
		{
			switch ( cs_get_user_team ( id ) )
			{
				case CS_TEAM_T: client_print_color ( iTeamMate, id, Message );
					
				case CS_TEAM_CT: client_print_color ( iTeamMate, id, Message );
						
				case CS_TEAM_SPECTATOR: client_print_color ( iTeamMate, id, Message );
			}
		}
	}
	
	return PLUGIN_HANDLED_MAIN; 
}

public TypePromoCode ( id )
{
	if ( !iLogged [id] )

		return PLUGIN_HANDLED;
		
	new Data [32];
	read_args ( Data, charsmax ( Data ) );

	remove_quotes ( Data );
	
	if ( equal ( Data, "" ) )
	{
		client_cmd(id, "messagemode TypeCode");

		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_INVALID_PROMOCODE" );

		return PLUGIN_HANDLED;
	}
	else
	{
		for ( new i = 0; i < PromoNums; i ++ )
		{
			if ( equal ( Data, PromoCode [i] ) && !PromoUse [id] [i] )
			{
				iUserPoints [id] += PromoPoints [i];

				new StrPoints [16];

				AddCommas ( PromoPoints [i], StrPoints, charsmax ( StrPoints ) );

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_VALID_PROMOCODE", PromoCode [i], StrPoints );

				PromoUse [id] [i] = 1;

				nvault_set ( PromoName [i], Name [id], "1" );

				ShowMainMenu ( id );

				return PLUGIN_HANDLED;
			}
		}

		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_INVALID_PROMOCODE" );

		client_cmd ( id, "messagemode TypeCode");
		
	}

	return PLUGIN_HANDLED;
}

public GiftValue ( id )
{
	if ( !iLogged [id] )

		return PLUGIN_HANDLED;
		
	new Data [32], Value;

	read_args ( Data, charsmax ( Data ) );

	remove_quotes ( Data );
	
	Value = str_to_num ( Data );

	if ( iGiftItem [id] == 3001 )
	{
		if ( Value < 0 || Value > iUserPoints [id] || Value == 0 )
		{
			client_cmd ( id, "messagemode InputValue");

			return PLUGIN_HANDLED;
		}
	}
	else if ( iGiftItem [id] == 3000 )
	{
		if ( Value < 0 || Value > iUserDusts [id] || Value == 0 )
		{
			client_cmd ( id, "messagemode InputValue");

			return PLUGIN_HANDLED;
		}
	}

	SendQuantity [id] = Value;

	ShowGiftMenu ( id );

	return PLUGIN_HANDLED;
}

public ClCmdSaySkin ( id )
{
	new ids = id;

	if ( !is_user_alive ( ids ) )
	{
		ids = pev ( ids, pev_iuser2 );

		if ( !is_user_alive ( ids ) )
		{
			return PLUGIN_HANDLED;
		}
	}

	new Skin [140];

	pev ( ids, pev_viewmodel2, Skin, charsmax ( Skin ) );

	new Temp [32], StrMin [16], StrMax [16];

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( g_iSkinBody [i] == g_iUserSelectedSkin[ids][SkinID[i]] && equal(Skin, SkinMdl[i]))
		{
			if ( SkinChest [i] == 0 )
			{
				formatex ( Temp, charsmax ( Temp ), "Contract" );
			}
			else
			{
				formatex ( Temp, charsmax ( Temp ), "%s", ChestName [SkinChest [i]] );
			}

			AddCommas ( SkinMinPrice [i], StrMin, charsmax ( StrMin ) );

			AddCommas ( SkinMaxPrice [i], StrMax, charsmax ( StrMax ) );

			client_print_color ( id, id, "%s Skin:^3 %s^1 |^3 %s^1 |^3 %d%%^1 |^3 %s - %s^1 euros", CHAT_PREFIX, SkinName [i], Temp, 100 - SkinChance [i], StrMin, StrMax );

			return PLUGIN_HANDLED;
		}
	}

	client_print_color ( id, id, "%s You have no skin selected on this weapon", CHAT_PREFIX );

	return PLUGIN_HANDLED;
}

public ClCmdSayGloves ( id )
{
	new ids = id;

	if ( !is_user_alive ( ids ) )
	{
		ids = pev ( ids, pev_iuser2 );

		if ( !is_user_alive ( ids ) )
		{
			return PLUGIN_HANDLED;
		}
	}

	new Glove = g_iUserSelectedGlove [ids];

	new StrMin [16], StrMax [16];

	//for ( new i = 1; i < GlovesNum; i ++ )
	//{
	if ( Glove > 0 )
	{
		AddCommas ( GloveMinPrice [Glove], StrMin, charsmax ( StrMin ) );

		AddCommas ( GloveMaxPrice [Glove], StrMax, charsmax ( StrMax ) );

		client_print_color ( id, id, "%s Glove:^3 %s^1 |^3 %d%%^1 |^3 %s - %s^1 euros", CHAT_PREFIX, GloveName [Glove], 100 - GloveChance [Glove], StrMin, StrMax );

		return PLUGIN_HANDLED;
	}
	//}

	client_print_color ( id, id, "%s You have no gloves selected", CHAT_PREFIX );

	return PLUGIN_HANDLED;
}


public ClCmdGiveAway ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 4, false ) )
	{
		return PLUGIN_HANDLED;
	}

	new Arg1 [16], Arg2 [16], Arg3 [16];

	read_argv ( 1, Arg1, charsmax ( Arg1 ) );

	read_argv ( 2, Arg2, charsmax ( Arg2 ) );

	read_argv ( 3, Arg3, charsmax ( Arg3 ) );

	new SkinID = str_to_num ( Arg1 );

	new Type = str_to_num ( Arg2 );

	new Time = str_to_num ( Arg3 );

	if ( WarmUp )
	{
		console_print ( id, "[CS:GO Infinity] You cannot start an event in the warm-up round!" );
		
		return PLUGIN_HANDLED;
	}	

	if ( GiveAwayRound )
	{
		console_print ( id, "[CS:GO Infinity] This half was already an event!" );
		
		return PLUGIN_HANDLED;
	}

	if ( SkinID < 0 || SkinID >= SkinsNum )
	{
		console_print ( id, "[CS:GO Infinity] SkinID wrong! Choose a number between 0 si %d", SkinsNum - 1 );
		
		return PLUGIN_HANDLED;
	}

	if ( Time < 120 || Time > 300 )
	{
		console_print ( id, "[CS:GO Infinity] Wrong time! Choose a number between 120 and 300" );
		
		return PLUGIN_HANDLED;
	}

	if ( CheckIsLogged (  ) < sGiveAwayLimit )
	{
		console_print ( id, "[CS:GO Infinity] Must be at least %d authenticated players!", sGiveAwayLimit );
		
		return PLUGIN_HANDLED;
	}

	sTime = Time;

	switch ( Type )
	{
		case 0:
		{
			sID = SkinID;

			LogToFile ( "[INFO] - %s giveaway: <%d> %s (%dsec)", Name [id], sID, SkinName [sID], sTime );

			client_print_color ( 0, 0, "^1[^4GiveAway^1]^3 :^1 Skin^4 :^3 %s^4 |^3 %dsec.", SkinName [sID], sTime );
		}
		case 1:
		{
			sID = SkinID + 7000;

			LogToFile ( "[INFO] - %s giveaway: <%d> %s (StatTrak) (%dsec)", Name [id], sID-7000, SkinName [sID-7000], sTime );

			client_print_color ( 0, 0, "^1[^4GiveAway^1]^3 :^1 Skin^4 :^3 %s^4 (^3StatTrak^4) |^3 %dsec.", SkinName [sID - 7000], sTime );
		}
	}

	GiveAwayRound = true;

	IsGiveAway = true;

	GiveAwayRun (  );

	return PLUGIN_HANDLED;
}

public GiveAwayRun (  )
{
	if ( CheckIsLogged ( ) < sGiveAwayLimit )
	{
		client_print_color ( 0, 0, "^1[^4GiveAway^1]^3 :^1 The event has been canceled! Authenticated players^3 :^4 %d/%d", CheckIsLogged ( ), sGiveAwayLimit );

		sTime = 0;

		sID = -1;

		GiveAwayRound = false;

		IsGiveAway = false;
	}
	else if ( sTime > 1 )
	{
		sTime --;

		set_task ( 1.0, "GiveAwayRun" );
	}
	else if ( sTime <= 1 )
	{
		new id = GetRandomPlayer ( random_num ( 1, CheckIsLogged (  ) ) );

		if ( sID >= 7000 )
		{
			client_print_color ( 0, id, "%s %L", CHAT_PREFIX, id, "CSGO_GIVEAWAY_WIN", Name [id], SkinName [sID-7000], " ^4(^3StatTrak^4)" );

			iUserSkins [id] [sID - 7000] ++;

			iUserSTs [id] [sID - 7000] ++;
		}
		else
		{
			client_print_color ( 0, id, "%s %L", CHAT_PREFIX, id, "CSGO_GIVEAWAY_WIN", Name [id], SkinName [sID], "" );

			iUserSkins [id] [sID] ++;
		}

		SaveData ( id );

		IsGiveAway = false;

		sTime = 0;

		sID = -1;
	}
}

CheckIsLogged (  )
{
	static IsLogged, id;
	
	IsLogged = 0;
	
	for ( id = 1; id <= MaxPlayers; id ++ )
	{
		if ( iLogged [id] && is_user_connected ( id ) )
		{			
			IsLogged ++;
		}
	}

	return IsLogged;
}

GetRandomPlayer ( Num )
{
	static Users, id;
	
	Users = 0;
	
	for ( id = 1; id <= MaxPlayers; id ++ )
	{
		if ( iLogged [id] && is_user_connected ( id ) )
		{			
			Users ++;
		}

		if ( Users == Num )
			
			return id;
	}

	return -1;
}

public MessageSendAudio (  )
{
	static Audio [17]; get_msg_arg_string ( 2, Audio, charsmax ( Audio ) );
	
	if ( equal ( Audio [7], "terwin") || equal ( Audio [7], "ctwin") ) 

	          return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}


public PlayerDropItemPost ( id )
{
	new Entity = GetHookChainReturn ( ATYPE_INTEGER );

	if ( !is_nullent ( Entity ) )
	{
		set_entvar ( Entity, var_euser1, id )	;

		SetThink ( Entity, "RemoveUser1" );

		set_entvar ( Entity, var_nextthink, get_gametime (  ) + 2.0 );

		new Float: Velocity [3], Float: Angles [3], Float: Origin [3], Float: Velocity2;

		get_entvar ( id, var_origin, Origin );

		get_entvar ( id, var_velocity, Velocity );

		get_entvar ( id, var_angles, Angles );
		
		Origin [2] += 15.0;
		
		Angles [0] *= 3.0;
		
		Velocity [0] += floatcos ( Angles[ 1], degrees ) * 250.0 * floatcos ( floatabs ( Angles [0] ), degrees );

		Velocity [1] += floatsin ( Angles [1], degrees ) * 250.0 * floatcos ( floatabs ( Angles [0] ), degrees );
		
		Velocity2 = floatsin ( Angles [0], degrees ) * 250.0 * 2
		
		Velocity [2] += Velocity2 < 0 ? 0.0 : Velocity2
		
		set_entvar ( Entity, var_velocity, Velocity );

		set_entvar ( Entity, var_origin, Origin );
	}
}

public RemoveUser1 ( Entity ) set_entvar ( Entity, var_euser1, -1 );

public fwTouch ( Entity, id ) 
{
	if ( get_entvar ( Entity,var_euser1 ) == id )

		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public BuyShield ( id )
{
	client_print_color ( id, id, "%s The^3 shield^1 item has been restricted", CHAT_PREFIX );
	
	return PLUGIN_HANDLED;
}

public client_command ( id )
{
	static Command [8]

	if ( read_argv ( 0, Command, charsmax ( Command ) ) == 6 && equali ( Command, "shield" ) )
	{
		client_print_color ( id, id, "%s The^3 shield^1 item has been restricted", CHAT_PREFIX );
        
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public CS_InternalCommand ( id, const Command [ ] )
{
	if ( equali ( Command, "shield" ) )
	{
		client_print_color ( id, id, "%s The^3 shield^1 item has been restricted", CHAT_PREFIX );
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
} 

public ImpulsePickUp ( id )
{
	if ( !is_user_alive ( id ) )
	{
		return 1;
	}

	new EndOrigin [3], StartOrigin [3];

	get_user_origin ( id, StartOrigin, 0 );

	get_user_origin ( id, EndOrigin, 3 );
	
	new Float:fOrigin [3] = 0.0;
	
	IVecFVec ( EndOrigin, fOrigin );

	if ( get_distance ( StartOrigin, EndOrigin ) > 100 )
	{
		return 1;
	}

	new WpnboxList [4], ArmouryList [4], WpnboxSize = 4, ArmourySize = 4;

	new Wpnbox = find_sphere_class ( 0, "weaponbox", 5.0, WpnboxList, WpnboxSize, fOrigin );
	
	new Armoury = find_sphere_class ( 0, "armoury_entity", 5.0, ArmouryList, ArmourySize, fOrigin );

	if ( !Wpnbox && !Armoury )
	{
		return 1;
	}

	new List, Num;

	if ( Wpnbox && Armoury )
	{
		List = random_num ( 1, 2 );
	}
	else if ( Wpnbox || Armoury )
	{
		if ( Wpnbox )
		{
			List = 1;
		}
		else
		{
			List = 2;
		}
	}

	new Entity, csw;

	if ( List == 1 )
	{	
		if ( Wpnbox > WpnboxSize )
		{
			Num = random_num ( 0, WpnboxSize -1 );
		}
		else
		{
			Num = random_num ( 0, Wpnbox -1 );
		}

		Entity = WpnboxList [Num];
	}
	else
	{
		if ( Armoury > ArmourySize )
		{
			Num = random_num ( 0, ArmourySize -1 );
		}
		else
		{
			Num = random_num ( 0, Armoury -1 );
		}

		Entity = ArmouryList [Num];
	}

	if ( !pev_valid ( Entity ) )
	{
		return 1;
	}

	if ( List == 1 )
	{
		csw = cs_get_weaponbox_type ( Entity );
	}
	else
	{
		csw = cs_get_armoury_type ( Entity );
	}

	if ( 1 << csw & PRIMARY_WEAPONS_BIT_SUM )
	{
		DropWeapons ( id, 1 );
	}
	else if ( 1 << csw & SECONDARY_WEAPONS_BIT_SUM )
	{
		DropWeapons ( id, 2 );
	}

	fake_touch ( Entity, id );

	return 1;
}

cs_get_weaponbox_type ( iWeaponBox )
{
	new iWeapon;

	for ( new i = 1; i <= 5; i ++ )
	{
		iWeapon = get_pdata_cbase ( iWeaponBox, m_rgpPlayerItems_CWeaponBox [i], 4 );
		
		if ( iWeapon > 0 )
		{
			return cs_get_weapon_id ( iWeapon );
		}
	}

	return 0;
}

stock DropWeapons ( id, dropwhat )
{
	static Weapons [32], Num, i, WeaponID;

	Num = 0;

	get_user_weapons ( id, Weapons, Num );

	for ( i = 0; i < Num; i ++ )
	{
		WeaponID = Weapons [i];

		if ( ( dropwhat == 1 && ( ( 1 << WeaponID ) & PRIMARY_WEAPONS_BIT_SUM ) ) || ( dropwhat == 2 && ( ( 1 << WeaponID) & SECONDARY_WEAPONS_BIT_SUM ) ) )
		{
			static WName [32];

			get_weaponname ( WeaponID, WName, charsmax ( WName ) );

			engclient_cmd ( id, "drop", WName );
		}
	}

	return 1;
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

public client_connect ( id ) iFirstSpawn [id] = true;

public client_putinserver ( id )
{
	get_user_name ( id, Name [id], charsmax ( Name [ ] ) );
	
	Checked [id] = false;

	iFirstSpawn [id] = false;

	InjectorAmmo [id] = 0;

	iUserRang [id] = 0;

	iUserKills [id] = 0;

	DerankCount [id] = 0;

	iUserPoints [id] = 0;

	iUserDusts [id] = 0;

	iUserCaps [id] = 0;

	iLogged [id] = false;

	iUserPassword [id] = "";
	
	iUserSavedPass [id] = "";
	
	iUserPassFail [id] = 0;

	PlayerHasTag [id] = false;

	LoadUserTag ( id );

	SkinTagS [id] = 0;

	TagInput [id] = "";

	iUserSell [id] = false;

	iUserSellItem [id] = -1;

	iGiftTarget [id] = 0;

	iGiftItem [id] = -1;

	iUserUpgradeItem [id] = -1;

	SendQuantity [id] = 0;

	//g_iUserSelectedGlove [id] = 0;

	iMenuType [id] = 0;

	SetViewEntityBody ( id, 0 );

	iUserGloveBoxes [id] = 0;

	for ( new sID = 0; sID < 25; sID ++ )
	{
		iUserSelectedSkin [id] [sID] = 0;
	}

	for ( new i = 1; i < SKINS_LIMIT + 1; i ++ )
	{
		iUserSTs [id] [i] = 0;

		STKills [id] [i] = 0;

		iUserSkins [id] [i] = 0;

		SkinTagN [id] [i] = "";

		SkinTag [id] [i] = 0;
	}

	for ( new sCK = 1; sCK < 11; sCK ++ )
	{
		iUserChests [id] [sCK] = 0;

		iUserKeys [id] [sCK] = 0;
	}

	for ( new sT = 0; sT < 21; sT ++ )
	{
		SprayRemaining [id] [sT] = 0;

		TrackRemaining [id] [sT] = 0;

		iUserGloves [id] [sT] = 0;
	}

	iUserSelectedSpray [id] = -1;

	iUserSelectedSound [id] = -1;

	SkinInfo [id] = 0;

	iUserMVP [id] = 0;

	SprayCooldown [id] = 0;

	ItemName [id] = 0;

	TypeName [id] = 0;

	Quantity [id] = 0;

	//IsChangeAllowed [id] = false;

	UserMaxRang [id] = 0;

	ResetTradeData ( id );

	iUserJackpotItem [id] = -1;

	bUserPlayJackpot [id] = false;

	iBattleItem [id] = -1;

	bUserPlayBattle [id] = false;

	iDay [id] = false;

	MVPAllowed [id] = true;

	iRouletteType [id] = 0;

	for ( new i = 0; i < 3; i ++ )
	{
		iRouletteBet [id] [i] = 0;
	}

	for ( new f = 0; f < 2; f ++ )
	{
		iUserSelectedFaction [id] [f] = 0;
	}

	iDay [id] = 0;

	bUserPlay [id] = false;

	BetValue [id] = 0;

	LoadHours ( id );

	LoadData ( id );

	set_task ( 1.0, "TaskHudInfo", id + 2000, "", 0, "b", 0 );

	set_task ( 7.0, "TaskPrintMessage", id );
}

public TaskPrintMessage ( id )
{
	if ( is_user_connected ( id ) )
	{	
		if ( IsRegistered ( id ) && !iLogged [id] )
		{
	      		new Password [32];

			get_user_info ( id, sPasswordField, Password, charsmax ( Password ) );

			if ( equal ( Password, iUserSavedPass [id] ) )
			{
				if ( sLogFade > 0 )
				{
					MessageScreenFade ( id, 6<<10, 0, 0, 0, 0, 255, 200 ); 
				}

				iLogged [id] = true;

				ExecuteForward ( iForwards [5], iForwardResult, id );

				//client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_AUTO_LOGGED" );
			}
		}
	
		client_print_color ( id, id, "^3[CS:GO]^1 You are now playing^4 CS:GO Infinity Mod^1, a^4 CS:GO^1 Remake Mod" );
	}
}

public client_disconnected ( id )
{
	iMvpKills [id] = 0;

	iMvpHead [id] = 0;

	fMvpDamage [id] = 0.0;

	//IsChangeAllowed [id] = false;

	iHoursPlayed [id] = iHoursPlayed [id] + ( get_user_time ( id ) / 60 );

	if ( iRouletteBet [id] [0] > 0 || iRouletteBet [id] [1] > 0 || iRouletteBet [id] [2] > 0 )
	{
		//iUserPoints [id] += iRouletteBet [id] [0] + iRouletteBet [id] [1] + iRouletteBet [id] [2];
		iRouletteBet [id] [0] = 0
		iRouletteBet [id] [1] = 0
		iRouletteBet [id] [2] = 0
		iRoulettePlayers --;
	}

	bUserBet [id] = false;

	SelectBetTeam [id] = 0;

	SaveHours ( id );

	SaveData ( id );
}

public SaveHours ( id )
{
	new VaultKey [64], VaultData [256];

	formatex ( VaultKey,charsmax ( VaultKey ),"%s-hours", Name [id] );

	formatex ( VaultData,charsmax ( VaultData ),"%i ",iHoursPlayed [id] );

	nvault_set ( HoursVault, VaultKey, VaultData );
}

public LoadHours ( id )
{ 
	new VaultKey [64], VaultData [256], Time [32];

	formatex ( VaultKey, charsmax ( VaultKey ), "%s-hours", Name [id] );

	formatex ( VaultData, charsmax ( VaultData ),"%i ", iHoursPlayed [id] );

	nvault_get ( HoursVault, VaultKey, VaultData, charsmax ( VaultData ) );

	parse ( VaultData, Time, charsmax ( Time ) );

	iHoursPlayed [id] = str_to_num ( Time ); 
}

public TaskHudInfo ( id )
{
	id -= 2000;

	if ( WarmUp )
	{
		return PLUGIN_CONTINUE;
	}

	new Temp [256], sHud [256], StrPoints [16], wID, gKills [32];


	if ( !is_user_alive ( id ) )
	{
		new ids = pev ( id, pev_iuser2 );

		if ( !is_user_alive ( ids ) )
		{
			return PLUGIN_CONTINUE;
		}

		if ( iLogged [ids] )
		{
			set_hudmessage ( 64, 64, 64, 0.05, 0.20, 0, 6.00, 1.10, 0.00, 0.00, -1 );

			AddCommas ( iUserPoints [ids], StrPoints, charsmax ( StrPoints ) );

			formatex ( Temp, charsmax ( Temp ), "Euro: %s^n", StrPoints );

			add ( sHud, charsmax ( sHud ), Temp, 0 );

			formatex ( Temp, charsmax ( Temp ), "Rank: %s^n", RangName [iUserRang [ids]] );

			add ( sHud, charsmax ( sHud ), Temp, 0 );

			if ( RangsNum -1 > iUserRang [ids] )
			{
				formatex ( gKills, charsmax ( gKills ), "%d/%d", iUserKills [ids], RangKills [iUserRang [ids] + 1] );
			}
			else 
			{
				formatex ( gKills, charsmax ( gKills ), "%d", iUserKills [ids] );
			}

			formatex ( Temp, charsmax ( Temp ), "Kills: %s^n", gKills );

			add ( sHud, charsmax ( sHud ), Temp, 0 );

			new clan[32]

			csgo_get_user_clan_name(ids, clan, charsmax(clan));

			formatex ( Temp, charsmax ( Temp ), "Clan: %s^n", clan );

			add ( sHud, charsmax ( sHud ), Temp, 0 );

			if ( SkinInfo [ids] == 1 )
			{
				for ( new i = 1; i < SkinsNum; i ++ )
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						wID = i + 7000;

						if ( wID == iUserSelectedSkin [ids] [sID] )
						{
							if ( get_user_weapon ( ids ) == SkinID [i] )
							{
								formatex ( Temp, charsmax ( Temp ), "[StatTrak] %s (%s)^nConfirmed kills: %i^n", SkinName [i], GetSTClass ( ids, i ), STKills [ids] [i] );

								add ( sHud, charsmax ( sHud ), Temp, 0 );
							}
						}
						else if ( wID + 10000 == iUserSelectedSkin [ids] [sID] )
						{
							if ( get_user_weapon ( ids ) == SkinID [i] )
							{
								formatex ( Temp, charsmax ( Temp ), "[StatTrak] %s (%s)^nConfirmed kills: %i^n", SkinTagN [ids] [i], GetSTClass ( ids, i ), STKills [ids] [i] );

								add ( sHud, charsmax ( sHud ), Temp, 0 );
							}
						}
					}
				}
			}
			else if ( SkinInfo [ids] == 2 )
			{
				new Entity = get_pdata_cbase ( ids, 373 );

				if ( pev_valid ( Entity ) )
				{
					for ( new i = 0; i < WeaponDropped + 1; i ++ )
					{
						if ( wPickUp [i] [0] == Entity && wPickUp [i] [2] == get_user_weapon ( ids ) )
						{
							formatex ( Temp, charsmax ( Temp ), "%s^n%s's weapon^n", wPickUp1 [i], wPickUp2 [i] );
						}
					}

					add ( sHud, charsmax ( sHud ), Temp, 0 );
				}
			}
		}
	/*	else
		{
			formatex ( Temp, charsmax ( Temp ), "Player %s is not logged!", Name [ids] );

			add ( sHud, charsmax ( sHud ), Temp, 0 );
		}*/
	}
	else
	{
		if ( iLogged [id] )
		{
			set_hudmessage ( 64, 64, 64, 0.05, 0.20, 0, 6.00, 1.10, 0.00, 0.00, -1 );

			AddCommas ( iUserPoints [id], StrPoints, charsmax ( StrPoints ) );

			formatex ( Temp, charsmax ( Temp ), "Euro: %s^n", StrPoints );

			add ( sHud, charsmax ( sHud ), Temp, 0 );

			formatex ( Temp, charsmax ( Temp ), "Rank: %s^n", RangName [iUserRang [id]], gKills );

			add ( sHud, charsmax ( sHud ), Temp, 0 );

			if ( RangsNum -1 > iUserRang [id] )
			{
				formatex ( gKills, charsmax ( gKills ), "%d/%d", iUserKills [id], RangKills [iUserRang [id] + 1] );
			}
			else
			{
				formatex ( gKills, charsmax ( gKills ), "%d", iUserKills [id] );
			}

			formatex ( Temp, charsmax ( Temp ), "Kills: %s^n", gKills );

			add ( sHud, charsmax ( sHud ), Temp, 0 );

			new clan[32]

			csgo_get_user_clan_name(id, clan, charsmax(clan));

			formatex ( Temp, charsmax ( Temp ), "Clan: %s^n", clan );

			add ( sHud, charsmax ( sHud ), Temp, 0 );

			if ( SkinInfo [id] == 1 )
			{
				for ( new i = 1; i < SkinsNum; i ++ )
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						wID = i + 7000;

						if ( wID == iUserSelectedSkin [id] [sID] )
						{
							if ( get_user_weapon ( id ) == SkinID [i] )
							{
								formatex ( Temp, charsmax ( Temp ), "[StatTrak] %s (%s)^nConfirmed Kills: %i^n", SkinName [i], GetSTClass ( id, i ), STKills [id] [i] );

								add ( sHud, charsmax ( sHud ), Temp, 0 );
							}
						}
						else if ( wID + 10000 == iUserSelectedSkin [id] [sID] )
						{
							if ( get_user_weapon ( id ) == SkinID [i] )
							{
								formatex ( Temp, charsmax ( Temp ), "[StatTrak] %s (%s)^nConfirmed Kills: %i^n", SkinTagN [id] [i], GetSTClass ( id, i ), STKills [id] [i] );

								add ( sHud, charsmax ( sHud ), Temp, 0 );
							}
						}
					}
				}
			}
			else if ( SkinInfo [id] == 2 )
			{
				new Entity = get_pdata_cbase ( id, 373 );
					
				if ( pev_valid ( Entity ) )
				{
					for ( new i = 0; i < WeaponDropped + 1; i ++ )
					{
						if ( wPickUp [i] [0] == Entity && wPickUp [i] [2] == get_user_weapon ( id ) )
						{
							formatex ( Temp, charsmax ( Temp ), "%s^n%s's weapon^n", wPickUp1 [i], wPickUp2 [i] );
						}
					}

					add ( sHud, charsmax ( sHud ), Temp, 0 );
				}
			}
		}
		else
		{
			set_hudmessage ( 255, 0, 0, 0.02, 0.89, 0, 6.00, 1.10, 0.00, 0.00, -1 );

			formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_NOT_LOGGED" );

			add ( sHud, charsmax ( sHud ), Temp, 0 );
		}
	}

	ShowSyncHudMsg ( id, SyncHud1, sHud );

	return PLUGIN_HANDLED;
}


public ClCmdChooseTeam ( id )
{
	if ( sOverrideMenu > 0 )
	{
		ShowMainMenu ( id )
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public EventDeathMsg (  )
{
	static Killer; Killer = read_data ( 1 ); 
	
	static Victim; Victim = read_data ( 2 );
	
	static Head; Head = read_data ( 3 );
	
	static Weapon [24]; read_data ( 4, Weapon, charsmax ( Weapon ) );
	
	if ( !is_user_alive ( Killer ) || cs_get_user_team ( Killer ) == cs_get_user_team ( Victim ) || Killer == Victim ) 

		return PLUGIN_CONTINUE;
	
	/*if ( Killer == Victim )
	{
		SendDeathMsg ( Killer, Victim, Head, Weapon );

		return PLUGIN_CONTINUE;
	}*/

	if ( !WarmUp )
	{
		iMvpKills [Killer] ++;

		if ( Head )
		{
			iMvpHead [Killer] ++;
		} 
	}

	iDigit [Killer] ++; 

	SetKillsIcon ( Killer, 0 );

	/*new Assist = iMostDamage [Victim];

	if ( is_user_connected ( Assist ) && Assist != Killer )
	{
		//GiveBonus ( Assist, 0 );

		//ExecuteForward ( iForwards [2], iForwardResult, Assist, Killer, Victim, Head );

		new kName [32], Name1 [32], Name2 [32];

		new iName1Len = strlen ( Name [Killer] );

		new iName2Len = strlen ( Name [Assist] );
		
		if ( iName1Len < 14 )
		{
			formatex ( Name1, iName1Len, "%s", Name [Killer] );
			
			formatex ( Name2, 28 - iName1Len, "%s", Name [Assist] );
		}
		else
		{
			if ( iName2Len < 14 )
			{
				formatex ( Name1, 28 - iName2Len, "%s", Name [Killer] );
				
				formatex ( Name2, iName2Len, "%s", Name [Assist] );
			}

			formatex ( Name1, 13, "%s", Name [Killer] );
			
			formatex ( Name2, 13, "%s", Name [Assist] );
		}

		formatex ( kName, charsmax ( kName ), "%s + %s", Name1, Name2 );

		iAmxMode = get_pcvar_num ( pAmxMode );

		set_pcvar_num ( pAmxMode, 0 );

		IsChangeAllowed [Killer] = true;

		set_msg_block ( MsgSayText, 1 );

		set_user_info ( Killer, "name", kName );

		new WeaponLong [24];

		if ( equali ( Weapon, "grenade" ) )
		{
			formatex ( WeaponLong, charsmax ( WeaponLong ), "%s", "weapon_hegrenade" );
		}
		else
		{
			formatex ( WeaponLong, charsmax ( WeaponLong ), "weapon_%s", Weapon );
		}

		new Args [4];

		Args [0] = Killer;
		Args [1] = Victim;
		Args [2] = Head;
		Args [3] = get_weaponid ( WeaponLong );
		
		set_task ( 0.1, "TaskSendDeathMsg", Killer + 4000, Args, 4 );
	}
	else
	{
		SendDeathMsg ( Killer, Victim, Head, Weapon );
	}*/

	if ( iLogged [Victim] && iUserKills [Victim] > 0 && !WarmUp )
	{
		DerankCount [Victim] ++;

		if ( DerankCount [Victim] >= sDerankCount )
		{
			iUserKills [Victim] --;
			
			DerankCount [Victim] = 0;
		}
		
		if ( iUserRang [Victim] > 0 )
		{
			if ( RangKills [iUserRang [Victim] -1] >= iUserKills [Victim] )
			{
				iUserRang [Victim] --;	
						
				client_print_color ( 0, Victim, "%s^4 %L", CHAT_PREFIX, -1, "CSGO_RANK_RELEGATED", Name [Victim], RangName [iUserRang [Victim]] );
			}
		}

		for ( new f = 0; f < 2; f ++ )
		{
			if ( FactionKills [iUserSelectedFaction [Victim] [f]] > iUserKills [Victim] )
			{
				iUserSelectedFaction [Victim] [f] = 0;
			}
		}
	}

	if ( !iLogged [Killer] )
	{
		client_print_color ( Killer, Killer, "%s %L", CHAT_PREFIX, Killer, "CSGO_REGISTER_MSG" );
		
		return PLUGIN_CONTINUE;
	}

	if ( !WarmUp )
	{
		for ( new i = 1; i < SkinsNum; i ++ )
		{
			for ( new sID = 0; sID < 25; sID ++ )
			{
				new wID = i + 7000;

				if ( wID == iUserSelectedSkin [Killer] [sID] || wID + 10000 == iUserSelectedSkin [Killer] [sID] )
				{
					if ( get_user_weapon ( Killer ) == SkinID [i] )
					{
						STKills [Killer] [i] ++;
					}
				}
			}
		}
	
		iUserKills [Killer] ++;

		ExecuteForward ( iForwards [6], iForwardResult, Killer, Head );

		new bool: LevelUp = false;
		
		if ( RangsNum -1 > iUserRang [Killer] )
		{
			if ( RangKills [iUserRang [Killer] + 1] <= iUserKills [Killer] )
			{
				iUserRang [Killer] ++;

				if ( iUserRang [Killer] > UserMaxRang [Killer] )
				
					LevelUp = true;
					
				client_print_color ( 0, Killer, "%s^4 %L", CHAT_PREFIX, -1, "CSGO_RANK_REACHED", Name [Killer], RangName [iUserRang [Killer]] );
			}
		}

		new rPoints = 0;
		
		if ( Head )
		{
			rPoints = random_num ( sHMinPoints, sHMaxPoints );
		}
		else
		{
			rPoints = random_num ( sKMinPoints, sKMaxPoints );
		}	
		

		new vPoints = 0;

		if ( is_user_vip ( Killer ) && !VipStopped [1] )
		{
			vPoints = rPoints * sVipBonusMultiplier;
		}
		else
		{
			vPoints = rPoints;
		}

		iUserPoints [Killer] += vPoints;

		/*set_hudmessage ( 255, 255, 255, -1.00, 0.20, 0, 6.00, 2.00, 0.00, 0.00, -1 );
			
		show_hudmessage ( Killer, "%L", Killer, "CSGO_BONUS_POINTS", vPoints );*/

		if ( sDropChance >= random_num ( 1, 1000 ) )
		{
			new x = random_num ( 1, 100 )

			if ( x >= 1 && x <= 25 )
			{
				GiveChest ( Killer, 1 );
			}
			else if ( 25 < x <= 40 || 51 <= x <= 100 )
			{
				GiveChest ( Killer, 0 );
			}
			else if ( 40 < x <= 50 )
			{
				GiveChest ( Killer, 2 );
			}
		}

		if ( LevelUp )
		{	
			new iKeys = 0, iChests = 0, iPoints = 0, i = 0, iBonus [16];

			get_pcvar_string ( GoSettings [RANG_UP_BONUS], iBonus, charsmax ( iBonus ) );
				
			while ( iBonus [i] != '|' )
			{
				switch ( iBonus [i] )
				{
					case 'k': iKeys ++;
						
					case 'c': iChests ++;
		
					default: {  } // Keep looping
				}
					
				i ++;
			}
				
			new Temp [8]; strtok ( iBonus, Temp, charsmax ( Temp ), iBonus, charsmax ( iBonus ), '|', 0 );
				
			if ( iBonus [0] )
			{
				iPoints = str_to_num ( iBonus );
			}

			new Num = random_num ( 1, ChestsNum -1 );

			new gName1 [9], gName2 [9];
				
			if ( iKeys > 0 )
			{
				iUserKeys [Killer] [Num] += iKeys;

				formatex ( gName1, charsmax ( gName1 ), "%L", Killer, "CSGO_KEY", ChestName [Num] );
			}
				
			if ( iChests > 0 )
			{
				iUserChests [Killer] [Num] += iChests;

				formatex ( gName2, charsmax ( gName2 ), "%L", Killer, "CSGO_CHEST", ChestName [Num] );
			}
				
			if ( iPoints > 0 )
			{
				iUserPoints [Killer] += iPoints;
			}
		
			UserMaxRang [Killer] ++;

			new StrPoints [16];

			AddCommas ( iPoints, StrPoints, charsmax ( StrPoints ) );
					
			client_print_color ( Killer, Killer, "%s %L", CHAT_PREFIX, Killer, "CSGO_RANGUP_BONUS", iKeys, gName1, ChestName [Num], iChests, gName2, ChestName [Num], StrPoints );
		}	
	}
	
	return PLUGIN_CONTINUE;
}

stock GiveChest ( id, Num )
{
	switch ( Num )
	{
		case 0:
		{
			new rChest = 0, rChance = 0, bool: Success = false, Timer = 0;

			do
			{
				rChest = random_num ( 1, ChestsNum -1 );

				rChance = random_num ( 1, 100 );

				if ( rChance >= ChestChance [rChest] )
				{
					Success = true;
				}
			}
			while ( Timer < 5 && !Success )

			if ( Success )
			{
				new Num = random_num ( 1, 2 );

				switch ( Num )
				{
					case 1:
					{
						iUserKeys [id] [rChest] ++;

						client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_FOUND_KEY", ChestName [rChest] );
					}
					case 2:
					{
						iUserChests [id] [rChest] ++;

						client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_FOUND_CHEST", ChestName [rChest] );

						ExecuteForward(iForwards [7], iForwardResult, id, rChest);
					}
				}
			}
		}
		case 1:
		{
			iUserCaps [id] ++;

			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_FOUND_CAPS" );
		}
		case 2:
		{
			iUserGloveBoxes [id] ++;
			
			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_FOUND_GLOVE_BOX" );
		}
	}
}

/*public TaskSendDeathMsg ( Arg [ ], Killer )
{
	Killer -= 4000;

	new Victim = Arg [1];

	new Head = Arg [2];

	new Weapon = Arg [3];

	new WeaponLong [24];

	if ( Weapon != 0 )
	
		get_weaponname ( Weapon, WeaponLong, charsmax ( WeaponLong ) );

	if ( Weapon == 4 )
	{
		replace ( WeaponLong, charsmax ( WeaponLong ), "weapon_he", "" );
	}
	else
	{
		replace ( WeaponLong, charsmax ( WeaponLong ), "weapon_", "" );
	}

	SendDeathMsg ( Killer, Victim, Head, WeaponLong );
	
	set_msg_block ( MsgSayText, 1 );

	set_user_info ( Killer, "name", Name [Killer] );

	set_task ( 0.1, "TaskResetAmxMode", Killer + 5000 );

	return PLUGIN_CONTINUE;
}

public EventDamage ( id )
{
	if ( !is_user_connected ( id ) )
	{
		return PLUGIN_CONTINUE;
	}

	static Attacker;
	
	Attacker = get_user_attacker ( id );

	if ( !is_user_connected ( Attacker ) )
	{
		return PLUGIN_CONTINUE;
	}

	static Damage;

	Damage = read_data ( 2 );

	iDamage [id] [Attacker] += Damage;
	
	new TopDamager = iMostDamage [id];

	if ( iDamage [id] [Attacker] > iDamage [id] [TopDamager] )
	{
		iMostDamage [id] = Attacker;
	}

	return PLUGIN_CONTINUE;
}

public MessageDeathMsg ( msgId, msgDest, msgEnt )
{
	return PLUGIN_HANDLED;
}

SendDeathMsg ( Killer, Victim, Head, Weapon [ ] )
{
	message_begin ( MSG_ALL, MsgDeathMsg );
	write_byte ( Killer );
	write_byte ( Victim );
	write_byte ( Head );
	write_string ( Weapon );
	message_end (  );
}


public TaskResetAmxMode ( id )
{
	id -= 5000;

	IsChangeAllowed [id] = false;

	set_pcvar_num ( pAmxMode, iAmxMode );

	return PLUGIN_CONTINUE;
}*/

public leRoundEnd (  )
{
	BetWork = false;

	if ( IsGiveAway )
	{
		if ( sID >= 7000 )
		{
			client_print_color ( 0, 0, "^1[^4GiveAway^1]^3 :^1 Skin^4 :^3 %s^4 (^3StatTrak^4) |^3 %dsec.", SkinName [sID - 7000], sTime );
		}
		else
		{
			client_print_color ( 0, 0, "^1[^4GiveAway^1]^3 :^1 Skin^4 :^3 %s^4 |^3 %dsec.", SkinName [sID], sTime );
		}
	}

	new id = GetTopKiller (  );

	if ( !is_user_connected ( id ) || WarmUp )
	{
		return PLUGIN_CONTINUE;
	}

	client_print_color ( 0, id, "%s Round MVP:^3 %s^1 %L", CHAT_PREFIX, Name [id], -1, "CSGO_MVP_INFO",  iMvpKills [id], iMvpHead [id], fMvpDamage [id] );

	iUserMVP [id] ++;

	ExecuteForward ( iForwards [4], iForwardResult, id );
	
	//GiveBonus ( id, 1 );

	if ( iUserSelectedSound [id] != -1 && iLogged [id] )
	{
		client_print_color ( 0, id, "%s MVP:^4 %s", CHAT_PREFIX, TrackName [iUserSelectedSound [id]] );

		for ( new i = 1; i <= MaxPlayers; i ++ )
		{
			if ( MVPAllowed [i] )
			{
				PlaySound ( i, TrackUrl [iUserSelectedSound [id]] );
			}
		}

		TrackRemaining [id] [iUserSelectedSound [id]] --;

		if ( TrackRemaining [id] [iUserSelectedSound [id]] < 1 )
		{
			TrackRemaining [id] [iUserSelectedSound [id]] = 0;

			iUserSelectedSound [id] = -1;
		}
	}
	else
	{
		switch ( cs_get_user_team ( id ) )
		{
			case CS_TEAM_CT: PlaySound ( 0, CT_WIN );
					
			case CS_TEAM_T: PlaySound ( 0, T_WIN );
					
			default: 
			{ 
				return PLUGIN_CONTINUE; 
			}
		}
	}

	return PLUGIN_CONTINUE;
}

public EventNewRound (  )
{
	BetWork = true;

	arrayset ( iMvpKills, 0, sizeof ( iMvpKills ) );

	arrayset ( iMvpHead, 0, sizeof ( iMvpHead ) );

	for ( new i = 0; i < sizeof ( fMvpDamage ); i ++ )
	{
		fMvpDamage [i] = 0.0;
	}

	if ( sCompetitiveMode < 1 || WarmUp || get_playersnum (  ) < 2 )
	
		return PLUGIN_CONTINUE;

	new sNextMap [32];

	get_cvar_string ( "amx_nextmap", sNextMap, charsmax ( sNextMap ) );

	if ( !IsHalf (  ) )
	{
		iRoundNum ++;

		client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_COMPETITIVE_INFO", iRoundNum, sNextMap );
	}
	else
	{
		if ( TeamSwap )
		{
			client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_MAP_END" );
		
			ShowBestPlayers (  );
		
			set_task ( 7.00, "TaskMapEnd", 0, "", 0, "", 0 );
		}
		else //if ( IsHalf (  ) && !TeamSwap )
		{
			GiveAwayRound = false;

			client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_HALF" );
		
			ShowBestPlayers (  );
		
			new Float: Delay;
	
			for ( new i = 1; i <= MaxPlayers; i ++ )
			{
				if ( is_user_connected ( i ) )
				{
					set_user_godmode ( i, 1 );

					Delay = 0.20 /*1045220557*/ * i;
				
					set_task ( Delay, "TaskDelayedSwap", i + 7000, "", 0, "", 0 );
				}
			}
		
			set_task ( 7.0, "TaskTeamSwap", 0, "", 0, "", 0 );
		}
	}

	return PLUGIN_CONTINUE;
}

public TaskDelayedSwap ( id )
{
	id -= 7000;
 
	if ( !is_user_connected ( id ) )
	{
		return PLUGIN_CONTINUE;
	}
   
	switch ( cs_get_user_team ( id )  ) 
	{
		case  CS_TEAM_T:  cs_set_user_team ( id,  CS_TEAM_CT );
		
		case  CS_TEAM_CT: cs_set_user_team ( id,  CS_TEAM_T );		
	}

	return PLUGIN_CONTINUE;
}

bool:IsHalf (  )
{
	if ( iScore [0] + iScore [1] == 15 )
	{
		return true;
	}
	
	return false;
}

public TaskMapEnd (  )
{
	set_cvar_num ( "mp_freezetime", 0 );

	emessage_begin ( MSG_ALL, SVC_INTERMISSION );
	
	emessage_end (  );
}

public TaskTeamSwap (  )
{
	TeamSwap = true;
	
	set_cvar_num ( "mp_freezetime", 3 );
	
	client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_TEAMS_CHANGED" );

	for ( new i = 1; i <= MaxPlayers; i ++ )
	{
		if ( is_user_connected ( i ) )
		{
			iUserMVP [i] = 0;

			set_user_godmode ( i, 0 );
		}
	}
	
	server_cmd ( "sv_restart 1" );
}

public TaskWarmUp ( Task )
{
	if ( sWarmTimer > 0 )
	{
		set_hudmessage ( 0, 255, 0, -1.00, 0.80, 0, 0.00, 1.10, 0.00, 0.00, -1 );
		
		ShowSyncHudMsg ( 0, SyncHud2, "WarmUp: %d secund%s", sWarmTimer, sWarmTimer == 1 ? "a" : "e" );
	}
	else
	{
		WarmUp = false;
		
		//iRoundNum = 1;
		
		set_cvar_num ( "mp_freezetime", 3 );
		
		set_cvar_num ( "mp_startmoney", 800 );
		
		remove_task ( Task );
		
		server_cmd ( "sv_restart 1" );
	}
	
	sWarmTimer --;
}

public leGameCommencing (  )
{
	iRoundNum = 0;
	
	if ( sCompetitiveMode < 1 )

		return PLUGIN_CONTINUE;

	if ( task_exists ( 9000 ) )

		return PLUGIN_CONTINUE;

	WarmUp = true;
	
	set_cvar_num ( "mp_freezetime", 0 );
	
	set_cvar_num ( "mp_startmoney", 16000 );
	
	set_task ( 1.0, "TaskWarmUp", 8000, "", 0, "b" );
   
	return PLUGIN_CONTINUE;
}

public leRestartRound (  )
{
	if ( sCompetitiveMode < 1 )
	{
		iRoundNum = 0;
	}

	arrayset ( iScore, 0, sizeof ( iScore ) );

	set_cvar_num ( "mp_startmoney", 800 );
}

public EventRoundWonT (  ) 
{
	iScore [0] ++;

	for ( new i = 1; i <= MaxPlayers; i ++ )
	{
		if ( bUserBet [i] && SelectBetTeam [i] == 1 )
		{
			new a = BetValue [i] * sBetTeamMultiplier;

			iUserPoints [i] += a;

			new StrPoints [16];

			AddCommas ( a, StrPoints, charsmax ( StrPoints ) );

			client_print_color ( i, i, "%s %L", CHAT_PREFIX, i, "CSGO_BET_TEAM_WIN" );

			ClearBetTeam ( i );
		}
	}
}

public EventRoundWonCT (  ) 
{
	iScore [1] ++;

	for ( new i = 1; i <= MaxPlayers; i ++ )
	{
		if ( bUserBet [i] && SelectBetTeam [i] == 2 )
		{
			new a = BetValue [i] * sBetTeamMultiplier;

			iUserPoints [i] += a;

			new StrPoints [16];

			AddCommas ( a, StrPoints, charsmax ( StrPoints ) );

			client_print_color ( i, i, "%s %L", CHAT_PREFIX, i, "CSGO_BET_TEAM_WIN" );

			ClearBetTeam ( i );
		}
	}
}

public EventRoundDraw (  ) 
{
	for ( new i = 1; i <= MaxPlayers; i ++ )
	{
		if ( bUserBet [i] && SelectBetTeam [i] > 0 )
		{
			ClearBetTeam ( i );
		}
	}
}

ClearBetTeam ( Index )
{
	bUserBet [Index] = false;
	
	SelectBetTeam [Index] = 0;

	BetValue [Index] = 0;
}
	
ShowBestPlayers (  )
{
	new Players [32], Num, id, BestPlayer, Frags, BestFrags, MVP, BestMVP, StrPoints [16];
   
	AddCommas ( sMVPBonus, StrPoints, charsmax ( StrPoints ) );
    
	get_players ( Players, Num, "he", "TERRORIST" );

	if ( Num > 0 )
	{
		for ( new i = 0; i < Num; i ++ )
		{
			id = Players [i];
			
			MVP = iUserMVP [id];
			
			if ( MVP < 1 || MVP < BestMVP )
			{
			}
			else
			{
				Frags = get_user_frags ( id );
			
				if ( MVP > BestMVP )
				{
					BestPlayer = id;
					
					BestMVP = MVP;
					
					BestFrags = Frags;
				}
				else
				{
					if ( Frags > BestFrags )
					{
						BestPlayer = id;
						
						BestFrags = Frags;
					}
				}
			}
		}
	}
	
	if ( BestPlayer && BestPlayer <= MaxPlayers )
	{
		client_print_color ( BestPlayer, BestPlayer, "%s %L", CHAT_PREFIX, BestPlayer, "CSGO_BEST_T", StrPoints, BestMVP );
	}
	/*else
	{ 
		client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_ZERO_MVP", "Terrorist" );
	}*/
	
	if ( iLogged [BestPlayer] )
	{
		iUserPoints [BestPlayer] += sMVPBonus;
	}
	
	get_players ( Players, Num, "he", "CT" );
	    
	BestPlayer = 0;
	
	BestMVP = 0;
	
	BestFrags = 0;
	
	if ( Num > 0 )
	{
		for ( new i = 0; i < Num; i ++ )
		{
			id = Players [i];
			
			MVP = iUserMVP [id];
			
			if ( MVP < 1 || MVP < BestMVP )
			{
			}
			else
			{
				Frags = get_user_frags ( id );
			
				if ( MVP > BestMVP )
				{
					BestPlayer = id;
					
					BestMVP = MVP;
					
					BestFrags = Frags;
				}
				else
				{
					if ( Frags > BestFrags )
					{
						BestPlayer = id;
						
						BestFrags = Frags;
					}
				}
			}
		}
	}
	
	if ( BestPlayer && BestPlayer <= MaxPlayers )
	{
		client_print_color ( BestPlayer, BestPlayer, "%s %L", CHAT_PREFIX, BestPlayer, "CSGO_BEST_CT", StrPoints, BestMVP );
	}
	/*else
	{
		client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_ZERO_MVP", "Counter-Terrorist" );
	}*/
	
	if ( iLogged [BestPlayer] )
	{
		iUserPoints [BestPlayer] += sMVPBonus;
	}
}

public HamPlayerKilledPost ( id ) 
{	
	if ( WarmUp )
	{
		set_task ( 1.0, "TaskRespawnPlayer", id + 9000 );
	}
}

public TaskRespawnPlayer ( id )
{
	id -= 9000;
	
	if ( !is_user_connected ( id ) || is_user_alive ( id ) || get_user_team ( id ) == 3 )
	{
		return PLUGIN_CONTINUE;
	}
	
	ExecuteHamB ( Ham_CS_RoundRespawn, id );
	
	return PLUGIN_CONTINUE;
}


public HamPlayerSpawnPre ( id )
{
	if ( is_user_connected ( id ) && !iFirstSpawn [id] && get_pdata_int ( id, 113, 5 ) )
	{
		new Float: iNextAttack = get_pdata_float ( id, 83, 5 );
		
		set_pdata_float ( id, 83, 0.00, 5 );

		new iWeapon = 0;
		
		for ( new iPlayerItems = 368; iPlayerItems <= 369; iPlayerItems ++ )
		{
			iWeapon = get_pdata_cbase ( id, iPlayerItems, 5 );
			
			if ( pev_valid ( iWeapon ) )
			{
				set_pdata_int ( iWeapon, 54, 1, 4 );
				
				ExecuteHamB ( Ham_Item_PostFrame, iWeapon );
			}
		}
		
		set_pdata_float ( id, 83, iNextAttack, 5 );
	}
	
	return HAM_IGNORED;
}

public HamPlayerSpawnPost ( id ) 
{
	if ( !is_user_alive ( id ) ) return HAM_IGNORED;
	
	if ( is_user_vip ( id ) )
	{
		InjectorAmmo [id] = sInjectorAmmo;
	}

	set_task ( 0.25, "TaskSetIcon", id + 32 );
	
	for ( new iAmmoIndex = 1; iAmmoIndex <= 10; iAmmoIndex ++ )
	{
		set_pdata_int ( id, 376 + iAmmoIndex, MAX_BP_AMMO [iAmmoIndex], 5 );
	}

	if ( !is_user_vip ( id ) )
	{
		if ( FactionKills [iUserSelectedFaction [id] [0]] == 0 )
		{
			iUserSelectedFaction [id] [0] = 0;
		}

		if ( FactionKills [iUserSelectedFaction [id] [1]] == 0 )
		{
			iUserSelectedFaction [id] [1] = 0;
		}
	}

	cs_reset_player_model ( id );

	if ( iUserSelectedFaction [id] [0] > 0 && cs_get_user_team ( id ) == CS_TEAM_T && iUserKills [id] >= FactionKills [iUserSelectedFaction [id] [0]] )
	{
		cs_set_player_model ( id, TFactionMdl [iUserSelectedFaction [id] [0]] );
	}
	else if ( iUserSelectedFaction [id] [1] > 0 && cs_get_user_team ( id ) == CS_TEAM_CT && iUserKills [id] >= FactionKills [iUserSelectedFaction [id] [0]] )
	{
		cs_set_player_model ( id, CTFactionMdl [iUserSelectedFaction [id] [1]] );
	}
	
	SprayCooldown [id] = 0;

	remove_task ( id + 2002991, 0 );

	/*new CurrentName [32];

	get_user_name ( id, CurrentName, charsmax ( CurrentName ) );

	if ( !equali ( CurrentName, Name [id] ) )
	{
		IsChangeAllowed [id] = true;

		set_msg_block ( MsgSayText, 1 );

		set_user_info ( id, "name", Name [id] );

		set_task ( 0.1, "TaskResetName", id + 6000 );
	}

	iMostDamage [id] = 0;

	arrayset ( iDamage [id], 0, 33 );*/
	
	return HAM_SUPERCEDE;
}

/*public TaskResetName ( id )
{
	id -= 6000;

	IsChangeAllowed [id] = false;
	
	return PLUGIN_CONTINUE;
}*/

public TaskSetIcon ( id )
{
	id -= 32;
	
	if ( is_user_alive ( id ) )

		SetKillsIcon ( id, 1 );
}

SetKillsIcon ( id, Reset )
{
	if ( !is_user_connected ( id ) ) return PLUGIN_CONTINUE;

	switch ( Reset )
	{
		case 0:
		{
			new Num = iDigit [id];
			
			if ( Num > 10 )
			{
				return PLUGIN_CONTINUE;
			}
				
			Num --;
			
			message_begin ( MSG_ONE_UNRELIABLE, get_user_msgid ( "StatusIcon" ), { 0, 0, 0 }, id );
			
			write_byte ( 0 );
			
			write_string ( FRAG_SPRITES [Num] );
			
			message_end (  );
			
			Num ++;
			
			message_begin ( MSG_ONE_UNRELIABLE, get_user_msgid ( "StatusIcon" ), { 0, 0, 0 }, id );
			
			write_byte ( 1 );
			
			if ( Num > 9 )
			{ 
				write_string ( FRAG_SPRITES [10] );
			}
			else
			{
				write_string ( FRAG_SPRITES [Num] );
			}
			
			write_byte ( 0 );
			
			write_byte ( 200 );
			
			write_byte ( 0 );
			
			message_end (  );
		}
		case 1:
		{
			new Num = iDigit [id];
			
			message_begin ( MSG_ONE_UNRELIABLE, get_user_msgid ( "StatusIcon" ), { 0, 0, 0 }, id );
	
			write_byte ( 0 );

			if ( Num > 9 )
			{
				write_string ( FRAG_SPRITES [10] );
			}
			else
			{
				write_string ( FRAG_SPRITES [Num] );
			}
	
			message_end (  );
	
			iDigit [id] = 0;
	
			message_begin ( MSG_ONE_UNRELIABLE, get_user_msgid ( "StatusIcon" ), { 0, 0, 0 }, id );
	
			write_byte ( 1 );

			write_string ( FRAG_SPRITES [0] );
		
			write_byte ( 0 );
	
			write_byte ( 200 );
	
			write_byte ( 0 );
	
			message_end (  );
		}
		default: {  }
	}
	
	return PLUGIN_CONTINUE;
}


public HamPlayerTakeDamage ( iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits )
{
	if ( is_user_connected ( iAttacker ) && iVictim != iAttacker && is_user_connected ( iVictim ) )
	{
		if ( cs_get_user_team ( iVictim ) != cs_get_user_team ( iAttacker ) )
		{
			fMvpDamage [iAttacker] += fDamage;
		}
	}
}

public HamKnifeHolstered ( Entity )
{
	new id = get_pdata_cbase ( Entity, 41, 4 );
	
	if( !pev_valid ( Entity ) )

		return HAM_IGNORED;

	if ( 1 <= id <= MaxPlayers )

		remove_task ( id + 25071973 );
	
	return HAM_IGNORED;
}

public HamGrenadePA ( Entity )
{
	if ( !( pev_valid ( Entity ) == 2 ) )
	{
		return HAM_IGNORED;
	}
	
	new id = get_pdata_cbase ( Entity, 41, 4 );
	
	ShortThrow [id] = false;
    
	return HAM_IGNORED;
}

public HamGrenadeSA ( Entity )
{
	if ( !( pev_valid ( Entity ) == 2 ) )
	{
		return HAM_IGNORED;
	}
	
	new id = get_pdata_cbase ( Entity, 41, 4 );
    
	ExecuteHamB ( Ham_Weapon_PrimaryAttack, Entity );
    
	ShortThrow [id] = true;
    
	return HAM_IGNORED;
}

public grenade_throw ( id, Entity, WeaponIndex )
{
	if ( !( pev_valid ( Entity ) ) || !( 0 < id && 32 >= id || !is_user_connected ( id ) ) )
	{
		return PLUGIN_CONTINUE;
	}
	
	if ( !ShortThrow [id] )
	{
		return PLUGIN_CONTINUE;
	}
	
	if ( WeaponIndex == 25 )
	{
		set_pev ( Entity, pev_dmgtime, get_gametime ( ) + 1.0 );
	}
		
	static Float:fVec [3]; 
	
	pev ( Entity, pev_velocity, fVec );
	
	fVec [0] *= 0.5;
	fVec [1] *= 0.5;
	fVec [2] *= 0.5;
	
	set_pev ( Entity, pev_velocity, fVec );
	
	pev ( Entity, pev_origin, fVec );
	
	fVec [2] -= 24.0;
	
	set_pev ( Entity, pev_origin, fVec );
	
	return PLUGIN_CONTINUE;
}


public RemoveWeapons ( Entity )
{
	if ( WeaponDropped + 1 >= 800 )

		WeaponDropped = 0;

	if ( !pev_valid ( Entity ) )

		return 0;

	for ( new w = 0; w < WeaponDropped + 1; w ++ )
	{
		if ( wPickUp [w] [0] == Entity )
		{
			wPickUp [w] [0] = 0;

			wPickUp [w] [2] = 0;

			formatex ( wPickUp1 [w], charsmax ( wPickUp1 [ ] ), "" );

			formatex ( wPickUp2 [w], charsmax ( wPickUp2 [ ] ), "" );
		}
	}

	return 0;
}

public HamWeaponSecondaryAttack ( Entity )
{
	static id;
	
	id = get_pdata_cbase ( Entity, 41, 4 );
	
	ExecuteHam ( Ham_Weapon_SecondaryAttack, Entity );
	
	set_pdata_float ( id, 83, 1.5, 5 );

	set_pdata_float ( Entity, 48, 2.5, 4 );
	
	SendWeaponAnim ( id, 5 );
	
	return HAM_SUPERCEDE;	
}

public HamCSWeaponSendWeaponAnimPost ( Entity, Anim, Skiplocal )
{
	Skiplocal = false;
	
	static id;
 
	id = get_pdata_cbase ( Entity, 41, 4 );
	
	if(!is_user_connected(id))
	{
		return HAM_IGNORED;
	}

	SendWeaponAnim ( id, Anim );
	
	SendSpectatorAnim ( id, Anim );		
	
	return HAM_IGNORED;
}

public ForwardPlaybackEvent ( iFlags, id, iEvent, Float: fDelay, Float: vecOrigin [3], Float: vecAngle [3], Float: flParam1, Float: flParam2, iParam1, iParam2, bParam1, bParam2 )
{
	if ( is_user_alive ( id ) )
	{	
		return FMRES_SUPERCEDE;
	}

	for ( new iFirstPerson = 1; iFirstPerson < 33; iFirstPerson ++ )
	{			
		if ( is_user_connected ( iFirstPerson ) && !is_user_alive ( iFirstPerson ) && !is_user_bot ( iFirstPerson ) )
		{				
			if ( pev ( iFirstPerson, pev_iuser2 ) == id )
			{
				return FMRES_SUPERCEDE;
			}
		}
	}	
	
	return FMRES_IGNORED;
}

public iSpectatorViewBody ( id )
{
	if ( !( 1 <= id <= MaxPlayers ) )
	{	
		return PLUGIN_HANDLED;
	}
	
	iSpectatorTarget [id] = read_data ( 2 );
	
	if ( !iSpectatorTarget [id] )
	{
		return PLUGIN_HANDLED;
	}
	
	CurrentWeapon(id);

	SendWeaponAnim ( id, 0 );
		
	return PLUGIN_CONTINUE;
}

public HamPlayerKilledPre ( id )
{
	WeaponPickUp ( id )
}
	

GetTopKiller (  )
{
	new iPlayers [32], Num, id;
	
	get_players ( iPlayers, Num, "ch" );

	new iPlayer;

	for ( new i = 0;i < Num; i ++ )
	{
		iPlayer = iPlayers [i];

		if ( iMvpKills [id] < iMvpKills [iPlayer] )
		{
			id = iPlayer;
		}
		else if ( iMvpKills [id] == iMvpKills [iPlayer] )
		{
			if ( fMvpDamage [iPlayer] > fMvpDamage [id] )
			{
				id = iPlayer;
			}
		}
	}

	new Temp;

	if ( iMvpKills [id] )
	{
		Temp = id;
	}
	else
	{
		Temp = -1;
	}

	return Temp;
}

PlaySound ( Index, const Sound [ ] ) 
{
	client_cmd ( Index, "stopsound" );
	
	if ( equal ( Sound [strlen ( Sound ) - 4], ".mp3" ) )
	{
		client_cmd ( Index, "mp3 play ^"sound/%s^"", Sound )
	}
	else
	{
		client_cmd ( Index, "spk ^"%s^"", Sound );
	}
}

public CurrentWeapon ( id )
{
	/*if ( id > 32 || id < 1 || !is_user_alive ( id ) )
	{
		return PLUGIN_HANDLED;
	}*/

	if ( ! ( 1 <= id <= MaxPlayers ) || !is_user_alive ( id ) )
	{
		return PLUGIN_HANDLED;
	}

	if ( WarmUp )
	{
		engclient_cmd ( id, "weapon_knife" );

		return PLUGIN_HANDLED;
	}

	//g_iUserViewBody[id] = GloveIndex [g_iUserSelectedGlove [id]] + g_iUserSelectedSkin[id][g_iIndex[id]];

	//SetViewEntityBody(id, g_iUserViewBody[id])

	InspectToggle [id] = true;

	//client_print(id, print_chat, "Glove: %i; Skin: %i", GloveIndex [g_iUserSelectedGlove [id]], g_iUserSelectedSkin[id]);

	//g_iUserViewBody[id] = GloveIndex [g_iUserSelectedGlove [id]] + g_iUserSelectedSkin[id][get_user_weapon(id)];

	//SetViewEntityBody ( id, g_iUserViewBody[id] );

	SkinInfo [id] = 0;

	new Entity = get_pdata_cbase ( id, 373 );

	if ( pev_valid ( Entity ) )
	{
		new Impulse = pev ( Entity, pev_impulse );

		if ( Impulse > 0 )
		{
			set_pev ( id, pev_viewmodel2, SkinMdl [Impulse] );

			SkinInfo [id] = 2;

			return PLUGIN_HANDLED;
		}
	}

	new wID;

	for ( new i = 1; i < SkinsNum && iLogged [id]; i ++ )
	{
		for ( new sID = 0; sID < 25; sID ++ )
		{
			wID = i + 7000;

			if ( i == iUserSelectedSkin [id] [sID] && iUserSkins [id] [i] || i + 10000 == iUserSelectedSkin [id] [sID] && SkinTag [id] [i] == 1 )
			{
				if ( get_user_weapon ( id ) == SkinID [i] )
				{
					set_pev ( id, pev_viewmodel2, SkinMdl [i] );

					return PLUGIN_HANDLED;
				}
			}
			else if ( wID == iUserSelectedSkin [id] [sID] && iUserSTs [id] [i] || wID + 10000 == iUserSelectedSkin [id] [sID] && SkinTag [id] [i] == 2 )
			{
				if ( get_user_weapon ( id ) == SkinID [i] )
				{
					set_pev ( id, pev_viewmodel2, SkinMdl [i] );

					SkinInfo [id] = 1;

					return PLUGIN_HANDLED;
				}
			}
		}
	}

	return PLUGIN_CONTINUE;
}

SetViewEntityBody ( Index, Value )
{
	g_iUserViewBody [Index] = Value;
}

public InspectWeapon ( id )
{
	if ( !is_user_alive ( id ) || !is_user_connected ( id ) )
    
		return PLUGIN_HANDLED

	if( cs_get_user_shield ( id ) ) return PLUGIN_HANDLED
 
	if ( cs_get_user_zoom ( id ) > 1 ) return PLUGIN_HANDLED

	if ( !InspectToggle [id] ) return PLUGIN_HANDLED;

    	new WeaponID = get_user_weapon ( id );
 
	static Weapon;
    	
	Weapon = get_pdata_cbase ( id, 373 );
 
	if ( !pev_valid ( Weapon ) )

		return PLUGIN_HANDLED;

    	set_pdata_float ( Weapon, 48, 7.0, 4 );
 
 	new Anim;

    	switch ( WeaponID )
   	{
       		case CSW_M4A1:
		{
		
            		if ( !cs_get_weapon_silen ( Weapon ) ) 
	    		{
				Anim = 15;
	    		}
            		else 
			{
	 			Anim = AnimationIds [WeaponID];
			}
		}
       	 	case CSW_USP:
		{	
			if ( !cs_get_weapon_silen ( Weapon ) )
			{
				Anim = 17;
			}
           		else 
			{
				Anim = AnimationIds [WeaponID];
			}
		}

       		default: Anim = AnimationIds [WeaponID];
    	}
 
    	if ( !get_pdata_int ( Weapon, 54, 4 ) )
	{
        	SendWeaponAnim ( id, Anim );
	}

	InspectToggle [id] = false;

    	set_pdata_float ( Weapon, 48, IdleCallTime [WeaponID], 4 );
 
   	return PLUGIN_HANDLED;
}
 
public ClientUserInfoChanged ( id )
{
	/*if ( IsChangeAllowed [id] )
	{
		return FMRES_IGNORED;
	}*/

	static const Name [] = "name"

	static NewName [32], OldName [32], iUserInfo [6] = "cl_lw", iClientValue [2], iServerValue [2] = "0";
	
	pev ( id, pev_netname, OldName, charsmax ( OldName ) );

	if ( OldName [0] )
	{
		get_user_info ( id, Name, NewName, charsmax ( NewName ) );
       
		if ( !equal ( OldName, NewName ) )
		{
			set_user_info ( id, Name, OldName );
			
			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_CANT_CHANGE_ACC" );
            
			return FMRES_HANDLED;
		}
	}

	if ( get_user_info ( id, iUserInfo, iClientValue, charsmax ( iClientValue ) ) )
	{
		set_user_info ( id, iUserInfo, iServerValue );	
		
		return FMRES_SUPERCEDE;
	}
			
	return FMRES_IGNORED;
}

public WeaponPickUp ( id )
{
	if ( WeaponDropped + 1 >= 800 )
		
		WeaponDropped = 0;

	if ( !is_user_connected ( id ) || !iLogged [id] )
	{
		return PLUGIN_CONTINUE;
	}

	new Entity = get_pdata_cbase ( id, 373 );

	if ( !pev_valid ( Entity ) )
	{
		return PLUGIN_CONTINUE;
	}

	new wID;

	new Impulse = pev ( Entity, pev_impulse );

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		for ( new sID = 0; sID < 25; sID ++ )
		{
			wID = i + 7000;

			if ( Impulse > 0 )

				return PLUGIN_CONTINUE;

			if ( ( i == iUserSelectedSkin [id] [sID] || wID == iUserSelectedSkin [id] [sID] || wID + 7000 == iUserSelectedSkin [id] [sID] || wID + 10000 == iUserSelectedSkin [id] [sID] ) && get_user_weapon ( id ) == SkinID [i] && get_user_weapon ( id ) != CSW_KNIFE )
			{
				WeaponDropped ++;

				wPickUp [WeaponDropped] [0] = Entity;

				wPickUp [WeaponDropped] [2] = SkinID [i];

				set_pev ( Entity, pev_impulse, i );

				get_user_name ( id, wPickUp2 [WeaponDropped], 32 );

				if ( i == iUserSelectedSkin [id] [sID] )
				{
					formatex ( wPickUp1 [WeaponDropped], charsmax ( wPickUp1 [ ] ), "%s", SkinName [i] );
				}
				else if ( wID == iUserSelectedSkin [id] [sID] )
				{
					formatex ( wPickUp1 [WeaponDropped], charsmax ( wPickUp1 [ ] ), "[StatTrak] %s (%s)", SkinName [i], GetSTClass ( id, i ) );
				}
				else if ( wID + 7000 == iUserSelectedSkin [id] [sID] )
				{
					formatex ( wPickUp1 [WeaponDropped], charsmax ( wPickUp1 [ ] ), "^"%s^"", SkinTagN [id] [i] );
				}

				else if ( wID + 10000 == iUserSelectedSkin [id] [sID] )
				{
					formatex ( wPickUp1 [WeaponDropped], charsmax ( wPickUp1 [ ] ), "[StatTrak] ^"%s^" (%s)", SkinTagN [id] [i], GetSTClass ( id, i ) );
				}

				return PLUGIN_CONTINUE;
			}
		}
	}

	return PLUGIN_CONTINUE;
}

public ShowRegMenu ( id )
{
	new Temp [64]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_REG_MENU" );
	
	new Menu = menu_create ( Temp, "RegMenuHandler", 0 );
	
	formatex ( Temp, charsmax ( Temp ), "\r%L\w %s", id, "CSGO_REG_ACCOUNT", Name [id] );
	
	menu_additem ( Menu, Temp, "0", 0, -1 );
	
	formatex ( Temp, charsmax ( Temp ), "\r%L\w %s^n", id, "CSGO_REG_PASSWORD", equali ( iUserPassword [id], "" ) ? "N/A" : iUserPassword [id] );
	
	menu_additem ( Menu, Temp, "1", 0, -1 );
	
	if ( IsRegistered ( id ) )
	{
		if ( !iLogged [id] )
		{
			formatex ( Temp, charsmax ( Temp ), "\r%L", id, "CSGO_REG_LOGIN" );
			
			menu_additem ( Menu, Temp, "3", 0, -1 );
		}
		else
		{
			formatex ( Temp, charsmax ( Temp ), "\r%L", id, "CSGO_REG_LOGOUT" );
				
			menu_additem ( Menu, Temp, "2", 0, -1 );
		}
	}
	else
	{	
		formatex ( Temp, charsmax ( Temp ), "\r%L", id, "CSGO_REG_REGISTER" );
		
		menu_additem ( Menu, Temp, "4", 0, -1 );
	}

	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

bool:IsRegistered ( id )
{
	if ( strlen ( iUserSavedPass [id] ) >= 4 )

		return true;

	return false;
}

public RegMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT ) return DestroyMenu ( Menu );

	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );

	new Len = strlen ( iUserPassword [id] );
	
	switch ( Index )
	{
		case 0:
		{	
			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_CANT_CHANGE_ACC" );
			
			ShowRegMenu ( id );
		}
		case 1:
		{
			if ( !iLogged [id] )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TYPE_PASS", 4 );
				
				client_cmd ( id, "messagemode UserPassword" );
			}
		}
		case 2:
		{
			if ( sLogFade > 0 )
			{
				MessageScreenFade ( id, 6<<10, 0, 0, 255, 0, 0, 200 );
			} 

			iLogged [id] = false;
			
			iUserPassword [id] = "";

			ExecuteForward ( iForwards [0], iForwardResult, id );
			
			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_LOGOUT_SUCCESS" );
		}
		case 3:
		{
			if (  Len < 4  )
			{
				ShowRegMenu ( id );
				
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_PASS_REQ_MIN", 4 );
				
				return DestroyMenu ( Menu );
			}
				
			if ( !equali ( iUserPassword [id], iUserSavedPass [id] ) )
			{
				iUserPassFail[id] ++;
				
				if ( iUserPassFail [id] >= 3 )
				{
					new Reason [32]; formatex ( Reason, charsmax ( Reason ), "%L", id, "CSGO_MAX_PASS_FAIL", 3 );
					
					server_cmd ( "kick #%d ^"%s^"", get_user_userid ( id ), Reason );
				}
				else
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_PASS_FAIL", iUserPassFail [id], 3 );
					
					ShowRegMenu ( id );
				}
			}
			else
			{
				set_user_info ( id, sPasswordField, iUserSavedPass [id] ) ;
   				
				client_cmd ( id, "setinfo %s %s", sPasswordField, iUserSavedPass [id] );
	
				if ( sLogFade > 0 )
				{
					MessageScreenFade ( id, 6<<10, 0, 0, 0, 0, 255, 200 ); 
				}

				iLogged [id] = true;
				
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_LOGIN_SUCCESS" );
		
				ExecuteForward ( iForwards [5], iForwardResult, id );
				
				ShowMainMenu ( id );
			}
		}
		case 4:
		{
			if ( Len < 4 )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_PASS_REQ_MIN", 4 );
				
				ShowRegMenu ( id );
				
				return DestroyMenu ( Menu );
			}

			if ( sLogFade > 0 )
			{
				MessageScreenFade ( id, 6<<10, 0, 0, 0, 255, 0, 200 );
			} 
	
			copy ( iUserSavedPass [id], charsmax ( iUserSavedPass [ ] ), iUserPassword [id] );

			SaveLog ( id );
			
			SaveData ( id );

			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_REG_SUCCESS", iUserSavedPass [id] );
			
			ShowRegMenu ( id );
		}
		default: {    }
	}
	
	return DestroyMenu ( Menu );
}

public PlayerPassword ( id )
{
	if ( iLogged [id] )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_ALREADY_LOGIN" );
		
		return PLUGIN_HANDLED;
	}
    
	new Data [32];
	
	read_args ( Data, charsmax ( Data ) );
   
	remove_quotes ( Data );

	MakeStringSQLSafeAll ( Data, charsmax ( Data ) );
    
	if ( strlen ( Data ) > 8 )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_PASS_REQ_MAX", 8 );
		
		client_cmd ( id, "messagemode UserPassword" );
		
		return PLUGIN_HANDLED;
	}
	
	copy ( iUserPassword [id], charsmax ( iUserPassword [ ] ), Data );
	
	ShowRegMenu ( id );
	
	return PLUGIN_HANDLED;
}


public ShowMainMenu ( id )
{
	if ( !iLogged [id] )
	{
		ShowRegMenu ( id )
		
		return PLUGIN_CONTINUE;
	}
	
	new Temp [96];

	new StrPoints [16];

	AddCommas ( iUserPoints [id], StrPoints, charsmax ( StrPoints ) );
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L %L\d", id, "CSGO_MAIN_MENU", id, "CSGO_MM_INFO", StrPoints );
	
	new Menu = menu_create ( Temp, "MainMenuHandler", 0 );
	
	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_INVENTORY" );
		
	menu_additem ( Menu, Temp, "", 0, -1 );
	
	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_OCC" );
		
	menu_additem ( Menu, Temp, "", 0, -1 );

	if ( iUserSell [id] )
	{
		new Sell [128];
		
		GetItemName ( id, iUserSellItem [id], Sell, charsmax ( Sell ) );
		
		formatex ( Temp, charsmax ( Temp ), "\w%L\d [\y%L:\r %s\d]", id, "CSGO_MM_MARKET", id, "CSGO_MARKET_SELL", Sell );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_MARKET" );
	}

	menu_additem ( Menu, Temp, "", 0, -1 );
	
	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_SHOP" );
	
	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_GAMES" );
		
	menu_additem ( Menu, Temp, "", 0, -1 );
	
	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_GIFT" );
		
	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "%s%L%s", HasTrade [id] ? "\d" : "\w", id, "CSGO_MM_TRADE", HasTrade [id] ? "\r (New Offer)" : "" );
		
	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_DUSTBIN" );
	
	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_UPGRADE" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_DAILY_REWARD" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_PROMOCODE" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_CROSSHAIR" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_PREVIEW" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_VIP_INFO" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_QUESTS" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_FACTIONS" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_DMG_HUDSET" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_CLAN_MENU" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_ACHIEVMENTS_MENU" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public MainMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		return DestroyMenu ( Menu );
	}

	switch ( Item )
	{
		case 0: ShowInventoryMenu ( id ); 

		case 1: ShowChestsMenu ( id ); 

		case 2: ShowMarketMenu ( id ); 

		case 3: ShowShopMenu ( id ); 

		case 4: ShowGamesMenu ( id ); 

		case 5: ShowGiftMenu ( id ); 

		case 6: 
		{
			if ( HasTrade [id] )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_INFO2" );
		
				ShowMainMenu ( id );

				return DestroyMenu ( Menu );
			}
			else
			{
				ShowTradeMenu ( id ); 
			}
		}

		case 7: ShowDustbinMenu ( id );

		case 8: ShowUpgradeMenu ( id );

		case 9: GetYourReward ( id );

		case 10:
		{
			client_cmd ( id, "messagemode TypeCode" );
		}

		case 11: client_cmd ( id, "say /ch" );

		case 12: ShowPreviewMenu ( id ); 

		case 13: ShowVipInfo ( id );

		case 14: show_quests_menu ( id );

		case 15: ShowFactionsTeamMenu ( id );

		//case 16: client_cmd ( id, "say /dmg" );

		case 17: csgo_show_clan_menu ( id );

		case 18: csgo_show_achievments_menu( id );

		default: {   }
	}

	return DestroyMenu ( Menu );
}

ShowInventoryMenu ( id )
{
	new Temp [96]; 

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_INVENTORY_MENU" );

	new Menu = menu_create ( Temp, "InventoryMenuHandler", 0 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_SKINS" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_GLOVE" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_SPRAY" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_MVP" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;
}

public InventoryMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );

		return DestroyMenu ( Menu );
	}

	switch ( Item )
	{
		case 0: ShowSSMenu ( id );

		case 1: ShowGlovesMenu ( id );

		case 2: ShowSpraysMenu ( id );

		case 3: ShowTracksMenu ( id );
	}

	return DestroyMenu ( Menu );
}


ShowFactionsTeamMenu ( id )
{
	new Temp [96]; 

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_FACTIONS_MENU" );

	new Menu = menu_create ( Temp, "FactionsTeamMenuHandler", 0 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_FACTIONS_T" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_FACTIONS_CT" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;
}

public FactionsTeamMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );

		return DestroyMenu ( Menu );
	}

	switch ( Item )
	{
		case 0: ShowFactionsMenu ( id, 1 );

		case 1: ShowFactionsMenu ( id, 2 );
	}

	return DestroyMenu ( Menu );
}


ShowFactionsMenu ( id, Team )
{
	new Temp [96]; 

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_FACTIONS_MENU" );

	new Menu = menu_create ( Temp, "FactionsMenuHandler", 0 );

	new xItem [32], bool: Apply = false, fTemp [32];

	switch ( Team )
	{
		case 1:
		{
			for ( new i = 1; i < FactionsNum; i ++ )
			{
				if ( i == iUserSelectedFaction [id] [0] )
				{
					Apply = true;
				}
				else
				{
					Apply = false;
				}

				if ( FactionKills [i] == 0 )
				{
					formatex ( fTemp, charsmax ( fTemp ), " \r[VIP]" );
				}
				else
				{
					formatex ( fTemp, charsmax ( fTemp ), " \r[%d/%d]", iUserKills [id], FactionKills [i] );
				}

				num_to_str ( i, xItem, charsmax ( xItem ) );

				formatex ( Temp, charsmax ( Temp ), "%s%s%s", Apply ? "\d" : "\w", TFactionName [i], iUserKills [id] >= FactionKills [i] && FactionKills [i] > 0 ? " \r[Owned]" : fTemp );

				menu_additem ( Menu, Temp, xItem);
			}
		}
		case 2:
		{
			for ( new i = 1; i < FactionsNum; i ++ )
			{
				if ( i == iUserSelectedFaction [id] [1] )
				{
					Apply = true;
				}
				else
				{
					Apply = false;
				}

				if ( FactionKills [i] == 0 )
				{
					formatex ( fTemp, charsmax ( fTemp ), " \r[VIP]" );
				}
				else
				{
					formatex ( fTemp, charsmax ( fTemp ), " \r[%d/%d]", iUserKills [id], FactionKills [i] );
				}

				new fID = i + 50;

				formatex ( xItem, charsmax ( xItem ), "%d", fID );

				formatex ( Temp, charsmax ( Temp ), "%s%s%s", Apply ? "\d" : "\w", CTFactionName [i], iUserKills [id] >= FactionKills [i] && FactionKills [i] > 0 ? " \r[Owned]" : fTemp );

				menu_additem ( Menu, Temp, xItem );
			}
		}
	}

	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public FactionsMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );

		return DestroyMenu ( Menu );
	}

	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );

	switch ( Index )
	{
		case -10:
		{
			ShowMainMenu ( id );

			return DestroyMenu ( Menu );
		}
		default:
		{
			if ( Index >= 50 )
			{			
				new bool: SameMdl = false;

				if ( FactionKills [Index-50] == 0 && !is_user_vip ( id ) )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_FACTIONS_VIP" );

					ShowFactionsMenu ( id, 2 );

					return DestroyMenu ( Menu );
				}

				if ( FactionKills [Index-50] > iUserKills [id] )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_KILLS", FactionKills [Index-50] - iUserKills [id] );

					ShowFactionsMenu ( id, 2 );

					return DestroyMenu ( Menu );		
				}
			
				if ( Index -50 == iUserSelectedFaction [id] [1] )
				{
					SameMdl = true;
				}
			
				if ( !SameMdl )
				{
					iUserSelectedFaction [id] [1] = Index - 50;
				}
				else
				{
					iUserSelectedFaction [id] [1] = 0;
				}

				ShowFactionsMenu ( id, 2 );
			}
			else
			{
				new bool: SameMdl = false;

				if ( FactionKills [Index] == 0 && !is_user_vip ( id ) )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_FACTIONS_VIP" );

					ShowFactionsMenu ( id, 1 );

					return DestroyMenu ( Menu );
				}

				if ( FactionKills [Index] > iUserKills [id] )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_KILLS", FactionKills [Index] - iUserKills [id] );

					ShowFactionsMenu ( id, 1 );

					return DestroyMenu ( Menu );		
				}
			
				if ( Index == iUserSelectedFaction [id] [0] )
				{
					SameMdl = true;
				}
			
				if ( !SameMdl )
				{
					iUserSelectedFaction [id] [0] = Index;
				}
				else
				{
					iUserSelectedFaction [id] [0] = 0;
				}

				ShowFactionsMenu ( id, 1 );
			}

			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_FACTIONS_UPDATE" );
		}
	}

	return DestroyMenu ( Menu );
}

public ShowVipInfo ( id )
{
	show_motd ( id, "addons/amxmodx/configs/csgo/vip.html", "VIP Info" );
}

public ShowSkinsFromID ( id, Num )
{
	new Temp [512]; 

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_SKINS_MENU" );

	new Menu = menu_create ( Temp, "SkinsMenuHandler2", 0 );

	new String [32], bool: HasSkins = false, Apply, sID, ApplyST;

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( SkinID [i] == Num )
		{
			if ( SkinTag [id] [i] != 0  )
			{
				Apply = 0;

				ApplyST = 0;

				for ( sID = 0; sID < 25; sID ++ )
				{
					if ( i + 10000 == iUserSelectedSkin [id] [sID] )
					{
						Apply = 1;

						sID = 25;
					}
					else if ( i + 17000 == iUserSelectedSkin [id] [sID] )
					{
						ApplyST = 1;

						sID = 25;
					}
				}

				if ( SkinTag [id] [i] == 2 )
				{
					new wID = i + 17000;

					formatex ( String, charsmax ( String ), "%d %d", wID, SkinID [i] );

					formatex ( Temp, charsmax ( Temp ), "%s[\r%s\d]\w %s\y [\rStatTrak\y]", ApplyST == 1 ? "\d# " : "\d", SkinTagN [id] [i], SkinName [i] );

					menu_additem ( Menu, Temp, String );

					HasSkins = true;
				}
				else if ( SkinTag [id] [i] == 1 )
				{
					new wID = i + 10000;

					formatex ( String, charsmax ( String ), "%d %d", wID, SkinID [i] );

					formatex ( Temp, charsmax ( Temp ), "%s[\r%s\d]\w %s\y [\r%s\y]", Apply == 1 ? "\d# " : "\d", SkinTagN [id] [i], SkinName [i], GetSkinClass ( i ) );

					menu_additem ( Menu, Temp, String );

					HasSkins = true;
				}
			}

			if ( iUserSkins [id] [i] != 0 )
			{
				Apply = 0;

				ApplyST = 0;

				for ( sID = 0; sID < 25; sID ++ )
				{
					if ( i == iUserSelectedSkin [id] [sID] )
					{
						Apply = 1;

						sID = 25;
					}
					else if ( i + 7000 == iUserSelectedSkin [id] [sID] )
					{
						ApplyST = 1;

						sID = 25;
					}
				}
				
				if ( iUserSTs [id] [i] )
				{
					new wID = i + 7000;

					formatex ( String, charsmax ( String ), "%d %d", wID, SkinID [i] );

					formatex ( Temp, charsmax ( Temp ), "%s%s\y [\rStatTrak\y]\d (%d)", ApplyST == 1 ? "\d# " : "\y", SkinName [i], iUserSTs [id] [i] );

					menu_additem ( Menu, Temp, String );

					HasSkins = true;
				}
				
				if ( iUserSkins [id] [i] > iUserSTs [id] [i] )
				{
					formatex ( String, charsmax ( String ), "%d %d", i, SkinID [i] );

					formatex ( Temp, charsmax ( Temp ), "%s%s\y [\r%s\y] \d(%d)", Apply == 1 ? "\d# " : "\w", SkinName [i], GetSkinClass ( i ), iUserSkins [id] [i] - iUserSTs [id] [i] );

					menu_additem ( Menu, Temp, String );

					HasSkins = true;
				}
			}
		}
	}

	if ( !HasSkins )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public SkinsMenuHandler2 ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [6] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );

	switch ( Item )
	{
		case -10:
		{
			return DestroyMenu ( Menu );
		}
		default:
		{
			parse ( Data [0], Data [2], charsmax ( Data [ ] ), Data [3], charsmax ( Data [ ] ) );

			new j = str_to_num ( Data [2] );

			for ( new i = 0; i < 25; i ++ )
			{
				if ( j == iUserSelectedSkin [id] [i] )
				{
					iUserSelectedSkin [id] [i] = 0;

					if ( j >= 17000 )
					{
						client_print_color ( id, id, "%s You removed the^3 %s^1 skin", CHAT_PREFIX, SkinName [j-17000] );

						g_iUserSelectedSkin [id][SkinID[j-17000]] = 0;

						ShowSkinsFromID ( id, SkinID [j-17000] );
					}
					else if ( j >= 10000 )
					{
						client_print_color ( id, id, "%s You removed the^3 %s^1 skin", CHAT_PREFIX, SkinName [j-10000] );

						g_iUserSelectedSkin [id][SkinID[j-10000]] = 0;

						ShowSkinsFromID ( id, SkinID [j-10000] );
					}
					else if ( j >= 7000 )
					{
						client_print_color ( id, id, "%s You removed the^3 %s^1 skin", CHAT_PREFIX, SkinName [j-7000] );

						g_iUserSelectedSkin [id][SkinID[j-7000]] = 0;

						ShowSkinsFromID ( id, SkinID [j-7000] );
					}
					else
					{
						client_print_color ( id, id, "%s You removed the^3 %s^1 skin", CHAT_PREFIX, SkinName [j] );

						g_iUserSelectedSkin [id][SkinID[j]] = 0;

						ShowSkinsFromID ( id, SkinID [j] );
					}

					return DestroyMenu ( Menu );
				}
			}

			new D1 = str_to_num ( Data [3] );

			new D2 = str_to_num ( Data [2] );

			//g_iUserViewBody[id] = D2;

			switch ( D1 )
			{
				case 15: iUserSelectedSkin [id] [0] = D2;

				case 16: iUserSelectedSkin [id] [1] = D2;

				case 17: iUserSelectedSkin [id] [2] = D2;

				case 18: iUserSelectedSkin [id] [3] = D2;

				case 19: iUserSelectedSkin [id] [4] = D2;

				case 21: iUserSelectedSkin [id] [5] = D2;

				case 22: iUserSelectedSkin [id] [6] = D2;

				case 26: iUserSelectedSkin [id] [7] = D2;

				case 28: iUserSelectedSkin [id] [8] = D2;

				case 29: iUserSelectedSkin [id] [9] = D2;

				case 30: iUserSelectedSkin [id] [10] = D2;

				case 3: iUserSelectedSkin [id] [11] = D2;

				case 8: iUserSelectedSkin [id] [12] = D2;

				case 12: iUserSelectedSkin [id] [13] = D2;

				case 5: iUserSelectedSkin [id] [14] = D2;

				case 13: iUserSelectedSkin [id] [15] = D2;

				case 27: iUserSelectedSkin [id] [16] = D2;

				case 24: iUserSelectedSkin [id] [17] = D2;

				case 1: iUserSelectedSkin [id] [18] = D2;

				case 14: iUserSelectedSkin [id] [19] = D2;

				case 20: iUserSelectedSkin [id] [20] = D2;

				case 11: iUserSelectedSkin [id] [21] = D2;

				case 10: iUserSelectedSkin [id] [22] = D2;

				case 23: iUserSelectedSkin [id] [23] = D2;

				case 7: iUserSelectedSkin [id] [24] = D2;
			}

			if ( j >= 17000 )
			{
				ShowSkinsFromID ( id, SkinID [j-17000] );
				D2 -= 17000;
			}
			else if ( j >= 10000 )
			{
				ShowSkinsFromID ( id, SkinID [j-10000] );
				D2 -= 10000;
			}
			else if ( j >= 7000 )
			{
				ShowSkinsFromID ( id, SkinID [j-7000] );
				D2 -= 7000;
			}
			else
			{
				ShowSkinsFromID ( id, SkinID [j] );
			}

			g_iUserSelectedSkin[id][SkinID[D2]] = g_iSkinBody[D2];

			SendWeaponAnim(id, 0);
		}
	}

	return DestroyMenu ( Menu );
}

public ShowSSMenu ( id )
{
	new Temp [96]; 

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_SKINS_MENU" );

	new Menu = menu_create ( Temp, "SSMenuHandler", 0 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_COMMON_SKINS" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_STATTRAK_SKINS" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_NAMETAG_SKINS" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;
}

public SSMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );

		return DestroyMenu ( Menu );
	}

	switch ( Item )
	{
		case 0: ShowSkinsMenu ( id, 1 );

		case 1: ShowSkinsMenu ( id, 2 );

		case 2: ShowSkinsMenu ( id, 3 );
	}

	return DestroyMenu ( Menu );
}

public ShowSkinsMenu ( id, Num )
{
	new Temp [512]; 

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_SKINS_MENU" );

	new Menu = menu_create ( Temp, "SkinsMenuHandler", 0 );

	new String [32], bool: HasSkins = false, bool: HasSTSkins = false, bool: HasTagSkins = false, Apply, sID, ApplyST;

	new const Sort [ ] =
	{
		CSW_M4A1, 
		CSW_AK47, 
		CSW_AWP, 
		CSW_KNIFE, 
		CSW_DEAGLE, 
		CSW_USP, 
		CSW_GLOCK18,
		CSW_FAMAS, 
		CSW_MP5NAVY, 
		CSW_M3, 
		CSW_P90, 
		CSW_SCOUT, 
		CSW_AUG, 
		CSW_UMP45, 
		CSW_XM1014, 
		CSW_SG550, 
		CSW_SG552, 
		CSW_G3SG1,
		CSW_P228, 
		CSW_GALIL, 
		CSW_M249, 
		CSW_FIVESEVEN, 
		CSW_ELITE, 
		CSW_TMP, 
		CSW_MAC10
	}

	switch ( Num )
	{
		case 1:
		{
			for ( new x = 0; x < sizeof ( Sort ); x ++ )
			{
				for ( new i = 1; i < SkinsNum; i ++ )
				{
					if ( iUserSkins [id] [i] != 0 && SkinID [i] == Sort [x]  )
					{
						Apply = 0;

						ApplyST = 0;

						for ( sID = 0; sID < 25; sID ++ )
						{
							if ( i == iUserSelectedSkin [id] [sID] )
							{
								Apply = 1;

								sID = 25;
							}
						}

						if ( iUserSkins [id] [i] > iUserSTs [id] [i] )
						{
							formatex ( String, charsmax ( String ), "%d %d", i, SkinID [i] );

							formatex ( Temp, charsmax ( Temp ), "%s%s\y [\r%s\y] \d(%d)", Apply == 1 ? "\d# " : "\w", SkinName [i], GetSkinClass ( i ), iUserSkins [id] [i] - iUserSTs [id] [i] );

							menu_additem ( Menu, Temp, String );

							HasSkins = true;
						}
					}
				}
			}
		}
		case 2:
		{
			for ( new x = 0; x < sizeof ( Sort ); x ++ )
			{
				for ( new i = 1; i < SkinsNum; i ++ )
				{
					if ( iUserSkins [id] [i] != 0 && SkinID [i] == Sort [x] )
					{
						Apply = 0
							
						ApplyST = 0
							
						for ( sID = 0; sID < 25; sID ++ )
						{
							if ( i + 7000 == iUserSelectedSkin [id] [sID] )
							{
								ApplyST = 1;

								sID = 25;
							}
						}

						if ( iUserSTs [id] [i] )
						{
							new wID = i + 7000;

							formatex ( String, charsmax ( String ), "%d %d", wID, SkinID [i] );

							formatex ( Temp, charsmax ( Temp ), "%s%s\y [\rStatTrak\y]\d (%d)", ApplyST == 1 ? "\d# " : "\y", SkinName [i], iUserSTs [id] [i] );

							menu_additem ( Menu, Temp, String );

							HasSTSkins = true;
						}
					}
				}
			}
		}
		case 3:
		{
			for ( new x = 0; x < sizeof ( Sort ); x ++ )
			{
				for ( new i = 1; i < SkinsNum; i ++ )
				{
					if ( SkinTag [id] [i] != 0 && SkinID [i] == Sort [x] )
					{
						Apply = 0;

						ApplyST = 0;

						for ( sID = 0; sID < 25; sID ++ )
						{
							if ( i + 10000 == iUserSelectedSkin [id] [sID] )
							{
								Apply = 1;

								sID = 25;
							}
							else if ( i + 17000 == iUserSelectedSkin [id] [sID] )
							{
								ApplyST = 1;

								sID = 25;
							}
						}

						if ( SkinTag [id] [i] == 2 )
						{
							new wID = i + 17000;

							formatex ( String, charsmax ( String ), "%d %d", wID, SkinID [i] );

							formatex ( Temp, charsmax ( Temp ), "%s[\r%s\d]\w %s\y [\rStatTrak\y]", ApplyST == 1 ? "\d# " : "\d", SkinTagN [id] [i], SkinName [i] );

							menu_additem ( Menu, Temp, String );

							HasTagSkins = true;
						}
						else if ( SkinTag [id] [i] == 1 )
						{
							new wID = i + 10000;

							formatex ( String, charsmax ( String ), "%d %d", wID, SkinID [i] );

							formatex ( Temp, charsmax ( Temp ), "%s[\r%s\d]\w %s\y [\r%s\y]", Apply == 1 ? "\d# " : "\d", SkinTagN [id] [i], SkinName [i], GetSkinClass ( i ) );

							menu_additem ( Menu, Temp, String );

							HasTagSkins = true;
						}
					}
				}
			}
		}
	}

	switch ( Num )
	{
		case 1:
		{
			if ( !HasSkins  )
			{
				formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
				menu_additem ( Menu, Temp, "-10", 0, -1 );
			}
		}
		case 2:
		{
			if ( !HasSTSkins  )
			{
				formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
				menu_additem ( Menu, Temp, "-10", 0, -1 );
			}
		}
		case 3:
		{
			if ( !HasTagSkins  )
			{
				formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
				menu_additem ( Menu, Temp, "-10", 0, -1 );
			}
		}
	}

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;
}

public SkinsMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowSSMenu ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [6] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );

	switch ( Item )
	{
		case -10:
		{
			ShowSSMenu ( id );

			return DestroyMenu ( Menu );
		}
		default:
		{
			parse ( Data [0], Data [2], charsmax ( Data [ ] ), Data [3], charsmax ( Data [ ] ) );

			new j = str_to_num ( Data [2] );

			for ( new i = 0; i < 25; i ++ )
			{
				if ( j == iUserSelectedSkin [id] [i] )
				{
					iUserSelectedSkin [id] [i] = 0;

					if ( j >= 17000 )
					{
						client_print_color ( id, id, "%s You removed the^3 %s^1 skin", CHAT_PREFIX, SkinName [j-17000] );

						g_iUserSelectedSkin [id][SkinID[j - 17000]] = 0;

						ShowSkinsMenu ( id, 3 );
					}
					else if ( j >= 10000 )
					{
						client_print_color ( id, id, "%s You removed the^3 %s^1 skin", CHAT_PREFIX, SkinName [j-10000] );

						g_iUserSelectedSkin [id][SkinID[j - 10000]] = 0;

						ShowSkinsMenu ( id, 3 );
					}
					else if ( j >= 7000 )
					{
						client_print_color ( id, id, "%s You removed the^3 %s^1 skin", CHAT_PREFIX, SkinName [j-7000] );

						g_iUserSelectedSkin [id][SkinID[j - 7000]] = 0;

						ShowSkinsMenu ( id, 2 );
					}
					else
					{
						client_print_color ( id, id, "%s You removed the^3 %s^1 skin", CHAT_PREFIX, SkinName [j] );

						g_iUserSelectedSkin [id][SkinID[j]] = 0;

						ShowSkinsMenu ( id, 1 );
					}

					return DestroyMenu ( Menu );
				}
			}

			new D1 = str_to_num ( Data [3] );

			new D2 = str_to_num ( Data [2] );

			switch ( D1 )
			{
				case 15: iUserSelectedSkin [id] [0] = D2;

				case 16: iUserSelectedSkin [id] [1] = D2;

				case 17: iUserSelectedSkin [id] [2] = D2;

				case 18: iUserSelectedSkin [id] [3] = D2;

				case 19: iUserSelectedSkin [id] [4] = D2;

				case 21: iUserSelectedSkin [id] [5] = D2;

				case 22: iUserSelectedSkin [id] [6] = D2;

				case 26: iUserSelectedSkin [id] [7] = D2;

				case 28: iUserSelectedSkin [id] [8] = D2;

				case 29: iUserSelectedSkin [id] [9] = D2;

				case 30: iUserSelectedSkin [id] [10] = D2;

				case 3: iUserSelectedSkin [id] [11] = D2;

				case 8: iUserSelectedSkin [id] [12] = D2;

				case 12: iUserSelectedSkin [id] [13] = D2;

				case 5: iUserSelectedSkin [id] [14] = D2;

				case 13: iUserSelectedSkin [id] [15] = D2;

				case 27: iUserSelectedSkin [id] [16] = D2;

				case 24: iUserSelectedSkin [id] [17] = D2;

				case 1: iUserSelectedSkin [id] [18] = D2;

				case 14: iUserSelectedSkin [id] [19] = D2;

				case 20: iUserSelectedSkin [id] [20] = D2;

				case 11: iUserSelectedSkin [id] [21] = D2;

				case 10: iUserSelectedSkin [id] [22] = D2;

				case 23: iUserSelectedSkin [id] [23] = D2;

				case 7: iUserSelectedSkin [id] [24] = D2;
			}
			
			if( j >= 17000)
			{
				ShowSkinsMenu ( id, 3 );
				D2 -= 17000;
			}
			else if ( j >= 10000 )
			{
				ShowSkinsMenu ( id, 3 );
				D2 -= 10000;
			}
			else if ( j >= 7000 )
			{
				ShowSkinsMenu ( id, 2 );
				D2 -= 7000;
			}
			else
			{
				ShowSkinsMenu ( id, 1 );
			}

			g_iUserSelectedSkin[id][SkinID[D2]] = g_iSkinBody[D2];
			//CurrentWeapon(id);

			SendWeaponAnim(id, 0);
		}
	}

	return DestroyMenu ( Menu );
}

public ShowPreviewMenu ( id )
{
	new Temp [96]; 

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_SKINS_MENU" );
	
	new Menu = menu_create ( Temp, "PreviewMenuHandler", 0 );
   
	new bool: HasSkins = false, xItem [10];
   
	for ( new i = 1; i < SkinsNum; i ++ )
	{
		formatex ( Temp, charsmax ( Temp ), "%s", SkinName [i] );

		num_to_str ( i, xItem, charsmax ( xItem ) );

		menu_additem ( Menu, Temp, xItem, 0, -1 );

		HasSkins = true;
	}

	if ( !HasSkins )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );

		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}
	
public PreviewMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowSSMenu ( id );
		
		return DestroyMenu ( Menu );
	}

	if ( !is_user_alive ( id ) )
	{
		ShowPreviewMenu ( id );

		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TEMPORALY_UNAVAILABLE" );

		return DestroyMenu ( Menu );
	}
   
   	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );
	
	if ( Index == -10 )
	{
		ShowSSMenu ( id );
	
		return DestroyMenu ( Menu );
	}

	if ( get_systime (  ) < iLastPreview [id] + sPreviewDelay )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_DONT_SPAM", sPreviewDelay );
					
		ShowPreviewMenu ( id );
					
		return PLUGIN_HANDLED;
	}

	iLastPreview [id] = get_systime (  );

	set_pev ( id, pev_viewmodel2, SkinMdl [Index] );

	new temp[2]
	temp [0] = g_iUserSelectedSkin[id][SkinID[Index]];
	temp [1] = SkinID[Index];

	g_iUserSelectedSkin[id][SkinID[Index]] = g_iSkinBody[Index];

	SendWeaponAnim(id, 0, SkinID[Index]);

	new Temp [32];

	if ( SkinChest [Index] == 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "Contract" );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "%s", ChestName [SkinChest [Index]] );
	}

	new StrMin [16], StrMax [16];

	AddCommas ( SkinMinPrice [Index], StrMin, charsmax ( StrMin ) );

	AddCommas ( SkinMaxPrice [Index], StrMax, charsmax ( StrMax ) );

	client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_PREVIEW_INFO", SkinName [Index], Temp, 100 - SkinChance [Index], StrMin, StrMax );

	set_task ( 3.0, "ResetPreviewSkin", id, temp, sizeof(temp) );
	
	return DestroyMenu ( Menu );
}

public ResetPreviewSkin (Param[], id )
{
    if ( is_user_alive ( id ) )
    {
        CurrentWeapon ( id );

        g_iUserSelectedSkin[id][Param[1]] = Param[0];

        client_cmd ( id, "lastinv;wait;wait;wait;wait;wait;wait;lastinv" );
    }
}

ShowSpraysMenu ( id )
{
	new Temp [64]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_GRF_MENU" );
	
	new Menu = menu_create ( Temp, "SpraysMenuHandler", 0 );
	
	new bool: Apply = false, xItem [10], bool: HasSprays = false;

	for ( new i = 0; i < SpraysNum; i ++ )
	{
		if ( SprayRemaining [id] [i] > 0 )
		{
			if ( i == iUserSelectedSpray [id] )
			{
				Apply = true;
			}
			else
			{
				Apply = false;
			}

			formatex ( Temp, charsmax ( Temp ), "%s%s\d (\r%d\y %L\d)", Apply ? "\d" : "\w", SprayName [i], SprayRemaining [id] [i], id, "CSGO_REMAINING" );

			num_to_str ( i, xItem, charsmax ( xItem ) );
				
			menu_additem ( Menu, Temp, xItem, 0, -1 );

			HasSprays = true;
		}
	}

	if ( !HasSprays )
	{
		formatex ( Temp, charsmax ( Temp ), "\dNo sprays" );

		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public SpraysMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );
		
		return DestroyMenu ( Menu );
	}
   
   	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );
	
	switch ( Index )
	{
		case -10:
		{
			ShowMainMenu ( id );

			return DestroyMenu ( Menu );
		}
		default:
		{	
			new bool: SameSpray = false;
			
			if ( Index == iUserSelectedSpray [id] )
			{
				SameSpray = true;
			}
			
			if ( !SameSpray )
			{
				iUserSelectedSpray [id] = Index;
			}
			else
			{
				iUserSelectedSpray [id] = -1;
			}
			
			ShowSpraysMenu ( id );
		}
	}
	
	return DestroyMenu ( Menu );
}	

ShowGlovesMenu ( id )
{
	new Temp [64]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_GLOVES_MENU" );
	
	new Menu = menu_create ( Temp, "GlovesMenuHandler", 0 );
	
	new bool: Apply = false, xItem [10], bool: HasGloves = false;

	for ( new i = 1; i < GlovesNum; i ++ )
	{
		if ( iUserGloves [id] [i] > 0 )
		{
			if ( i == g_iUserSelectedGlove [id] )
			{
				Apply = true;
			}
			else
			{
				Apply = false;
			}

			formatex ( Temp, charsmax ( Temp ), "%s%s\d [\r%d\d]", Apply ? "\d" : "\w", GloveName [i], iUserGloves [id] [i] );

			num_to_str ( i, xItem, charsmax ( xItem ) );
				
			menu_additem ( Menu, Temp, xItem, 0, -1 );

			HasGloves = true;
		}
	}

	if ( !HasGloves )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_ZERO_GLOVES" );

		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public GlovesMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );
		
		return DestroyMenu ( Menu );
	}
   
   	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );
	
	switch ( Index )
	{
		case -10:
		{
			ShowMainMenu ( id );

			return DestroyMenu ( Menu );
		}	
		default:
		{	
			new bool: SameGlove = false;
			
			if ( Index == g_iUserSelectedGlove [id] )
			{
				SameGlove = true;
			}
			
			if ( !SameGlove )
			{
				g_iUserSelectedGlove [id] = Index;
			}
			else
			{
				g_iUserSelectedGlove [id] = 0;
			}
			
			ShowGlovesMenu ( id );
		}
	}
	
	return DestroyMenu ( Menu );
}

public PutGraffiti ( id ) 
{
	if ( !iLogged [id] )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GRF_NOT_LOGGED" );
		
		return 2;
	}

	if ( !is_user_alive ( id ) )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GRF_NOT_ALIVE" );
		
		return 2;
	}

	if ( iUserSelectedSpray [id] < 0 )
	{
		return 2;
	}

	if ( SprayCooldown [id] > 0 )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GRF_COOLDOWN", SprayCooldown [id] );

		return 2;
	}

	new ClassName;

	ClassName = create_entity ( "info_target" );

	new Float: fAimOrigin [3]

	new Float: fPlayerOrigin [3], Float:fAimVector [3], Float: fNormalVector [3],Float: fTextVector [3];

	pev ( id, 126, fAimVector );

	pev ( id, 118, fPlayerOrigin );

	new iTr = create_tr2 (  );

	new Float: Start [3], Float: ViewOfs [3];

	pev ( id, pev_origin, Start );

	pev ( id, pev_view_ofs, ViewOfs );

	xs_vec_add ( Start, ViewOfs, Start );

	pev ( id, pev_v_angle, fAimVector );

	engfunc ( EngFunc_MakeVectors, fAimVector );

	global_get ( glb_v_forward, fAimVector );

	xs_vec_mul_scalar ( fAimVector, 9999.0, fAimVector );

	xs_vec_add ( Start, fAimVector, fAimVector );

	engfunc ( EngFunc_TraceLine, fPlayerOrigin, fAimVector, 1, 1 , iTr );

	get_tr2 ( iTr, 5, fAimOrigin );

	if ( get_distance_f ( fPlayerOrigin, fAimOrigin ) <= 100.00 )
	{
		if ( SprayCount == 10 )
		{
			remove_entity ( MaxGrf [0] );

			for ( new i = 1; i < SprayCount; i ++ )
			{
				MaxGrf [i-1] = MaxGrf [i];
			}

			SprayCount --;
		}

		ExecuteForward ( iForwards [2], iForwardResult, id );

		MaxGrf [SprayCount] = ClassName;

		get_tr2 ( iTr, 7, fNormalVector );

		free_tr2 ( iTr );

		vector_to_angle ( fNormalVector, fTextVector );

		entity_set_vector ( MaxGrf [SprayCount], 6, fTextVector );

		entity_set_model ( MaxGrf [SprayCount], sGrfModel );
		
		entity_set_origin ( MaxGrf [SprayCount], fAimOrigin );
		
		entity_set_int ( MaxGrf [SprayCount], 14, 0 );
		
		entity_set_edict ( MaxGrf [SprayCount], 4, id );
		
		entity_set_string ( MaxGrf [SprayCount], 0, "GraffitiEntity" );
		
		entity_set_int ( MaxGrf [SprayCount], 15, 0);
		
		entity_set_int ( MaxGrf [SprayCount], 16, iUserSelectedSpray [id] );

		SprayRemaining [id] [iUserSelectedSpray [id] ]--;

		if ( SprayRemaining [id] [iUserSelectedSpray [id] ] <= 0 )
		{
			SprayRemaining [id] [iUserSelectedSpray [id] ] = 0;

			iUserSelectedSpray [id] = -1;
		}
		
		SprayCount ++;

		SprayCooldown [id] = sSprayCooldown;

		emit_sound ( id, CHAN_AUTO, SPRAY_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

		set_task ( 1.0, "TaskRemoveGraffiti", id + 2002991, _, _, "b" );

		SaveData ( id );
	}
	else
		remove_entity ( ClassName );

	return 2;
}

public TaskRemoveGraffiti ( Task )
{
	new id = Task - 2002991;

	if ( !is_user_alive ( id ) )

		remove_task ( id + 2002991 );

	if ( sSprayCooldown < SprayCooldown [id] )

		SprayCooldown [id] = sSprayCooldown;

	SprayCooldown [id] --;

	if ( SprayCooldown [id] <= 0 )
	{
		remove_task ( id + 2002991 );
	}
}

public ShowTracksMenu ( id )
{
	new Temp [96]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_TRACKS_MENU" );
	
	new Menu = menu_create ( Temp, "TracksMenuHandler", 0 );
   
	new bool: Apply = false, bool: HasTracks = false, xItem [10];
   
	for ( new i = 0; i < TracksNum; i ++ )
	{
		if ( i == iUserSelectedSound [id] )
		{
			Apply = true;
		}
		else
		{
			Apply = false;
		}
		
		if ( TrackRemaining [id] [i] > 0 )
		{
			formatex ( Temp, charsmax ( Temp ), "%s%s\d (\r%d\y %L\d)", Apply ? "\d" : "\w", TrackName [i], TrackRemaining [id] [i], id, "CSGO_REMAINING" );
		}
		else
		{
			new StrPoints [16];

			AddCommas ( TrackCost [i], StrPoints, charsmax ( StrPoints ) );

			formatex ( Temp, charsmax ( Temp ), "%s%s\d [\yEuro:\r %s\d]", Apply ? "\d" : "\w", TrackName [i], StrPoints );
		}

		num_to_str ( i, xItem, charsmax ( xItem ) );

		menu_additem ( Menu, Temp, xItem, 0, -1 );

		HasTracks = true;
	}

	if ( !HasTracks )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_TRACKS" );

		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}

	formatex ( Temp, charsmax ( Temp ), "\r------------------------------" );

	menu_addtext ( Menu, Temp, 0 );

	formatex ( Temp, charsmax ( Temp ), "\dMVP Status:\r %s", MVPAllowed [id] ? "ON" : "OFF" );

	menu_additem ( Menu, Temp, "-30", 0, -1 );
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}
	
public TracksMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );
		
		return DestroyMenu ( Menu );
	}
   
   	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );
	
	switch ( Index )
	{
		case -10:
		{
			ShowMainMenu ( id );
	
			return DestroyMenu ( Menu );
		}
		case -30:
		{
			if ( MVPAllowed [id] )
			{
				MVPAllowed [id] = false;
			}
			else
			{
				MVPAllowed [id] = true;	
			}

			ShowTracksMenu ( id );

			return DestroyMenu ( Menu );
		}
		default:
		{
			if ( TrackRemaining [id] [Index] < 1 )
			{
				if ( TrackCost [Index] > iUserPoints [id] )
				{
					new rPoints = TrackCost [Index] - iUserPoints [id];

					new StrPoints [16];

					AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );	
				
					ShowTracksMenu ( id );
					
					return DestroyMenu ( Menu );
				}
				
				iUserPoints [id] -= TrackCost [Index];
				
				TrackRemaining [id] [Index] = TrackLeft [Index];
			
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BUY_TRACK", TrackName [Index] );	
				
				SaveData ( id );
			}
				
			new bool: SameTrack = false;
			
			if ( Index == iUserSelectedSound [id] )
			{
				SameTrack = true;
			}
			
			if ( !SameTrack )
			{
				iUserSelectedSound [id] = Index;
	
				//client_print_color ( id, id, "%s %L", "[CSGO UltimateX]", id, "CSGO_SELECT_SOUND", Buffer );
			}
			else
			{
				iUserSelectedSound [id] = -1;
	
				//client_print_color ( id, id, "^4%s^1 %L", "[CSGO UltimateX]", id, "CSGO_DESELECT_SOUND" );
			}
			
			ShowTracksMenu ( id );
		}
	}
	
	return DestroyMenu ( Menu );
}


ShowChestsMenu ( id )
{
	new Temp [96]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_OCC_MENU" );
	
	new Menu = menu_create ( Temp, "ChestsMenuHandler", 0 );
   
	formatex ( Temp, charsmax ( Temp ), "\wContract\y [\r%d\w/\r%d\y]", iUserDusts [id], sContractCost );
	
	menu_additem ( Menu, Temp, "0", 0, -1 );

	//new bool: HasChests = false;

	for ( new i = 1; i < ChestsNum; i ++ )
	{
		new CNum = iUserChests [id] [i];

		new KNum = iUserKeys [id] [i];

		new xItem [16];

		num_to_str ( i, xItem, charsmax ( xItem ) );

		formatex ( Temp, charsmax ( Temp ), "\w%s\y [\dC: \r%d\w|\dK:\r %d\y]", ChestName [i], CNum, KNum );

		menu_additem ( Menu, Temp, xItem, 0, -1 );
	}

	formatex ( Temp, charsmax ( Temp ), "\w%L\y [\r%d\y]", id, "CSGO_CAPSULE_CHEST", iUserCaps [id] );
	
	menu_additem ( Menu, Temp, "11", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L\y [\r%d\y]", id, "CSGO_GLOVE_BOX", iUserGloveBoxes [id] );
	
	menu_additem ( Menu, Temp, "12", 0, -1 );

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;
}

public ChestsMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );

		return DestroyMenu ( Menu );
	}

	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );

	switch ( Index )
	{
		case 0:
		{
			if ( iUserDusts [id] < sContractCost )
			{
				client_print_color ( id, id, "%s^1 %L", CHAT_PREFIX, id, "CSGO_CRAFT_NOT_ENOUGH", sContractCost );

				ShowChestsMenu ( id );

				return DestroyMenu ( Menu );
			}

			if ( get_systime (  ) < iLastOpenCraft [id] + sOpenChestsDelay )
			{
				client_print_color ( id, id, "%s^1 %L", CHAT_PREFIX, id, "CSGO_DONT_SPAM", sOpenChestsDelay );
					
				ShowChestsMenu ( id );
					
				return DestroyMenu ( Menu );
			}

			MakeContract ( id );
		}
		case 11:
		{
			if ( iUserCaps [id] < 1 )
			{
				client_print_color ( id, id, "%s^1 %L", CHAT_PREFIX, id, "CSGO_OPEN_BOX_NOT_ENOUGH" );

				ShowChestsMenu ( id );

				return DestroyMenu ( Menu );
			}

			if ( get_systime (  ) < iLastOpenCraft [id] + sOpenChestsDelay )
			{
				client_print_color ( id, id, "%s^1 %L", CHAT_PREFIX, id, "CSGO_DONT_SPAM", sOpenChestsDelay );
					
				ShowChestsMenu ( id );
					
				return DestroyMenu ( Menu );
			}

			CapsOpen ( id );
		}
		case 12:
		{
			if ( iUserGloveBoxes [id] < 1 )
			{
				client_print_color ( id, id, "%s^1 %L", CHAT_PREFIX, id, "CSGO_OPEN_BOX_NOT_ENOUGH" );

				ShowChestsMenu ( id );

				return DestroyMenu ( Menu );
			}

			if ( get_systime (  ) < iLastOpenCraft [id] + sOpenChestsDelay )
			{
				client_print_color ( id, id, "%s^1 %L", CHAT_PREFIX, id, "CSGO_DONT_SPAM", sOpenChestsDelay );
					
				ShowChestsMenu ( id );
					
				return DestroyMenu ( Menu );
			}

			GloveBoxOpen ( id );
		}
		default:
		{
			if ( iUserChests [id] [Index] < 1 || iUserKeys [id] [Index] < 1 )
			{
				client_print_color ( id, id, "%s^1 %L", CHAT_PREFIX, id, "CSGO_OPEN_NOT_ENOUGH" );

				ShowChestsMenu ( id );

				return DestroyMenu ( Menu );
			}

			if ( get_systime (  ) < iLastOpenCraft [id] + sOpenChestsDelay )
			{
				client_print_color ( id, id, "%s^1 %L", CHAT_PREFIX, id, "CSGO_DONT_SPAM", sOpenChestsDelay );
					
				ShowChestsMenu ( id );
					
				return DestroyMenu ( Menu );
			}

			ChestOpen ( id, Index );
		}
	}

	ShowChestsMenu ( id );	

	return DestroyMenu ( Menu );
}

public MakeContract ( Index )
{
	new j, cItem [SKINS_LIMIT + 1];

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		j ++;

		cItem [j] = i;
	}

	if ( j == 0 )
	{
		client_print_color ( Index, Index, "%s^1 %L", CHAT_PREFIX, Index, "CSGO_NO_SKINS_CHEST" );

		ShowChestsMenu ( Index );

		return;
	}

	new rSkin = 0, rChance = 0, bool: IsSTs = false, bool: Success = false, Timer = 0, Temp [32];

	do
	{
		rSkin = random_num ( 1, j );

		rChance = random_num ( 1, 100 );

		if ( rChance >= SkinChance [cItem [rSkin]] )
		{
			Success = true;
		}
	}
	while ( Timer < 5 && !Success )

	if ( Success )
	{
		iUserDusts [Index] -= sContractCost;

		new STs = random_num ( 1, 50 );

		if ( sDropStatTrakChance >= STs )
		{
			IsSTs = true;

			iUserSkins [Index] [cItem [rSkin]] ++;

			iUserSTs [Index] [cItem [rSkin]] ++;
		}
		else
		{
			iUserSkins [Index] [cItem [rSkin]] ++;
		}

		if ( 100 - SkinChance [cItem [rSkin]] > 34 )
		{
			formatex ( Temp, charsmax ( Temp ), "Common" );

			PlaySound ( Index, COMMON_CLASS );
		}
		else if ( 100 - SkinChance [cItem [rSkin]] > 14 )
		{
			formatex ( Temp, charsmax ( Temp ), "Rare" );

			PlaySound ( Index, RARE_CLASS );
		}
		else if ( 100 - SkinChance [cItem [rSkin]] > 1 )
		{
			formatex ( Temp, charsmax ( Temp ), "Mythical" );

			PlaySound ( Index, MYTHICAL_CLASS );
		}
		else if ( 100 - SkinChance [cItem [rSkin]] == 1 )
		{
			formatex ( Temp, charsmax ( Temp ), "Legendary" );

			PlaySound ( Index, LEGENDARY_CLASS );
		}

		client_print_color ( Index, Index, "%s^4 %L^3", CHAT_PREFIX, Index, "CSGO_DROP_SUCCESS_YOU", Name [Index], SkinName [cItem [rSkin]], IsSTs ? "StatTrak" : Temp, 100 - SkinChance [cItem [rSkin]] );

		iLastOpenCraft [Index] = get_systime (  );

		SaveData ( Index );
	}
}

public ChestOpen ( Index, Key )
{
	new j, cItem [SKINS_LIMIT + 1];

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( SkinChest [i] == Key )
		{
			j ++;

			cItem [j] = i;
		}
	}

	if ( j == 0 )
	{
		client_print_color ( Index, Index, "%s^1 %L", CHAT_PREFIX, Index, "CSGO_NO_SKINS_CHEST" );

		ShowChestsMenu ( Index );

		return;
	}

	new rSkin = 0, rChance = 0, bool: IsSTs = false, bool: Success = false, Timer = 0, Temp [32];

	do
	{
		rSkin = random_num ( 1, j );

		rChance = random_num ( 1, 100 );

		if ( rChance >= SkinChance [cItem [rSkin]] )
		{
			Success = true;
		}
	}
	while ( Timer < 5 && !Success )

	if ( Success )
	{
		iUserChests [Index] [Key] --;

		iUserKeys [Index] [Key] --;

		new STs = random_num ( 1, 50 );

		if ( sDropStatTrakChance >= STs )
		{
			IsSTs = true;

			iUserSkins [Index] [cItem [rSkin]] ++;

			iUserSTs [Index] [cItem [rSkin]] ++;
		}
		else
		{
			iUserSkins [Index] [cItem [rSkin]] ++;
		}

		if ( 100 - SkinChance [cItem [rSkin]] > 34 )
		{
			formatex ( Temp, charsmax ( Temp ), "Common" );

			PlaySound ( Index, COMMON_CLASS );
		}
		else if ( 100 - SkinChance [cItem [rSkin]] > 14 )
		{
			formatex ( Temp, charsmax ( Temp ), "Rare" );

			PlaySound ( Index, RARE_CLASS );
		}
		else if ( 100 - SkinChance [cItem [rSkin]] > 1 )
		{
			formatex ( Temp, charsmax ( Temp ), "Mythical" );

			PlaySound ( Index, MYTHICAL_CLASS );
		}
		else if ( 100 - SkinChance [cItem [rSkin]] == 1 )
		{
			formatex ( Temp, charsmax ( Temp ), "Legendary" );

			PlaySound ( Index, LEGENDARY_CLASS );
		}

		client_print_color ( Index, Index, "%s^4 %L^3", CHAT_PREFIX, Index, "CSGO_DROP_SUCCESS_YOU", Name [Index], SkinName [cItem [rSkin]], IsSTs ? "StatTrak" : Temp, 100 - SkinChance [cItem [rSkin]] );

		iLastOpenCraft [Index] = get_systime (  );

		SaveData ( Index );
	}
}

public CapsOpen ( Index )
{
	iUserCaps [Index] --;

	ExecuteForward ( iForwards [1], iForwardResult, Index );

	new Num = random_num ( 0, SpraysNum -1 );

	SprayRemaining [Index] [Num] += SprayLeft [Num];

	client_print_color ( Index, Index, "%s^4 %L", CHAT_PREFIX, Index, "CSGO_DROP_SPRAY_SUCCESS", Name [Index], SprayName [Num] );

	iLastOpenCraft [Index] = get_systime (  );

	SaveData ( Index );
}

public GloveBoxOpen ( Index )
{
	new j, cItem [11];

	for ( new i = 1; i < GlovesNum; i ++ )
	{
		j ++;

		cItem [j] = i;
	}

	if ( j == 0 )
	{
		ShowChestsMenu ( Index );

		return;
	}

	new rGlove = 0, rChance = 0, bool: Success = false, Timer = 0;

	do
	{
		rGlove = random_num ( 1, j );

		rChance = random_num ( 1, 100 );

		if ( rChance >= GloveChance [cItem [rGlove]] )
		{
			Success = true;
		}
	}
	while ( Timer < 5 && !Success )

	if ( Success )
	{
		iUserGloveBoxes [Index] --;

		iUserGloves [Index] [cItem [rGlove]] ++;

		client_print_color ( Index, Index, "%s^4 %L", CHAT_PREFIX, Index, "CSGO_DROP_GLOVE_SUCCESS", Name [Index], GloveName [cItem [rGlove]], 100 - GloveChance [cItem [rGlove]] );

		iLastOpenCraft [Index] = get_systime (  );
	
		SaveData ( Index );
	}
}

ShowMarketMenu ( id )
{
	new Temp [512]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L\d", id, "CSGO_MARKET_MENU" );
	
	new Menu = menu_create ( Temp, "MarketMenuHandler", 0 );
	
	new xItem [512], StrPoints [16];
	
	if ( iUserSellItem [id] < 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r N/A", id, "CSGO_MR_SELECT_ITEM" );
	}
	else
	{
		AddCommas ( iUserItemPrice [id], StrPoints, charsmax ( StrPoints ) );

		GetItemName ( id, iUserSellItem [id], xItem, charsmax ( xItem ) );
		
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r %s\d |\r %s", id, "CSGO_MR_SELECT_ITEM", xItem, StrPoints );
	}
	
	menu_additem ( Menu, Temp, "33", 0, -1 );
	
	if ( iUserSell [id] )
	{
		formatex ( Temp, charsmax ( Temp ), "\y%L^n\r------------------------------^n", id, "CSGO_MR_CANCEL_SELL" );
		
		menu_additem ( Menu, Temp, "35", 0, -1 );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "\y%L^n\r------------------------------^n", id, "CSGO_MR_START_SELL" );
		
		menu_additem ( Menu, Temp, "34", 0, -1 );
	}

	/*formatex ( Temp, charsmax ( Temp ), "\r------------------------------" );

	menu_addtext ( Menu, Temp );*/
	
	new Players [32], Num = 0, User = 0;

	get_players ( Players, Num, "ch" );
	
	if ( Num )
	{
		new Items = 0, String [10], StrPoints [16];
		
		for ( new i = 0; i < Num; i ++ )
		{
			User = Players [i];
			
			if ( iLogged [User] && User != id )
			{	
				if ( iUserSell [User] )
				{
					new Index = iUserSellItem [User];
						
					GetItemName ( User, Index, xItem, charsmax ( xItem ) );

					AddCommas ( iUserItemPrice [User], StrPoints, charsmax ( StrPoints ) );

					formatex ( Temp, charsmax ( Temp ), "\w%s\d |\y %s\d |\r %s", Name [User], xItem, StrPoints );
						
					num_to_str ( User, String, charsmax ( String ) );
						
					menu_additem ( Menu, Temp, String );
						
					Items ++;
				}
			}
		}

		if ( !Items )
		{
			formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_MARKET_NO_ITEMS" );
			
			menu_additem ( Menu, Temp, "-10", 0, -1 );
		}
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public MarketMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{	
		if ( !iUserSell [id] )
		{
			iUserSellItem [id] = -1;
		}

		ShowMainMenu ( id );
		
		return DestroyMenu ( Menu );
	}
    
	new ItemData [6], Index;

	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
   
	Index = str_to_num ( ItemData );

	switch ( Index )
	{
		case -10:
		{
			ShowMarketMenu ( id );
	
			return DestroyMenu ( Menu );
		}
		case 33:
		{
			if ( iUserSell [id] )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MUST_CANCEL" );
				
				ShowMarketMenu ( id );
			}
			else
			{
				ShowItems ( id );
			}
		}
		case 34:
		{
			if ( iUserSellItem [id] < 1 || !UserHasItem ( id, iUserSellItem [id] ) )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MUST_SELECT" );

				ShowMarketMenu ( id );

				return DestroyMenu ( Menu );
			}
			else
			{
				if ( sWaitForPlace > get_systime (  ) - iLastPlace [id] )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MUST_WAIT", sWaitForPlace + iLastPlace [id] - get_systime (  ) );
					
					ShowMarketMenu ( id );
					
					return DestroyMenu ( Menu );
				}

				if ( iUserSellItem [id] == iTradeItem [id] && bTradeActive [id] )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_CANT_GIVE" );
						
					iUserSellItem [id] = -1;

					ShowMarketMenu ( id );

					return DestroyMenu ( Menu );
				}
			
				if ( iUserItemPrice [id] < 1 )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_IM_SET_PRICE" );
				
					ShowMarketMenu ( id );

					return DestroyMenu ( Menu );
				}
               
				new wPriceMin;
				
				new wPriceMax;
				
				CalcItemPrice ( iUserSellItem [id], wPriceMin, wPriceMax );

				if ( !( wPriceMin <= iUserItemPrice [id] <= wPriceMax ) )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_ITEM_MIN_MAX_PRICE", wPriceMin, wPriceMax );
					
					ShowMarketMenu ( id );
					
					return DestroyMenu ( Menu );
				}
               
				iUserSell [id] = true;
				
				iLastPlace [id] = get_systime (  );
				
				new xItem [128];
                
				GetItemName ( id, iUserSellItem [id], xItem, charsmax ( xItem ) );

				new StrPoints [16];

				AddCommas ( iUserItemPrice [id], StrPoints, charsmax ( StrPoints ) );
               
				client_print_color ( 0, id, "%s %L", CHAT_PREFIX, id, "CSGO_SELL_ANNOUNCE", Name [id], xItem, StrPoints );
			}
		}
		case 35:
		{
			iUserSell [id] = false;
			
			iUserSellItem [id] = -1;

			iUserItemPrice [id] = 0;

			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_CANCEL_SELL" );
			
			ShowMarketMenu ( id );
		}
		default:
		{
			if ( iLogged [Index] && iLogged [id] )
			{
				if ( iUserPoints [id] < iUserItemPrice [Index] )
				{
					new rPoints = iUserItemPrice [Index] - iUserPoints [id];
					
					new StrPoints [16];

					AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );	
						
					ShowMarketMenu ( id );
						
					return DestroyMenu ( Menu );
				}
						
				if ( iUserSellItem [Index] < 1 || !UserHasItem ( Index, iUserSellItem [Index] ) )
				{	
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_DONT_HAVE_ITEM" );	
						
					iUserSell [Index] = false;
					
					iUserSellItem [Index] = -1;

					ShowMarketMenu ( id );
						
					return DestroyMenu ( Menu );
				}

				if ( iUserSellItem [Index] >= 17000 )
				{
					if ( SkinTag [id] [iUserSellItem [Index] - 17000] != 0)
					{
						client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GIFT_HAS_SKINTAG", SkinName [iUserSellItem [Index] - 17000] );

						ShowMarketMenu ( id );
						
						return DestroyMenu ( Menu );
					}

					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( iUserSellItem [Index] - 17000 == iUserSelectedSkin [Index] [sID] )
						{
							iUserSelectedSkin [Index] [sID] = 0;
						}
					}

					SkinTag [Index] [iUserSellItem [Index] - 17000] = 0;

					if ( iUserSTs [Index] [iUserSellItem [Index] - 17000] < 1 )
					
						STKills [Index] [iUserSellItem [Index] - 17000] = 0;

					copy ( SkinTagN [id] [iUserSellItem [Index] - 17000], charsmax ( SkinTagN [ ] ), SkinTagN [Index] [iUserSellItem [Index] - 17000] );

					SkinTag [id] [iUserSellItem [Index] - 17000] = 2;
				}
				else if ( iUserSellItem [Index] >= 10000 )
				{
					if ( SkinTag [id] [iUserSellItem [Index] - 10000] != 0)
					{
						client_print_color ( id, id, "%s %L",CHAT_PREFIX, id, "CSGO_GIFT_HAS_SKINTAG", SkinName [iUserSellItem [Index] - 10000] );
						
						ShowMarketMenu ( id );

						return DestroyMenu ( Menu );
					}

					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( iUserSellItem [Index] - 10000 == iUserSelectedSkin [Index] [sID] )
						{
							iUserSelectedSkin [Index] [sID] = 0;
						}
					}

					SkinTag [Index] [iUserSellItem [Index] - 10000] = 0;

					copy ( SkinTagN [id] [iUserSellItem [Index] - 10000], charsmax ( SkinTagN [ ] ), SkinTagN [Index] [iUserSellItem [Index] - 10000] );	

					SkinTag [id] [iUserSellItem [Index] - 10000] = 1;
				}
				else if ( iUserSellItem [Index] >= 7000 )
				{

					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( iUserSellItem [Index] - 7000 == iUserSelectedSkin [Index] [sID] )
						{
							iUserSelectedSkin [Index] [sID] = 0;
						}
					}

					iUserSkins [Index] [iUserSellItem [Index] - 7000] --;

					iUserSTs [Index] [iUserSellItem [Index] - 7000] --;

					if ( iUserSTs [Index] [iUserSellItem [Index] - 7000] < 1 )
					
						STKills [Index] [iUserSellItem [Index] - 7000] = 0;

					iUserSkins [id] [iUserSellItem [Index] - 7000] ++;

					iUserSTs [id] [iUserSellItem [Index] - 7000] ++;

				}
				else if ( iUserSellItem [Index] >= 3000 )
				{
					iUserKeys [Index] [iUserSellItem [Index] - 3000] --;

					iUserKeys [id] [iUserSellItem [Index] - 3000] ++;
				}
				else if ( iUserSellItem [Index] >= 2500 )
				{
					iUserChests [Index] [iUserSellItem [Index] - 2500] --;

					iUserChests [id] [iUserSellItem [Index] - 2500] ++;
				}
				else if ( iUserSellItem [Index] >= 2000 )
				{
					iUserGloves [Index] [iUserSellItem [Index] - 2000] --;

					if ( iUserGloves [Index] [iUserSellItem [Index] - 2000] < 1 && g_iUserSelectedGlove [Index] == iUserSellItem [Index] - 2000 )
					{
						g_iUserSelectedGlove [Index] = 0;
					}

					iUserGloves [id] [iUserSellItem [Index] - 2000] ++;
				}
				else
				{

					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( iUserSellItem [Index] == iUserSelectedSkin [Index] [sID] )
						{
							iUserSelectedSkin [Index] [sID] = 0;
						}
					}

					iUserSkins [Index] [iUserSellItem [Index]] --;

					iUserSkins [id] [iUserSellItem [Index]] ++;
				}
				
				iUserPoints [id] -= iUserItemPrice [Index];
					
				iUserPoints [Index] += iUserItemPrice [Index];

				new xItem [128];
                
				GetItemName ( Index, iUserSellItem [Index], xItem, charsmax ( xItem ) );
			
				client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_X_BUY_Y", Name [id], xItem, Name [Index] );

				if ( iUserSellItem [Index] >= 17000 && iUserSellItem [Index] < 2000 )
				{
					formatex ( SkinTagN [Index] [iUserSellItem [Index] - 17000], charsmax ( SkinTagN [ ] ), "" );
				}
				else if ( iUserSellItem [Index] >= 10000 && iUserSellItem [Index] < 17000 )
				{
					formatex ( SkinTagN [Index] [iUserSellItem [Index] - 10000], charsmax ( SkinTagN [ ] ), "" );
				}

				iUserSell [Index] = false;
					
				iUserSellItem [Index] = -1;
			}
		}
	}
	
	return DestroyMenu ( Menu );
}

public ShowItems ( id )
{
	new Temp [512];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_ITEMS_MENU" );
	
	new Menu = menu_create ( Temp, "ItemMenuHandler", 0 );
	
	new String [32], bool: HasSkins = false;

	formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_KEY" );

	menu_additem ( Menu, Temp, "-30" );

	formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_CHEST" );

	menu_additem ( Menu, Temp, "-29" );

	formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_GLOVE" );

	menu_additem ( Menu, Temp, "-28" );
	
	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( SkinTag [id] [i] == 2 )
		{
			new wID = i + 17000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "\d[\r%s\d]\y %s\y [\rStatTrak\y]", SkinTagN [id] [i], SkinName [i]  );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
		else if ( SkinTag [id] [i] == 1 )
		{
			new wID = i + 10000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "\d[\r%s\d]\y %s\y [\r%s\y]", SkinTagN [id] [i], SkinName [i], GetSkinClass ( i ) );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( iUserSTs [id] [i] )
		{
			new wID = i + 7000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s \y[\rStatTrak\y]\d (%d)", SkinName [i], iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}

		if ( iUserSkins [id] [i] > iUserSTs [id] [i] )
		{
			num_to_str ( i, String, charsmax ( String ) );

			formatex ( Temp, charsmax ( Temp ), "%s\y [\r%s\y]\d (%d)", SkinName [i], GetSkinClass ( i ), iUserSkins [id] [i] - iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	if ( !HasSkins )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public ItemMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	
	switch ( Item )
	{
		case -10:
		{
			ShowMarketMenu ( id );
			
			return DestroyMenu ( Menu );
		}
		case -30:
		{
			ShowKeys ( id );
		}
		case -29:
		{
			ShowChests ( id );
		}
		case -28:
		{
			ShowGloves ( id );
		}
		default:
		{
			iUserSellItem [id] = Item;

			iUserItemPrice [id] = 0;

			client_cmd ( id, "messagemode ItemPrice" );
	
			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_IM_SET_PRICE" );
		}
	}

	return DestroyMenu ( Menu );
}

ShowKeys ( id )
{
	new Temp [96];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_KEYS_MENU" );
	
	new Menu = menu_create ( Temp, "KeysMMHandler", 0 );
	
	new bool: HasKeys = false, String [32];
	
	for ( new i = 1; i < ChestsNum; i ++ )
	{
		if ( iUserKeys [id] [i] != 0 )
		{
			new wID = i + 3000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s", ChestName [i] );

			menu_additem ( Menu, Temp, String );

			HasKeys = true;
		}
	}

	if ( !HasKeys )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_KEYS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;                                                                                
}

public KeysMMHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowItems ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	switch ( Item )
	{
		case -10:
		{
			ShowItems ( id );
			
			return DestroyMenu ( Menu );
		}
		default:
		{
			iUserSellItem [id] = Item;

			iUserItemPrice [id] = 0;

			client_cmd ( id, "messagemode ItemPrice" );
	
			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_IM_SET_PRICE" );
		}
	}

	return DestroyMenu ( Menu );
}

ShowChests ( id )
{
	new Temp [96];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_CHESTS_MENU" );
	
	new Menu = menu_create ( Temp, "ChestsMMHandler", 0 );
	
	new bool: HasChests = false, String [32];
	
	for ( new i = 1; i < ChestsNum; i ++ )
	{
		if ( iUserChests [id] [i] != 0 )
		{
			new wID = i + 2500;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s", ChestName [i] );

			menu_additem ( Menu, Temp, String );

			HasChests = true;
		}
	}

	if ( !HasChests )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_CHESTS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;                                                                                
}

public ChestsMMHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowItems ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	switch ( Item )
	{
		case -10:
		{
			ShowItems ( id );
			
			return DestroyMenu ( Menu );
		}
		default:
		{
			iUserSellItem [id] = Item;

			iUserItemPrice [id] = 0;

			client_cmd ( id, "messagemode ItemPrice" );
	
			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_IM_SET_PRICE" );
		}
	}

	return DestroyMenu ( Menu );
}

ShowGloves ( id )
{
	new Temp [96];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_GLOVES_MENU" );
	
	new Menu = menu_create ( Temp, "GlovesMMHandler", 0 );
	
	new bool: HasGloves = false, String [32];
	
	for ( new i = 1; i < GlovesNum; i ++ )
	{
		if ( iUserGloves [id] [i] != 0 )
		{
			new wID = i + 2000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s", GloveName [i] );

			menu_additem ( Menu, Temp, String );

			HasGloves = true;
		}
	}

	if ( !HasGloves )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_GLOVES" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;                                                                                
}

public GlovesMMHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowItems ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	switch ( Item )
	{
		case -10:
		{
			ShowItems ( id );
			
			return DestroyMenu ( Menu );
		}
		default:
		{
			iUserSellItem [id] = Item;

			iUserItemPrice [id] = 0;

			client_cmd ( id, "messagemode ItemPrice" );
	
			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_IM_SET_PRICE" );
		}
	}

	return DestroyMenu ( Menu );
}

ShowGiftMenu ( id )
{
	new Temp [64]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_GIFT_MENU" );
	
	new Menu = menu_create ( Temp, "GiftMenuHandler", 0 );
	
	new bool: HasTarget = false, HasItem = false;
	
	if ( !iGiftTarget [id] )
	{
		formatex ( Temp, charsmax ( Temp ), "%L:\r N/A", id, "CSGO_GIFT_USER" );
		
		menu_additem (Menu, Temp, "", 0, -1 );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "%L:\r %s", id, "CSGO_GIFT_USER", Name [iGiftTarget [id]] );
		
		menu_additem ( Menu, Temp, "", 0, -1);
		
		HasTarget = true;
	}
	if ( iGiftItem [id] < 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "%L:\r N/A", id, "CSGO_GIFT_ITEM" );
		
		menu_additem ( Menu, Temp, "", 0, -1 );
	}
	else
	{
		new Item [128]; GetItemName ( id, iGiftItem [id], Item, charsmax ( Item ) );
		
		formatex ( Temp, charsmax ( Temp ), "%L:\r %s^n", id, "CSGO_GIFT_ITEM", Item );

		menu_additem ( Menu, Temp, "", 0, -1 );
		
		HasItem = true;
	}
	
	if ( HasTarget && HasItem )
	{
		formatex ( Temp, charsmax ( Temp ), "\r%L", id, "CSGO_GIFT_SEND" );
		
		menu_additem ( Menu, Temp, "", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public GiftMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );
		
		return DestroyMenu ( Menu );
	}
	
	switch ( Item )
	{
		case 0: SelectGiftTarget ( id );
		
		case 1: SelectGiftItem ( id );

		case 2:
		{
			if ( iGiftItem [id] < 1 || !UserHasItem ( id, iGiftItem [id] ) )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MUST_SELECT" );

				//iGiftTarget [id] = 0;

				SendQuantity [id] = 0;

				iGiftItem [id] = -1;

				ShowGiftMenu ( id );

				return DestroyMenu ( Menu );
			}

			if ( iGiftItem [id] == iUserSellItem [id] && iUserSell [id] || iGiftItem [id] == iTradeItem [id] && bTradeActive [id] )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_CANT_GIVE" );
						
				SelectGiftItem ( id );

				return DestroyMenu ( Menu );
			}

			if ( !iLogged [iGiftTarget [id]] )
			{
				if ( iGiftItem [id] >= 3000 )
				{
					SendQuantity [id] = 0;
				}

				iGiftTarget [id] = 0;
				
				iGiftItem [id] = -1;
				
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_INVALID_TARGET" );
				
				return DestroyMenu ( Menu );
			}
			else
			{
				if ( iGiftItem [id] == 4001 )
				{
					iUserPoints [id] -= SendQuantity [id];
			
					iUserPoints [iGiftTarget [id]] += SendQuantity [id];
				}
				else if ( iGiftItem [id] == 4000 )
				{
					iUserDusts [id] -= SendQuantity [id];
			
					iUserDusts [iGiftTarget [id]] += SendQuantity [id];
				}
				else if ( iGiftItem [id] >= 17000 )
				{
					if ( SkinTag [iGiftTarget [id]] [iGiftItem [id] - 17000] != 0 )
					{
						client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GIFT_HAS_SKINTAG", SkinName [iGiftItem [id] - 17000] );

						ShowGiftMenu ( id );
						
						return DestroyMenu ( Menu );
					}

					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( iGiftItem [id] - 17000 == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					SkinTag [id] [iGiftItem [id] - 17000] = 0;

					if ( iUserSTs [id] [iGiftItem [id] - 17000] < 1 )

						STKills [id] [iGiftItem [id] - 17000] = 0;

					copy ( SkinTagN [iGiftTarget [id]] [iGiftItem [id] - 17000], charsmax ( SkinTagN [ ] ), SkinTagN [id] [iGiftItem [id] - 17000] );

					//formatex ( SkinTagN [id] [iGiftItem [id] - 17000], charsmax ( SkinTagN [ ] ), "" );

					SkinTag [iGiftTarget [id]] [iGiftItem [id] - 17000] = 2;
				}
				else if ( iGiftItem [id] >= 10000 )
				{
					if ( SkinTag [iGiftTarget [id]] [iGiftItem [id] - 10000] != 0 )
					{
						client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GIFT_HAS_SKINTAG", SkinName [iGiftItem [id] - 10000] );

						ShowGiftMenu ( id );
						
						return DestroyMenu ( Menu );
					}

					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( iGiftItem [id] - 10000 == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					SkinTag [id] [iGiftItem [id] - 10000] = 0;

					copy ( SkinTagN [iGiftTarget [id]] [iGiftItem [id] - 10000], charsmax ( SkinTagN [ ] ), SkinTagN [id] [iGiftItem [id] - 10000] );

					//formatex ( SkinTagN [id] [iGiftItem [id] - 10000], charsmax ( SkinTagN [ ] ), "" );

					SkinTag [iGiftTarget [id]] [iGiftItem [id] - 10000] = 1;
				}
				else if ( iGiftItem [id] >= 7000 )
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( iGiftItem [id] - 7000 == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					iUserSkins [id] [iGiftItem [id] - 7000] --;

					iUserSTs [id] [iGiftItem [id] - 7000] --;

					if ( iUserSTs [id] [iGiftItem [id] - 7000] < 1 )

						STKills [id] [iGiftItem [id] - 7000] = 0;

					iUserSkins [iGiftTarget [id]] [iGiftItem [id] - 7000] ++;

					iUserSTs [iGiftTarget [id]] [iGiftItem [id] - 7000] ++;

				}
				else if ( iGiftItem [id] >= 3000 )
				{
					iUserKeys [id] [iGiftItem [id] - 3000] --;

					iUserKeys [iGiftTarget [id]] [iGiftItem [id] - 3000] ++;
				}
				else if ( iGiftItem [id] >= 2500 )
				{
					iUserChests [id] [iGiftItem [id] - 2500] --;

					iUserChests [iGiftTarget [id]] [iGiftItem [id] - 2500] ++;
				}
				else if ( iGiftItem [id] >= 2000 )
				{
					iUserGloves [id] [iGiftItem [id] - 2000] --;

					if ( iUserGloves [id] [iGiftItem [id] - 2000] < 1 && g_iUserSelectedGlove [id] == iGiftItem [id] - 2000 )
					{
						g_iUserSelectedGlove [id] = 0;
					}

					iUserGloves [iGiftTarget [id]] [iGiftItem [id] - 2000] ++;
				}
				else
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( iGiftItem [id] == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					iUserSkins [id] [iGiftItem [id]] --;

					iUserSkins [iGiftTarget [id]] [iGiftItem [id]] ++;
				}

				new xItem [128];
                
				GetItemName ( id, iGiftItem [id], xItem, charsmax ( xItem ) );

				LogToFile ( "[GIFT] - %s i-a dat lui %s %s", Name [id], Name [iGiftTarget [id]], xItem );

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SEND_GIFT", xItem, Name [iGiftTarget [id]] );
				
				client_print_color ( iGiftTarget [id], id, "%s %L", CHAT_PREFIX, iGiftTarget [id], "CSGO_RECIEVE_GIFT", Name [id], xItem );

				if ( iGiftItem [id] >= 4000 )
				{
					SendQuantity [id] = 0;
				}
				else if ( iGiftItem [id] >= 17000 && iGiftItem [id] < 2000 )
				{
					formatex ( SkinTagN [id] [iGiftItem [id] - 17000], charsmax ( SkinTagN [ ] ), "" );
				}
				else if ( iGiftItem [id] >= 10000 && iGiftItem [id] < 17000 )
				{	
					formatex ( SkinTagN [id] [iGiftItem [id] - 10000], charsmax ( SkinTagN [ ] ), "" );
				}

				iGiftTarget [id] = 0;
				
				iGiftItem [id] = -1;
			}
		}
		default: {    }
	}
	
	return DestroyMenu ( Menu );
}

SelectGiftTarget ( id )
{
	new Temp [64]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_USERS_MENU" );

	new Menu = menu_create ( Temp, "SGTargetMenuHandler", 0 );

	new xItem [10];

	new Players [32], Num, User;

	get_players ( Players, Num, "ch" ); 

	new Total = 0;

	if ( Num )
	{
		for ( new i = 0; i < Num; i ++ )
		{
			User = Players [i];
			
			if ( iLogged [User] && User != id  )
			{	
				num_to_str ( User, xItem, charsmax ( xItem ) );
				
				menu_additem ( Menu, Name [User], xItem, 0, -1 );
				
				Total ++;
			}
		}
	}

	if ( !Total )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_NOT_USERS_LOGGED" );

		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}

	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public SGTargetMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowGiftMenu ( id );
		
		return DestroyMenu ( Menu );
	}

	new ItemData [6], Index, UserName [32];
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ), UserName, charsmax ( UserName ) );
	
	Index = str_to_num ( ItemData );
	
	switch ( Index )
	{
		case -10:
		{
			ShowGiftMenu ( id );

			return DestroyMenu ( Menu );
		}
		default:
		{
			iGiftTarget [id] = Index;
			
			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SELECT_TARGET", UserName );
            
			ShowGiftMenu ( id );
		}
	}
	return DestroyMenu ( Menu );
}

SelectGiftItem ( id )
{
	new Temp [64]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_ITEMS_MENU" );
	
	new Menu = menu_create ( Temp, "SGItemMenuHandler", 0 );
	
	new String [32], bool: HasSkins = false;

	formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_POINTS" );

	menu_additem ( Menu, Temp, "-32" );

	formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_DUSTS" );

	menu_additem ( Menu, Temp, "-31" );

	formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_KEY" );

	menu_additem ( Menu, Temp, "-30" );

	formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_CHEST" );

	menu_additem ( Menu, Temp, "-29" );

	formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_GLOVE" );

	menu_additem ( Menu, Temp, "-28" );
	
	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( SkinTag [id] [i] == 2 )
		{
			new wID = i + 17000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "\d[\r%s\d]\w %s\y [\rStatTrak\y]", SkinTagN [id] [i], SkinName [i]);

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
		else if ( SkinTag [id] [i] == 1 )
		{
			new wID = i + 10000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "\d[\r%s\d]\y %s\y [\r%s\y]", SkinTagN [id] [i], SkinName [i], GetSkinClass ( i ) );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( iUserSTs [id] [i] )
		{
			new wID = i + 7000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s \y[\rStatTrak\y]\d (%d)", SkinName [i], iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}

		if ( iUserSkins [id] [i] > iUserSTs [id] [i] )
		{
			num_to_str ( i, String, charsmax ( String ) );

			formatex ( Temp, charsmax ( Temp ), "%s\y [\r%s\y] \d (%d)", SkinName [i], GetSkinClass ( i ), iUserSkins [id] [i] - iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	if ( !HasSkins )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public SGItemMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	
	switch ( Item )
	{
		case -10:
		{
			ShowMainMenu ( id );
			
			return DestroyMenu ( Menu );
		}
		case -32:
		{
			iGiftItem [id] = 4001;

			client_cmd ( id, "messagemode InputValue" );
		}
		case -31:
		{
			iGiftItem [id] = 4000;

			client_cmd ( id, "messagemode InputValue" );
		}
		case -30:
		{
			ShowGiftKeysMenu ( id );
		}
		case -29:
		{
			ShowGiftChestsMenu ( id );
		}
		case -28:
		{
			ShowGiftGlovesMenu ( id );
		}
		default:
		{
			iGiftItem [id] = Item;

			ShowGiftMenu ( id );
		}
	}

	return DestroyMenu ( Menu );
}

ShowGiftKeysMenu ( id )
{
	new Temp [96];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_KEYS_MENU" );
	
	new Menu = menu_create ( Temp, "GiftKeysHandler", 0 );
	
	new bool: HasKeys = false, String [32];
	
	for ( new i = 1; i < ChestsNum; i ++ )
	{
		if ( iUserKeys [id] [i] != 0 )
		{
			new wID = i + 3000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s", ChestName [i] );

			menu_additem ( Menu, Temp, String );

			HasKeys = true;
		}
	}

	if ( !HasKeys )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_KEYS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;                                                                                
}

public GiftKeysHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		SelectGiftItem ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	switch ( Item )
	{
		case -10:
		{
			SelectGiftItem ( id );
			
			return DestroyMenu ( Menu );
		}
		default:
		{
			iGiftItem [id] = Item;

			ShowGiftMenu ( id );
		}
	}

	return DestroyMenu ( Menu );
}

ShowGiftChestsMenu ( id )
{
	new Temp [96];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_CHESTS_MENU" );
	
	new Menu = menu_create ( Temp, "GiftChestsHandler", 0 );
	
	new bool: HasChests = false, String [32];
	
	for ( new i = 1; i < ChestsNum; i ++ )
	{
		if ( iUserChests [id] [i] != 0 )
		{
			new wID = i + 2500;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s", ChestName [i] );

			menu_additem ( Menu, Temp, String );

			HasChests = true;
		}
	}

	if ( !HasChests )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_CHESTS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;                                                                                
}

public GiftChestsHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		SelectGiftItem ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	switch ( Item )
	{
		case -10:
		{
			SelectGiftItem ( id );
			
			return DestroyMenu ( Menu );
		}
		default:
		{
			iGiftItem [id] = Item;

			ShowGiftMenu ( id );
		}
	}

	return DestroyMenu ( Menu );
}

ShowGiftGlovesMenu ( id )
{
	new Temp [96];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_GLOVES_MENU" );
	
	new Menu = menu_create ( Temp, "GiftGlovesHandler", 0 );
	
	new bool: HasGloves = false, String [32];
	
	for ( new i = 1; i < GlovesNum; i ++ )
	{
		if ( iUserGloves [id] [i] != 0 )
		{
			new wID = i + 2000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s", GloveName [i] );

			menu_additem ( Menu, Temp, String );

			HasGloves = true;
		}
	}

	if ( !HasGloves )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_GLOVES" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;                                                                                
}

public GiftGlovesHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		SelectGiftItem ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	switch ( Item )
	{
		case -10:
		{
			SelectGiftItem ( id );
			
			return DestroyMenu ( Menu );
		}
		default:
		{
			iGiftItem [id] = Item;

			ShowGiftMenu ( id );
		}
	}

	return DestroyMenu ( Menu );
}

ShowTradeMenu ( id )
{
	if ( bTradeAccept [id] )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_INFO2" );
		
		return PLUGIN_CONTINUE;
	}

	new Temp [124];

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_TRADE_MENU" );

	new Menu = menu_create ( Temp, "TradeMenuHandler", 0 );

	new bool:HasTarget = false, bool:HasItem = false;

	new Target = iTradeTarget [id];

	if ( Target )
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r %s", id, "CSGO_GIFT_USER", Name [Target] );
	
		menu_additem ( Menu, Temp, "0", 0, -1 );
		
		HasTarget = true;
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r N/A", id, "CSGO_GIFT_USER" );
	
		menu_additem ( Menu, Temp, "0", 0, -1 );
	}

	if ( iTradeItem [id] < 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r N/A^n", id, "CSGO_GIFT_ITEM" );

		menu_additem ( Menu, Temp, "1", 0, -1 );
	}
	else
	{
		new Item [512];
	
		GetItemName ( id, iTradeItem [id], Item, charsmax ( Item ) );

		formatex ( Temp, charsmax ( Temp ), "\w%L:\r %s^n", id, "CSGO_GIFT_ITEM", Item );

		menu_additem ( Menu, Temp, "1", 0, -1 );
		
		HasItem = true;
	}

	if ( HasTarget && HasItem && !bTradeActive [id] )
	{
		formatex ( Temp, charsmax ( Temp ), "\y%L^n\d--------------------", id, "CSGO_GIFT_SEND" );

		menu_additem ( Menu, Temp, "2", 0, -1 );
	}

	if ( bTradeActive [id] || bTradeSecond [id] )
	{
		formatex ( Temp, charsmax ( Temp ), "\r%L", id, "CSGO_TRADE_CANCEL" );
		
		menu_additem ( Menu, Temp, "3", 0, -1 );
	}

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;
}

public TradeMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		if ( bTradeSecond [id] )
		{
			ClCmdSayDeny ( id );
		}

		ShowMainMenu ( id );

		return DestroyMenu ( Menu );
	}

	switch ( Item )
	{
		case 0:
		{
			if ( bTradeActive [id] || bTradeSecond [id] )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_LOCKED" );

				ShowTradeMenu ( id );

				return DestroyMenu ( Menu );
			}
			else
			{
				SelectTradeTarget ( id );
			}
		}
		case 1:
		{
			if ( bTradeActive [id] )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_LOCKED" );
			
				ShowTradeMenu ( id );

				return DestroyMenu ( Menu );
			}
			else
			{
				SelectTradeItem ( id );
			}
		}
		case 2:
		{
			new Target = iTradeTarget [id];

			new xItem = iTradeItem [id];

			if ( xItem < 1 || !UserHasItem ( id, xItem ) )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MUST_SELECT" );

				iTradeItem [id] = -1;

				ShowTradeMenu ( id );

				return DestroyMenu ( Menu );
			}

			if ( xItem == iUserSellItem [id] && iUserSell [id] )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_CANT_GIVE" );
						
				SelectTradeItem ( id );

				return DestroyMenu ( Menu );
			}

			if ( !iLogged [Target] || !is_user_connected ( Target ) )
			{
				client_print_color ( id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CSGO_INVALID_TARGET" );
				
				ResetTradeData ( id );
				
				ShowTradeMenu ( id );
			}
			else
			{
				if ( xItem < 1 || !UserHasItem (id, xItem ) )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_ITEMS" );
					
					iTradeItem [id] = -1;
					
					ShowTradeMenu ( id );

					return DestroyMenu ( Menu );
				}

				if ( bTradeSecond [id] && ( iTradeItem [Target] < 1 || !UserHasItem ( Target, iTradeItem [Target] ) ) )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_FAIL" );
					
					client_print_color ( Target, Target, "%s %L", CHAT_PREFIX, Target, "CSGO_TRADE_FAIL" );

					ResetTradeData ( id );
				
					ResetTradeData ( Target );
	
					ShowTradeMenu ( id );

					return DestroyMenu ( Menu );
				}
				
				bTradeActive [id] = true;

				iTradeRequest [Target] = id;

				HasTrade [Target] = true;

				new gItem [128];

				GetItemName ( id, iTradeItem [id], gItem, charsmax ( gItem ) );

				if ( !bTradeSecond [id] )
				{
					client_print_color ( Target, Target, "%s %L", CHAT_PREFIX, Target, "CSGO_TRADE_INFO1", Name [id], gItem );
					
					client_print_color ( Target, Target, "%s %L", CHAT_PREFIX, Target, "CSGO_TRADE_INFO2" );
				}
				else
				{
					new sItem [128];
					
					GetItemName ( Target, iTradeItem [Target], sItem, charsmax ( sItem ) );
					
					client_print_color ( Target, Target, "%s %L", CHAT_PREFIX, Target, "CSGO_TRADE_INFO3", Name[id], gItem, sItem );
					
					client_print_color ( Target, Target, "%s %L", CHAT_PREFIX, Target, "CSGO_TRADE_INFO2" );
					
					bTradeAccept [Target] = true;
				}

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_SEND", Name [Target] );
			}
		}
		case 3:
		{
			if ( bTradeSecond [id] )
			{
				ClCmdSayDeny ( id );
			}
			else
			{
				ResetTradeData ( id );
			}

			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_CANCELED" );

			ShowTradeMenu ( id );
		}
		default: {   }
	}

	return DestroyMenu ( Menu );
}

SelectTradeTarget ( id )
{
	new Temp [64]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d] %L", id, "CSGO_USERS_MENU" );

	new Menu = menu_create ( Temp, "TTMenuHandler", 0 );

	new xItem [10];

	new Players [32], Num, User;

	get_players ( Players, Num, "ch" ); 

	new Total = 0;

	if ( Num )
	{
		for ( new i = 0; i < Num; i ++ )
		{
			User = Players [i];
			
			if ( iLogged [User] && User != id  )
			{	
				num_to_str ( User, xItem, charsmax ( xItem ) );
				
				menu_additem ( Menu, Name [User], xItem, 0, -1 );
				
				Total ++;
			}
		}
	}

	if ( !Total )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_NOT_USERS_LOGGED" );

		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}

	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public TTMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowTradeMenu(id);
		
		return DestroyMenu ( Menu );
	}

	new ItemData [6], UserName [32], Index;

	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ), UserName, charsmax ( UserName ) );

	Index = str_to_num ( ItemData );

	switch ( Index )
	{
		case -10:
		{
			ShowMainMenu ( id );

			return DestroyMenu ( Menu );
		}
		default:
		{
			if ( iTradeRequest [Index] )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TARGET_TRADE_ACTIVE", UserName );
			}
			else
			{
				iTradeTarget [id] = Index;
			}

			ShowTradeMenu ( id );
		}	
	}

	return DestroyMenu ( Menu );
}

SelectTradeItem ( id )
{
	new Temp [512]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_ITEMS_MENU" );
	
	new Menu = menu_create ( Temp, "TIMenuHandler", 0 );
	
	new String [32], bool: HasSkins = false;

	formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_KEY" );

	menu_additem ( Menu, Temp, "-30" );

	formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_CHEST" );

	menu_additem ( Menu, Temp, "-29" );

	formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_GLOVE" );

	menu_additem ( Menu, Temp, "-28" );
	
	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( SkinTag [id] [i] == 2 )
		{
			new wID = i + 17000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "\d[\r%s\d]\y %s\y [\rStatTrak\y]", SkinTagN [id] [i], SkinName [i], GetSkinClass ( i ) );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
		else if ( SkinTag [id] [i] == 1 )
		{
			new wID = i + 10000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "\d[\r%s\d]\y %s\y [\r%s\y]", SkinTagN [id] [i], SkinName [i], GetSkinClass ( i ) );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( iUserSTs [id] [i] )
		{
			new wID = i + 7000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s\y [\rStatTrak\y]\d (%d)", SkinName [i], iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}

		if ( iUserSkins [id] [i] > iUserSTs [id] [i] )
		{
			num_to_str ( i, String, charsmax ( String ) );

			formatex ( Temp, charsmax ( Temp ), "%s\y [\r%s\y]\d (%d)", SkinName [i], GetSkinClass ( i ), iUserSkins [id] [i] - iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	if ( !HasSkins )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public TIMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	switch ( Item )
	{
		case -10:
		{
			ShowMainMenu ( id );
			
			return DestroyMenu ( Menu );
		}
		case -30:
		{
			ShowTradeKeysMenu ( id );
		}
		case -29:
		{
			ShowTradeChestsMenu ( id );
		}
		case -28:
		{
			ShowTradeGlovesMenu ( id );
		}
		default:
		{
			iTradeItem [id] = Item;

			ShowTradeMenu ( id );
		}
	}

	return DestroyMenu ( Menu );
}

ShowTradeKeysMenu ( id )
{
	new Temp [96];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_KEYS_MENU" );
	
	new Menu = menu_create ( Temp, "TradeKeysHandler", 0 );
	
	new bool: HasKeys = false, String [32];
	
	for ( new i = 1; i < ChestsNum; i ++ )
	{
		if ( iUserKeys [id] [i] != 0 )
		{
			new wID = i + 3000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s", ChestName [i] );

			menu_additem ( Menu, Temp, String );

			HasKeys = true;
		}
	}

	if ( !HasKeys )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_KEYS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;                                                                                
}

public TradeKeysHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		SelectTradeItem ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	switch ( Item )
	{
		case -10:
		{
			SelectTradeItem ( id );
			
			return DestroyMenu ( Menu );
		}
		default:
		{
			iTradeItem [id] = Item;

			ShowTradeMenu ( id );
		}
	}

	return DestroyMenu ( Menu );
}

ShowTradeChestsMenu ( id )
{
	new Temp [96];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_CHESTS_MENU" );
	
	new Menu = menu_create ( Temp, "TradeChestsHandler", 0 );
	
	new bool: HasChests = false, String [32];
	
	for ( new i = 1; i < ChestsNum; i ++ )
	{
		if ( iUserChests [id] [i] != 0 )
		{
			new wID = i + 2500;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s", ChestName [i] );

			menu_additem ( Menu, Temp, String );

			HasChests = true;
		}
	}

	if ( !HasChests )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_CHESTS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;                                                                                
}

public TradeChestsHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		SelectGiftItem ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	switch ( Item )
	{
		case -10:
		{
			SelectTradeItem ( id );
			
			return DestroyMenu ( Menu );
		}
		default:
		{
			iTradeItem [id] = Item;

			ShowTradeMenu ( id );
		}
	}

	return DestroyMenu ( Menu );
}

ShowTradeGlovesMenu ( id )
{
	new Temp [96];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_GLOVES_MENU" );
	
	new Menu = menu_create ( Temp, "TradeGlovesHandler", 0 );
	
	new bool: HasGloves = false, String [32];
	
	for ( new i = 1; i < GlovesNum; i ++ )
	{
		if ( iUserGloves [id] [i] != 0 )
		{
			new wID = i + 2000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s", GloveName [i] );

			menu_additem ( Menu, Temp, String );

			HasGloves = true;
		}
	}

	if ( !HasGloves )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_GLOVES" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;                                                                                
}

public TradeGlovesHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		SelectGiftItem ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	switch ( Item )
	{
		case -10:
		{
			SelectTradeItem ( id );
			
			return DestroyMenu ( Menu );
		}
		default:
		{
			iTradeItem [id] = Item;

			ShowTradeMenu ( id );
		}
	}

	return DestroyMenu ( Menu );
}

public ClCmdSayAccept ( id )
{
	new Sender = iTradeRequest [id];

	if ( Sender < 1 || Sender > 32 )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_DONT_HAVE_REQ" );

		return PLUGIN_HANDLED;
	}

	if ( !iLogged [Sender] || !is_user_connected ( Sender ) )
	{
		ResetTradeData ( id );
		
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_INVALID_SENDER" );

		return PLUGIN_HANDLED;
	}

	if ( !bTradeActive [Sender] )// || id == iTradeTarget [Sender] )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_IS_CANCELED" );
		
		ResetTradeData ( id );

		return PLUGIN_HANDLED;
	}

	if ( bTradeAccept [id] )
	{
		new sItem = iTradeItem [Sender];

		new tItem = iTradeItem [id];

		if ( tItem < 1 || !UserHasItem ( id, tItem ) || sItem < 1 || !UserHasItem ( Sender, sItem ) )
		{
			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_FAIL2" );
			
			client_print_color ( Sender, Sender, "%s %L", CHAT_PREFIX, Sender, "CSGO_TRADE_FAIL2" );
			
			ResetTradeData ( id );
			
			ResetTradeData ( Sender );

			return PLUGIN_HANDLED;
		}

		if ( sItem >= 17000 )
		{
			if ( SkinTag [id] [sItem - 17000] != 0 )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GIFT_HAS_SKINTAG", SkinName [sItem - 17000] );

				ResetTradeData ( Sender );

				ResetTradeData ( id );
	
				return PLUGIN_CONTINUE;
			}

			for ( new sID = 0; sID < 25; sID ++ )
			{
				if ( sItem - 17000 == iUserSelectedSkin [Sender] [sID] )
				{
					iUserSelectedSkin [Sender] [sID] = 0;
				}
			}

			SkinTag [Sender] [sItem - 17000] = 0;

			if ( iUserSTs [Sender] [sItem - 17000] < 1 )

				STKills [Sender] [sItem - 17000] = 0;

			copy ( SkinTagN [id] [sItem - 17000], charsmax ( SkinTagN [ ] ), SkinTagN [Sender] [sItem - 17000] );

			SkinTag [id] [sItem - 17000] = 2;
		}
		else if ( sItem >= 10000 )
		{
			if ( SkinTag [id] [sItem - 10000] != 0 )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GIFT_HAS_SKINTAG", SkinName [sItem - 10000] );

				ResetTradeData ( Sender );

				ResetTradeData ( id );
						
				return PLUGIN_CONTINUE;
			}

			for ( new sID = 0; sID < 25; sID ++ )
			{
				if ( sItem - 10000 == iUserSelectedSkin [Sender] [sID] )
				{
					iUserSelectedSkin [Sender] [sID] = 0;
				}
			}

			SkinTag [Sender] [sItem - 10000] = 0;

			copy ( SkinTagN [id] [sItem - 10000], charsmax ( SkinTagN [ ] ), SkinTagN [Sender] [sItem - 10000] );

			SkinTag [id] [sItem - 10000] = 1;
		}
		else if ( sItem >= 7000 )
		{
			for ( new sID = 0; sID < 25; sID ++ )
			{
				if ( iTradeItem [Sender] - 7000 == iUserSelectedSkin [Sender] [sID] )
				{
					iUserSelectedSkin [Sender] [sID] = 0;
				}
			}

			iUserSkins [Sender] [sItem - 7000] --;

			iUserSTs [Sender] [sItem - 7000] --;

			if ( iUserSTs [Sender] [sItem - 7000] < 1 )

				STKills [Sender] [sItem - 7000] = 0;

			iUserSkins [id] [sItem - 7000] ++;

			iUserSTs [id] [sItem - 7000] ++;
		}
		else if ( sItem >= 3000 )
		{
			iUserKeys [Sender] [sItem - 3000] --;

			iUserKeys [id] [sItem - 3000] ++;
		}
		else if ( sItem >= 2500 )
		{
			iUserChests [Sender] [sItem - 2500] --;

			iUserChests [id] [sItem - 2500] ++;
		}
		else if ( sItem >= 2000 )
		{
			iUserGloves [Sender] [sItem - 2000] --;

			if ( iUserGloves [Sender] [sItem - 2000] < 1 && g_iUserSelectedGlove [Sender] == sItem - 2000 )
			{
				g_iUserSelectedGlove [Sender] = 0;
			}

			iUserGloves [id] [sItem - 2000] ++;
		}
		else
		{
			for ( new sID = 0; sID < 25; sID ++ )
			{
				if ( iTradeItem [Sender] == iUserSelectedSkin [Sender] [sID] )
				{
					iUserSelectedSkin [Sender] [sID] = 0;
				}
			}

			iUserSkins [Sender] [sItem] --;

			iUserSkins [id] [sItem] ++;
		}

		if ( tItem >= 17000 )
		{
			if ( SkinTag [Sender] [tItem - 17000] != 0 )
			{
				client_print_color ( Sender, Sender, "%s %L", CHAT_PREFIX, Sender, "CSGO_GIFT_HAS_SKINTAG", SkinName [tItem - 17000] );

				ResetTradeData ( Sender );

				ResetTradeData ( id );
	
				return PLUGIN_CONTINUE;
			}

			for ( new sID = 0; sID < 25; sID ++ )
			{
				if ( tItem == iUserSelectedSkin [id] [sID] )
				{
					iUserSelectedSkin [id] [sID] = 0;
				}
			}

			SkinTag [id] [tItem - 17000] = 0;

			if ( iUserSTs [id] [tItem - 17000] < 1 )

				STKills [id] [tItem - 17000] = 0;

			copy ( SkinTagN [Sender] [tItem - 17000], charsmax ( SkinTagN [ ] ), SkinTagN [id] [tItem - 17000] );

			SkinTag [Sender] [tItem - 17000] = 2;
		}
		else if ( tItem >= 10000 )
		{
			if ( SkinTag [Sender] [tItem - 10000] != 0 )
			{
				client_print_color ( Sender, Sender, "%s %L", CHAT_PREFIX, Sender, "CSGO_GIFT_HAS_SKINTAG", SkinName [tItem - 10000] );

				ResetTradeData ( Sender );

				ResetTradeData ( id );
						
				return PLUGIN_CONTINUE;
			}

			for ( new sID = 0; sID < 25; sID ++ )
			{
				if ( tItem - 10000 == iUserSelectedSkin [id] [sID] )
				{
					iUserSelectedSkin [id] [sID] = 0;
				}
			}

			SkinTag [id] [tItem - 10000] = 0;

			copy ( SkinTagN [Sender] [tItem - 10000], charsmax ( SkinTagN [ ] ), SkinTagN [id] [tItem - 10000] );
			
			SkinTag [Sender] [tItem - 10000] = 1;
		}
		else if ( tItem >= 7000 )
		{
			for ( new sID = 0; sID < 25; sID ++ )
			{
				if ( iTradeItem [id] - 7000 == iUserSelectedSkin [id] [sID] )
				{
					iUserSelectedSkin [id] [sID] = 0;
				}
			}

			iUserSkins [id] [tItem - 7000] --;

			iUserSTs [id] [tItem - 7000] --;

			if ( iUserSTs [id] [tItem - 7000] < 1 )

				STKills [id] [tItem - 7000] = 0;

			iUserSkins [Sender] [tItem - 7000] ++;

			iUserSTs [Sender] [tItem - 7000] ++;
		}
		else if ( tItem >= 3000 )
		{
			iUserKeys [id] [tItem - 3000] --;

			iUserKeys [Sender] [tItem - 3000] ++;
		}
		else if ( tItem >= 2500 )
		{
			iUserChests [id] [tItem - 2500] --;

			iUserChests [Sender] [tItem - 2500] ++;
		}
		else if ( tItem >= 2000 )
		{
			iUserGloves [id] [tItem - 2000] --;

			if ( iUserGloves [id] [tItem - 2000] < 1 && g_iUserSelectedGlove [id] == tItem - 2000 )
			{
				g_iUserSelectedGlove [id] = 0;
			}

			iUserGloves [Sender] [tItem - 2000] ++;
		}
		else
		{
			for ( new sID = 0; sID < 25; sID ++ )
			{
				if ( iTradeItem [id] == iUserSelectedSkin [id] [sID] )
				{
					iUserSelectedSkin [id] [sID] = 0;
				}
			}

			iUserSkins [id] [tItem] --;

			iUserSkins [Sender] [tItem] ++;
		}

		new sItemsz [128], tItemsz [128];

		GetItemName ( id, tItem, tItemsz, charsmax ( tItemsz ) );

		GetItemName ( Sender, sItem, sItemsz, charsmax ( sItemsz ) );

		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_SUCCESS", tItemsz, sItemsz );
		
		client_print_color ( Sender, Sender, "%s %L", CHAT_PREFIX, Sender, "CSGO_TRADE_SUCCESS", sItemsz, tItemsz );

		if ( sItem >= 17000 && sItem < 2000 )
		{
			formatex ( SkinTagN [Sender] [sItem - 17000], charsmax ( SkinTagN [ ] ), "" );
		}
		else if ( sItem >= 10000 && sItem < 17000 )
		{
			formatex ( SkinTagN [Sender] [sItem - 10000], charsmax ( SkinTagN [ ] ), "" );
		}

		if ( tItem >= 17000 && tItem < 2000 )
		{
			formatex ( SkinTagN [id] [tItem - 17000], charsmax ( SkinTagN [ ] ), "" );

		}
		else if ( tItem >= 10000 && tItem < 17000 )
		{
			formatex ( SkinTagN [id] [tItem - 10000], charsmax ( SkinTagN [ ] ), "" );
		}

		ResetTradeData ( id );
		
		ResetTradeData ( Sender );
	}
	else if ( !bTradeSecond [id] )
	{
		iTradeTarget [id] = Sender;

		iTradeItem [id] = -1;
	
		bTradeSecond [id] = true;

		ShowTradeMenu ( id );

		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_SELECT_ITEM" );
	}

	return PLUGIN_HANDLED;
}

public ClCmdSayDeny ( id )
{
	new Sender = iTradeRequest [id];

	if ( Sender < 1 || Sender > 32 )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_DONT_HAVE_REQ" );
		
		return PLUGIN_HANDLED;
	}

	if ( !iLogged [Sender] || !is_user_connected ( Sender ) )
	{
		ResetTradeData ( id );
		
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_INVALID_SENDER" );
		
		return PLUGIN_HANDLED;
	}

	if ( !bTradeActive [Sender] )// || id == iTradeTarget [Sender] )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_TRADE_IS_CANCELED" );

		ResetTradeData ( id );

		return PLUGIN_HANDLED;
	}

	ResetTradeData ( id );

	ResetTradeData ( Sender );

	client_print_color ( Sender, Sender, "%s %L", CHAT_PREFIX, Sender, "CSGO_TARGET_REFUSE_TRADE", Name [id] );
	
	client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_YOU_REFUSE_TRADE", Name [Sender] );
	
	return PLUGIN_HANDLED;
}

ResetTradeData ( id )
{
	bTradeActive [id] = false;
	
	bTradeSecond [id] = false;
	
	bTradeAccept [id] = false;
	
	iTradeTarget [id] = 0;
	
	iTradeItem [id] = -1;
	
	iTradeRequest [id] = 0;

	HasTrade [id] = false;
}


ShowGamesMenu ( id )
{
	new Temp [64]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_GAMES_MENU" );

	new Menu = menu_create ( Temp, "GamesMenuHandler", 0 );

	new StrPoints1 [16];

	AddCommas ( sTombolaCost, StrPoints1, charsmax ( StrPoints1 ) );

	formatex ( Temp, charsmax ( Temp ), "\w%L\d [\yCost:\r %s\d]", id, "CSGO_MM_TOMBOLA", StrPoints1 );
	
	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L %s", id, "CSGO_GAME_ROULETTE", bRouletteWork ? "\r[Open]" : "\d[Closed]" );
	
	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L %s", id, "CSGO_GAME_JACKPOT", bJackpotWork ? "\r[Open]" : "\d[Closed]" );
	
	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L %s", id, "CSGO_GAME_BATTLE", bBattleWork ? "\r[Open]" : "\d[Closed]" );
	
	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L %s", id, "CSGO_GAME_GUESS_NUMBER", bGuessNumWork ? "\r[Open]" : "\d[Closed]" );
	
	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_BET_TEAM" );
	
	menu_additem ( Menu, Temp, "", 0, -1 );
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public GetYourReward ( id )
{
	new year, month, day, seconds, hours, minutes;
   
	date ( year, month, day );

	seconds = ( iHoursPlayed [id]* 60 ) + get_user_time ( id );

	minutes = iHoursPlayed [id] + ( get_user_time ( id ) / 60 )

	hours = seconds / 3600;
   
	if ( !iLogged [id] ) 
	{
      		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_REWARD_LOGGED" );

		return PLUGIN_CONTINUE;
   	}
   	else if ( hours < sRewardHoursPlayed )
   	{
   		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_REWARD_MIN_HOURS", sRewardHoursPlayed, sRewardHoursPlayed == 1 ? "" : "s" );

		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_REWARD_YOUR_HOURS", hours, hours == 1 ? "": "s", minutes, minutes == 1 ? "" : "s" );
   	}
   	else if ( iDay [id] != day )
   	{
      		switch ( random_num ( 1, 20 ) ) 
		{
			case 1..7: 
			{
              			new iPoints = random_num ( 5000, 15000 );

				new StrPoints [16];
	
				AddCommas ( iPoints, StrPoints, charsmax ( StrPoints ) );
               
				client_print_color ( id, id, "%s %L^4 :^3 %s Euro", CHAT_PREFIX, id, "CSGO_REWARD_MSG", StrPoints );
               					
				iUserPoints [id] += iPoints;
           		}
           		case 8..12: 
			{
              			new iCases = random_num ( 1, 4 );
						
				new Num = random_num ( 1, ChestsNum -1 );

				iUserChests [id] [Num] += iCases;

				client_print_color ( id, id, "%s %L^4 :^3 %d %s [Chests]", CHAT_PREFIX, id, "CSGO_REWARD_MSG", iCases, ChestName [Num] );
           		}
           		case 13..17: 
			{
                		new iKeys = random_num ( 1, 4 );
						
				new Num = random_num ( 1, ChestsNum -1 );

				iUserKeys [id] [Num] += iKeys;    
						
				client_print_color ( id, id, "%s %L^4 :^3 %d %s [Keys]", CHAT_PREFIX, id, "CSGO_REWARD_MSG", iKeys, ChestName [Num] );
           		}
			case 18..20:
			{
				new iDusts = random_num ( 5, 15 );

				iUserDusts [id] += iDusts;
					
				client_print_color ( id, id, "%s %L^4 :^3 %d dusts", CHAT_PREFIX, id, "CSGO_REWARD_MSG", iDusts );          
 			}
       		}

       		iDay [id] = day;  

       		SaveData ( id )
   	}
    	else 
	{
       		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_REWARD_PICKUP" );
   	}

   	return PLUGIN_HANDLED;
}

public GamesMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );
        
		return DestroyMenu ( Menu );
	}
	
	switch ( Item )
	{
		case 0: ShowTombolaMenu ( id );
		case 1:
		{
			if ( bRouletteWork )
			{
				ShowRouletteMenu ( id );
			}
			else
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_ROULETTE_CLOSED" );
			}
		}
		case 2:
		{
			if ( bJackpotWork )
			{
				ShowJackpotMenu ( id );
			}
			else
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_JP_CLOSED", sJackpotTimer );
			}
		}
		case 3:
		{
			if ( bBattleWork )
			{
				ShowBattleMenu ( id );
			}
			else
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BATTLE_CLOSED", sBattleTimer );
			}
		}
		case 4:
		{
			if ( bGuessNumWork )
			{
				new StrPoints [16];

				AddCommas ( sGuessNumberEarn + sGuessNumberCost, StrPoints, charsmax ( StrPoints ) );

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GUESS_DESCRIPTION_1", 1, 8 );
		
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GUESS_DESCRIPTION_2", StrPoints );

				ShowGuessMenu ( id );
			}
			else
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GUESS_IS_CLOSED" );

				return PLUGIN_HANDLED;
			}
		}
		case 5:
		{
			if ( is_user_alive ( id ) )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BET_TEAM_ALIVE" );
	
				return PLUGIN_HANDLED;
			}
			else
			{
				ShowBetTeamMenu ( id );
			}
		}
				
		default:  {  }
	}
	
	return DestroyMenu ( Menu );
}

ShowTombolaMenu ( id )
{
	new Temp [64];

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d] \y%L", id, "CSGO_TOMBOLA_MENU");

	new Menu = menu_create ( Temp, "TombolaMenuHandler", 0 );

	new Timer [32];

	FormatTime ( Timer, charsmax ( Timer ), iNextTombolaStart );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_TOMB_TIMER", Timer );

	menu_additem ( Menu, Temp, "0", 0 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_TOMB_PLAYERS", iTombolaPlayers );
	
	menu_additem ( Menu, Temp, "0", 0 );

	new StrPoints1 [16];

	AddCommas ( iTombolaPrize, StrPoints1, charsmax ( StrPoints1 ) );

	formatex ( Temp, charsmax ( Temp ), "\w%L^n", id, "CSGO_TOMB_PRIZE", StrPoints1 );

	menu_additem ( Menu, Temp, "0", 0 );

	if ( bUserPlay [id] )
	{
		formatex ( Temp, charsmax ( Temp ), "\r%L", id, "CSGO_TOMB_ALREADY_PLAY" );
	
		menu_additem ( Menu, Temp, "0", 0 );
	}
	else
	{
		new StrPoints2 [16];

		AddCommas ( sTombolaCost, StrPoints2, charsmax ( StrPoints2 ) );

		formatex ( Temp, charsmax ( Temp ), "\r%L\w [\d%L:\r %s]", id, "CSGO_TOMB_PLAY", id, "CSGO_TOMB_COST", StrPoints2 );
		
		menu_additem ( Menu, Temp, "1", 0 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public TombolaMenuHandler ( id, Menu, Item ) 
{
	if ( Item == MENU_EXIT )
	{
		ShowGamesMenu ( id );

		return DestroyMenu ( Menu );
	}

	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );

	switch ( Index )
	{
		case 0:
		{
			ShowTombolaMenu ( id );
		}
		case 1:
		{
			if ( iUserPoints [id] < sTombolaCost )
			{
				new rPoints = sTombolaCost - iUserPoints [id];
				
				new StrPoints [16];

				AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );

				ShowTombolaMenu ( id );

				return DestroyMenu ( Menu );
			}

			iUserPoints [id] -= sTombolaCost;

			iTombolaPrize = sTombolaCost + iTombolaPrize;

			bUserPlay [id] = true;

			ArrayPushCell ( aTombola, id );

			iTombolaPlayers += 1;

			client_print_color ( 0, id, "%s %L", CHAT_PREFIX, -1, "CSGO_TOMB_ANNOUNCE", Name [id] );
				
			ShowTombolaMenu ( id) ;
		}

		default: {  }
	}

	return DestroyMenu ( Menu );
}

public TaskTombolaRun ( Task )
{
	if ( iTombolaPlayers < 1 )
	{
		ClearTombola (  );

		return PLUGIN_CONTINUE
	}
	else
	{
		if ( iTombolaPlayers < 2 )
		{
			new id = ArrayGetCell ( aTombola, 0 );

			if ( is_user_connected ( id ) )
			{
				iUserPoints [id] += sTombolaCost;

				//bUserPlay [id] = false;
			}

			ClearTombola (  );

			return PLUGIN_CONTINUE;
		}
		else
		{
			new id;
			new Size = ArraySize ( aTombola );
			new bool: Succes = false;
			new Random = 0;
			new StrPoints [16];

			do 
			{
				Random = random_num ( 0, Size -1 );

				id = ArrayGetCell ( aTombola, Random );

				if ( is_user_connected ( id ) )
				{
					Succes = true;

					iUserPoints [id] += iTombolaPrize;

					AddCommas ( iTombolaPrize, StrPoints, charsmax ( StrPoints ) );

					client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_TOMB_WINNER", Name [id], StrPoints );
				}
				else
				{
					ArrayDeleteItem ( aTombola, Random );
				
					Size--;
				}
			} 
			while ( !Succes && Size > 0 );
		}
	}

	ClearTombola (  );

	return PLUGIN_CONTINUE;
}

ClearTombola (  )
{
	arrayset ( bUserPlay, false, 33 );

	iTombolaPlayers = 0;

	iTombolaPrize = 0;

	ArrayClear ( aTombola );

	iNextTombolaStart = sTombolaTimer + get_systime (  );

	/*new Timer [32];

	FormatTime ( Timer, charsmax ( Timer ), iNextTombolaStart );

	client_print_color ( 0, 0, "%s Raffle^3 :^1 %L", CHAT_PREFIX, -1, "CSGO_TOMB_NEXT", Timer );*/
}

public ShowRouletteMenu ( id )
{
	static Line [1280];

	if ( !iRouletteBet [id] [0] && !iRouletteBet [id] [1] && !iRouletteBet [id] [2] )
	{
		if ( iRoulettePlayers >= 1 && iRouletteTimer >= 10 )
		{
			formatex ( Line, charsmax ( Line ), "\wRoulette \d[\r%i\y euros\d]^n\wLast digits:\y %s %s %s %s %s %s %s^n\wStarts in %i", iUserPoints [id], iRouletteNr [0], iRouletteNr [1], iRouletteNr [2], iRouletteNr [3], iRouletteNr [4], iRouletteNr [5], iRouletteNr [6], iRouletteTimer );
		}
		else
		{
			formatex ( Line, charsmax ( Line ), "Roulette \d[\r%i\y euros\d]^n\wUltimele cifre:\y %s %s %s %s %s %s %s^n\wDecision", iUserPoints [id], iRouletteNr [0], iRouletteNr [1], iRouletteNr [2], iRouletteNr [3], iRouletteNr [4], iRouletteNr [5], iRouletteNr[6] );
		}
	}
	else
	{
		if ( iRoulettePlayers >= 1 && iRouletteTimer >= 10 )
		{
			formatex ( Line, charsmax ( Line ), "Roulette \d[\r%i\y euros\d]^n\wLast digits:\y %s %s %s %s %s %s %s^n\rRed %d\w -\y Yellow %d\w -\d Grey %d^n\wStarts in %i", iUserPoints [id], iRouletteNr [0], iRouletteNr [1], iRouletteNr [2], iRouletteNr [3], iRouletteNr [4], iRouletteNr [5], iRouletteNr [6], iRouletteBet [id] [0], iRouletteBet [id] [1], iRouletteBet [id] [2], iRouletteTimer );
		}
		else
		{
			formatex ( Line, charsmax ( Line ), "Roulette \d[\r%i\y euros\d]^n\wLast digits: %s %s %s %s %s %s %s^n\w\rRed %d\w -\y Yellow %d\w -\d Grey %d^nDecision...", iUserPoints [id], iRouletteNr [0], iRouletteNr [1], iRouletteNr [2], iRouletteNr [3], iRouletteNr [4], iRouletteNr [5], iRouletteNr [6],iRouletteBet [id] [0], iRouletteBet [id] [1], iRouletteBet [id] [2] );
		}
	}

	new Menu = menu_create ( Line, "RouletteMenuHandler" );

	new a, b, c;

	for ( new i = 1; i <= MaxPlayers; i ++ )
	{
		if ( is_user_connected ( i ) )
		{
			a += iRouletteBet [i] [0];

			b += iRouletteBet [i] [1];

			c += iRouletteBet [i] [2];
		}
	}

	if ( iRouletteTimer >= 10 )
	{
		formatex ( Line, charsmax ( Line ), "\rRed\w 2x\d (1,2,3,4,5,6,7)\w - %d", a );

		menu_additem ( Menu, Line, "" );

		formatex ( Line, charsmax ( Line ), "\yYellow\w 7x\d (0)\w - %d", b );

		menu_additem ( Menu, Line, "" );

		formatex ( Line, charsmax ( Line ), "\dGrey\w 2x\d (8,9,10,11,12,13,14)\w - %d^n", c );

		menu_additem ( Menu, Line, "" );
	}
	else
	{
		formatex ( Line, charsmax ( Line ), "\rRed\w 2x\d (1,2,3,4,5,6,7)\w - %d", a );

		menu_additem ( Menu, Line, "-10" );

		formatex ( Line, charsmax ( Line ), "\yYellow\w 7x\d (0)\w - %d", b );

		menu_additem ( Menu, Line, "-10" );

		formatex ( Line, charsmax ( Line ), "\dGrey\w 2x\d (8,9,10,11,12,13,14)\w - %d^n", c );

		menu_additem ( Menu, Line, "-10" );
	}

	menu_additem ( Menu, "Refresh", "" );

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;
}

public RouletteMenuHandler ( id, Menu, Item ) 
{ 
	if ( Item == MENU_EXIT ) 
	{
		return DestroyMenu ( Menu );
	}
	
	switch ( Item )
	{
		case -10:
		{
			client_print_color ( id, id, "%s You don't have enough euros!", CHAT_PREFIX );

			return DestroyMenu ( Menu );
		}
		case 0, 1, 2:
		{
			iRouletteType [id] = Item;

			client_cmd ( id, "messagemode Bet" );
		}
		case 3:
		{
			ShowRouletteMenu ( id );
		}
	}

	return DestroyMenu ( Menu );
}

public BetRoulette ( id )
{
	if ( !bRouletteWork || !iLogged [id] || iRouletteBet [id] [0] > 0 ||  iRouletteBet [id] [1] > 0 ||  iRouletteBet [id] [2] > 0 || iRouletteTimer < 11 )

		return PLUGIN_HANDLED;
		
	new Data [32], Cost;

	read_args ( Data, charsmax ( Data ) );

	remove_quotes ( Data );
	
	Cost = str_to_num ( Data );
	
	if ( Cost < 0 || Cost > iUserPoints [id] || Cost == 0 )
	{
		client_cmd ( id, "messagemode Bet");

		return PLUGIN_HANDLED;
	}

	if ( Cost > sRouletteBetLimit )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BET_LIMIT", sRouletteBetLimit )

		client_cmd ( id, "messagemode Bet" );

		return PLUGIN_HANDLED;
	}

	iRouletteBet [id] [iRouletteType [id]] = Cost;
		
	iUserPoints [id] -= Cost;

	SaveData ( id )

	ShowRouletteMenu ( id );

	iRoulettePlayers ++;

	if ( iRoulettePlayers == 1 && iRouletteTimer == 60 )

		TaskPlayRoulette (  );

	return PLUGIN_HANDLED;
}

public TaskPlayRoulette (  )
{
	iRouletteTimer = 60;

	client_print_color ( 0, 0, "%s The roulette started", CHAT_PREFIX );

	set_task ( 1.0, "DrawRoulette", 1534554, _, _, "b" );
}

public DrawRoulette (  )
{
	/*if ( iRoulettePlayers < 1 )
	{
		remove_task ( 1534554 );
	}*/
	if ( iRouletteTimer != 0 )
	{
		iRouletteTimer -= 1;
	}
	else
	{
		new a = random_num ( 0, 14 );

		if ( a < 8 && a > 0 )
		{
			formatex ( iRouletteNr [6], charsmax ( iRouletteNr ), "%s", iRouletteNr [5] );
			formatex ( iRouletteNr [5], charsmax ( iRouletteNr ), "%s", iRouletteNr [4] );
			formatex ( iRouletteNr [4], charsmax ( iRouletteNr ), "%s", iRouletteNr [3] );
			formatex ( iRouletteNr [3], charsmax ( iRouletteNr ), "%s", iRouletteNr [2] );
			formatex ( iRouletteNr [2], charsmax ( iRouletteNr ), "%s", iRouletteNr [1] );
			formatex ( iRouletteNr [1], charsmax ( iRouletteNr ), "%s", iRouletteNr [0] );
			formatex ( iRouletteNr [0], charsmax ( iRouletteNr ), "\r%d", a );

			for ( new i = 1; i <= MaxPlayers; i ++ )
			{
				if ( is_user_connected ( i ) )
				{
					iRouletteBet [i] [0] *= 2;

					iRouletteBet [i] [1] = 0;

					iRouletteBet [i] [2] = 0;

					iUserPoints [i] += iRouletteBet [i] [0] + iRouletteBet [i] [1] + iRouletteBet [i] [2];

					iRouletteBet [i] [0] = 0;

					SaveData ( i )
				}
			}

			client_print_color ( 0, print_team_red, "%s The number drawn at the roulette is^3 %d red", CHAT_PREFIX, a );
		}
		else if ( a > 7 && a < 15 )
		{
			formatex ( iRouletteNr [6], charsmax ( iRouletteNr ), "%s", iRouletteNr [5] );
			formatex ( iRouletteNr [5], charsmax ( iRouletteNr ), "%s", iRouletteNr [4] );
			formatex ( iRouletteNr [4], charsmax ( iRouletteNr ), "%s", iRouletteNr [3] );
			formatex ( iRouletteNr [3], charsmax ( iRouletteNr ), "%s", iRouletteNr [2] );
			formatex ( iRouletteNr [2], charsmax ( iRouletteNr ), "%s", iRouletteNr [1] );
			formatex ( iRouletteNr [1], charsmax ( iRouletteNr ), "%s", iRouletteNr [0] );
			formatex ( iRouletteNr [0], charsmax ( iRouletteNr ), "\d%d", a );

			for ( new i = 1; i <= MaxPlayers; i ++ )
			{
				if ( is_user_connected ( i ) )
				{
					iRouletteBet [i] [0] = 0;
					
					iRouletteBet [i] [1] = 0;

					iRouletteBet [i] [2] *= 2;

					iUserPoints [i] += iRouletteBet [i] [0] + iRouletteBet [i] [1] + iRouletteBet [i] [2]
					
					iRouletteBet [i] [2] = 0;
					
					SaveData ( i );
				}
			}

			client_print_color ( 0, print_team_grey, "%s The number drawn at the roulette is^3 %d grey", CHAT_PREFIX, a );
		}
		else if(a == 0)
		{
			formatex ( iRouletteNr [6], charsmax ( iRouletteNr ), "%s", iRouletteNr [5] );
			formatex ( iRouletteNr [5], charsmax ( iRouletteNr ), "%s", iRouletteNr [4] );
			formatex ( iRouletteNr [4], charsmax ( iRouletteNr ), "%s", iRouletteNr [3] );
			formatex ( iRouletteNr [3], charsmax ( iRouletteNr ), "%s", iRouletteNr [2] );
			formatex ( iRouletteNr [2], charsmax ( iRouletteNr ), "%s", iRouletteNr [1] );
			formatex ( iRouletteNr [1], charsmax ( iRouletteNr ), "%s", iRouletteNr [0] );
			formatex ( iRouletteNr [0], charsmax ( iRouletteNr ), "\y%d", a );

			for ( new i = 1; i <= MaxPlayers; i ++ )
			{
				if ( is_user_connected ( i ) )
				{
					iRouletteBet [i] [0] = 0;
					
					iRouletteBet [i] [1] *= 7;

					iRouletteBet [i] [2] = 0;

					iUserPoints [i] += iRouletteBet [i] [0] + iRouletteBet [i] [1] + iRouletteBet [i] [2]
					
					iRouletteBet [i] [1] = 0;
					
					SaveData ( i );
				}
			}

			client_print_color ( 0, 0, "%s The number drawn at the roulette is %d yellow", CHAT_PREFIX, a );
		}

		iRoulettePlayers = 0;

		remove_task ( 1534554 );

		bRouletteWork = false;

		set_task ( 300.0, "TaskRouletteWork", 13231 );
	}
}

public TaskRouletteWork (  )
{
	bRouletteWork = true;

	iRouletteTimer = 60;
}

ShowJackpotMenu ( id )
{
	new Temp [64];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_JACKPOT_MENU" );
	
	new Menu = menu_create ( Temp, "JackpotMenuHandler", 0 );

	if ( iUserJackpotItem [id] < 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r N/A", id, "CSGO_GIFT_ITEM");

		menu_additem ( Menu, Temp, "1", 0 );
	}
	else
	{
		new xItem [128];
		
		GetItemName ( id, iUserJackpotItem [id], xItem, charsmax ( xItem ) );

		formatex ( Temp, charsmax ( Temp ), "\w%L:\r %s", id, "CSGO_GIFT_ITEM", xItem );

		menu_additem ( Menu, Temp, "1", 0 );
	}

	if ( bUserPlayJackpot [id] )
	{
		formatex ( Temp, charsmax ( Temp ), "\r%L^n", id, "CSGO_JP_ALREADY_PLAY" );

		menu_additem ( Menu, Temp, "0", 0 );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "\r%L^n", id, "CSGO_JP_PLAY" );

		menu_additem ( Menu, Temp, "2" );
	}

	new Timer [32];
	
	FormatTime ( Timer, charsmax ( Timer ), iJackpotClose );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_TOMB_TIMER", Timer );

	menu_additem ( Menu, Temp, "0", 0 );

	DisplayMenu ( id, Menu );
}

public JackpotMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowGamesMenu ( id );

		return DestroyMenu ( Menu );
	}

	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );

	if ( !bJackpotWork )
	{
		ShowGamesMenu ( id );

		return DestroyMenu ( Menu );
	}

	switch ( Index )
	{
		case 0:
		{
			ShowJackpotMenu ( id );
		}
		case 1:
		{
			if ( bUserPlayJackpot [id] )
			{
				ShowJackpotMenu ( id );
			}
			else
			{
				SelectJackpotSkin ( id );
			}
		}
		case 2:
		{
			if ( iUserJackpotItem [id] == -1 )
			{
				ShowJackpotMenu ( id );

				return DestroyMenu ( Menu );
			}

			if ( iUserJackpotItem [id] < 1 || !UserHasItem ( id, iUserJackpotItem [id] ) )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_ITEMS" );
					
				iUserJackpotItem [id] = -1;

				ShowJackpotMenu ( id );

				return DestroyMenu ( Menu );
			}

			if ( iUserJackpotItem [id] == iUserSellItem [id] && iUserSell [id] || iUserJackpotItem [id] == iTradeItem [id] && bTradeActive [id] )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_CANT_GIVE" );
						
				ShowJackpotMenu ( id );

				return DestroyMenu ( Menu );
			}

			bUserPlayJackpot [id] = true;

			if ( iUserJackpotItem [id] >= 7000 )
			{
				for ( new sID = 0; sID < 25; sID ++ )
				{
					if ( iUserJackpotItem [id] - 7000 == iUserSelectedSkin [id] [sID] )
					{
						iUserSelectedSkin [id] [sID] = 0;
					}
				}

				iUserSkins [id] [iUserJackpotItem [id]-7000] --;

				iUserSTs [id] [iUserJackpotItem [id]-7000] --;

				if ( iUserSTs [id] [iUserJackpotItem [id]-7000] < 1 )

					STKills [id] [iUserJackpotItem [id]-7000] = 0;
			}
			else
			{
				for ( new sID = 0; sID < 25; sID ++ )
				{
					if ( iUserJackpotItem [id] == iUserSelectedSkin [id] [sID] )
					{
						iUserSelectedSkin [id] [sID] = 0;
					}
				}

				iUserSkins [id] [iUserJackpotItem [id]]--;
			}

			ArrayPushCell ( aJackpotSkins, iUserJackpotItem [id] );

			ArrayPushCell ( aJackpotUsers, id );

			new xItem [128];

			GetItemName ( id, iUserJackpotItem [id], xItem, charsmax ( xItem ) );

			client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_JP_JOIN", Name [id], xItem );
		}
	}

	return DestroyMenu ( Menu );
}

SelectJackpotSkin ( id )
{
	new Temp [64];

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_SKINS_MENU" );
	
	new Menu = menu_create ( Temp, "JPSkinsMenuHandler", 0 );

	new String [32], bool: HasSkins = false;

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( iUserSTs [id] [i] )
		{
			new wID = i + 7000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s\y [\rStatTrak\y]\d (%d)", SkinName [i], iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}

		if ( iUserSkins [id] [i] > iUserSTs [id] [i] )
		{
			num_to_str ( i, String, charsmax ( String ) );

			formatex ( Temp, charsmax ( Temp ), "%s\y [\r%s\y]\d (%d)", SkinName [i], GetSkinClass ( i ), iUserSkins [id] [i] - iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	if ( !HasSkins )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;	
}

public JPSkinsMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowJackpotMenu ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	if ( Item == -10 )
	{
		ShowGamesMenu ( id );

		return DestroyMenu ( Menu );	
	}

	iUserJackpotItem [id] = Item;

	ShowJackpotMenu ( id );

	return DestroyMenu ( Menu );
}

public TaskJackpotRun ( Task )
{
	if ( !bJackpotWork )
	{
		return PLUGIN_CONTINUE;
	}

	new id;

	new Size = ArraySize ( aJackpotUsers );
	
	if ( Size < 1 )
	{
		ClearJackpot (  );
		
		return PLUGIN_CONTINUE;
	}
	if ( Size < 2)
	{
		new k;

		new id = ArrayGetCell ( aJackpotUsers, 0 );
		
		if ( is_user_connected ( id ) )
		{
			k = ArrayGetCell ( aJackpotSkins, 0 );
			
			if ( k >= 7000 )
			{
				iUserSkins [id] [k-7000] ++;

				iUserSTs [id] [k-7000] ++;
			}
			else
			{
				iUserSkins [id] [k] ++;
			}
		}
		
		ClearJackpot (  );
		
		return PLUGIN_CONTINUE;
	}

	new bool: Succes, Random;

	do 
	{
		Random = random_num ( 0, Size -1 );

		id = ArrayGetCell ( aJackpotUsers, Random );

		if ( is_user_connected ( id ) )
		{
			Succes = true;

			new i, j, k;

			i = ArraySize ( aJackpotSkins );
			
			j = 0;

			while ( j < i )
			{
				k = ArrayGetCell ( aJackpotSkins, j );
				
				if ( k >= 7000 )
				{
					iUserSkins [id] [k-7000] ++;

					iUserSTs [id] [k-7000] ++;
				}
				else
				{
					iUserSkins [id] [k] ++;
				}
				
				j ++;
			}

			client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_JP_WINNER", Name [id] );
		}
		else
		{
			ArrayDeleteItem ( aJackpotUsers, Random );
			
			Size--;
		}
	} 

	while ( !Succes && Size > 0 )	

	ClearJackpot (  );

	return PLUGIN_CONTINUE;
}

ClearJackpot (  )
{
	remove_task ( 10000 );

	ArrayClear ( aJackpotSkins );

	ArrayClear ( aJackpotUsers );

	arrayset ( bUserPlayJackpot, 0, sizeof ( bUserPlayJackpot ) );

	bJackpotWork = false;

	arrayset ( iUserJackpotItem, -1, sizeof ( iUserJackpotItem ) );

	//client_print_color ( 0, 0, "^4%s^1 %L", CHAT_PREFIX, -1, "CSGO_JP_NEXT" );
}

ShowBattleMenu ( id )
{
	new Temp [64];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_BATTLE_MENU" );
	
	new Menu = menu_create ( Temp, "BattleMenuHandler", 0 );

	if ( iBattleItem [id] < 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r N/A", id, "CSGO_GIFT_ITEM");

		menu_additem ( Menu, Temp, "1", 0 );
	}
	else
	{
		new xItem [128];
		
		GetItemName ( id, iBattleItem [id], xItem, charsmax ( xItem ) );

		formatex ( Temp, charsmax ( Temp ), "\w%L:\r %s", id, "CSGO_GIFT_ITEM", xItem );

		menu_additem ( Menu, Temp, "1", 0 );
	}

	if ( bUserPlayBattle [id] )
	{
		formatex ( Temp, charsmax ( Temp ), "\r%L^n", id, "CSGO_JP_ALREADY_PLAY" );

		menu_additem ( Menu, Temp, "0", 0 );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "\r%L^n", id, "CSGO_JP_PLAY" );

		menu_additem ( Menu, Temp, "2" );
	}

	new Timer [32];
	
	FormatTime ( Timer, charsmax ( Timer ), iBattleClose );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_TOMB_TIMER", Timer );

	menu_additem ( Menu, Temp, "0", 0 );

	DisplayMenu ( id, Menu );
}

public BattleMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowGamesMenu ( id );

		return DestroyMenu ( Menu );
	}

	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );

	if ( !bBattleWork )
	{
		ShowGamesMenu ( id );

		return DestroyMenu ( Menu );
	}

	switch ( Index )
	{
		case 0:
		{
			ShowBattleMenu ( id );
		}
		case 1:
		{
			if ( bUserPlayBattle [id] )
			{
				ShowBattleMenu ( id );
			}
			else
			{
				SelectBattleCases ( id );
			}
		}
		case 2:
		{
			if ( iBattleItem [id] == -1 )
			{
				ShowBattleMenu ( id );

				return DestroyMenu ( Menu );
			}

			if ( iBattleItem [id] < 1 || !UserHasItem ( id, iBattleItem [id] ) )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_ITEMS" );
					
				iBattleItem [id] = -1;

				return DestroyMenu ( Menu );
			}

			if ( iBattleItem [id] == iUserSellItem [id] && iUserSell [id] || iBattleItem [id] == iTradeItem [id] && bTradeActive [id] )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_CANT_GIVE" );
						
				ShowBattleMenu ( id );

				return DestroyMenu ( Menu );
			}

			new Chest = iBattleItem [id] - 2000;

			bUserPlayBattle [id] = true;

			iUserChests [id] [Chest] --;

			ArrayPushCell ( aBattleCases, iBattleItem [id] );

			ArrayPushCell ( aBattleUsers, id );

			new xItem [128];

			GetItemName ( id, iBattleItem [id], xItem, charsmax ( xItem ) );

			client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_BATTLE_JOIN", Name [id], xItem );
		}
	}

	return DestroyMenu ( Menu );
}

SelectBattleCases ( id )
{
	new Temp [96];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_CHESTS_MENU" );
	
	new Menu = menu_create ( Temp, "bCasesMenuHandler", 0 );
	
	new bool: HasChests = false, String [32];
	
	for ( new i = 1; i < ChestsNum; i ++ )
	{
		if ( iUserChests [id] [i] != 0 )
		{
			new wID = i + 2000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s", ChestName [i] );

			menu_additem ( Menu, Temp, String );

			HasChests = true;
		}
	}

	if ( !HasChests )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_CHESTS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;                                                                                
}

public bCasesMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowItems ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );

	switch ( Item )
	{
		case -10:
		{
			if ( Item == -10 )
			{
				ShowBattleMenu ( id );
			
				return DestroyMenu ( Menu );
			}
		}
		default:
		{
			iBattleItem [id] = Item;

			ShowBattleMenu ( id );
		}
	}

	return DestroyMenu ( Menu );
}

public TaskBattleRun ( Task )
{
	if ( !bBattleWork )
	{
		return PLUGIN_CONTINUE;
	}

	new id;

	new Size = ArraySize ( aBattleUsers );
	
	if ( Size < 1 )
	{
		ClearBattle (  );
		
		return PLUGIN_CONTINUE;
	}
	if ( Size < 2)
	{
		new k;

		new id = ArrayGetCell ( aBattleUsers, 0 );
		
		if ( is_user_connected ( id ) )
		{
			k = ArrayGetCell ( aBattleCases, 0 );
			
			iUserChests [id] [k-2000] ++;
		}
		
		ClearBattle (  );
		
		return PLUGIN_CONTINUE;
	}

	new bool: Succes, Random;

	do 
	{
		Random = random_num ( 0, Size -1 );

		id = ArrayGetCell ( aBattleUsers, Random );

		if ( is_user_connected ( id ) )
		{
			Succes = true;

			new i, j, k;

			i = ArraySize ( aBattleCases );
			
			j = 0;

			while ( j < i )
			{
				k = ArrayGetCell ( aBattleCases, j );
				
				iUserChests [id] [k-2000] ++;
				
				j ++;
			}

			client_print_color ( 0, 0, "%s %L", CHAT_PREFIX, -1, "CSGO_BATTLE_WINNER", Name [id] );
		}
		else
		{
			ArrayDeleteItem ( aBattleUsers, Random );
			
			Size--;
		}
	} 
	while ( !Succes && Size > 0 )	

	ClearBattle (  );

	return PLUGIN_CONTINUE;
}

ClearBattle (  )
{
	remove_task ( 20000 );

	ArrayClear ( aBattleCases );

	ArrayClear ( aBattleUsers );

	arrayset ( bUserPlayBattle, 0, sizeof ( bUserPlayBattle ) );

	bBattleWork = false;

	arrayset ( iBattleItem, -1, sizeof ( iBattleItem ) );
}

public ShowGuessMenu ( id )
{
	new Temp [96], StrPoints [16];

	AddCommas ( sGuessNumberCost, StrPoints, charsmax ( StrPoints ) );

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L^n\r%L", id, "CSGO_GUESS_JOIN_1", StrPoints, id, "CSGO_GUESS_JOIN_2" );

	new Menu = menu_create ( Temp, "GuessMenuHandler", 0 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_GUESS_YES" );
	
	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_GUESS_NO" );
	
	menu_additem ( Menu, Temp, "", 0, -1 );

	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public GuessMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowGamesMenu ( id );
        
		return DestroyMenu ( Menu );
	}
	
	switch ( Item )
	{
		case 0:
		{
			client_cmd ( id, "messagemode GuessTheNumber" );
		}
		case 1:
		{
			ShowGamesMenu ( id );
		}
	}

	return DestroyMenu ( Menu );
}

public InputNumber ( id )
{
	if ( !iLogged [id] )

		return PLUGIN_HANDLED;
		
	new Data [32], Number;

	read_args ( Data, charsmax ( Data ) );

	remove_quotes ( Data );
	
	Number = str_to_num ( Data );

	if ( !bGuessNumWork )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GUESS_IS_CLOSED");

		return PLUGIN_HANDLED;
	}
	
	if ( sGuessNumberCost > iUserPoints [id] )
	{
		new rPoints = sGuessNumberCost - iUserPoints [id];

		new StrPoints [16];

		AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );	

		return PLUGIN_HANDLED;
	}

	if ( Number < 1 || Number > 8 )
	{
		client_cmd ( id, "messagemode GuessTheNumber" );

		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GUESS_NUMBER_INVALID", 1, 8 );

		return PLUGIN_HANDLED;
	}

	iUserPoints [id] -= sGuessNumberCost;

	client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GUESS_NUMBER_CHOOSED", Number );

	GuessNumberRun ( id, Number );

	return PLUGIN_HANDLED;
}

public ShowBetTeamMenu ( id )
{
	if ( bUserBet [id] )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_ALREADY_BET", SelectBetTeam [id] == 1 ? "T" : "CT" );

		return PLUGIN_HANDLED;
	}

	new Temp [96];

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_BET_TEAM" );

	new Menu = menu_create ( Temp, "BetTeamMenuHandler", 0 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_BET_T_TEAM" );
	
	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_BET_CT_TEAM" );
	
	menu_additem ( Menu, Temp, "", 0, -1 );

	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public BetTeamMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowGamesMenu ( id );
        
		return DestroyMenu ( Menu );
	}
	
	if ( is_user_alive ( id ) )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BET_TEAM_ALIVE" );	

		return DestroyMenu ( Menu );
	}

	switch ( Item )
	{
		case 0:
		{
			SelectBetTeam [id] = 1;

			client_cmd ( id, "messagemode BetTeam" );
		}
		case 1:
		{
			SelectBetTeam [id] = 2;
			
			client_cmd ( id, "messagemode BetTeam" );
		}
	}

	return DestroyMenu ( Menu );
}

public InputValueBetTeam ( id )
{
	if ( !iLogged [id] || is_user_alive ( id ) || !SelectBetTeam [id] || bUserBet [id] || !BetWork )
		
		return PLUGIN_HANDLED;
		
	new Data [32], Value;

	read_args ( Data, charsmax ( Data ) );

	remove_quotes ( Data );
	
	Value = str_to_num ( Data );

	if ( SelectBetTeam [id] == 1 && GetAliveTs (  ) < sBetMinPlayersReq )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BET_MIN_PLAYERS_REQ", sBetMinPlayersReq );

		return PLUGIN_HANDLED;
	}
	else if ( SelectBetTeam [id] == 2 && GetAliveCTs (  ) < sBetMinPlayersReq )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BET_MIN_PLAYERS_REQ", sBetMinPlayersReq );

		return PLUGIN_HANDLED;
	}
	
	if ( Value < 0 || Value > iUserPoints [id] || Value == 0 )
	{
		client_cmd ( id, "messagemode BetTeam" );

		return PLUGIN_HANDLED;
	}

	if ( Value > sBetTeamLimit )
	{
		new a [16];

		AddCommas ( sBetTeamLimit, a, charsmax ( a ) );

		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MAX_BET_LIMIT", a);
	
		client_cmd ( id, "messagemode BetTeam" );
		
		return PLUGIN_HANDLED;
	}

	bUserBet [id] = true;

	BetValue [id] = Value;

	iUserPoints [id] -= Value;

	new StrPoints [16];

	AddCommas ( Value, StrPoints, charsmax ( StrPoints ) );

	client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BET_TEAM_BET", StrPoints, SelectBetTeam [id] == 1 ? "T" : "CT" );

	return PLUGIN_HANDLED;
}	

GetAliveCTs (  ) 
{
	static iCTs, id;

	iCTs = 0
	
	for ( id = 1; id <= MaxPlayers; id ++ )
	{
		if ( is_user_alive ( id ) )
		{			
			if ( cs_get_user_team ( id ) == CS_TEAM_CT )

				iCTs ++;
		}
	}
	
	return iCTs;
}

GetAliveTs (  )
{
	static iTs, id;

	iTs = 0
	
	for ( id = 1; id <= MaxPlayers; id ++ )
	{
		if ( is_user_alive ( id ) )
		{			
			if ( cs_get_user_team ( id ) == CS_TEAM_T )

				iTs ++;
		}
	}
	
	return iTs;
}
		
		
GuessNumberRun ( id, Num )
{
	new RNum = random_num ( 1, 8 );

	if ( Num == RNum )
	{
		new rPoints = sGuessNumberCost + sGuessNumberEarn;

		new StrPoints [16];

		AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

		iUserPoints [id] += rPoints	

		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GUESS_NUMBER_WIN", StrPoints );
	}
	else
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_GUESS_NUMBER_LOSE" );
	}
}

public TaskGuessNumberWork (  )
{
	if ( bGuessNumWork )
	{
		bGuessNumWork = false;
	}
	else
	{
		bGuessNumWork = true;
	}
}
	
ShowUpgradeMenu ( id )
{
	new Temp [64];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_UPGRADE_MENU" );
	
	new Menu = menu_create ( Temp, "UpgradeMenuHandler", 0 );

	if ( iUserUpgradeItem [id] < 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r N/A", id, "CSGO_GIFT_ITEM");

		menu_additem ( Menu, Temp, "", 0 );
	}
	else
	{
		new xItem [128];
		
		GetItemName ( id, iUserUpgradeItem [id], xItem, charsmax ( xItem ) );

		formatex ( Temp, charsmax ( Temp ), "\w%L:\r %s", id, "CSGO_GIFT_ITEM", xItem );

		menu_additem ( Menu, Temp, "", 0 );
	}

	if ( iUserUpgradeItem [id] < 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r N/A^n------------------------------^n", id, "CSGO_ITEM_PRICE" );

		menu_additem ( Menu, Temp, "", 0 );
	}
	else
	{
		new StrPoints [16];

		AddCommas ( SkinMaxPrice [iUserUpgradeItem [id]] * sUpgradeMultiplier, StrPoints, charsmax ( StrPoints ) );

		formatex ( Temp, charsmax ( Temp ), "\w%L:\r %s^n------------------------------^n", id, "CSGO_ITEM_PRICE", StrPoints );

		menu_additem ( Menu, Temp, "" );
	}

	if ( iUserUpgradeItem [id] > 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "\r%L", id, "CSGO_GO_UPGRADE" );

		menu_additem ( Menu, Temp, "" );
	}

	DisplayMenu ( id, Menu );
}

public UpgradeMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );

		return DestroyMenu ( Menu );
	}

	switch ( Item )
	{
		case 0:
		{
			SelectUpgradeSkin ( id );
		}
		case 1:
		{
			ShowUpgradeMenu ( id );
		}
		case 2:
		{
			new Skin = iUserUpgradeItem [id];

			if ( Skin < 1 || !UserHasItem ( id, Skin ) )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_ITEMS" );
					
				iUserUpgradeItem [id] = -1;

				return DestroyMenu ( Menu );
			}

			if ( iUserUpgradeItem [id] == iUserSellItem [id] && iUserSell [id] || iUserUpgradeItem [id] == iTradeItem [id] && bTradeActive [id] )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_CANT_GIVE" );
						
				ShowUpgradeMenu ( id );

				return DestroyMenu ( Menu );
			}

			if ( SkinMaxPrice [iUserUpgradeItem [id]] * sUpgradeMultiplier > iUserPoints [id] )
			{	
				new StrPoints [16];

				new rPoints = SkinMaxPrice [iUserUpgradeItem [id]] * sUpgradeMultiplier - iUserPoints [id];

				AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );

				ShowUpgradeMenu ( id );

				return DestroyMenu ( Menu );
			}

			if ( Skin < 7000 && iUserSkins [id] [Skin] > 0 )
			{
				new rNum = random_num ( 1, 100 );

				iUserPoints [id] -= SkinMaxPrice [Skin] * sUpgradeMultiplier;

				if ( rNum <= sUpgradeChance )
				{
					iUserSTs [id] [Skin] ++;

					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( Skin == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = Skin + 7000;
						}
					}

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_UPGRADE_SUCCESS", SkinName [Skin] );

					iUserUpgradeItem [id] = -1;
				}
				else
				{
					iUserSkins [id] [Skin] --;

					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( Skin == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_UPGRADE_FAIL" );

					iUserUpgradeItem [id] = -1;
				}
			}

			SaveData ( id );
		}
	}

	return DestroyMenu ( Menu );
}

SelectUpgradeSkin ( id )
{
	new Temp [64];

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_SKINS_MENU" );
	
	new Menu = menu_create ( Temp, "SUpMenuHandler", 0 );

	new String [32], bool: HasSkins = false;

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( iUserSkins [id] [i] > iUserSTs [id] [i] )
		{
			num_to_str ( i, String, charsmax ( String ) );

			formatex ( Temp, charsmax ( Temp ), "%s\y [\r%s\y]\d (%d)", SkinName [i], GetSkinClass ( i ), iUserSkins [id] [i] - iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	if ( !HasSkins )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;	
}     

public SUpMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowUpgradeMenu ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	if ( Item == -10 )
	{
		ShowGamesMenu ( id );

		return DestroyMenu ( Menu );	
	}

	iUserUpgradeItem [id] = Item;

	ShowUpgradeMenu ( id );

	return DestroyMenu ( Menu );
}                                                                                                 

FormatTime ( Timer [ ], Len, NextEvent )
{
	new iSeconds = NextEvent - get_systime (  );

	new iMinutes;

	while ( iSeconds >= 60 )
	{
		iSeconds -= 60;

		iMinutes ++;
	}

	new bool: AddBefore;

	new Temp [32];

	if ( iSeconds )
	{
		new iSecond [64];

		if ( iSeconds == 1 )
		{
			formatex ( iSecond, charsmax ( iSecond ), "second" );
		}
		else
		{
			formatex ( iSecond, charsmax ( iSecond ), "seconds" );
		}

		formatex ( Temp, charsmax ( Temp ), "%i %s", iSeconds, iSecond );

		AddBefore = true;
	}

	if ( iMinutes )
	{
		if ( AddBefore )
		{
			new iMinute [64];

			if ( iMinutes == 1 )
			{
				formatex ( iMinute, charsmax ( iMinute ), "minute" );
			}
			else
			{
				formatex ( iMinute, charsmax ( iMinute ), "minutes" );
			}

			format ( Temp, charsmax ( Temp ), "%i %s, %s", iMinutes, iMinute, Temp );
		}
		else
		{
			new iMinute [64];

			if ( iMinutes == 1 )
			{
				formatex ( iMinute, charsmax ( iMinute ), "minute" );
			}
			else
			{
				formatex ( iMinute, charsmax ( iMinute ), "minutes" );
			}
			
			formatex ( Temp, charsmax ( Temp ), "%i %s", iMinutes, iMinute );
			
			AddBefore = true;
		}
	}

	if ( !AddBefore )
	{
		copy ( Timer, Len, "Now!" );
	}
	else
	{
		formatex ( Timer, Len, "%s", Temp );
	}

	return PLUGIN_CONTINUE;
}


GetItemName ( id, gItem, fTemp [ ], len )
{
	if ( gItem == 4001 )
	{
		formatex ( fTemp, len, "%d points", SendQuantity [id] )
	}
	else if ( gItem == 4000 )
	{
		formatex ( fTemp, len, "%d dusts", SendQuantity [id] )
	}	
	else if ( gItem >= 17000 )
	{
		formatex ( fTemp, len, "[%s] %s [StatTrak]", SkinTagN [id] [gItem - 17000], SkinName [gItem - 17000] )
	}
	else if ( gItem >= 10000 )
	{
		formatex ( fTemp, len, "[%s] %s [%s]", SkinTagN [id] [gItem - 10000], SkinName [gItem - 10000], GetSkinClass ( gItem - 10000 ) )
	}
	else if ( gItem >= 7000 )
	{
		formatex ( fTemp, len, "%s [StatTrak]", SkinName [gItem - 7000] )
	}
	else if ( gItem >= 3000 )
	{
		formatex ( fTemp, len, "%s [Key]", ChestName [gItem - 3000] )
	}
	else if ( gItem >= 2500 )
	{
		formatex ( fTemp, len, "%s [Chest]", ChestName [gItem - 2500] )
	}
	else if ( gItem >= 2000 )
	{
		formatex ( fTemp, len, "%s", GloveName [gItem - 2000] )
	}
	else
	{
		formatex ( fTemp, len, "%s [%s]", SkinName [gItem], GetSkinClass ( gItem ) )
	}

	return 0;
}

bool: UserHasItem ( id, item )
{
	if ( item == 4001 )
	{
		if ( iUserPoints [id] >= SendQuantity [id] && SendQuantity [id] > 0 )
		{
			return true;
		}
	}
	else if ( item == 4000 )
	{
		if ( iUserDusts [id] >= SendQuantity [id] && SendQuantity [id] > 0 )
		{
			return true;
		}
	}
	else if ( item >= 17000 )
	{
		if ( SkinTag [id] [item-17000] > 0 )
		{
			return true;
		}
	}
	else if ( item >= 10000 )
	{
		if ( SkinTag [id] [item-10000] > 0 )
		{
			return true;
		}
	}
	else if ( item >= 7000 )
	{
		if ( iUserSTs [id] [item-7000] > 0 )
		{
			return true;
		}
	}
	else if ( item >= 3000 )
	{
		if ( iUserKeys [id] [item-3000] > 0 )
		{
			return true;
		}
	}
	else if ( item >= 2500 )
	{
		if ( iUserChests [id] [item-2500] > 0 )
		{
			return true;
		}
	}
	else if ( item >= 2000 )
	{
		if ( iUserGloves [id] [item-2000] > 0 )
		{
			return true;
		}
	}
	else
	{
		if ( iUserSkins [id] [item] > 0 )
		{
			return true;
		}
	}
	
	return false;
}

CalcItemPrice ( Item, &Min, &Max )
{
	if ( Item >= 17000 )
	{
		Min = SkinMinPrice [Item-17000] * sTagStatTrakCostMultiplier;

		Max = SkinMaxPrice [Item-17000] * sTagStatTrakCostMultiplier;
	}
	else if ( Item >= 10000 )
	{
		Min = SkinMinPrice [Item-10000] * sTagCostMultiplier;

		Max = SkinMaxPrice [Item-10000] * sTagCostMultiplier;
	}
	else if ( Item >= 7000 )
	{
		Min = SkinMinPrice [Item-7000] * sStatTrakCostMultiplier;

		Max = SkinMaxPrice [Item-7000] * sStatTrakCostMultiplier;
	}
	else if ( Item >= 3000 )
	{
		Min = ChestMinPrice [Item-3000];

		Max = ChestMaxPrice [Item-3000];
	}
	else if ( Item >= 2500 )
	{
		Min = ChestMinPrice [Item-2500];

		Max = ChestMaxPrice [Item-2500];
	}
	else if ( Item >= 2000 )
	{
		Min = GloveMinPrice [Item-2000];

		Max = GloveMaxPrice [Item-2000];
	}
	else 
	{
		Min = SkinMinPrice [Item];

		Max = SkinMaxPrice [Item];
	}
}

public CmdItemPrice ( id )
{
	if ( iUserSellItem [id] < 0 )
	{
		return PLUGIN_HANDLED;
	}

	new uPrice [32];
	
	read_args ( uPrice, charsmax ( uPrice ) );
   
	remove_quotes ( uPrice );
	
	new wPriceMin, wPriceMax;
         
	CalcItemPrice ( iUserSellItem [id], wPriceMin, wPriceMax );
	
	new nPrice = str_to_num ( uPrice );

	if ( !nPrice )
	{
		client_cmd ( id, "messagemode ItemPrice" );

		return PLUGIN_HANDLED;
	}
	
	if ( wPriceMin > nPrice || wPriceMax < nPrice )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_ITEM_MIN_MAX_PRICE", wPriceMin, wPriceMax );
		
		client_cmd ( id, "messagemode ItemPrice" );
		
		return PLUGIN_HANDLED;
	}
    
	iUserItemPrice [id] = nPrice;
    
	ShowMarketMenu ( id );
    
	return PLUGIN_HANDLED;
}

public ShowShopMenu ( id )
{
	new Temp [96]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_SHOP_MENU" );
	
	new Menu = menu_create ( Temp, "ShopMenuHandler", 0 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_SM_BUY_SKINTAG" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_SM_RENAME_SKINTAG" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	new StrPoints1 [16], StrPoints2 [16], Tag1 [16], Tag2 [16];

	AddCommas ( sBuyChatTag * 2, StrPoints1, charsmax ( StrPoints1 ) );
   
	AddCommas ( sBuyChatTag, StrPoints2, charsmax ( StrPoints2 ) );

	formatex ( Tag1, charsmax ( Tag1 ), "%L", id, "CSGO_BUY_CHAT_TAG" );

	formatex ( Tag2, charsmax ( Tag2 ), "%L", id, "CSGO_CHANGE_CHAT_TAG" );

	formatex ( Temp, charsmax ( Temp ), "\w%s\y (\r%s Euro\y)", PlayerHasTag [id] ? Tag2 : Tag1, PlayerHasTag [id] ? StrPoints1 : StrPoints2 );
	
	menu_additem ( Menu, Temp, "", 0, -1 );
	
	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_MM_BUY_CK" );

	menu_additem ( Menu, Temp, "", 0, -1 );

	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public ShopMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );
		
		return DestroyMenu ( Menu );
	}
   
	switch ( Item )
	{
		case 0:
		{
			ShowBuySkinTag ( id );
		}
		case 1:
		{
			ShowReNameSkinTag ( id );
		}
		case 2:
		{
			if ( PlayerHasTag [id] )
			{
				if (  sBuyChatTag * 2 > iUserPoints [id] )
				{
					new rPoints = sBuyChatTag * 2 - iUserPoints [id];
		
					new StrPoints [16];

					AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );	
				
					ShowShopMenu ( id );
					
					return PLUGIN_CONTINUE;
				}
			}
			else
			{
				if (  sBuyChatTag > iUserPoints [id] )
				{
					new rPoints = sBuyChatTag - iUserPoints [id];

					new StrPoints [16];

					AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

					client_print_color ( id, id, "%s %L",CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );	
				
					ShowShopMenu ( id );
					
					return PLUGIN_CONTINUE;
				}
			}

			//client_print_color ( id, id, "^4%s^1 %L", "[CSGO UltimateX]", id, "CSGO_SET_TAG" );
		
			client_cmd ( id, "messagemode UserTag" );
				
			ShowShopMenu ( id );
		}
		case 3:
		{
			ShowBuyCasesOrKeysMenu ( id );
		}
		default: {  } // Keep looping
	}
	
	return PLUGIN_CONTINUE;
}

public ShowBuySkinTag ( id )
{
	new Temp [96]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y Buy Skin-Tag" );
	
	new Menu = menu_create ( Temp, "BuySkinTagHandler", 0 );

	if ( !SkinTagS [id] )
	{
		formatex ( Temp, charsmax ( Temp ), "\wSkin:\r N/A" );

		menu_additem ( Menu, Temp, "", 0, -1 );
	}
	else
	{
		if ( SkinTagS [id] > 7000 )
		{
			formatex ( Temp, charsmax ( Temp ), "\wSkin:\r %s\y [\rStatTrak\y]", SkinName [SkinTagS [id] - 7000] )
		}
		else
		{
			formatex ( Temp, charsmax ( Temp ), "\wSkin:\r %s", SkinName [SkinTagS [id]] )
		}	
			
		menu_additem ( Menu, Temp, "", 0, -1 );
	}

	if ( equali ( TagInput [id], "" ) )
	{
		formatex ( Temp, charsmax ( Temp ), "\wTag:\r N/A" );

		menu_additem ( Menu, Temp, "", 0, -1 );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "\wTag:\r %s%s", TagInput [id], SkinTagS [id] > 0 && !equali ( TagInput [id], "" ) ? "^n" : "" );
			
		menu_additem ( Menu, Temp, "", 0, -1 );
	}

	new StrPoints [16];

	AddCommas ( sSkinTagPrice, StrPoints, charsmax ( StrPoints ) );

	if ( SkinTagS [id] > 0 && !equali ( TagInput [id], "" ) )
	{
		formatex ( Temp, charsmax ( Temp ), "Buy Tag\d (\yCost:\r %s\d)", StrPoints );
			
		menu_additem ( Menu, Temp, "", 0, -1 );	
	}

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;
}

public BuySkinTagHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowShopMenu ( id );

		return DestroyMenu ( Menu );
	}

	switch ( Item )
	{
		case 0:
		{
			SelectTagSkin ( id );
		}
		case 1:
		{
			client_cmd ( id, "messagemode NameTag" );
		}
		case 2:
		{
			if ( sSkinTagPrice > iUserPoints [id] )
			{
				new rPoints = sSkinTagPrice - iUserPoints [id];

				new StrPoints [16];

				AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );
				
				ShowBuySkinTag ( id );	

				return DestroyMenu ( Menu );
			}

			if ( SkinTagS [id] > 7000 && SkinTag [id] [SkinTagS [id] - 7000] != 0)
			{
				ShowBuySkinTag ( id );

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, "CSGO_GIFT_HAS_SKINTAG", SkinName [SkinTagS [id] - 7000] );

				return DestroyMenu ( Menu );
			}
			
			new Apply;

			if ( SkinTagS [id] > 7000 )
			{
				SkinTag [id] [SkinTagS [id] - 7000] = 2;

				copy ( SkinTagN [id] [SkinTagS [id] - 7000], charsmax ( SkinTagN [ ] ), TagInput [id] );
					
				iUserSkins [id] [SkinTagS [id] - 7000] --;

				iUserSTs [id] [SkinTagS [id] - 7000] --;

				for ( Apply = 0; Apply < 25; Apply ++ )
				{
					if ( SkinTagS [id] == iUserSelectedSkin [id] [Apply] )
					{
						iUserSelectedSkin [id] [Apply] = SkinTagS [id] + 10000;
					}
				}
			}
			else
			{
				SkinTag [id] [SkinTagS [id]] = 1;

				copy ( SkinTagN [id] [SkinTagS [id]], charsmax ( SkinTagN [ ] ), TagInput [id] );

				iUserSkins [id] [SkinTagS [id]] --;

				for ( Apply = 0; Apply < 25; Apply ++ )
				{
					if ( SkinTagS [id] == iUserSelectedSkin [id] [Apply] )
					{
						iUserSelectedSkin [id] [Apply] = SkinTagS [id] + 10000;
					}
				}
			}

			if ( SkinTagS [id] > 7000 )
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BUY_SKIN_TAG", TagInput [id], SkinName [SkinTagS [id] - 7000] );
			}
			else
			{
				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BUY_SKIN_TAG", TagInput [id], SkinName [SkinTagS [id]] );					
			}

			iUserPoints [id] -= sSkinTagPrice;

			SkinTagS [id] = 0;

			TagInput [id] = "";
		}
	}
	
	return DestroyMenu ( Menu );
}

public SelectTagSkin ( id )
{
	new Temp [96];

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_SKINS_MENU" );

	new Menu = menu_create ( Temp, "SelectTagSkinHandler" );

	new String [32], bool: HasSkins = false;

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( iUserSTs [id] [i] )
		{
			new sID = i + 7000;

			formatex ( String, charsmax ( String ), "%d", sID );

			formatex ( Temp, charsmax ( Temp ), "%s\y [\rStatTrak\y]\d (%d)", SkinName [i], iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}

		if ( iUserSkins [id] [i] > iUserSTs [id] [i] )
		{
			num_to_str ( i, String, charsmax ( String ) );

			formatex ( Temp, charsmax ( Temp ), "%s\y [\r%s\y]\d (%d)", SkinName [i], GetSkinClass ( i ), iUserSkins [id] [i] - iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	if ( !HasSkins  )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;
}

public SelectTagSkinHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowShopMenu ( id );

		return DestroyMenu ( Menu );
	}

	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );

	switch ( Item )
	{
		case -10:
		{
			ShowBuySkinTag ( id );

			return DestroyMenu ( Menu );
		}
		default:
		{
			SkinTagS [id] = Item;

			ShowBuySkinTag ( id );
		}
	}

	return DestroyMenu ( Menu );
}

public SetSkinTag ( id )
{
	if ( !iLogged [id] || !SkinTagS [id] || SkinTagS [id] > 7000 && SkinTag [id] [SkinTagS [id] - 7000] != 0 || SkinTagS [id] < 7000 && SkinTag [id] [SkinTagS [id]] != 0 )
	{
		ShowBuySkinTag ( id );

		return PLUGIN_HANDLED;
	}
		
	new Data [32];

	read_args ( Data, charsmax ( Data ) );

	remove_quotes ( Data );
	
	replace_all ( Data, charsmax ( Data ), "#", "" );

	MakeStringSQLSafeAll ( Data, charsmax ( Data ) );

	if ( !Data [0] || !strlen ( Data ) )
	{
		client_cmd ( id, "messagemode NameTag" );

		return PLUGIN_HANDLED;
	}
	else if ( strlen ( Data ) > 16 )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MAX_TAG", 16 );

		client_cmd ( id, "messagemode NameTag" );

		return PLUGIN_HANDLED;
	}
	else if ( strlen ( Data ) < 3 )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MIN_TAG", 3 );

		client_cmd ( id, "messagemode NameTag" );

		return PLUGIN_HANDLED;
	}

	copy ( TagInput [id], charsmax ( TagInput [ ] ), Data );

	ShowBuySkinTag ( id );

	return PLUGIN_CONTINUE;
}

public ShowReNameSkinTag ( id )
{
	new Temp [96]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y ReName Skin-Tag" );
	
	new Menu = menu_create ( Temp, "ReNameSkinTagHandler", 0 );

	if ( !SkinTagS [id] )
	{
		formatex ( Temp, charsmax ( Temp ), "\wSkin:\r N/A" );

		menu_additem ( Menu, Temp, "", 0, -1 );
	}
	else
	{
		if ( SkinTagS [id] > 7000 )
		{
			formatex ( Temp, charsmax ( Temp ), "\wSkin:\d [\r%s\d]\w %s\y [\rStatTrak\y]", SkinTagN [id] [SkinTagS [id] - 7000], SkinName [SkinTagS [id] - 7000] )
		}
		else
		{
			formatex ( Temp, charsmax ( Temp ), "\wSkin:\d [\r%s\d]\y %s", SkinTagN [id] [SkinTagS [id]], SkinName [SkinTagS [id]] )
		}	
			
		menu_additem ( Menu, Temp, "", 0, -1 );
	}

	if ( equali ( TagInput [id], "" ) )
	{
		formatex ( Temp, charsmax ( Temp ), "\wTag:\r N/A" );

		menu_additem ( Menu, Temp, "", 0, -1 );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "\wTag:\r %s%s", TagInput [id], SkinTagS [id] > 0 && !equali ( TagInput [id], "" ) ? "^n" : "" );
			
		menu_additem ( Menu, Temp, "", 0, -1 );
	}

	new StrPoints [16];

	AddCommas ( sRenameSkinTagPrice, StrPoints, charsmax ( StrPoints ) );

	if ( SkinTagS [id] > 0 && !equali ( TagInput [id], "" ) )
	{
		formatex ( Temp, charsmax ( Temp ), "ReName Tag\d (\yCost:\r %s\d)", StrPoints );
			
		menu_additem ( Menu, Temp, "", 0, -1 );	
	}

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;
}

public ReNameSkinTagHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowShopMenu ( id );

		return DestroyMenu ( Menu );
	}

	switch ( Item )
	{
		case 0:
		{
			ReNameTagSkin ( id );
		}
		case 1:
		{
			client_cmd ( id, "messagemode ReNameTag" );
		}
		case 2:
		{
			if ( sRenameSkinTagPrice > iUserPoints [id] )
			{
				new rPoints = sRenameSkinTagPrice - iUserPoints [id];

				new StrPoints [16];

				AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );
				
				ShowReNameSkinTag ( id );	

				return DestroyMenu ( Menu );
			}

			//copy ( SkinTagN [id] [SkinTagS [id] - 7000], charsmax ( SkinTagN [ ] ), TagInput [id] );

			if ( 7000 <= SkinTagS [id] )
			{
				copy ( SkinTagN [id] [SkinTagS [id] - 7000], charsmax ( SkinTagN [ ] ), TagInput [id] );

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_RENAME_SKIN_TAG", TagInput [id], SkinName [SkinTagS [id] - 7000] );
			}
			else
			{
				copy ( SkinTagN [id] [SkinTagS [id]], charsmax ( SkinTagN [ ] ), TagInput [id] );

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_RENAME_SKIN_TAG", TagInput [id], SkinName [SkinTagS [id]] );					
			}

			iUserPoints [id] -= sRenameSkinTagPrice;

			SkinTagS [id] = 0;

			TagInput [id] = "";
		}
	}
	
	return DestroyMenu ( Menu );
}

public ReNameTagSkin ( id )
{
	new Temp [96];

	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d] %L", id, "CSGO_SKINS_MENU" );

	new Menu = menu_create ( Temp, "ReNameTagSkinHandler" );

	new String [32], bool: HasSkins = false;

	for ( new i = 1; i < SkinsNum; i++)
	{
		if ( SkinTag [id] [i] == 2 )
		{
			formatex ( String, charsmax ( String ), "%d", i );

			formatex ( Temp, charsmax ( Temp ), "\d[\r%s\d]\w %s\y [\rStatTrak\y]", SkinTagN [id] [i], SkinName [i] );
			
			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
		else if ( SkinTag [id] [i] == 1 )
		{
			formatex ( String, charsmax ( String ), "%d", i );

			formatex ( Temp, charsmax ( Temp ), "\d[\r%s\d]\y %s", SkinTagN [id] [i], SkinName [i] );
			
			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	if ( !HasSkins  )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}

	DisplayMenu ( id, Menu );

	return PLUGIN_CONTINUE;
}

public ReNameTagSkinHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowShopMenu ( id );

		return DestroyMenu ( Menu );
	}

	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );

	switch ( Item )
	{
		case -10:
		{
			ShowReNameSkinTag ( id );

			return DestroyMenu ( Menu );
		}
		default:
		{
			SkinTagS [id] = Item;

			ShowReNameSkinTag ( id );
		}
	}

	return DestroyMenu ( Menu );
}

public ReNameSkinTag ( id )
{
	if ( !iLogged [id] || !SkinTagS [id] || (7000 <= SkinTagS[id]) ? SkinTag [id] [SkinTagS [id] - 7000] == 0 : SkinTag [id] [SkinTagS [id]] == 0 )
		
		return PLUGIN_HANDLED;
		
	new Data [32];

	read_args ( Data, charsmax ( Data ) );

	remove_quotes ( Data );
	
	replace_all ( Data, charsmax ( Data ), "#", "" );

	MakeStringSQLSafeAll ( Data, charsmax ( Data ) );

	if ( !Data [0] || !strlen ( Data ) )
	{
		client_cmd ( id, "messagemode ReNameTag" );

		return PLUGIN_HANDLED;
	}
	else if ( strlen ( Data ) > 16 )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MAX_TAG", 3 );

		client_cmd ( id, "messagemode ReNameTag" );

		return PLUGIN_HANDLED;
	}
	else if ( strlen ( Data ) < 3 )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MIN_TAG", 3 );

		client_cmd ( id, "messagemode ReNameTag" );

		return PLUGIN_HANDLED;
	}

	copy ( TagInput [id], charsmax ( TagInput [ ] ), Data );

	ShowReNameSkinTag ( id );
	
	return PLUGIN_CONTINUE;
}

public ShowBuyCasesOrKeysMenu ( id )
{
	new Temp [96]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_SM_BUY_CK" );
	
	new Menu = menu_create ( Temp, "BuyCasesOrKeysHandler", 0 );
	
	if ( ItemName [id] == 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r N/A", id, "CSGO_BUY_CK_NAME" );
	
		menu_additem ( Menu, Temp, "", 0, -1 );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r %s", id, "CSGO_BUY_CK_NAME", ChestName [ItemName [id]] )
			
		menu_additem ( Menu, Temp, "", 0, -1 );
	}

	if ( TypeName [id] == 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r N/A", id, "CSGO_BUY_CK_TYPE" );
	
		menu_additem ( Menu, Temp, "", 0, -1 );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r %s", id, "CSGO_BUY_CK_TYPE", GetTypeName ( id ) )
			
		menu_additem ( Menu, Temp, "", 0, -1 );
	}

	if ( Quantity [id] == 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r N/A", id, "CSGO_BUY_CK_AMOUNT" );
	
		menu_additem ( Menu, Temp, "", 0, -1 );
	}
	else
	{
		formatex ( Temp, charsmax ( Temp ), "\w%L:\r %d%s", id, "CSGO_BUY_CK_AMOUNT", Quantity [id], ItemName [id] > 0 && TypeName [id] > 0 && Quantity [id] > 0 ? "^n" : "" );
			
		menu_additem ( Menu, Temp, "", 0, -1 );
	}

	if ( ItemName [id] > 0 && TypeName [id] > 0 && Quantity [id] > 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_BUY_CK", GetPrice ( id ) );
			
		menu_additem ( Menu, Temp, "", 0, -1 );	
	}

	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public BuyCasesOrKeysHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );
		
		return DestroyMenu ( Menu );
	}

	switch ( Item )
	{
		case 0:
		{
			if ( ItemName [id] >= ChestsNum -1 )
			{
				ItemName [id] = 1;
			}
			else
			{
				ItemName [id] ++;
			}

			ShowBuyCasesOrKeysMenu ( id );
		}
		case 1:
		{
			if ( TypeName [id] >= 2 )
			{
				TypeName [id] = 1;
			}
			else
			{
				TypeName [id] ++;
			}

			ShowBuyCasesOrKeysMenu ( id );
		}
		case 2:
		{
			if ( Quantity [id] >= 10 || Quantity [id] < 1 )
			{
				Quantity [id] = 1;
			}
			else if ( Quantity [id] < 5 )
			{
				Quantity [id] = 5;
			}
			else if ( Quantity [id] < 10 )
			{
				Quantity [id] = 10;
			}

			ShowBuyCasesOrKeysMenu ( id );
		}
		case 3:
		{
			if ( GetPrice ( id ) > iUserPoints [id] )
			{
				new rPoints = GetPrice ( id ) - iUserPoints [id];

				new StrPoints [16];

				AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

				client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );
				
				ShowBuyCasesOrKeysMenu ( id );
			}
			else
			{
				iUserPoints [id] -= GetPrice ( id );

				if ( TypeName [id] == 1 )
				{
					iUserChests [id] [ItemName [id]] += Quantity [id];
				}
				else if ( TypeName [id] == 2 )
				{
					iUserKeys [id] [ItemName [id]] += Quantity [id];
				}

				if ( TypeName [id] == 1 )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BUY_CHESTS", Quantity [id], ChestName [ItemName [id]]  );
				}
				else if ( TypeName [id] == 2 )
				{
					client_print_color ( id, id, "%s %L", CHAT_PREFIX,id, "CSGO_BUY_KEYS", Quantity [id], ChestName [ItemName [id]]  );
				}
			}
		}
	}

	return DestroyMenu ( Menu );
}

GetPrice ( id )
{
	new StorePrice;

	switch ( TypeName [id] )
	{
		case 1: StorePrice = ChestMaxPrice [ItemName [id]] * sBuyCKMultiplier * Quantity [id];

		case 2: StorePrice = ChestMaxPrice [ItemName [id]] * sBuyCKMultiplier * Quantity [id];
	}

	return StorePrice;
}

GetTypeName ( id )
{
	new Temp [32];

	switch ( TypeName [id] )
	{
		case 1: formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_CHEST" );

		case 2: formatex ( Temp, charsmax ( Temp ), "%L", id, "CSGO_KEY" );
	}

	return Temp;
}

public PlayerTag ( id )
{
	if ( !iLogged [id] )
	{
		return PLUGIN_HANDLED;
	}
    
	new sTag [32];
	
	read_args ( sTag, charsmax ( sTag ) );
   
	remove_quotes ( sTag );

	if ( strlen ( sTag ) > 15 )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MAX_TAG", 15 );
		
		client_cmd ( id, "messagemode UserTag" );
		
		return PLUGIN_HANDLED;
	}
	else if ( strlen ( sTag ) < 4 )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_MIN_TAG", 4 );
		
		client_cmd ( id, "messagemode UserTag" );
		
		return PLUGIN_HANDLED;
	}

	if ( containi ( sTag, "[" ) != -1 || containi ( sTag, "(" ) != -1 || containi ( sTag, "]" ) != -1 || containi ( sTag, ")" ) != -1 )
	{
		replace_all ( sTag, charsmax ( sTag ), "[", "" );
		
		replace_all ( sTag, charsmax ( sTag ), "(", "" );

		replace_all ( sTag, charsmax ( sTag ), "]", "" );
		
		replace_all ( sTag, charsmax ( sTag ), ")", "" );
	}
	
	if ( PlayerHasTag [id] )
	{
		replace_all ( iUserSavedTag [id], charsmax ( iUserSavedTag [ ] ), "[", "" );
		
		replace_all ( iUserSavedTag [id], charsmax ( iUserSavedTag [ ] ), "]", "" );
		
		if ( equal ( sTag, iUserSavedTag [id] ) )
		{
			client_cmd ( id, "messagemode UserTag" );
		
			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_ALREADY_HAS_TAG", sTag );
		
			return PLUGIN_HANDLED;
		}
	}

	new StrPoints [16], rPoints;
	
	if ( PlayerHasTag [id] )
	{
		if ( sBuyChatTag * 2 > iUserPoints [id] )
		{
			rPoints = sBuyChatTag * 2 - iUserPoints [id];

			AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );
		
			return PLUGIN_HANDLED;
		}

		iUserPoints [id] -= sBuyChatTag * 2;
	}
	else
	{
		if ( sBuyChatTag  > iUserPoints [id] )
		{
			rPoints = sBuyChatTag - iUserPoints [id];

			AddCommas ( rPoints, StrPoints, charsmax ( StrPoints ) );

			client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_NOT_ENOUGH_POINTS", StrPoints );
		
			return PLUGIN_HANDLED;
		}

		iUserPoints [id] -= sBuyChatTag;
	}

	new wFile [256], Data [32];
				
	//get_configsdir ( Director, charsmax ( Director ) );
	
	formatex ( wFile, charsmax ( wFile ), "%s/csgo_tags.ini", Director );
	
	formatex ( Data, charsmax ( Data ), "^"%s^" ^"%s^"", Name [id], sTag );
	
	CheckUsers ( id );
				
	write_file ( wFile, Data );	
	
	LoadUserTag ( id );	
		
	client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_BUY_TAG", sTag );

	return PLUGIN_HANDLED;
}

public LoadUserTag ( id )
{
	//get_configsdir ( TagFile, charsmax ( TagFile ) );
	
	formatex ( TagFile, charsmax ( TagFile ), "%s/csgo_tags.ini", Director );
    
	if ( !file_exists ( TagFile ) ) 
		
		write_file ( TagFile, "^"EnTeR_^" ^"[Dev. #]^"", -1 );
		
	PlayerHasTag [id] = false;
    
	new FileOpen = fopen ( TagFile, "rt" );
    
	if ( !FileOpen ) return PLUGIN_CONTINUE;
    
	new Data [512], Buffer [2] [32];
    
	while ( !feof ( FileOpen ) ) 
 	{
   		fgets ( FileOpen, Data, charsmax ( Data ) );
        
        	if ( !Data [0] || Data [0] == ';' || ( Data [0] == '/' && Data [1] == '/' ) ) 
			
			continue;
        
       		parse ( Data, Buffer [0], charsmax ( Buffer [ ] ), Buffer [1], charsmax ( Buffer [ ] ) )
        
        	if ( equal ( Name [id], Buffer [0] ) )
        	{
         		PlayerHasTag [id] = true;
         	
			copy ( iUserSavedTag [id], charsmax ( iUserSavedTag [ ] ), Buffer [1] );
           	
			break;
        	}
	}

        return PLUGIN_CONTINUE;
} 

public CheckUsers ( id )
{
	new FileName [64]; get_configsdir ( FileName, charsmax ( FileName ) );
	
	add ( FileName, charsmax ( FileName ), "/csgo_tags.ini" );
	
	new File, Line;
	
	ReadFile:
	
	File = fopen ( FileName , "rt" );
	
	Line = -1;
	
	if ( File )
	{
		new Format [256], i, Key [32];
		
		while ( !feof ( File ) )
		{
			Line ++;
			
			fgets ( File, Format, charsmax ( Format ) );
			
			trim ( Format );
			
			i = Format [0];
			
			if ( i && i != '#' && i != ';' && !( i == '/' && Format [1] == '/' ) )
			{
				parse ( Format, Key, charsmax ( Key ) );
				
				if ( equal ( Key, Name [id] ) )
				{
					fclose ( File );
					
					File = 0;
					
					write_file ( FileName, "", Line );
					
					goto ReadFile;
				}
			}
		}
		
		fclose ( File );
		
		File = 0;
	}
}

ShowDustbinMenu ( id )
{
	new Temp [64]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_DB_MENU" );
	
	new Menu = menu_create ( Temp, "DustbinMenuHandler", 0 );
	
	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_DB_DESTROY" );
	
	menu_additem ( Menu, Temp, "1", 0, -1 );
	
	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_DB_TRANSFORM");
	
	menu_additem ( Menu, Temp, "2", 0, -1 );
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public DustbinMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		ShowMainMenu ( id );
		
		return DestroyMenu( Menu);
	}
	
	new ItemData [6], Index;
	
	menu_item_getinfo ( Menu, Item, _, ItemData, charsmax ( ItemData ) );
	
	Index = str_to_num ( ItemData );
	
	iMenuType [id] = Index;
	
	ShowSkins ( id );
	
	return DestroyMenu ( Menu );
}


public dbSkinsMenuHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		iMenuType [id] = 0;

		ShowDustbinMenu ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );

	parse ( Data [0], Data [2], charsmax ( Data [ ] ), Data [3], charsmax ( Data [ ] ) );


	switch ( Item )
	{
		case -30:
		{
			ShowDBGlovesMenu ( id );
		}
		case -10:
		{
			ShowMainMenu ( id );
		}
		default:
		{
			DestroySkin ( id, Item, iMenuType [id] );
		}
	}

	return DestroyMenu ( Menu );
}

ShowDBGlovesMenu ( id )
{
	new Temp [96];
	
	formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_GLOVES_MENU" );
	
	new Menu = menu_create ( Temp, "DBGlovesHandler", 0 );
	
	new bool: HasGloves = false, String [32];
	
	for ( new i = 1; i < GlovesNum; i ++ )
	{
		if ( iUserGloves [id] [i] != 0 )
		{
			new wID = i + 2000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s", GloveName [i] );

			menu_additem ( Menu, Temp, String );

			HasGloves = true;
		}
	}

	if ( !HasGloves )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_GLOVES" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;                                                                                
}

public DBGlovesHandler ( id, Menu, Item )
{
	if ( Item == MENU_EXIT )
	{
		SelectGiftItem ( id );
		
		return DestroyMenu ( Menu );
	}
	
	new aMenu [2], Data [4] [32], sKey [32];

	menu_item_getinfo ( Menu, Item, aMenu [0], Data [0], charsmax ( Data [ ] ), Data [1], charsmax ( Data [ ] ), aMenu [1] );
	
	parse ( Data [0], sKey, charsmax ( sKey ) );

	Item = str_to_num ( sKey );
	
	switch ( Item )
	{
		case -10:
		{
			ShowSkins ( id );
		}
		default:
		{
			DestroySkin ( id, Item, iMenuType [id] );
		}
	}

	return DestroyMenu ( Menu );
}

public DestroySkin ( id, Item, Type )
{	
	new Temp [96];

	if ( Item == iUserSellItem [id] && iUserSell [id] || Item == iTradeItem [id] && bTradeActive [id] )
	{
		client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_CANT_GIVE" );
		
		iMenuType [id] = 0;
					
		ShowDustbinMenu ( id );

		return PLUGIN_HANDLED;
	}

	switch ( Type )
	{
		case 1:
		{
			for ( new i = 1; i < SkinsNum; i ++ )
			{
				if ( Item == i && iUserSkins [id] [i] > 0 )
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( i == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					iUserSkins [id] [i] --;	
	
					iUserDusts [id] += sDustForTransform;

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SKIN_DESTROYED", sDustForTransform, SkinName [i], "" );
	
					SaveData ( id );
				}
				else if ( Item == i + 7000 && iUserSkins [id] [i] > 0 )
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( i + 7000 == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					iUserSkins [id] [i] --;

					iUserSTs [id] [i] --;

					if ( iUserSTs [id] [i] < 1 )
					{
						STKills [id] [i] = 0;
					}

					iUserDusts [id] += sDustForTransform;

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SKIN_DESTROYED", sDustForTransform, SkinName [i], " ^4(^3StatTrak^4)" );

					SaveData ( id );
				}
				else if ( Item == i + 10000 && SkinTag [id] [i] > 0 )
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( i + 10000 == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					SkinTag [id] [i] = 0;

					iUserDusts [id] += sDustForTransform;

					formatex ( Temp, charsmax ( Temp ), " ^4(^3%s^4)", SkinTagN [id] [i] );

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SKIN_DESTROYED", sDustForTransform, SkinName [i], Temp );

					SaveData ( id );
				}
				else if ( Item == i + 17000 && SkinTag [id] [i] > 0 )
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( i + 17000 == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					SkinTag [id] [i] = 0;

					if ( iUserSTs [id] [i] < 1 )
					{
						STKills [id] [i] = 0;
					}

					iUserDusts [id] += sDustForTransform;

					formatex ( Temp, charsmax ( Temp ), " ^4(^3%s^4)^1 |^4 (^3StatTrak^4)", SkinTagN [id] [i] );

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SKIN_DESTROYED", sDustForTransform, SkinName [i], Temp )

					SaveData ( id );
				}
			}

			for ( new i = 1; i < GlovesNum; i ++ )
			{
				if ( Item == i + 2000 && iUserGloves [id] [i] > 0 )
				{
					iUserGloves [id] [i] --;

					if ( iUserGloves [id] [i] < 1 && g_iUserSelectedGlove [id] == i )
					{
						g_iUserSelectedGlove [id] = 0;
					}

					iUserDusts [id] += sDustForTransform;

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SKIN_DESTROYED", sDustForTransform, GloveName [i], "" );

					SaveData ( id );
				}
			}
			
		}
		case 2:
		{
			for ( new i = 1; i < SkinsNum; i ++ )
			{
				if ( Item == i && iUserSkins [id] [i] > 0 )
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( i == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					iUserSkins [id] [i] --;	
			
					new sPrice = SkinMaxPrice [i] / sTransformRest;

					new StrPoints [16];

					AddCommas ( sPrice, StrPoints, charsmax ( StrPoints ) );
					
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SKIN_TRANSFORMED", StrPoints, SkinName [i], "" );
					
					iUserPoints [id] += sPrice;
					
					SaveData ( id );
				}
				else if ( Item == i + 7000 && iUserSkins [id] [i] > 0 )
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( i + 7000 == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					iUserSkins [id] [i] --;

					iUserSTs [id] [i] --;

					if ( iUserSTs [id] [i] < 1 )
					{
						STKills [id] [i] = 0;
					}

					new sPrice = SkinMaxPrice [i] / sTransformRest;
					
					new StrPoints [16];

					AddCommas ( sPrice, StrPoints, charsmax ( StrPoints ) );

					iUserPoints [id] += sPrice;
					
					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SKIN_TRANSFORMED", StrPoints, SkinName [i], " ^4(^3StatTrak^4)" );
					
					SaveData ( id );
				}
				else if ( Item == i + 10000 && SkinTag [id] [i] > 0 )
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( i + 10000 == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					SkinTag [id] [i] = 0;

					new sPrice = SkinMaxPrice [i] / sTransformRest;

					new StrPoints [16];

					AddCommas ( sPrice, StrPoints, charsmax ( StrPoints ) );

					iUserPoints [id] += sPrice;

					formatex ( Temp, charsmax ( Temp ), " ^4(^3%s^4)", SkinTagN [id] [i] );

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SKIN_TRANSFORMED", StrPoints, SkinName [i], Temp )

					SaveData ( id );
				}
				else if ( Item == i + 17000 && SkinTag [id] [i] > 0 )
				{
					for ( new sID = 0; sID < 25; sID ++ )
					{
						if ( i + 17000 == iUserSelectedSkin [id] [sID] )
						{
							iUserSelectedSkin [id] [sID] = 0;
						}
					}

					SkinTag [id] [i] = 0;	

					new sPrice = SkinMaxPrice [i] / sTransformRest;
					
					new StrPoints [16];

					AddCommas ( sPrice, StrPoints, charsmax ( StrPoints ) );

					iUserPoints [id] += sPrice;

					formatex ( Temp, charsmax ( Temp ), " ^4(^3%s^4)^1 |^4 (^3StatTrak^4)", SkinTagN [id] [i] );

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SKIN_TRANSFORMED", StrPoints, SkinName [i], Temp )

					SaveData ( id );
				}
			}

			for ( new i = 1; i < GlovesNum; i ++ )
			{
				if ( Item == i + 2000 && iUserGloves [id] [i] > 0 )
				{
					iUserGloves [id] [i] --;

					if ( iUserGloves [id] [i] < 1 && g_iUserSelectedGlove [id] == i )
					{
						g_iUserSelectedGlove [id] = 0;
					}

					new sPrice = GloveMaxPrice [i] / sTransformRest;
					
					new StrPoints [16];

					AddCommas ( sPrice, StrPoints, charsmax ( StrPoints ) );

					iUserPoints [id] += sPrice;

					client_print_color ( id, id, "%s %L", CHAT_PREFIX, id, "CSGO_SKIN_TRANSFORMED", StrPoints, GloveName [i], "" );

					SaveData ( id );
				}
			}
		}
		default: {   }
	}

	iMenuType [id] = 0;

	ShowDustbinMenu ( id );
	
	return PLUGIN_HANDLED;
}

ShowSkins ( id )
{
	new Temp [64]; formatex ( Temp, charsmax ( Temp ), "\d[\rCS:GO\w Infinity\d]\y %L", id, "CSGO_SKINS_MENU" );
	
	new Menu = menu_create ( Temp, "dbSkinsMenuHandler", 0 );
	
	new bool: HasSkins = false, String [32];

	formatex ( Temp, charsmax ( Temp ), "\w%L", id, "CSGO_GLOVE" );
		
	menu_additem ( Menu, Temp, "-30", 0, -1 );

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( SkinTag [id] [i] == 2 )
		{
			new wID = i + 17000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "\d[\r%s\d]\y %s\y [\rStatTrak\y]", SkinTagN [id] [i], SkinName [i]);

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
		else if ( SkinTag [id] [i] == 1 )
		{
			new wID = i + 10000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "\d[\r%s\d]\y %s\y [\r%s\y]", SkinTagN [id] [i], SkinName [i], GetSkinClass ( i ) );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	for ( new i = 1; i < SkinsNum; i ++ )
	{
		if ( iUserSTs [id] [i] )
		{
			new wID = i + 7000;

			formatex ( String, charsmax ( String ), "%d", wID );

			formatex ( Temp, charsmax ( Temp ), "%s\y [\rStatTrak\y]\d (%d)", SkinName [i], iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}

		if ( iUserSkins [id] [i] > iUserSTs [id] [i] )
		{
			num_to_str ( i, String, charsmax ( String ) );

			formatex ( Temp, charsmax ( Temp ), "%s\y [\r%s\y]\d (%d)", SkinName [i], GetSkinClass ( i ), iUserSkins [id] [i] - iUserSTs [id] [i] );

			menu_additem ( Menu, Temp, String );

			HasSkins = true;
		}
	}

	if ( !HasSkins )
	{
		formatex ( Temp, charsmax ( Temp ), "\d%L", id, "CSGO_SM_NO_SKINS" );
		
		menu_additem ( Menu, Temp, "-10", 0, -1 );
	}
	
	DisplayMenu ( id, Menu );
	
	return PLUGIN_CONTINUE;
}

public SaveLog ( id )
{
	ExecuteForward ( iForwards [3], iForwardResult, id );

	new Data [2], Query [256], SafeName [100];

	Data [0] = id;

	MakeStringSQLSafe ( Name [id], SafeName, charsmax ( SafeName ) );
 
	formatex ( Query, charsmax ( Query ), "INSERT INTO `%s` (`name`,`password`) VALUES (^"%s^",^"%s^");", SQL_TABLE, SafeName, iUserSavedPass [id] );

	SQL_ThreadQuery ( iSqlTuple, "QuerySetData", Query, Data, sizeof ( Data ) );
}

public QuerySetData ( FailState, Handle: Query, Error [ ], Errcode, Data [ ], DataSize, Float:Queuetime ) 
{
  	if ( FailState == TQUERY_CONNECT_FAILED )
        {
		LogToFile ( "[SQL] Could not connect to SQL database.  [%d] %s",Errcode, Error)

		return set_fail_state ( "Could not connect to SQL database." );
	}
    	else if ( FailState == TQUERY_QUERY_FAILED )
	{
		LogToFile ( "[SQL] - Query failed. [%d] %s", Errcode, Error)

        	return set_fail_state ( "Query failed." );
	}
	
	new id = Data [0];

	LoadData ( id );

	SQL_FreeHandle ( Query );

	return PLUGIN_HANDLED;
}

public ClCmdGivePoints ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 3, false ) )
	{
		return PLUGIN_HANDLED;
	}
    
	new Arg1 [32], Arg2 [16], StrPoints [16];
    
	read_argv ( 1, Arg1, charsmax ( Arg1 ) );
	read_argv ( 2, Arg2, charsmax ( Arg2 ) );

	new Amount = str_to_num ( Arg2 );

	if ( equal ( Arg1, "@all" ) )
	{
		for ( new i = 1; i < MaxPlayers; i ++ )
		{
			if ( iLogged [i] )
			{
				iUserPoints [i] += Amount;

				SaveData ( i );
			}
		}

		AddCommas ( Amount, StrPoints, charsmax ( StrPoints ) );
			
		console_print ( id, "[CS:GO Infinity] Ai dat tuturor jucatorilor %s euro", StrPoints );
			
		LogToFile ( "[INFO] - %s a dat tututor jucatorilor %s Euro", Name [id], StrPoints );

		client_print_color ( 0, 0, "%s Adminul^4 %s^1 a dat tuturor jucatorilor^3 %s Euro", CHAT_PREFIX, Name [id], StrPoints );
	}
	else
	{
		new Target = cmd_target ( id, Arg1, 3 );
	    
		if ( !Target )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul nu a fost gasit!" );
			
			return PLUGIN_HANDLED;
		}
		
		if ( !iLogged [Target] )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul %s nu este logat!", Name [Target] );
			
			return PLUGIN_HANDLED;
		}
		
		if ( Amount < 0 )
		{
			replace ( Arg2, charsmax ( Arg2 ), "-", "" );
			
			Amount = str_to_num ( Arg2 );
			
			iUserPoints [Target] -= Amount;
	       
			if ( iUserPoints [Target] < 0 )
			{
				iUserPoints [Target] = 0;
			}

			AddCommas ( Amount, StrPoints, charsmax ( StrPoints ) );
		
			console_print ( id, "[CS:GO Infinity] Ai luat de la %s %s euro", Name [Target], StrPoints );
			
			LogToFile ( "[INFO] - %s i-a luat lui %s %d euro", Name [id], Name [Target], StrPoints );

			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a luat^3 %s euro", CHAT_PREFIX, Name [id], StrPoints );
		}
		else
		{
			iUserPoints [Target] += Amount;

			AddCommas ( Amount, StrPoints, charsmax ( StrPoints ) );
				
			console_print ( id, "[CS:GO Infinity] I-ai dat lui %s %s euro", Name [Target], StrPoints );
				
			LogToFile ( "[INFO] - %s i-a dat lui %s %s Euro", Name [id], Name [Target], StrPoints );

			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a dat^3 %s Euro", CHAT_PREFIX, Name [id], StrPoints );
			
			//return PLUGIN_HANDLED;
		}

		SaveData ( Target );
	}
	
	return PLUGIN_HANDLED;
}

public ClCmdGiveCaps ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 3, false ) )
	{
		return PLUGIN_HANDLED;
	}
    
	new Arg1 [32], Arg2 [16], StrPoints [16];
    
	read_argv ( 1, Arg1, charsmax ( Arg1 ) );
	read_argv ( 2, Arg2, charsmax ( Arg2 ) );

	new Amount = str_to_num ( Arg2 );

	if ( equal ( Arg1, "@all" ) )
	{
		for ( new i = 1; i < MaxPlayers; i ++ )
		{
			if ( iLogged [i] )
			{
				iUserCaps [i] += Amount;

				SaveData ( i );
			}
		}

		console_print ( id, "[CS:GO Infinity] Ai dat tuturor jucatorilor %d capsule", Amount );
			
		LogToFile ( "[INFO] - %s a dat tututor jucatorilor %d capsule", Name [id], Amount );

		client_print_color ( 0, 0, "%s Adminul^4 %s^1 a dat tuturor jucatorilor^3 %d capsule", CHAT_PREFIX, Name [id], Amount );
	}
	else
	{
		new Target = cmd_target ( id, Arg1, 3 );
	    
		if ( !Target )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul nu a fost gasit!" );
			
			return PLUGIN_HANDLED;
		}
		
		if ( !iLogged [Target] )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul %s nu este logat!", Name [Target] );
			
			return PLUGIN_HANDLED;
		}
		
		if ( Amount < 0 )
		{
			replace ( Arg2, charsmax ( Arg2 ), "-", "" );
			
			Amount = str_to_num ( Arg2 );
			
			iUserCaps [Target] -= Amount;
	       
			if ( iUserCaps [Target] < 0 )
			{
				iUserCaps [Target] = 0;
			}

			console_print ( id, "[CS:GO Infinity] Ai luat de la %s %d capsule", Name [Target], Amount );
			
			LogToFile ( "[INFO] - %s i-a luat lui %s %d capsule", Name [id], Name [Target], Amount );

			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a luat^3 %d capsule", CHAT_PREFIX, Name [id], StrPoints );
		}
		else
		{
			iUserCaps [Target] += Amount;

			console_print ( id, "[CS:GO Infinity] I-ai dat lui %s %d capsule", Name [Target], Amount );
				
			LogToFile ( "[INFO] - %s i-a dat lui %s %d capsule", Name [id], Name [Target], Amount );

			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a dat^3 %d capsule", CHAT_PREFIX, Name [id], Amount );
			
			//return PLUGIN_HANDLED;
		}

		SaveData ( Target );
	}
	
	return PLUGIN_HANDLED;
}

public ClCmdGiveCases ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 4, false ) )
	{
		return PLUGIN_HANDLED;
	}
    
	new Arg1 [32], Arg2 [3], Arg3 [16];
    
	read_argv ( 1, Arg1, charsmax ( Arg1 ) );
	read_argv ( 2, Arg2, charsmax ( Arg2 ) );
	read_argv ( 3, Arg3, charsmax ( Arg3 ) );

	new CaseID = str_to_num ( Arg2 );
	
	new Amount = str_to_num ( Arg3 );

	if ( CaseID < 1 || CaseID >= ChestsNum )
	{
		console_print ( id, "[CS:GO Infinity] CaseID gresit! Alege un numar intre 1 si %d", ChestsNum - 1 );
		
		return PLUGIN_HANDLED;
	}

	if ( equal ( Arg1, "@all" ) )
	{
		for ( new i = 1; i < MaxPlayers; i ++ )
		{
			if ( iLogged [i] )
			{
				iUserChests [i] [CaseID] += Amount;

				SaveData ( i );
			}
		}

		console_print ( id, "[CS:GO Infinity] Ai dat tuturor jucatorilor %d cutii %s", Amount, ChestName [CaseID] );
			
		LogToFile ( "[INFO] - %s a dat tututor jucatorilor %d cutii %s", Name [id], Amount, ChestName [CaseID] );

		client_print_color ( 0, 0, "%s Adminul^4 %s^1 a dat tuturor jucatorilor^3 %d cutii %s", CHAT_PREFIX, Name [id], Amount, ChestName [CaseID] );
	}
	else
	{
		new Target = cmd_target ( id, Arg1, 3 );

		if ( !Target )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul nu a fost gasit!" );
		
			return PLUGIN_HANDLED;
		}
	
		if ( !iLogged [Target] )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul %s nu este logat!", Name [Target] );
		
			return PLUGIN_HANDLED;
		}
	
		if ( Amount < 0 )
		{
			replace ( Arg3, charsmax ( Arg3 ), "-", "" );
		
			Amount = str_to_num ( Arg3 );

			iUserChests [Target] [CaseID] -= Amount;
		
			if ( iUserChests [Target] [CaseID] < 0 )
			{
				iUserChests [Target] [CaseID] = 0;
			}
		
			console_print ( id, "[CS:GO Infinity] Ai luat de la %s %d cutii %s", Name [Target], Amount, ChestName [CaseID] );

			LogToFile ( "[INFO] - %s i-a luat lui %s %d cutii %s", Name [id], Name [Target], Amount, ChestName [CaseID] );
	
			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a luat^3 %d cutii^4 %s", CHAT_PREFIX, Name [id], Amount, ChestName [CaseID] );
		}
		else 
		{
			iUserChests [Target] [CaseID] += Amount;
			
			console_print ( id, "[CS:GO Infinity] I-ai dat lui %s %d cutii %s", Name [Target], Amount, ChestName [CaseID] );

			LogToFile ( "[INFO] - %s i-a dat lui %s %d cutii %s", Name [id], Name [Target], Amount, ChestName [CaseID] );
			
			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a dat^3 %d cutii^4 %s", CHAT_PREFIX, Name [id], Amount, ChestName [CaseID] );
		}

		SaveData ( Target );
	}

	return PLUGIN_HANDLED;
}

public ClCmdGiveKeys ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 3, false ) )
	{
		return PLUGIN_HANDLED;
	}
    
	new Arg1 [32], Arg2 [3], Arg3 [16];
    
	read_argv ( 1, Arg1, charsmax ( Arg1 ) );
	read_argv ( 2, Arg2, charsmax ( Arg2 ) );
	read_argv ( 3, Arg3, charsmax ( Arg3 ) );
  

	new KeyID = str_to_num ( Arg2 );
	
	new Amount = str_to_num ( Arg3 );

	if ( KeyID < 1 || KeyID >= ChestsNum )
	{
		console_print ( id, "[CS:GO Infinity] KeyID gresit! Alege un numar intre 1 si %d", ChestsNum - 1 );
		
		return PLUGIN_HANDLED;
	}

	if ( equal ( Arg1, "@all" ) )
	{
		for ( new i = 1; i < MaxPlayers; i ++ )
		{
			if ( iLogged [i] )
			{
				iUserKeys [i] [KeyID] += Amount;

				SaveData ( i );
			}
		}

		console_print ( id, "[CS:GO Infinity] Ai dat tuturor jucatorilor %d chei %s", Amount, ChestName [KeyID] );
			
		LogToFile ( "[INFO] - %s a dat tututor jucatorilor %d chei %s", Name [id], Amount, ChestName [KeyID] );

		client_print_color ( 0, 0, "%s Adminul^4 %s^1 a dat tuturor jucatorilor^3 %d chei %s", CHAT_PREFIX, Name [id], Amount, ChestName [KeyID] );
	}
	else
	{
		new Target = cmd_target ( id, Arg1, 3 );

		if ( !Target )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul nu a fost gasit!" );
		
			return PLUGIN_HANDLED;
		}
	
		if ( !iLogged [Target] )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul %s nu este logat!", Name [Target] );
		
			return PLUGIN_HANDLED;
		}

		if ( Amount < 0 )
		{
			replace ( Arg3, charsmax ( Arg3 ), "-", "" );
		
			Amount = str_to_num ( Arg3 );
		
			iUserKeys [Target] [KeyID] -= Amount;
       
			if ( iUserKeys [Target] [KeyID] < 0 )
			{
				iUserKeys [Target] [KeyID] = 0;
			}
		
			console_print ( id, "[CS:GO Infinity] Ai luat de la %s %d chei %s", Name [Target], Amount, ChestName [KeyID] );

			LogToFile ( "[INFO] - %s i-a luat lui %s %d chei %s", Name [id], Name [Target], Amount, ChestName [KeyID] );
		
			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a luat^3 %d chei^4 %s", CHAT_PREFIX, Name [id], Amount, ChestName [KeyID] );
		}
		else
		{
			iUserKeys [Target] [KeyID] += Amount;
			
			console_print ( id, "[CS:GO Infinity] I-ai dat lui %s %d chei %s", Name [Target], Amount, ChestName [KeyID] );

			LogToFile ( "[INFO] - %s i-a dat lui %s %d chei %s", Name [id], Name [Target], Amount, ChestName [KeyID] );
			
			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a dat^3 %d chei^4 %s", CHAT_PREFIX, Name [id], Amount, ChestName [KeyID] );
		}
		
		SaveData ( Target );
	}
	
	return PLUGIN_HANDLED;
}

public ClCmdGiveDusts ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 3, false ) )
	{
		return PLUGIN_HANDLED;
	}
    
	new Arg1 [32], Arg2 [16];
    
	read_argv ( 1, Arg1, charsmax ( Arg1 ) );
	read_argv ( 2, Arg2, charsmax ( Arg2 ) );

	new Amount = str_to_num ( Arg2 );

	if ( equal ( Arg1, "@all" ) )
	{
		for ( new i = 1; i < MaxPlayers; i ++ )
		{
			if ( iLogged [i] )
			{
				iUserDusts [i] += Amount;

				SaveData ( i );
			}
		}

		console_print ( id, "[CS:GO Infinity] Ai dat tuturor jucatorilor %d fragmente", Amount );
			
		LogToFile ( "[INFO] - %s a dat tututor jucatorilor %d fragmente", Name [id], Amount );

		client_print_color ( 0, 0, "%s Adminul^4 %s^1 a dat tuturor jucatorilor^3 %d fragmente", CHAT_PREFIX, Name [id], Amount );
	}
	else
	{
		new Target = cmd_target ( id, Arg1, 3 );
    
		if ( !Target )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul nu a fost gasit!" );
			
			return PLUGIN_HANDLED;
		}
		
		if ( !iLogged [Target] )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul %s nu este logat!", Name [Target] );
			
			return PLUGIN_HANDLED;
		}

		if ( Amount < 0 )
		{
			replace ( Arg2, charsmax ( Arg2 ), "-", "" );
			
			Amount = str_to_num ( Arg2 );
			
			iUserDusts [Target] -= Amount;
	       
			if ( iUserDusts [Target] < 0 )
			{
				iUserDusts [Target] = 0;
			}
		
			console_print ( id, "[CS:GO Infinity] Ai luat de la %s %d fragmente", Name [Target], Amount );
			
			LogToFile ( "[INFO] - %s i-a luat lui %s %d fragmente", Name [id], Name [Target], Amount );

			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a luat^3 %d fragmente", CHAT_PREFIX, Name [id], Amount );
		}
		else
		{
			iUserDusts [Target] += Amount;
				
			console_print ( id, "[CS:GO Infinity] I-ai dat lui %s %d fragmente", Name [Target], Amount );

			LogToFile ( "[INFO] - %s i-a dat lui %s %d fragmente", Name [id], Name [Target], Amount );
				
			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a dat^3 %d fragmente", CHAT_PREFIX, Name [id], Amount );
			
			//return PLUGIN_HANDLED;
		}
	
		SaveData ( Target );
	}
	
	return PLUGIN_HANDLED;
}

public ClCmdSetRang ( id, level, cid )
{
	if (!cmd_access ( id, level, cid, 3, false ) )
	{
		return PLUGIN_HANDLED;
	}
   
	new Arg1 [32], Arg2 [8];
	
	read_argv ( 1, Arg1, charsmax ( Arg1 ) );
	read_argv ( 2, Arg2, charsmax ( Arg2 ) );
	
	new Target = cmd_target ( id, Arg1, charsmax ( Arg1 ) );
	
	if ( !Target )
	{
		console_print ( id, "[CS:GO Infinity] Jucatorul nu a fost gasit!" );
		
		return PLUGIN_HANDLED;
	}
	
	if ( !iLogged [Target] )
	{
		console_print ( id, "[CS:GO Infinity] Jucatorul %s nu este logat!", Name [Target] );
		
		return PLUGIN_HANDLED;
	}
	
	new Rang = str_to_num ( Arg2 );
	
	if ( Rang < 0 || Rang >= RangsNum )
	{
		console_print ( id, "[CS:GO Infinity] RangID gresit! Alege un numar intre 0 si %d", RangsNum -1 );
		
		return PLUGIN_HANDLED;
	}

	iUserRang [Target] = Rang;
    
	if ( Rang )
	{
		iUserKills [Target] = RangKills [Rang];
		
		UserMaxRang [Target] = Rang;
	}
	else
	{
		iUserKills [Target] = 0;
	}
	
	SaveData ( Target );
	
	console_print ( id, "[CS:GO Infinity] Ai setat jucatorului %s rang-ul %s", Arg1, RangName [iUserRang [Target]] );

	LogToFile ( "[INFO] - %s i-a setat lui %s Rangul %s", Name [id], Name [Target], RangName [iUserRang [Target]] );
   
	client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a setat rang-ul^4 %s", CHAT_PREFIX, Name [id], RangName [iUserRang [Target]] );
   
	return PLUGIN_HANDLED;
}

public ClCmdGiveAllSkins ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 2, false ) )
	{
		return PLUGIN_HANDLED;
	}

	new Arg1 [32], Arg2 [6];

	read_argv ( 1, Arg1, charsmax ( Arg1 ) );

	read_argv ( 2, Arg2, charsmax ( Arg2 ) );

	new Target = cmd_target ( id, Arg1, 3 );

	new Type = str_to_num ( Arg2 );

	if ( !Target )
	{
		console_print ( id, "[CS:GO Infinity] Jucatorul nu a fost gasit!" );
		
		return PLUGIN_HANDLED;
	}
	
	if ( !iLogged [Target] )
	{
		console_print ( id, "[CS:GO Infinity] Jucatorul %s nu este logat!", Name [Target] );
		
		return PLUGIN_HANDLED;
	}

	switch ( Type )
	{
		case 0:
		{
			for ( new i = 1; i < SkinsNum; i ++ )
			{
				iUserSkins [Target] [i] += 1;
			}

			console_print ( id, "[CS:GO Infinity] I-ai dat lui %s toate skin-urile (Common)", Name [Target] );

			LogToFile ( "[INFO] - %s i-a dat lui %s toate skin-urile (Common)", Name [id], Name [Target] );
					
			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a dat toate skin-urile^4 (Common)", CHAT_PREFIX, Name [id] );
		}
		case 1:
		{
			for ( new i = 1; i < SkinsNum; i ++ )
			{
				iUserSkins [Target] [i] += 1;

				iUserSTs [Target] [i] += 1;
			}

			console_print ( id, "[CS:GO Infinity] I-ai dat lui %s toate skin-urile (StatTrak)", Name [Target] );

			LogToFile ( "[INFO] - %s i-a dat lui %s toate skin-urile (StatTrak)", Name [id], Name [Target] );
					
			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a dat toate skin-urile^4 (StatTrak)", CHAT_PREFIX, Name [id] );
		}
		default:
		{
			console_print ( id, "SkinType gresit! [0-normal | 1-stattrak]" );

			return PLUGIN_HANDLED;
		}
	}

	SaveData ( Target );
	
	return PLUGIN_HANDLED;
}

public ClCmdGiveSkins ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 5, false ) )
	{
		return PLUGIN_HANDLED;
	}

	new Arg1 [32], Arg2 [8], Arg3 [6], Arg4 [16];
	
	read_argv ( 1, Arg1, charsmax ( Arg1 ) );
	read_argv ( 2, Arg2, charsmax ( Arg2 ) );
	read_argv ( 3, Arg3, charsmax ( Arg3 ) );
	read_argv ( 4, Arg4, charsmax ( Arg4 ) );
	
	new Target = cmd_target ( id, Arg1, 3 );
    
	new Skin = str_to_num ( Arg2 );

	new Type = str_to_num ( Arg3 );
	
	if ( !Target )
	{
		console_print ( id, "[CS:GO Infinity] Jucatorul nu a fost gasit!" );
		
		return PLUGIN_HANDLED;
	}
	
	if ( !iLogged [Target] )
	{
		console_print ( id, "[CS:GO Infinity] Jucatorul %s nu este logat!", Name [Target] );
		
		return PLUGIN_HANDLED;
	}
	
	if ( Skin < 1 || Skin >= SkinsNum )
	{
		console_print ( id, "[CS:GO Infinity] SkinID gresit! Alege un numar intre 1 si %d", SkinsNum - 1 );
		
		return PLUGIN_HANDLED;
	}

	new Amount = str_to_num ( Arg4 );
  
    	switch ( Type )
    	{
    		case 0:
		{
			if ( Amount < 0 )
			{
				replace ( Arg3, charsmax ( Arg3 ), "-", "" );
				
				Amount = str_to_num ( Arg3 );
				
				iUserSkins [Target] [Skin] -= Amount;
		       
				if ( iUserSkins [Target] [Skin] < 0 )
				{
					iUserSkins [Target] [Skin] = 0;
				}
			
				console_print ( id, "[CS:GO Infinity] Ai luat de la %s %d x %s", Name [Target], Amount, SkinName [Skin] );
				
				LogToFile ( "[INFO] - %s i-a luat lui %s %d x %s", Name [id], Name [Target], Amount, SkinName [Skin] );

				client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a luat^4 %d^1 x^3 %s", CHAT_PREFIX, Name [id], Amount, SkinName [Skin] );
			}
			else
			{
				iUserSkins [Target] [Skin] += Amount;
					
				console_print ( id, "[CS:GO Infinity] I-ai dat lui %s %d x %s", Name [Target], Amount, SkinName [Skin] );

				LogToFile ( "[INFO] - %s i-a dat lui %s %d x %s", Name [id], Name [Target], Amount, SkinName [Skin] );
					
				client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a dat^4 %d^1 x^3 %s", CHAT_PREFIX, Name [id], Amount, SkinName [Skin] );
			}
		}
		case 1:
		{
			if ( Amount < 0 )
			{
				replace ( Arg3, charsmax ( Arg3 ), "-", "" );
				
				Amount = str_to_num ( Arg3 );
				
				iUserSkins [Target] [Skin] -= Amount;

				iUserSTs [Target] [Skin] -= Amount;
		       
				if ( iUserSTs [Target] [Skin] < 0 )
				{
					iUserSkins [Target] [Skin] = 0;

					iUserSTs [Target] [Skin] = 0;

					STKills [Target] [Skin] = 0;
				}
			
				console_print ( id, "[CS:GO Infinity] Ai luat de la %s %d x %s (StatTrak)", Name [Target], Amount, SkinName [Skin] );
				
				LogToFile ( "[INFO] - %s i-a luat lui %s %d x %s (StatTrak)", Name [id], Name [Target], Amount, SkinName [Skin] );

				client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a luat^4 %d^1 x^3 %s^4 (^3StatTrak^4)", CHAT_PREFIX, Name [id], Amount, SkinName [Skin] );
			}
			else
			{
				iUserSkins [Target] [Skin] += Amount;

				iUserSTs [Target] [Skin] += Amount;
					
				console_print ( id, "[CS:GO Infinity] I-ai dat lui %s %d x %s (StatTrak)", Name [Target], Amount, SkinName [Skin] );

				LogToFile ( "[INFO] - %s i-a dat lui %s %d x %s (StatTrak)", Name [id], Name [Target], Amount, SkinName [Skin] );

				client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a dat^4 %d^1 x^3 %s^4 (^3StatTrak^4)", CHAT_PREFIX, Name [id], Amount, SkinName [Skin] );
			}
		}	
		default:
		{
			console_print ( id, "SkinType gresit! [0-normal | 1-stattrak]" );

			return PLUGIN_HANDLED;
		}
	}
	
	SaveData ( Target );
	
	return PLUGIN_HANDLED;
}

public ClCmdGiveGloveBox ( id, level, cid )
{
	if ( !cmd_access ( id, level, cid, 3, false ) )
	{
		return PLUGIN_HANDLED;
	}
    
	new Arg1 [32], Arg2 [16];
    
	read_argv ( 1, Arg1, charsmax ( Arg1 ) );
	read_argv ( 2, Arg2, charsmax ( Arg2 ) );

	new Amount = str_to_num ( Arg2 );

	if ( equal ( Arg1, "@all" ) )
	{
		for ( new i = 1; i < MaxPlayers; i ++ )
		{
			if ( iLogged [i] )
			{
				iUserGloveBoxes [i] += Amount;

				SaveData ( i );
			}
		}
	
		console_print ( id, "[CS:GO Infinity] Ai dat tuturor jucatorilor %d Gloves Box", Amount );
			
		LogToFile ( "[INFO] - %s a dat tututor jucatorilor %d Gloves Box", Name [id], Amount );

		client_print_color ( 0, 0, "%s Adminul^4 %s^1 a dat tuturor jucatorilor^3 %d Gloves Box", CHAT_PREFIX, Name [id], Amount );
	}
	else
	{
		new Target = cmd_target ( id, Arg1, 3 );
	    
		if ( !Target )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul nu a fost gasit!" );
			
			return PLUGIN_HANDLED;
		}
		
		if ( !iLogged [Target] )
		{
			console_print ( id, "[CS:GO Infinity] Jucatorul %s nu este logat!", Name [Target] );
			
			return PLUGIN_HANDLED;
		}
		
		if ( Amount < 0 )
		{
			replace ( Arg2, charsmax ( Arg2 ), "-", "" );
			
			Amount = str_to_num ( Arg2 );
			
			iUserGloveBoxes [Target] -= Amount;
	       
			if ( iUserGloveBoxes [Target] < 0 )
			{
				iUserGloveBoxes [Target] = 0;
			}

			console_print ( id, "[CS:GO Infinity] Ai luat de la %s %d Gloves Box", Name [Target], Amount );
			
			LogToFile ( "[INFO] - %s i-a luat lui %s %d Gloves Box", Name [id], Name [Target], Amount );

			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a luat^3 %d Gloves Box", CHAT_PREFIX, Name [id], Amount );
		}
		else
		{
			iUserGloveBoxes [Target] += Amount;

			console_print ( id, "[CS:GO Infinity] I-ai dat lui %s %d Gloves Box", Name [Target], Amount );
				
			LogToFile ( "[INFO] - %s i-a dat lui %s %d Gloves Box", Name [id], Name [Target], Amount );

			client_print_color ( Target, Target, "%s Adminul^4 %s^1 ti-a dat^3 %d Gloves Box", CHAT_PREFIX, Name [id], Amount );
			
			//return PLUGIN_HANDLED;
		}

		SaveData ( Target );
	}
	
	return PLUGIN_HANDLED;
}


public NativeIsUserLogged (  ) return iLogged [get_param ( 1 )];

public NativeGetUserPoints ( iPluginID, iParamNum )
{
	if ( iParamNum != 1 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID)" );
		
		return -1;
	}
	
	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
       
		return -1;
	}
	
	return iUserPoints [id];
}

public NativeSetUserPoints ( iPluginID, iParamNum )
{
	if ( iParamNum != 2 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID, Amount)" );
		
		return 0;
	}
    
	new id = get_param ( 1 );
   
	if ( !is_user_connected ( id ) )
	{
		log_error  (10, "[CS:GO Infinity] Player is not connected (%d)", id );
		
		return 0;
	}
    
	new Amount = get_param ( 2 );
    
	if ( Amount < 0 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid amount value (%d)", Amount );
		
		return 0;
	}
    
	iUserPoints [id] = Amount;
    
	return 1;
}

public NativeGetUserDusts ( iPluginID, iParamNum )
{
	if ( iParamNum != 1 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID)" );
		
		return -1;
	}

	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
		
		return -1;
	}
   
	return iUserDusts [id];
}

public NativeSetUserDusts ( iPluginID, iParamNum )
{
	if ( iParamNum != 2 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID, Amount)" );
       
		return 0;
	}
	
	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
		
		return 0;
	}
    
	new Amount = get_param ( 2 );
   
	if ( Amount < 0 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid amount value (%d)", Amount );
		
		return 0;
	}
    
	iUserDusts [id] = Amount;
    
	return 1;
}

public NativeGetUserChests ( iPluginID, iParamNum )
{
	if ( iParamNum != 2 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID, ChestID)" );
		
		return -1;
	}
  
	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
        
		return -1;
	}
	
	new Chest = get_param ( 2 );
   
	if ( Chest < 1 || Chest >= ChestsNum )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid ChestID (%d)", ChestsNum -1 -1 );
        
		return -1;
	}
    
	new Amount = iUserChests [id] [Chest];
  
	return Amount;
}

public NativeSetUserChests ( iPluginID, iParamNum )
{
	if ( iParamNum != 3 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID, ChestID, Amount)" );
		return 0;
	}
	
	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
		
		return 0;
	}
	
	new Chest = get_param ( 2 );
	
	if ( Chest < 0 || Chest >= ChestsNum )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid ChestID (%d)", ChestsNum -1 );
		
		return 0;
	}
	
	new Amount = get_param ( 3 );
	
	if ( Amount < 0 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid amount value (%d)", Amount );
		
		return 0;
	}
	
	iUserChests [id] [Chest] = Amount;
    
	return 1;
}

public NativeGetUserKeys ( iPluginID, iParamNum )
{
	if ( iParamNum != 2 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID, KeyID)" );
		
		return -1;
	}
  
	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
        
		return -1;
	}
	
	new Key = get_param ( 2 );
   
	if ( Key < 1 || Key >= ChestsNum )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid KeyID (%d)", ChestsNum -1 );
        
		return -1;
	}
    
	new Amount = iUserKeys [id] [Key];
  
	return Amount;
}

public NativeSetUserKeys ( iPluginID, iParamNum )
{
	if ( iParamNum != 3 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID, KeyID, Amount)" );
		return 0;
	}
	
	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
		
		return 0;
	}
	
	new Key = get_param ( 2 );
	
	if ( Key < 1 || Key >= ChestsNum )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid KeyID (%d)", ChestsNum -1 );
		
		return 0;
	}
	
	new Amount = get_param ( 3 );
	
	if ( Amount < 0 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid amount value (%d)", Amount );
		
		return 0;
	}
	
	iUserKeys [id] [Key] = Amount;
    
	return 1;
}

public NativeGetUserSkins ( iPluginID, iParamNum )
{
	if ( iParamNum != 2 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID, SkinID)" );
		
		return -1;
	}
  
	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
        
		return -1;
	}
	
	new Skin = get_param ( 2 );
   
	if ( Skin < 0 || Skin >= SkinsNum )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid SkinID (%d)", Skin -1 );
        
		return -1;
	}
    
	new Amount = iUserSkins [id] [Skin];
  
	return Amount;
}

public NativeSetUserSkins ( iPluginID, iParamNum )
{
	if ( iParamNum != 3 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID, SkinID, Amount)" );
		return 0;
	}
	
	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
		
		return 0;
	}
	
	new Skin = get_param ( 2 );
	
	if ( Skin < 0 || Skin >= SkinsNum )
	{
		log_error ( 10, "[CSGO UltimateX] Invalid SkinID (%d)", Skin -1 );
		
		return 0;
	}
	
	new Amount = get_param ( 3 );
	
	if ( Amount < 0 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid amount value (%d)", Amount );
		
		return 0;
	}
	
	iUserSkins [id] [Skin] = Amount;
    
	return 1;
}

public NativeGetUserSTSkins ( iPluginID, iParamNum )
{
	if ( iParamNum != 2 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID, SkinID)" );
		
		return -1;
	}
  
	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
        
		return -1;
	}
	
	new Skin = get_param ( 2 );
   
	if ( Skin < 0 || Skin >= SkinsNum )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid SkinID (%d)", Skin -1 );
        
		return -1;
	}
    
	new Amount = iUserSTs [id] [Skin];
  
	return Amount;
}

public NativeSetUserSTSkins ( iPluginID, iParamNum )
{
	if ( iParamNum != 3 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID, SkinID, Amount)" );
		return 0;
	}
	
	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
		
		return 0;
	}
	
	new Skin = get_param ( 2 );
	
	if ( Skin < 0 || Skin >= SkinsNum )
	{
		log_error ( 10, "[CSGO UltimateX] Invalid SkinID (%d)", Skin -1 );
		
		return 0;
	}
	
	new Amount = get_param ( 3 );
	
	if ( Amount < 0 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid amount value (%d)", Amount );
		
		return 0;
	}
	
	iUserSkins [id] [Skin] = Amount;
	iUserSTs [id] [Skin] = Amount;
    
	return 1;
}

public NativeGetUserRang ( iPluginID, iParamNum )
{
	if ( iParamNum != 1 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID)" );
		
		return -1;
	}

	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
		
		return -1;
	}
    
	new Len = get_param ( 3 );
	
	set_string ( 2, RangName [iUserRang [id]], Len );
   
	return iUserRang [id];
}

public NativeSetUserRang ( iPluginID, iParamNum )
{
	if ( iParamNum != 2 )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid param num! Valid: (PlayerID, Amount)" );
       
		return 0;
	}
	
	new id = get_param ( 1 );
	
	if ( !is_user_connected ( id ) )
	{
		log_error ( 10, "[CS:GO Infinity] Player is not connected (%d)", id );
		
		return 0;
	}
    
	new Rang = get_param ( 2 );
   
	if ( Rang < 0 || Rang >= RangsNum )
	{
		log_error ( 10, "[CS:GO Infinity] Invalid RangID (%d)", Rang -1 );
		
		return 0;
	}
    
	iUserRang [id] = Rang;
	
	iUserKills [id] = RangKills [Rang - 1];
    
	return 1;
}

public NativeIsWarmup (  ) return WarmUp;

public NativeGetUserHands (  ) return g_iUserViewBody [get_param ( 1 )];

public NativeSetUserHands( iParamID, iPluginID )
{
	g_iUserViewBody [get_param ( 1 )] = get_param(2)
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

MakeStringSQLSafeAll ( Output [ ], Len )
{
	replace_all ( Output, Len, "\", "" );
	replace_all ( Output, Len, "'", "" );
	replace_all ( Output, Len, "^"", "" );
	replace_all ( Output, Len, "^n", "" );
	replace_all ( Output, Len, "^x00", "" );
	replace_all ( Output, Len, "^x1a", "" );
}

stock GetSkinClass ( Index )
{
	new Temp [128];

	if ( 100 - SkinChance [Index] > 34 )
	{
		formatex ( Temp, charsmax ( Temp ), "Common" );
	}
	else if ( 100 - SkinChance [Index] > 14 )
	{
		formatex ( Temp, charsmax ( Temp ), "Rare" );
	}
	else if ( 100 - SkinChance [Index] > 1 )
	{
		formatex ( Temp, charsmax ( Temp ), "Mythical" );
	}
	else if ( 100 - SkinChance [Index] == 1 )
	{
		formatex ( Temp, charsmax ( Temp ), "Legendary" );
	}

	return Temp;
}

stock GetSTClass ( id, Index )
{
	new Temp [128];

	if ( STKills [id] [Index] > 2000 )
	{
		formatex ( Temp, charsmax ( Temp ), "Battle-Scared" );
	}
	else if ( STKills [id] [Index] > 1500 )
	{ 
		formatex ( Temp, charsmax ( Temp ), "Well-Worn" );
	}
	else if ( STKills [id] [Index] > 1000 )
	{
		formatex ( Temp, charsmax ( Temp ), "Field-Tested" );
	}
	else if ( STKills [id] [Index] > 500 )
	{ 
		formatex ( Temp, charsmax ( Temp ), "Minimal Wear" );
	}
	else if ( STKills [id] [Index] >= 0 )
	{
		formatex ( Temp, charsmax ( Temp ), "Factory New" );
	}

	return Temp;
}

stock set_hp ( id )
{
	new hp = pev ( id, pev_health) ;

	if ( hp < 100.0 )
	{
		if ( hp + float ( sInjectorHeal ) > 100.0 )
		{
			set_pev ( id, pev_health, 100.0 );
		}
		else 
		{
			set_pev ( id, pev_health, hp + float ( sInjectorHeal ) );
			
			//emit_sound(plr, CHAN_BODY, heal_sound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
	}
}
	
public LogToFile ( const Msg [ ], any:...)
{
	new Message [256];

	vformat ( Message, charsmax ( Message ), Msg , 2 );
	
	new Folder [64], File  [128], Log [256], LogTime [32];

	get_time ( "%d.%m.%Y - %H:%M:%S", LogTime, charsmax ( LogTime ) );
	
	if ( !Folder [0] )
	{	
		get_basedir ( Folder, sizeof ( Folder ) -1 );

		formatex ( File, charsmax ( File ),"%s/logs/csgo_infinity.log", Folder );
	}
	
	formatex ( Log, charsmax ( Log ), "|%s| %s ", LogTime, Message );

	write_file ( File, Log, -1 );

	return PLUGIN_HANDLED;
}

stock bool: ValidMdl ( Mdl [ ] )
{
	if ( containi ( Mdl, ".mdl" ) != -1 )
	{
		return true;
	}

	return false;
}

stock bool: ValidSnd ( Snd [ ] )
{
	if ( containi ( Snd, ".mp3" ) || containi ( Snd, ".wav" ) )
	{
		return true;
	}

	return false;
}

stock SendSpectatorAnim ( id, Anim )
{
	for ( new iSpectator = 1; iSpectator < 33; iSpectator ++ )
	{			
		if ( is_user_connected ( iSpectator ) && !is_user_alive ( iSpectator ) && !is_user_bot ( iSpectator ) )	
		{				
			if ( pev ( iSpectator, pev_iuser2 ) == id )
			{				
				SendWeaponAnim ( iSpectator, Anim );
			}
		}
	}	
}

stock SendWeaponAnim ( id, Anim, iIndex = 0 ) 
{
	new ids = id;

	if ( !is_user_alive ( ids ) )
	{
		ids = pev ( id, pev_iuser2 );

		if ( !is_user_alive ( ids ) )
		{
			return;
		}
	}

	//CurrentWeapon(id);

	g_iUserViewBody[ids] = GloveIndex [g_iUserSelectedGlove [ids]] + g_iUserSelectedSkin[ids][iIndex > 0 ? iIndex : cs_get_user_weapon(ids)];

	//server_print("%d, index: %d", g_iUserSelectedSkin[ids][iIndex > 0 ? iIndex : cs_get_user_weapon(ids)], iIndex > 0 ? iIndex : cs_get_user_weapon(ids))

	//SetViewEntityBody(ids, g_iUserViewBody[ids])

	static iBody;
	
	iBody = g_iUserViewBody [ids];

	//client_print(id, print_chat, "Body: %i", iBody);

	set_pev ( id, pev_weaponanim, Anim );
	
	message_begin ( MSG_ONE, SVC_WEAPONANIM, _, id );

	write_byte ( Anim );

	write_byte ( iBody );

	message_end (  );	
}

public MessageScreenFade ( id, iDuration, iHold, FadeMode, iRed, iGreen, iBlue, iAlpha )
{
	if ( !is_user_connected ( id ) ) return PLUGIN_CONTINUE;

   	message_begin ( MSG_ONE_UNRELIABLE, get_user_msgid ( "ScreenFade" ), { 0, 0, 0 }, id );
   	write_short ( iDuration );
    	write_short ( iHold );
   	write_short ( FadeMode );
   	write_byte ( iRed );
   	write_byte ( iGreen );
   	write_byte ( iBlue );
   	write_byte ( iAlpha );
   	message_end  (   );

	return PLUGIN_CONTINUE;
}

AddCommas ( iNum, szOutput [], iLen ) 
{
	static Tmp [15], Pos, Num, Len;

	Tmp [0] = '^0', Pos = Num = Len = 0;

	if ( iNum < 0 ) 
	{
		szOutput [Pos++] = '-';

		iNum = abs ( iNum );
	}

	Len = num_to_str ( iNum, Tmp, charsmax ( Tmp) );

	if ( Len <=3 )
	{
		Pos += copy ( szOutput [Pos], iLen, Tmp );
	}
	else 
	{
		while ( ( Num < Len ) && ( Pos < iLen ) )
		{
			szOutput [Pos++] = Tmp [Num++];

			if ( ( Len - Num ) && !( ( Len - Num ) % 3 ) )

				szOutput [Pos++] = ',';
		}

		szOutput [Pos] = EOS;
	}

	return Pos;
}