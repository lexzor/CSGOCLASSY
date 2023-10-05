#include <amxmodx>
#include <amxconst>
#include <amxmisc>
#include <nvault>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <engine>
#include <csgoclassy>
#include <sqlx>
#include <reapi>

#pragma dynamic 32768
#pragma compress 1

#define VERSION "2.4D"
/* SERVERS

51.75.87.38:27015 - go16.elders.ro 
93.114.82.249:27015 - csgo.arenag.ro
188.212.102.30:27015 - csgo.darkland.ro
141.95.93.16:27015 - cs.csblackdevil.com 
172.18.0.3:27015 - csgo.legioncs.ro // DNS MODE 1
93.114.82.108:27015 - skynet 
172.18.0.12:27015 - hard.indungi.ro
188.212.100.232:27015 - csgo.oldgaming.nl
172.18.0.32:27015 - add.leaguecs.ro // DNS MODE 1
45.95.38.12:27015 - gox.blackgames.ro // DNS MODE 1
93.114.82.91:27015 - CSGO.HECKERS.RO
188.212.102.130:27015 - CSGO.CSPOWER.RO
188.212.100.79:27015 - global nebunaticii
188.212.102.102:27015 - CSE.WESTCSTRIKE.RO
51.38.104.190:27015 - bifanul
188.212.102.13:27015 - reddix
213.226.71.126:27015 - star.cspower.ro - dudu // DNS MODE 1;
51.77.76.159:27015 - CS.BLACKLIFE.RO // DNS MODE 1
93.114.82.36:27015 - testing server GO.WESTCSTRIKE.RO
188.212.102.92:27015 - fun.westrike.ro
131.196.198.52:27055 -> brazilianu
172.18.0.3:27015 -> marty
51.38.104.190:27015 -> csgo.kranci.ro
89.40.233.106:27015 -> robert
93.114.82.106:27015 -> sandu

//last version
172.18.0.2:27015 - devilboy extreamcs
188.212.101.144:27015 - go.weststrike.ro
188.212.102.180:27015 - CSGO.NEBUNATICII.RO
188.212.101.238:27015 - TEST ERAZER
188.212.101.21:27015 - csgo.erazer.ro 
*/

#define LICENSED_IP "188.212.101.238:27015"
#define TOTAL_SKINS 1025
static const MODE = 0; // 1 - DNS, 0 - IP

#define MENU_PREFIX "\y[\dCSGO Classy\y]\w"
#define CHAT_PREFIX "^4[^3CSGO Classy^4]^1"
#define CONSOLE_PREFIX "[CSGO Classy]"

#define MAIN_MENU_DEFAULT_ITEMS_COUNT 14
#define INVENTORY_DEFAULT_ITEMS_COUNT 3
#define GAMBLING_DEFAULT_ITEMS_COUNT 4
#define SETTINGS_DEFAULT_ITEMS_COUNT 2

#define NVAULT_PRUNE_DAYS 30

#define SKIN_LIMIT 5
#define DEFAULT_SKIN 3812
#define MAX_SKINS 10

#define MAX_SKIN_TAG_LENGTH 15
// #define OPEN_DELAY 1
#define MAX_GLOVES 5
#define MAX_RANG_NAME_LENGTH 32

#define CS_MAX_WEAPONS MAX_WEAPONS - 1

#define MIN_SKINS_TO_UPGRADE 5
#define GLOVES_FILE_NAME "gloves.cfg"
#define CONFIG_FILE_NAME "csgoclassy.cfg"
#define INI_FILE_NAME "csgoclassy.ini"

#define CSGO_CONFIG_DIRECTORY "csgoclassy" 
#define LOG_FILE "csgoclassy_errors.log"

#define XO_PLAYER 5
#define CSW_SHIELD  2
#define IsValidPlayer(%0) (1 <= %0 <= 32)
#define NO_BODY_PART -1
#define MAX_SQL_NAME_LENGTH (MAX_NAME_LENGTH * 3)

#define NO_SKIN_VALUE 2000

#define SET_DEFAULT_MODEL -1

native isUsingSomeoneElsesWeapon(id, weaponID);
native getOriginalOwnerID(owner, weaponid);
native isUsingCertainPlayersSkin(iPlayer, id, iWeaponID);

native cs_set_viewmodel_body(id, weaponId, iBodyPart);
native cs_set_modelformat(id, weaponId, viewModel[]);

enum (+= 1234)
{
	TASK_GIVEAWAY = 532,
	TASK_SWAP,
	TASK_JACKPOT,
	TASK_WARMUP,
	TASK_RESPAWN,
	TASK_FORCE_DEPLOY,
	TASK_RESTORE_PREVIOUS_SKIN,
	TASK_REMOVE_AWP_SECONDARY,
	TASK_PLAYED_TIME
}

enum _:WEAPONS 
{
	WeapName[64],
	WeaponID
}

enum _:WEAPONS_TYPE
{
	WeaponsID,
	WeaponsType
}

enum _:GLOVESINFO
{
	szGloveName[64],
	iMaxPrice,
	iMinPrice,
	iVIPOnly,
	iDropChance
}

enum _:DEFAULT_MODEL
{
	PATH[128],
	BODYINDEX
}

enum _:COUNTER
{
	MAIN_MENU_DEFAULT_ITEMS,
	INVENTORY_DEFAULT_ITEMS,
	GAMBLING_DEFAULT_ITEMS,
	SETTINGS_DEFAULT_ITEMS
}

enum MENU_ITEMS
{
	Array:aMainMenu,
	Array:aInventoryMenu,
	Array:aGamblingMenu,
	Array:aSettingsMenu
}

enum _:MENU_DATA 
{
	szMenuName[MAX_MENU_ITEM_LENGTH],
	iMinRankAccess,
	Trie:tUserMenuData
}

enum _:USER_MENU_DATA
{
	szAdditionalName[MAX_MENU_ITEM_LENGTH],
	iInventoryValue
}

enum _:FORWARDS 
{
	LOGIN,
	REGISTER,
	MENU_ITEM_SELECTED,
	CONFIG_EXECUTED
}

enum _:SQLDATA 
{
	SQL_HOST[64],
	SQL_USER[64],
	SQL_PASS[64],
	SQL_DB[64]
}

enum _:PlayerScopeData
{
	Float:ScopeTime, ScopeType
}

enum STATISTICS
{
	DROPPED_SKINS, //done
	DROPPED_STT_SKINS, //done
	WEAPON_KILL,
	RECEIVED_MONEY, //done
	RECEIVED_SCRAPS, //done
	DROPPED_CASES, //done
	DROPPED_KEYS, //done
	DROPPED_NAMETAG_CAPSULES, //done
	DROPPED_NAMETAG_MYTHICS, //done
	DROPPED_NAMETAG_RARE, //done
	DROPPED_NAMETAG_COMMON, //done
	DROPPED_GLOVE_CASES, //done
	DROPPED_GLOVES, //done
	DROPPED_GLOVE0, //done
	DROPPED_GLOVE1, //done
	DROPPED_GLOVE2, //done
	DROPPED_GLOVE3, //done
	DROPPED_GLOVE4, //done
	TOTAL_UPGRADES, //done
	TOTAL_DAILY_REWARDS, //done
	TOTAL_GIFTS, //done -> for server must be /2
	TOTAL_TRADES, //done -> for server must be /2
	TOTAL_COINFLIPS,//done -> for server must be /2
	TOTAL_GIVEAWAYS, //done
	TOTAL_CONTRACTS, //done
	TOTAL_ROULETTE, //done
	MARKET_ITEMS_SOLD, //done
	MARKET_ITEM_BOUGHT //done
}

enum _:RANG_DATA
{
	RANG_NAME[64],
	RANG_EXP
}

enum
{
	GLOVES_CONFIG 	= 	1,
	MODEL_CONFIG 	= 	2
}

enum 
{
	SELL_SKIN 		= 	0,
	SELL_CAPSULE 	= 	1,
	SELL_GLOVE 		= 	2
}

enum
{
	CONFIG_SQL 				= 	1,
	CONFIG_RANKS 			= 	2,
	CONFIG_RANGS			=	3,
	CONFIG_DEFAULT_SKINS 	= 	4,
	CONFIG_SKINS 			= 	5
}

enum
{
	CRAFT_SKIN 	= 	0,
	DROP_SKIN	=	1
}

enum 
{
	NVAULT 		= 	0,
	SQL 		= 	1
}

enum
{
	PLAYER_DATA 		=	0,
	PLAYER_SKINS 		=	1,
	USERS_STATISTICS	=	2,		
	SERVER_STATISTICS	=	3,		
}

enum 
{
	NAMETAG_NONE,
	NAMETAG_COMMON,
	NAMETAG_RARE,
	NAMETAG_MYTHIC
}

enum 
{
	GLOVE0,
	GLOVE1,
	GLOVE2,
	GLOVE3,
	GLOVE4,
}

static const g_iMaxBpAmmo[] =
{
	0, 30, 90, 200, 90, 32, 100, 100, 35, 52, 120
}

static const g_szTWin[] =
{
	"sound/csgoclassyv2/twin.wav"
}

static const g_szCTWin[] =
{
	"sound/csgoclassyv2/ctwin.wav"
}

static const g_szStatsName[][] =
{
	"DROPPED_SKINS", 
	"DROPPED_STT_SKINS", 
	"WEAPON_KILLS",
	"RECEIVED_MONEY", 
	"RECEIVED_SCRAPS", 
	"DROPPED_CASES", 
	"DROPPED_KEYS", 
	"DROPPED_NAMETAG_CAPSULES", 
	"DROPPED_NAMETAG_MYTHICS", 
	"DROPPED_NAMETAG_RARE", 
	"DROPPED_NAMETAG_COMMON", 
	"DROPPED_GLOVE_CASES", 
	"DROPPED_GLOVES", 
	"DROPPED_GLOVE0", 
	"DROPPED_GLOVE1", 
	"DROPPED_GLOVE2", 
	"DROPPED_GLOVE3", 
	"DROPPED_GLOVE4", 
	"TOTAL_UPGRADES", 
	"TOTAL_DAILY_REWARDS", 
	"TOTAL_GIFTS",
	"TOTAL_TRADES",
	"TOTAL_COINFLIPS",
	"TOTAL_GIVEAWAYS", 
	"TOTAL_CONTRACTS", 
	"TOTAL_ROULETTE", 
	"MARKET_ITEMS_SOLD", 
	"MARKET_ITEM_BOUGHT" 
}

static const g_szWeaponEntName[31][] =
{
	"",
	"weapon_p228",
	"",
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

static const 	MYSQL_HOST[] 		=	 	"MYSQL_HOST",
				MYSQL_USER[]		=	 	"MYSQL_USER",
				MYSQL_PASS[]	 	=		"MYSQL_PASS",
				MYSQL_DB[]			=		"MYSQL_DB";

static const g_szTables[][] = {
	"csgoclassy_player_data",
	"csgoclassy_skins",
	"csgoclassy_users_statistics",
	"csgoclassy_server_statistics",
}

static const g_szTablesInfo[][] = {
	"(`id` INT(11) NOT NULL AUTO_INCREMENT ,\
	`uname` VARCHAR(96) NOT NULL DEFAULT 'NONE' COLLATE utf8_bin  ,\
	`upassword` VARCHAR(33) NOT NULL DEFAULT 'NONE' COLLATE utf8_bin ,\
	`money` INT(11) NOT NULL DEFAULT 0 ,\
	`scraps` INT(11) NOT NULL DEFAULT 0 ,\
	`keys` INT(11) NOT NULL DEFAULT 0 ,\
	`cases` INT(11) NOT NULL DEFAULT 0 ,\
	`kills` INT(11) NOT NULL DEFAULT 0 ,\
	`rank` INT(2) NOT NULL DEFAULT 0 ,\
	`nametag_capsules` INT(11) NOT NULL DEFAULT 0 ,\
	`nametag_common` INT(11) NOT NULL DEFAULT 0 ,\
	`nametag_rare` INT(11) NOT NULL DEFAULT 0 ,\
	`nametag_mythic` INT(11) NOT NULL DEFAULT 0 ,\
	`chat_clear` INT(1) NOT NULL DEFAULT 0 ,\
	`cases_glove` INT(11) NOT NULL DEFAULT 0 ,\
	`use_default_skin` INT(1) NOT NULL DEFAULT 0 ,\
	`first_seen` VARCHAR(12) NOT NULL DEFAULT '0' ,\
	`last_seen` VARCHAR(12) NOT NULL DEFAULT '0' ,\
	`daily_bonus_time` int(12) NOT NULL DEFAULT 0 ,\
	`rang` int(3) NOT NULL DEFAULT 0 ,\
	`rang_experience` int(10) NOT NULL DEFAULT 0 ,\
	`played_time` int(12) NOT NULL DEFAULT 0 ,\
	`total_inventory` TEXT NOT NULL DEFAULT '0' ,\
	PRIMARY KEY(id, uname));",


	"(`id` INT(11) NOT NULL AUTO_INCREMENT ,\
	`uname` VARCHAR(96) NOT NULL DEFAULT 'NONE' COLLATE utf8_bin,\
	`skins` TEXT NOT NULL DEFAULT '0' ,\
	`stattrack_skins` TEXT NOT NULL DEFAULT '0' ,\
	`stattrack_kills` TEXT NOT NULL DEFAULT '0' ,\
	`selected_skins` TEXT NOT NULL DEFAULT '0' ,\
	`using_stattrak` TEXT NOT NULL DEFAULT '0' ,\
	`gloves` TEXT NOT NULL DEFAULT '0' ,\
	`weapon_gloves` TEXT NOT NULL DEFAULT '0' ,\
	`has_skin_nametag` TEXT NOT NULL DEFAULT '0' ,\
	`skin_tag` TEXT NOT NULL DEFAULT '0' ,\
	`tag_level` TEXT NOT NULL DEFAULT '0' ,\
	PRIMARY KEY(id));",


	"(`id` INT(11) NOT NULL AUTO_INCREMENT ,\
	`uname` VARCHAR(96) NOT NULL DEFAULT 'NONE' COLLATE utf8_bin,\
	`DROPPED_SKINS` TEXT NOT NULL DEFAULT '0' ,\
	`DROPPED_STT_SKINS` TEXT NOT NULL DEFAULT '0' ,\
	`WEAPON_KILLS` TEXT NOT NULL DEFAULT '0' ,\
	`RECEIVED_MONEY` INT(11) NOT NULL DEFAULT 0 ,\ 
	`RECEIVED_SCRAPS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_CASES` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_KEYS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_NAMETAG_CAPSULES` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_NAMETAG_MYTHICS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_NAMETAG_RARE` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_NAMETAG_COMMON` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE_CASES` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVES` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE0` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE1` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE2` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE3` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE4` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_UPGRADES` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_DAILY_REWARDS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_GIFTS` INT(11) NOT NULL DEFAULT 0 ,\  
	`TOTAL_TRADES` INT(11) NOT NULL DEFAULT 0 ,\  
	`TOTAL_COINFLIPS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_GIVEAWAYS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_CONTRACTS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_ROULETTE` INT(11) NOT NULL DEFAULT 0 ,\ 
	`MARKET_ITEMS_SOLD` INT(11) NOT NULL DEFAULT 0 ,\ 
	`MARKET_ITEM_BOUGHT` INT(11) NOT NULL DEFAULT 0 ,\
	PRIMARY KEY(id, uname));",


	"(`server_key` VARCHAR(32) NOT NULL ,\
	`DROPPED_SKINS` TEXT NOT NULL DEFAULT '0' ,\
	`DROPPED_STT_SKINS` TEXT NOT NULL DEFAULT '0' ,\
	`WEAPON_KILLS` TEXT NOT NULL DEFAULT '0' ,\
	`RECEIVED_MONEY` INT(11) NOT NULL DEFAULT 0 ,\ 
	`RECEIVED_SCRAPS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_CASES` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_KEYS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_NAMETAG_CAPSULES` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_NAMETAG_MYTHICS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_NAMETAG_RARE` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_NAMETAG_COMMON` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE_CASES` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVES` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE0` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE1` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE2` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE3` INT(11) NOT NULL DEFAULT 0 ,\ 
	`DROPPED_GLOVE4` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_UPGRADES` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_DAILY_REWARDS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_GIFTS` INT(11) NOT NULL DEFAULT 0 ,\  
	`TOTAL_TRADES` INT(11) NOT NULL DEFAULT 0 ,\  
	`TOTAL_COINFLIPS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_GIVEAWAYS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_CONTRACTS` INT(11) NOT NULL DEFAULT 0 ,\ 
	`TOTAL_ROULETTE` INT(11) NOT NULL DEFAULT 0 ,\ 
	`MARKET_ITEMS_SOLD` INT(11) NOT NULL DEFAULT 0 ,\ 
	`MARKET_ITEM_BOUGHT` INT(11) NOT NULL DEFAULT 0 ,\
	PRIMARY KEY(server_key));",
}

static const g_szStatsLang[][] =
{
	"MENU_DROPPED_SKINS", 
	"MENU_DROPPED_STT_SKINS", 
	"MENU_WEAPON_KILLS",
	"MENU_RECEIVED_MONEY", 
	"MENU_RECEIVED_SCRAPS", 
	"MENU_DROPPED_CASES", 
	"MENU_DROPPED_KEYS", 
	"MENU_DROPPED_NAMETAG_CAPSULES", 
	"MENU_DROPPED_NAMETAG_MYTHICS", 
	"MENU_DROPPED_NAMETAG_RARE", 
	"MENU_DROPPED_NAMETAG_COMMON", 
	"MENU_DROPPED_GLOVE_CASES", 
	"MENU_DROPPED_GLOVES", 
	"MENU_DROPPED_GLOVE0", 
	"MENU_DROPPED_GLOVE1", 
	"MENU_DROPPED_GLOVE2", 
	"MENU_DROPPED_GLOVE3", 
	"MENU_DROPPED_GLOVE4", 
	"MENU_TOTAL_UPGRADES", 
	"MENU_TOTAL_DAILY_REWARDS", 
	"MENU_TOTAL_GIFTS",
	"MENU_TOTAL_TRADES",
	"MENU_TOTAL_COINFLIPS",
	"MENU_TOTAL_GIVEAWAYS", 
	"MENU_TOTAL_CONTRACTS", 
	"MENU_TOTAL_ROULETTE", 
	"MENU_MARKET_ITEMS_SOLD", 
	"MENU_MARKET_ITEM_BOUGHT" 
}

static const g_WeapMenu[][WEAPONS] =
{
	{"Knives", CSW_KNIFE},
	{"AK-47", CSW_AK47},
	{"M4A1-S and M4A4", CSW_M4A1},
	{"AWP", CSW_AWP},	
	{"Deagle", CSW_DEAGLE},
	{"Glock", CSW_GLOCK18},
	{"USP-S", CSW_USP},
	{"Famas", CSW_FAMAS},
	{"Galil-AR", CSW_GALIL},
	{"AUG", CSW_AUG},
	{"SSG", CSW_SCOUT},
	{"SG552", CSW_SG552},
	{"SG550", CSW_SG550},
	{"G3SG1", CSW_G3SG1},
	{"Negev", CSW_M249},
	{"MP7", CSW_MP5NAVY},
	{"MP9", CSW_TMP},
	{"UMP-45", CSW_UMP45},
	{"MAC-10", CSW_MAC10},
	{"P90", CSW_P90},
	{"P250", CSW_P228},
	{"FiveSeven", CSW_FIVESEVEN},
	{"Dual Berettas", CSW_ELITE},
	{"XM1014", CSW_XM1014},
	{"Nova", CSW_M3}
}

static const g_szDefaultSkinModels[][] = {
	"",
	"models/v_p228.mdl",
	"",
	"models/v_scout.mdl",
	"models/v_hegrenade.mdl",
	"models/v_xm1014.mdl",
	"models/v_c4.mdl",
	"models/v_mac10.mdl",
	"models/v_aug.mdl",
	"models/v_smokegrenade.mdl",
	"models/v_elite.mdl",
	"models/v_fiveseven.mdl",
	"models/v_ump45.mdl",
	"models/v_sg550.mdl",
	"models/v_galil.mdl",
	"models/v_famas.mdl",
	"models/v_usp.mdl",
	"models/v_glock18.mdl",
	"models/v_awp.mdl",
	"models/v_mp5.mdl",
	"models/v_m249.mdl",
	"models/v_m3.mdl",
	"models/v_m4a1.mdl",
	"models/v_tmp.mdl",
	"models/v_g3sg1.mdl",
	"models/v_flashbang.mdl",
	"models/v_deagle.mdl",
	"models/v_sg552.mdl",
	"models/v_ak47.mdl",
	"models/v_knife.mdl",
	"models/v_p90.mdl"
}

static const g_cItemCounter[COUNTER] = 
{
	MAIN_MENU_DEFAULT_ITEMS_COUNT,
	INVENTORY_DEFAULT_ITEMS_COUNT,
	GAMBLING_DEFAULT_ITEMS_COUNT,
	SETTINGS_DEFAULT_ITEMS_COUNT
}

static const DB_SERVER_KEY[] = "SERVER_STATS"

static const g_sznVaultGlovesName[] 			=		 "user_gloves"
static const g_sznVaultWeaponGlovesName[] 		=		 "user_weapon_gloves"
static const g_sznVaultSkinTagVaultName[]	 	=		 "skin_tags"
static const g_sznVaultPlayerTagName[] 			=		 "player_skin_tags"
static const g_sznVaultTagLevelName[] 			=		 "name_tag_skin_level"
static const g_sznVaultStattrakName[] 			=		 "csgoclassy_stattrak"
static const g_sznVaultStattrakKillsName[]		=		 "csgoclassy_stattrak_kills"
static const g_sznVaultAccountsName[] 			=		 "csgoclassy"

new g_nVaultAccounts
new g_nVaultStattrak
new g_nVaultStattrakKills
new g_nVaultGloves
new g_nVaultWeaponGloves
new g_nVaultPlayerTags
new g_nVaultNameTagsLevel
new g_nVaultSkinTags

new AMXX_CONFIG_DIRECTORY[64]
new g_iKills[MAX_PLAYERS + 1]
new g_iHS[MAX_PLAYERS + 1]
new Float:g_fDmg[MAX_PLAYERS + 1] 
new bool:g_bUsingM4A4[MAX_PLAYERS + 1]
new g_GiveawayDelay
new g_iCurrentRound
new g_bGiveAwayStarted
new bool:g_bJoinedGiveAway[MAX_PLAYERS + 1]
new g_szSkinName[32]
new g_iSkinID
new g_iSkinsInContract[MAX_PLAYERS + 1]
new g_iWeaponUsedInContract[MAX_PLAYERS + 1][MAX_SKINS]
new g_iUserChance[MAX_PLAYERS + 1]
new g_iUsedSttC[MAX_PLAYERS + 1][MAX_SKINS]

new g_status_sync
new g_iRang[MAX_PLAYERS + 1]
new g_iRangExp[MAX_PLAYERS + 1]
new rank[MAX_PLAYERS + 1]
new bool:g_bLogged[MAX_PLAYERS + 1]
new g_WarmUpSync
new g_iRanksNum
new g_iSkinsNum
new bool:g_bShallUseStt[MAX_PLAYERS + 1][31]
new g_iAskType[MAX_PLAYERS + 1]
new bool:g_bPublishedStattrakSkin[MAX_PLAYERS + 1]
new bool:g_bGiftingStt[MAX_PLAYERS + 1]
new bool:g_bDestroyStt[MAX_PLAYERS + 1]
new bool:g_bTradingStt[MAX_PLAYERS + 1]
new bool:g_bJackpotStt[MAX_PLAYERS + 1]
new bool:g_bIsWeaponStattrak[MAX_PLAYERS + 1][TOTAL_SKINS]
new g_iUserStattrakKillCount[MAX_PLAYERS + 1][TOTAL_SKINS]
const STATTRAK_STATUS = 3111
const STATTRAK_CHANCE = 2
new g_iUserSelectedSkin[MAX_PLAYERS + 1][31]
new g_iUserSkins[MAX_PLAYERS + 1][TOTAL_SKINS]
new g_iUserMoney[MAX_PLAYERS + 1]
new g_iUserScraps[MAX_PLAYERS + 1]
new g_iUserKeys[MAX_PLAYERS + 1]
new g_iUserCases[MAX_PLAYERS + 1]
new g_iUserKills[MAX_PLAYERS + 1]
new g_iUserRank[MAX_PLAYERS + 1]
new g_szName[MAX_PLAYERS + 1][MAX_NAME_LENGTH]
new g_szUserPassword[MAX_PLAYERS + 1][MAX_NAME_LENGTH]
new g_szUserSavedPass[MAX_PLAYERS + 1][MAX_SQL_NAME_LENGTH]
new g_szUserOldPassword[MAX_PLAYERS + 1][MAX_NAME_LENGTH]
new g_szUserNewPassword[MAX_PLAYERS + 1][MAX_NAME_LENGTH]
new g_iUserPassFail[MAX_PLAYERS + 1]
new g_iWeaponUsedInUpgrade[MAX_PLAYERS + 1]
new c_RegOpen
new fw_CUIC
new HamHook:fw_ID[31]
new HamHook:fw_ICD[31]
new HamHook:fw_K1
new HamHook:fw_K2
new c_DropType
new c_KeyPrice
new c_DropChance
new c_CraftCost
new g_iUserSellItem[MAX_PLAYERS + 1]
new g_iUserItemPrice[MAX_PLAYERS + 1]
new bool:g_bUserSellSkin[MAX_PLAYERS + 1]
new g_iLastPlace[MAX_PLAYERS + 1]
new g_iMenuType[MAX_PLAYERS + 1]
new c_DustForTransform
new c_ReturnPercent
new g_iGiftTarget[MAX_PLAYERS + 1]
new g_iGiftItem[MAX_PLAYERS + 1]
new g_bTradeAccept[MAX_PLAYERS + 1]
new g_iTradeTarget[MAX_PLAYERS + 1]
new g_iTradeItem[MAX_PLAYERS + 1]
new g_bTradeActive[MAX_PLAYERS + 1]
new g_bTradeSecond[MAX_PLAYERS + 1]
new g_iTradeRequest[MAX_PLAYERS + 1]
new g_bCFAccept[MAX_PLAYERS + 1]
new g_iCFTarget[MAX_PLAYERS + 1]
new g_iCFItem[MAX_PLAYERS + 1]
new g_bCFActive[MAX_PLAYERS + 1]
new g_bCFSecond[MAX_PLAYERS + 1]
new g_iCFRequest[MAX_PLAYERS + 1]
new bool:g_bOneAccepted
new bool:g_bBettingCFStt[MAX_PLAYERS + 1]
new g_iRouletteCost
new g_bRoulettePlay[MAX_PLAYERS + 1]
new g_iTombolaPlayers
new g_iTombolaPrize
new g_bUserPlay[MAX_PLAYERS + 1]
new g_iNextTombolaStart
new c_TombolaCost
new c_TombolaTimer
new g_iTombolaTimer = 180
new g_bTombolaWork = 1
new c_RouletteMin
new c_RouletteMax
new g_iUserBetMoney[MAX_PLAYERS + 1]
new bool:g_bJackpotWork
new g_iUserJackpotItem[MAX_PLAYERS + 1]
new g_bUserPlayJackpot[MAX_PLAYERS + 1]
new g_iJackpotClose
new c_JackpotTimer
new g_iMaxPlayers
new g_iRoundNum
new g_iTotalRounds;
new bool:g_bWarmUp
new bool:g_bWasWarmUp
new c_WarmUpDuration
new c_Competitive
new g_iTimer
new bool:g_bTeamSwap
new p_Freezetime
new g_iFreezetime
new c_RankUpBonus[16]
new c_CmdAccess[16]
new c_MVPMsgType
new g_iRoundKills[MAX_PLAYERS + 1]
new g_iDealDamage[MAX_PLAYERS + 1]
new c_AMinMoney
new c_AMaxMoney
new c_HMinMoney
new c_HMaxMoney
new c_KMinMoney
new c_KMaxMoney
new c_HMinChance
new c_HMaxChance
new c_KMinChance
new c_KMaxChance
new g_iMostDamage[MAX_PLAYERS + 1]
new g_iDamage[MAX_PLAYERS + 1][MAX_PLAYERS + 1]
new ScopeData[MAX_PLAYERS + 1][PlayerScopeData]
new PluginForwardQuick
new g_quick_enable
new g_quick_type
new g_iMenuToOpen[MAX_PLAYERS + 1]
new bool:g_IsChangeAllowed[MAX_PLAYERS + 1]
new Handle:g_SqlTuple, g_Error[512];
new MYSQL[SQLDATA];

new g_eDefaultModels[31][DEFAULT_MODEL]

new Array:g_aGloves
new Array:g_aGlovesModelName
new Array:g_aGlovesModelAmount
new Array:g_aWeapIDs
new Array:g_aSkinType
new Array:g_aRankName
new Array:g_aRankKills
new Array:g_aRangName
new Array:g_aRangExp
new Array:g_aSkinBody
new Array:g_aSkinWeaponID
new Array:g_aSkinName
new Array:g_aSkinModel
new Array:g_aSkinChance
new Array:g_aSkinCostMin
new Array:g_aDropSkin
new Array:g_aCraftSkin
new Array:g_aTombola
new Array:g_aJackpotSkins
new Array:g_aJackPotSttSkins
new Array:g_aJackpotUsers
new Array:g_aeMenus[MENU_ITEMS]

new Float:g_CvarBuyTime,g_CvarKnifeWarmup,g_CvarCapsuleChance,g_CvarCommonNameTagChance, g_CvarMVPSystem,
g_CvarRareNameTagChance,g_CvarMythicNameTagChance,g_CvarCommonPrice,g_CvarRarePrice, g_CvarUndroppableChance,
g_CvarMythicPrice,g_CvarGoldVipCapsuleChance,g_CvarSilverVipCapsuleChance,g_CvarGoldVipNameTagChance,
g_CvarSilverVipNameTagChance,g_CvarScrapsDestroyNameTagSkin,g_CvarMoneyDestroyNameTagSkin,g_CvarPreviewTime,
g_CvarRoundEndSounds,g_CvarGiveawayMinPlayers,g_CvarWeekendEvent,g_CvarWeekendFriday,g_CvarWeekendBonus,
g_CvarShowSpecialSkins,g_CvarGloveDropChance,g_CvarGloveCaseDropChance,g_CvarCanUserDropVIPGloves, g_CvarRangUpBonus,
g_CvarCanUserUseVIPGloves,g_CvarRetrieveGlove,g_CvarWeekendHud,g_CvarMVPMaxMoney,g_CvarMVPMinMoney,g_CvarMVPMaxCases,
g_CvarMVPMinCases,g_CvarMVPMaxKeys,g_CvarMVPMinKeys,g_CvarMVPMinScraps,g_CvarMVPMaxScraps, g_CvarDailyMinRank,
g_CvarSkinType, g_CvarSaveType, g_CvarKnifeKillScraps, g_CvarDoubleScope, g_CvarStatsCountCmds;
new msgScreenFade;
new g_hWeekBonus;
new bool:g_bWeekBonusActive;
new bool:g_bActiveGloveSystem;
new g_iRoundsToPlay;

new g_eForwards[FORWARDS]

new bool:g_bSellGlove[MAX_PLAYERS + 1];
new bool:g_bIsInPreview[MAX_PLAYERS + 1];
new bool:g_bHasSkinTag[MAX_PLAYERS + 1][TOTAL_SKINS];
new bool:g_bSellCapsule[MAX_PLAYERS + 1];  
new bool:g_bIsSelling[MAX_PLAYERS + 1];
new bool:g_bChatClear[MAX_PLAYERS + 1];
new bool:g_bUserDefaultModels[MAX_PLAYERS + 1];
new bool:g_bAccountExists[MAX_PLAYERS + 1];
new bool:g_bMultipleAccounts[MAX_PLAYERS + 1];
new bool:g_bWaitingResponse[MAX_PLAYERS + 1];
new bool:g_bWaitingSkins[MAX_PLAYERS + 1];
new bool:g_bAccountReseted[MAX_PLAYERS + 1]

new g_iUserGloves[MAX_PLAYERS + 1][MAX_GLOVES + 1];
new g_iWeaponGloves[MAX_PLAYERS + 1][31];
new g_iGlovesCases[MAX_PLAYERS + 1];
new g_iMarketGloveID[MAX_PLAYERS + 1];
new g_szCurrentSkinTag[MAX_PLAYERS + 1][MAX_SKIN_TAG_LENGTH];
new g_szCurrentSkinThatGetTag[MAX_PLAYERS + 1][48];
new g_szSkinsTag[MAX_PLAYERS + 1][TOTAL_SKINS][MAX_SKIN_TAG_LENGTH + 1];
new g_iTagCurrentWeaponID[MAX_PLAYERS + 1];
new g_iNameTagCapsule[MAX_PLAYERS + 1];
new g_iNameTagSkinLevel[MAX_PLAYERS + 1][TOTAL_SKINS];
new g_iSelectedNameTagRarity[MAX_PLAYERS + 1];
new g_iCommonNameTag[MAX_PLAYERS + 1];
new g_iRareNameTag[MAX_PLAYERS + 1];
new g_iMythicNameTag[MAX_PLAYERS + 1];
new g_iMarketNameTagsRarity[MAX_PLAYERS + 1];  
new g_iWeaponIdToCheck[MAX_PLAYERS + 1];
// new g_iOpenDelay[MAX_PLAYERS + 1];
new g_iNewNameTagIndex[MAX_PLAYERS + 1];
new g_szSQLName[MAX_PLAYERS + 1][MAX_SQL_NAME_LENGTH];
new g_iUserDailyTime[MAX_PLAYERS + 1]
new g_iTotalPlayedTime[MAX_PLAYERS + 1]

new g_eServerStatistics[STATISTICS]
new g_eUserStatistics[MAX_PLAYERS + 1][STATISTICS]
new g_iServerSkinStatistics[TOTAL_SKINS]
new g_iServerSttSkinStatistics[TOTAL_SKINS]
new g_iServerWeaponKill[CS_MAX_WEAPONS]
new g_iUserSkinStatistics[MAX_PLAYERS + 1][TOTAL_SKINS]
new g_iUserSttSkinStatistics[MAX_PLAYERS + 1][TOTAL_SKINS]
new g_iUserWeaponKill[MAX_PLAYERS + 1][CS_MAX_WEAPONS]

public plugin_init()
{
	register_plugin("CSGO Classy Enhanced", VERSION, "lexzor")	

	check_license()
	set_task(15.0, "check_license", .flags = "b");

	register_dictionary("csgoclassy.txt");
	register_event("HLTV", "ev_NewRound", "a", "1=0", "2=0")
	register_event("HLTV", "event_RoundStart", "a", "1=0", "2=0")
	register_logevent("logev_Restart_Round", 2, "1&Restart_Round")
	register_logevent("logev_Game_Commencing", 2, "1&Game_Commencing")
	register_event("SendAudio", "ev_RoundWon_T", "a", "2&%!MRAD_terwin")
	register_event("SendAudio", "ev_RoundWon_CT", "a", "2&%!MRAD_ctwin")	
	register_event("StatusValue", "showStatus", "be", "1=2", "2!0")
	register_event("StatusValue", "hideStatus", "be", "1=1", "2=0")

	PluginForwardQuick = CreateMultiForward("client_NoScoped", ET_STOP, FP_CELL, FP_CELL, FP_CELL)
	register_event("DeathMsg", "checkQuickScopeKill", "a", "1>0", "4=scout", "4=sg550", "4=awp", "4=g3sg1")
	register_event("CurWeapon", "fw_EvCurWeapon", "b", "1=1", "2=3", "2=13", "2=18", "2=24")
	register_event("SetFOV", "Zoom", "b", "1<90")

	fw_CUIC = register_forward(122, "fw_FM_ClientUserInfoChanged", 0)
	fw_K1 = RegisterHam(Ham_Killed, "player", "Ham_Player_Killed_Post", 1)
	fw_K2 = RegisterHam(Ham_Killed, "player", "Ham_Player_Killed_Pre", 0)
	RegisterHam(Ham_TakeDamage, "player", "OnTakeDamage")  

	register_event("DeathMsg", "ev_DeathMsg", "a", "1>0")
	register_event("Damage", "ev_Damage", "b", "2!0", "3=0", "4!0")
	register_event("DeathMsg", "OnPlayerKilled", "a")
	register_logevent("OnRoundEnd", 2, "1=Round_End")
	
	register_forward(FM_ClientKill, "concmd_kill")

	g_WarmUpSync = CreateHudSyncObj(0)
	g_iMaxPlayers = get_maxplayers()
	
	for(new i = 1; i < sizeof(g_szWeaponEntName); i++)
	{
		if (g_szWeaponEntName[i][0])
		{
			fw_ID[i] = RegisterHam(Ham_Item_Deploy, g_szWeaponEntName[i], "Ham_Item_Deploy_Post", 1)
			fw_ICD[i] = RegisterHam(Ham_CS_Item_CanDrop, g_szWeaponEntName[i], "Ham_Item_Can_Drop", 0)
		}
	}
	
	RegisterHam(Ham_Weapon_SecondaryAttack, g_szWeaponEntName[CSW_AWP], "Ham_Weapon_SecondaryAttack_Post", _:true)
	RegisterHam(Ham_Weapon_PrimaryAttack, g_szWeaponEntName[CSW_AWP], "Ham_Weapon_PrimaryAttack_Post", _:true)
	
	register_cvar("csgo_classy_enhanced", VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)

	g_status_sync = CreateHudSyncObj()
	RegisterHam(Ham_Spawn, "player", "Ham_Spawn_Post", 1);

	g_eForwards[LOGIN] = CreateMultiForward("user_log_in_post", ET_IGNORE, FP_CELL)
	g_eForwards[REGISTER] = CreateMultiForward("user_register_post", ET_IGNORE, FP_CELL)
	g_eForwards[MENU_ITEM_SELECTED] = CreateMultiForward("csgo_menu_item_selected", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_eForwards[CONFIG_EXECUTED] = CreateMultiForward("csgo_config_executed", ET_IGNORE)

	if(weekend_event() && g_CvarWeekendHud)
	{
		g_bWeekBonusActive = true;
		set_task(1.0, "show_weekend_event_hud", .flags = "b");
	}

	msgScreenFade = get_user_msgid("ScreenFade")

	get_configsdir(AMXX_CONFIG_DIRECTORY, charsmax(AMXX_CONFIG_DIRECTORY))

	RegisterCVARS()
	ExecConfigFile()
	ReadINIFile()
	RegisterCMDS()
}

stock AddStatistics(const id, const STATISTICS:type, const amount, const skinid = -1, const gloveid = -1, const weaponid = -1, const line = -1)
{
	if(type == WEAPON_KILL)
	{
		g_iUserWeaponKill[id][weaponid]++
		g_iServerWeaponKill[weaponid]++

		new name[64]
		get_weaponname(weaponid, name, 63)

		return
	}

	if(type == DROPPED_SKINS || type == DROPPED_STT_SKINS)
	{
		if(skinid == -1 || skinid > ArraySize(g_aSkinName))
		{
			log_to_file(LOG_FILE, "[STATISTICS] %s. Invalid skin id [%i] at line %i", g_szStatsName[_:type], skinid, line)
			return
		} 

		switch(type)
		{
			case DROPPED_SKINS:
			{
				g_iServerSkinStatistics[skinid] += amount
				g_iUserSkinStatistics[id][skinid] += amount
			}

			case DROPPED_STT_SKINS:
			{
				g_iServerSttSkinStatistics[skinid] += amount
				g_iUserSttSkinStatistics[id][skinid] += amount
			}
		}
		return
	}


	if(type == DROPPED_GLOVES)
	{
		switch(gloveid)
		{
			case GLOVE0:
			{
				g_eServerStatistics[DROPPED_GLOVE0] += amount
				g_eUserStatistics[id][DROPPED_GLOVE0] += amount
			}

			case GLOVE1:
			{
				g_eServerStatistics[DROPPED_GLOVE1] += amount
				g_eUserStatistics[id][DROPPED_GLOVE1] += amount
			}

			case GLOVE2:
			{
				g_eServerStatistics[DROPPED_GLOVE2] += amount
				g_eUserStatistics[id][DROPPED_GLOVE2] += amount
			}

			case GLOVE3:
			{
				g_eServerStatistics[DROPPED_GLOVE3] += amount
				g_eUserStatistics[id][DROPPED_GLOVE3] += amount
			}

			case GLOVE4:
			{
				g_eServerStatistics[DROPPED_GLOVE4] += amount
				g_eUserStatistics[id][DROPPED_GLOVE4] += amount
			}
		}

		g_eServerStatistics[DROPPED_GLOVES] += amount
		g_eUserStatistics[id][DROPPED_GLOVES] += amount
		
		return
	}

	if(amount < 1)
	{
		log_to_file(LOG_FILE, "[STATISTICS] %s. Wrong amount value [%i] at line %i", g_szStatsName[_:type], amount, line)
		return
	}

	g_eServerStatistics[type] += amount
	g_eUserStatistics[id][type] += amount
	
	return
}

public Ham_Weapon_SecondaryAttack_Post(const iWeaponEnt)
{
	new iZoom, iOwner = get_entvar(iWeaponEnt, var_owner)
	
	if((iZoom = cs_get_user_zoom(iOwner)) != CS_SET_NO_ZOOM)
	{
		set_entvar(iOwner, var_viewmodel, "")
		cs_set_user_zoom(iOwner, g_CvarDoubleScope ? CS_SET_SECOND_ZOOM : iZoom, _:true)
	}
	else 
	{
		ToggleAWPSkin(iOwner)
	}
}

public Ham_Weapon_PrimaryAttack_Post(const iWeaponEnt)
{	
	new iOwner = get_entvar(iWeaponEnt, var_owner)

	ToggleAWPSkin(iOwner)

	new Float:fNextPrimaryAttack = get_member(iWeaponEnt, m_Weapon_flNextPrimaryAttack)

	set_task(fNextPrimaryAttack, "AWPNextPrimaryAttack", iOwner + TASK_REMOVE_AWP_SECONDARY)
}

public AWPNextPrimaryAttack(iOwner)
{
	iOwner -= TASK_REMOVE_AWP_SECONDARY
	
	if(!is_user_connected(iOwner))
	{
		return
	}

	new iWeaponEnt = get_member(iOwner, m_pActiveItem)
	
	new iLastZoom  = cs_get_user_zoom(iOwner)

	if(
		is_valid_ent(iWeaponEnt) 
		&& get_member(iWeaponEnt, m_iId) == CSW_AWP
		&& (iLastZoom == CS_SET_FIRST_ZOOM || iLastZoom == CS_SET_SECOND_ZOOM)
		&& !bool:get_member(iWeaponEnt, m_Weapon_fInReload)
	)
	{
		set_entvar(iOwner, var_viewmodel, "")
	}
}
stock ToggleAWPSkin(const iOwner)
{
	new iBodyPart

	if(g_iUserSelectedSkin[iOwner][CSW_AWP] != -1)
	{
		new szModel[128]
		ArrayGetString(g_aSkinModel, g_iUserSelectedSkin[iOwner][CSW_AWP], szModel, charsmax(szModel))
		CalculateModelBodyIndex(g_iWeaponGloves[iOwner][CSW_AWP], szModel, ArrayGetCell(g_aSkinBody, g_iUserSelectedSkin[iOwner][CSW_AWP]), iBodyPart)
		set_entvar(iOwner, var_viewmodel, szModel)
		set_entvar(iOwner, var_body, iBodyPart)
		return
	}

	if(!g_bUserDefaultModels[iOwner])
	{
		CalculateModelBodyIndex(-1, g_eDefaultModels[CSW_AWP][PATH], g_eDefaultModels[CSW_AWP][BODYINDEX] > -1 ? g_eDefaultModels[CSW_AWP][BODYINDEX] : 0, iBodyPart);
		set_entvar(iOwner, var_viewmodel, g_eDefaultModels[CSW_AWP][PATH])
		set_entvar(iOwner, var_body, iBodyPart)
	}
	else 
	{
		set_entvar(iOwner, var_viewmodel, g_szDefaultSkinModels[CSW_AWP])
	}

	return
}

public plugin_cfg()
{
	new Float:timer = float(c_TombolaTimer);
	g_iNextTombolaStart = c_TombolaTimer + get_systime();
	
	set_task(timer, "task_TombolaRun", .flags = "b");
}

public plugin_natives()
{
	g_aRankName 			=	ArrayCreate(32, 1);
	g_aRankKills 			=	ArrayCreate(1, 1);
	g_aSkinWeaponID 		=	ArrayCreate(1, 1);
	g_aSkinBody 			=	ArrayCreate(1, 1);
	g_aSkinName 			=	ArrayCreate(48, 1);
	g_aSkinModel 			=	ArrayCreate(256, 1);
	g_aSkinChance 			=	ArrayCreate(1, 1);
	g_aSkinCostMin 			=	ArrayCreate(1, 1);
	g_aDropSkin 			=	ArrayCreate(1, 1);
	g_aCraftSkin 			=	ArrayCreate(1, 1);
	g_aTombola 				=	ArrayCreate(1, 1);
	g_aJackpotSkins 		=	ArrayCreate(1, 1);
	g_aJackPotSttSkins 		=	ArrayCreate(1, 1)
	g_aJackpotUsers 		=	ArrayCreate(1, 1);
	g_aSkinType 			=	ArrayCreate(1, 1);

	g_aGloves 				= 	ArrayCreate(GLOVESINFO)
	g_aGlovesModelName 		= 	ArrayCreate(256);
	g_aGlovesModelAmount 	= 	ArrayCreate(1);
	g_aWeapIDs 				= 	ArrayCreate(1);
	g_aRangName				=	ArrayCreate(MAX_RANG_NAME_LENGTH + 1)
	g_aRangExp				=	ArrayCreate(1)

	for(new MENU_ITEMS:i; i < MENU_ITEMS; i++)
	{
		g_aeMenus[i] = ArrayCreate(MENU_DATA)
	}

	register_library("csgoclassy");

	register_native("csgo_add_inventory_item_value", "native_csgo_add_inventory_item_value", 0)
	register_native("csgo_additional_menu_name", "native_csgo_additional_menu_name", 0)
	register_native("csgo_register_menu", "native_csgo_register_menu", 0)
	register_native("csgo_get_prefixes", "native_csgo_get_prefixes")
	register_native("csgo_directory", "native_csgo_directory")
	register_native("csgo_get_mysql", "native_csgo_get_mysql");
	register_native("is_warmup", "native_is_warmup", 0);
	register_native("was_warmup", "native_was_warmup", 0);
	register_native("round_num", "native_round_num", 0);
	register_native("set_user_login_value", "native_force_user_log_in", 0);
	register_native("has_skin_tag", "native_has_skin_tag", 0);
	register_native("get_skin_tag", "native_get_skin_tag", 0);
	register_native("get_skin_level", "native_get_skin_level", 0);
	register_native("is_in_preview", "native_is_in_preview", 0);
	register_native("display_menu", "native_display_menu", 0);
	register_native("get_skin_name", "native_get_skin_name", 0);
	register_native("get_skins_num", "native_get_skins_num", 0);
	register_native("get_weapon_max_skins", "native_get_weapon_max_skins", 0);
	register_native("get_skin_weaponid", "native_get_skin_weaponid", 0);
	register_native("get_warmup_time", "native_get_warmup_time", 0);
	register_native("get_user_capsules", "native_get_user_capsules", 0);
	register_native("get_user_common", "native_get_user_common", 0);
	register_native("get_user_rare", "native_get_user_rare", 0);
	register_native("get_user_mythic", "native_get_user_mythic", 0);
	register_native("get_user_rank_id", "native_get_user_rank_id", 0);
	register_native("is_using_default_skins", "native_is_using_default_skins", 0);
	register_native("get_user_password", "native_get_user_password");
	register_native("get_user_money", "native_get_user_money", 0);
	register_native("set_user_money", "native_set_user_money", 0);
	register_native("get_user_cases", "native_get_user_cases", 0);
	register_native("set_user_cases", "native_set_user_cases", 0);
	register_native("get_user_keys", "native_get_user_keys", 0);
	register_native("set_user_keys", "native_set_user_keys", 0);
	register_native("get_user_scraps", "native_get_user_scraps", 0);
	register_native("set_user_scraps", "native_set_user_scraps", 0);
	register_native("get_user_rank", "native_get_user_rank", 0);
	register_native("set_user_rank", "native_set_user_rank", 0);
	register_native("get_user_skins", "native_get_user_skins", 0);
	register_native("set_user_skins", "native_set_user_skins", 0);
	register_native("is_user_logged", "native_is_user_logged", 0);
	register_native("is_using_m4a4", "_checku");
	register_native("getSkinName", "_getSkinName");
	register_native("getWeaponSkinId", "_getCurrentSkin");
	register_native("updateWeaponSkin", "_update");
	register_native("set_user_randomskin", "_setRandom");
	register_native("force_user_login", "_allow")
	register_native("aug_sg_unscope", "native_aug_sg_unscope")
}

public native_aug_sg_unscope(iPluginID, iParams)
{
	new iOwner = get_param(1)
	if(is_user_alive(iOwner))
	{
		new iWeaponID = get_user_weapon(iOwner)
		new iBodyPart

		if(!g_bLogged[iOwner])
		{
			set_entvar(iOwner, var_viewmodel, g_szDefaultSkinModels[iWeaponID])
			return
		}


		if(g_iUserSelectedSkin[iOwner][iWeaponID] != -1)
		{
			new szModel[256]
			ArrayGetString(g_aSkinModel, g_iUserSelectedSkin[iOwner][iWeaponID], szModel, charsmax(szModel))

			CalculateModelBodyIndex(g_iWeaponGloves[iOwner][iWeaponID], szModel, ArrayGetCell(g_aSkinBody, g_iUserSelectedSkin[iOwner][iWeaponID]), iBodyPart)

			set_entvar(iOwner, var_viewmodel, szModel)
			set_entvar(iOwner, var_body, iBodyPart)
		}
		else 
		{
			if(!g_bUserDefaultModels[iOwner])
			{
				CalculateModelBodyIndex(-1, g_eDefaultModels[iWeaponID][PATH], g_eDefaultModels[iWeaponID][BODYINDEX] > -1 ? g_eDefaultModels[iWeaponID][BODYINDEX] : 0, iBodyPart);
				set_entvar(iOwner, var_viewmodel, g_eDefaultModels[iWeaponID][PATH])
				set_entvar(iOwner, var_body, iBodyPart)
			}
			else 
			{
				set_entvar(iOwner, var_viewmodel, g_szDefaultSkinModels[iWeaponID])
			}
		}
	}
}

public plugin_end()
{
	ArrayDestroy(g_aRankName);
	ArrayDestroy(g_aRankKills);
	ArrayDestroy(g_aSkinWeaponID);
	ArrayDestroy(g_aSkinName);
	ArrayDestroy(g_aSkinModel);
	ArrayDestroy(g_aSkinChance);
	ArrayDestroy(g_aSkinCostMin);
	ArrayDestroy(g_aDropSkin);
	ArrayDestroy(g_aCraftSkin);
	ArrayDestroy(g_aGloves);
	ArrayDestroy(g_aGlovesModelName);
	ArrayDestroy(g_aGlovesModelAmount);
	ArrayDestroy(g_aWeapIDs);
	ArrayDestroy(g_aSkinType);

	for(new MENU_ITEMS:i; i < MENU_ITEMS; i++)
	{
		ArrayDestroy(g_aeMenus[MENU_ITEMS:i])
	}

	if(g_bWeekBonusActive)
	{
		ClearSyncHud(0, g_hWeekBonus);
	}

	DisableHamForward(fw_K1);
	DisableHamForward(fw_K2);

	for(new iForward; iForward < FORWARDS; iForward++)
	{
		DestroyForward(g_eForwards[iForward])
	}

	DestroyForward(PluginForwardQuick)
	unregister_forward(122, fw_CUIC, 0);

	switch(g_CvarSaveType)
	{
		case SQL:
		{		
			static szQuery[TOTAL_SKINS * 6], szSkinData[2][TOTAL_SKINS * 3]
			new iQueryLen, iLen[2]

			iQueryLen = formatex(szQuery[iQueryLen], charsmax(szQuery), "UPDATE `%s` SET", g_szTables[SERVER_STATISTICS])

			for(new i = 0; i < g_iSkinsNum; i++)
			{
				iLen[_:DROPPED_SKINS] 			+=		formatex(szSkinData[_:DROPPED_SKINS][iLen[_:DROPPED_SKINS]], 					charsmax(szSkinData[]),	 "%d,", g_iServerSkinStatistics[i])
				iLen[_:DROPPED_STT_SKINS] 		+=		formatex(szSkinData[_:DROPPED_STT_SKINS][iLen[_:DROPPED_STT_SKINS]], 			charsmax(szSkinData[]),	 "%d,", g_iServerSttSkinStatistics[i])
			}

			iQueryLen += formatex(szQuery[iQueryLen], charsmax(szQuery), " `%s` = '", g_szStatsName[_:WEAPON_KILL])
			
			for(new i = 1; i < CS_MAX_WEAPONS; i++)
			{
				iQueryLen += formatex(szQuery[iQueryLen], charsmax(szQuery), "%d,", g_iServerWeaponKill[i])
			}

			iQueryLen += formatex(szQuery[iQueryLen], charsmax(szQuery), "'")
			iQueryLen += formatex(szQuery[iQueryLen], charsmax(szQuery), ", `%s` = '%s', `%s` = '%s'", g_szStatsName[_:DROPPED_SKINS], szSkinData[_:DROPPED_SKINS], g_szStatsName[_:DROPPED_STT_SKINS], szSkinData[_:DROPPED_STT_SKINS])

			for(new STATISTICS:iStats = RECEIVED_MONEY; iStats < STATISTICS; iStats++)
			{
				iQueryLen += formatex(szQuery[iQueryLen], charsmax(szQuery), ", `%s` = %i", g_szStatsName[_:iStats], g_eServerStatistics[iStats])
			}

			iQueryLen += formatex(szQuery[iQueryLen], charsmax(szQuery), " WHERE `server_key` = '%s';", DB_SERVER_KEY)

			new iData[1]; iData[0] = __LINE__
			SQL_ThreadQuery(g_SqlTuple, "FreeHandle", szQuery, iData, sizeof(iData))
			SQL_FreeHandle(g_SqlTuple)
		}

		case NVAULT:
		{
			new iTime = get_systime() - NVAULT_PRUNE_DAYS * 86400

			nvault_prune(g_nVaultAccounts, 0, iTime)
			nvault_close(g_nVaultAccounts)

			nvault_prune(g_nVaultSkinTags, 0, iTime)
			nvault_close(g_nVaultSkinTags)

			nvault_prune(g_nVaultPlayerTags, 0, iTime)
			nvault_close(g_nVaultPlayerTags)

			nvault_prune(g_nVaultNameTagsLevel, 0, iTime)
			nvault_close(g_nVaultNameTagsLevel)

			nvault_prune(g_nVaultGloves, 0, iTime)
			nvault_close(g_nVaultGloves)

			nvault_prune(g_nVaultWeaponGloves, 0, iTime)
			nvault_close(g_nVaultWeaponGloves)

			nvault_prune(g_nVaultStattrak, 0, iTime)
			nvault_close(g_nVaultStattrak)

			nvault_prune(g_nVaultStattrakKills, 0, iTime)
			nvault_close(g_nVaultStattrakKills)
		}
	}
}

public client_connect(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
	{
		return PLUGIN_CONTINUE;
	}

	get_user_name(id, g_szName[id], charsmax(g_szName[]));

	if(g_CvarSaveType == SQL)
	{
		copy(g_szSQLName[id], charsmax(g_szSQLName[]), g_szName[id])
		mysql_escape_string(g_szSQLName[id], charsmax(g_szSQLName[]))
	}
	
	g_bAccountExists[id] = false;
	g_bMultipleAccounts[id] = false;
	g_iNameTagCapsule[id] = 0;
	g_iCommonNameTag[id] = 0;
	g_iRareNameTag[id] = 0;
	g_iMythicNameTag[id] = 0;
	g_iMarketNameTagsRarity[id] = 0;
	g_bSellCapsule[id] = false;
	g_iNewNameTagIndex[id] = -1;
	g_bAccountReseted[id] = false
	g_iTotalPlayedTime[id] = 0
	g_iRang[id] = 0
	g_iRangExp[id] = 0

	g_iSelectedNameTagRarity[id] = 0;
	g_bIsInPreview[id] = false;
	g_iTagCurrentWeaponID[id] = -1;

	g_iUserItemPrice[id] = 0;

	g_bWaitingResponse[id] = false
	g_bWaitingSkins[id] = false

	_ResetCFData(id)
	g_bJoinedGiveAway[id] = false
	g_IsChangeAllowed[id] = false
	g_bBettingCFStt[id] = false
	g_bUsingM4A4[id] = false
	g_iWeaponUsedInUpgrade[id] = -1
	
	g_iSkinsInContract[id] = -1
	g_iUserChance[id] = 0
	g_bChatClear[id] = false;
	
	for(new i;i < sizeof g_bShallUseStt[];i++)
	{
		g_bShallUseStt[id][i] = false
	}
	
	g_bPublishedStattrakSkin[id] = false
	g_bGiftingStt[id] = false
	g_bDestroyStt[id] = false
	g_bTradingStt[id] = false
	g_bJackpotStt[id] = false
	
	g_iMostDamage[id] = 0;
	g_szUserPassword[id] = "";
	g_szUserNewPassword[id] = ""
	g_szUserOldPassword[id] = ""
	g_szUserSavedPass[id] = "";
	g_iUserPassFail[id] = 0;
	g_bLogged[id] = false;
	g_iUserMoney[id] = 0;
	g_iUserScraps[id] = 0;
	g_iUserKeys[id] = 0;
	g_iUserCases[id] = 0;
	g_iUserKills[id] = 0;
	g_iUserRank[id] = 0;
	g_iUserDailyTime[id] = 0;
	
	g_bUserSellSkin[id] = false;
	g_bIsSelling[id] = false;
	g_iUserSellItem[id] = -1;
	g_iLastPlace[id] = 0;
	
	g_iMenuType[id] = 0;
	
	g_iGiftTarget[id] = 0;
	g_iGiftItem[id] = -1;
	
	g_iTradeTarget[id] = 0;
	g_iTradeItem[id] = -1;
	g_bTradeActive[id] = 0;
	g_bTradeAccept[id] = 0;
	g_bTradeSecond[id] = 0;
	g_iTradeRequest[id] = 0;
	
	_ResetCFData(id)
	
	g_bUserPlay[id] = 0;
	g_iUserBetMoney[id] = 100;
	g_bRoulettePlay[id] = 0;
	g_iUserJackpotItem[id] = -1;
	g_bUserPlayJackpot[id] = 0;

	for(new i; i < 31; i++)
	{
		if(g_bActiveGloveSystem)
		{
			g_iWeaponGloves[id][i] = -1;
		}

		g_iUserSelectedSkin[id][i] = -1;
		g_iUserWeaponKill[id][i] = 0
	}

	for(new i; i < MAX_SKINS; i++)
	{
		g_iWeaponUsedInContract[id][i] = -1
		g_iUsedSttC[id][i] = -1
	}

	for(new i; i < g_iSkinsNum; i++)
	{
		g_iUserSkins[id][i] = 0
		g_bIsWeaponStattrak[id][i] = false;
	}

	_LoadData(id);
	return PLUGIN_CONTINUE;
}

public Ham_Spawn_Post(id)
{
	if(is_user_alive(id))
	{
		if(g_CvarKnifeWarmup && g_bWarmUp)
		{
			strip_user_weapons(id);
			give_item(id, "weapon_knife");
		}
		
		if(g_bWarmUp)
		{
			rg_add_account(id, 16000)
		}

		for(new iAmmoIndex = 1; iAmmoIndex < sizeof(g_iMaxBpAmmo); iAmmoIndex++)
		{
			set_pdata_int(id, iAmmoIndex + 376, g_iMaxBpAmmo[iAmmoIndex], 5, 5);
		}
	}
}

public ev_NewRound(id)
{	
	g_iTotalRounds++
	
	if(g_bJackpotWork)
	{
		new Timer[32];
		_FormatTime(Timer, charsmax(Timer), g_iJackpotClose);
		client_print_color(0, 0, "%s %l", CHAT_PREFIX, "JACKPOT_PLAY", Timer);
	}

	if(g_iRoundNum == g_iRoundsToPlay + 1)
	{
		new szNextmap[32]
		get_cvar_string("amx_nextmap", szNextmap, charsmax(szNextmap))
		
		if(equali(szNextmap, "[not yet voted on]"))
		{
			server_cmd("gal_startvote");
			server_exec();
		}
	}	
	
	arrayset(g_iRoundKills, 0, sizeof(g_iRoundKills));
	arrayset(g_bRoulettePlay, 0, sizeof(g_bRoulettePlay));

	if (1 >  c_Competitive)
	{
		return PLUGIN_HANDLED;
	}

	if (g_bWarmUp)
	{
		return PLUGIN_HANDLED;
	}

	new iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	if (iNum < 2)
	{
		return PLUGIN_HANDLED;
	}

	if (!IsHalf() && !IsLastRound() && 0 < g_iRoundNum && g_iRoundNum <= g_iRoundsToPlay)
	{
		client_print_color(0, 0, "%s^1 %l", CHAT_PREFIX, "ROUND_INFO", g_iRoundNum, g_iRoundsToPlay);
	}
	
	if (IsHalf() && !g_bTeamSwap)
	{	
		new Float:delay = 0.0

		for(new i, iPlayer, CsTeams:tTeam; i < iNum; i++)
		{
			iPlayer = iPlayers[i]
	
			tTeam = cs_get_user_team(iPlayer)
			
			if(IsValidPlayer(iPlayer) && (tTeam == CS_TEAM_CT || tTeam == CS_TEAM_T))
			{
				delay = 0.2 * i;
				set_task(delay, "task_Delayed_Swap", iPlayer + TASK_SWAP);
			}
		}
		
		set_task(delay + 2.0, "task_Team_Swap")
		g_iRoundNum = g_iRoundsToPlay / 2
	}

	if (!g_bWarmUp || !IsHalf())
	{
		g_iRoundNum += 1;
	}

	return PLUGIN_HANDLED
}

bool:IsHalf()
{
	if (!g_bTeamSwap && g_iRoundNum == (g_iRoundsToPlay / 2 + 1))
	{
		return true;
	}
	return false;
}

bool:IsLastRound()
{
	if (g_bTeamSwap && (g_iRoundNum == (g_iRoundsToPlay + 1)))
	{
		return true;
	}
	return false;
}

public task_Delayed_Swap(id)
{
	id -= TASK_SWAP

	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}

	switch(cs_get_user_team(id))
	{
		case CS_TEAM_T:
		{
			cs_set_user_team(id, CS_TEAM_CT);
		}
		
		case CS_TEAM_CT:
		{
			cs_set_user_team(id, CS_TEAM_T);
		}
	}
	
	return PLUGIN_CONTINUE;
}

public task_Team_Swap()
{
	g_bTeamSwap = true
	set_pcvar_num(p_Freezetime, g_iFreezetime)
	server_cmd("sv_restartround 1")
}

public ev_RoundWon_T()
{
	if(g_CvarRoundEndSounds == 1)
	{
		client_cmd(0, "spk ^"%s^"", g_szTWin)
	}

	if (IsHalf())
	{
		g_iFreezetime = p_Freezetime
		set_pcvar_num(p_Freezetime, 10)
		set_task(1.0, "task_reset_kills")
	}
}

public ev_RoundWon_CT()
{
	if(g_CvarRoundEndSounds == 1)
	{
		client_cmd(0, "spk ^"%s^"", g_szCTWin)
	}

	if (IsHalf())
	{
		g_iFreezetime = p_Freezetime
		set_pcvar_num(p_Freezetime, 10)
		set_task(1.0, "task_reset_kills")
	}
}

_GiveBonus(const id, const type)
{
	if (!g_bLogged[id])
	{
		return;
	}

	switch(type)
	{
		case 0:
		{
			new value = random_num(c_AMinMoney, c_AMaxMoney);
		
			g_iUserMoney[id] += value
			AddStatistics(id, RECEIVED_MONEY, value, .line = __LINE__)
		}

		case 1:
		{
			new reward = random_num(0, 3)
			
			switch(reward)
			{
				case 0:
				{
					new random_value = random_num(g_CvarMVPMinMoney, g_CvarMVPMaxMoney);

					g_iUserMoney[id] += random_value

					AddStatistics(id, RECEIVED_MONEY, random_value, .line = __LINE__)

					switch (c_MVPMsgType)
					{
						case 1:
						{
							set_hudmessage(47, 79, 79, -1.0, 0.25, 0, 3.5, 3.5, 0.12, 0.12, -1)
							show_hudmessage(0, "%L", id, "MVP_HUD_MONEY", g_szName[id], random_value)
						}

						case 0:
						{
							client_print_color(0, id, "%s %l", CHAT_PREFIX, "MVP_CHAT_MONEY", g_szName[id], random_value)
						}
					}
				}

				case 1:
				{
					new random_value = random_num(g_CvarMVPMinCases, g_CvarMVPMaxCases);
					
					g_iUserCases[id] += random_value
					AddStatistics(id, DROPPED_CASES, random_value, .line = __LINE__)

					switch (c_MVPMsgType)
					{
						case 1:
						{
							set_hudmessage(47, 79, 79, -1.0, 0.25, 0, 3.5, 3.5, 0.12, 0.12, -1)
							show_hudmessage(0, "%L", id, "MVP_HUD_CASES", g_szName[id], random_value, random_value == 1 ? "" : "s")
						}

						case 0:
						{
							client_print_color(0, id, "%s %L", CHAT_PREFIX, id, "MVP_CHAT_CASES", g_szName[id], random_value, random_value == 1 ? "" : "s")
						}
					}
				}

				case 2:
				{
					new random_value = random_num(g_CvarMVPMinKeys, g_CvarMVPMaxKeys);
					
					g_iUserKeys[id] += random_value
					AddStatistics(id, DROPPED_KEYS, random_value, .line = __LINE__)
					
					switch (c_MVPMsgType)
					{
						case 1:
						{
							set_hudmessage(47, 79, 79, -1.0, 0.25, 0, 3.5, 3.5, 0.12, 0.12, -1)
							show_hudmessage(0, "%L", id, "MVP_HUD_KEYS", g_szName[id], random_value, random_value == 1 ? "" : "s")
						}
						
						case 0:
						{
							client_print_color(0, id, "%s %L", CHAT_PREFIX, id, "MVP_CHAT_KEYS", g_szName[id], random_value, random_value == 1 ? "" : "s")
						}
					}
				}

				case 3:
				{
					new random_value = random_num(g_CvarMVPMinScraps, g_CvarMVPMaxScraps);
					
					g_iUserScraps[id] += random_value
					AddStatistics(id, RECEIVED_SCRAPS, random_value, .line = __LINE__)

					switch (c_MVPMsgType)
					{
						case 1:
						{
							set_hudmessage(47, 79, 79, -1.0, 0.25, 0, 3.5, 3.5, 0.12, 0.12, -1)
							show_hudmessage(0, "%L", id, "MVP_HUD_SCRAPS", g_szName[id], random_value, random_value == 1 ? "" : "s")
						}

						case 0:
						{
							client_print_color(0, id, "%s %L", CHAT_PREFIX, id, "MVP_CHAT_SCRAPS", g_szName[id], random_value, random_value == 1 ? "" : "s")
						}
					}
				}
			}
		}
	}

	return
}

public logev_Restart_Round()
{	
	remove_task(TASK_JACKPOT);

	g_bJackpotWork = true;
	g_bGiveAwayStarted = false;

	g_iJackpotClose = c_JackpotTimer + get_systime();

	set_task(float(c_JackpotTimer), "task_Jackpot", TASK_JACKPOT, .flags = "b");
}

public logev_Game_Commencing()
{
	new iPlayers[32], iNum
	get_players(iPlayers, iNum, "ch")
	
	g_bTeamSwap = false;
	g_iRoundNum = 0;
	if (1 > c_Competitive)
	{
		return PLUGIN_HANDLED;
	}
	g_bWarmUp = true;
	g_bWasWarmUp = true;
	g_CvarBuyTime = get_cvar_float("mp_buytime")

	if(g_CvarKnifeWarmup)
	{
		set_cvar_num("mp_buytime", 0);
	}

	g_iTimer = c_WarmUpDuration;
	set_task(1.0, "task_WarmUp_CD", .flags = "b");
	set_task(1.0, "task_reset_kills")
	return PLUGIN_HANDLED;
}

public task_reset_kills(id)
{
	g_iKills[id] = 0
}

public task_WarmUp_CD(task)
{
	if (0 < g_iTimer)
	{
		set_hudmessage(47, 79, 79, -1.00, 0.72, 0, 0.00, 1.10, 0.00, 0.00, -1);
		new second[64];
		if (1 < g_iTimer)
		{
			formatex(second, 63, "%L", 0, "TEXT_SECONDS");
		}
		else
		{
			formatex(second, 63, "%L", 0, "TEXT_SECOND");
		}

		ShowSyncHudMsg(0, g_WarmUpSync, "Warmup %d %s", g_iTimer, second);
	}
	else
	{
		g_iRoundNum = 1;
		g_bWarmUp = false;

		if(g_CvarKnifeWarmup)
		{
			set_cvar_float("mp_buytime", g_CvarBuyTime);
		}

		remove_task(task, 0);
		server_cmd("sv_restart 1");
	}

	g_iTimer--;
}

public fw_FM_ClientUserInfoChanged(id)
{
	if (!(0 < id && 32 >= id || !is_user_connected(id)))
	{
		return PLUGIN_HANDLED;
	}

	new szNewName[32];
	new szOldName[32];

	pev(id, 6, szOldName, 31);
	if (szOldName[0])
	{
		get_user_info(id, "name", szNewName, 31);
		if (!equal(szOldName, szNewName, 0) && !g_IsChangeAllowed[id])
		{
			set_user_info(id, "name", szOldName);
			client_print_color(id, id, "%s^1 %L", CHAT_PREFIX, id, "CANT_CHANGE");
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_HANDLED;
}

public Ham_Player_Killed_Pre(id)
{
	if(g_bIsInPreview[id])
		restore_previous_skin(id);

	new iActiveItem = get_pdata_cbase(id, 373, 5, 0);

	if (!pev_valid(iActiveItem))
	{
		return PLUGIN_HANDLED;
	}
	
	new imp = pev(iActiveItem, 82);
	
	if (imp > 0)
	{
		return PLUGIN_HANDLED;
	}

	new iId = get_pdata_int(iActiveItem, 43, 4, 0);

	if (1 << iId & 570425936)
	{
		return PLUGIN_HANDLED;
	}
	
	new skin = g_iUserSelectedSkin[id][iId];
	
	set_pev(iActiveItem, 82, (skin == -1) ? DEFAULT_SKIN : (skin + 1))
	return PLUGIN_HANDLED;
}

public Ham_Player_Killed_Post(id, iKiller)
{
	if(!is_user_connected(iKiller) || id == iKiller)
		return PLUGIN_HANDLED
	
	new iUserWeaponId = get_user_weapon(iKiller);
	new iUserSkinId = g_iUserSelectedSkin[iKiller][iUserWeaponId];

	AddStatistics(iKiller, WEAPON_KILL, 1, .weaponid = iUserWeaponId, .line = __LINE__)

	if(iUserSkinId != -1)
	{			
		if(g_bIsWeaponStattrak[iKiller][iUserSkinId] && g_bShallUseStt[iKiller][iUserWeaponId])
		{
			if(!isUsingSomeoneElsesWeapon(iKiller, iUserWeaponId))
			{
				g_iUserStattrakKillCount[iKiller][iUserSkinId]++
				saveStattrakStatus(iKiller)
			}
		}
	}

	if(g_bWarmUp && g_CvarKnifeWarmup && is_user_alive(iKiller))
	{
		set_pev(id, pev_health, 100)
	}

	if (g_bWarmUp)
	{
		set_task(1.0, "RespawnPlayer", id + TASK_RESPAWN, "", 0, "", 0);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_HANDLED;
}

public RespawnPlayer(id)
{
	id -= TASK_RESPAWN
	ExecuteHamB(Ham_CS_RoundRespawn, id)
}

public clcmd_say_menu(id)
{
	if(g_bAccountReseted[id])
	{
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "ACCOUNT_RESETED")
		return PLUGIN_HANDLED
	}

	if (g_bLogged[id] == true)
	{
		_ShowMainMenu(id);
	}
	else
	{
		_ShowRegMenu(id);
	}

	return PLUGIN_CONTINUE
}

public clcmd_chooseteam(id)
{
	clcmd_say_menu(id);
	return PLUGIN_HANDLED;
}

//SAVE DATA
registerUser(id)
{
	g_bAccountExists[id] = true;

	new szDbPass[MAX_SQL_NAME_LENGTH], szQuery[512];

	copy(szDbPass, charsmax(szDbPass), g_szUserPassword[id]);
	mysql_escape_string(szDbPass, charsmax(szDbPass))

	formatex(szQuery, charsmax(szQuery),
		"INSERT INTO `%s` (`uname`,`upassword`,`first_seen`) \
		VALUES (^"%s^",^"%s^",%d); \
		INSERT INTO `%s` (`uname`) \
		VALUES (^"%s^"); \
		INSERT INTO `%s` (`uname`) \
		VALUES (^"%s^");",
		g_szTables[PLAYER_DATA], g_szSQLName[id], szDbPass, get_systime(),
		g_szTables[PLAYER_SKINS], g_szSQLName[id],
		g_szTables[USERS_STATISTICS], g_szSQLName[id]);
	new iData[1]; iData[0] = __LINE__
	SQL_ThreadQuery(g_SqlTuple, "FreeHandle", szQuery, iData, sizeof(iData))

	ExecuteForward(g_eForwards[REGISTER], _, id);
}

_SaveData(id)
{		
	switch(g_CvarSaveType)
	{
		case 	SQL: 		SaveSQLData(id)
		case 	NVAULT:		SaveVaultData(id);
	}
}

SaveSQLData(id)
{
	static szQuery[TOTAL_SKINS * 10], iTotalInventoryValue, iQueryLen, weaponkill[4096];
	static droppedskins[2][TOTAL_SKINS * 6], weapbuff[TOTAL_SKINS * 6], stattrackkill[TOTAL_SKINS * 6], stattrackskins[TOTAL_SKINS * 6];
	new skinbuff[200], stattrakbuff[200], iLen[5]

	getTotalInventoryValue(id, iTotalInventoryValue);
	
	for(new iSkinID = 0; iSkinID < g_iSkinsNum; iSkinID++)
	{
		iLen[0] += formatex(stattrackskins[iLen[0]], 							charsmax(stattrackskins), 	"%d,", 	_:g_bIsWeaponStattrak[id][iSkinID])
		iLen[1] += formatex(stattrackkill[iLen[1]], 							charsmax(stattrackkill), 	"%d,", 	g_iUserStattrakKillCount[id][iSkinID])
		iLen[2] += formatex(droppedskins[_:DROPPED_SKINS][iLen[2]], 			charsmax(droppedskins[]), 	"%d,",	g_iUserSkinStatistics[id][iSkinID])
		iLen[3] += formatex(droppedskins[_:DROPPED_STT_SKINS][iLen[3]], 		charsmax(droppedskins[]), 	"%d,", 	g_iUserSttSkinStatistics[id][iSkinID])
		iLen[4] += formatex(weapbuff[iLen[4]], 									charsmax(weapbuff), 		"%d,", 	g_iUserSkins[id][iSkinID]);
	}

	iLen[0] = 0
	iLen[1] = 0
	iLen[2] = 0

	new szSkinName[256]

	for(new i = 1; i < CS_MAX_WEAPONS; i++)
	{
		if(g_iUserSelectedSkin[id][i] != -1)
		{
			ArrayGetString(g_aSkinName, g_iUserSelectedSkin[id][i], szSkinName, charsmax(szSkinName))
		}
		
		iLen[0] += formatex(skinbuff[iLen[0]], charsmax(skinbuff), "%d,", g_iUserSelectedSkin[id][i]);
		iLen[1] += formatex(stattrakbuff[iLen[1]], charsmax(stattrakbuff), "%d,", _:g_bShallUseStt[id][i])
		iLen[2] += formatex(weaponkill[iLen[2]], charsmax(weaponkill), "%d,", g_iUserWeaponKill[id][i])
	}

	iQueryLen = formatex(szQuery, charsmax(szQuery), "UPDATE %s AS data \
		JOIN %s AS skins ON skins.id = data.id \
		JOIN %s AS statistics ON statistics.id = data.id \
		SET \
		`money` = %d, \
		`scraps` = %d, \
		`keys` = %d, \
		`cases` = %d, \
		`kills` = %d, \
		`rank` = %d, \
		`nametag_capsules` = %d, \
		`nametag_common` = %d, \
		`nametag_rare` = %d, \
		`nametag_mythic` = %d, \
		`chat_clear` = %d, \
		`cases_glove` = %d, \
		`use_default_skin` = %d, \
		`last_seen` = %d, \
		`daily_bonus_time` = %d, \
		`rang` = %d, \
		`rang_experience` = %d, \
		`played_time` = %d, \
		`total_inventory` = '%s', \
		`skins` = '%s', \
		`stattrack_skins` = '%s', \
		`stattrack_kills` = '%s', \
		`selected_skins` = '%s', \
		`using_stattrak` = '%s', \
		`DROPPED_SKINS` = '%s', \
		`DROPPED_STT_SKINS` = '%s', \
		`WEAPON_KILLS` = '%s'",
		g_szTables[PLAYER_DATA], g_szTables[PLAYER_SKINS], g_szTables[USERS_STATISTICS],
		g_iUserMoney[id],
		g_iUserScraps[id],
		g_iUserKeys[id],
		g_iUserCases[id],
		g_iUserKills[id],
		g_iUserRank[id],
		g_iNameTagCapsule[id],
		g_iCommonNameTag[id],
		g_iRareNameTag[id],
		g_iMythicNameTag[id],
		_:g_bChatClear[id],
		g_iGlovesCases[id],
		_:g_bUserDefaultModels[id],
		get_systime(),
		g_iUserDailyTime[id],
		g_iRang[id],
		g_iRangExp[id],
		g_iTotalPlayedTime[id],
		AddCommas(iTotalInventoryValue),
		weapbuff,
		stattrackskins,
		stattrackkill,
		skinbuff,
		stattrakbuff,
		droppedskins[_:DROPPED_SKINS],
		droppedskins[_:DROPPED_STT_SKINS],
		weaponkill);

	for(new STATISTICS:iStats = RECEIVED_MONEY; iStats < STATISTICS; iStats++)
	{
		iQueryLen += formatex(szQuery[iQueryLen], charsmax(szQuery), ", `%s` = %i", g_szStatsName[_:iStats], g_eUserStatistics[id][iStats]);
	}

	formatex(szQuery[iQueryLen], charsmax(szQuery), " WHERE data.uname = ^"%s^";", g_szSQLName[id]);

	new iData[1]; iData[0] = __LINE__
	SQL_ThreadQuery(g_SqlTuple, "FreeHandle", szQuery, iData, sizeof(iData))
}

SaveVaultData(id)
{
	static Data[TOTAL_SKINS * 6];
	static infobuff[2048];
	static weapbuff[TOTAL_SKINS * 6];
	new skinbuff[512];
	new stattrakbuff[512];

	formatex(infobuff, charsmax(infobuff), "%s=%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
	g_szUserSavedPass[id], g_iUserMoney[id], g_iUserScraps[id], g_iUserKeys[id], g_iUserCases[id], g_iUserKills[id], g_iUserRank[id],
	g_iNameTagCapsule[id], g_iCommonNameTag[id], g_iRareNameTag[id], g_iMythicNameTag[id], g_bChatClear[id], g_iGlovesCases[id],
	g_bUserDefaultModels[id], g_iUserDailyTime[id], g_iTotalPlayedTime[id], g_iRang[id], g_iRangExp[id]);

	formatex(weapbuff, charsmax(weapbuff), "%d", g_iUserSkins[id][0]);
	for(new i = 1; i < g_iSkinsNum; i++)
	{
		format(weapbuff, charsmax(weapbuff), "%s,%d", weapbuff, g_iUserSkins[id][i]);
	}

	formatex(skinbuff, charsmax(skinbuff), "%d", g_iUserSelectedSkin[id][1]);
	for(new i = 2; i < 31; i++)
	{
		format(skinbuff, charsmax(skinbuff), "%s,%d", skinbuff, g_iUserSelectedSkin[id][i]);
	}

	formatex(stattrakbuff, charsmax(stattrakbuff), "%d", g_bShallUseStt[id][1] == true ? 1 : 0);
	for(new i = 2; i < 31; i++)
	{	
		format(stattrakbuff, charsmax(stattrakbuff), "%s,%d", stattrakbuff, g_bShallUseStt[id][i] == true ? 1 : 0)
	}

	formatex(Data, charsmax(Data), "%s*%s#%s@%s", infobuff, skinbuff, stattrakbuff, weapbuff);
	nvault_set(g_nVaultAccounts, g_szName[id], Data);
	
	saveStattrakStatus(id);
}

saveStattrakStatus(id)
{
	static szVaultData[TOTAL_SKINS * 6];
	formatex(szVaultData, charsmax(szVaultData), "%d", g_bIsWeaponStattrak[id][0] == true ? 1 : 0);

	for(new i = 1; i < g_iSkinsNum; i++)
	{
		format(szVaultData, charsmax(szVaultData), "%s,%d", szVaultData, g_bIsWeaponStattrak[id][i] == true ? 1 : 0);
	}

	nvault_set(g_nVaultStattrak, g_szName[id], szVaultData)
	saveStattrakKills(id);
}

public saveStattrakKills(id)
{
	static szVaultData[TOTAL_SKINS * 6]
	formatex(szVaultData, charsmax(szVaultData), "%d", g_iUserStattrakKillCount[id][0]);
	
	for(new i = 1; i < g_iSkinsNum; i++)
	{
		format(szVaultData, charsmax(szVaultData), "%s,%d", szVaultData, g_iUserStattrakKillCount[id][i])
	}

	nvault_set(g_nVaultStattrakKills, g_szName[id], szVaultData)
}


//LOAD DATA
_LoadData(id)
{
	switch(g_CvarSaveType)
	{
		case 	SQL: 		GetSQLData(id);
	
		case 	NVAULT:		GetVaultData(id);
	
		default: set_fail_state("Invalid save type mode (loading player data)");
	}
}

//SQL
GetSQLData(id)
{
	if(IsRegistered(id))
	{
		return PLUGIN_HANDLED;
	}

	g_bWaitingResponse[id] = true;
	new iData[1]; iData[0] = id; new szQuery[512];
	
	formatex(szQuery, charsmax(szQuery), 	"SELECT %s.*, %s.*, %s.* FROM %s \
											JOIN %s ON %s.id = %s.id \
											JOIN %s ON %s.id = %s.id \
											WHERE %s.uname = ^"%s^"",
											g_szTables[PLAYER_DATA], g_szTables[PLAYER_SKINS], g_szTables[USERS_STATISTICS],
											g_szTables[PLAYER_DATA],
											g_szTables[PLAYER_SKINS], g_szTables[PLAYER_SKINS], g_szTables[PLAYER_DATA],
											g_szTables[USERS_STATISTICS], g_szTables[USERS_STATISTICS], g_szTables[PLAYER_DATA],
											g_szTables[PLAYER_DATA], g_szSQLName[id]);

	SQL_ThreadQuery(g_SqlTuple, "GetUserData", szQuery, iData, sizeof(iData));
	return PLUGIN_CONTINUE;
}

public GetUserData(FailState, Handle:Query, szError[], ErrorCode, szData[], iSize)
{
	if(FailState || ErrorCode)
	{
		log_to_file(LOG_FILE, "[LINE: %i] An SQL Error has been encoutered. Error code %i^nError: %s", __LINE__, ErrorCode, szError);
		SQL_FreeHandle(Query);
		return;
	}

	new iResult = SQL_NumResults(Query)
	new id = szData[0];

	g_bWaitingResponse[id] = false;

	if(iResult == 0)
	{
		g_bAccountExists[id] = false;
		SQL_FreeHandle(Query)
		return
	}
	
	g_bWaitingSkins[id] = true;

	if(iResult == 1)
	{
		g_bAccountExists[id]	= 	true;
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "upassword"), g_szUserSavedPass[id], charsmax(g_szUserSavedPass[]));
		mysql_escape_string(g_szUserSavedPass[id], charsmax(g_szUserSavedPass[]))
		g_iUserMoney[id] 			=	 	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "money"));
		g_iUserScraps[id] 			=		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "scraps"));
		g_iUserKeys[id] 			=		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "keys"));
		g_iUserCases[id] 			=		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "cases"));
		g_iUserKills[id] 			=		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kills"));
		g_iUserRank[id] 			=		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "rank"));
		g_iNameTagCapsule[id] 		=		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "nametag_capsules"));
		g_iCommonNameTag[id]		=		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "nametag_common"));
		g_iRareNameTag[id] 			=		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "nametag_rare"));
		g_iMythicNameTag[id] 		=		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "nametag_mythic"));
		g_bChatClear[id] 			=		bool:SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "chat_clear"));
		g_iGlovesCases[id]			=	 	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "cases_glove"));
		g_bUserDefaultModels[id] 	=	 	bool:SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "use_default_skin"));
		g_iUserDailyTime[id]		=   	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "daily_bonus_time"))
		g_iTotalPlayedTime[id]		=   	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "played_time"))
		g_iRang[id]					=   	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "rang"))
		g_iRangExp[id]				=   	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "rang_experience"))

		new szValue[MAX_SKIN_TAG_LENGTH], j;
		static szQueryData[TOTAL_SKINS * 6];
		
		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "skins"), szQueryData, charsmax(szQueryData))
		j = 0

		while (j < g_iSkinsNum && szQueryData[0] && strtok2(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ','))
		{
			g_iUserSkins[id][j] = str_to_num(szValue);
			j++;
		}

		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "stattrack_skins"), szQueryData, charsmax(szQueryData))
		j = 0
		
		while (j < g_iSkinsNum && szQueryData[0] && strtok2(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ','))
		{
			g_bIsWeaponStattrak[id][j] = bool:str_to_num(szValue);
			j++;
		}

		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "stattrack_kills"), szQueryData, charsmax(szQueryData))
		j = 0

		while (j < g_iSkinsNum && szQueryData[0] && strtok2(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ','))
		{
			g_iUserStattrakKillCount[id][j] = str_to_num(szValue);
			j++;
		}

		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "selected_skins"), szQueryData, charsmax(szQueryData))
		j = 1;

		while(j < 31 && szQueryData[0] && strtok(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ','))
		{
			g_iUserSelectedSkin[id][j] = str_to_num(szValue);
			j++;
		}

		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "using_stattrak"), szQueryData, charsmax(szQueryData))
		j = 1;

		while(j < 31 && szQueryData[0] && strtok(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ','))
		{
			g_bShallUseStt[id][j] = bool:str_to_num(szValue);
			j++;
		}

		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "has_skin_nametag"), szQueryData, charsmax(szQueryData))
		j = 0;

		while(j < g_iSkinsNum && szQueryData[0] && strtok2(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ','))
		{
			if(!equali(szValue, "0"))
			{
				g_bHasSkinTag[id][j] = true;
			}
			
			j++
		}

		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "skin_tag"), szQueryData, charsmax(szQueryData))
		j = 0;

		while(j < g_iSkinsNum && szQueryData[0] && strtok2(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ','))
		{
			if(!equal(szValue, "0"))
			{
				g_szSkinsTag[id][j] = szValue;
			}

			j++
		}

		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "tag_level"), szQueryData, charsmax(szQueryData))
		j = 0;

		while(j < g_iSkinsNum && szQueryData[0] && strtok2(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ','))
		{
			g_iNameTagSkinLevel[id][j] = str_to_num(szValue);
			j++;
		}

		if(g_bActiveGloveSystem)
		{
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "gloves"), szQueryData, charsmax(szQueryData))
			j = 0;

			while(szQueryData[0] && strtok2(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ',') && j < MAX_GLOVES)
			{
				g_iUserGloves[id][j] = str_to_num(szValue);
				j++
			}

			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "weapon_gloves"), szQueryData, charsmax(szQueryData))
			j = 0;
			while(szQueryData[0] && strtok2(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ',') && j < 31)
			{
				g_iWeaponGloves[id][j] = str_to_num(szValue);
				j++;
			}
		}

		for(new STATISTICS:iStat = RECEIVED_MONEY; iStat < STATISTICS; iStat++ )
		{
			g_eUserStatistics[id][iStat] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, g_szStatsName[_:iStat]))
		}

		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, g_szStatsName[_:DROPPED_SKINS]), szQueryData, charsmax(szQueryData))
		j = 0;

		while(j < g_iSkinsNum && szQueryData[0] && strtok2(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ','))
		{
			g_iUserSkinStatistics[id][j] = str_to_num(szValue);
			j++;
		}

		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, g_szStatsName[_:DROPPED_STT_SKINS]), szQueryData, charsmax(szQueryData))
		j = 0;

		while(j < g_iSkinsNum && szQueryData[0] && strtok2(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ','))
		{
			g_iUserSttSkinStatistics[id][j] = str_to_num(szValue);
			j++;
		}

		SQL_ReadResult(Query, SQL_FieldNameToNum(Query, g_szStatsName[_:WEAPON_KILL]), szQueryData, charsmax(szQueryData))
		j = 1

		while(j < CS_MAX_WEAPONS && szQueryData[0] && strtok2(szQueryData, szValue, charsmax(szValue), szQueryData, charsmax(szQueryData), ','))
		{
			g_iUserWeaponKill[id][j] = str_to_num(szValue[0])
			j++
		}

		g_bWaitingSkins[id] = false
	}
	else 
	{
		g_bMultipleAccounts[id] = true;
		log_to_file(LOG_FILE, "Too many query results for account '%s' (ESCAPED NAME: '%s') (data table)", g_szName[id], g_szSQLName[id]);
	}

	SQL_FreeHandle(Query);
	
	return;
}

public SetUserSkin(const id, const skinid, const weaponid)
{
	new iBodyPart

	if(skinid != -1)
	{
		new szModel[128]
		ArrayGetString(g_aSkinModel, skinid, szModel, charsmax(szModel))

		CalculateModelBodyIndex(g_iWeaponGloves[id][weaponid], szModel, ArrayGetCell(g_aSkinBody, skinid), iBodyPart)
		cs_set_viewmodel_body(id, weaponid, iBodyPart)
		cs_set_modelformat(id, weaponid, szModel)

		return
	}

	if(!g_bUserDefaultModels[id])
	{
		CalculateModelBodyIndex(-1, g_eDefaultModels[weaponid][PATH], g_eDefaultModels[weaponid][BODYINDEX] > -1 ? g_eDefaultModels[weaponid][BODYINDEX] : 0, iBodyPart);
		cs_set_viewmodel_body(id, weaponid, iBodyPart)
		cs_set_modelformat(id, weaponid, g_eDefaultModels[weaponid][PATH])
	}
	else 
	{
		cs_set_modelformat(id, weaponid, "")
		cs_set_viewmodel_body(id, weaponid, -1)

		set_pev(id, pev_viewmodel2, g_szDefaultSkinModels[weaponid])
	}
}

public FreeHandle(FailState, Handle:Query, szError[], ErrorCode, szData[], iSize)
{
	if(FailState || ErrorCode)
	{
		log_to_file(LOG_FILE, "[FREEHANDLE] [LINE: %i] An SQL Error has been encoutered. Error code %i.^nError: %s", szData[0], ErrorCode, szError);
	}

	SQL_FreeHandle(Query);
}
//SQL

//NVAULT
GetVaultData(id)
{
	static Data[TOTAL_SKINS * 6];
	new iTimestamp;
	if (nvault_lookup(g_nVaultAccounts, g_szName[id], Data, charsmax(Data), iTimestamp) == 1)
	{
		new buffer[256];
		new userData[17][15];
		strtok2(Data, g_szUserSavedPass[id], charsmax(g_szUserSavedPass), Data, charsmax(Data), '=');
		strtok2(Data, buffer, charsmax(buffer), Data, charsmax(Data), '*');

		for(new i; i < sizeof(userData); i++)
		{
			strtok2(buffer, userData[i], charsmax(userData[]), buffer, charsmax(buffer), ',');
		}

		g_iUserMoney[id] 		  	=	 	str_to_num(userData[0]);
		g_iUserScraps[id] 		  	=	 	str_to_num(userData[1]);
		g_iUserKeys[id] 		  	=	 	str_to_num(userData[2]);
		g_iUserCases[id] 		  	=	 	str_to_num(userData[3]);
		g_iUserKills[id] 		  	=	 	str_to_num(userData[4]);
		g_iUserRank[id] 		  	=	 	str_to_num(userData[5]);
		g_iNameTagCapsule[id] 	  	=	 	str_to_num(userData[6]);
		g_iCommonNameTag[id] 	  	=	 	str_to_num(userData[7]);
		g_iRareNameTag[id] 		  	=	 	str_to_num(userData[8]);
		g_iMythicNameTag[id] 	  	=	 	str_to_num(userData[9]);
		g_bChatClear[id] 		  	=	 	bool:str_to_num(userData[10]);
		g_iGlovesCases[id] 		  	=	 	str_to_num(userData[11]);
		g_bUserDefaultModels[id] 	=	 	bool:str_to_num(userData[12]);
		g_iUserDailyTime[id]		=		str_to_num(userData[13])
		g_iTotalPlayedTime[id]		=		str_to_num(userData[14])
		g_iRang[id]					=		str_to_num(userData[15])
		g_iRangExp[id]				=		str_to_num(userData[16])

		new szValue[5], j = 1
		arrayset(buffer, 0, charsmax(buffer));
		strtok2(Data, buffer, charsmax(buffer), Data, charsmax(Data), '#');

		while (j < 31 && buffer[0] && strtok(buffer, szValue, charsmax(szValue), buffer, charsmax(buffer), ','))
		{
			g_iUserSelectedSkin[id][j] = str_to_num(szValue);
			j++;
		}

		arrayset(buffer, 0, charsmax(buffer));
		strtok2(Data, buffer, charsmax(buffer), Data, charsmax(Data), '@')

		j = 1;
		while(j < 31 && buffer[0] && strtok(buffer, szValue, charsmax(szValue), buffer, charsmax(buffer), ','))
		{
			g_bShallUseStt[id][j] = bool:str_to_num(szValue);
			j++;
		}

		j = 0;
		while (j < g_iSkinsNum && Data[0] && strtok2(Data, szValue, charsmax(szValue), Data, charsmax(Data), ','))
		{
			g_iUserSkins[id][j] = str_to_num(szValue);
			j++;
		}

	}
	
	loadStattrakStatus(id)
}


loadStattrakStatus(id)
{
	static Data[TOTAL_SKINS * 4]
	new iTimestamp
	if (nvault_lookup(g_nVaultStattrak, g_szName[id], Data, charsmax(Data), iTimestamp))
	{		
		new weaponData[8], j;

		while (j < g_iSkinsNum && Data[0] && strtok(Data, weaponData, charsmax(weaponData), Data, charsmax(Data), ','))
		{
			g_bIsWeaponStattrak[id][j] = bool:str_to_num(weaponData);
			j++;
		}
	}
	loadStattrakKills(id);
}

public loadStattrakKills(id)
{
	static Data[TOTAL_SKINS * 4];
	new iTimestamp;
	if (nvault_lookup(g_nVaultStattrakKills, g_szName[id], Data, charsmax(Data), iTimestamp))
	{	
		new weaponData[8];
		new j = 0;
		while (j < g_iSkinsNum && Data[0] && strtok2(Data, weaponData, charsmax(weaponData), Data, charsmax(Data), ','))
		{
			g_iUserStattrakKillCount[id][j] = bool:str_to_num(weaponData);
			j++;
		}
	}

	load_skin_tags(id);
}

//NVAULT

bool:IsRegistered(id)
{
	switch(g_CvarSaveType)
	{
		case SQL: {
			return g_bAccountExists[id];
		}

		case NVAULT: {
			new szData[1], iTs;
			return bool:nvault_lookup(g_nVaultAccounts, g_szName[id], szData, charsmax(szData), iTs);
		}
	}
	
	return false;
}

_ShowRegMenu(id)
{	
	if(g_bWaitingResponse[id])
	{
		fadescreen(id, 70, 1);

		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "WAITING_FOR_DATA_FIRST_MSG")
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "WAITINF_FOR_DATA_SECOND_MSG")
		
		return PLUGIN_HANDLED;
	}

	if(g_bMultipleAccounts[id])
	{
		fadescreen(id, 70, 1);

		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "MULTIPLE_ACCOUNTS_FIRST_MSG")
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "MULTIPLE_ACCOUNTS_SECOND_MSG")

		return PLUGIN_HANDLED;
	}

	if(!c_RegOpen)
	{
		return PLUGIN_HANDLED
	}

	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "REG_MENU");
	new menu = menu_create(temp, "reg_menu_handler", 0);
	new szItem[2];
	szItem[1] = 0;
	formatex(temp, 63, "\r%L \w%s", id, "REG_ACCOUNT", g_szName[id]);
	szItem[0] = 0;
	menu_additem(menu, temp, szItem, 0, -1);
	formatex(temp, 63, "\r%L \w%s^n", id, "REG_PASSWORD", g_szUserPassword[id]);
	szItem[0] = 1;
	menu_additem(menu, temp, szItem, 0, -1);
	if (g_bLogged[id] == false)
	{
		if (IsRegistered(id)) 
		{
			formatex(temp, 63, "\r%L", id, "REG_LOGIN");
			szItem[0] = 3;
			menu_additem(menu, temp, szItem, 0, -1);
		} 
		else 
		{
			formatex(temp, 63, "\r%L", id, "REG_REGISTER");
			szItem[0] = 4;
			menu_additem(menu, temp, szItem, 0, -1);
		}
	}
	szItem[0] = 5;
	menu_additem(menu, "\rChange password", szItem, 0, -1);

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
	return PLUGIN_HANDLED;
}

public reg_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	new itemdata[2];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, 1, {0}, 0, dummy);
	index = itemdata[0];
	
	switch (index)
	{
		case 0:
		{
			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CANT_CHANGE");
			_ShowRegMenu(id);
		}
		case 1:
		{
			if (g_bLogged[id] != true)
			{
				client_cmd(id, "messagemode UserPassword");
			}
		}
		case 2:
		{
			g_bLogged[id] = false;
		}
		case 3:
		{
			if (strlen(g_szUserPassword[id]) <= 0) 
			{
				client_cmd(id, "messagemode UserPassword");
				return PLUGIN_HANDLED
			}

			if(!equal(g_szUserPassword[id], g_szUserSavedPass[id]))
			{
				g_iUserPassFail[id]++;
				if (3 <= g_iUserPassFail[id])
				{
					new reason[32];
					formatex(reason, 31, "%L", id, "WRONG_PASS", 3);
					server_cmd("kick #%d ^"%s^"", get_user_userid(id), reason);
				}
				else
				{
					client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "PASS_FAIL", g_iUserPassFail[id], 3);
					fadescreen(id, 70, 1);
					_ShowRegMenu(id);
				}
			}
			else
			{
				g_bLogged[id] = true;
				
				if(is_user_alive(id))
				{
					new iActiveItem = get_member_s(id, m_pActiveItem)
					ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}	

				fadescreen(id, 70, 2);
				_ShowMainMenu(id);
				ExecuteForward(g_eForwards[LOGIN], _, id);
			
				set_task_ex(1.0, "playerAddTime", id + TASK_PLAYED_TIME, .flags = SetTask_Repeat)
			}
		}
		case 4:
		{
			new pLen = strlen(g_szUserPassword[id]);
	
			if (pLen < 6)
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "REG_INSERT_PASS", 6);
				_ShowRegMenu(id);
				return PLUGIN_HANDLED;
			}
			
			g_szUserSavedPass[id] = g_szUserPassword[id];

			if(g_CvarSaveType == SQL)
			{
				registerUser(id);
			}
			else
			{
				_SaveData(id);
			}
			
			_ShowRegMenu(id);
			
			client_print_color(id, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "REG_SUCCESS", g_szUserSavedPass[id]);
			
			fadescreen(id, 70, 3);
		}
		case 5:
		{
			if(!strlen(g_szUserSavedPass[id]))
			{
				client_print_color(id, id, "%s %l", CHAT_PREFIX, "NOT_HAVING_ACCOUNT")
				_ShowRegMenu(id);
				fadescreen(id, 70, 1);
				return PLUGIN_HANDLED
			}
			openChangeMenu(id)
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

public playerAddTime(id)
{
	id -= TASK_PLAYED_TIME

	g_iTotalPlayedTime[id]++
}

openChangeMenu(id)
{
	new iMenu = menu_create(fmt("%s \wChange password", MENU_PREFIX), "change_menu")
	
	new szItemFormat[128]
	formatex(szItemFormat, charsmax(szItemFormat), "Old password: \r%s", g_szUserOldPassword[id][0] ? g_szUserOldPassword[id] : "")
	menu_additem(iMenu, szItemFormat)
	
	formatex(szItemFormat, charsmax(szItemFormat), "New password: \r%s^n", g_szUserNewPassword[id][0] ? g_szUserNewPassword[id] : "")
	menu_additem(iMenu, szItemFormat)

	menu_additem(iMenu, "\rChange password")

	if(is_user_connected(id))
	{
		menu_display(id, iMenu)
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public change_menu(id, iMenu, iItem)
{
	if (iItem == -3)
	{
		_ShowRegMenu(id)
		menu_destroy(iMenu)
		return PLUGIN_HANDLED;
	}
	switch(iItem)
	{
		case 0:
		{		
			client_cmd(id, "messagemode UserOldPassword");
		}
		case 1:
		{
			client_cmd(id, "messagemode UserNewPassword")
		}
		case 2:
		{
			if(!(g_szUserOldPassword[id][0] && g_szUserNewPassword[id][0]))
			{
				openChangeMenu(id)
				return PLUGIN_HANDLED;
			}
			
			g_szUserSavedPass[id] = g_szUserNewPassword[id]
			g_szUserPassword[id] = g_szUserNewPassword[id]
			_ShowRegMenu(id);
			
			client_print_color(id, id, "%s %l", CHAT_PREFIX, "PASSWORD_CHANGED", g_szUserNewPassword[id]);
			g_szUserNewPassword[id] = ""
			g_szUserOldPassword[id] = ""
		}
	}

	menu_destroy(iMenu)
	return PLUGIN_HANDLED;
}

public concmd_newpassword(id)
{
	if (g_bLogged[id] == true)
	{
		return 1;
	}
	new data[32];
	read_args(data, 31);
	remove_quotes(data);
	if (6 > strlen(data))
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "REG_INSERT_PASS", 6);
		client_cmd(id, "messagemode UserNewPassword");
		return 1;
	}
	else if(equal(data, g_szUserSavedPass[id]))
	{
		client_print_color(id, id, "%s %l", CHAT_PREFIX, "PW_CANT_BE_THE_SAME");
		client_cmd(id, "messagemode UserNewPassword");
		return 1;
	}
	g_szUserNewPassword[id] = data
	openChangeMenu(id)
	return 1;
}

public concmd_oldpassword(id)
{
	if (g_bLogged[id] == true)
	{
		return 1;
	}
	new data[32];
	read_args(data, 31);
	remove_quotes(data);
	if (6 > strlen(data))
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "REG_INSERT_PASS", 6);
		client_cmd(id, "messagemode UserOldPassword");
		return 1;
	}
	else if(!equal(data, g_szUserSavedPass[id]))
	{
		g_iUserPassFail[id]++;
		if (3 <= g_iUserPassFail[id])
		{
			new reason[32];
			formatex(reason, 31, "%L", id, "WRONG_PASS", 3);
			server_cmd("kick #%d ^"%s^"", get_user_userid(id), reason);
		}
		else
		{
			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "PASS_FAIL", g_iUserPassFail[id], 3);
			client_cmd(id, "messagemode UserOldPassword");
		}
		return 1;
	}
	g_szUserOldPassword[id] = data
	openChangeMenu(id)
	return 1;
}

public concmd_password(id)
{
	if (g_bLogged[id] == true)
	{
		return 1;
	}
	new data[32];
	read_args(data, 31);
	remove_quotes(data);
	if (6 > strlen(data))
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "REG_INSERT_PASS", 6);
		client_cmd(id, "messagemode UserPassword");
		return 1;
	}
	g_szUserPassword[id] = data;
	_ShowRegMenu(id);
	return 1;
}

//showm
new g_iMainMenuPage[MAX_PLAYERS + 1]
new g_iMainMenuID[MAX_PLAYERS + 1]
_ShowMainMenu(id)
{
	g_iMainMenuPage[id] = 0

	new iMenu, szTitle[256]

	format_main_menu_title(id, szTitle, charsmax(szTitle))

	iMenu = menu_create(szTitle, "main_menu_handler")
	
	new szMenuStats[128], temp[95]
	format_menu_rank(id, szMenuStats, charsmax(szMenuStats))

	formatex(temp, 95, "\w%L", id, "MENU_INVENTORY");
	menu_additem(iMenu, temp, "0");

	formatex(temp, 95, "\w%L", id, "MENU_OC");
	menu_additem(iMenu, temp, "1");

	if (g_bIsSelling[id])
	{
		if(g_bUserSellSkin[id] == true)
		{
			new szSell[32];
			_GetItemName(g_iUserSellItem[id], szSell, 31);
			formatex(temp, 95, "\w%L \r[\y%s%s\r]", id, "MENU_MARKET", g_bPublishedStattrakSkin[id] ? "StatTrak " : "", szSell);
		}
		else if(g_bSellCapsule[id] == true)
		{
			formatex(temp, 95, "\w%L \r[\y%s\d Name-Tag\r]", id, "MENU_MARKET", g_iMarketNameTagsRarity[id] == 1 ? "Common" : g_iMarketNameTagsRarity[id] == 2 ? "Rare" : "Mythic");
		}
		else if(g_bSellGlove[id] == true)
		{
			new eGlove[GLOVESINFO];
			ArrayGetArray(g_aGloves, g_iMarketGloveID[id], eGlove)
			formatex(temp, 95, "\w%L \r[\y%s\d Glove\r]", id, "MENU_MARKET", eGlove[szGloveName]);
		}
	}
	else
	{
		formatex(temp, 95, "\w%L", id, "MENU_MARKET");
	}

	menu_additem(iMenu, temp, "2");

	formatex(temp, 95, "\r%L", id, "MENU_CONTRACT");
	menu_additem(iMenu, temp, "3");

	if(g_bGiveAwayStarted || total_players() < g_CvarGiveawayMinPlayers)
	{
		formatex(temp, 95, "\w%L", id, "MENU_GIVEAWAY_CLOSED");
	}
	else
	{
		formatex(temp, 95, "\w%L", id, "MENU_GIVEAWAY_OPEN");
	}

	menu_additem(iMenu, temp, "4");

	formatex(temp, 95, "\w%L", id, "MENU_UPGRADE");
	menu_additem(iMenu, temp, "5");

	formatex(temp, 95, "\w%L^n", id, "MENU_DESTROY");
	menu_additem(iMenu, temp, "6");

	menu_addtext(iMenu, szMenuStats, _:false);

	formatex(temp, 95, "\w%L", id, "MENU_GIFT");
	menu_additem(iMenu, temp, "7");

	formatex(temp, 95, "\w%L", id, "MENU_TRADE");
	menu_additem(iMenu, temp, "8");

	formatex(temp, 95, "\r%L", id, "MENU_GAMBLING");
	menu_additem(iMenu, temp, "9");

	formatex(temp, 95, "\w%L", id, "MENU_PREVIEW");
	menu_additem(iMenu, temp, "10");

	if(g_iUserRank[id] >= g_CvarDailyMinRank)
	{
		formatex(temp, 95, "%s%L", (g_iUserDailyTime[id] <= get_systime()) ? "\y" : "\d", id, "MENU_DAILY");
	} 
	else 
	{
		new szRankName[64]
		ArrayGetString(g_aRankName, g_CvarDailyMinRank, szRankName, charsmax(szRankName))

		formatex(temp, 95, "\d%l %l", "MENU_DAILY", "MENU_MIN_RANK_INFO", szRankName);
	}

	menu_additem(iMenu, temp, "11");

	formatex(temp, 95, "\w%L", id, "MENU_SETTINGS_TITLE");
	menu_additem(iMenu, temp, "12");

	formatex(temp, 95, "\w%L", id, "MENU_STATISTICS_TITLE");
	menu_additem(iMenu, temp, "13");

	addDynamicMenus(id, iMenu, MenuCode:MENU_MAIN)

	// menu_setprop(iMenu, MPROP_SHOWPAGE, false)
	menu_setprop(iMenu, MPROP_PAGE_CALLBACK, "MainMenuPageCallback")

	if(is_user_connected(id))
	{
		menu_display(id, iMenu, 0, -1)
		g_iMainMenuID[id] = iMenu
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

format_main_menu_title(const id, buffer[], const bufferlen)
{
	new szRank[64], szRang[64]
	ArrayGetString(g_aRankName, g_iUserRank[id], szRank, charsmax(szRank))
	ArrayGetString(g_aRangName, g_iRang[id], szRang, charsmax(szRang))

	formatex(buffer, bufferlen, "%s %l", MENU_PREFIX, "MENU_TITLE_INFO",
		g_szName[id],
		szRank,
		szRang,
		AddCommas(g_iUserMoney[id]),
		fmt("%s%i\dh\r %s%i\dm", (g_iTotalPlayedTime[id] / 60 ) / 60 > 9 ? "" : "0", (g_iTotalPlayedTime[id] / 60 ) / 60, (g_iTotalPlayedTime[id] / 60) % 60 > 9 ? "" : "0", (g_iTotalPlayedTime[id]/ 60) % 60 )
	)
}

public MainMenuPageCallback(const id, const status, const menu)
{
	if(status == MENU_MORE)
	{
		g_iMainMenuPage[id]++ 
	}
	else 
	{
		g_iMainMenuPage[id]--
	}

	new szTitle[256]

	if(g_iMainMenuPage[id] == 0)
	{
		format_main_menu_title(id, szTitle, charsmax(szTitle))
	}
	else 
	{
		formatex(szTitle, charsmax(szTitle), "%s %l", MENU_PREFIX, "MENU_TITLE_CLEAR")
	}

	menu_setprop(g_iMainMenuID[id], MPROP_TITLE, szTitle)
}

stock format_menu_rank(const id, szMenuItem[], iLen)
{
	new szRank[64];
	new iStringLen

	if(g_iUserRank[id] + 1 >= ArraySize(g_aRankKills))
	{
		iStringLen = formatex(szMenuItem, iLen, "%l", "MENU_MAX_RANK")
	}
	else 
	{
		ArrayGetString(g_aRankName, g_iUserRank[id] + 1, szRank, charsmax(szRank))
		iStringLen = formatex(szMenuItem, iLen, "%l", "MENU_NEXT_RANK_INFO",
		szRank, AddCommas(g_iUserKills[id]), AddCommas(ArrayGetCell(g_aRankKills, g_iUserRank[id] + 1)))
	}

	if(g_iRang[id] + 1 >= ArraySize(g_aRangName))
	{
		formatex(szMenuItem[iStringLen], iLen, "^n%l", "MENU_MAX_RANG")
	}
	else 
	{
		ArrayGetString(g_aRangName, g_iRang[id] + 1, szRank, charsmax(szRank))
		formatex(szMenuItem[iStringLen], iLen, "^n%l", "MENU_NEXT_RANG_INFO",
		szRank, AddCommas(g_iRangExp[id]), AddCommas(ArrayGetCell(g_aRangExp, g_iRang[id] + 1)));
	}
}

_GetItemName(item, temp[], len)
{
	ArrayGetString(g_aSkinName, item, temp, len);
	return PLUGIN_HANDLED;
}

public main_menu_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return
	}

	new szMenuInfo[4], iMenuInfo;
	menu_item_getinfo(menu, item, _, szMenuInfo, charsmax(szMenuInfo), _, _, _);
	menu_destroy(menu)

	iMenuInfo = str_to_num(szMenuInfo)

	switch (iMenuInfo)
	{
		case 0:
		{
			g_iMenuToOpen[id] = 0
			ShowInventoryMenu(id)
		}
		case 1:
		{
			_ShowOpenCaseCraftMenu(id);
		}
		case 2:
		{
			g_iMenuToOpen[id] = 3
			_ShowMarketMenu(id);
		}
		case 3:
		{
			g_iMenuToOpen[id] = 1
			_ShowContractMenu(id)
		}
		case 4:
		{
			if(!g_bGiveAwayStarted)
			{
				joinGiveaway(id);
			}
			else 
			{
				_ShowMainMenu(id);
			}
		}
		case 5:
		{
			g_iMenuToOpen[id] = 8
			_ShowUpgradeMenu(id)
		}
		case 6:
		{
			g_iMenuToOpen[id] = 4
			_ShowDustbinMenu(id);
		}
		case 7:
		{
			g_iMenuToOpen[id] = 5
			_ShowGiftMenu(id);
		}
		case 8:
		{
			g_iMenuToOpen[id] = 6
			_ShowTradeMenu(id);
		}
		case 9:
		{
			_ShowGamesMenu(id);
		}
		case 10:
		{
			open_preview_menu(id);
		}
		case 11:
		{
			DailyReward(id);
		}

		case 12:
		{
			OpenSettingsMenu(id)
		}

		case 13:
		{
			OpenStatisticsMenu(id)
		}

		default:
		{
			ExecuteForward(g_eForwards[MENU_ITEM_SELECTED], _, id, _:MENU_MAIN, iMenuInfo)
		}
	}
	
	return
}

OpenStatisticsMenu(const id)
{
	new iMenu = menu_create(fmt("%s %l", MENU_PREFIX, "MENU_STATISTICS_TITLE"), "statistics_menu_handler")

	menu_additem(iMenu, fmt("%l", "MENU_STATISTICS_SERVER"))
	menu_additem(iMenu, fmt("%l", "MENU_STATISTICS_USER"))

	menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)

	if(is_user_connected(id))
	{
		menu_display(id, iMenu)
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public statistics_menu_handler(const id, const menu, const item)
{
	menu_destroy(menu)

	if(item == MENU_EXIT)
	{
		_ShowMainMenu(id)
		return
	}

	ShowStatsMenu(id, bool:item)

	return
}

ShowStatsMenu(const id, const bool:bUser)
{
	new iMenu = menu_create(fmt("%s %l %l", MENU_PREFIX, bUser ? "MENU_STATISTICS_USER" : "MENU_STATISTICS_SERVER", "MENU_STATISTICS_TITLE"), "show_stats_handler")

	menu_additem(iMenu, fmt("%l", "MENU_SKINS_STATISTICS"), bUser ? "user" : "server")
	menu_additem(iMenu, fmt("%l", "MENU_WEAPON_KILLS"), 	bUser ? "user" : "server")

	for(new STATISTICS:iStats = RECEIVED_MONEY, eGlove[GLOVESINFO]; iStats < STATISTICS; iStats++)
	{
		if(iStats == RECEIVED_MONEY)
		{
			menu_additem(iMenu, fmt("%l^n%l\y$", g_szStatsLang[_:iStats], "MENU_STATISTICS_DESCRIPTION", AddCommas(bUser ? g_eUserStatistics[id][iStats] : g_eServerStatistics[iStats])))
			continue
		}

		switch(iStats)
		{
			case DROPPED_GLOVE0:
			{
				ArrayGetArray(g_aGloves, GLOVE0, eGlove, sizeof(eGlove))
				menu_additem(iMenu, fmt("%l^n%l", g_szStatsLang[_:iStats], eGlove[szGloveName], "MENU_STATISTICS_DESCRIPTION", AddCommas(bUser ? g_eUserStatistics[id][iStats] : g_eServerStatistics[iStats])))
			}

			case DROPPED_GLOVE1:
			{
				ArrayGetArray(g_aGloves, GLOVE1, eGlove, sizeof(eGlove))
				menu_additem(iMenu, fmt("%l^n%l", g_szStatsLang[_:iStats], eGlove[szGloveName], "MENU_STATISTICS_DESCRIPTION", AddCommas(bUser ? g_eUserStatistics[id][iStats] : g_eServerStatistics[iStats])))
			}

			case DROPPED_GLOVE2:
			{
				ArrayGetArray(g_aGloves, GLOVE2, eGlove, sizeof(eGlove))
				menu_additem(iMenu, fmt("%l^n%l", g_szStatsLang[_:iStats], eGlove[szGloveName], "MENU_STATISTICS_DESCRIPTION", AddCommas(bUser ? g_eUserStatistics[id][iStats] : g_eServerStatistics[iStats])))
			}

			case DROPPED_GLOVE3:
			{
				ArrayGetArray(g_aGloves, GLOVE3, eGlove, sizeof(eGlove))
				menu_additem(iMenu, fmt("%l^n%l", g_szStatsLang[_:iStats], eGlove[szGloveName], "MENU_STATISTICS_DESCRIPTION", AddCommas(bUser ? g_eUserStatistics[id][iStats] : g_eServerStatistics[iStats])))
			}

			case DROPPED_GLOVE4:
			{
				ArrayGetArray(g_aGloves, GLOVE4, eGlove, sizeof(eGlove))
				menu_additem(iMenu, fmt("%l^n%l", g_szStatsLang[_:iStats], eGlove[szGloveName], "MENU_STATISTICS_DESCRIPTION", AddCommas(bUser ? g_eUserStatistics[id][iStats] : g_eServerStatistics[iStats])))
			}

			default:
			{
				menu_additem(iMenu, fmt("%l^n%l", g_szStatsLang[_:iStats], "MENU_STATISTICS_DESCRIPTION", AddCommas(bUser ? g_eUserStatistics[id][iStats] : g_eServerStatistics[iStats]))) 
			}
		}
	}

	menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)

	if(is_user_connected(id))
	{
		menu_display(id, iMenu)
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public show_stats_handler(const id, const menu, const item)
{
	if(item == MENU_EXIT)
	{
		OpenStatisticsMenu(id)
		return
	}
	
	enum 
	{
		ITEM_SKINS,
		ITEM_WEAPON_KILLS
	}

	new szData[7]
	menu_item_getinfo(menu, item, _, szData, charsmax(szData), _, _, _)

	new bool:bUser = bool:equal(szData, "user")
	
	if(item == ITEM_SKINS || item == ITEM_WEAPON_KILLS)
	{
		
		ShowStatsMenu(id, bUser)

		client_print_color(id, print_team_default, "%s Not available for moment", CHAT_PREFIX)

		menu_destroy(menu)
		return
	}

	menu_destroy(menu)
	ShowStatsMenu(id, bUser)
}

ShowInventoryMenu(const id)
{
	new iTotalInventory, iTotalSkinsValue, iTotalNameTagValue, iTotalGlovesValue
	getTotalInventoryValue(id, iTotalInventory, iTotalSkinsValue, iTotalNameTagValue, iTotalGlovesValue)
	
	new iMenu = menu_create(fmt("%s %l", MENU_PREFIX, "MENU_INVENTORY_TITLE", AddCommas(iTotalInventory)), "inventory_menu_handler")
	new szItem[192]

	formatex(szItem, charsmax(szItem), "%l %l", "MENU_SKINS", "MENU_INVENTORY_VALUE", AddCommas(iTotalSkinsValue))
	menu_additem(iMenu, szItem, "0")

	formatex(szItem, charsmax(szItem), "%l %l", "MENU_NAMETAG", "MENU_INVENTORY_VALUE", AddCommas(iTotalNameTagValue))
	menu_additem(iMenu, szItem, "1")

	if(g_bActiveGloveSystem)
	{
		formatex(szItem, charsmax(szItem), "%l %l", "MENU_GLOVES", "MENU_INVENTORY_VALUE", AddCommas(iTotalGlovesValue))
		menu_additem(iMenu, szItem, "2")
	}

	addDynamicMenus(id, iMenu, MenuCode:MENU_INVENTORY)

	menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)
	menu_setprop(iMenu, MPROP_SHOWPAGE, false)

	if(is_user_connected(id))
	{
		menu_display(id, iMenu)
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

stock getTotalInventoryValue(const id, &iTotalInventoryValue, &iTotalSkinsValue = -1, &iTotalNameTagValue = -1, &iTotalGlovesValue = -1)
{
	new iTotalDynamicInvValue 		=		getDynamicInvValue(id)
	iTotalSkinsValue 				=		getUserTotalSkinsValue(id)
	
	if(iTotalNameTagValue != -1)
	{
		iTotalNameTagValue 				=		getUserTotalNametagValue(id)
	} else iTotalNameTagValue = 0
	
	if(iTotalGlovesValue != -1)
	{
		iTotalGlovesValue 				=		g_bActiveGloveSystem ? getUserTotalGlovesValue(id) : 0
	} else iTotalGlovesValue = 0

	iTotalInventoryValue = iTotalSkinsValue + iTotalGlovesValue + iTotalNameTagValue + iTotalDynamicInvValue
}

stock getUserTotalSkinsValue(const id)
{
	new iTotalValue
	for(new i = 0; i < g_iSkinsNum; i++)
	{
		iTotalValue += ArrayGetCell(g_aSkinCostMin, i) * g_iUserSkins[id][i]
	}

	return iTotalValue
}

stock getDynamicInvValue(const id)
{
	new const MenuCode:menu_code = MENU_INVENTORY
	new iTotalValue
	new eMenuData[MENU_DATA]
	new eUserMenuData[USER_MENU_DATA]
	new szID[4]
	num_to_str(id, szID, charsmax(szID))

	iTotalValue = 0

	for(new i; i < ArraySize(g_aeMenus[MENU_ITEMS:menu_code]); i++)
	{
		ArrayGetArray(g_aeMenus[MENU_ITEMS:menu_code], i, eMenuData)

		if(TrieKeyExists(eMenuData[tUserMenuData], szID))
		{
			TrieGetArray(eMenuData[tUserMenuData], szID, eUserMenuData, sizeof(eUserMenuData))
			iTotalValue += eUserMenuData[iInventoryValue]
		}
	}

	return iTotalValue
}

stock getUserTotalGlovesValue(const id)
{
	new iTotalValue
	new eGlove[MAX_GLOVES][GLOVESINFO]

	for(new i; i < MAX_GLOVES; i++)
	{
		ArrayGetArray(g_aGloves, i, eGlove[i])
		iTotalValue += g_iUserGloves[id][i + 1] * eGlove[i][iMinPrice]
	}

	for(new i, iWeaponGlove; i < 31; i++)
	{
		if(g_iWeaponGloves[id][i] == -1)
		{
			continue;
		}

		iWeaponGlove = g_iWeaponGloves[id][i]
		iTotalValue += iWeaponGlove * eGlove[iWeaponGlove][iMinPrice]
	}

	return iTotalValue
}

stock getUserTotalNametagValue(const id)
{
	new iTotalValue = 0

	for(new i; i < g_iSkinsNum; i++)
	{
		switch(g_iNameTagSkinLevel[id][i])
		{
			case NAMETAG_COMMON: iTotalValue += g_CvarCommonPrice
			case NAMETAG_RARE: iTotalValue += g_CvarRarePrice
			case NAMETAG_MYTHIC: iTotalValue += g_CvarMythicPrice
			case NAMETAG_NONE: continue

			default: 
			{
				log_to_file(LOG_FILE, "Invalid nametag indentifier. Line %d", __LINE__)
			}
		}
	}

	iTotalValue += g_iCommonNameTag[id] * g_CvarCommonPrice
	iTotalValue += g_iRareNameTag[id] * g_CvarRarePrice
	iTotalValue += g_iMythicNameTag[id] * g_CvarMythicPrice

	return iTotalValue
}

stock addDynamicMenus(const id, const &menu, MenuCode:menu_code)
{
	new iLen

	if(!(iLen = ArraySize(g_aeMenus[MENU_ITEMS:menu_code])))
	{
		return
	}

	new eMenuData[MENU_DATA], szAdditionalMenuName[MAX_MENU_ADDITIONAL_NAME_LENGTH], szID[4]

	num_to_str(id, szID, charsmax(szID))

	for(new i = 0, eUserMenuData[USER_MENU_DATA]; i < iLen; i++)
	{
		ArrayGetArray(g_aeMenus[MENU_ITEMS:menu_code], i, eMenuData)

		if(!TrieKeyExists(eMenuData[tUserMenuData], szID))
		{
			menu_additem(menu, fmt("%s", eMenuData[szMenuName]), fmt("%d", i + g_cItemCounter[_:menu_code]))
			continue	
		}

		if(MenuCode:menu_code == MenuCode:MENU_INVENTORY)
		{
			TrieGetArray(eMenuData[tUserMenuData], szID, eUserMenuData, sizeof(eUserMenuData))
			menu_additem(menu, fmt("%s %l %s", eMenuData[szMenuName], "MENU_INVENTORY_VALUE", AddCommas(eUserMenuData[iInventoryValue]), eUserMenuData[szAdditionalName]), fmt("%d", i + g_cItemCounter[_:menu_code]))
			continue
		}
		
		TrieGetString(eMenuData[tUserMenuData], szID, szAdditionalMenuName, charsmax(szAdditionalMenuName))
		menu_additem(menu, fmt("%s %s", eMenuData[szMenuName], szAdditionalMenuName), fmt("%d", i + g_cItemCounter[_:menu_code]))
	}
}

public inventory_menu_handler(const id, const menu, const item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		_ShowMainMenu(id)
		return
	}

	new szMenuInfo[4]
	menu_item_getinfo(menu, item, _, szMenuInfo, charsmax(szMenuInfo), _, _, _)
	new iMenuInfo = str_to_num(szMenuInfo)

	switch(iMenuInfo)
	{
		case 0: 
		{
			_ShowSkinMenu(id)
		}

		case 1:
		{
			open_skin_tag_menu(id)
		}

		case 2:
		{
			open_gloves_menu(id)
		}

		default:
		{
			ExecuteForward(g_eForwards[MENU_ITEM_SELECTED], _, id, _:MENU_INVENTORY, iMenuInfo)
		}
	}

	return 
}

OpenSettingsMenu(id)
{
	new iMenu = menu_create(fmt("%s %l", MENU_PREFIX, "MENU_SETTINGS_TITLE"), "settings_menu_handler")
	new szMenuItem[256]

	formatex(szMenuItem, charsmax(szMenuItem), "\w%l^n%l", "MENU_CHAT_CLEAR", g_bChatClear[id] ? "ON" : "OFF", "MENU_CHAT_CLEAR_TEXT");
	menu_additem(iMenu, szMenuItem, "0");

	formatex(szMenuItem, charsmax(szMenuItem), "\w%l^n%l", "MENU_DEFAULT_SKINS", g_bUserDefaultModels[id] ? "ON" : "OFF", "MENU_DEFAULT_SKINS_TEXT");
	menu_additem(iMenu, szMenuItem, "1");

	addDynamicMenus(id, iMenu, MenuCode:MENU_SETTINGS)
	
	if(is_user_connected(id))
	{
		menu_setprop(iMenu, MPROP_SHOWPAGE, false)
		menu_display(id, iMenu, 0, -1) 
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public settings_menu_handler(const id, const menu, const item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		_ShowMainMenu(id)
		return 
	}

	new szMenuInfo[5]
	menu_item_getinfo(menu, item, _, szMenuInfo, charsmax(szMenuInfo), _, _, _)
	new iMenuInfo = str_to_num(szMenuInfo)

	switch(str_to_num(szMenuInfo))
	{
		case 0:
		{
			toggle_clear_chat(id);
		}

		case 1:
		{
			toggle_default_skins(id)
		}

		default:
		{
			ExecuteForward(g_eForwards[MENU_ITEM_SELECTED], _, id, _:MENU_SETTINGS, iMenuInfo)
			return
		}
	}

	menu_destroy(menu)
	OpenSettingsMenu(id)

	return
}

toggle_clear_chat(id)
{
	g_bChatClear[id] = !g_bChatClear[id];
	client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "CHAT_CLEAR_CHAT_MSG", g_bChatClear[id]? "enabled" : "disabled", g_bChatClear[id] ? "won't" : "will");
	_ShowMainMenu(id);
}

toggle_default_skins(id)
{
	g_bUserDefaultModels[id] = !g_bUserDefaultModels[id];
	new wid = get_user_weapon(id);

	SetUserSkin(id, g_iUserSelectedSkin[id][wid], wid)
	_ShowMainMenu(id);

	client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "USE_DEFAULT_MODELS_CHAT_MSG", g_bUserDefaultModels[id] ? "enabled" : "disabled");
}

public open_skin_tag_menu(id)
{
	new iMenu = menu_create(fmt("%s %l", MENU_PREFIX, "MENU_SKIN_TAGS_TITLE", g_iNameTagCapsule[id], g_iNameTagCapsule[id] > 1 ? "s" : ""), "open_skin_tag_menu_handler");

	new szItem[64];
	formatex(szItem, charsmax(szItem), "%l", "OPEN_NAMETAG_CAPSULE_ITEM")
	menu_additem(iMenu, szItem);

	menu_additem(iMenu, fmt("%l", "SET_NAMETAG_ITEM"));

	menu_additem(iMenu, fmt("%l", "NAMETAG_LIST_ITEM"));

	formatex(szItem, charsmax(szItem), "\r%d\d Common Name-Tag%s", g_iCommonNameTag[id], g_iCommonNameTag[id] > 1 ? "s" : "");
	menu_addtext2(iMenu, szItem);

	formatex(szItem, charsmax(szItem), "\r%d\d Rare Name-Tag%s^n\r%d\d Mythic Name-Tag%s",
	g_iRareNameTag[id], g_iRareNameTag[id] > 1 ? "s" : "", g_iMythicNameTag[id], g_iMythicNameTag[id] > 1 ? "s" : "")
	menu_addtext2(iMenu, szItem);

	if(is_user_connected(id))
	{
		menu_display(id, iMenu, 0, -1);
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public open_skin_tag_menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		ShowInventoryMenu(id);
		return PLUGIN_HANDLED;
	}

	switch(item)
	{
		case 0: open_name_tag_capsule(id);
		case 1: show_stattrak_inventory(id);
		case 2: active_name_tags(id);
	}

	menu_destroy(menu);

	return PLUGIN_CONTINUE;
}

public open_name_tag_capsule(id)
{
	if(g_iNameTagCapsule[id] < 1)
	{
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NOT_ENOUGH_NAMETAG_CAPSULES_MSG");
		open_skin_tag_menu(id);
		return PLUGIN_HANDLED;
	}

	new iRandom = random_num(1,3);
	new iRandomNameTag = random_num(0,100);
	new bool:bItemDropped
	new iItemType

	switch(iRandom)
	{
		case 1:
		{
			if(!is_user_gold_vip(id) && !is_user_silver_vip(id))
			{
				if(iRandomNameTag <= g_CvarCommonNameTagChance)
				{
					bItemDropped = true
					g_iCommonNameTag[id]++;
					AddStatistics(id, DROPPED_NAMETAG_COMMON, 1, .line = __LINE__)
					iItemType = NAMETAG_COMMON
				}
			}
			else 
			{
				if(is_user_gold_vip(id))
				{
					if(iRandomNameTag <= g_CvarCommonNameTagChance + g_CvarGoldVipNameTagChance)
					{
						bItemDropped = true
						g_iCommonNameTag[id]++;
						AddStatistics(id, DROPPED_NAMETAG_COMMON, 1, .line = __LINE__)
						iItemType = NAMETAG_COMMON
					}
				}
				else if (is_user_silver_vip(id))
				{
					if(iRandomNameTag <= g_CvarCommonNameTagChance + g_CvarSilverVipNameTagChance)
					{
						bItemDropped = true
						g_iCommonNameTag[id]++;
						AddStatistics(id, DROPPED_NAMETAG_COMMON, 1)
						iItemType = NAMETAG_COMMON
					}
				}
			}
		}

		case 2:
		{
			if(!is_user_gold_vip(id) && !is_user_silver_vip(id))
			{
				if(iRandomNameTag <= g_CvarRareNameTagChance )
				{
					bItemDropped = true
					g_iRareNameTag[id]++;
					AddStatistics(id, DROPPED_NAMETAG_RARE, 1, .line = __LINE__)
					iItemType = NAMETAG_RARE
				}
			}
			else 
			{
				if(is_user_gold_vip(id))
				{
					if(iRandomNameTag <= g_CvarRareNameTagChance + g_CvarGoldVipNameTagChance)
					{
						bItemDropped = true
						g_iRareNameTag[id]++;
						AddStatistics(id, DROPPED_NAMETAG_RARE, 1, .line = __LINE__)
						iItemType = NAMETAG_RARE
					}
				}
				else if (is_user_silver_vip(id))
				{
					if(iRandomNameTag <= g_CvarRareNameTagChance + g_CvarSilverVipNameTagChance)
					{
						bItemDropped = true
						g_iRareNameTag[id]++;
						AddStatistics(id, DROPPED_NAMETAG_RARE, 1, .line = __LINE__)
						iItemType = NAMETAG_RARE
					}
				}
			}
		}

		case 3:
		{
			if(!is_user_gold_vip(id) && !is_user_silver_vip(id))
			{
				if(iRandomNameTag <= g_CvarMythicNameTagChance)
				{
					bItemDropped = true
					g_iMythicNameTag[id]++;
					AddStatistics(id, DROPPED_NAMETAG_MYTHICS, 1, .line = __LINE__)
					iItemType = NAMETAG_MYTHIC
				}
			}
			else 
			{
				if(is_user_gold_vip(id))
				{
					if(iRandomNameTag <= g_CvarMythicNameTagChance + g_CvarGoldVipNameTagChance)
					{
						bItemDropped = true
						g_iMythicNameTag[id]++;
						AddStatistics(id, DROPPED_NAMETAG_MYTHICS, 1, .line = __LINE__)
						iItemType = NAMETAG_MYTHIC
					}
				}
				else if (is_user_silver_vip(id))
				{
					if(iRandomNameTag <= g_CvarMythicNameTagChance + g_CvarSilverVipNameTagChance)
					{
						bItemDropped = true
						g_iMythicNameTag[id]++;
						AddStatistics(id, DROPPED_NAMETAG_MYTHICS, 1, .line = __LINE__)
						iItemType = NAMETAG_MYTHIC
					}
				}
			}
		}
	}

	if(bItemDropped)
	{
		client_print_color(0, print_team_default, "%s %l", CHAT_PREFIX, "GOT_NAMETAG", g_szName[id], iItemType == NAMETAG_COMMON ? "Common" : iItemType == NAMETAG_RARE ? "Rare" : "Mythic");
	}
	else 
	{
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "DIDNT_GOT_NAMETAG")
	}

	g_iNameTagCapsule[id]--;

	open_skin_tag_menu(id);

	return PLUGIN_HANDLED;
}

public active_name_tags(id)
{
	new iMenu = menu_create(fmt("%s Active Name-Tags", MENU_PREFIX), "active_name_tags_handler");
	
	new szSkinName[64], szItem[64], szParseData[6];

	new iTotalNameTags;

	for(new i; i < g_iSkinsNum - 1; i++)
	{
		if(g_bHasSkinTag[id][i] == true)
		{
			ArrayGetString(g_aSkinName, i, szSkinName, charsmax(szSkinName));
			formatex(szItem, charsmax(szItem), "%s \d-\r (%s)\y %s", szSkinName, g_iNameTagSkinLevel[id][i] == 1 ? "Common" : g_iNameTagSkinLevel[id][i] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][i]);
			num_to_str(i, szParseData, charsmax(szParseData));
			menu_additem(iMenu, szItem, szParseData);
			iTotalNameTags++;
		}
	}

	if(iTotalNameTags == 0)
	{
		menu_additem(iMenu, "\dYou don't have used any name-tags");
	}

	if(is_user_connected(id))
	{
		menu_display(id, iMenu);
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public active_name_tags_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		open_skin_tag_menu(id);
		return PLUGIN_HANDLED;
	}

	new szData[10], szSkinName[64], szName[64];
	menu_item_getinfo(menu, item, _, szData, charsmax(szData), szName, charsmax(szName), _);

	new index = str_to_num(szData);

	if(item == 0 && !szData[0])
	{
		active_name_tags(id);
		return PLUGIN_HANDLED;
	}

	if(g_bHasSkinTag[id][index] && !g_szSkinsTag[id][index][0])
	{
		strtok2(szName, szSkinName, charsmax(szSkinName), szName, charsmax(szName), '\', TRIM_FULL);

		if(g_iNewNameTagIndex[id] != -1)
			return PLUGIN_HANDLED;

		g_iNewNameTagIndex[id] = index;

		client_cmd(id, "messagemode NewSkinTag");

		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "WILL_SET_NAMETAG", szSkinName);
	}
	else active_name_tags(id);

	return PLUGIN_CONTINUE;
}

public concmd_new_skintag(id)
{
	new szArg[MAX_SKIN_TAG_LENGTH + 1];
	read_args(szArg, charsmax(szArg));
	remove_quotes(szArg);
	trim(szArg);

	if(containi(szArg, "#") != -1 || containi(szArg, ",") != -1 || containi(szArg, "^"") != -1)
	{
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "INVALID_CHARACTERS");
		client_cmd(id, "messagemode NewSkinTag");
		return PLUGIN_HANDLED;
	}

	new index = g_iNewNameTagIndex[id];

	g_szSkinsTag[id][index] = szArg;

	g_iNewNameTagIndex[id] = -1;

	new szSkinName[128];
	_GetItemName(index, szSkinName, charsmax(szSkinName));

	save_skin_tags(id);
	active_name_tags(id);

	new szSkinTag[MAX_SKIN_TAG_LENGTH * 2 + 1]

	copy(szSkinTag, charsmax(szSkinTag), g_szSkinsTag[id][index])
	mysql_escape_string(szSkinTag, charsmax(szSkinTag))

	client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NAMETAG_SET", szSkinTag, szSkinName);
	
	return PLUGIN_HANDLED;
}

public show_stattrak_inventory(id)
{
	new iMenu = menu_create(fmt("%s %l", MENU_PREFIX, "STATTRAK_INVENTORY_TITLE"), "show_stattrak_inventory_handler");
	
	new szItem[128], szData[5], iWeaponID;

	for(new i; i < sizeof(g_WeapMenu); i++)
	{
		iWeaponID = g_WeapMenu[i][WeaponID];

		if(getMaxSkinsOfWeapon(iWeaponID) > 0)
		{									
			formatex(szItem, charsmax(szItem), "%s \r[\w%d\r]", g_WeapMenu[i][WeapName], getUserStattrakSkins(id, iWeaponID))
			num_to_str(g_WeapMenu[i][WeaponID], szData, charsmax(szData))
			menu_additem(iMenu, szItem, szData);
		}
	}
	
	if(is_user_connected(id))
	{
		menu_display(id, iMenu)
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public show_stattrak_inventory_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		open_skin_tag_menu(id);
		return PLUGIN_HANDLED;
	}

	new szWeaponID[4], szParseItemName[64], szItemName[64], temp[2];
	menu_item_getinfo(menu, item, _, szWeaponID, charsmax(szWeaponID), szParseItemName, charsmax(szParseItemName));

	strtok2(szParseItemName, szItemName, charsmax(szItemName), temp, charsmax(temp), '\');
	trim(szItemName);

	new szSkinName[64], szItem[90], szParseData[5];
	new iMenu = menu_create(fmt("%s %s %l", MENU_PREFIX, szItemName, "WEAPON_STATTRAK_SKINS_TITLE"), "add_skin_tag_menu_handler");
	new iTotalSkins;

	for(new i; i < g_iSkinsNum; i++)
	{
		if(ArrayGetCell(g_aSkinWeaponID, i) != str_to_num(szWeaponID))
				continue;

		if(g_iUserSkins[id][i] > 0 && g_bIsWeaponStattrak[id][i])
		{
			ArrayGetString(g_aSkinName, i, szSkinName, charsmax(g_szSkinName))
			formatex(szItem, charsmax(szItem), "\rStatTrak |\w %s", szSkinName);
			formatex(szParseData, charsmax(szParseData), "%d", i);

			menu_additem(iMenu, szItem, szParseData);
			iTotalSkins++;
		}
	}

	if(iTotalSkins == 0)	menu_additem(iMenu, fmt("%l", "NO_STATTRAK_TO_SHOW"));

	if(is_user_connected(id))
	{
		menu_display(id, iMenu, 0, -1);
	}
	else 
	{
		menu_destroy(iMenu)
	}

	return PLUGIN_CONTINUE;
}

public add_skin_tag_menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		if(menu != 0)	menu_destroy(menu);
		arrayset(g_szCurrentSkinTag[id], 0, charsmax(g_szCurrentSkinTag));
		arrayset(g_szCurrentSkinThatGetTag[id], 0, charsmax(g_szCurrentSkinThatGetTag));
		show_stattrak_inventory(id);
		return PLUGIN_HANDLED;
	}

	new szSkinName[64], szParseData[5];

	if(g_szCurrentSkinThatGetTag[id][0] == EOS)
	{
		new szData[5], index;

		if(menu != 0)
		{
			menu_item_getinfo(menu, item, _, szData, charsmax(szData), _, _, _);
			index = str_to_num(szData);
		} else index = g_iTagCurrentWeaponID[id];

		if(index == -1)
			return PLUGIN_HANDLED

		if(g_iUserSellItem[id] == index)
		{
			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CURRENTLY_SELLING");
			open_skin_tag_menu(id);
			return PLUGIN_HANDLED;
		}

		g_iTagCurrentWeaponID[id] = index;
		ArrayGetString(g_aSkinName, index, szSkinName, charsmax(szSkinName));
	}

	if(g_szCurrentSkinThatGetTag[id][0] == EOS)
	{
		trim(szSkinName);
		copy(g_szCurrentSkinThatGetTag[id], charsmax(g_szCurrentSkinThatGetTag[]), szSkinName);
	}

	new szItem[64];
	new iMenu = menu_create(fmt("%s Add\y %s\w a Name-Tag", MENU_PREFIX, g_szCurrentSkinThatGetTag[id]), "add_tag_to_skin_handler");

	formatex(szItem, charsmax(szItem), "Name-Tag:\r %s", g_szCurrentSkinTag[id]);
	menu_additem(iMenu, szItem);

	formatex(szItem, charsmax(szItem), "Name-Tag Rarity: %s^n^n", g_iSelectedNameTagRarity[id] == 1 ? "Common" : g_iSelectedNameTagRarity[id] == 2 ? "\yRare" : g_iSelectedNameTagRarity[id] == 3 ? "\rMythic" : "\dNot selected");
	menu_additem(iMenu, szItem);

	menu_additem(iMenu, "Confirm", szParseData);

	if(is_user_connected(id))
	{
		menu_display(id, iMenu, 0, -1);
	}
	else 
	{
		menu_destroy(iMenu)
	}

	return PLUGIN_CONTINUE;
}

public add_tag_to_skin_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		g_iSelectedNameTagRarity[id] = 0
		open_skin_tag_menu(id);
		return PLUGIN_HANDLED;
	}

	switch(item)
	{
		case 0: client_cmd(id, "messagemode SkinTag");
		case 1:
		{
			switch(g_iSelectedNameTagRarity[id])
			{
				case 0: g_iSelectedNameTagRarity[id] = 1
				case 1: g_iSelectedNameTagRarity[id] = 2;
				case 2: g_iSelectedNameTagRarity[id] = 3;
				case 3: g_iSelectedNameTagRarity[id] = 0
			}

			add_skin_tag_menu_handler(id, 0, 0);
		}
		case 2:
		{
			if(!g_szCurrentSkinTag[id][0])
			{
				client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "MUST_TYPE_NAMETAG_NAME_MSG");
				add_skin_tag_menu_handler(id, 0, 0);
				return PLUGIN_HANDLED;
			}
			else if (containi(g_szCurrentSkinTag[id], "#") != -1 || containi(g_szCurrentSkinTag[id], ",") != -1 || containi(g_szCurrentSkinTag[id], "^"") != -1)
			{
				client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "INVALID_CHARACTERS");
				add_skin_tag_menu_handler(id, 0, 0);
				return PLUGIN_HANDLED;
			}

			new index = g_iTagCurrentWeaponID[id];

			if(index == -1)
				return PLUGIN_HANDLED;

			if(strlen(g_szCurrentSkinTag[id]) > MAX_SKIN_TAG_LENGTH - 1)
			{
				client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "INVALID_NAMETAG_LENGTH", MAX_SKIN_TAG_LENGTH - 1);
				add_skin_tag_menu_handler(id, 0, 0);
				return PLUGIN_HANDLED;
			}

			if(g_bSellCapsule[id] == true)
			{
				if(g_iMarketNameTagsRarity[id] == g_iSelectedNameTagRarity[id])
				{
					client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "CURRENTLY_SELLING");
					add_skin_tag_menu_handler(id, 0, 0);
					return PLUGIN_HANDLED;
				}		
			}

			switch(g_iSelectedNameTagRarity[id])
			{
				case 1:
				{
					if(g_iCommonNameTag[id] < 1)
					{
						client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NOT_ENOUGH", "Common Name-Tags");
						add_skin_tag_menu_handler(id, 0, 0);
						return PLUGIN_HANDLED;
					}

					g_iCommonNameTag[id]--;

					client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NAMETAG_SET", "Common", g_szCurrentSkinTag[id], g_szCurrentSkinThatGetTag[id]);
				}

				case 2:
				{
					if(g_iRareNameTag[id] < 1)
					{
						client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NOT_ENOUGH", "Rare Name-Tags");
						add_skin_tag_menu_handler(id, 0, 0);
						return PLUGIN_HANDLED;
					}

					g_iRareNameTag[id]--;

					client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NAMETAG_SET", "Rare", g_szCurrentSkinTag[id], g_szCurrentSkinThatGetTag[id]);
				}

				case 3:
				{
					if(g_iMythicNameTag[id] < 1)
					{
						client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NOT_ENOUGH", "Mythic Name-Tags");
						add_skin_tag_menu_handler(id, 0, 0);
						return PLUGIN_HANDLED;
					}

					g_iMythicNameTag[id]--;

					client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NAMETAG_SET", "Mythic", g_szCurrentSkinTag[id], g_szCurrentSkinThatGetTag[id]);
				}

				default:
				{
					client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "MUST_SELECT_RARITY")
				
					add_skin_tag_menu_handler(id, 0, 0);

					return PLUGIN_HANDLED;
				}
			}

			g_bHasSkinTag[id][index] = true;
			g_iNameTagSkinLevel[id][index] = g_iSelectedNameTagRarity[id];
			g_szSkinsTag[id][index] = g_szCurrentSkinTag[id];

			save_skin_tags(id);

			arrayset(g_szCurrentSkinTag[id], 0, charsmax(g_szCurrentSkinTag[]));
			arrayset(g_szCurrentSkinThatGetTag[id], 0, charsmax(g_szCurrentSkinThatGetTag[]));
			g_iSelectedNameTagRarity[id] = 0;
			g_iTagCurrentWeaponID[id] = -1;

		}
	}

	return PLUGIN_CONTINUE;
}

public save_skin_tags(id)
{
	static szData[TOTAL_SKINS * 3];
	static szData2[TOTAL_SKINS * 5];
	static szData3[TOTAL_SKINS * 3];
	
	formatex(szData, charsmax(szData), "%s", (g_bHasSkinTag[id][0] == true) ? "1" : "0");
	formatex(szData2, charsmax(szData2), "%s", g_szSkinsTag[id][0][0] != EOS ? g_szSkinsTag[id][0] : "0");
	formatex(szData3, charsmax(szData3), "%i", g_iNameTagSkinLevel[id][0]);


	for(new i = 1, szQuotedString[MAX_SKIN_TAG_LENGTH * 2 + 1]; i < g_iSkinsNum; i++)
	{
		format(szData, charsmax(szData), "%s,%s", szData, g_bHasSkinTag[id][i] == true ? "1" : "0");
		
		if(g_CvarSaveType == SQL)
		{
			if(g_bHasSkinTag[id][i])
			{
				copy(szQuotedString, charsmax(szQuotedString), g_szSkinsTag[id][i])
				mysql_escape_string(szQuotedString, charsmax(szQuotedString))
				format(szData2, charsmax(szData2), "%s,%s", szData2, szQuotedString);
			}
			else 
			{
				format(szData2, charsmax(szData2), "%s,0", szData2);
			}
		}
		else 
		{
			format(szData2, charsmax(szData2), "%s,%s", szData2, g_bHasSkinTag[id][i] ? g_szSkinsTag[id][i] : "0");
		}

		format(szData3, charsmax(szData3), "%s,%i", szData3, g_iNameTagSkinLevel[id][i]);
	}
	
	switch(g_CvarSaveType)
	{
		case SQL:
		{
			static szQuery[TOTAL_SKINS * 5]
			formatex(szQuery, charsmax(szQuery), "UPDATE `%s` SET \
			`has_skin_nametag` = '%s', \
			`skin_tag` = ^"%s^", \ 
			`tag_level` = '%s' WHERE `uname` = ^"%s^"",
			g_szTables[PLAYER_SKINS], szData, szData2, szData3, g_szSQLName[id])
			new iData[1]; iData[0] = __LINE__
			SQL_ThreadQuery(g_SqlTuple, "FreeHandle", szQuery, iData, sizeof(iData))
		}

		case NVAULT:
		{
			nvault_set(g_nVaultSkinTags, g_szName[id], szData);
			nvault_set(g_nVaultPlayerTags, g_szName[id], szData2);
			nvault_set(g_nVaultNameTagsLevel, g_szName[id], szData3);
		}
	}
}

public load_skin_tags(id)
{
	static szData[TOTAL_SKINS * 2 + 3];
	static szData2[TOTAL_SKINS * 6];
	static szData3[TOTAL_SKINS * 2 + 3];
	new left[5], left2[MAX_SKIN_TAG_LENGTH + 1], iTs, left3[4];

	arrayset(g_bHasSkinTag[id], false, charsmax(g_bHasSkinTag[]))

	new i;
	if(nvault_lookup(g_nVaultSkinTags, g_szName[id], szData, charsmax(szData), iTs))
	{
		while(i < g_iSkinsNum && szData[0] && strtok2(szData, left, charsmax(left), szData, charsmax(szData), ','))
		{
			g_bHasSkinTag[id][i] = !bool:equal(left, "0");

			i++
		}
	}

	for(new i; i < g_iSkinsNum; i++)
	{
		arrayset(g_szSkinsTag[id][i], 0, charsmax(g_szSkinsTag[][]))
	}

	i = 0
	if(nvault_lookup(g_nVaultPlayerTags, g_szName[id], szData2, charsmax(szData2), iTs))
	{
		while(i < g_iSkinsNum && szData2[0] && strtok2(szData2, left2, charsmax(left2), szData2, charsmax(szData2), ','))
		{
			if(!equal(left2, "0"))
			{
				g_szSkinsTag[id][i] = left2;
			}

			i++
		}
	}

	arrayset(g_iNameTagSkinLevel[id], 0, charsmax(g_iNameTagSkinLevel[]))

	i = 0
	if(nvault_lookup(g_nVaultNameTagsLevel, g_szName[id], szData3, charsmax(szData3), iTs))
	{
		while(i < g_iSkinsNum && szData3[0] && strtok2(szData3, left3, charsmax(left3), szData3, charsmax(szData3), ','))
		{
			g_iNameTagSkinLevel[id][i] = str_to_num(left3);
			i++;
		}
	}

	load_user_gloves(id);
}

public concmd_skintag(id)
{
	new szSkinTag[MAX_SKIN_TAG_LENGTH + 15];
	read_args(szSkinTag, charsmax(szSkinTag));
	remove_quotes(szSkinTag);
	
	copy(g_szCurrentSkinTag[id], charsmax(g_szCurrentSkinTag[]), szSkinTag);

	add_skin_tag_menu_handler(id, 0 , 0)
}

getUserStattrakSkins(id, iWeaponID)
{
	new iTotalSkins; 

	for(new i; i < g_iSkinsNum - 1; i++)
	{
		if(ArrayGetCell(g_aSkinWeaponID, i) != iWeaponID)
			continue;

		if(g_iUserSkins[id][i] != 0 && g_bIsWeaponStattrak[id][i])
			iTotalSkins++;
	}
	return iTotalSkins;
}

public open_preview_menu(id)
{
	new iMenu = menu_create(fmt("%s Preview Menu", MENU_PREFIX), "preview_menu_handler");
	
	new szItem[128], szData[5], iWeaponID

	for(new i; i < sizeof(g_WeapMenu); i++)
	{
		iWeaponID = g_WeapMenu[i][WeaponID];

		if(getMaxSkinsOfWeapon(iWeaponID) > 0)
		{									
			formatex(szItem, charsmax(szItem), "%s \r[%d]", g_WeapMenu[i][WeapName], getMaxSkinsOfWeapon(iWeaponID))
			num_to_str(g_WeapMenu[i][WeaponID], szData, charsmax(szData))
			menu_additem(iMenu, szItem, szData);
		}
	}
	
	if(is_user_connected(id))
	{
		menu_display(id, iMenu)
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public preview_menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		_ShowMainMenu(id);
		return PLUGIN_HANDLED;
	}

	new szWeaponID[4];
	menu_item_getinfo(menu, item, _, szWeaponID, charsmax(szWeaponID), _, _, _);
	new iWeaponID = str_to_num(szWeaponID);

	new iMenu = menu_create(fmt("%s Preview skin menu", MENU_PREFIX), "preview_skin_handler");
	new szData[6], szSkinName[64], szItem[100];

	for(new i; i < g_iSkinsNum; i++)
	{
		if(iWeaponID != ArrayGetCell(g_aSkinWeaponID, i))
			continue;

		ArrayGetString(g_aSkinName, i, szSkinName, charsmax(szSkinName));
		formatex(szData, charsmax(szData), "%d", i);

		if(ArrayGetCell(g_aSkinChance, i) == 101 && g_CvarShowSpecialSkins)
		{
			formatex(szItem, charsmax(szItem), "\r%s\d - \y[\dSPECIAL SKIN\y]", szSkinName)
		}
		else copy(szItem, charsmax(szItem), szSkinName);

		menu_additem(iMenu, szItem, szData);
	}

	if(is_user_connected(id))
	{
		menu_display(id, iMenu, 0, -1);
	}
	else 
	{
		menu_destroy(iMenu)
	}

	return PLUGIN_CONTINUE;
}

public preview_skin_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		_ShowMainMenu(id);
		return PLUGIN_HANDLED;
	}

	if(!is_user_alive(id))
	{
		client_print_color(id, print_team_default, "^4[CSGO Classy]^1 You must be alive");
		return PLUGIN_HANDLED;
	}

	new szIndex[6], szSkinName[48], index, iChance, iWeaponID = get_user_weapon(id);
	menu_item_getinfo(menu, item, _, szIndex, charsmax(szIndex), _, _, _);
	index = str_to_num(szIndex);

	SetUserSkin(id, index, iWeaponID)

	ArrayGetString(g_aSkinName, index, szSkinName, charsmax(szSkinName));
	client_print_color(id, print_team_default, "^4[CSGO Classy]^1 You are previewing^4 %s^1", szSkinName);

	iChance = 100 - ArrayGetCell(g_aSkinChance, index);

	if(!g_CvarShowSpecialSkins)
		iChance = random_num(1, 100);

	if(iChance < 0 && g_CvarShowSpecialSkins)
		client_print_color(id, print_team_default, "^4[CSGO Classy]^1 This skin cannot be obtained!");
	else
		client_print_color(id, print_team_default, "^4[CSGO Classy]^1 Price: ^4%d$^1. Chance: ^4%d^3/^4%s^1.", ArrayGetCell(g_aSkinCostMin, index), iChance, "100");
	
	g_bIsInPreview[id] = true;

	set_task(float(g_CvarPreviewTime), "restore_previous_skin", id + TASK_RESTORE_PREVIOUS_SKIN);

	open_preview_menu(id)

	return PLUGIN_CONTINUE;
}

public restore_previous_skin(id)
{
	if(id > MAX_PLAYERS)
	{
		id -= TASK_RESTORE_PREVIOUS_SKIN;
	}

	g_bIsInPreview[id] = false;

	new iWeaponID = get_user_weapon(id)

	SetUserSkin(id, g_iUserSelectedSkin[id][iWeaponID], iWeaponID)
}

open_gloves_menu(id)
{
	new iMenu = menu_create(fmt("%s %l", MENU_PREFIX, "MENU_GLOVES_TITLE"), "open_gloves_menu_handler"), szItem[64];

	formatex(szItem, charsmax(szItem), "Open Glove Case\r [\y%d\r] [\y%d key%s\r]", g_iGlovesCases[id], g_iUserKeys[id], g_iUserKeys[id] > 0 ? "s" : "");
	menu_additem(iMenu, szItem);

	menu_additem(iMenu, "Gloves");
	menu_additem(iMenu, "Set Weapon Gloves");

	menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
	
	if(is_user_connected(id))
	{
		menu_display(id, iMenu, 0, -1);
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public open_gloves_menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		if(menu != 0)
			menu_destroy(menu);
		ShowInventoryMenu(id);
		return PLUGIN_HANDLED;
	}

	new szMessage[192], szItem[64];

	switch(item)
	{
		case 0:
		{	
			if(g_iGlovesCases[id] == 0 || g_iUserKeys[id] == 0)
			{
				open_gloves_menu(id);
				return PLUGIN_HANDLED;
			}
			new iRandom= random_num(0, 100);

			if(iRandom <= g_CvarGloveDropChance)
			{
				new iRandomGlove = getRandomGlove(bool:is_user_gold_vip(id));
				
				g_iUserGloves[id][iRandomGlove]++;
				AddStatistics(id, DROPPED_GLOVES, 1, .gloveid = iRandomGlove, .line = __LINE__)

				save_user_gloves(id);

				new eGlove[GLOVESINFO];
				ArrayGetArray(g_aGloves, iRandomGlove, eGlove);

				formatex(szMessage, charsmax(szMessage), "^4[CSGO Classy] %s^1 dropped^3 %s", g_szName[id], eGlove[szGloveName]);
				send_message(id, szMessage);
			}
			else client_print_color(id, print_team_default, "^4[CSGO Classy]^1 You didn't get a^3 glove");

			g_iUserKeys[id]--;
			g_iGlovesCases[id]--;

			open_gloves_menu(id);
		}

		case 1:
		{
			new iMenu = menu_create(fmt("%s Your Gloves", MENU_PREFIX), "your_gloves_handler");
			new iGlovesCount, eGlove[GLOVESINFO];

			for(new i; i < MAX_GLOVES; i++)
			{
				if(g_iUserGloves[id][i] > 0)
				{
					ArrayGetArray(g_aGloves, i, eGlove);
					formatex(szItem, charsmax(szItem), "%s\r [%d] [\y%d$\r]%s", eGlove[szGloveName], g_iUserGloves[id][i], eGlove[iMinPrice], eGlove[iVIPOnly] != 0 ? " \r[\dVIP ONLY\r]" : "");
					menu_additem(iMenu, szItem);
					iGlovesCount++;
				}
			}

			if(iGlovesCount == 0)
			{
				menu_additem(iMenu, "\dYou don't have any gloves");
			}

			menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)

			if(is_user_connected(id))
			{
				menu_display(id, iMenu, 0, -1);
			}
			else 
			{
				menu_destroy(iMenu)
			}
		}

		case 2:
		{
			new iMenu = menu_create(fmt("%s Add gloves to a weapon^n^n%l", MENU_PREFIX, "MENU_ADD_GLOVES_TEXT"), "show_gloves_weapon_menu");
			new szData[5], eGlove[GLOVESINFO], szActiveGloveName[64], iWeaponID, iCount, szItem[64];

			for(new i; i < sizeof(g_WeapMenu); i++)
			{
				iWeaponID = g_WeapMenu[i][WeaponID];

				if(getMaxSkinsOfWeapon(iWeaponID) > 0 && ArrayFindValue(g_aWeapIDs, iWeaponID) != -1)
				{									
					ArrayGetArray(g_aGloves, g_iWeaponGloves[id][iWeaponID] == -1 ? 0 : g_iWeaponGloves[id][iWeaponID], eGlove);
					formatex(szActiveGloveName, charsmax(szActiveGloveName), " \r[%s%s\r]", g_iWeaponGloves[id][iWeaponID] == -1 ? "\d" : "\y", eGlove[szGloveName]);

					formatex(szItem, charsmax(szItem), "%s%s", g_WeapMenu[i][WeapName], szActiveGloveName);
					num_to_str(g_WeapMenu[i][WeaponID], szData, charsmax(szData))
					menu_additem(iMenu, szItem, szData);
					iCount++;
				}
			}

			if(iCount == 0)
			{
				menu_additem(iMenu, fmt("%l", "NO_ITEMS"), "595995")
			}	

			menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)
			menu_setprop(iMenu, MPROP_SHOWPAGE, false)
			
			if(is_user_connected(id))
			{
				menu_display(id, iMenu, 0, -1);
			}
			else 
			{
				menu_destroy(iMenu)
			}
		}
	}

	return PLUGIN_CONTINUE;
}

getRandomGlove(bool:bVIP)
{
	new bool:bFound = false, iRandomGloveID, eGlove[GLOVESINFO];
	new iGloveID;
	new iRandomChance = random_num(99, 100);
	new bool:bCanDrop = bool:g_CvarCanUserDropVIPGloves;

	while(!bFound)
	{ 
		iRandomGloveID = random_num(0, MAX_GLOVES-1);

		ArrayGetArray(g_aGloves, iRandomGloveID, eGlove);

		if(iRandomChance <= eGlove[iDropChance])
		{
			if(eGlove[iVIPOnly] == 1 && bVIP)
			{
				iGloveID = iRandomGloveID;
				bFound = true;
			}
			else if(eGlove[iVIPOnly] == 1 && !bVIP && bCanDrop)
			{
				iGloveID = iRandomGloveID;
				bFound = true;
			}
			else if(eGlove[iVIPOnly] == 1 && !bVIP && !bCanDrop)
			{
				bFound = false;
			}
			else
			{
				iGloveID = iRandomGloveID;
				bFound = true;
			}
		} else iRandomChance = random_num(0, 100);
	}

	return iGloveID;
}

public show_gloves_weapon_menu(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		if(menu != 0)
			menu_destroy(menu);
		open_gloves_menu(id);
		return PLUGIN_HANDLED;
	}

	new szData[5], szWeapName[32], szTemp[1], szItem[64], szParseData[128], iGlovesCount, eGlove[GLOVESINFO];

	menu_item_getinfo(menu, item, _, szData, charsmax(szData), szWeapName, charsmax(szWeapName), _);
	strtok2(szWeapName, szWeapName, charsmax(szWeapName), szTemp, charsmax(szTemp), '\', TRIM_FULL);

	if(equal(szData, "595995"))
	{
		open_gloves_menu_handler(id, 0, 2);
		return PLUGIN_HANDLED;
	}

	new iMenu = menu_create(fmt("%s Set gloves for\y %s\w skins", MENU_PREFIX, szWeapName), "add_gloves_to_weapon_handler");

	for(new i; i < MAX_GLOVES; i++)
	{
		if(g_iUserGloves[id][i] > 0)
		{
			ArrayGetArray(g_aGloves, i, eGlove)
			formatex(szItem, charsmax(szItem), "%s\r [%d]", eGlove[szGloveName], g_iUserGloves[id][i]);
			formatex(szParseData, charsmax(szParseData), "^"%s^" ^"%d^" ^"%s^"", szData, i, szWeapName);
			menu_additem(iMenu, szItem, szParseData);
			iGlovesCount++;
		}
	}

	if(iGlovesCount == 0)
	{
		menu_additem(iMenu, "\dYou don't have any gloves");
	}

	menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)

	if(is_user_connected(id))
	{
		menu_display(id, iMenu, 0, -1);
	}
	else 
	{
		menu_destroy(iMenu)
	}

	return PLUGIN_CONTINUE;
}

public add_gloves_to_weapon_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		open_gloves_menu_handler(id, 0, 2);
		return PLUGIN_HANDLED;
	}

	new szData[64];
	menu_item_getinfo(menu, item, _, szData, charsmax(szData), _, _, _);

	if(item == 0 && !szData[0])
	{
		open_gloves_menu_handler(id, 0, 2);
		return PLUGIN_HANDLED;
	}

	new szWeaponID[5], szGlovesID[5], szWeapName[64]
	parse(szData, szWeaponID, charsmax(szWeaponID), szGlovesID, charsmax(szGlovesID), szWeapName, charsmax(szWeapName));
	new iWeaponID = str_to_num(szWeaponID);
	new iGloveID = str_to_num(szGlovesID);

	new eGlove[GLOVESINFO];
	ArrayGetArray(g_aGloves, iGloveID, eGlove)

	trim(szWeapName);

	if(g_bSellGlove[id] == true && (g_iMarketGloveID[id] == iGloveID) && g_iUserGloves[id][iGloveID] < 2)
	{
		client_print_color(id, print_team_default, "^4[CSGO Classy]^1 Can't^4 perform^1 this action because you are selling^3 %s^4 glove", eGlove[szGloveName]);
		open_gloves_menu_handler(id, 0, 2);
		return PLUGIN_HANDLED
	}

	if(!g_CvarCanUserUseVIPGloves && eGlove[iVIPOnly] && !is_user_gold_vip(id))
	{
		client_print_color(id, print_team_default, "^4[CSGO Classy]^1 You must be^3 Gold VIP^1 to set^3 %s^4 glove^1 on^4 %s^1 skins", eGlove[szGloveName], szWeapName);
		open_gloves_menu_handler(id, 0, 2);
		return PLUGIN_HANDLED;
	}

	if(g_iWeaponGloves[id][iWeaponID] == iGloveID)
	{
		client_print_color(id, print_team_default, "^4[CSGO Classy]^1 You already use this type of^3 glove");
		open_gloves_menu_handler(id, 0, 2);
		return PLUGIN_HANDLED;
	}

	new bool:bRetrieveGlove = bool:g_CvarRetrieveGlove
	new iUsedGloveID = -1, eLastGlove[GLOVESINFO], szLastGloveName[64];

	if(g_iWeaponGloves[id][iWeaponID] != -1 && bRetrieveGlove)
	{
		g_iUserGloves[id][g_iWeaponGloves[id][iWeaponID]]++;
		ArrayGetArray(g_aGloves, g_iWeaponGloves[id][iWeaponID], eLastGlove);
		copy(szLastGloveName, charsmax(szLastGloveName), eLastGlove[szGloveName]);
	}

	g_iUserGloves[id][iGloveID]--;
	g_iWeaponGloves[id][iWeaponID] = iGloveID;

	if(iWeaponID == get_user_weapon(id) && g_iUserSelectedSkin[id][iWeaponID] != -1)
	{
		SetUserSkin(id, g_iUserSelectedSkin[id][iWeaponID], iWeaponID)
	}

	menu_destroy(menu);
	
	open_gloves_menu(id);

	save_user_gloves(id);

	client_print_color(id, print_team_default, "^4[CSGO Classy]^1 You set^3 %s^1 for^4 %s^1 skins%s %s",
	eGlove[szGloveName], szWeapName, iUsedGloveID == -1 ? "" : " and got back your^3", iUsedGloveID == -1 ? "" : szLastGloveName);

	return PLUGIN_CONTINUE;
}

public your_gloves_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		open_gloves_menu(id);
		return PLUGIN_HANDLED;
	}

	open_gloves_menu_handler(id, 0, 1);

	return PLUGIN_CONTINUE;
}

stock CalculateModelBodyIndex(gloves_id, const model_name[], skin_id, &body)
{
	new amount_of_models;

	if(gloves_id == -1)
	{
		gloves_id = 0;
	}

	new iModelIndex = ArrayFindString(g_aGlovesModelName, model_name);

	if(iModelIndex != -1)
	{
		amount_of_models = ArrayGetCell(g_aGlovesModelAmount, iModelIndex);
	}
	else
	{
		body = skin_id 
		return	
	}

	if(amount_of_models == -1)
	{
		amount_of_models = 0;
	}

	if(skin_id == -1)
	{
		skin_id = 0;
	}

	body = gloves_id * amount_of_models + skin_id
}

public save_user_gloves(id)
{
	if(!g_bActiveGloveSystem)
	{
		return 
	}

	new szGlovesData[MAX_GLOVES * 3 + 10];
	new szWeaponGlovesData[31 * 3 + 10];

	formatex(szGlovesData, charsmax(szGlovesData), "%d", g_iUserGloves[id][0]);
	formatex(szWeaponGlovesData, charsmax(szWeaponGlovesData), "%d", g_iWeaponGloves[id][0]);

	for(new i = 1; i < MAX_GLOVES; i++)
	{
		format(szGlovesData, charsmax(szGlovesData), "%s,%d", szGlovesData, g_iUserGloves[id][i]);
	}

	for(new i = 1; i < 31; i++)
	{
		format(szWeaponGlovesData, charsmax(szWeaponGlovesData), "%s,%d", szWeaponGlovesData, g_iWeaponGloves[id][i]);
	}

	switch(g_CvarSaveType)
	{
		case SQL:
		{
			new szQuery[1024]
			formatex(szQuery, charsmax(szQuery), "UPDATE `%s` SET \
			`gloves` = '%s', \
			`weapon_gloves` = '%s' WHERE `uname` = '%s';",
			g_szTables[PLAYER_SKINS], szGlovesData, szWeaponGlovesData, g_szSQLName[id])
			new iData[1]; iData[0] = __LINE__
			SQL_ThreadQuery(g_SqlTuple, "FreeHandle", szQuery, iData, sizeof(iData))
		}

		case NVAULT:
		{
			nvault_set(g_nVaultGloves, g_szName[id], szGlovesData);
			nvault_set(g_nVaultWeaponGloves, g_szName[id], szWeaponGlovesData);
		}
	}	
}

public load_user_gloves(id)
{
	if(!g_bActiveGloveSystem)
	{
		return 
	}

	new szGlovesData[MAX_GLOVES * 3 + 10];
	new szWeaponGlovesData[31 * 3 + 10];
	new iTs, szData[2][5];

	if(nvault_lookup(g_nVaultGloves, g_szName[id], szGlovesData, charsmax(szGlovesData), iTs))
	{
		new i;
		while(strtok2(szGlovesData, szData[0], charsmax(szData[]), szGlovesData, charsmax(szGlovesData), ',') && i < MAX_GLOVES)
		{
			g_iUserGloves[id][i] = str_to_num(szData[0]);
			i++
		}
	}

	if(nvault_lookup(g_nVaultWeaponGloves, g_szName[id], szWeaponGlovesData, charsmax(szWeaponGlovesData), iTs))
	{
		new j;
		while(strtok2(szWeaponGlovesData, szData[1], charsmax(szData[]), szWeaponGlovesData, charsmax(szWeaponGlovesData), ',') && j < 31 && szWeaponGlovesData[0])
		{
			g_iWeaponGloves[id][j] = str_to_num(szData[1]);
			j++;
		}
	}
}

public simulate_glove_drop(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED;

	new cases = read_argv_int(1);
	new gloves, glove_fails, glove_cases, cases_fails;
	new iRandom, eGlove[GLOVESINFO];
	new igloves[MAX_GLOVES];

	for(new i; i < cases; i++)
	{
		iRandom = random_num(0, 100);
		if(iRandom <= g_CvarGloveDropChance)
		{
			new iRandomGlove = getRandomGlove(bool:is_user_gold_vip(id));
				
			gloves++;
			igloves[iRandomGlove]++
		}
		else glove_fails++

		if(iRandom <= g_CvarGloveCaseDropChance)
		{
			glove_cases++
		}
		else cases_fails++
	}
	
	client_print(id, print_console, "^n^n%s Gloves drop from %d glove cases^n", CONSOLE_PREFIX, cases);

	for(new i; i < MAX_GLOVES; i++)
	{
		ArrayGetArray(g_aGloves, i, eGlove);
		client_print(id, print_console, "%s drops: %d; chance: %d", eGlove[szGloveName], igloves[i], eGlove[iDropChance]);
	}

	client_print(id, print_console, "^nFrom %d Kills you would have dropped %d Glove Cases (%d fails) (Server Chance: %d)", cases, glove_cases, cases_fails, g_CvarGloveCaseDropChance);
	client_print(id, print_console, "From %d Glove Cases you would have dropped %d gloves (%d fails) (Server Chance: %d)^n", cases, gloves, glove_fails, g_CvarGloveDropChance);
	
	return PLUGIN_HANDLED;
}

_ShowUpgradeMenu(id)
{
	show_upgrade_info(id)
	return PLUGIN_HANDLED
}

_ShowSkinsU(id)
{
	_ShowSkinMenu(id)
}

public show_upgrade_info(id)
{
	new menu = menu_create(fmt("%s Upgrade", MENU_PREFIX), "show_upgrade_handler" );
	menu_additem(menu, "Upgrade informations" );
	menu_additem(menu, "\rUpgrade your skins");
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	if(is_user_connected(id))
	{
		menu_display(id, menu)
	}
	else 
	{
		menu_destroy(menu)
	}
}

public show_upgrade_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}

	switch(item)
	{
		case 0:
		{
			show_upgradeinformation(id)
		}

		case 1:
		{
			_ShowSkinsU(id)
		}
	}
	return PLUGIN_HANDLED;
}

public show_upgradeinformation(id)
{
	new menu = menu_create(fmt("%s Upgrade", MENU_PREFIX), "show_upgradeinformation_handler" );
	menu_additem(menu, "You need 5 non-StatTrak pieces of the same skin");
	menu_additem(menu, "After you press on those 5 non-StatTrak skins the Upgrade will happen");
	menu_additem(menu, "5 non-StatTrak equal 1 StatTrak of the same skin");
	menu_additem(menu, "The results can not be reversed");

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	if(is_user_connected(id))
	{
		menu_display(id, menu)
	}
	else 
	{
		menu_destroy(menu)
	}
}

public show_upgradeinformation_handler(id, menu, item)
{
	if (item == -3)
	{
		show_upgrade_info(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}

	switch(item)
	{
		case 0:
		{
			show_upgradeinformation(id)
		}

		case 1:
		{
			show_upgradeinformation(id)
		}

		case 2:
		{
			show_upgradeinformation(id)
		}

		case 3:
		{
			show_upgradeinformation(id)
		}
	}
	return PLUGIN_HANDLED
}

openUpgradeMenu(id, iWeaponId)
{	
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "MENU_SKINS");
	new menu = menu_create(temp, "upgrade_handler", 0);
	new szItem[10];
	szItem[1] = 0;
	new szSkin[32];
	new num;
	new total;
	new i, wid;
	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i];
		if (0 < num)
		{
			wid = ArrayGetCell(g_aSkinWeaponID, i);
			if(wid != iWeaponId)
			{
				i++
				continue
			}
			
			ArrayGetString(g_aSkinName, i, szSkin, 31);
			formatex(temp, 63, "\r%s\w%s \r[%d]%s", g_bIsWeaponStattrak[id][i] ? "StatTrak " : "", szSkin, num, (g_iWeaponUsedInUpgrade[id] == i) ? " [Upgrade]" : "");
			num_to_str(i, szItem, charsmax(szItem));
			menu_additem(menu, temp, szItem);
			total++;
		}
		i++;
	}
	if (!total)
	{
		formatex(temp, 63, "\r%L", id, "NO_ITEMS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp, szItem);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public upgrade_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowSkinsU(id)
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[5];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, charsmax(itemdata), {0}, 0, dummy);
	index = str_to_num(itemdata);
	if (index == NO_SKIN_VALUE)
	{
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	if(index == g_iUserSellItem[id])
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CURRENTLY_SELLING");
		_ShowUpgradeMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	else if(g_iUserSkins[id][index] < MIN_SKINS_TO_UPGRADE)
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "UPGRADE_NEED_5", MIN_SKINS_TO_UPGRADE);
		_ShowUpgradeMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	else if(g_bIsWeaponStattrak[id][index])
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "UPGRADE_ALREADY_STT");
		_ShowUpgradeMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	else if((g_iWeaponUsedInUpgrade[id] != -1) && (g_iWeaponUsedInUpgrade[id] != index))
	{
		_ShowUpgradeMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	else if(g_iWeaponUsedInUpgrade[id] == index)
	{
		g_iWeaponUsedInUpgrade[id] = -1
		_ShowUpgradeMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	g_iWeaponUsedInUpgrade[id] = index
	askToContinueU(id)
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

askToContinueU(id)
{
	new menu = menu_create(fmt("%s \wDo you confirm your Upgrade?", MENU_PREFIX), "confirmationu_handler");	
	menu_additem(menu, "\rNo")
	menu_additem(menu, "\yYes")

	if(is_user_connected(id))
	{
		menu_display(id, menu)
	}
	else 
	{
		menu_destroy(menu)
	}
}

public confirmationu_handler(id, menu, item)
{
	if (item == -3)
	{
		g_iWeaponUsedInUpgrade[id] = -1
		_ShowSkinsU(id)
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	if(item)
	{
		new szSName[32], iIndex = g_iWeaponUsedInUpgrade[id]
		ArrayGetString(g_aSkinName, iIndex, szSName, charsmax(szSName));
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "UPGRADE_INFO", szSName, szSName);
		
		g_iUserSkins[id][iIndex] -= MIN_SKINS_TO_UPGRADE
		g_iUserSkins[id][iIndex] += 1
		g_bIsWeaponStattrak[id][iIndex] = true
		AddStatistics(id, DROPPED_STT_SKINS, 1, iIndex, .line = __LINE__)
		AddStatistics(id, TOTAL_UPGRADES, 1, .line = __LINE__)
	}

	g_iWeaponUsedInUpgrade[id] = -1
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_QuestsMenu(id)
{
	new menu = menu_create(fmt("%s \wQuests\r", MENU_PREFIX), "QuestsMenu_handler");

	menu_additem(menu, "You've Made Your Points \r[250 scraps and 500$] ^n\dDeal 50000 damage points");

	menu_additem(menu, "Reloader \r[150 scraps and 250$]^n\dReload your weapons 1000 times");

	menu_additem(menu, "Play Around \r[25 scraps and 50$]^n\dSpend 1 hour playing on the server");

	menu_additem(menu, "I'll Be Back  \r[50 scraps and 100$]^n\dConnect 100 times to the server");

	menu_additem(menu, "I Like This Server \r[75 scraps and 125$]^n\dConnect 250 times to the server");

	menu_additem(menu, "Half Way There \r[100 scraps and 150$]^n\dConnect 500 times to the server");

	menu_additem(menu, "Ultimate Server Lover \r[125 scraps and 175$]^n\dConnect 1000 times to the server");

	menu_additem(menu, "Baby Foot Steps \r[25 scraps and 50$]^n\dWalk for the first time on the server");

	menu_additem(menu, "I'm Half Way There \r[35 scraps and 70$]^n\dWalk 5 kilometers on the server");

	menu_additem(menu, "Long Run \r[35 scraps and 100$]^n\dWalk 10 kilometers on the server");

	menu_additem(menu, "OMFG! That Was Close \r[125 scraps and 150$]^n\dDefuse the bomb with 0.5 seconds left");

	menu_additem(menu, "C4 Defuser \r[25 scraps and 50$]^n\dDefuse the bomb 50 times");

	menu_additem(menu, "That Was Easy \r[35 scraps and 65$]^n\dDefuse the bomb 100 times");

	menu_additem(menu, "Like A Game \r[50 scraps and 70$]^n\dDefuse the bomb 150 times");

	menu_additem(menu, "Master Of C4 \r[65 scraps and 85$]^n\dDefuse the bomb 200 times");

	menu_additem(menu, "Short Fuse \r[100 scraps and 125$]^n\dPlant the bomb in the first 25 second of the round start");

	menu_additem(menu, "Nothing Can Blow Up \r[85 scraps and 115$]^n\dDefuse the bomb 400 times");

	menu_additem(menu, "Boomala, Boomala! \r[45 scraps and 75$]^n\dPlant the bomb 100 times");

	menu_additem(menu, "C4 Killer \r[50 scraps and 75$]^n\dKill 30 enemies with the C4");

	menu_additem(menu, "Grenade Expert \r[100 scraps and 125$]^n\dKill 300 enemies with HE Grenade");

	menu_additem(menu, "Hat Trick \r[35 scraps and 40$]^n\dKill 3 enemies with one HE Grenade");

	menu_additem(menu, "Can You See? \r[15 scraps and 25$]^n\dKill 150 enemies while you are flashed");

	menu_additem(menu, "Ammo Conservation \r[35 scraps and 40$]^n\dKill two enemies with one bullet");

	menu_additem(menu, "BOOM! Headshot \r[65 scraps and 100$]^n\dKill 300 enemies with headshots");

	menu_additem(menu, "P250 Expert \r[65 scraps and 80$]^n\dKill 200 enemies using the P250");

	menu_additem(menu, "SSG Expert \r[65 scraps and 80$]^n\dKill 1000 enemies using the SSG");

	menu_additem(menu, "XM1014 Expert \r[65 scraps and 80$]^n\dKill 200 enemies using the XM1014");

	menu_additem(menu, "MAC-10 Expert \r[65 scraps and 80$]^n\dKill 500 enemies using the MAC-10");

	menu_additem(menu, "AUG Expert \r[65 scraps and 80$]^n\dKill 500 enemies using the AUG");

	menu_additem(menu, "Dual Berettas Expert \r[65 scraps and 80$]^n\dKill 100 enemies using the Dual Berettas");

	menu_additem(menu, "FiveSeven Expert \r[65 scraps and 80$]^n\dKill 100 enemies using the FiveSeven");

	menu_additem(menu, "UMP45 Expert \r[65 scraps and 80$]^n\dKill 1000 enemies using the UMP-45");

	menu_additem(menu, "SG-550 Expert \r[65 scraps and 80$]^n\dKill 500 enemies using the SG-550");

	menu_additem(menu, "Galil-AR Expert \r[65 scraps and 80$]^n\dKill 500 enemies using the Galil-AR");

	menu_additem(menu, "Famas Expert \r[65 scraps and 80$]^n\dKill 500 enemies using the Famas");

	menu_additem(menu, "USP-S Expert \r[65 scraps and 80$]^n\dKill 200 enemies using the USP-S");

	menu_additem(menu, "Glock Expert \r[65 scraps and 80$]^n\dKill 200 enemies using the Glock");

	menu_additem(menu, "AWP Expert \r[65 scraps and 80$]^n\dKill 1000 enemies using the AWP");

	menu_additem(menu, "MP7 Expert \r[65 scraps and 80$]^n\dKill 1000 enemies using the MP7");

	menu_additem(menu, "M249 Expert \r[65 scraps and 80$]^n\dKill 500 enemies using the M249");

	menu_additem(menu, "Nova Expert \r[65 scraps and 80$]^n\dKill 200 enemies using the Nova");

	menu_additem(menu, "M4A1-S/M4A4 Expert \r[65 scraps and 80$]^n\dKill 1000 enemies using the M4A1-S/M4A4");

	menu_additem(menu, "MP9 Expert \r[65 scraps and 80$]^n\dKill 1000 enemies using the MP9");

	menu_additem(menu, "SG-553 Expert \r[65 scraps and 80$]^n\dKill 500 enemies using the SG-553");

	menu_additem(menu, "Deagle Expert \r[65 scraps and 80$]^n\dKill 200 enemies using the Deagle");

	menu_additem(menu, "SG-552 Expert \r[65 scraps and 80$]^n\dKill 500 enemies using the SG-552");

	menu_additem(menu, "AK-47 Expert \r[65 scraps and 80$]^n\dKill 1000 enemies using the AK-47");

	menu_additem(menu, "Knife Expert \r[65 scraps and 80$]^n\dKill 200 enemies using the Knife");

	menu_additem(menu, "P90 Expert \r[65 scraps and 80$]^n\dKill 1000 enemies using the P90");

	menu_additem(menu, "Short Range Kill \r[65 scraps and 80$]^n\dKill an enemy from 1 to 5 meters");

	menu_additem(menu, "Nice Aim \r[65 scraps and 80$]^n\dKill an enemy from 6 to 50 meters");

	menu_additem(menu, "Long Range Kill \r[65 scraps and 80$]^n\dKill an enemy from 51 to 99 meters");

	menu_additem(menu, "Aim-Bot Time \r[65 scraps and 80$]^n\dKill an enemy from 100 to 150 meters");

	menu_additem(menu, "I Got The Power \r[65 scraps and 80$]^n\dKill an enemy from 151 to 300 meters");

	menu_additem(menu, "Killer Master \r[150 scraps and 250$]^n\dKill a total of 5000 enemies");

	menu_additem(menu, "God Of War \r[250 scraps and 450$]^n\dKill a total of 10000 enemies");

	menu_additem(menu, "Pistol Master \r[65 scraps and 80$]^n\dComplete all pistols firearms quests");

	menu_additem(menu, "Rifle Master \r[65 scraps and 80$]^n\dComplete all rifles firearms quests");

	menu_additem(menu, "Shotgun Master \r[65 scraps and 80$]^n\dComplete all shotguns firearms quests");

	menu_additem(menu, "Master At Arms \r[65 scraps and 80$]^n\dComplete all weapons quests and masteries");

	menu_additem(menu, "Fly Away \r[65 scraps and 80$]^n\dKill one enemy while he is in air");

	menu_additem(menu, "Spray And Pray \r[65 scraps and 80$]^n\dKill one enemy while you are fully-flashed");

	menu_additem(menu, "Stand Alone \r[65 scraps and 80$]^n\dDie 15 times as the last member in your team");

	menu_additem(menu, "One HP Hero \r[65 scraps and 80$]^n\dWhile you have 1 HP kill at least 3 enemies and win the round");

	menu_additem(menu, "Camp Fire \r[65 scraps and 80$]^n\dKill 3 enemies in the same area");
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_PERPAGE, 4);

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public QuestsMenu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		_ShowMainMenu(id);
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	switch(item)
	{
		default: _QuestsMenu(id);
	}
	
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

DailyReward(id)
{
	if(g_iUserRank[id] < g_CvarDailyMinRank)
	{
		new szRankName[64]

		ArrayGetString(g_aRankName, g_CvarDailyMinRank, szRankName, charsmax(szRankName))

		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "CHAT_MINIMUM_RANK", szRankName)
		_ShowMainMenu(id)
		return
	}

	if(g_iUserDailyTime[id] <= get_systime())
	{
		new menu = menu_create(fmt("%s %l", MENU_PREFIX, "DAILY_REWARD_MENU_TITLE"), "reward_handler" );
		menu_additem(menu, fmt("%l", "DAILY_MONEY"));
		menu_additem(menu, fmt("%l", "DAILY_KEYS"));
		menu_additem(menu, fmt("%l", "DAILY_CASES"));
		menu_additem(menu, fmt("%l", "DAILY_SCRAPS"));
		menu_additem(menu, fmt("%l", "DAILY_CAPSULE"));
		
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

		if(is_user_connected(id))
		{
			menu_display(id, menu)
		}
		else 
		{
			menu_destroy(menu)
		}
	}
	else 
	{
		new iMinutes = (( g_iUserDailyTime[id] - get_systime() ) / 60) % 60
		new iHours = (( g_iUserDailyTime[id] - get_systime() ) / 60) / 60

		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "DAILY_ALREADY_GOT", iHours < 10 ? "0" : "", iHours,  iHours > 1 ? "s" : "", iMinutes < 10 ? "0" : "", iMinutes, iMinutes > 1 ? "s" : "")
		_ShowMainMenu(id);
	}

	return
}


public reward_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}

	new rand
	switch(item)
	{
		case 0:
		{
			rand = random_num(1, 100);
			g_iUserMoney[id] += rand
			AddStatistics(id, RECEIVED_MONEY, rand, .line = __LINE__)
			client_print_color(id, id, "%s %l", CHAT_PREFIX, "DAILY_GOT_MONEY", rand);
		}
		case 1:
		{
			rand = random_num(1, 5);
			g_iUserKeys[id] += rand
			AddStatistics(id, DROPPED_KEYS, rand, .line = __LINE__)
			client_print_color(id, id, "%s %l", CHAT_PREFIX, "DAILY_GOT_KEYS", rand, rand == 1 ? "" : "s" );
		}
		case 2:
		{
			rand = random_num(1, 6);
			g_iUserCases[id] += rand
			AddStatistics(id, DROPPED_CASES, rand, .line = __LINE__)
			client_print_color(id, id, "%s %l", CHAT_PREFIX, "DAILY_GOT_CASES", rand, rand == 1 ? "" : "s" );
		}
		case 3:
		{
			rand = random_num(1, 75);
			g_iUserScraps[id] += rand
			AddStatistics(id, RECEIVED_SCRAPS, rand, .line = __LINE__)
			client_print_color(id, id, "%s %l", CHAT_PREFIX, "DAILY_GOT_SCRAPS", rand, rand == 1 ? "" : "s" );
		}
		case 4:
		{
			g_iNameTagCapsule[id]++
			AddStatistics(id, DROPPED_NAMETAG_CAPSULES, 1, .line = __LINE__)
			client_print_color(id, id, "%s %l", CHAT_PREFIX, "DAILY_GOT_CAPSULE");
		}
	}

	g_iUserDailyTime[id] = get_systime(86400)
	menu_destroy(menu)
	_ShowMainMenu(id)
	return PLUGIN_HANDLED;
}
	
_ShowContractMenu(id)
{
	_ShowContractInfo(id)
	return PLUGIN_HANDLED;
}

_ShowContractMenu_continue(id)
{
	_ShowSkinsC(id);
	return PLUGIN_HANDLED;
}

_ShowSkinsC(id)
{
	_ShowSkinMenu(id)
}

_ShowContractInfo(id)
{
	new menu = menu_create(fmt("%s Contract", MENU_PREFIX), "ShowContractInfo_handler" );
	menu_additem(menu, "Contract informations" );
	menu_additem(menu, "\rSign a Contract");
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	if(is_user_connected(id))
	{
		menu_display(id, menu)
	}
	else 
	{
		menu_destroy(menu)
	}
}

public ShowContractInfo_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}

	switch(item)
	{
		case 0:
		{
			_Showcontracti(id)
		}

		case 1:
		{
			_ShowSkinsC(id)
		}
	}
	return PLUGIN_HANDLED;
}

_Showcontracti(id)
{
	new menu = menu_create(fmt("%s Contract", MENU_PREFIX), "showcontracti_handler" );
	menu_additem(menu, "You need 10 skins to sign a Contract");
	menu_additem(menu, "Once you select 10 skins you will be asked to continue or not");
	menu_additem(menu, "You can get better or worse skins depending on the chance");
	menu_additem(menu, "Selected skins will have '\r[Contract]\w' status on them");
	menu_additem(menu, "The results can not be reversed");

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	if(is_user_connected(id))
	{
		menu_display(id, menu)
	}
	else 
	{
		menu_destroy(menu)
	}
}

public showcontracti_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowContractInfo(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}

	switch(item)
	{
		default: _Showcontracti(id);
	}

	return PLUGIN_HANDLED;
}

openContractMenu(id, iWeaponId)
{	
	new temp[128];
	formatex(temp, charsmax(temp), "\r%s \w%L", MENU_PREFIX, id, "MENU_SKINS");
	new menu = menu_create(temp, "contract_handler", 0);
	new szItem[10];
	szItem[1] = 0;
	new szSkin[32];
	new num;
	new total;
	new i, wid;
	new iChance 

	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i];
		if (0 < num)
		{
			wid = ArrayGetCell(g_aSkinWeaponID, i);
			if(wid != iWeaponId)
			{
				i++
				continue
			}
			
			ArrayGetString(g_aSkinName, i, szSkin, 31);

			new bool:bFound = false
			for(new a; a < MAX_SKINS; a++)
			{
				if(i == g_iWeaponUsedInContract[id][a])
				{
					bFound = true
					break
				}
			}

			iChance = ArrayGetCell(g_aSkinChance, i)

			if(iChance == 101)
			{
				formatex(temp, charsmax(temp), "%s%s%s \d[\r%d\d]%s",
				g_bIsWeaponStattrak[id][i] ? "\rStatTrak " : "", bool:g_CvarShowSpecialSkins ? "\y" : "\w", szSkin, num, bFound ? " [\rCON\d]" : "");
			}
			else 
			{
				formatex(temp, charsmax(temp), "%s%s \d[\r%d\d] [\r%i\y%s\d]%s",
				g_bIsWeaponStattrak[id][i] ? "\rStatTrak\w " : "", szSkin, num, 100 - iChance, "%", bFound ? " [\rCON\d]" : "");
			}

			num_to_str(i, szItem, charsmax(szItem));
			menu_additem(menu, temp, szItem);

			total++;
		}

		i++;
	}

	if (!total)
	{
		formatex(temp, charsmax(temp), "\r%L", id, "NO_ITEMS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp, szItem);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public contract_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowSkinsC(id)
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[5];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, charsmax(itemdata), {0}, 0, dummy);
	index = str_to_num(itemdata);
	if (index == NO_SKIN_VALUE)
	{
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	if(index == g_iUserSellItem[id])
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CURRENTLY_SELLING");
		_ShowContractMenu_continue(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}

	new bool:bFound = false
	for(new i;i < MAX_SKINS;i++)
	{
		if(index == g_iWeaponUsedInContract[id][i])
		{
			bFound = true
			break
		}
	}
	
	if(g_iWeaponIdToCheck[id] != ArrayGetCell(g_aSkinWeaponID, index))
	{
		_ShowContractMenu_continue(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
		
	if(bFound)
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CURRENTLY_USING_CONTRACT");
		_ShowContractMenu_continue(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}

	g_iSkinsInContract[id]++
	
	g_iUsedSttC[id][g_iSkinsInContract[id]] = -1

	if(g_bIsWeaponStattrak[id][index])
	{
		if(g_iUserSkins[id][index] > 1)
		{
			askWhichType(id, index)
			g_iAskType[id] = 6
			return PLUGIN_HANDLED
		}
		else g_iUsedSttC[id][g_iSkinsInContract[id]] = index
	}
	g_iWeaponUsedInContract[id][g_iSkinsInContract[id]] = index

	if(g_bIsWeaponStattrak[id][index])
	{
		g_iUserChance[id] += 3
	}
	else g_iUserChance[id] += 1
	
	if(g_iSkinsInContract[id] == MAX_SKINS - 1)
	{
		askToContinue(id)
	}
	else
	{
		_ShowContractMenu_continue(id);
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

askToContinue(id)
{
	new menu = menu_create(fmt("%s Do you confirm your Contract?", MENU_PREFIX), "confirmation_handler");	
	menu_additem(menu, "\rNo")
	menu_additem(menu, "\yYes")

	if(is_user_connected(id))
	{
		menu_display(id, menu)
	}
	else 
	{
		menu_destroy(menu)
	}
}

public confirmation_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		_ShowSkinsC(id)
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}

	g_iSkinsInContract[id] = -1
	
	if(bool:item == true)
	{
		AddStatistics(id, TOTAL_CONTRACTS, 1, .line = __LINE__)

		for(new i, index = -1;i < MAX_SKINS;i++)
		{
			index = g_iWeaponUsedInContract[id][i]
			g_iUserSkins[id][index]--

	
			if((g_iUsedSttC[id][i] != -1 || g_iUserSkins[id][index] == 0) && g_iUsedSttC[id][i] == index)
			{
				g_bIsWeaponStattrak[id][index] = false
			
				if(g_bHasSkinTag[id][index])
				{
					g_bHasSkinTag[id][index] = false
					g_szSkinsTag[id][index][0] = '0'
					g_iNameTagSkinLevel[id][index] = 0

					save_skin_tags(id)
				}
			}

			if(g_iUsedSttC[id][i] != index && g_iUsedSttC[id][i] != -1)
			{
				log_to_file(LOG_FILE, "Contract error: g_iUsedSttC[id][i] = %d ; g_iWeaponUsedInContract[id][i] = %d ; index = %d", g_iUsedSttC[id][i], g_iWeaponUsedInContract[id][i], index)
			}
			
			checkInstantDefault(id, index)
			
			g_iUsedSttC[id][i] = -1;
			g_iWeaponUsedInContract[id][i] = -1
		}

		new iRandomSkin = contractitem(); new name[48];
		ArrayGetString(g_aSkinName, iRandomSkin, name, charsmax(name));

		if(g_iUserSkins[id][iRandomSkin] >= SKIN_LIMIT)
		{
			new iValue, iRandom = random_num(0, 1)
			if(iRandom)
			{
				iValue = random_num(5, 100)
				g_iUserMoney[id] += iValue
				AddStatistics(id, RECEIVED_MONEY, iValue, .line = __LINE__)
			}
			else
			{
				iValue = random_num(5, 75)
				g_iUserScraps[id] += iValue
				AddStatistics(id, RECEIVED_SCRAPS, iValue, .line = __LINE__)
			}
			client_print_color(id, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "SINCE_ALREADY_HAVE", name, iValue, (iRandom == 1) ? "$" : " scraps")
			_ShowMainMenu(id)
		}
		else
		{
			g_iUserSkins[id][iRandomSkin]++

			if(random_num(1, 100) <= g_iUserChance[id])
			{
				g_bIsWeaponStattrak[id][iRandomSkin] = true
				AddStatistics(id, DROPPED_STT_SKINS, 1, iRandomSkin, .line = __LINE__)
			}
			else 
			{
				AddStatistics(id, DROPPED_SKINS, 1, iRandomSkin, .line = __LINE__)
			}

			client_print_color(0, id, "^4%s^1 %L", CHAT_PREFIX, id, "SIGNED_CONTRACT", g_szName[id], g_bIsWeaponStattrak[id][iRandomSkin] ? "StatTrak " : "", name)
		}
	}

	for(new i; i < MAX_SKINS; i++)
	{
		g_iUsedSttC[id][i] = -1;
		g_iWeaponUsedInContract[id][i] = -1
	}

	g_iUserChance[id] = 0

	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

contractitem()
{
	new bool:bFoundSkin = false;
	new iRandomSkin, iChance;

	while(!bFoundSkin)
	{
		iRandomSkin = random_num(0, g_iSkinsNum - 1);
		iChance = ArrayGetCell(g_aSkinChance, iRandomSkin)

		if((g_CvarUndroppableChance != -1 && iChance >= g_CvarUndroppableChance) || (iChance == 101))
		{
			continue
		}
		
		bFoundSkin = true;
	}
	
	return iRandomSkin;
}

_ShowSkinMenu(id)
{
	new szTitle[256]
	formatex(szTitle, charsmax(szTitle), "%s %L", MENU_PREFIX, id, "MENU_SKINS")
	new iMenu = menu_create(szTitle, "skins_handler")	
	new szItem[128], szData[5], iWeaponID, iMaxSkins, iUserTotalSkins, iWeapSkins

	for(new i; i < sizeof(g_WeapMenu); i++)
	{
		iWeaponID = g_WeapMenu[i][WeaponID];

		iMaxSkins = getMaxSkinsOfWeapon(iWeaponID)

		if(iMaxSkins > 0)
		{							
			iWeapSkins = getUserSkinsValue(id, iWeaponID)
			formatex(szItem, charsmax(szItem), "%s \d[\r%d\w/\y%d\d]", g_WeapMenu[i][WeapName], iWeapSkins, iMaxSkins * 5);
			num_to_str(g_WeapMenu[i][WeaponID], szData, charsmax(szData))
			menu_additem(iMenu, szItem, szData);

			iUserTotalSkins += iWeapSkins
		}
	}
	
	if(is_user_connected(id))
	{
		formatex(szTitle, charsmax(szTitle), "%s %l", MENU_PREFIX, "MENU_SKINS_INV_TITLE", AddCommas(iUserTotalSkins), iUserTotalSkins > 1 ? "s" : "")
		menu_setprop(iMenu, MPROP_TITLE, szTitle)
		menu_display(id, iMenu)
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

getUserSkinsValue(id, iWeaponID)
{
	new i, wid, num, iTotalSkins
	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i]
		if (num > 0)
		{
			wid = ArrayGetCell(g_aSkinWeaponID, i)
			if(wid != iWeaponID)
			{
				i++
				continue
			}
			iTotalSkins += num
		}
		i++
	}
	return iTotalSkins
}

getMaxSkinsOfWeapon(iWeaponID)
{
	new i, wid, iTotalSkins
	while (i < g_iSkinsNum)
	{
		wid = ArrayGetCell(g_aSkinWeaponID, i)
		if(wid == iWeaponID)
		{
			iTotalSkins++
		}
		i++
	}
	return iTotalSkins
}

public skins_handler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		ShowInventoryMenu(id);
		menu_destroy(iMenu)
		return PLUGIN_HANDLED
	}
	new szData[6], szItemName[64]
	new _access, item_callback
	menu_item_getinfo(iMenu, iItem, _access, szData, charsmax(szData), szItemName, charsmax(szItemName), item_callback)
	
	new iData = str_to_num(szData)
	g_iWeaponIdToCheck[id] = iData
	switch(g_iMenuToOpen[id])
	{
		case 0: 	openInventory(id, iData)
		case 1:	 	openContractMenu(id, iData)
		case 2: 	openCoinflipMenu(id, iData)
		case 3: 	openSellMenu(id, iData)
		case 4: 	openDustbinSkins(id, iData)
		case 5: 	openGiftMenu(id, iData)
		case 6:		openTradeMenu(id, iData)
		case 7:		openJackpotMenu(id, iData)
		case 8:		openUpgradeMenu(id, iData)
	}
	return PLUGIN_HANDLED
}

openInventory(id, iWeaponId)
{
	new temp[128];
	formatex(temp, charsmax(temp), "%s \w%L", MENU_PREFIX, id, "MENU_SKINS");
	new menu = menu_create(temp, "skin_menu_handler", 0);
	new szItem[10];
	new bool:hasSkins;
	new num;
	new skinName[100];
	new wid;
	new apply;
	new applied[25];
	new i;
	new iChance

	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i];
		if (num > 0)
		{
			wid = ArrayGetCell(g_aSkinWeaponID, i);
			if(wid != iWeaponId)
			{
				i++
				continue
			}
			ArrayGetString(g_aSkinName, i, skinName, 47);
			
			if (i == g_iUserSelectedSkin[id][wid])
			{
				apply = 1;
			}
			else
			{
				apply = 0;
			}
			
			switch (apply)
			{
				case 1:
				{
					applied = " \y[\w#\y]";
				}
				
				default:
				{
					applied = "";
				}
			}

			iChance = ArrayGetCell(g_aSkinChance, i)

			if(iChance == 101)
			{
				formatex(temp, charsmax(temp), "%s%s%s \d[\r%d\d]%s",
				g_bIsWeaponStattrak[id][i] ? "\rStatTrak " : "", bool:g_CvarShowSpecialSkins ? "\y" : "\w", skinName, num, applied);
			}
			else 
			{
				formatex(temp, charsmax(temp), "%s%s \d[\r%d\d] [\r%i\y%s\d]%s",
				g_bIsWeaponStattrak[id][i] ? "\rStatTrak\w " : "", skinName, num,
				100 - iChance, "%", applied);
			}

			num_to_str(i, szItem, charsmax(szItem));
			menu_additem(menu, temp, szItem);

			hasSkins = true;
		}

		i++;
	}
	
	if (!hasSkins)
	{
		formatex(temp, 63, "\r%L", id, "NO_ITEMS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp, szItem);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public skin_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowSkinMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}

	new itemdata[10], dummy, index;
	menu_item_getinfo(menu, item, dummy, itemdata, charsmax(itemdata), {0}, 0, dummy);
	index = str_to_num(itemdata);
	switch (index)
	{
		case NO_SKIN_VALUE:
		{
			_ShowMainMenu(id);
			menu_destroy(menu)
			return PLUGIN_HANDLED;
		}
		default:
		{
			new wid = ArrayGetCell(g_aSkinWeaponID, index);
			if((g_iWeaponIdToCheck[id] != wid) || notAnySkins(id))
			{
				_ShowSkinMenu(id);
				menu_destroy(menu)
				return PLUGIN_HANDLED;
			}
	
			new bool:SameSkin;
			if (index == g_iUserSelectedSkin[id][wid])
			{
				SameSkin = true;
			}
			
			if(isUsingSomeoneElsesWeapon(id, wid))
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "WARN_CHANGE");
				_ShowSkinMenu(id);
				menu_destroy(menu)
				return PLUGIN_HANDLED;
			}
			
			if (!SameSkin)
			{
				if(g_bIsWeaponStattrak[id][index])
				{
					if(g_iUserSkins[id][index] > 1)
					{
						askWhichType(id, index)
						g_iAskType[id] = 0
						return PLUGIN_HANDLED
					} else g_bShallUseStt[id][wid] = true;
				}
				g_iUserSelectedSkin[id][wid] = index;

				if(wid == CSW_M4A1)
				{
					new sName[32];
					ArrayGetString(g_aSkinName, index, sName, 31);

					g_bUsingM4A4[id] = containi(sName, "m4a4") == -1 ? false : true
				}
				
				new iPlayers[32], iNum, model[256]
				get_players(iPlayers, iNum, "ach")

				for(new i, iPlayer;i < iNum;i++)
				{
					iPlayer = iPlayers[i]
					if(get_user_weapon(iPlayer) == wid)
					{
						if(isUsingCertainPlayersSkin(iPlayer, id, wid))
						{
							SetUserSkin(iPlayer, index, wid)
						}
					}
				}
				
				if(get_user_weapon(id) == wid)
				{
					ArrayGetString(g_aSkinModel, index, model, charsmax(model))
					SetUserSkin(id, index, wid)
				}
			
				_ShowSkinMenu(id);
			}
			else
			{
				g_iUserSelectedSkin[id][wid] = -1;
				
				SetUserSkin(id, SET_DEFAULT_MODEL, wid)
					
				_ShowSkinMenu(id);
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_ShowCFMenu(id)
{
	if (g_bCFAccept[id])
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CANT_START_CF");
		return
	}
	new temp[64];
	formatex(temp, 63, "%s \wCoinflip", MENU_PREFIX);
	new menu = menu_create(temp, "cf_main_menu_handler", 0);
	new szItem[2];
	szItem[1] = 0;
	new bool:HasTarget;
	new bool:HasItem;
	new target = g_iCFTarget[id];
	if (target)
	{
		formatex(temp, 63, "\w%L", id, "GIFT_TARGET", g_szName[target]);
		szItem[0] = 0;
		menu_additem(menu, temp, szItem, 0, -1);
		HasTarget = true;
	}
	else
	{
		formatex(temp, 63, "Choose receiver");
		szItem[0] = 0;
		menu_additem(menu, temp, szItem, 0, -1);
	}
	if (!_IsGoodItem(g_iCFItem[id]))
	{
		formatex(temp, 63, "\rSelect a skin^n");
		szItem[0] = 1;
		menu_additem(menu, temp, szItem, 0, -1);
	}
	else
	{
		new Item[32];
		new index = g_iCFItem[id];
		_GetItemName(index, Item, 31);
		
		if(!g_bHasSkinTag[id][index] && (g_bBettingCFStt[id] || !g_bBettingCFStt[id]))
			formatex(temp, 63, "\r%s\w%s^n", g_bBettingCFStt[id] ? "StatTrak " : "", Item);
		else 
			formatex(temp, 63, "%s \r(%s '%s')^n",
			Item, g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
		szItem[0] = 1;
		menu_additem(menu, temp, szItem, 0, -1);
		HasItem = true;
	}
	if (HasTarget && HasItem && !g_bCFActive[id])
	{
		formatex(temp, 63, "\rSend");
		szItem[0] = 2;
		menu_additem(menu, temp, szItem, 0, -1);
	}
	if (g_bCFActive[id] || g_bCFSecond[id])
	{
		formatex(temp, 63, "\rCancel");
		szItem[0] = 3;
		menu_additem(menu, temp, szItem, 0, -1);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public cf_main_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		if (g_bCFSecond[id])
		{
			clcmd_say_deny_cf(id);
		}
		_ShowGamesMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[2];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, 1, {0}, 0, dummy);
	index = itemdata[0];
	switch (index)
	{
		case 0:
		{
			if (g_bCFActive[id] || g_bCFSecond[id])
			{
				_ShowCFMenu(id);
			}
			else
			{
				_SelectCFTarget(id);
			}
		}
		case 1:
		{
			if (g_bCFActive[id])
			{
				_ShowCFMenu(id);
			}
			else
			{
				_SelectCFItem(id);
			}
		}
		case 2:
		{
			new target = g_iCFTarget[id];
			new _item = g_iCFItem[id];
			if (!g_bLogged[target] || !(0 < target && 32 >= target))
			{
				_ResetCFData(id);
			}
			else
			{
				if (!_UserHasItem(id, _item))
				{
					g_iCFItem[id] = -1;
					_ShowCFMenu(id);
					return PLUGIN_HANDLED
				}
				
				if (g_bCFSecond[id] && !_UserHasItem(target, g_iCFItem[target]))
				{
					_ResetCFData(id);
					_ResetCFData(target);
					_ShowCFMenu(id);
					return PLUGIN_HANDLED
				}
				
				if(g_iUserSkins[target][_item] >= SKIN_LIMIT)
				{
					client_print_color(id, id, "^4%s %L", CHAT_PREFIX, id, "CANT_RECEIVE", g_szName[target]);
					_ShowCFMenu(id)
					return PLUGIN_HANDLED
				}
	
				g_bCFActive[id] = 1;
				g_iCFRequest[target] = id;
				new szItem[50], index = g_iCFItem[id];
				_GetItemName(index, szItem, charsmax(szItem));
				
				if(g_bBettingCFStt[id])
				{
					if(g_bHasSkinTag[id][index])
					{
						formatex(szItem, charsmax(szItem), "%s^3 (%s '%s')",
						szItem, g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
					}	
					else formatex(szItem, charsmax(szItem), "StatTrak %s", szItem)
				}
				
				if (!g_bCFSecond[id])
				{
					g_bCFAccept[target] = 1
					
					client_print_color(target, target, "^4%s %L", CHAT_PREFIX, id, "WANT_BET_CF", g_szName[id], szItem);
					client_print_color(target, target, "^4%s^1 %L", CHAT_PREFIX, id, "CF_INFO");
				}
				else
				{
					if(g_iUserSkins[id][_item] >= SKIN_LIMIT)
					{
						client_print_color(id, id, "^4%s %L", CHAT_PREFIX, id, "CANT_RECEIVE", g_szName[id]);
						_ShowCFMenu(target)
						return PLUGIN_HANDLED
					}
				
					new szItem[50], index = g_iCFItem[target];
					_GetItemName(g_iCFItem[target], szItem, charsmax(szItem));
					
					if(g_bBettingCFStt[target])
					{
						if(g_bHasSkinTag[target][index])
						{
							formatex(szItem, charsmax(szItem), "%s^3 (%s '%s')",
							szItem, g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
						}	
						else formatex(szItem, charsmax(szItem), "StatTrak %s", szItem)
					}
					client_print_color(target, print_team_default, "^4%s %L", CHAT_PREFIX, id, "WANT_BET_CF", g_szName[id], szItem);
					client_print_color(target, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "CF_INFO");
					
					g_bCFAccept[target] = 1;
				}
			}
		}
		case 3:
		{
			if (g_bCFSecond[id])
			{
				clcmd_say_deny_cf(id);
			}
			else
			{
				_ResetCFData(id);
			}
			_ShowCFMenu(id);
		}
		default:
		{
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_SelectCFTarget(id)
{
	new temp[64];
	formatex(temp, 63, "%s %L", MENU_PREFIX, id, "GIFT_SELECT_TARGET");
	new menu = menu_create(temp, "cf_menu_handler", 0);
	new szItem[10];
	szItem[1] = 0;
	new Pl[32];
	new n;
	new p;
	get_players(Pl, n);
	new total;
	if (n)
	{
		new i;
		while (i < n)
		{
			p = Pl[i];
			
			if (g_bLogged[p])
			{
				if (!(p == id))
				{
					szItem[0] = p;
					menu_additem(menu, g_szName[p], szItem, 0, -1);
					total++;
				}
			}
			i++;
		}
	}
	if (!total)
	{
		formatex(temp, 63, "\r%L", id, "NO_REGISTERED_PLAYERS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp, szItem, 0, -1);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public cf_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowCFMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[2];
	new dummy;
	new index;
	new name[32];
	menu_item_getinfo(menu, item, dummy, itemdata, 1, name, 31, dummy);
	index = itemdata[0];
	switch (index)
	{
		case NO_SKIN_VALUE:
		{
			_ShowMainMenu(id);
			menu_destroy(menu)
			return PLUGIN_HANDLED;
		}
		default:
		{
			if (!g_iCFRequest[index])
			{
				g_iCFTarget[id] = index;
			}
			_ShowCFMenu(id);
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_SelectCFItem(id)
{
	_ShowSkinMenu(id)
}

openCoinflipMenu(id, iWeaponId)
{
	new temp[64];
	formatex(temp, 63, "%s \w%L", MENU_PREFIX, id, "MENU_SKINS");
	new menu = menu_create(temp, "cf_item_menu_handler", 0);
	new szItem[10];
	szItem[1] = 0;
	new total;
	new szSkin[32];
	new num;
	new i, wid;
	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i];
		if (0 < num)
		{
			wid = ArrayGetCell(g_aSkinWeaponID, i);
			if(wid != iWeaponId)
			{
				i++
				continue
			}
			
			ArrayGetString(g_aSkinName, i, szSkin, 31);
			
			formatex(temp, 63, "\r%s\w%s \r[%d]", g_bIsWeaponStattrak[id][i] ? "StatTrak " : "", szSkin, num);
			num_to_str(i, szItem, charsmax(szItem));
			menu_additem(menu, temp, szItem, 0, -1);
			total++;
		}
		i++;
	}
	if (!total)
	{
		formatex(temp, 63, "\r%L", id, "NO_ITEMS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp, szItem, 0, -1);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu)
	}
	else 
	{
		menu_destroy(menu)
	}
}

public cf_item_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowCFMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[5];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, charsmax(itemdata), {0}, 0, dummy);
	index = str_to_num(itemdata);
	switch (index)
	{
		case NO_SKIN_VALUE:
		{
			_ShowCFMenu(id);
			menu_destroy(menu)
			return PLUGIN_HANDLED;
		}
		default:
		{
			if (index == g_iUserSellItem[id] && g_bUserSellSkin[id])
			{
				new Item[50], index;
				_GetItemName(index, Item, charsmax(Item));
				
				if(g_bPublishedStattrakSkin[id])
				{
					if(g_bHasSkinTag[id][index])
					{
						formatex(Item, charsmax(Item), "%s^3 (%s '%s')",
						Item, g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
					}	
					else formatex(Item, charsmax(Item), "StatTrak %s", Item)
				}
				
				client_print_color(id, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_INVALID_ITEM", Item);
				_SelectCFItem(id);
			}
			else
			{
				if(g_iWeaponIdToCheck[id] != ArrayGetCell(g_aSkinWeaponID, index))
				{
					_SelectCFItem(id);
					menu_destroy(menu)
					return PLUGIN_HANDLED;
				}
				g_iCFItem[id] = index;
				
				if(g_bIsWeaponStattrak[id][index])
				{
					if(g_iUserSkins[id][index] > 1)
					{
						askWhichType(id, index)
						g_iAskType[id] = 7
						return PLUGIN_HANDLED
					}
					else
					{
						g_bBettingCFStt[id] = true
					}
				}
				else g_bBettingCFStt[id] = false
				
				if(g_bCFAccept[id])
				{
					confirmationCoinflip(id)
				}
				else _ShowCFMenu(id);
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_ResetCFData(id)
{
	g_bOneAccepted = false
	
	g_bCFActive[id] = 0;
	g_bCFSecond[id] = 0;
	g_bCFAccept[id] = 0;
	g_iCFTarget[id] = 0;
	g_iCFItem[id] = -1;
	g_iCFRequest[id] = 0;
}

public clcmd_say_accept_cf(id)
{
	new sender = g_iCFRequest[id];
	if (1 > sender || 32 < sender)
	{
		return 1;
	}
	if (!g_bLogged[sender] || !(0 < sender && 32 >= sender))
	{
		_ResetCFData(id);
		return 1;
	}
	if (!g_bCFActive[sender] && id == g_iCFTarget[sender])
	{
		_ResetCFData(id);
		return 1;
	}
	g_iCFTarget[id] = sender;
	g_iCFItem[id] = -1;
	g_bCFSecond[id] = 1;
	
	g_iMenuToOpen[id] = 2
	_SelectCFItem(id)
	return 1;
}

public confirmationCoinflip(id)
{
	new menu = menu_create(fmt("%s \wDo you confirm the Coinflip?", MENU_PREFIX), "confirm_cf_handler");	
	menu_additem(menu, "\rNo")
	menu_additem(menu, "\yYes")

	if(is_user_connected(id))
	{
		menu_display(id, menu)
	}
	else 
	{
		menu_destroy(menu)
	}
}

public confirm_cf_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		_ResetCFData(id);
		_ResetCFData(g_iCFRequest[id]);
	
		_ShowCFMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	new sender = g_bOneAccepted ? g_iCFTarget[id] : g_iCFRequest[id]
	if(item)
	{
		new sItem = g_iCFItem[sender];
		new tItem = g_iCFItem[id];

		if (!_UserHasItem(id, tItem) || !_UserHasItem(sender, sItem))
		{
			_ResetCFData(id);
			_ResetCFData(sender);
			return 1;
		}

		if(g_bHasSkinTag[id][tItem] == g_bHasSkinTag[sender][sItem] && sItem == tItem)
		{
			client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "CANT_BET_SKINS_WITH_NAMETAG");
			client_print_color(sender, print_team_default, "%s %l", CHAT_PREFIX, "CANT_BET_SKINS_WITH_NAMETAG");
			return PLUGIN_HANDLED;
		}
		
		new sItemsz[50];
		new tItemsz[50];
		_GetItemName(tItem, tItemsz, charsmax(tItemsz));
		_GetItemName(sItem, sItemsz, charsmax(sItemsz));
		
		if(!g_bOneAccepted)
		{
			if(g_bIsWeaponStattrak[id][tItem])
			{
				if(g_bHasSkinTag[id][tItem])
				{
					formatex(tItemsz, charsmax(tItemsz), "%s^3 (%s '%s')",
					tItemsz, g_iNameTagSkinLevel[id][tItem] == 1 ? "Common" : g_iNameTagSkinLevel[id][tItem] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][tItem]);
				}	
				else formatex(tItemsz, charsmax(tItemsz), "StatTrak %s", tItemsz)
			}

			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CF_ACCEPT");
			client_print_color(sender, sender, "^4%s %L", CHAT_PREFIX, id, "CF_ACCEPT_INFO", g_szName[id], tItemsz);
	
			g_bOneAccepted = true
			
			confirmationCoinflip(sender)
			menu_destroy(menu)
			return PLUGIN_HANDLED	
		}


		// new iWinner, iLoser, iWinnerItem, iLoserItem

		// if(random_num(0,1) == 1)
		// {
		// 	iWinner		= id
		// 	iLoser		= sender 
		// 	iWinnerItem = tItem
		// 	iLoserItem	= sItem 
		// }

		// g_iUserSkins[iWinner][iWinnerItem]--;
		// g_iUserSkins[iLoser][iLoserItem]++;
		
		// if(g_bBettingCFStt[iLoser])
		// {
		// 	if(g_bIsWeaponStattrak[sender][tItem])
		// 	{
		// 		client_print_color(sender, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "YOU_ALREADY_HAVE", tItemsz, tItemsz);

		// 		if(!g_bHasSkinTag[sender][tItem] && g_bHasSkinTag[id][tItem])
		// 		{
		// 			g_bHasSkinTag[sender][tItem] = g_bHasSkinTag[id][tItem];
		// 			g_iNameTagSkinLevel[sender][tItem] = g_iNameTagSkinLevel[id][tItem];
		// 			g_szSkinsTag[sender][tItem] = g_szSkinsTag[id][tItem];
		// 		}
		// 	}
		// 	else 
		// 	{
		// 		if(!g_bHasSkinTag[sender][tItem] && g_bHasSkinTag[id][tItem])
		// 		{
		// 			formatex(tItemsz, charsmax(tItemsz), "%s^3 (%s '%s')",
		// 			tItemsz, g_iNameTagSkinLevel[id][tItem] == 1 ? "Common" : g_iNameTagSkinLevel[id][tItem] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][tItem]);
				
		// 			g_bHasSkinTag[sender][tItem] = g_bHasSkinTag[id][tItem];
		// 			g_iNameTagSkinLevel[sender][tItem] = g_iNameTagSkinLevel[id][tItem];
		// 			g_szSkinsTag[sender][tItem] = g_szSkinsTag[id][tItem];

		// 			g_bHasSkinTag[id][tItem] = false;
		// 			g_iNameTagSkinLevel[id][tItem] = 0;
		// 			g_szSkinsTag[id][tItem][0] = '0';
		// 		}	
		// 		else formatex(tItemsz, charsmax(tItemsz), "StatTrak %s", tItemsz)
				
		// 		g_bIsWeaponStattrak[sender][tItem] = true
		// 	}
		// 	g_bIsWeaponStattrak[id][tItem] = false
		// 	g_iUserStattrakKillCount[id][tItem] = 0
		// }
			
		// checkInstantDefault(id, tItem)
	
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CF_LOST");
		client_print_color(sender, sender, "^4%s^1 %L", CHAT_PREFIX, id, "CF_WON", tItemsz);
		
		if(random_num(0, 1) == 1)
		{
			g_iUserSkins[id][tItem]--;
			g_iUserSkins[sender][tItem]++;

			
			if(g_bBettingCFStt[id])
			{
				if(g_bIsWeaponStattrak[sender][tItem])
				{
					client_print_color(sender, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "YOU_ALREADY_HAVE", tItemsz, tItemsz);

					if(!g_bHasSkinTag[sender][tItem] && g_bHasSkinTag[id][tItem])
					{
						g_bHasSkinTag[sender][tItem] = g_bHasSkinTag[id][tItem];
						g_iNameTagSkinLevel[sender][tItem] = g_iNameTagSkinLevel[id][tItem];
						g_szSkinsTag[sender][tItem] = g_szSkinsTag[id][tItem];
					}
				}
				else 
				{
					if(!g_bHasSkinTag[sender][tItem] && g_bHasSkinTag[id][tItem])
					{
						formatex(tItemsz, charsmax(tItemsz), "%s^3 (%s '%s')",
						tItemsz, g_iNameTagSkinLevel[id][tItem] == 1 ? "Common" : g_iNameTagSkinLevel[id][tItem] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][tItem]);
					
						g_bHasSkinTag[sender][tItem] = g_bHasSkinTag[id][tItem];
						g_iNameTagSkinLevel[sender][tItem] = g_iNameTagSkinLevel[id][tItem];
						g_szSkinsTag[sender][tItem] = g_szSkinsTag[id][tItem];

						g_bHasSkinTag[id][tItem] = false;
						g_iNameTagSkinLevel[id][tItem] = 0;
						g_szSkinsTag[id][tItem][0] = '0';
					}	
					else formatex(tItemsz, charsmax(tItemsz), "StatTrak %s", tItemsz)
					
					g_bIsWeaponStattrak[sender][tItem] = true
				}
				g_bIsWeaponStattrak[id][tItem] = false
				g_iUserStattrakKillCount[id][tItem] = 0
			}
				
			checkInstantDefault(id, tItem)
		
			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CF_LOST");
			client_print_color(sender, sender, "^4%s^1 %L", CHAT_PREFIX, id, "CF_WON", tItemsz);
		}
		else
		{
			g_iUserSkins[id][sItem]++;
			g_iUserSkins[sender][sItem]--;
				
			if(g_bBettingCFStt[sender])
			{
				if(g_bIsWeaponStattrak[id][sItem])
				{
					client_print_color(sender, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "YOU_ALREADY_HAVE", tItemsz, tItemsz);
					g_bIsWeaponStattrak[id][sItem] = true;
					if(!g_bHasSkinTag[id][sItem] && g_bHasSkinTag[sender][sItem])
					{
						g_bHasSkinTag[id][sItem] = g_bHasSkinTag[sender][sItem];
						g_iNameTagSkinLevel[id][sItem] = g_iNameTagSkinLevel[sender][sItem];
						g_szSkinsTag[id][sItem] = g_szSkinsTag[sender][sItem];
					}
				}
				else 
				{
					if(!g_bHasSkinTag[id][sItem] && g_bHasSkinTag[sender][sItem])
					{
						formatex(sItemsz, charsmax(sItemsz), "%s^3 (%s '%s')",
						sItemsz, g_iNameTagSkinLevel[id][sItem] == 1 ? "Common" : g_iNameTagSkinLevel[id][sItem] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][sItem]);
					
						g_bHasSkinTag[id][sItem] = g_bHasSkinTag[sender][sItem];
						g_iNameTagSkinLevel[id][sItem] = g_iNameTagSkinLevel[sender][sItem];
						g_szSkinsTag[id][sItem] = g_szSkinsTag[sender][sItem];

						g_bHasSkinTag[sender][sItem] = false;
						g_iNameTagSkinLevel[sender][sItem] = 0;
						g_szSkinsTag[sender][sItem][0] = '0';
					}	
					else formatex(sItemsz, charsmax(sItemsz), "StatTrak %s", sItemsz)
					
					g_bIsWeaponStattrak[id][sItem] = true
				}
				g_bIsWeaponStattrak[sender][sItem] = false
				g_iUserStattrakKillCount[sender][sItem] = 0
			}
		
			checkInstantDefault(sender, sItem)
		
			client_print_color(sender, sender, "^4%s^1 %L", CHAT_PREFIX, id, "CF_LOST");
			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CF_WON", sItemsz);
		}
	}
	else
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CF_LOST");
		client_print_color(sender, sender, "^4%s^1 %L", CHAT_PREFIX, id, "CF_CANCELED", g_szName[id]);
	}
	
	g_bBettingCFStt[id] = false
	g_bBettingCFStt[sender] = false
		
	_ResetCFData(id);
	_ResetCFData(sender);

	AddStatistics(id, TOTAL_COINFLIPS, 1, .line = __LINE__)
	AddStatistics(sender, TOTAL_COINFLIPS, 1, .line = __LINE__)
		
	return 1
}

public clcmd_say_deny_cf(id)
{
	new sender = g_iCFRequest[id];
	if (sender < 1 || sender > 32)
	{
		return 1;
	}
	if (!g_bLogged[sender] || !(0 < sender && 32 >= sender))
	{
		_ResetCFData(id);
		return 1;
	}
	if (!g_bCFActive[sender] && id == g_iCFTarget[sender])
	{
		_ResetCFData(id);
		return 1;
	}
	_ResetCFData(id);
	_ResetCFData(sender);
	client_print_color(sender, sender, "^4%s^1 %L", CHAT_PREFIX, id, "CF_DENY", g_szName[id])
	client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CF_DENY_INFO", g_szName[sender])
	return 1;
}

askWhichType(id, index)
{
	new iMenu = menu_create("Use StatTrak?", "ask_handler")
	
	new szIndex[5]
	num_to_str(index, szIndex, charsmax(szIndex))
	
	menu_additem(iMenu, "\rNo", szIndex)
	menu_additem(iMenu, "\yYes", szIndex)
	
	if(is_user_connected(id))
	{
		menu_display(id, iMenu)
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public ask_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		_ShowSkinMenu(id)
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[5], dummy, index;
	menu_item_getinfo(menu, item, dummy, itemdata, charsmax(itemdata), {0}, 0, dummy);
	index = str_to_num(itemdata);
	
	new wid = ArrayGetCell(g_aSkinWeaponID, index);
	
	switch(g_iAskType[id])
	{
		case 0:
		{
			g_bShallUseStt[id][wid] = bool:item
			g_iUserSelectedSkin[id][wid] = index;
	
			new iPlayers[32], iNum
			get_players(iPlayers, iNum, "ach")

			for(new i, iPlayer;i < iNum;i++)
			{
				iPlayer = iPlayers[i]
				if(get_user_weapon(iPlayer) == wid)
				{
					if(isUsingCertainPlayersSkin(iPlayer, id, wid))
					{
						SetUserSkin(iPlayer, index, wid)
					}
				}
			}
				
			if(get_user_weapon(id) == wid)
			{
				SetUserSkin(id, index, wid)
			}

			_ShowSkinMenu(id)
		}
		case 1:
		{
			g_bPublishedStattrakSkin[id] = bool:item
			
			new szItem[32];
			_GetItemName(index, szItem, 31);
			if(g_bPublishedStattrakSkin[id])
			{
				if(g_bHasSkinTag[id][index])
				{
					client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "ITEM_SELECT_NAMETAG",
					szItem, g_iMarketNameTagsRarity[id] == 1 ? "Common" : g_iMarketNameTagsRarity[id] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
					client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "ITEM_SET_PRICE_NAMETAG",
					szItem, g_iMarketNameTagsRarity[id] == 1 ? "Common" : g_iMarketNameTagsRarity[id] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
				}
				else 
				{
					client_print_color(id, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "ASK_HANDLER_STT", szItem);
					client_print_color(id, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "ASK_HANDLER_INFO", szItem)
				}
			}
			else
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "ITEM_SET_PRICE", szItem);
			}

			client_cmd(id, "messagemode SkinPrice");
		}
		case 2:
		{
			g_bGiftingStt[id] = bool:item
			
			new szItem[32];
			_GetItemName(index, szItem, 31);
			
			if(g_bGiftingStt[id])
			{
				if(!g_bHasSkinTag[id][index])
					client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "ASK_HANDLER_SELECTED", szItem);
				else 
					client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "ITEM_SELECT_NAMETAG",
					szItem, g_iMarketNameTagsRarity[id] == 1 ? "Common" : g_iMarketNameTagsRarity[id] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
			}
			else 
			{
				client_print_color(id, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "GIFT_YOUR_GIFT", szItem);
			}
			_ShowGiftMenu(id);
		}
		case 3:
		{
			g_bDestroyStt[id] = bool:item
			destroySkin(id, index)
			_ShowDustbinMenu(id)
		}
		case 4:
		{
			g_bTradingStt[id] = bool:item
			
			new szItem[100];
			_GetItemName(index, szItem, 31);
			
			if(g_bTradingStt[id])
			{
				if(g_bHasSkinTag[id][index])
					formatex(szItem, charsmax(szItem), "%s^3 (%s '%s')",
					szItem, g_iMarketNameTagsRarity[id] == 1 ? "Common" : g_iMarketNameTagsRarity[id] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
				else 
					formatex(szItem, charsmax(szItem), "StatTrak %s", szItem);
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "ASK_HANDLER_SELECTED", szItem);
				_ShowTradeMenu(id);
			}
			else 
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_ITEM", szItem);
				_ShowTradeMenu(id);
			}
		}
		case 5:
		{
			g_bJackpotStt[id] = bool:item
			_ShowJackpotMenu(id)
		}
		case 6:
		{
			g_iUsedSttC[id][g_iSkinsInContract[id]] = (bool:item == true) ? index : -1

			g_iWeaponUsedInContract[id][g_iSkinsInContract[id]] = index
			if(g_bIsWeaponStattrak[id][index])
			{
				g_iUserChance[id] += 3
			}
			else g_iUserChance[id] += 1
	
			if(g_iSkinsInContract[id] == MAX_SKINS - 1)
			{
				askToContinue(id)
			}
			else
			{
				_ShowContractMenu_continue(id);
			}
		}
		case 7:
		{
			g_bBettingCFStt[id] = bool:item
			g_iCFItem[id] = index;
			if(g_bCFAccept[id])
			{
				confirmationCoinflip(id)
			}
			else _ShowCFMenu(id);
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

public Ham_Item_Deploy_Post(weapon_ent)
{
	new owner = fm_cs_get_weapon_ent_owner(weapon_ent);

	if (!is_user_alive(owner))
	{
		return HAM_IGNORED
	}

	if(g_bIsInPreview[owner])
	{
		restore_previous_skin(owner);
	}
	
	new weaponid = cs_get_weapon_id(weapon_ent);
		
	if(!g_bLogged[owner])
	{
		SetUserSkin(owner, SET_DEFAULT_MODEL, weaponid)
		return HAM_IGNORED
	}
				
	new userskin = g_iUserSelectedSkin[owner][weaponid];
	
	if (userskin != -1)
	{
		if (1 > g_iUserSkins[owner][userskin])
		{
			g_iUserSelectedSkin[owner][weaponid] = -1;
			userskin = -1;
		}
	}	
					
	new imp = pev(weapon_ent, 82)
	
	if(imp > 0)
	{
		if(isUsingSomeoneElsesWeapon(owner, weaponid))
		{
			if(g_iUserSelectedSkin[getOriginalOwnerID(owner, weaponid)][weaponid] == -1)
			{
				SetUserSkin(owner, SET_DEFAULT_MODEL, weaponid)
			}
			else
			{
				SetUserSkin(owner, g_iUserSelectedSkin[getOriginalOwnerID(owner, weaponid)][weaponid], weaponid)
			}
		}
		else // is not using his weapon
		{
			if(imp != DEFAULT_SKIN)
			{
				new iIndex = imp - 1
				SetUserSkin(owner, iIndex, weaponid)
			}
			else
			{
				SetUserSkin(owner, SET_DEFAULT_MODEL, weaponid)
			}

		}
	}
	else // is using his weapon
	{
		SetUserSkin(owner, userskin, weaponid)
	}

	return HAM_IGNORED
}

fm_cs_get_weapon_ent_owner(ent)
{
	if (pev_valid(ent) != 2)
	{
		return -1;
	}
	return get_pdata_cbase(ent, 41, 4, 5);
}

public Ham_Item_Can_Drop(ent)
{
	if (pev_valid(ent) != 2)
	{
		return PLUGIN_HANDLED;
	}
	
	new weapon = get_pdata_int(ent, 43, 4, 5);
	if ((weapon <= 0) || (weapon > 30))
	{
		return PLUGIN_HANDLED;
	}
	if (1 << weapon & 570425936)
	{
		return PLUGIN_HANDLED;
	}
	new imp = pev(ent, 82), id = get_pdata_cbase(ent, 41, 4, 5);
	if ((0 < imp))
	{
		return PLUGIN_HANDLED;
	}
	if (!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}
	new skin = g_iUserSelectedSkin[id][weapon];
	set_pev(ent, 82, (skin == -1) ? DEFAULT_SKIN : skin + 1)
	return PLUGIN_HANDLED;
}

_ShowOpenCaseCraftMenu(id)
{
	new temp[96];
	formatex(temp, 95, "\r%s \w%L", MENU_PREFIX, id, "CRAFT_MENU");
	new menu = menu_create(temp, "oc_craft_menu_handler", 0);
	new szItem[2];
	szItem[1] = 0;
	formatex(temp, 95, "\w%L \r[%L]^n", id, "OPENCASE", id, "OPENCASE_CK", g_iUserCases[id], g_iUserKeys[id]);
	szItem[0] = 0;
	menu_additem(menu, temp, szItem, 0, -1);
	if (0 < c_DropType)
	{
		formatex(temp, 95, "\r%L \r[%L]", id, "BUY_KEY", id, "KEY_PRICE", c_KeyPrice);
		szItem[0] = 2;
		menu_additem(menu, temp, szItem, 0, -1);
		formatex(temp, 95, "\r%L \r[%L]^n", id, "SELL_KEY", id, "KEY_CASHBACK", c_KeyPrice / 2);
		szItem[0] = 3;
		menu_additem(menu, temp, szItem, 0, -1);
	}
	
	formatex(temp, 95, "\w%l \r[%l]", "CRAFT_SUBMENU", "CRAFT_SCRAPS", g_iUserScraps[id], c_CraftCost);
	szItem[0] = 1;
	menu_additem(menu, temp, szItem, 0, -1);

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public oc_craft_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[2];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, 1, {0}, 0, dummy);
	index = itemdata[0];
	switch (index)
	{
		case 0:
		{
			if (g_iUserCases[id] < 1 || g_iUserKeys[id] < 1)
			{
				_ShowOpenCaseCraftMenu(id);
			}
			else
			{
				_ShowOpenCaseCraftMenu(id);
				_OpenCase(id);
				return PLUGIN_HANDLED
			}
		}
		case 1:
		{
			if (c_CraftCost > g_iUserScraps[id])
			{
				_ShowOpenCaseCraftMenu(id);
			}
			else
			{
				_ShowOpenCaseCraftMenu(id);
				_CraftSkin(id);
				return PLUGIN_HANDLED
			}
		}
		case 2:
		{
			if (c_KeyPrice > g_iUserMoney[id])
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "NOT_ENOUGH_MONEY", c_KeyPrice - g_iUserMoney[id]);
				_ShowOpenCaseCraftMenu(id);
			}
			else
			{
				g_iUserMoney[id] -= c_KeyPrice;
				g_iUserKeys[id]++;
				AddStatistics(id, DROPPED_KEYS, 1, .line = __LINE__)
				_ShowOpenCaseCraftMenu(id);
			}
		}
		case 3:
		{
			if (1 > g_iUserKeys[id])
			{
				_ShowOpenCaseCraftMenu(id);
			}
			else
			{
				g_iUserMoney[id] += c_KeyPrice / 2;
				AddStatistics(id, RECEIVED_MONEY, c_KeyPrice / 2, .line = __LINE__)
				g_iUserKeys[id]--;
				_ShowOpenCaseCraftMenu(id);
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}


_OpenCase(id)
{
	new szMessage[191];	
	new bool:succes;
	new rSkin = -1;
	new rChance;
	new wChance;

	new bool:bNoSkinSelected = true;
	new bool:bSkinTypeMode = bool:g_CvarSkinType;

	while(bNoSkinSelected)
	{
		rSkin = random(g_iSkinsNum - 1);

		if(bSkinTypeMode)
		{
			if (ArrayGetCell(g_aSkinType, rSkin) != DROP_SKIN)
				continue;
		}
		
		rChance = random_num(1, 100);
		wChance = ArrayGetCell(g_aSkinChance, rSkin);
		
		if(g_CvarUndroppableChance != -1 && wChance >= g_CvarUndroppableChance)
		{
			continue
		}

		if(wChance == 101)
		{
			continue;
		}
		
		if (rChance >= wChance)
		{
			succes = true;
		}
		
		if (succes)
		{
			bNoSkinSelected = false
			
			g_iUserCases[id]--;
			g_iUserKeys[id]--;

			new Skin[32];
			ArrayGetString(g_aSkinName, rSkin, Skin, 31);
			if(g_iUserSkins[id][rSkin] >= SKIN_LIMIT)
			{
				new iRandomValue = random_num(0, 1);
				new bool:bScrapsInstead = bool:(iRandomValue == 1);

				new iValue = 1;
				if(bScrapsInstead)
				{
					g_iUserScraps[id] += iValue;
					AddStatistics(id, RECEIVED_SCRAPS, iValue, .line = __LINE__)
				}
				else
				{
					iValue = (ArrayGetCell(g_aSkinCostMin, rSkin)) / 4;
					g_iUserMoney[id] += iValue;
					AddStatistics(id, RECEIVED_MONEY, iValue, .line = __LINE__)
				}

				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "SINCE_ALREADY_HAVE", Skin, iValue, bScrapsInstead ? " scrap" : "$")

			}
			else
			{
				g_iUserSkins[id][rSkin]++;

				if((random_num(1, 100) <= STATTRAK_CHANCE) && !g_bIsWeaponStattrak[id][rSkin])
				{
					g_bIsWeaponStattrak[id][rSkin] = true
					formatex(szMessage, charsmax(szMessage), "%s^3 %s ^1opened ^4StatTrak %s^1 with a ^4chance of %d percent",
					CHAT_PREFIX, g_szName[id], Skin, 100 - wChance)
					AddStatistics(id, DROPPED_STT_SKINS, 1, rSkin, .line = __LINE__)
				}
				else 
				{
					formatex(szMessage, charsmax(szMessage), "%s^3 %s^1 opened ^4%s^1 with a ^4chance of %d percent",
					CHAT_PREFIX, g_szName[id], Skin, 100 - wChance)
					AddStatistics(id, DROPPED_SKINS, 1, rSkin, .line = __LINE__)
				}

				send_message(id, szMessage)
			}
		}
		_ShowOpenCaseCraftMenu(id);
	}

	return PLUGIN_HANDLED;
}

send_message(id, msg[])
{
	new iPlayers[MAX_PLAYERS], iNum, iPlayer;
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeBots | GetPlayers_ExcludeHLTV);

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i];

		if(id == iPlayer)
		{
			client_print_color(id, print_team_default, "%s", msg);
			continue;
		}

		if(g_bChatClear[iPlayer] || iPlayer == id)
			continue;

		client_print_color(iPlayer, print_team_default, "%s", msg);
	}
}

_CraftSkin(id)
{
	new bool:succes;
	new rSkin;
	new rChance;
	new wChance;
	
	new bool:bNoSkinSelected = true;
	new bool:bSkinTypeMode = bool:g_CvarSkinType;

	while(bNoSkinSelected)
	{
		rSkin = random_num(0, g_iSkinsNum - 1);

		if(bSkinTypeMode)
		{
			if (ArrayGetCell(g_aSkinType, rSkin) != CRAFT_SKIN)
				continue;
		}

		rChance = random_num(1, 100);
		wChance = ArrayGetCell(g_aSkinChance, rSkin);

		if((wChance == 101) || (g_CvarUndroppableChance != -1 && wChance >= g_CvarUndroppableChance))
		{
			continue
		}

		if (rChance < wChance)
		{
			succes = true
		}
		
		if(succes)
		{
			bNoSkinSelected = false
			
			new Skin[32];
			ArrayGetString(g_aSkinName, rSkin, Skin, 31);
			if(g_iUserSkins[id][rSkin] >= SKIN_LIMIT)
			{
				new iRandomValue = random_num(0, 1);
				new bool:bScrapsInstead = bool:(iRandomValue == 1);

				new iValue = random_num(3, 15);
				if(bScrapsInstead)
				{
					g_iUserScraps[id] += iValue;
					AddStatistics(id, RECEIVED_SCRAPS, iValue, .line = __LINE__)
				}
				else
				{
					iValue = (ArrayGetCell(g_aSkinCostMin, rSkin)) / 4;
					g_iUserMoney[id] += iValue;
					AddStatistics(id, RECEIVED_MONEY, iValue, .line = __LINE__)
				}
				g_iUserScraps[id] -= c_CraftCost;
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "SINCE_ALREADY_HAVE", Skin, iValue, bScrapsInstead ? " scrap" : "$")
			}
			else
			{
				new szMessage[191];
				
				if(random_num(1, 100) <= STATTRAK_CHANCE && !g_bIsWeaponStattrak[id][rSkin])
				{
					g_bIsWeaponStattrak[id][rSkin] = true
					formatex(szMessage, charsmax(szMessage), "^4%s^1 %l", CHAT_PREFIX, "CRAFT_STT", g_szName[id], Skin, 100 - wChance);
					AddStatistics(id, DROPPED_STT_SKINS, 1, rSkin, .line = __LINE__)
				}
				else
				{
					formatex(szMessage, charsmax(szMessage), "^4%s^1 %l", CHAT_PREFIX, "CRAFT_SUCCES", g_szName[id], Skin, 100 - wChance);
					AddStatistics(id, DROPPED_SKINS, 1, rSkin, .line = __LINE__)
				}

				send_message(id, szMessage);
				
				g_iUserSkins[id][rSkin]++;
				g_iUserScraps[id] -= c_CraftCost;
			}
			_ShowOpenCaseCraftMenu(id);
		}
	}

	return PLUGIN_HANDLED;
}

_ShowMarketMenu(id)
{
	new szTitle[96], szItem[256], szItemID[5], szSkin[100];

	formatex(szTitle, charsmax(szTitle), "\r%s \w%L", MENU_PREFIX, id, "MARKET_MENU", g_iUserMoney[id]);
	new iMenu = menu_create(szTitle, "market_menu_handler", 0);

	szItemID[1] = 0;
	if (!_IsGoodItem(g_iUserSellItem[id]))
	{
		szItemID[0] = 33;
		formatex(szItem, charsmax(szItem), "\w%l", "SELECT_ITEM");
		menu_additem(iMenu, szItem, szItemID);

		if(!g_bSellCapsule[id])
		{
			szItemID[0] = 36;
			formatex(szItem, charsmax(szItem), "\w%l", "SELL_NAMETAG");
			menu_additem(iMenu, szItem, szItemID);
		}
		else
		{
			szItemID[0] = 36;
			formatex(szItem, charsmax(szItem), "%s Name-Tag\r [%d$]", g_iMarketNameTagsRarity[id] == 1 ? "Common" : g_iMarketNameTagsRarity[id] == 2 ? "\yRare\w" : "\rMythic\w", g_iUserItemPrice[id]);
			menu_additem(iMenu, szItem, szItemID);
		}

		if(g_bActiveGloveSystem)
		{
			if(!g_bSellGlove[id])
			{
				szItemID[0] = 37;
				formatex(szItem, charsmax(szItem), "\w%l", "SELL_GLOVE");
				menu_additem(iMenu, szItem, szItemID);
			}
			else
			{
				szItemID[0] = 37;
				new eGlove[GLOVESINFO];
				ArrayGetArray(g_aGloves, g_iMarketGloveID[id], eGlove);
				formatex(szItem, charsmax(szItem), "\y%s\d Glove\r [%d$]", eGlove[szGloveName], g_iUserItemPrice[id]);
				menu_additem(iMenu, szItem, szItemID);
			}
		}
	}
	else 
	{
		szItemID[0] = 33;
		new index = g_iUserSellItem[id]

		_GetItemName(index, szSkin, charsmax(szSkin));

		if(g_bPublishedStattrakSkin[id] )
		{
			if(!g_bHasSkinTag[id][index])
			{
				formatex(szItem, charsmax(szItem), "\r%s%s%s \r[%d$]",
				g_bPublishedStattrakSkin[id] ? "StatTrak " : "", (ArrayGetCell(g_aSkinChance, index) == 101) ? "\y" : "\w", szSkin, g_iUserItemPrice[id]);
			}
			else 
			{
				formatex(szItem, charsmax(szItem), "%s%s\r (%s '%s') \r[%d$]", (ArrayGetCell(g_aSkinChance, index) == 101) ? "\y" : "\w",
				szSkin, g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic",
				g_szSkinsTag[id][index], g_iUserItemPrice[id]);
			}
		}
		else copy(szItem, charsmax(szItem), szSkin);

		menu_additem(iMenu, szItem, szItemID);


		szItemID[0] = 36;
		formatex(szItem, charsmax(szItem), "\w%l", "SELL_NAMETAG");
		menu_additem(iMenu, szItem, szItemID);

		if(g_bActiveGloveSystem)
		{
			szItemID[0] = 37;
			formatex(szItem, charsmax(szItem), "\w%l", "SELL_GLOVE");
			menu_additem(iMenu, szItem, szItemID);
		}
	}

	if (g_bIsSelling[id])
	{
		formatex(szItem, charsmax(szItem), "\r%l^n", "CANCEL_SELL");
		szItemID[0] = 35;
		menu_additem(iMenu, szItem, szItemID);
	}
	else
	{
		formatex(szItem, charsmax(szItem), "\r%l^n", "START_SELL");
		szItemID[0] = 34;
		menu_additem(iMenu, szItem, szItemID);
	}

	new iPlayers[MAX_PLAYERS], iPlayer, iNum;
	new items, szParseData[5], eGlove[GLOVESINFO];

	get_players(iPlayers, iNum, "ch");

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i];

		if(!g_bLogged[iPlayer] || (iPlayer == id))
		{
			continue
		}

		if(!g_bIsSelling[iPlayer])
		{
			continue
		}

		num_to_str(iPlayer, szParseData, charsmax(szParseData))

		if(g_bUserSellSkin[iPlayer] && _IsGoodItem(g_iUserSellItem[iPlayer]))
		{
			_GetItemName(g_iUserSellItem[iPlayer], szSkin, charsmax(szSkin));
		
			if(g_bPublishedStattrakSkin[iPlayer])
			{
				if(!g_bHasSkinTag[iPlayer][g_iUserSellItem[iPlayer]])
				{
					formatex(szItem, charsmax(szItem), "\w%s^n\r%s\w%s \r[%d$]",
					g_szName[iPlayer], g_bPublishedStattrakSkin[iPlayer] ? "StatTrak " : "", szSkin, g_iUserItemPrice[iPlayer]);		
				}
				else 
				{
					formatex(szItem, charsmax(szItem), "\w%s^n\w%s %s '%s' \r[%d$]",
					g_szName[iPlayer], szSkin,
					g_iMarketNameTagsRarity[iPlayer] == 1 ? "Common" : g_iMarketNameTagsRarity[iPlayer] == 2 ? "\yRare" : "\rMythic",
					g_szSkinsTag[iPlayer][g_iUserSellItem[iPlayer]],
					g_iUserItemPrice[iPlayer]);			
				}
			}
			else formatex(szItem, charsmax(szItem), "%s^n%s\r [%d$]", g_szName[iPlayer], szSkin, g_iUserItemPrice[iPlayer])

			menu_additem(iMenu, szItem, szParseData);
		}
		else if(g_bSellCapsule[iPlayer])
		{
			formatex(szItem, charsmax(szItem), "%s^n\w%s\w Name-Tag \r[%d$]",
			g_szName[iPlayer], g_iMarketNameTagsRarity[iPlayer] == 1 ? "\dCommon" :  g_iMarketNameTagsRarity[iPlayer] == 2 ? "\yRare" :  g_iMarketNameTagsRarity[iPlayer] == 3 ? "\rMythic" : "",
			g_iUserItemPrice[iPlayer]);
			menu_additem(iMenu, szItem, szParseData);
		}
		else if(g_bSellGlove[iPlayer])
		{
			ArrayGetArray(g_aGloves, g_iMarketGloveID[id] == -1 ? 0 : g_iMarketGloveID[id], eGlove)
			formatex(szItem, charsmax(szItem), "%s^n\y%s\w Glove\r [%d$]", g_szName[iPlayer], eGlove[szGloveName], g_iUserItemPrice[iPlayer]);
			menu_additem(iMenu, szItem, szParseData);
		}
		items++;	

	}

	if (!items)
	{
		formatex(szItem, charsmax(szItem), "\r%l", "NOBODY_SELL");
		menu_additem(iMenu, szItem);
	}

	if(is_user_connected(id))
	{
		menu_display(id, iMenu, 0, -1);
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

bool:_IsGoodItem(item)
{
	if (0 <= item < g_iSkinsNum || item == -11 || item == -12)
	{
		return true;
	}
	return false;
}
public market_menu_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}

	new szIndex[5];
	new index;

	menu_item_getinfo(menu, item, _, szIndex, charsmax(szIndex), _, _);
	index = szIndex[0];
	
	switch (index)
	{
		case NO_SKIN_VALUE:
		{
			_ShowMarketMenu(id);
			menu_destroy(menu)
			return PLUGIN_HANDLED;
		}
		case 33:
		{
			if(g_bIsSelling[id])
			{
				client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "MUST_STOP_SELLING");
				_ShowMarketMenu(id);
			}
			else _ShowItems(id)		
		}
		case 36:
		{
			if(g_bIsSelling[id])
			{
				client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "MUST_STOP_SELLING");
				_ShowMarketMenu(id);
			}
			else show_market_name_tag_menu(id);
		}
		case 37:
		{
			if(g_bIsSelling[id])
			{
				client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "MUST_STOP_SELLING");
				_ShowMarketMenu(id);
			}
			else show_market_gloves(id);
		}
		case 34:
		{
			if (!_UserHasItem(id, g_iUserSellItem[id]) && g_bSellCapsule[id] == false && g_bSellGlove[id] == false)
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "MUST_SELECT");
				_ShowMarketMenu(id);
			}
			else
			{			
				if (1 > g_iUserItemPrice[id])
				{
					client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "MUST_SET_PRICE"); 
					_ShowMarketMenu(id);
					return PLUGIN_HANDLED;
				}

				if(g_bUserSellSkin[id] && g_iUserSellItem[id] != -1)
				{
					new wPriceMin;
					new wPriceMax;

					_CalcItemPrice(g_iUserSellItem[id], id, wPriceMin, wPriceMax);

					if (!(wPriceMin <= g_iUserItemPrice[id] <= wPriceMax))
					{
						new szSkinName[64]
						ArrayGetString(g_aSkinName, g_iUserSellItem[id], szSkinName, charsmax(szSkinName))
						client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "PRICE_MUST_BE_BETWEEN", szSkinName, AddCommas(wPriceMin), AddCommas(wPriceMax));
						_ShowMarketMenu(id);
						return PLUGIN_HANDLED
					}

					publicItemOnMarket(id, g_bPublishedStattrakSkin[id], SELL_SKIN);
				}
				else if (g_bSellCapsule[id])
				{
					publicItemOnMarket(id, g_bPublishedStattrakSkin[id], SELL_CAPSULE);
				}
				else if(g_bSellGlove[id])
				{
					publicItemOnMarket(id, g_bPublishedStattrakSkin[id], SELL_GLOVE);
				}
			}
		}
		case 35:
		{
			g_bUserSellSkin[id] = false;
			g_bIsSelling[id] = false; 
			g_iUserSellItem[id] = -1; 
			g_bSellCapsule[id] = false;
			g_iMarketNameTagsRarity[id] = 0;
			g_bPublishedStattrakSkin[id] = false;
			g_iUserItemPrice[id] = 0;
			g_bSellGlove[id] = false;
			g_iMarketGloveID[id] = -1;
			
			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CANCEL_SELL_M");
			_ShowMarketMenu(id);
		}
		default:
		{
			index = str_to_num(szIndex);
			if(index <= 0 || index > 32)
			{
				_ShowMarketMenu(id);
			}
			else if (!g_bLogged[index])
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "INVALID_SELLER");
				g_bUserSellSkin[index] = false;
				g_bIsSelling[index] = true;
				_ShowMarketMenu(id);
			}
			else
			{
				new tItem = g_iUserSellItem[index];
				new price = g_iUserItemPrice[index];
			
				if (!_UserHasItem(index, tItem) && !g_bSellCapsule[index] && !g_bSellGlove[index])
				{
					client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "DONT_HAVE_ITEM");
					g_bUserSellSkin[index] = false;
					g_bIsSelling[index] = false;
					g_iUserSellItem[index] = -1;
					g_bPublishedStattrakSkin[index] = false
					_ShowMarketMenu(id);
					return PLUGIN_HANDLED
				}
				if (price > g_iUserMoney[id])
				{
					client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "NOT_ENOUGH_MONEY", price - g_iUserMoney[id]);
					_ShowMarketMenu(id);
					return PLUGIN_HANDLED
				}
				
				if(tItem != -1 && !g_bSellCapsule[index] && !g_bSellGlove[index])
				{
					if(g_iUserSkins[id][tItem] >= SKIN_LIMIT)
					{
						client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CANT_BUY");
						_ShowMarketMenu(id);
						return PLUGIN_HANDLED
					}
				}
				
				if(g_bSellCapsule[index])
				{
					switch(g_iMarketNameTagsRarity[index])
					{
						case 1: { g_iCommonNameTag[id]++; g_iCommonNameTag[index]--; }
						case 2:	{ g_iRareNameTag[id]++; g_iRareNameTag[index]--; }
						case 3:	{ g_iMythicNameTag[id]++; g_iMythicNameTag[index]--; }
					}

					client_print_color(0, print_team_default, "%s %l", CHAT_PREFIX, "BOUGHT_NAMETAG", g_szName[id],
					g_iMarketNameTagsRarity[index] == 1 ? "Common" :  g_iMarketNameTagsRarity[index] == 2 ? "Rare" : "Mythic", g_szName[index], AddCommas(g_iUserItemPrice[index]));
					
					g_iUserMoney[index] += g_iUserItemPrice[index];
					g_iUserMoney[id] -= g_iUserItemPrice[index];
					g_bIsSelling[index] = false;
					g_iUserItemPrice[index] = 0;
					g_bSellCapsule[index] = false;
					g_iMarketNameTagsRarity[index] = 0;

					save_skin_tags(id);
					save_skin_tags(index);

					AddStatistics(id, MARKET_ITEM_BOUGHT, 1, .line = __LINE__)
					AddStatistics(index, MARKET_ITEMS_SOLD, 1, .line = __LINE__)

					return PLUGIN_HANDLED;
				}

				if (g_bSellGlove[index])
				{
					g_iUserMoney[index] += g_iUserItemPrice[index];
					g_iUserMoney[id] -= g_iUserItemPrice[index];

					g_iUserGloves[id][g_iMarketGloveID[index]]++;
					g_iUserGloves[index][g_iMarketGloveID[index]]--;

					save_user_gloves(id);
					save_user_gloves(index);

					new eGlove[GLOVESINFO];
					ArrayGetArray(g_aGloves, g_iMarketGloveID[index], eGlove);

					client_print_color(0, print_team_default, "%s %l", CHAT_PREFIX, "BOUGHT_GLOVE", g_szName[id], eGlove[szGloveName], g_szName[index], AddCommas(g_iUserItemPrice[index]));
					g_iMarketGloveID[index] = -1;
					g_bIsSelling[index] = false;
					g_iUserItemPrice[index] = 0;
					g_bSellGlove[index] = false;

					AddStatistics(id, MARKET_ITEM_BOUGHT, 1, .line = __LINE__)
					AddStatistics(index, MARKET_ITEMS_SOLD, 1, .line = __LINE__)

					return PLUGIN_HANDLED;
				}

				if(_UserHasItem(index, tItem))
				{
					new szItem[32];
					_GetItemName(g_iUserSellItem[index], szItem, 31);
					
					g_iUserSkins[id][tItem]++;
					g_iUserSkins[index][tItem]--;
					g_iUserMoney[id] -= price;
					g_iUserMoney[index] += price;	

					checkInstantDefault(index, tItem)
								
					if(g_bPublishedStattrakSkin[index])
					{
						g_bIsWeaponStattrak[id][tItem] = true

						g_bIsWeaponStattrak[index][tItem] = false
						g_iUserStattrakKillCount[index][tItem] = 0
						g_bPublishedStattrakSkin[index] = false
						
						if(!g_bHasSkinTag[index][tItem])
						{
							client_print_color(0, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "ITEM_BOUGHT_STT", g_szName[id], szItem, g_szName[index]);
						}
						else 
						{
							client_print_color(0, print_team_default, "%s %l", CHAT_PREFIX, "ITEM_BOUGHT_STT_NAMETAG",
							g_szName[id], szItem, g_iNameTagSkinLevel[index][tItem] == 1 ? "Common" : g_iNameTagSkinLevel[index][tItem] == 2 ? "Rare" : "Mythic", g_szSkinsTag[index][tItem],g_szName[index], AddCommas(g_iUserItemPrice[index]));
						
							g_bHasSkinTag[id][tItem] = true;
							g_szSkinsTag[id][tItem] = g_szSkinsTag[index][tItem];
							g_iNameTagSkinLevel[id][tItem] = g_iNameTagSkinLevel[index][tItem];

							g_bHasSkinTag[index][tItem] = false;
							g_szSkinsTag[index][tItem][0] = '0';
							g_iNameTagSkinLevel[index][tItem] = 0;
							save_skin_tags(id);
							save_skin_tags(index);
						}
					}
					else client_print_color(0, print_team_default, "^4%s^1 %L", CHAT_PREFIX, -1, "ITEM_BOUGHT", g_szName[id], szItem, g_szName[index]);
					
					g_iUserSellItem[index] = -1;
					g_bUserSellSkin[index] = false;
					g_bIsSelling[index] = false;
					g_iUserItemPrice[index] = 0;
					_ShowMarketMenu(id);

					AddStatistics(id, MARKET_ITEM_BOUGHT, 1, .line = __LINE__)
					AddStatistics(index, MARKET_ITEMS_SOLD, 1, .line = __LINE__)
				}	
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

publicItemOnMarket(id, bool:bPublicStt = false, type)
{
	g_bIsSelling[id] = true;
	g_iLastPlace[id] = get_systime(0)

	switch(type)
	{
		case SELL_SKIN:
		{
			new szItem[32], index = g_iUserSellItem[id];
			_GetItemName(index, szItem, charsmax(szItem))
			g_bUserSellSkin[id] = true;
			
			if(bPublicStt)
			{	
				if(g_bHasSkinTag[id][index])
				{
					client_print_color(0, print_team_default, "%s %l", CHAT_PREFIX, "SELL_ANNOUNCE_STT_NAMETAG",
					g_szName[id], szItem, g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic",
					g_szSkinsTag[id][index], AddCommas(g_iUserItemPrice[id]));
				}
				else
					client_print_color(0, id, "^4%s^1 %L", CHAT_PREFIX, id, "SELL_ANNOUNCE_STT", g_szName[id], szItem, AddCommas(g_iUserItemPrice[id]));
			}
			else
			{
				client_print_color(0, id, "^4%s %L", CHAT_PREFIX, id, "SELL_ANNOUNCE", g_szName[id], szItem, AddCommas(g_iUserItemPrice[id]));
			}
		}

		case SELL_CAPSULE:
		{
			client_print_color(0, print_team_default, "%s %l", CHAT_PREFIX, "SELL_ANNOUNCE_CAPSULE", g_szName[id],
			g_iMarketNameTagsRarity[id] == 1 ? "^4Common" : g_iMarketNameTagsRarity[id] == 2 ? "^4Rare" : "^3Mythic", AddCommas(g_iUserItemPrice[id]));
		}

		case SELL_GLOVE:
		{
			new eGlove[GLOVESINFO];
			ArrayGetArray(g_aGloves, g_iMarketGloveID[id], eGlove);
			client_print_color(0, print_team_default, "%s %l", CHAT_PREFIX, "SELL_ANNOUNCE_GLOVE", g_szName[id], eGlove[szGloveName], AddCommas(g_iUserItemPrice[id]));
		}
	}
}

show_market_gloves(id)
{
	new iMenu = menu_create(fmt("%s %l", MENU_PREFIX, "SELL_GLOVE_MENU_TITLE"), "show_market_gloves_handler");

	new szItem[64], eGlove[GLOVESINFO], szParseData[10], iCount;

	for(new i; i < MAX_GLOVES; i++)
	{
		if(g_iUserGloves[id][i] > 0)
		{
			ArrayGetArray(g_aGloves, i, eGlove);
			formatex(szItem, charsmax(szItem), "%s\r [%d]", eGlove[szGloveName], g_iUserGloves[id][i]);
			num_to_str(i, szParseData, charsmax(szParseData));
			menu_additem(iMenu, szItem, szParseData);

			iCount++
		}	
	}


	if(iCount == 0)
	{
		menu_additem(iMenu, fmt("%l", "NO_ITEMS"), "-1")
	}

	menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);

	if(is_user_connected(id))
	{
		menu_display(id, iMenu, 0, -1);
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public show_market_gloves_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		_ShowMarketMenu(id);
		return PLUGIN_HANDLED;
	}

	new szData[5];
	menu_item_getinfo(menu, item, _, szData, charsmax(szData), _, _, _);

	if(equal(szData, "-1"))
	{
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NO_ITEMS_CHAT")
		show_market_gloves(id)
		return PLUGIN_HANDLED
	}

	g_iMarketGloveID[id] = str_to_num(szData);
	g_bSellGlove[id] = true;
	g_iUserSellItem[id] = -1;
	g_bUserSellSkin[id] = false;
	g_bSellCapsule[id] = false;
	g_iUserItemPrice[id] = -1

	new eGlove[GLOVESINFO]
	ArrayGetArray(g_aGloves, g_iMarketGloveID[id], eGlove);

	client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "ITEM_SET_PRICE", eGlove[szGloveName]);

	client_cmd(id, "messagemode SkinPrice");

	return PLUGIN_CONTINUE;
}

show_market_name_tag_menu(id)
{
	new iMenu = menu_create(fmt("%s %l", MENU_PREFIX, "SELL_NAMETAG"), "sell_name_tag_menu_handler");
	new szItem[64], iid[5];
	
	iid[0] = 1;
	formatex(szItem, charsmax(szItem), fmt("%l", "SELL_NAMETAG_ITEM", "Common", g_iCommonNameTag[id]));
	menu_additem(iMenu, szItem, iid);

	iid[0] = 2;
	formatex(szItem, charsmax(szItem), fmt("%l", "SELL_NAMETAG_ITEM", "Rare", g_iRareNameTag[id]));
	menu_additem(iMenu, szItem, iid);

	iid[0] = 3;
	formatex(szItem, charsmax(szItem), fmt("%l", "SELL_NAMETAG_ITEM", "Mythic", g_iMythicNameTag[id]));
	menu_additem(iMenu, szItem, iid);


	menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);

	if(is_user_connected(id))
	{
		menu_display(id, iMenu, 0, -1)
	}
	else 
	{
		menu_destroy(iMenu)
	}
}

public sell_name_tag_menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		_ShowMarketMenu(id);
		return PLUGIN_HANDLED;
	}

	new szIndex[5];
	menu_item_getinfo(menu, item, _, szIndex, charsmax(szIndex), _, _, _);
	
	switch(szIndex[0])
	{
		case 1:
		{
			if(g_iCommonNameTag[id] < 1)
			{
				client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NOT_ENOUGH", "Common Name-Tags");
				_ShowMarketMenu(id);
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			if(g_iRareNameTag[id] < 1)
			{
				client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NOT_ENOUGH", "Rare Name-Tags");
				_ShowMarketMenu(id);
				return PLUGIN_HANDLED;
			}
		}

		case 3:
		{
			if(g_iMythicNameTag[id] < 1)
			{
				client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NOT_ENOUGH", "Mythic Name-Tags");
				_ShowMarketMenu(id);
				return PLUGIN_HANDLED;
			}
		}
	}

	g_iUserSellItem[id] = -1;
	g_bUserSellSkin[id] = false;
	g_bSellGlove[id] = false
	g_bSellCapsule[id] = true;
	g_iMarketNameTagsRarity[id] = szIndex[0];

	client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "SET_PRICE_NAMETAG", g_iMarketNameTagsRarity[id] == 1 ? "Common" : g_iMarketNameTagsRarity[id] == 2 ? "Rare" : "Mythic");

	client_cmd(id, "messagemode SkinPrice");

	return PLUGIN_CONTINUE;
}

_ShowItems(id)
{
	if(notAnySkins(id))
	{
		_ShowMainMenu(id);
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "NO_ITEMS_CHAT")
		return PLUGIN_HANDLED;
	}
	_ShowSkinMenu(id);
	return PLUGIN_CONTINUE;
}

openSellMenu(id, iWeaponId)
{
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "MENU_SKINS");
	new menu = menu_create(temp, "item_menu_handler", 0);
	new szItem[10];
	szItem[1] = 0;
	new total;
	new szSkin[32];
	new num;
	new i, wid;
	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i];
		if (0 < num)
		{
			wid = ArrayGetCell(g_aSkinWeaponID, i);
			if(wid != iWeaponId)
			{
				i++
				continue
			}
			
			ArrayGetString(g_aSkinName, i, szSkin, 31);
			formatex(temp, 63, "\r%s\w%s \r[%d]", g_bIsWeaponStattrak[id][i] ? "StatTrak " : "", szSkin, num);
			num_to_str(i, szItem, charsmax(szItem));
			menu_additem(menu, temp, szItem);
			total++;
		}
		i++;
	}
	if (!total)
	{
		formatex(temp, 63, "\d%L", id, "NO_ITEMS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp, szItem, 0, -1);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public item_menu_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		_ShowMarketMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	new index;

	new itemdata[5], dummy;
	menu_item_getinfo(menu, item, dummy, itemdata, charsmax(itemdata), {0}, 0, dummy);
	index = str_to_num(itemdata);
	if (index == NO_SKIN_VALUE)
	{
		_ShowMarketMenu(id);
		return PLUGIN_HANDLED
	}
	
	if(g_iWeaponIdToCheck[id] != ArrayGetCell(g_aSkinWeaponID, index))
	{
		_ShowMarketMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}

	
	g_iUserSellItem[id] = index;
	g_bSellCapsule[id] = false;
	g_bSellGlove[id] = false;
	g_bUserSellSkin[id] = true;
	
	new szItem[50], szSkinName[50];
	_GetItemName(index, szSkinName, charsmax(szSkinName));
	if(g_bIsWeaponStattrak[id][index])
	{
		if(g_iUserSkins[id][index] > 1)
		{
			askWhichType(id, index)
			g_iAskType[id] = 1
			return PLUGIN_HANDLED
		}
		else
		{
			g_bPublishedStattrakSkin[id] = true
		}

		if(g_bHasSkinTag[id][index])
		{
			formatex(szItem, charsmax(szItem), "StatTrak %s^3 (%s '%s')", szSkinName, 
			g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
		}
		else formatex(szItem, charsmax(szItem), "StatTrak %s", szSkinName);
	}
	else g_bPublishedStattrakSkin[id] = false
	
	client_print_color(id, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "ITEM_SET_PRICE", szItem);
	
	client_cmd(id, "messagemode SkinPrice");
	
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

public concmd_itemprice(id)
{
	new item = g_iUserSellItem[id];

	new data[16];
	read_args(data, 15);
	remove_quotes(data);
	new uPrice = str_to_num(data);

	if(g_bSellCapsule[id] == true)
	{
		g_iUserItemPrice[id] = str_to_num(data);
		_ShowMarketMenu(id)
		return PLUGIN_HANDLED;
	}

	if(g_bSellGlove[id])
	{
		new eGlove[GLOVESINFO];
		ArrayGetArray(g_aGloves, g_iMarketGloveID[id], eGlove)

		if(uPrice > eGlove[iMaxPrice] || uPrice < eGlove[iMinPrice])
		{
			g_iUserItemPrice[id] = 0;
			client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "PRICE_MUST_BE_BETWEEN", eGlove[szGloveName], AddCommas(eGlove[iMinPrice]), AddCommas(eGlove[iMaxPrice]));
			client_cmd(id, "messagemode SkinPrice");
			return PLUGIN_HANDLED;
		}

		g_iUserItemPrice[id] = str_to_num(data);
		_ShowMarketMenu(id);
		return PLUGIN_HANDLED
	}

	if (!_IsGoodItem(item))
	{
		return 1;
	}
	new wPriceMin;
	new wPriceMax;
	_CalcItemPrice(item, id, wPriceMin, wPriceMax);
	if (uPrice < wPriceMin || uPrice > wPriceMax)
	{
		new szSkinName[64]
		ArrayGetString(g_aSkinName, item, szSkinName, charsmax(szSkinName))
		client_print_color(id, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "PRICE_MUST_BE_BETWEEN", szSkinName, AddCommas(wPriceMin), AddCommas(wPriceMax));
		client_cmd(id, "messagemode SkinPrice");
		return 1;
	}

	g_iUserItemPrice[id] = uPrice;
	_ShowMarketMenu(id);
	return 1;
}

bool:_UserHasItem(id, item)
{
	if (!_IsGoodItem(item))
	{
		return false;
	}
	switch (item)
	{
		default:
		{
			if (0 < g_iUserSkins[id][item])
			{
				return true;
			}
		}
	}
	return false;
}

_CalcItemPrice(item, id, &min, &max)
{
	switch (item)
	{
		default:
		{
			min = ArrayGetCell(g_aSkinCostMin, item);
			new i = min;
			if(g_bIsWeaponStattrak[id][item] && g_bPublishedStattrakSkin[id])
			{
				if(g_bHasSkinTag[id][item])
				{
					switch(g_iNameTagSkinLevel[id][item])
					{
						case 1:
						{
							min = min * 2 + g_CvarCommonPrice
							i = i * 2 + g_CvarCommonPrice
						}
						case 2:
						{
							min = min * 2 + g_CvarRarePrice
							i = i * 2 + g_CvarRarePrice
						}
						case 3:
						{
							min = min * 2 + g_CvarMythicPrice
							i = i * 2 + g_CvarMythicPrice
						}
					}
				}
				else
				{
					min *= 2
					i *= 2	
				}	
			}
			max = i * 2;
		}
	}
	return PLUGIN_HANDLED;
}
_ShowDustbinMenu(id)
{
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "DESTROY_MENU");
	new menu = menu_create(temp, "dustbin_menu_handler", 0);
	new szItem[2];
	szItem[1] = 0;
	formatex(temp, 63, "\w%L^n%L", id, "GET_SCRAPS", id, "GET_SCRAPS_INFO");
	szItem[0] = 1;
	menu_additem(menu, temp, szItem, 0, -1);
	formatex(temp, 63, "\w%L^n%L", id, "GET_MONEY", id, "GET_MONEY_INFO");
	szItem[0] = 2;
	menu_additem(menu, temp, szItem, 0, -1);

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public dustbin_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[2];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, 1, {0}, 0, dummy);
	index = itemdata[0];
	
	new i, total, num
	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i];
		if (0 < num)
		{
			total++
		}
		i++
	}
	
	if(!total)
	{
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	g_iMenuType[id] = index;
	_ShowSkins(id);
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_ShowSkins(id)
{
	if(notAnySkins(id))
	{
		_ShowMainMenu(id);
		return
	}
	_ShowSkinMenu(id)
}

openDustbinSkins(id, iWeaponId)
{
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "MENU_SKINS");
	new menu = menu_create(temp, "db_skins_menu_handler", 0);
	new szItem[10];
	szItem[1] = 0;
	new szSkin[32];
	new num;
	new total;
	new i, wid;
	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i];
		if (0 < num)
		{
			wid = ArrayGetCell(g_aSkinWeaponID, i);
			if(wid != iWeaponId)
			{
				i++
				continue
			}
			ArrayGetString(g_aSkinName, i, szSkin, 31);
		
			formatex(temp, 63, "\r%s\w%s \r[%d]", g_bIsWeaponStattrak[id][i] ? "StatTrak " : "", szSkin, num);
			num_to_str(i, szItem, charsmax(szItem));
			menu_additem(menu, temp, szItem);
			total++;
		}
		i++;
	}
	if (!total)
	{
		formatex(temp, 63, "\r%L", id, "NO_ITEMS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp, szItem);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public db_skins_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowSkinMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[5];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, charsmax(itemdata), {0}, 0, dummy);
	index = str_to_num(itemdata);
	if (index == NO_SKIN_VALUE)
	{
		_ShowSkinMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	if(index == g_iUserSellItem[id])
	{

		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CURRENTLY_SELLING");
		_ShowDustbinMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}	
	if(g_bIsWeaponStattrak[id][index])
	{
		if(1 <= g_iMenuType[id] <= 2)
		{
			if(g_iUserSkins[id][index] > 1)
			{
				askWhichType(id, index)
				g_iAskType[id] = 3
				return PLUGIN_HANDLED
			}
			else
			{
				g_bDestroyStt[id] = true
			}
		}
	}
	if(g_iWeaponIdToCheck[id] != ArrayGetCell(g_aSkinWeaponID, index))
	{
		_ShowSkins(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	destroySkin(id, index)
	_ShowDustbinMenu(id);
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

destroySkin(id, index)
{
	g_iUserSkins[id][index]--;
	new Skin[102];
	ArrayGetString(g_aSkinName, index, Skin, charsmax(Skin));

	switch (g_iMenuType[id])
	{
		case 1:
		{
			new iScraps = c_DustForTransform
			
			if(g_bDestroyStt[id])
			{
				if(g_bHasSkinTag[id][index])
				{
					iScraps += g_CvarScrapsDestroyNameTagSkin;

					formatex(Skin, charsmax(Skin), "%s^3 (%s '%s')",
					Skin, g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
				
					g_bHasSkinTag[id][index] = false;
					g_szSkinsTag[id][index][0] = '0';
					g_iNameTagSkinLevel[id][index] = 0;

					save_skin_tags(id)
				}	

				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRANSFORM_STT", iScraps, iScraps > 1 ? "s" : "", Skin);
				
				g_iUserStattrakKillCount[id][index] = 0
				g_bIsWeaponStattrak[id][index] = false
			}
			else client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRANSFORM", iScraps, iScraps > 1 ? "s" : "", Skin);
			
			g_iUserScraps[id] += iScraps;
			AddStatistics(id, RECEIVED_SCRAPS, iScraps, .line = __LINE__)
		}
		case 2:
		{	
			new sPrice = ArrayGetCell(g_aSkinCostMin, index);
			new rest = sPrice / c_ReturnPercent;

			if(g_bDestroyStt[id])
			{
				rest *= 3
				
				g_iUserStattrakKillCount[id][index] = 0
				g_bIsWeaponStattrak[id][index] = false

				if(g_bHasSkinTag[id][index])
				{
					formatex(Skin, charsmax(Skin), "%s^3 (%s '%s')",
					Skin, g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
				
					rest += g_CvarMoneyDestroyNameTagSkin;
					g_bHasSkinTag[id][index] = false;
					g_szSkinsTag[id][index][0] = '0';
					g_iNameTagSkinLevel[id][index] = 0;

					save_skin_tags(id)
				}

				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "DESTROY_STT", Skin, rest);
			}
			else client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "DESTROY", Skin, rest);
			
			g_iUserMoney[id] += rest;
			AddStatistics(id, RECEIVED_MONEY, rest, .line = __LINE__)
		}
	}
	
	g_bDestroyStt[id] = false
	g_iMenuType[id] = 0;
}

_ShowGiftMenu(id)
{
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "GIFT_MENU");
	new menu = menu_create(temp, "gift_menu_handler", 0);
	new bool:HasTarget;
	new bool:HasItem;
	new target = g_iGiftTarget[id];
	if (target)
	{
		formatex(temp, 63, "\w%L", id, "GIFT_TARGET", g_szName[target]);
		menu_additem(menu, temp);
		
		HasTarget = true;
	}
	else
	{
		formatex(temp, 63, "\r%L", id, "GIFT_SELECT_TARGET");
		menu_additem(menu, temp);
	}
	if (!_IsGoodItem(g_iGiftItem[id]))
	{
		formatex(temp, 63, "\r%L^n", id, "GIFT_SELECT_ITEM");
		menu_additem(menu, temp);
	}
	else
	{
		new Item[32];
		_GetItemName(g_iGiftItem[id], Item, 31);

		if(g_bGiftingStt[id] && !g_bHasSkinTag[id][g_iGiftItem[id]])
		{
			formatex(temp, 63, "\r%s\w%s^n", g_bGiftingStt[id] ? "StatTrak " : "", Item);
		}
		else if (g_bGiftingStt[id] && g_bHasSkinTag[id][g_iGiftItem[id]])
		{
			formatex(temp, 63, "%s\r (%s '%s') ^n",
			Item, g_iNameTagSkinLevel[id][g_iGiftItem[id]] == 1 ? "Common" : g_iNameTagSkinLevel[id][g_iGiftItem[id]] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][g_iGiftItem[id]]);
		}
		else 
		{
			formatex(temp, 63, "%s^n", Item);
		}

		menu_additem(menu, temp);
		HasItem = true;
	}
	if (HasTarget && HasItem)
	{
		formatex(temp, 63, "\r%L", id, "GIFT_SEND");
		menu_additem(menu, temp);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public gift_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	switch (item)
	{
		case 0:
		{
			_SelectTarget(id);
		}
		case 1:
		{
			_SelectItem(id);
		}
		case 2:
		{
			new target = g_iGiftTarget[id];
			new _item = g_iGiftItem[id];
			if (g_bLogged[target] != true || !(0 < target && 32 >= target))
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "INVALID_TARGET", g_szName[id]);
				g_iGiftTarget[id] = 0;
				_ShowGiftMenu(id);
			}
			else
			{
				if (!_UserHasItem(id, _item))
				{
					client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "NO_LONGER");
					g_iGiftItem[id] = -1;
					_ShowGiftMenu(id);
				}
				giftPlayer(id, target, _item)

				g_iGiftTarget[id] = 0;
				g_iGiftItem[id] = -1;
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

giftPlayer(id, target, iSkin)
{		
	if(g_iUserSkins[target][iSkin] >= SKIN_LIMIT)
	{
		client_print_color(id, id, "^4%s %L", CHAT_PREFIX, id, "CANT_RECEIVE", g_szName[target]);
		_ShowGiftMenu(id);
		return PLUGIN_HANDLED
	}
			
	new Skin[32];
	_GetItemName(iSkin, Skin, 31);
						
	if(g_bGiftingStt[id])
	{
		if(g_bHasSkinTag[id][iSkin])
		{
			client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "SEND_GIFT_STT_NAMETAG",
			Skin, g_iNameTagSkinLevel[id][iSkin] == 1 ? "Common" : g_iNameTagSkinLevel[id][iSkin] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][iSkin], g_szName[target]);
			client_print_color(target, print_team_default, "%s %l", CHAT_PREFIX, "RECEIVE_GIFT_STT_NAMETAG",
			g_szName[id], Skin, g_iNameTagSkinLevel[id][iSkin] == 1 ? "Common" : g_iNameTagSkinLevel[id][iSkin] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][iSkin]);

			if(g_bHasSkinTag[target][iSkin] && (g_iNameTagSkinLevel[target][iSkin] > g_iNameTagSkinLevel[id][iSkin]))
			{
				client_print_color(target, print_team_default, "%s %l", CHAT_PREFIX, "RECEIVE_ALREADY_NAMETAG",
				g_iNameTagSkinLevel[target][iSkin] == 1 ? "Common" : g_iNameTagSkinLevel[target][iSkin] == 2 ? "Rare" : "Mythic");
			}
			else 
			{
				g_szSkinsTag[target][iSkin] = g_szSkinsTag[id][iSkin];
				g_iNameTagSkinLevel[target][iSkin] = g_iNameTagSkinLevel[id][iSkin];
				g_bHasSkinTag[target][iSkin] = true;
			}

			g_szSkinsTag[id][iSkin][0] = '0';
			g_iNameTagSkinLevel[id][iSkin] = 0;
			g_bHasSkinTag[id][iSkin] = false;
			
			save_skin_tags(id);
			save_skin_tags(target)
		}
		else 
		{
			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "SEND_GIFT_STT", Skin, g_szName[target]);
			client_print_color(target, target, "^4%s^1 %L", CHAT_PREFIX, id, "RECEIVE_GIFT_STT", g_szName[id], Skin);
		}

		g_iUserStattrakKillCount[id][iSkin] = 0

		g_bIsWeaponStattrak[target][iSkin] = true
		g_bIsWeaponStattrak[id][iSkin] = false
	}
	else
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "SEND_GIFT", Skin, g_szName[target]);
		client_print_color(target, target, "^4%s^1 %L", CHAT_PREFIX, target, "RECEIVE_GIFT", g_szName[id], Skin);
	}
	
	g_iUserSkins[id][iSkin]--;
	g_iUserSkins[target][iSkin]++;
	
	AddStatistics(id, TOTAL_GIFTS, 1, .line = __LINE__)

	checkInstantDefault(id, iSkin)
			
	g_bGiftingStt[id] = false
	
	return PLUGIN_HANDLED
}

_SelectTarget(id)
{
	new temp[64];
	formatex(temp, 63, "\r%s \y%L", MENU_PREFIX, id, "GIFT_SELECT_TARGET");
	new menu = menu_create(temp, "st_menu_handler", 0);
	new szItem[10];
	szItem[1] = 0;
	new Pl[32];
	new n;
	new p;
	get_players(Pl, n, "h", "");
	new total;
	if (n)
	{
		new i;
		while (i < n)
		{
			p = Pl[i];
			if (g_bLogged[p])
			{
				if (!(p == id))
				{
					szItem[0] = p;
					menu_additem(menu, g_szName[p], szItem, 0, -1);
					total++;
				}
			}
			i++;
		}
	}
	if (!total)
	{
		formatex(temp, 63, "\r%L", id, "NO_REGISTERED_PLAYERS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public st_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowGiftMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[2];
	new dummy;
	new index;
	new name[32];
	menu_item_getinfo(menu, item, dummy, itemdata, 1, name, 31, dummy);
	index = itemdata[0];
	switch (index)
	{
		case NO_SKIN_VALUE:
		{
			_ShowGiftMenu(id);
			menu_destroy(menu)
			return PLUGIN_HANDLED;
		}
		default:
		{	
			g_iGiftTarget[id] = index;
			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "GIFT_YOUR_TARGET", name);
			_ShowGiftMenu(id);
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_SelectItem(id)
{
	if(notAnySkins(id))
	{
		_ShowMainMenu(id);
		return
	}
	_ShowSkinMenu(id)
}

openGiftMenu(id, iWeaponId)
{
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "MENU_SKINS");
	new menu = menu_create(temp, "si_menu_handler", 0);
	new szItem[10];
	szItem[1] = 0;
	new total;
	new szSkin[32];
	new num;
	new i, wid;
	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i];
		if (0 < num)
		{
			wid = ArrayGetCell(g_aSkinWeaponID, i);
			if(wid != iWeaponId)
			{
				i++
				continue
			}
			
			ArrayGetString(g_aSkinName, i, szSkin, 31);

			formatex(temp, 63, "\r%s\w%s \r[%d]", g_bIsWeaponStattrak[id][i] ? "StatTrak " : "", szSkin, num);
			
			num_to_str(i, szItem, charsmax(szItem));			
			menu_additem(menu, temp, szItem);

			total++;
		}
		i++;
	}
	if (!total)
	{
		formatex(temp, 63, "\r%L", id, "NO_ITEMS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp, szItem, 0, -1);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public si_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[5];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, charsmax(itemdata), {0}, 0, dummy);
	index = str_to_num(itemdata);
	switch (index)
	{
		case NO_SKIN_VALUE:
		{
			_ShowGiftMenu(id);
			menu_destroy(menu)
			return PLUGIN_HANDLED;
		}
		default:
		{
			if (index == g_iUserSellItem[id] && g_bUserSellSkin[id])
			{
				new Item[50];
				_GetItemName(g_iUserSellItem[id], Item, charsmax(Item));
				
				if(g_bPublishedStattrakSkin[id])
				{
					if(g_bHasSkinTag[id][index])
					{
						formatex(Item, charsmax(Item), "%s^3 (%s '%s')",
						Item, g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
					}	
					else formatex(Item, charsmax(Item), "StatTrak %s", Item)
				}
				client_print_color(id, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "INVALID_GIFT", Item);
				_SelectItem(id);
			}
			else
			{
				if(g_iWeaponIdToCheck[id] != ArrayGetCell(g_aSkinWeaponID, index))
				{
					_ShowGiftMenu(id);
					menu_destroy(menu)
					return PLUGIN_HANDLED;
				}
	
				g_iGiftItem[id] = index;
				if(g_bIsWeaponStattrak[id][index])
				{
					if(g_iUserSkins[id][index] > 1)
					{
						askWhichType(id, index)
						g_iAskType[id] = 2
						return PLUGIN_HANDLED
					}
					g_bGiftingStt[id] = true
					_ShowGiftMenu(id);
				}
				else
				{
					g_bGiftingStt[id] = false
					
					new szItem[32];
					_GetItemName(index, szItem, 31);
					client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "GIFT_YOUR_GIFT", szItem);
					_ShowGiftMenu(id);
				}
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_ShowTradeMenu(id)
{
	if (g_bTradeAccept[id])
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_INFO2");
		return
	}
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "TRADE_MENU");
	new menu = menu_create(temp, "trade_menu_handler", 0);
	new szItem[2];
	szItem[1] = 0;
	new bool:HasTarget;
	new bool:HasItem;
	new target = g_iTradeTarget[id];
	if (target)
	{
		formatex(temp, 63, "\w%L", id, "GIFT_TARGET", g_szName[target]);
		szItem[0] = 0;
		menu_additem(menu, temp, szItem, 0, -1);
		HasTarget = true;
	}
	else
	{
		formatex(temp, 63, "\r%L", id, "GIFT_SELECT_TARGET");
		szItem[0] = 0;
		menu_additem(menu, temp, szItem, 0, -1);
	}

	if (!_IsGoodItem(g_iTradeItem[id]))
	{
		formatex(temp, 63, "\r%L^n", id, "GIFT_SELECT_ITEM");
		szItem[0] = 1;
		menu_additem(menu, temp, szItem, 0, -1);
	}
	else
	{
		new Item[32];
		_GetItemName(g_iTradeItem[id], Item, 31);
		
		if(!g_bHasSkinTag[id][g_iTradeItem[id]])
		{
			formatex(temp, 63, "\r%s\w%s^n", g_bTradingStt[id] ? "StatTrak " : "", Item);
		}
		else 
		{
			formatex(temp, charsmax(temp), "%s\r (%s '%s')",
			Item, g_iNameTagSkinLevel[id][g_iTradeItem[id]] == 1 ? "Common" : g_iNameTagSkinLevel[id][g_iTradeItem[id]] == 2 ? "Rare" : "Mythic",
			g_szSkinsTag[id][g_iTradeItem[id]]);
		}
		szItem[0] = 1;
		menu_additem(menu, temp, szItem, 0, -1);
		HasItem = true;
	}
	
	if (HasTarget && HasItem)
	{
		formatex(temp, 63, "\r%L", id, "TRADE_SEND_OFFER");
		szItem[0] = 2;
		menu_additem(menu, temp, szItem, 0, -1);
	}
	
	if (g_bTradeActive[id] || g_bTradeSecond[id])
	{
		formatex(temp, 63, "\r%L", id, "TRADE_CANCEL");
		szItem[0] = 3;
		menu_additem(menu, temp, szItem, 0, -1);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public trade_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		if (g_bTradeSecond[id])
		{
			clcmd_say_deny(id);
		}
		_ShowMainMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[2];
	new index;
	menu_item_getinfo(menu, item, _, itemdata, charsmax(itemdata), _, _, _);
	index = itemdata[0];
	switch (index)
	{
		case 0:
		{
			if (g_bTradeActive[id] || g_bTradeSecond[id])
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_LOCKED");
				_ShowTradeMenu(id);
			}
			else
			{
				_SelectTradeTarget(id);
			}
		}
		case 1:
		{
			if (g_bTradeActive[id] && !g_bTradeSecond[id])
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_LOCKED");
				_ShowTradeMenu(id);
			}
			else
			{
				_SelectTradeItem(id);
			}
		}
		case 2:
		{
			new target = g_iTradeTarget[id];
			new _item = g_iTradeItem[id];
			if (!g_bLogged[target] || !(0 < target && 32 >= target))
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "INVALID_TARGET");
				_ResetTradeData(id);
				_ShowTradeMenu(id);
			}
			else
			{
				if (!_UserHasItem(id, _item))
				{
					client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "NO_LONGER");
					g_iTradeItem[id] = -1;
					_ShowTradeMenu(id);
					return PLUGIN_HANDLED
				}
				if (g_bTradeSecond[id] && !_UserHasItem(target, g_iTradeItem[target]))
				{
					client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_FAILED");
					client_print_color(target, target, "^4%s^1 %L", CHAT_PREFIX, target, "TRADE_FAILED");
					_ResetTradeData(id);
					_ResetTradeData(target);
					_ShowTradeMenu(id);
					return PLUGIN_HANDLED
				}
				
				if(g_iUserSkins[target][_item] >= SKIN_LIMIT)
				{
					client_print_color(id, id, "^4%s %L", CHAT_PREFIX, id, "CANT_RECEIVE", g_szName[target]);
					_ShowGiftMenu(id);
					_ShowTradeMenu(id)
					return PLUGIN_HANDLED
				}
	
				g_bTradeActive[id] = 1;
				g_iTradeRequest[target] = id;

				new szItem[50], index = g_iTradeItem[id];
				_GetItemName(index, szItem, charsmax(szItem));
				
				if(g_bTradingStt[id])
				{
					if(!g_bHasSkinTag[id][index])
					{
						formatex(szItem, charsmax(szItem), "StatTrak %s", szItem)
					}
					else 
					{
						formatex(szItem, charsmax(szItem), "%s^3 (%s '%s')", szItem, 
						g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
					}
				}
				
				if (!g_bTradeSecond[id])
				{
					client_print_color(target, target, "^4%s^1 %L", CHAT_PREFIX, target, "TRADE_INFO1", g_szName[id], szItem);
					client_print_color(target, target, "^4%s^1 %L", CHAT_PREFIX, target, "TRADE_INFO2");
				}
				else
				{
					if(g_iUserSkins[id][_item] >= SKIN_LIMIT)
					{
						client_print_color(id, id, "^4%s %L", CHAT_PREFIX, id, "CANT_RECEIVE", g_szName[id]);
						_ShowTradeMenu(target)
						return PLUGIN_HANDLED
					}
				
					new yItem[50], index = g_iTradeItem[target];
					_GetItemName(g_iTradeItem[target], yItem, charsmax(yItem));
					
					if(!g_bHasSkinTag[target][index])
					{
						formatex(yItem, charsmax(yItem), "StatTrak %s", yItem)
					}
					else 
					{
						formatex(yItem, charsmax(yItem), "%s^3 (%s '%s')", yItem, 
						g_iNameTagSkinLevel[target][index] == 1 ? "Common" : g_iNameTagSkinLevel[target][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[target][index]);
					}

					client_print_color(target, print_team_default, "^4%s %L", CHAT_PREFIX, target, "TRADE_INFO3", g_szName[id], szItem, yItem);
					client_print_color(target, print_team_default, "^4%s^1 %L", CHAT_PREFIX, target, "TRADE_INFO2");
					g_bTradeAccept[target] = 1;
				}
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_SEND", g_szName[target]);
			}
		}
		case 3:
		{
			if (g_bTradeSecond[id])
			{
				clcmd_say_deny(id);
			}
			else
			{
				_ResetTradeData(id);
			}
			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_CANCELED");
			_ShowTradeMenu(id);
		}
		default:
		{
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_SelectTradeTarget(id)
{
	new temp[64];
	formatex(temp, 63, "\r%s %L", MENU_PREFIX, id, "GIFT_SELECT_TARGET");
	new menu = menu_create(temp, "tst_menu_handler", 0);
	new szItem[10];
	szItem[1] = 0;
	new Pl[32];
	new n;
	new p;
	get_players(Pl, n, "h", "");
	new total;
	if (n)
	{
		new i;
		while (i < n)
		{
			p = Pl[i];
			if (g_bLogged[p])
			{
				if (!(p == id))
				{
					szItem[0] = p;
					menu_additem(menu, g_szName[p], szItem, 0, -1);
					total++;
				}
			}
			i++;
		}
	}
	if (!total)
	{
		formatex(temp, 63, "\r%L", id, "NO_REGISTERED_PLAYERS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp, szItem, 0, -1);
	}
	
	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public tst_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		if(is_user_connected(id))
			_ShowTradeMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[2];
	new dummy;
	new index;
	new name[32];
	menu_item_getinfo(menu, item, dummy, itemdata, 1, name, 31, dummy);
	index = itemdata[0];
	switch (index)
	{
		case NO_SKIN_VALUE:
		{
			_ShowMainMenu(id);
			menu_destroy(menu)
			return PLUGIN_HANDLED;
		}
		default:
		{
			if (g_iTradeRequest[index])
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TARGET_TRADE_ACTIVE", name);
			}
			else
			{
				g_iTradeTarget[id] = index;
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_TARGET", name);
			}
			_ShowTradeMenu(id);
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_SelectTradeItem(id)
{
	if(notAnySkins(id))
	{
		_ShowMainMenu(id);
		return
	}
	_ShowSkinMenu(id)
}

openTradeMenu(id, iWeaponId)
{
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "MENU_SKINS");
	new menu = menu_create(temp, "tsi_menu_handler", 0);
	new szItem[10];
	szItem[1] = 0;
	new total;
	new szSkin[32];
	new num;
	new i, wid;
	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i];
		if (0 < num)
		{
			wid = ArrayGetCell(g_aSkinWeaponID, i);
			if(wid != iWeaponId)
			{
				i++
				continue
			}
			
			ArrayGetString(g_aSkinName, i, szSkin, 31);
			formatex(temp, 63, "\r%s\w%s \r[%d]", g_bIsWeaponStattrak[id][i] ? "StatTrak " : "", szSkin, num);
			num_to_str(i, szItem, charsmax(szItem));
			menu_additem(menu, temp, szItem, 0, -1);
			total++;
		}
		i++;
	}
	if (!total)
	{
		formatex(temp, 63, "\r%L", id, "NO_ITEMS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp, szItem, 0, -1);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu)
	}
	else 
	{
		menu_destroy(menu)
	}
}

public tsi_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowTradeMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[5];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, charsmax(itemdata), {0}, 0, dummy);
	index = str_to_num(itemdata);
	switch (index)
	{
		case NO_SKIN_VALUE:
		{
			_ShowTradeMenu(id);
			menu_destroy(menu)
			return PLUGIN_HANDLED;
		}
		default:
		{
			if (index == g_iUserSellItem[id] && g_bUserSellSkin[id])
			{
				new Item[50], index = g_iUserSellItem[id];
				_GetItemName(index, Item, charsmax(Item));
				
				if(g_bPublishedStattrakSkin[id])
				{
					if(!g_bHasSkinTag[id][index])
					{
						formatex(Item, charsmax(Item), "StatTrak %s", Item)
					}
					else
					{
						formatex(Item, charsmax(Item), "%s^3 (%s '%s')^1", Item, 
						g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
					}
				}
				
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_INVALID_ITEM", Item);
				_SelectTradeItem(id);
			}
			else
			{
				if(g_iWeaponIdToCheck[id] != ArrayGetCell(g_aSkinWeaponID, index))
				{
					_SelectTradeItem(id)
					menu_destroy(menu)
					return PLUGIN_HANDLED
				}
				g_iTradeItem[id] = index
	
				if(g_bIsWeaponStattrak[id][index])
				{
					if(g_iUserSkins[id][index] > 1)
					{
						askWhichType(id, index)
						g_iAskType[id] = 4
						return PLUGIN_HANDLED
					}
					else
					{
						g_bTradingStt[id] = true
					}
				}
				else g_bTradingStt[id] = false
				
				new szItem[32];
				_GetItemName(index, szItem, 31);
				if(g_bTradingStt[id])
				{
					if(!g_bHasSkinTag[id][index])
					{
						client_print_color(id, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_ITEM_STT", szItem);
					}
					else 
					{
						client_print_color(id, print_team_default, "^4[CSGO Classy]^1 You choosed^4 %s^3 (%s '%s')^1 to be offered in the^4 trade offer", szItem, 
						g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
					}
				}
				else client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_ITEM", szItem);
				_ShowTradeMenu(id);
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_ResetTradeData(id)
{
	g_bTradeActive[id] = 0;
	g_bTradeSecond[id] = 0;
	g_bTradeAccept[id] = 0;
	g_iTradeTarget[id] = 0;
	g_iTradeItem[id] = -1;
	g_iTradeRequest[id] = 0;
	
	g_bTradingStt[id] = false
}

public clcmd_say_accept(id)
{
	new sender = g_iTradeRequest[id];
	if (1 > sender || 32 < sender)
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "DONT_HAVE_TRADE");
		return 1;
	}
	if (!g_bLogged[sender] || !(0 < sender && 32 >= sender))
	{
		_ResetTradeData(id);
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_INVALID_SENDER");
		return 1;
	}
	if (!g_bTradeActive[sender] && id == g_iTradeTarget[sender])
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_IS_CANCELED", g_iTradeRequest[id]);
		_ResetTradeData(id);
		return 1;
	}

	if (g_bTradeAccept[id])
	{
		new sItem = g_iTradeItem[sender];
		new tItem = g_iTradeItem[id];
		if (!_UserHasItem(id, tItem) || !_UserHasItem(sender, sItem))
		{
			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_FAILED2");
			client_print_color(sender, sender, "^4%s^1 %L", CHAT_PREFIX, sender, "TRADE_FAILED2");
			_ResetTradeData(id);
			_ResetTradeData(sender);
			return 1;
		}
		switch (sItem)
		{
			default:
			{
				g_iUserSkins[id][sItem]++;
				g_iUserSkins[sender][sItem]--;
			}
		}
		switch (tItem)
		{
			default:
			{
				g_iUserSkins[id][tItem]--;
				g_iUserSkins[sender][tItem]++;
			}
		}
		
		checkInstantDefault(sender, sItem)
		checkInstantDefault(id, tItem)
	
		new sItemsz[100];
		new tItemsz[100];
		_GetItemName(tItem, tItemsz, charsmax(tItemsz));
		_GetItemName(sItem, sItemsz, charsmax(sItemsz));

		new sender_level, target_level, bool:sender_nametag, bool:target_nametag, sender_tag[MAX_SKIN_TAG_LENGTH + 1], target_tag[MAX_SKIN_TAG_LENGTH];
		
		sender_level = g_iNameTagSkinLevel[sender][sItem];
		sender_nametag = g_bHasSkinTag[sender][sItem];
		formatex(sender_tag, charsmax(sender_tag), "%s", g_szSkinsTag[sender][sItem])
		
		target_level = g_iNameTagSkinLevel[id][tItem];
		target_nametag = g_bHasSkinTag[id][tItem];
		formatex(target_tag, charsmax(sender_tag), "%s", g_szSkinsTag[id][tItem])

		if(g_bTradingStt[sender])
		{
			g_bIsWeaponStattrak[sender][sItem] = false
			g_iUserStattrakKillCount[sender][sItem] = 0
			g_bIsWeaponStattrak[id][sItem] = true
			
			if(!g_bHasSkinTag[sender][sItem])
				formatex(sItemsz, charsmax(sItemsz), "StatTrak %s", sItemsz)
			else 
			{
				formatex(sItemsz, charsmax(sItemsz), "%s^3 (%s '%s')", sItemsz,
				g_iNameTagSkinLevel[sender][sItem] == 1 ? "Common" : g_iNameTagSkinLevel[sender][sItem] == 2 ? "Rare" : "Mythic", g_szSkinsTag[sender][sItem]);
			
				g_iNameTagSkinLevel[id][sItem] = sender_level;
				g_bHasSkinTag[id][sItem] = sender_nametag;
				g_szSkinsTag[id][sItem] = sender_tag;

				g_iNameTagSkinLevel[sender][sItem] = 0;
				g_bHasSkinTag[sender][sItem] = false;
				g_szSkinsTag[sender][sItem][0] = '0';
				
			}
		}
		
		if(g_bTradingStt[id])
		{
			g_bIsWeaponStattrak[id][tItem] = false
			g_iUserStattrakKillCount[id][tItem] = 0
			g_bIsWeaponStattrak[sender][tItem] = true
			
			if(!g_bHasSkinTag[id][tItem])
				formatex(tItemsz, charsmax(tItemsz), "StatTrak %s", tItemsz)
			else 
			{
				formatex(tItemsz, charsmax(tItemsz), "%s^3 (%s '%s')", tItemsz,
				g_iNameTagSkinLevel[id][tItem] == 1 ? "Common" : g_iNameTagSkinLevel[id][tItem] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][tItem]);
			
				g_iNameTagSkinLevel[sender][tItem] = target_level;
				g_bHasSkinTag[sender][tItem] = target_nametag;
				g_szSkinsTag[sender][tItem] = target_tag;

				g_iNameTagSkinLevel[id][tItem] = 0;
				g_bHasSkinTag[id][tItem] = false;
				g_szSkinsTag[id][tItem][0] = '0';
			}
		}

		
		client_print_color(id, print_team_default, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_SUCCESS", tItemsz, sItemsz);
		client_print_color(sender, print_team_default, "^4%s^1 %L", CHAT_PREFIX, sender, "TRADE_SUCCESS", sItemsz, tItemsz);
		
		g_bTradingStt[id] = false;
		g_bTradingStt[sender] = false;
	
		_ResetTradeData(id);
		_ResetTradeData(sender);

		AddStatistics(id, TOTAL_TRADES, 1, .line = __LINE__)
		AddStatistics(sender, TOTAL_TRADES, 1, .line = __LINE__)
	}
	else
	{
		if (!g_bTradeSecond[id])
		{
			g_iTradeTarget[id] = sender;
			g_iTradeItem[id] = -1;
			g_bTradeSecond[id] = 1;

			g_iMenuToOpen[id] = 6
			_ShowTradeMenu(id);
		}
	}
	
	return 1;
}

public clcmd_say_deny(id)
{
	new sender = g_iTradeRequest[id];
	if (sender < 1 || sender > 32)
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "DONT_HAVE_TRADE");
		return 1;
	}
	if (!g_bLogged[sender] || !(0 < sender && 32 >= sender))
	{
		_ResetTradeData(id);
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_INVALID_SENDER");
		return 1;
	}
	if (!g_bTradeActive[sender] && id == g_iTradeTarget[sender])
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_IS_CANCELED");
		_ResetTradeData(id);
		return 1;
	}
	_ResetTradeData(id);
	_ResetTradeData(sender);
	client_print_color(sender, sender, "^4%s^1 %L", CHAT_PREFIX, sender, "TRADE_REFUSE_TARGET", g_szName[id]);
	client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "TRADE_REFUSE_SENDER", g_szName[sender]);
	return 1;
}

_ShowGamesMenu(id)
{
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "GAMBLING");
	new menu = menu_create(temp, "games_menu_handler", 0);
	new szItem[2];
	szItem[1] = 0;

	formatex(temp, 63, "\w%L", id, "GAME_RAFFLE", c_TombolaCost);
	menu_additem(menu, temp, "0");

	formatex(temp, 63, "\w%L", id, "GAME_ROULETTE");
	menu_additem(menu, temp, "1");

	formatex(temp, 63, "\w%L", id, "GAME_JACKPOT");
	menu_additem(menu, temp, "2");

	formatex(temp, 63, "\w%L", id, "GAME_COINFLIP");
	menu_additem(menu, temp, "3");
	
	addDynamicMenus(id, menu, MenuCode:MENU_GAMBLING)

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public games_menu_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		_ShowMainMenu(id)
		return
	}

	new szMenuInfo[4]
	menu_item_getinfo(menu, item, _, szMenuInfo, charsmax(szMenuInfo), _, _, _)
	new iMenuInfo = str_to_num(szMenuInfo)

	switch (item)
	{
		case 0:
		{
			_ShowTombolaMenu(id);
		}
		case 1:
		{
			new money = g_iUserMoney[id];
			if (money < g_iRouletteCost)
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "NOT_ENOUGH_MONEY", g_iRouletteCost - money);
				_ShowGamesMenu(id);
			}
			else
			{
				if (g_bRoulettePlay[id])
				{
					client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "ROULETTE_NEXT");
					_ShowGamesMenu(id);
				}
				else
				{
					_ShowRouletteMenu(id);
				}
			}
		}
		case 2:
		{
			if (g_bJackpotWork)
			{
				g_iMenuToOpen[id] = 7
				_ShowJackpotMenu(id);
			}
			else
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "JACKPOT_UNAVAIBLE", c_JackpotTimer);
				_ShowGamesMenu(id);
			}
		}
		case 3: 
		{
			g_iMenuToOpen[id] = 2
			_ShowCFMenu(id)
		}
		default:
		{
			ExecuteForward(g_eForwards[MENU_ITEM_SELECTED], _, id, _:MENU_GAMBLING, iMenuInfo)
		}
	}
	menu_destroy(menu)
	return
}

_ShowTombolaMenu(id)
{
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "RAFFLE_MENU");
	new menu = menu_create(temp, "tombola_menu_handler", 0);
	new szItem[2];
	szItem[1] = 0;
	new Timer[32];
	_FormatTime(Timer, 31, g_iNextTombolaStart);
	formatex(temp, 63, "\w%L", id, "COUNTDOWN", Timer);
	szItem[0] = 0;
	menu_additem(menu, temp, szItem, 0, -1);
	formatex(temp, 63, "\w%L", id, "RAFFLE_PLAYERS", g_iTombolaPlayers);
	szItem[0] = 0;
	menu_additem(menu, temp, szItem, 0, -1);
	formatex(temp, 63, "\w%L^n", id, "RAFFLE_TOTAL_BET", g_iTombolaPrize);
	szItem[0] = 0;
	menu_additem(menu, temp, szItem, 0, -1);
	if (g_bUserPlay[id])
	{
		formatex(temp, 63, "\r%L", id, "RAFFLE_ALREADY_JOINED");
		szItem[0] = 0;
		menu_additem(menu, temp, szItem, 0, -1);
	}
	else
	{
		formatex(temp, 63, "\r%L \r[%d$]", id, "RAFFLE_JOIN", c_TombolaCost);
		szItem[0] = 1;
		menu_additem(menu, temp, szItem, 0, -1);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

_FormatTime(timer[], len, nextevent)
{
	new seconds = nextevent - get_systime(0);
	new minutes;
	while (seconds >= 60)
	{
		seconds += -60;
		minutes++;
	}
	new bool:add_before;
	new temp[32];
	if (seconds)
	{
		new second[64];
		if (seconds == 1)
		{
			formatex(second, 63, "%L", 0, "TEXT_SECOND");
		}
		else
		{
			formatex(second, 63, "%L", 0, "TEXT_SECONDS");
		}
		formatex(temp, 31, "%d %s", seconds, second);
		add_before = true;
	}
	if (minutes)
	{
		if (add_before)
		{
			new minute[64];
			if (minutes == 1)
			{
				formatex(minute, 63, "%L", 0, "TEXT_MINUTE");
			}
			else
			{
				formatex(minute, 63, "%L", 0, "TEXT_MINUTES");
			}
			format(temp, 31, "%d %s and %s", minutes, minute, temp);
		}
		else
		{
			new minute[64];
			if (minutes == 1)
			{
				formatex(minute, 63, "%L", 0, "TEXT_MINUTE");
			}
			else
			{
				formatex(minute, 63, "%L", 0, "TEXT_MINUTES");
			}
			formatex(temp, 31, "%d %s", minutes, minute);
			add_before = true;
		}
	}
	if (add_before)
	{
		formatex(timer, len, "%s", temp);
	}
	return PLUGIN_HANDLED;
}

public tombola_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowGamesMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[2];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, 1, {0}, 0, dummy);
	index = itemdata[0];
	switch (index)
	{
		case 0:
		{
			_ShowTombolaMenu(id);
		}
		case 1:
		{
			new uMoney = g_iUserMoney[id];
			if (!g_bTombolaWork)
			{
				
			}
			else
			{
				if (uMoney < c_TombolaCost)
				{
					client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "NOT_ENOUGH_MONEY", c_TombolaCost - uMoney);
					_ShowTombolaMenu(id);
					return PLUGIN_HANDLED
				}
				g_iUserMoney[id] -= c_TombolaCost
				g_iTombolaPrize = c_TombolaCost + g_iTombolaPrize;
				g_bUserPlay[id] = 1;
				ArrayPushCell(g_aTombola, id);
				g_iTombolaPlayers += 1;
				client_print_color(0, id, "^4%s^1 %L", CHAT_PREFIX, -1, "RAFFLE_ANNOUNCE_JOIN", g_szName[id]);
				_ShowTombolaMenu(id);
			}
		}
		default:
		{
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

public task_TombolaRun(task)
{
	if (1 > g_iTombolaPlayers)
	{
		client_print_color(0, 0, "^4%s^1 %L", CHAT_PREFIX, -1, "RAFFLE_NOBODY_JOINED");
	}
	else
	{
		if (2 > g_iTombolaPlayers)
		{
			client_print_color(0, 0, "^4%s^1 %L", CHAT_PREFIX, -1, "RAFFLE_ONLY_ONE");
		}
		new id;
		new size = ArraySize(g_aTombola);
		new random;
		new run;
		do {
			random = random_num(0, size + -1);
			id = ArrayGetCell(g_aTombola, random);
			if (0 < id && 32 >= id || !is_user_connected(id))
			{
				if (2 > g_iTombolaPlayers)
				{
					g_iUserMoney[id] += c_TombolaCost
				}
				else
				{
					g_iUserMoney[id] += g_iTombolaPrize;
					AddStatistics(id, RECEIVED_MONEY, g_iTombolaPrize, .line = __LINE__)
					new Name[32];
					get_user_name(id, Name, 31);
					client_print_color(0, 0, "^4%s^1 %L", CHAT_PREFIX, -1, "RAFFLE_WINNER", Name, g_iTombolaPrize);
				}
			}
			else
			{
				ArrayDeleteItem(g_aTombola, random);
				size--;
			}
		} while (run);
	}
	arrayset(g_bUserPlay, 0, 33);
	g_iTombolaPlayers = 0;
	g_iTombolaPrize = 0;
	ArrayClear(g_aTombola);
	g_iNextTombolaStart = g_iTombolaTimer + get_systime(0);
	new Timer[32];
	_FormatTime(Timer, 31, g_iNextTombolaStart);
	return PLUGIN_HANDLED;
}

_ShowRouletteMenu(id)
{
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "GAME_ROULETTE");
	new menu = menu_create(temp, "roulette_menu_handler", 0);
	new szItem[2];
	szItem[1] = 0;
	formatex(temp, 63, "\w%L", id, "ROULETTE_UNDER", c_RouletteMin);
	menu_additem(menu, temp, szItem, 0, -1);
	formatex(temp, 63, "\w%L", id, "ROULETTE_OVER", c_RouletteMin);
	menu_additem(menu, temp, szItem, 0, -1);
	formatex(temp, 63, "\w%L^n", id, "ROULETTE_EQUAL", c_RouletteMax);
	menu_additem(menu, temp, szItem, 0, -1);
	formatex(temp, 63, "\w%L", id, "ROULETTE_BET", g_iUserBetMoney[id]);
	menu_additem(menu, temp, szItem, 0, -1);

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public roulette_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowGamesMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	if (0 <= item <= 2)
	{
		if (g_iUserBetMoney[id] <= g_iUserMoney[id])
		{
			g_iUserMoney[id] -= g_iUserBetMoney[id];
		}
		else
		{
			client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "NOT_ENOUGH_MONEY", g_iUserBetMoney[id] - g_iUserMoney[id]);
			return PLUGIN_HANDLED
		}
	}
	new chance = random_num(1, 100);
	switch (item)
	{
		case 0:
		{
			if (chance <= 48)
			{
				_RouletteWin(id, c_RouletteMin);
			}
			else
			{
				_RouletteLoose(id, chance);
			}
		}
		case 1:
		{
			if (chance >= 53)
			{
				_RouletteWin(id, c_RouletteMin);
			}
			else
			{
				_RouletteLoose(id, chance);
			}
		}
		case 2:
		{
			if (48 <= chance <= 53)
			{
				_RouletteWin(id, c_RouletteMax);
			}
			else
			{
				_RouletteLoose(id, chance);
			}
		}
		case 3:
		{
			client_cmd(id, "messagemode BetMoney");
		}
		default:
		{
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_RouletteWin(id, multi)
{
	new num = multi * g_iUserBetMoney[id];
	g_iUserMoney[id] += num;
	AddStatistics(id, RECEIVED_MONEY, num, .line = __LINE__)
	AddStatistics(id, TOTAL_ROULETTE, num, .line = __LINE__)
	g_bRoulettePlay[id] = 1;
	client_print_color(0, id, "^4%s^1 %L", CHAT_PREFIX, -1, "ROULETTE_WIN", g_szName[id], num);
	client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "ROULETTE_NEXT");
	return PLUGIN_HANDLED;
}

_RouletteLoose(id, num)
{
	client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "ROULETTE_LOOSE", num);
	_ShowGamesMenu(id);
	return PLUGIN_HANDLED;
}

public concmd_betmoney(id)
{
	new data[16];
	read_args(data, 15);
	remove_quotes(data);
	new Amount = str_to_num(data);
	if (Amount < 100 || Amount > 1000)
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "ROULETTE_INFO", 100, 1000);
		client_cmd(id, "messagemode BetMoney");
		return 1;
	}
	g_iUserBetMoney[id] = Amount;
	_ShowRouletteMenu(id);
	return 1;
}

_ShowJackpotMenu(id)
{
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "GAME_JACKPOT");
	new menu = menu_create(temp, "jackpot_menu_handler", 0);
	new szItem[2];
	szItem[1] = 0;
	if (!_IsGoodItem(g_iUserJackpotItem[id]))
	{
		formatex(temp, 63, "\w%L", id, "SELECT_ITEM");
		szItem[0] = 1;
		menu_additem(menu, temp, szItem, 0, -1);
	}
	else
	{
		new Item[50];
		_GetItemName(g_iUserJackpotItem[id], Item, charsmax(Item));
		
		formatex(temp, 63, "\r%s\w%s", g_bJackpotStt[id] ? "StatTrak " : "", Item);
		szItem[0] = 1;
		menu_additem(menu, temp, szItem, 0, -1);
	}
	if (g_bUserPlayJackpot[id])
	{
		formatex(temp, 63, "\r%L^n", id, "JACKPOT_ALREADY_JOINED");
		szItem[0] = 0;
		menu_additem(menu, temp, szItem, 0, -1);
	}
	else
	{
		formatex(temp, 63, "\r%L^n", id, "JACKPOT_JOIN");
		szItem[0] = 2;
		menu_additem(menu, temp, szItem, 0, -1);
	}
	new Timer[32];
	_FormatTime(Timer, 31, g_iJackpotClose);
	formatex(temp, 63, "\w%L", id, "COUNTDOWN", Timer);
	szItem[0] = 0;
	menu_additem(menu, temp, szItem, 0, -1);

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public jackpot_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowGamesMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[2];
	new dummy;
	new index;
	menu_item_getinfo(menu, item, dummy, itemdata, 1, {0}, 0, dummy);
	index = itemdata[0];
	if (!g_bJackpotWork)
	{
		_ShowGamesMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	switch (index)
	{
		case 0:
		{
			_ShowJackpotMenu(id);
		}
		case 1:
		{
			if (g_bUserPlayJackpot[id])
			{
				_ShowJackpotMenu(id);
			}
			else
			{
				_SelectJackpotSkin(id);
			}
		}
		case 2:
		{
			new skin = g_iUserJackpotItem[id];
			if (!_IsGoodItem(skin))
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "JACKPOT_JOIN_PRESS");
				_ShowJackpotMenu(id);
			}
			else
			{
				if (!_UserHasItem(id, skin))
				{
					client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "NO_LONGER");
					g_iUserJackpotItem[id] = -1;
				}
				g_bUserPlayJackpot[id] = 1;
				g_iUserSkins[id][skin]--;
				
				checkInstantDefault(id, skin)
				
				ArrayPushCell(g_aJackpotSkins, skin);
				ArrayPushCell(g_aJackpotUsers, id);
				ArrayPushCell(g_aJackPotSttSkins, g_bJackpotStt[id])
				new szItem[50];
				_GetItemName(skin, szItem, charsmax(szItem));
				
				if(g_bJackpotStt[id])
				{
					format(szItem, charsmax(szItem), "StatTrak %s", szItem)
					
					g_iUserStattrakKillCount[id][skin] = 0
					g_bIsWeaponStattrak[id][skin] = false
				}
				client_print_color(0, 0, "^4%s %L", CHAT_PREFIX, -1, "JACKPOT_JOINED", g_szName[id], szItem);
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

_SelectJackpotSkin(id)
{
	_ShowSkinMenu(id)
}

ExecConfigFile()
{	
	new szConfigFile[128]
	formatex(szConfigFile, charsmax(szConfigFile), "%s/%s/%s", AMXX_CONFIG_DIRECTORY, CSGO_CONFIG_DIRECTORY, CONFIG_FILE_NAME)

	if (!file_exists(szConfigFile))
	{
		set_fail_state("%s Config file ^"%s^" does not exists!", CONSOLE_PREFIX, szConfigFile)
	}
	else 
	{
		
		server_cmd("exec %s", szConfigFile)
	}

	ExecuteForward(g_eForwards[CONFIG_EXECUTED])
}

public ReadINIFile()
{	
	new szINIFile[128]
	formatex(szINIFile, charsmax(szINIFile), "%s/%s/%s", AMXX_CONFIG_DIRECTORY, CSGO_CONFIG_DIRECTORY, INI_FILE_NAME)
	
	if(!file_exists(szINIFile))
	{
		set_fail_state("File ^"%s^" does not exists", szINIFile)
	}
	
	new fp = fopen(szINIFile, "rt");

	if (!fp)
	{
		set_fail_state("Could not open file ^"%s^"", szINIFile);
	}
	
	new buff[256];
	new section;
	new leftpart[48];
	new rightpart[48];
	new weaponid[4];
	new weaponname[32];
	new weaponmodel[128];
	new weaponchance[8];
	new weaponcostmin[8];
	new bodypart[8]
	new weapontype[5];
	new szTemp[2][64];

	while(!feof(fp))
	{
		fgets(fp, buff, charsmax(buff))
		trim(buff);

		if(buff[0] == ';' || buff[0] == EOS || buff[0] == '#' || buff[0] == ' ')
		{
			continue
		}

		if (buff[0] == '[')
		{
			section += 1;
			continue;
		}

		switch (section)
		{
			case CONFIG_SQL:
			{
				strtok2(buff, szTemp[0], charsmax(szTemp[]), szTemp[1], charsmax(szTemp[]), '=', TRIM_FULL);

				if(equali(szTemp[0], MYSQL_HOST))
				{
					copy(MYSQL[SQL_HOST], charsmax(MYSQL[SQL_HOST]), szTemp[1]);
				}

				if(equali(szTemp[0], MYSQL_USER))
				{
					copy(MYSQL[SQL_USER], charsmax(MYSQL[SQL_USER]), szTemp[1]);
				}

				if(equali(szTemp[0], MYSQL_PASS))
				{
					copy(MYSQL[SQL_PASS], charsmax(MYSQL[SQL_PASS]), szTemp[1]);
				}

				if(equali(szTemp[0], MYSQL_DB))
				{
					copy(MYSQL[SQL_DB], charsmax(MYSQL[SQL_DB]), szTemp[1]);
				}
			}

			case CONFIG_RANKS:
			{
				parse(buff, leftpart, charsmax(leftpart), rightpart, charsmax(rightpart));
				
				ArrayPushString(g_aRankName, leftpart);
				ArrayPushCell(g_aRankKills, str_to_num(rightpart));

				g_iRanksNum += 1;
			}

			case CONFIG_RANGS:
			{
				parse(buff, leftpart, charsmax(leftpart), rightpart, charsmax(rightpart))
				
				ArrayPushString(g_aRangName, leftpart)
				ArrayPushCell(g_aRangExp, str_to_num(rightpart))
			}

			case CONFIG_DEFAULT_SKINS:
			{
				parse(buff, weaponid, charsmax(weaponid), weaponmodel, charsmax(weaponmodel), bodypart, charsmax(bodypart));

				if(file_exists(weaponmodel))
				{
					engfunc(EngFunc_PrecacheModel, weaponmodel)
				}
				else 
				{
					set_fail_state("[CSGO Classy] You have a missing model ^"%s^" in the [DEFAULT] section of csgoclassy.ini", weaponmodel);
				}

				copy(g_eDefaultModels[str_to_num(weaponid)][PATH], charsmax(g_eDefaultModels[][PATH]), weaponmodel)
				g_eDefaultModels[str_to_num(weaponid)][BODYINDEX] = str_to_num(bodypart) > 0 ? str_to_num(bodypart) : NO_BODY_PART 
			}

			case CONFIG_SKINS:
			{
				switch(g_CvarSkinType)
				{
					case 0: parse(buff, weaponid, 3, weaponname, 31, weaponmodel, charsmax(weaponmodel), weaponchance, 7, weaponcostmin, 7, bodypart, 7);
					case 1:	parse(buff, weaponid, 3, weaponname, 31, weaponmodel, charsmax(weaponmodel), weapontype, charsmax(weapontype), weaponchance, 7, weaponcostmin, 7, bodypart, 7);
				}

				if (!file_exists(weaponmodel))
				{
					set_fail_state("[CSGO Classy] You have a missing model ^"%s^" in the [SKINS] section of csgoclassy.ini", weaponmodel);
				}
				
				if(g_CvarSkinType)
				{
					switch(weapontype[0])
					{
						case 'c': ArrayPushCell(g_aSkinType, CRAFT_SKIN);

						case 'd': ArrayPushCell(g_aSkinType, DROP_SKIN);
					}
				}

				if(!equal(g_eDefaultModels[str_to_num(weaponid)], weaponmodel) && ArrayFindString(g_aSkinModel, weaponmodel) == -1)
				{
					engfunc(EngFunc_PrecacheModel, weaponmodel)
				}

				ArrayPushString(g_aSkinModel, weaponmodel);
				ArrayPushCell(g_aSkinWeaponID, str_to_num(weaponid));
				ArrayPushString(g_aSkinName, weaponname);
				ArrayPushCell(g_aSkinChance, str_to_num(weaponchance));
				ArrayPushCell(g_aSkinCostMin, str_to_num(weaponcostmin));
				ArrayPushCell(g_aSkinBody, str_to_num(bodypart))

				g_iSkinsNum += 1;
			}
		}
	}

	fclose(fp);

	if(g_iSkinsNum > TOTAL_SKINS)
	{
		set_fail_state("Error, too many skins. Total: %d", TOTAL_SKINS);
	}

	switch(g_CvarSaveType)
	{
		case SQL:
		{
			connectToDatabase()
		}

		case NVAULT:
		{
			g_nVaultSkinTags 			=	 nvault_open(g_sznVaultSkinTagVaultName);
			g_nVaultPlayerTags 			=	 nvault_open(g_sznVaultPlayerTagName);
			g_nVaultNameTagsLevel		=	 nvault_open(g_sznVaultTagLevelName)
			g_nVaultGloves 				=	 nvault_open(g_sznVaultGlovesName);
			g_nVaultWeaponGloves 		=	 nvault_open(g_sznVaultWeaponGlovesName);
			g_nVaultStattrak 			=	 nvault_open(g_sznVaultStattrakName)
			g_nVaultStattrakKills 		=	 nvault_open(g_sznVaultStattrakKillsName)
			g_nVaultAccounts 			=	 nvault_open(g_sznVaultAccountsName)
			
			if (g_nVaultAccounts == INVALID_HANDLE)
			{
				set_fail_state("[CSGO Classy] Could not open file csgoclassy.vault")
			}

			if(g_nVaultGloves == INVALID_HANDLE || g_nVaultWeaponGloves == INVALID_HANDLE)
			{
				set_fail_state("[CSGO Classy] Could not open one of the gloves vault files");
			}

			if(g_nVaultSkinTags == INVALID_HANDLE || g_nVaultPlayerTags == INVALID_HANDLE || g_nVaultNameTagsLevel == INVALID_HANDLE)
			{
				set_fail_state("[CSGO Classy] Could not open one of the skin tags vault files");
			}
		}

		default: 	set_fail_state("Invalid save type (0 - NVAULT; 1 - SQL)");
	}

	server_print("[CSGO Classy] Total skins: %d", g_iSkinsNum);

	read_gloves_file();
	g_iSkinID = getGiveawaySkin(g_szSkinName);

	if(g_CvarRoundEndSounds)
	{
		if(file_exists(g_szCTWin) && file_exists(g_szTWin))
		{
			engfunc(EngFunc_PrecacheGeneric, g_szCTWin)
			engfunc(EngFunc_PrecacheGeneric, g_szTWin)
		}
		else 
		{
			set_fail_state("File %s or %s does not exista", g_szTWin, g_szCTWin)
		}
	}
}

getServerStatistics() 
{
	new szQuery[512]
	formatex(szQuery, charsmax(szQuery), "SELECT * FROM `%s` WHERE `server_key` = '%s';", g_szTables[SERVER_STATISTICS], DB_SERVER_KEY)
	
	SQL_ThreadQuery(g_SqlTuple, "GetServerStatistics", szQuery)
}

public GetServerStatistics(FailState, Handle:Query, szError[], ErrorCode, szData[], iSize)
{
	if(FailState || ErrorCode)
	{
		log_to_file(LOG_FILE, "[LINE: %i] An SQL Error has been encoutered. Error code %i^nError: %s", __LINE__, ErrorCode, szError);
		SQL_FreeHandle(Query);
		return;
	}

	if(SQL_NumResults(Query) == 0)
	{
		new iData[1]; iData[0] = __LINE__
		SQL_ThreadQuery(g_SqlTuple, "FreeHandle", fmt("INSERT INTO `%s` (`server_key`) VALUES ('%s')", g_szTables[SERVER_STATISTICS], DB_SERVER_KEY), iData, sizeof(iData))
		log_to_file(LOG_FILE, "Server statistics entity has been created in database")
		
		SQL_FreeHandle(Query)
		return
	}

	for(new STATISTICS:iStat = RECEIVED_MONEY; iStat < STATISTICS; iStat++)
	{
		g_eServerStatistics[iStat] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, g_szStatsName[_:iStat]))
	}

	static szData[2][6086]

	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, g_szStatsName[_:DROPPED_SKINS]), szData[_:DROPPED_SKINS], charsmax(szData[]))
	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, g_szStatsName[_:DROPPED_STT_SKINS]), szData[_:DROPPED_STT_SKINS], charsmax(szData[]))

	new szValue[2][32], i

	while(
		i < g_iSkinsNum
		&& szData[_:DROPPED_SKINS][0]
		&& szData[_:DROPPED_STT_SKINS][0]
		&& strtok2(szData[_:DROPPED_SKINS], 		szValue[_:DROPPED_SKINS], 		charsmax(szValue[]), 	szData[_:DROPPED_SKINS], 		charsmax(szData[]), ',') 
		&&	strtok2(szData[_:DROPPED_STT_SKINS], 	szValue[_:DROPPED_STT_SKINS], 	charsmax(szValue[]), 	szData[_:DROPPED_STT_SKINS], 	charsmax(szData[]), ',')
		)
	{
		g_iServerSkinStatistics[i] = str_to_num(szValue[_:DROPPED_SKINS])
		g_iServerSttSkinStatistics[i] = str_to_num(szValue[_:DROPPED_STT_SKINS])

		i++
	}

	SQL_ReadResult(Query, SQL_FieldNameToNum(Query, g_szStatsName[_:WEAPON_KILL]), szData[0], charsmax(szData[]))

	i = 1
	while(i < CS_MAX_WEAPONS && szData[0][0] && strtok2(szData[0], szValue[0], charsmax(szValue[]), szData[0], charsmax(szData[]), ','))
	{
		g_iServerWeaponKill[i] = str_to_num(szValue[0])
		i++
	}

	SQL_FreeHandle(Query)
}

RegisterCMDS()
{
	register_clcmd("say /tradeaccept", "clcmd_say_accept", -1)
	register_clcmd("say /tradedeny", "clcmd_say_deny", -1)
	
	register_clcmd("say /coinflipaccept", "clcmd_say_accept_cf", -1)
	register_clcmd("say /coinflipdeny", "clcmd_say_deny_cf", -1)

	register_clcmd("chooseteam", "clcmd_chooseteam", -1, "", -1)

	register_concmd("UserPassword", "concmd_password", -1, "", -1)
	register_concmd("UserNewPassword", "concmd_newpassword", -1, "", -1)
	register_concmd("UserOldPassword", "concmd_oldpassword", -1, "", -1)
	register_concmd("SkinPrice", "concmd_itemprice", -1, "", -1)
	register_concmd("BetMoney", "concmd_betmoney", -1, "", -1);
	register_concmd("SkinTag", "concmd_skintag", -1, "", -1)
	register_concmd("NewSkinTag", "concmd_new_skintag", -1, "", -1)
	

	new Access = read_flags(c_CmdAccess)
	register_concmd("amx_givemoney", "concmd_givemoney", Access, "<name> <amount>", -1)
	register_concmd("amx_givecases", "concmd_givecases", Access, "<name> <amount>", -1)
	register_concmd("amx_givekeys", "concmd_givekeys", Access, "<name> <amount>", -1)
	register_concmd("amx_givescraps", "concmd_givescraps", Access, "<name> <amount>", -1)
	register_concmd("amx_givecapsules", "concmd_givecapsules", Access, "<name> <amount>", -1)
	register_concmd("amx_givenametags_common", "concmd_givecommonnametags", Access, "<name> <amount>", -1)
	register_concmd("amx_givenametags_rare", "concmd_giverarenametags", Access, "<name> <amount>", -1)
	register_concmd("amx_givenametags_mythic", "concmd_givemythicnametags", Access, "<name> <amount>", -1)
	register_concmd("amx_giveglovecases", "concmd_giveglovecases", Access, "<name> <amount>", -1)
	register_concmd("amx_setskins", "concmd_giveskins", Access, "<name> <skinID or @ALL> <amount> <StatTrak status (1 or 0)", -1)
	register_concmd("amx_setrank", "concmd_setrank", Access, "<name> <rankID>", -1)
	register_concmd("amx_finddata", "concmd_finddata", Access, "<name>", -1)
	register_concmd("amx_resetdata", "concmd_resetdata", Access, "<name>", -1)
	register_concmd("amx_giveglove", "concmd_giveglove", Access, "<name> <glove id (from 0 to 4)> <amount>");
	register_clcmd("say /skin", "clcmd_skin", -1, "", -1, false);
	register_clcmd("say_team /skin", "clcmd_skin", -1, "", -1, false);
	register_clcmd("amx_skin", "clcmd_skin", -1, "", -1, false);
	register_clcmd("simulate_glove_drop", "simulate_glove_drop", Access, "<number>", -1, false);
	register_clcmd("get_models", "get_models", Access, "<number>", -1, false);
}

RegisterCVARS()
{
	bind_pcvar_num(
		create_cvar(
				"bonus_amount",
				"150",
				FCVAR_NONE,
				"Bonus amount when ranking up",
				true,
				0.0
		),
		g_CvarRangUpBonus
	)
	bind_pcvar_num(
		create_cvar(
				"quick_scope_enabled",
				"1",
				FCVAR_NONE,
				"Enabling quick scope event",
				true,
				0.0,
				true,
				1.0
		),
		g_quick_enable
	)
	bind_pcvar_num(
		create_cvar(
				"quick_type",
				"1",
				FCVAR_NONE,
				"Display message: 0 in chat, 1 in HUD",
				true,
				0.0,
				true,
				1.0
		),
		g_quick_type
	)
	bind_pcvar_num(
		create_cvar(
				"giveaway_rounds",
				"18",
				FCVAR_NONE,
				"Rounds played until giveaway starts",
				true,
				1.0
		),
		g_GiveawayDelay
	)
	bind_pcvar_num(
		create_cvar(
				"head_minmoney",
				"1",
				FCVAR_NONE,
				"Min. money when killing by headshot",
				true,
				1.0
		),
		c_HMinMoney
	)
	bind_pcvar_num(
		create_cvar(
				"head_maxmoney",
				"2",
				FCVAR_NONE,
				"Max. money when killing by headshot",
				true,
				1.0
		),
		c_HMaxMoney
	)
	bind_pcvar_num(
		create_cvar(
				"kill_minmoney",
				"1",
				FCVAR_NONE,
				"Min. money when killing",
				true,
				1.0
		),
		c_KMinMoney
	)
	bind_pcvar_num(
		create_cvar(
				"kill_maxmoney",
				"2",
				FCVAR_NONE,
				"Max. money when killing",
				true,
				1.0
		),
		c_KMaxMoney
	)
	bind_pcvar_num(
		create_cvar(
				"head_minchance",
				"50",
				FCVAR_NONE,
				"Min. chance to get case/key when killing by headshot",
				true,
				0.0,
				true,
				100.1
		),
		c_HMinChance
	)
	bind_pcvar_num(
		create_cvar(
				"head_maxchance",
				"100",
				FCVAR_NONE,
				"Max. chance to get case/key when killing by headshot",
				true,
				0.0,
				true,
				100.1
		),
		c_HMaxChance
	)
	bind_pcvar_num(
		create_cvar(
				"kill_minchance",
				"0",
				FCVAR_NONE,
				"Min. chance to get case/key when killing",
				true,
				0.0,
				true,
				100.1
		),
		c_KMinChance
	)
	bind_pcvar_num(
		create_cvar(
				"kill_maxchance",
				"100",
				FCVAR_NONE,
				"Max. chance to get case/key when killing",
				true,
				0.0,
				true,
				100.1
		),
		c_KMaxChance
	)
	bind_pcvar_num(
		create_cvar(
				"assist_minmoney",
				"1",
				FCVAR_NONE,
				"Min. money to get when kill assist",
				true,
				0.0,
				true,
				100.0
		),
		c_AMinMoney
	)
	bind_pcvar_num(
		create_cvar(
				"assist_maxmoney",
				"2",
				FCVAR_NONE,
				"Max. money to get when kill assist",
				true,
				0.0,
				true,
				100.0
		),
		c_AMaxMoney
	)
	bind_pcvar_num(
		create_cvar(
				"mvp_message",
				"0",
				FCVAR_NONE,
				"Display MVP message: 0 in chat, 1 in HUD",
				true,
				1.0,
				true,
				2.0
		),
		c_MVPMsgType
	)
	bind_pcvar_num(
		create_cvar(
				"raffle_cost",
				"500",
				FCVAR_NONE,
				"Min. money to join the raffle"
		),
		c_TombolaCost
	)
	bind_pcvar_string(
		create_cvar(
				"rankup_bonus",
				"kkcc|150",
				FCVAR_NONE,
				"Rankup bonus pattern (k -> key, c -> cases, |150 -> money (150))"
		),
		c_RankUpBonus,
		charsmax(c_RankUpBonus)
	)

	bind_pcvar_num(
		create_cvar(
				"register_open",
				"1",
				FCVAR_NONE,
				"Register system opened: 0 disable, 1 enable",
				true,
				0.0,
				true,
				1.0
		),
		c_RegOpen
	)
	bind_pcvar_num(
		create_cvar(
				"return_percent",
				"4",
				FCVAR_NONE,
				"Percent of retrieved money when destroying a skin",
				true,
				0.0,
				true,
				100.0
		),
		c_ReturnPercent
	)
	bind_pcvar_num(
		create_cvar(
				"drop_type",
				"1",
				FCVAR_NONE,
				"If having the chance to get key or cases: 1 only case, 2 key and case",
				true,
				1.0,
				true,
				2.0
		),
		c_DropType
	)
	bind_pcvar_num(
		create_cvar(
				"key_price",
				"80",
				FCVAR_NONE,
				"Key price in crafting menu"
		),
		c_KeyPrice
	)
	bind_pcvar_num(
		create_cvar(
				"raffle_timer",
				"180",
				FCVAR_NONE,
				"Delay in seconds between raffles"
		),
		c_TombolaTimer
	)
	bind_pcvar_num(
		create_cvar(
				"jackpot_timer",
				"240",
				FCVAR_NONE,
				"Delay in seconds between jackpots"
		),
		c_JackpotTimer
	)
	bind_pcvar_num(
		create_cvar(
				"competitive_mode",
				"1",
				FCVAR_NONE,
				"Competitive mode: 1 enable, 0 disable"
		),
		c_Competitive
	)
	bind_pcvar_num(
		create_cvar(
				"warmup_duration",
				"15",
				FCVAR_NONE,
				"Warmup duration in seconds"
		),
		c_WarmUpDuration
	)
	bind_pcvar_num(
		create_cvar(
				"roulette_min",
				"2",
				FCVAR_NONE,
				"Min. roulette bet"
		),
		c_RouletteMin
	)
	bind_pcvar_num(
		create_cvar(
				"roulette_max",
				"10",
				FCVAR_NONE,
				"Max. roulette bet"
		),
		c_RouletteMax
	)
	bind_pcvar_num(
		create_cvar(
				"dropchance",
				"95",
				FCVAR_NONE,
				"Minimum chanche to get a cases or a key when killing someone",
				true,
				0.0,
				true,
				100.0
		),
		c_DropChance
	)
	bind_pcvar_num(
		create_cvar(
				"craft_cost",
				"25",
				FCVAR_NONE,
				"Min. scraps to craft",
				true,
				1.0
		),
		c_CraftCost
	)
	bind_pcvar_num(
		create_cvar(
				"scraps_for_transform",
				"1",
				FCVAR_NONE,
				"Min. scraps when destroying skin (value increased by nametag prices)",
				true,
				1.0
		),
		c_DustForTransform
	)
	bind_pcvar_num(
		create_cvar(
				"scraps_per_kill",
				"1",
				FCVAR_NONE,
				"Min. scraps when killing with knife",
				true,
				1.0
		),
		g_CvarKnifeKillScraps
	)
	bind_pcvar_num(
		create_cvar(
				"warmup_knife_only",
				"0",
				FCVAR_NONE,
				"Only weapons in warmup: 0 disabled, 1 enabled",
				true,
				0.0,
				true,
				1.0
		),
		g_CvarKnifeWarmup
	)
	bind_pcvar_num(
		create_cvar(
				"name_tag_capsule_drop_chance",
				"5",
				FCVAR_NONE,
				"Chance to get a nametag capsule",
				true,
				1.0,
				true,
				100.0
		),
		g_CvarCapsuleChance
	)
	bind_pcvar_num(
		create_cvar(
				"name_tag_chance_common",
				"25",
				FCVAR_NONE,
				"Chance to get a Common nametag from capsule",
				true,
				1.0,
				true,
				100.0
		),
		g_CvarCommonNameTagChance
	)
	bind_pcvar_num(
		create_cvar(
				"name_tag_chance_rare",
				"20",
				FCVAR_NONE,
				"Chance to get a Rarre nametag from capsule",
				true,
				1.0,
				true,
				100.0
		),
		g_CvarRareNameTagChance
	)
	bind_pcvar_num(
		create_cvar(
				"name_tag_chance_mythic",
				"10",
				FCVAR_NONE,
				"Chance to get a Mythic nametag from capsule",
				true,
				1.0,
				true,
				100.0
		),
		g_CvarMythicNameTagChance
	)

	bind_pcvar_num(
		create_cvar(
				"name_tag_common_price_add",
				"1250",
				FCVAR_NONE,
				"Money to add on skins that have common nametag and nametag price"
		),
		g_CvarCommonPrice
	)
	bind_pcvar_num(
		create_cvar(
				"name_tag_rare_price_add",
				"1250",
				FCVAR_NONE,
				"Money to add on skins that have rare nametag and nametag price"
		),
		g_CvarRarePrice
	)
	bind_pcvar_num(
		create_cvar(
				"name_tag_mythic_price_add",
				"1250",
				FCVAR_NONE,
				"Money to add on skins that have mythic nametag and nametag price"
		),
		g_CvarMythicPrice
	)
	bind_pcvar_num(
		create_cvar(
				"capsule_gold_chance_add",
				"10",
				FCVAR_NONE,
				"Chance to add to nametag capsule drop for a Gold VIP",
				true,
				0.0,
				true,
				100.0
		),
		g_CvarGoldVipCapsuleChance
	)
	bind_pcvar_num(
		create_cvar(
				"capsule_silver_chance_add",
				"5",
				FCVAR_NONE,
				"Chance to add to nametag capsule drop for a Silver VIP (not FREE VIP)",
				true,
				0.0,
				true,
				100.0
		),
		g_CvarSilverVipCapsuleChance
	)
	bind_pcvar_num(
		create_cvar(
				"name_tag_gold_chance_add",
				"10",
				FCVAR_NONE,
				"Chance to add to nametag drop from capsule for a Gold VIP",
				true,
				0.0,
				true,
				100.0
		),
		g_CvarGoldVipNameTagChance
	)
	bind_pcvar_num(
		create_cvar(
				"name_tag_silver_chance_add",
				"5",
				FCVAR_NONE,
				"Chance to add to nametag drop from capsule for a Silver VIP (not FREE VIP)",
				true,
				0.0,
				true,
				100.0
		),
		g_CvarSilverVipNameTagChance
	)
	bind_pcvar_num(
		create_cvar(
				"name_tag_scraps_destroy_skin",
				"25",
				FCVAR_NONE,
				"Scraps to add when destroying a skin with nametag"
		),
		g_CvarScrapsDestroyNameTagSkin
	)
	bind_pcvar_num(
		create_cvar(
				"name_tag_money_destroy_skin",
				"500",
				FCVAR_NONE,
				"Money to add when destroying a skin with nametag"
		),
		g_CvarMoneyDestroyNameTagSkin
	)
	bind_pcvar_num(
		create_cvar(
				"preview_skin_time",
				"10",
				FCVAR_NONE,
				"Previwing a skin time in seconds",
				true,
				1.0
		),
		g_CvarPreviewTime
	)
	bind_pcvar_num(
		create_cvar(
				"round_end_sounds",
				"1",
				FCVAR_NONE,
				"Playing T/CT win sound on round end",
				true,
				0.0,
				true,
				1.0
		),
		g_CvarRoundEndSounds
	)
	bind_pcvar_num(
		create_cvar(
				"giveaway_min_players",
				"3",
				FCVAR_NONE,
				"Min. online players to start giveaway",
				true,
				0.0,
				true,
				32.0
		),
		g_CvarGiveawayMinPlayers
	)
	bind_pcvar_num(
		create_cvar(
				"weekend_event",
				"1",
				FCVAR_NONE,
				"Weekend event: 0 disabled, 1 enabled",
				true,
				0.0,
				true,
				1.0
		),
		g_CvarWeekendEvent
	)
	bind_pcvar_num(
		create_cvar(
				"weekend_add_friday",
				"1",
				FCVAR_NONE,
				"Adding friday as weekend day: 0 disabled, 1 enabled",
				true,
				0.0,
				true,
				1.0
		),
		g_CvarWeekendFriday
	)
	bind_pcvar_num(
		create_cvar(
				"weekend_money_bonus",
				"25",
				FCVAR_NONE,
				"Money per kill when weekend bonus event is enabled",
				true,
				1.0
		),
		g_CvarWeekendBonus
	)
	bind_pcvar_num(
		create_cvar(
				"weekend_event_hud",
				"1",
				FCVAR_NONE,
				"Weekend event HUD info: 0 disabled, 1 enabled",
				true,
				0.0,
				true,
				1.0
		),
		g_CvarWeekendHud
	)
	bind_pcvar_num(
		create_cvar(
				"show_special_skins",
				"1",
				FCVAR_NONE,
				"Special skins yellow color in menus: 0 disabled, 1 enabled",
				true,
				0.0,
				true,
				1.0
		),
		g_CvarShowSpecialSkins
	)
	bind_pcvar_num(
		create_cvar(
				"glove_drop_chance",
				"50",
				FCVAR_NONE,
				"Chance to drop a glove from glove case",
				true,
				1.0,
				true,
				100.0
		),
		g_CvarGloveDropChance
	)
	bind_pcvar_num(
		create_cvar(
				"glove_case_drop_chance",
				"15",
				FCVAR_NONE,
				"Chance to drop a glove case from kill",
				true,
				1.0,
				true,
				100.0
		),
		g_CvarGloveCaseDropChance
	)
	bind_pcvar_num(
		create_cvar(
				"user_drop_vip_glove",
				"0",
				FCVAR_NONE,
				"Non-VIP players can drop VIP only gloves: 0 disabled, 1 enabled",
				true,
				0.0,
				true,
				1.0
		),
		g_CvarCanUserDropVIPGloves
	)
	bind_pcvar_num(
		create_cvar(
				"user_use_vip_gloves",
				"0",
				FCVAR_NONE,
				"Non-VIP players can use VIP only gloves: 0 disabled, 1 enabled",
				true,
				0.0,
				true,
				1.0
		),
		g_CvarCanUserUseVIPGloves
	)
	bind_pcvar_num(
		create_cvar(
				"retrieve_glove",
				"0",
				FCVAR_NONE,
				"Get back used glove when apply another glove: 0 disabled, 1 enabled",
				true,
				0.0,
				true,
				1.0
		),
		g_CvarRetrieveGlove
	)
	bind_pcvar_num(
		create_cvar(
				"mvp_max_money",
				"5",
				FCVAR_NONE,
				"Max. money when player is MVP of the round",
				true,
				1.0
		),
		g_CvarMVPMaxMoney
	)
	bind_pcvar_num(
		create_cvar(
				"mvp_min_money",
				"25",
				FCVAR_NONE,
				"Min. money when player is MVP of the round",
				true,
				1.0
		),
		g_CvarMVPMinMoney
	)
	bind_pcvar_num(
		create_cvar(
				"mvp_max_cases",
				"4",
				FCVAR_NONE,
				"Max. cases when player is MVP of the round",
				true,
				1.0
		),
		g_CvarMVPMaxCases
	)
	bind_pcvar_num(
		create_cvar(
				"mvp_min_cases",
				"1",
				FCVAR_NONE,
				"Min. cases when player is MVP of the round",
				true,
				1.0
		),
		g_CvarMVPMinCases
	)
	bind_pcvar_num(
		create_cvar(
				"mvp_max_keys",
				"4",
				FCVAR_NONE,
				"Max. keys when player is MVP of the round"
		),
		g_CvarMVPMaxKeys
	)
	bind_pcvar_num(
		create_cvar(
				"mvp_min_keys",
				"1",
				FCVAR_NONE,
				"Min. keys when player is MVP of the round"
		),
		g_CvarMVPMinKeys
	)
	bind_pcvar_num(
		create_cvar(
				"mvp_min_scraps",
				"3",
				FCVAR_NONE,
				"Max. scraps when player is MVP of the round",
				true,
				1.0
		),
		g_CvarMVPMinScraps
	)
	bind_pcvar_num(
		create_cvar(
				"mvp_max_scraps",
				"15",
				FCVAR_NONE,
				"Min. scraps when player is MVP of the round",
				true,
				1.0
		),
		g_CvarMVPMaxScraps
	)
	bind_pcvar_num(
		create_cvar(
				"skin_type_mode",
				"1",
				FCVAR_NONE,
				"Skin type mode (^"c^" and ^"d^" in csgoclassy.ini): 0 disabled, 1 enabled",
				true,
				0.0,
				true,
				1.0
		),
		g_CvarSkinType
	)
	bind_pcvar_num(
		create_cvar(
				"data_save_type",
				"1",
				FCVAR_NONE,
				"Data type mode: 0 nVault, 1 MySQL",
				true,
				0.0,
				true,
				1.0
		),
		g_CvarSaveType
	)
	bind_pcvar_string(
		create_cvar(
			"command_access",
			"a",
			FCVAR_PROTECTED,
			"Flag that can use CSGO Classy admin commands"
		),
		c_CmdAccess,
		charsmax(c_CmdAccess)
	)
	bind_pcvar_num(
		create_cvar(
			"awp_double_scope",
			"0",
			FCVAR_NONE,
			"Instantly AWP double scope",
			true,
			0.0,
			true,
			1.0
		),
		g_CvarDoubleScope
	)

	bind_pcvar_num(
		create_cvar(
			"count_cmd_stats",
			"1",
			FCVAR_NONE,
			"If counting admin commands in statistics",
			true,
			0.0,
			true,
			1.0
		),
		g_CvarStatsCountCmds
	)

	bind_pcvar_num(
		create_cvar(
			"daily_bonus_min_rank",
			"2",
			FCVAR_NONE,
			"Minimum rank to get daily bonus",
			true,
			0.0
		),
		g_CvarDailyMinRank
	)

	bind_pcvar_num(
		create_cvar(
			"undroppable_skin_chance",
			"-1",
			FCVAR_NONE,
			"Chance of some skins to make them undroppable. Disabled: -1"
		),
		g_CvarUndroppableChance
	)

	bind_pcvar_num(
		create_cvar(
			"mvp_active",
			"1",
			FCVAR_NONE,
			"If MVP System is enabled/disabled. Disable if you are using a MVP plugin",
			true,
			0.0,
			true,
			1.0
		),
		g_CvarMVPSystem
	)

	p_Freezetime = get_cvar_pointer("mp_freezetime")
	g_iRoundsToPlay = get_cvar_num("mp_maxrounds");
}

connectToDatabase()
{
	g_SqlTuple = SQL_MakeDbTuple(MYSQL[SQL_HOST], MYSQL[SQL_USER], MYSQL[SQL_PASS], MYSQL[SQL_DB], 10);
	   
	new ErrorCode;
	new Handle:SqlConnection = SQL_Connect(g_SqlTuple,ErrorCode,g_Error,charsmax(g_Error));
	   
	if(SqlConnection == Empty_Handle)
	{
		set_fail_state(g_Error);
	}
	
	new szQuery[2048]
	new Handle:Queries

	for(new i; i < sizeof(g_szTables); i++)
	{
		formatex(szQuery, charsmax(szQuery), "CREATE TABLE IF NOT EXISTS %s %s", g_szTables[i], g_szTablesInfo[i]);	
	
		Queries = SQL_PrepareQuery(SqlConnection, szQuery);

		if(!SQL_Execute(Queries))
		{
			SQL_QueryError(Queries,g_Error,charsmax(g_Error));
			set_fail_state(g_Error);
		}		
	}
	
	SQL_FreeHandle(Queries);
	SQL_FreeHandle(SqlConnection);

	getServerStatistics()
}

openJackpotMenu(id, iWeaponId)
{
	new temp[64];
	formatex(temp, 63, "\r%s \w%L", MENU_PREFIX, id, "MENU_SKINS");
	new menu = menu_create(temp, "jp_skins_menu_handler", 0);
	new szItem[10];
	szItem[1] = 0;
	new szSkin[32];
	new num;
	new total;
	new i, wid;
	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i];
		if (0 < num)
		{
			wid = ArrayGetCell(g_aSkinWeaponID, i);
			if(wid != iWeaponId)
			{
				i++
				continue
			}
			
			ArrayGetString(g_aSkinName, i, szSkin, 31);
			formatex(temp, 63, "\r%s\w%s \r[%d]", g_bIsWeaponStattrak[id][i] ? "StatTrak " : "", szSkin, num);
			num_to_str(i, szItem, charsmax(szItem));
			menu_additem(menu, temp, szItem, 0, -1);
			total++;
		}
		i++;
	}
	if (!total)
	{
		formatex(temp, 63, "\r%L", id, "NO_ITEMS");
		num_to_str(NO_SKIN_VALUE, szItem, charsmax(szItem))
		menu_additem(menu, temp, szItem, 0, -1);
	}

	if(is_user_connected(id))
	{
		menu_display(id, menu);
	}
	else 
	{
		menu_destroy(menu)
	}
}

public jp_skins_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		_ShowJackpotMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new itemdata[5], dummy, index;
	menu_item_getinfo(menu, item, dummy, itemdata, charsmax(itemdata), {0}, 0, dummy);
	index = str_to_num(itemdata);

	if(g_bHasSkinTag[id][index])
	{
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "JACKPOT_NO_NAMETAG_SKIN");
		_ShowJackpotMenu(id);
		return PLUGIN_HANDLED;
	}
	if (index == NO_SKIN_VALUE)
	{
		_ShowGamesMenu(id);
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	if(index == g_iUserSellItem[id])
	{
		new Item[50];
		_GetItemName(g_iUserSellItem[id], Item, charsmax(Item));
		
		if(g_bPublishedStattrakSkin[id])
		{
			if(g_bHasSkinTag[id][index])
			{
				formatex(Item, charsmax(Item), "%s^3 (%s '%s')",
				Item, g_iNameTagSkinLevel[id][index] == 1 ? "Common" : g_iNameTagSkinLevel[id][index] == 2 ? "Rare" : "Mythic", g_szSkinsTag[id][index]);
			}	
			else formatex(Item, charsmax(Item), "StatTrak %s", Item)
		}
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CURRENTLY_SELLING");
		_SelectJackpotSkin(id)
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	g_iUserJackpotItem[id] = index;
	
	if(g_bIsWeaponStattrak[id][index])
	{
		if(g_iUserSkins[id][index] > 1)
		{
			askWhichType(id, index)
			g_iAskType[id] = 5
			return PLUGIN_HANDLED
		}
		else
		{
			g_bJackpotStt[id] = true
		}
	}
	else g_bJackpotStt[id] = false
	
	_ShowJackpotMenu(id);
	menu_destroy(menu)
	return PLUGIN_HANDLED;
}

public task_Jackpot()
{
	if (!g_bJackpotWork)
	{
		return PLUGIN_HANDLED;
	}

	new id;
	new size = ArraySize(g_aJackpotUsers);
	if (1 > size)
	{
		client_print_color(0, 0, "^4%s %L", CHAT_PREFIX, -1, "JACKPOT_NO_ONE");
		_ClearJackpot();
		return PLUGIN_HANDLED;
	}
	if (2 > size)
	{
		client_print_color(0, 0, "^4%s %L", CHAT_PREFIX, -1, "JACKPOT_ONLY_ONE");
		new id;
		new k;
		id = ArrayGetCell(g_aJackpotUsers, 0);
		if (0 < id && 32 >= id || !is_user_connected(id))
		{
			k = ArrayGetCell(g_aJackpotSkins, 0);
			g_iUserSkins[id][k]++;
		}
		_ClearJackpot();
		return PLUGIN_HANDLED;
	}
	new bool:succes;
	new random;
	new run;
	do 
	{
		random = random_num(0, size + -1);
		id = ArrayGetCell(g_aJackpotUsers, random);
		if (0 < id && 32 >= id || !is_user_connected(id))
		{
			succes = true;
			new i;
			new j;
			new k;
			i = ArraySize(g_aJackpotSkins);
			j = 0;
			while (j < i)
			{
				k = ArrayGetCell(g_aJackpotSkins, j);
				
				g_bIsWeaponStattrak[id][k] = bool:ArrayGetCell(g_aJackPotSttSkins, j)
				g_iUserSkins[id][k]++;
				j++;
			}
			client_print_color(0, 0, "^4%s %L", CHAT_PREFIX, -1, "JACKPOT_WINNER", g_szName[id]);
		}
		else
		{
			ArrayDeleteItem(g_aJackpotUsers, random);
			size--;
		}
		if (!(!succes && size > 0))
		{
			_ClearJackpot();
			return PLUGIN_HANDLED;
		}
	} while (run);
	_ClearJackpot();
	return PLUGIN_HANDLED;
}

_ClearJackpot()
{
	ArrayClear(g_aJackpotSkins);
	ArrayClear(g_aJackPotSttSkins)
	ArrayClear(g_aJackpotUsers);
	arrayset(g_bUserPlayJackpot, 0, 33);
	g_bJackpotWork = false;
	
	for(new i;i < sizeof g_bJackpotStt;i++)
	{
		g_bJackpotStt[i] = false
	}
	return PLUGIN_HANDLED;
}

bool:weekend_event()
{
	new szDay[12];
	get_time("%A", szDay, charsmax(szDay));

	if(!bool:g_CvarRoundEndSounds)
		return false;

	if(equali(szDay, "Friday") && g_CvarWeekendFriday)
		return true;

	if(equali(szDay, "Saturday") || equali(szDay, "Sunday"))
		return true;

	return false;
}

public ev_DeathMsg()
{
	new killer, victim, head, szWeapon[24], bool:gotbonus
	killer = read_data(1);
	victim = read_data(2);
	head = read_data(3);
	gotbonus = false;
	read_data(4, szWeapon, charsmax(szWeapon));

	if (victim == killer || !g_bLogged[killer])
		return PLUGIN_HANDLED;
	
	if (g_iMostDamage[victim] != killer && is_user_connected(g_iMostDamage[victim]) && cs_get_user_team(g_iMostDamage[victim]) == cs_get_user_team(killer))
	{
		_GiveBonus(g_iMostDamage[victim], 0);
	}

	g_iRoundKills[killer]++;

	if (equal(szWeapon, "knife", 0))
	{
		g_iUserScraps[killer] += g_CvarKnifeKillScraps
		AddStatistics(killer, RECEIVED_SCRAPS, g_CvarKnifeKillScraps, .line = __LINE__)
		client_print_color(0, print_team_default, "^4%s^1 %L", CHAT_PREFIX, -1, "KNIFE_KILL", g_szName[killer], g_szName[victim], g_CvarKnifeKillScraps)
	}

	g_iUserKills[killer]++;
	new bool:levelup;
	if (g_iRanksNum + -1 > g_iUserRank[killer])
	{
		new iMaxSize = ArraySize(g_aRankKills) - 1
		if(ArrayGetCell(g_aRankKills, clamp((g_iUserRank[killer] + 1), 0, iMaxSize)) <= g_iUserKills[killer] < ArrayGetCell(g_aRankKills, clamp((g_iUserRank[killer] + 2), 0, iMaxSize)))
		{
			g_iUserRank[killer]++;
			levelup = true;
			new szRank[32];
			ArrayGetString(g_aRankName, g_iUserRank[killer], szRank, 31);
			client_print_color(0, killer, "^4%s^1 %L", CHAT_PREFIX, -1, "RANKUP", g_szName[killer], szRank);
		}
	}
	new rmoney;
	new rchance;
	if (head)
	{
		rmoney = random_num(c_HMinMoney, c_HMaxMoney) + ((weekend_event() == true) ? g_CvarWeekendBonus : 0);
		rchance = random_num(c_HMinChance, c_HMaxChance);
	}
	else
	{
		rmoney = random_num(c_KMinMoney, c_KMaxMoney) + ((weekend_event() == true) ? g_CvarWeekendBonus : 0);
		rchance = random_num(c_KMinChance, c_KMaxChance);
	}

	g_iUserMoney[killer] += rmoney;
	AddStatistics(killer, RECEIVED_MONEY, rmoney, .line = __LINE__)

	new szMessage[192];

	if (rchance > c_DropChance)
	{
		new r;
		if (0 < c_DropType)
		{
			r = 1;
		}
		else
		{
			r = random_num(1, 2);
		}
		switch (r)
		{
			case 1:
			{
				g_iUserCases[killer]++;
				AddStatistics(killer, DROPPED_CASES, 1, .line = __LINE__)
			}
			case 2:
			{
				g_iUserKeys[killer]++;
				AddStatistics(killer, DROPPED_KEYS, 1, .line = __LINE__)
			}
		}

		gotbonus = true;
	}

	new iRandom = random_num(1, 100);

	if(!gotbonus)
	{
		if(!is_user_gold_vip(killer) && !is_user_silver_vip(killer))
		{
			if(iRandom <= g_CvarCapsuleChance)
			{
				g_iNameTagCapsule[killer]++;
				AddStatistics(killer, DROPPED_NAMETAG_CAPSULES, 1, .line = __LINE__)
				formatex(szMessage, charsmax(szMessage), "^4[CSGO Classy] %s^1 dropped a^3 Name-Tag capsule", g_szName[killer]);
				send_message(killer, szMessage);
				gotbonus = true;
			}
		}
		else
		{
			if(is_user_gold_vip(killer))
			{
				if(iRandom <= g_CvarCapsuleChance + g_CvarGoldVipCapsuleChance)
				{
					g_iNameTagCapsule[killer]++;
					AddStatistics(killer, DROPPED_NAMETAG_CAPSULES, 1, .line = __LINE__)
					formatex(szMessage, charsmax(szMessage), "^4[CSGO Classy] %s^1 dropped a^3 Name-Tag capsule", g_szName[killer]);
					send_message(killer, szMessage);
					gotbonus = true;
				}
			}
			else if(is_user_silver_vip(killer))
			{
				if(iRandom <= g_CvarCapsuleChance + g_CvarSilverVipCapsuleChance)
				{
					g_iNameTagCapsule[killer]++;
					AddStatistics(killer, DROPPED_NAMETAG_CAPSULES, 1, .line = __LINE__)
					formatex(szMessage, charsmax(szMessage), "^4[CSGO Classy] %s^1 dropped a^3 Name-Tag capsule", g_szName[killer]);
					send_message(killer, szMessage);
					gotbonus = true;
				}
			}
		}
	}

	if(random_num(1, 100) <= g_CvarGloveCaseDropChance && !gotbonus && g_bActiveGloveSystem)
	{
		g_iGlovesCases[killer]++;
		formatex(szMessage, charsmax(szMessage), "^4%s^3 %s^1 dropped a^4 Glove Case", CHAT_PREFIX, g_szName[killer]);
		send_message(killer, szMessage);
		gotbonus = true;

		AddStatistics(killer, DROPPED_GLOVE_CASES, 1, .line = __LINE__)
	}
	
	if (levelup)
	{
		new keys;
		new cases;
		new money;
		new i;

		new szTempRankBonus[16]
		copy(szTempRankBonus, charsmax(szTempRankBonus), c_RankUpBonus)

		while (szTempRankBonus[i] != '|')
		{
			switch (szTempRankBonus[i])
			{
				case 'c':
				{
					cases++;
				}
				case 'k':
				{
					keys++;
				}
			}

			i++
		}
		new temp[8];
		strtok2(szTempRankBonus, temp, 7, szTempRankBonus, 15, '|');
		if (szTempRankBonus[0])
		{
			money = str_to_num(szTempRankBonus);
		}
		if (0 < keys)
		{
			g_iUserKeys[killer] += keys;
			AddStatistics(killer, DROPPED_KEYS, keys, .line = __LINE__)
		}
		if (0 < cases)
		{
			g_iUserCases[killer] += cases;
			AddStatistics(killer, DROPPED_CASES, cases, .line = __LINE__)
		}
		if (0 < money)
		{
			g_iUserMoney[killer] += money;
			AddStatistics(killer, RECEIVED_MONEY, money, .line = __LINE__)
		}

		client_print_color(killer, print_team_default, "^4%s^1 %L", CHAT_PREFIX, killer, "RANKUP_BONUS", keys, cases, money);
	}

	return PLUGIN_HANDLED;
}

public ev_Damage(id)
{
	if (!(id && id <= g_iMaxPlayers))
	{
		return PLUGIN_HANDLED;
	}
	new att = get_user_attacker(id);
	if (!(0 < att && att <= g_iMaxPlayers))
	{
		return PLUGIN_HANDLED;
	}
	new damage = read_data(2);
	g_iDealDamage[att] += damage;
	g_iDamage[id][att] += damage;
	new topDamager = g_iMostDamage[id];
	if (g_iDamage[id][topDamager] < g_iDamage[id][att])
	{
		g_iMostDamage[id] = att;
	}
	return PLUGIN_HANDLED;
}

public show_weekend_event_hud()
{
	g_hWeekBonus = CreateHudSyncObj();
	new szMessage[128];

	formatex(szMessage, charsmax(szMessage), "Weekend Event ON!^nBonus: %d$/kill", g_CvarWeekendBonus);
	set_hudmessage(47, 79, 79, 0.01, 0.23, 0, 0.1, 1.0, 0.1, 0.1, -1);

	ShowSyncHudMsg(0, g_hWeekBonus, szMessage);
}

public get_models(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
	{
		return PLUGIN_HANDLED;
	}

	new szModelPath[256];
	new szLastPath[256];

	for(new i; i < g_iSkinsNum; i++)
	{
		ArrayGetArray(g_aSkinModel, i, szModelPath, charsmax(szModelPath))

		if(!equal(szLastPath, szModelPath))
		{
			copy(szLastPath, charsmax(szLastPath), szModelPath);
			server_print("^"%s^"", szModelPath);
		}
	}
	
	return PLUGIN_HANDLED
}

public clcmd_skin(id)
{
	if(is_user_alive(id))
	{
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "CANT_USE_CMD_WHEN_ALIVE");
		return PLUGIN_HANDLED;
	}

	new iSpecPlayer = entity_get_int(id, EV_INT_iuser2);

	if(!iSpecPlayer)
	{
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "MUST_SPECTATE");
		return PLUGIN_HANDLED;
	}

	if(!g_bLogged[id])
	{
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "USER_NOT_LOGGED")
		return PLUGIN_HANDLED
	}

	new iWeaponID = get_user_weapon(iSpecPlayer);
	new index = g_iUserSelectedSkin[iSpecPlayer][iWeaponID];

	if(index == -1)
	{
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "SPEC_IS_USING_DEFAULT_MODEL", g_szName[iSpecPlayer])
		return PLUGIN_HANDLED;
	}

	new szSkinName[100]
	_GetItemName(index, szSkinName, charsmax(szSkinName));

	if(g_bActiveGloveSystem)
	{
		new eGlove[GLOVESINFO]
		ArrayGetArray(g_aGloves, g_iWeaponGloves[iSpecPlayer][iWeaponID] == -1 ? 0 : g_iWeaponGloves[iSpecPlayer][iWeaponID], eGlove);
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "SPEC_IS_USING_SKIN_GLOVE", g_szName[iSpecPlayer], (g_bIsWeaponStattrak[iSpecPlayer][iWeaponID] && (g_bShallUseStt[iSpecPlayer][iWeaponID] == true)) ? " StatTrak" : "", szSkinName, eGlove[szGloveName]);
	}
	else 
	{
		client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "SPEC_IS_USING_SKIN", g_szName[iSpecPlayer], (g_bIsWeaponStattrak[iSpecPlayer][iWeaponID] && (g_bShallUseStt[iSpecPlayer][iWeaponID] == true)) ? " StatTrak" : "", szSkinName);
	}

	new iMin, iMax;

	_CalcItemPrice(g_iUserSelectedSkin[iSpecPlayer][iWeaponID], id, iMin, iMax)

	client_print_color(id, print_team_default, "%s %l", CHAT_PREFIX, "PRICE_AND_CHANCE", AddCommas(iMin), AddCommas(iMax), 100 - ArrayGetCell(g_aSkinChance, index))

	return PLUGIN_HANDLED;
}

public check_license()
{
	new szLicense[128];

	switch(MODE)
	{
		case 1:
		{
			get_cvar_string("hostname", szLicense, charsmax(szLicense))

			if (containi(szLicense, LICENSED_IP) == -1)
			{
				set_fail_state("[CSGO Classy] Invalid license! Contact Discord: lexzor#0630. Steam: lexzor");
			}
		}

		case 0:
		{
			get_cvar_string("net_address", szLicense, charsmax(szLicense))

			if(!equali(szLicense, LICENSED_IP))
			{
				set_fail_state("[CSGO Classy] Invalid license! Contact Discord: lexzor#0630. Steam: lexzor");
			}
		}
	}
}

read_gloves_file()
{
	new szFile[128], iCount;
	formatex(szFile, charsmax(szFile), "%s/%s/%s", AMXX_CONFIG_DIRECTORY, CSGO_CONFIG_DIRECTORY, GLOVES_FILE_NAME);

	if(file_exists(szFile))
	{
		new iFilePointer = fopen(szFile, "r")
		new szData[256], szTemp[4][10], eGlove[GLOVESINFO], iSection, szModelPath[256], iPos;

		while(fgets(iFilePointer, szData, charsmax(szData)))
		{
			trim(szData);

			if(!szData[0] || szData[0] == ';' || szData[0] == '#' || szData[0] == ' ')
			{
				continue;
			}

			if(szData[0] == '[')
			{
				iSection++;
				continue;
			}

			switch(iSection)
			{
				case GLOVES_CONFIG:
				{
					parse(szData, eGlove[szGloveName], charsmax(eGlove[szGloveName]), szTemp[0], charsmax(szTemp[]), szTemp[1], charsmax(szTemp[]), szTemp[2], charsmax(szTemp[]), szTemp[3], charsmax(szTemp[]));
					eGlove[iMaxPrice] = str_to_num(szTemp[0]);
					eGlove[iMinPrice] = str_to_num(szTemp[1]);
					eGlove[iVIPOnly] = str_to_num(szTemp[2]);
					eGlove[iDropChance] = str_to_num(szTemp[3]);

					ArrayPushArray(g_aGloves, eGlove);
				}

				case MODEL_CONFIG:
				{
					parse(szData, szModelPath, charsmax(szModelPath), szTemp[1], charsmax(szTemp[]));

					if(!file_exists(szModelPath))
					{
						log_amx("Error! File ^"%s^" couldn't be found", szModelPath);
						continue;
					}

					ArrayPushString(g_aGlovesModelName, szModelPath);
					ArrayPushCell(g_aGlovesModelAmount, str_to_num(szTemp[1]));

					iPos = ArrayFindString(g_aSkinModel, szModelPath)
					
					if(iPos != -1)
					{
						ArrayPushCell(g_aWeapIDs, ArrayGetCell(g_aSkinWeaponID, iPos))
						iCount++;
					} 
				}
			}	
		}

		fclose(iFilePointer);

		if(iCount == 0) 
		{
			server_print("%s Gloves system has been disabled due to no gloves configuration.", CONSOLE_PREFIX);
			g_bActiveGloveSystem = false;
		}
		else
		{
			g_bActiveGloveSystem = true;
		}
	}
	else 
	{
		new iFilePointer = fopen(szFile, "w")
		fputs(iFilePointer, "#Model for gloves: ^"GloveName^" ^"GloveMaxPrice^" ^"GloveMinPrice^" ^"OnlyVIP 1/0^" ^"DropChance^"^n");
		fputs(iFilePointer, "#Model for models info: ^".mdl path^" ^"amount of models (only skins)^"^n^n^n");
		fputs(iFilePointer, "[GLOVES INFO]^n^n^n");
		fputs(iFilePointer, "[MODELS INFO]^n^n")
		log_to_file(LOG_FILE, "File ^"%s^" has been created", szFile);
		fclose(iFilePointer);
	}
}

public concmd_givemoney(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 15);
	new target;
	if (arg1[0] == 64)
	{
		_GiveToAll(id, arg1, arg2, 0);
		return 1;
	}
	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}
	new amount = str_to_num(arg2);
	
	if(g_CvarStatsCountCmds)
	{
		AddStatistics(target, RECEIVED_MONEY, amount, .line = __LINE__)
	}

	if (0 > amount)
	{
		g_iUserMoney[target] += amount;
		if (0 > g_iUserMoney[target])
		{
			g_iUserMoney[target] = 0;
		}

		
		console_print(id, "%s Substracted %d$ from %s", CONSOLE_PREFIX, amount, arg1);
	}
	else
	{
		if (0 < amount)
		{
			g_iUserMoney[target] += amount;
			console_print(id, "%s You gave %s %d$", CONSOLE_PREFIX, arg1, amount);
		}
		return 1;
	}
	return 1;
}

public concmd_givecases(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 15);
	new target;
	if (arg1[0] == 64)
	{
		_GiveToAll(id, arg1, arg2, 1);
		return 1;
	}
	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}
	new amount = str_to_num(arg2);

	if(g_CvarStatsCountCmds)
	{
		AddStatistics(target, DROPPED_CASES, amount, .line = __LINE__)
	}

	if (0 > amount)
	{
		g_iUserCases[target] += amount;
		if (0 > g_iUserCases[target])
		{
			g_iUserCases[target] = 0
		}
		console_print(id, "%s Substracted %d cases from %s", CONSOLE_PREFIX, amount, arg1)
	}
	else
	{
		if (0 < amount)
		{
			g_iUserCases[target] += amount
			console_print(id, "%s You gave %s %d cases", CONSOLE_PREFIX, arg1, amount)
		}
		return 1;
	}
	return 1;
}

public concmd_givekeys(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 15);
	new target;
	if (arg1[0] == 64)
	{
		_GiveToAll(id, arg1, arg2, 2);
		return 1;
	}
	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}
	new amount = str_to_num(arg2);

	if(g_CvarStatsCountCmds)
	{
		AddStatistics(target, DROPPED_KEYS, amount, .line = __LINE__)
	}

	if (0 > amount)
	{
		g_iUserKeys[target] += amount;
		if (0 > g_iUserKeys[target])
		{
			g_iUserKeys[target] = 0;
		}
		console_print(id, "%s Substracted %d keys from %s", CONSOLE_PREFIX, amount, arg1)
	}
	else
	{
		if (0 < amount)
		{
			g_iUserKeys[target] += amount;
			console_print(id, "%s You gave %s %d keys", CONSOLE_PREFIX, arg1, amount)
		}
		return 1;
	}
	return 1;
}

public concmd_givescraps(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 15);
	new target;
	if (arg1[0] == 64)
	{
		_GiveToAll(id, arg1, arg2, 3);
		return 1;
	}
	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}
	new amount = str_to_num(arg2);

	if(g_CvarStatsCountCmds)
	{
		AddStatistics(target, RECEIVED_SCRAPS, amount, .line = __LINE__)
	}

	if (0 > amount)
	{
		g_iUserScraps[target] += amount;
		if (0 > g_iUserScraps[target])
		{
			g_iUserScraps[target] = 0;
		}
		console_print(id, "%s Substracted %d scraps from %s", CONSOLE_PREFIX, amount, arg1)
	}
	else
	{
		if (0 < amount)
		{
			g_iUserScraps[target] += amount;
			console_print(id, "%s You gave %s %d scraps", CONSOLE_PREFIX, arg1, amount)
		}
		return 1;
	}
	return 1;
}

public concmd_givecapsules(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 15);
	new target;
	if (arg1[0] == 64)
	{
		_GiveToAll(id, arg1, arg2, 7);
		return 1;
	}
	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}
	new amount = str_to_num(arg2);

	if(g_CvarStatsCountCmds)
	{
		AddStatistics(target, DROPPED_NAMETAG_CAPSULES, amount, .line = __LINE__)
	}
	
	if (0 > amount)
	{
		g_iNameTagCapsule[target] += amount;
		if (0 > g_iNameTagCapsule[target])
		{
			g_iNameTagCapsule[target] = 0;
		}
		console_print(id, "%s Substracted %d Name-Tags Capsules from %s", CONSOLE_PREFIX, amount, arg1)
	}
	else
	{
		if (0 < amount)
		{
			g_iNameTagCapsule[target] += amount;
			console_print(id, "%s You gave %s %d Name-Tags Capsules", CONSOLE_PREFIX, arg1, amount)
		}
		return 1;
	}
	return 1;
}

public concmd_givecommonnametags(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 15);
	new target;
	if (arg1[0] == 64)
	{
		_GiveToAll(id, arg1, arg2, 4);
		return 1;
	}
	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}
	new amount = str_to_num(arg2);

	if(g_CvarStatsCountCmds)
	{
		AddStatistics(target, DROPPED_NAMETAG_COMMON, amount, .line = __LINE__)
	}

	if (0 > amount)
	{
		g_iCommonNameTag[target] += amount;
		if (0 > g_iCommonNameTag[target])
		{
			g_iCommonNameTag[target] = 0;
		}
		console_print(id, "%s Substracted %d Common Name-Tags from %s", CONSOLE_PREFIX, amount, arg1)
	}
	else
	{
		if (0 < amount)
		{
			g_iCommonNameTag[target] += amount;
			console_print(id, "%s You gave %s %d Common Name-Tags", CONSOLE_PREFIX, arg1, amount)
		}
		return 1;
	}
	return 1;
}

public concmd_giverarenametags(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 15);
	new target;
	if (arg1[0] == 64)
	{
		_GiveToAll(id, arg1, arg2, 5);
		return 1;
	}
	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}
	new amount = str_to_num(arg2);

	if(g_CvarStatsCountCmds)
	{
		AddStatistics(target, DROPPED_NAMETAG_RARE, amount, .line = __LINE__)
	}

	if (0 > amount)
	{
		g_iRareNameTag[target] += amount;
		if (0 > g_iRareNameTag[target])
		{
			g_iRareNameTag[target] = 0;
		}
		console_print(id, "%s Substracted %d Rare Name-Tags from %s", CONSOLE_PREFIX, amount, arg1)
	}
	else
	{
		if (0 < amount)
		{
			g_iRareNameTag[target] += amount;
			console_print(id, "%s You gave %s %d Rare Name-Tags", CONSOLE_PREFIX, arg1, amount)
		}
		return 1;
	}
	return 1;
}

public concmd_givemythicnametags(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 15);
	new target;
	if (arg1[0] == 64)
	{
		_GiveToAll(id, arg1, arg2, 6);
		return 1;
	}
	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}
	new amount = str_to_num(arg2);

	if(g_CvarStatsCountCmds)
	{
		AddStatistics(target, DROPPED_NAMETAG_MYTHICS, amount, .line = __LINE__)
	}

	if (0 > amount)
	{
		g_iMythicNameTag[target] += amount;
		if (0 > g_iMythicNameTag[target])
		{
			g_iMythicNameTag[target] = 0;
		}
		console_print(id, "%s Substracted %d Mythic Name-Tags from %s", CONSOLE_PREFIX, amount, arg1)
	}
	else
	{
		if (0 < amount)
		{
			g_iMythicNameTag[target] += amount;
			console_print(id, "%s You gave %s %d Mythic Name-Tags", CONSOLE_PREFIX, arg1, amount)
		}
		return 1;
	}
	return 1;
}

public concmd_giveglovecases(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 15);
	new target;
	if (arg1[0] == 64)
	{
		_GiveToAll(id, arg1, arg2, 8);
		return 1;
	}
	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}
	new amount = str_to_num(arg2);

	if(g_CvarStatsCountCmds)
	{
		AddStatistics(target, DROPPED_GLOVE_CASES, amount, .line = __LINE__)
	}

	if (0 > amount)
	{
		g_iGlovesCases[target] += amount;
		if (0 > g_iGlovesCases[target])
		{
			g_iGlovesCases[target] = 0;
		}
		console_print(id, "%s Substracted %d Glove Cases from %s", CONSOLE_PREFIX, amount, arg1)
	}
	else
	{
		if (0 < amount)
		{
			g_iGlovesCases[target] += amount;
			console_print(id, "%s You gave %s %d Glove Cases", CONSOLE_PREFIX, arg1, amount)
		}
		return 1;
	}
	return 1;
}

_GiveToAll(id, arg1[], arg2[], type)
{
	new Pl[32];
	new n;
	new target;
	new amount = str_to_num(arg2);
	if (amount)
	{
		switch (arg1[1])
		{
			case 65, 97:
			{
				get_players(Pl, n, "h", "");
			}
			case 67, 99:
			{
				get_players(Pl, n, "eh", "CT");
			}
			case 84, 116:
			{
				get_players(Pl, n, "eh", "TERRORIST");
			}
		}
		if (n)
		{
			switch (type)
			{
				case 0:
				{
					new i;
					while (i < n)
					{
						target = Pl[i];
						if (g_bLogged[target])
						{
							if (0 > amount)
							{
								g_iUserMoney[target] += amount;
								if (0 > g_iUserMoney[target])
								{
									g_iUserMoney[target] = 0
								}
							}
							else
							{
								g_iUserMoney[target] += amount
							}

							if(g_CvarStatsCountCmds)
							{
								AddStatistics(target, RECEIVED_MONEY, amount, .line = __LINE__)
							}
						}
						i++
					}
					if (0 < amount)
					{
						console_print(id, "%s You gave %d$ to @ALL", CONSOLE_PREFIX, amount);
					}
					else
					{
						console_print(id, "%s You substracted %d$ from @ALL", CONSOLE_PREFIX, amount);
					}
				}
				case 1:
				{
					new i
					while (i < n)
					{
						target = Pl[i];
						if (g_bLogged[target])
						{
							if (0 > amount)
							{
								g_iUserCases[target] += amount
								if (0 > g_iUserCases[target])
								{
									g_iUserCases[target] = 0
								}
							}
							else
							{
								g_iUserCases[target] += amount
							}

							if(g_CvarStatsCountCmds)
							{
								AddStatistics(target, DROPPED_CASES, amount, .line = __LINE__)
							}
						}
						i++;
					}
					if (0 < amount)
					{
						console_print(id, "%s You gave %d cases to @ALL", CONSOLE_PREFIX, amount);
					}
					else
					{
						console_print(id, "%s You substracted %d cases from @ALL", CONSOLE_PREFIX, amount);
					}
				}
				case 2:
				{
					new i
					while (i < n)
					{
						target = Pl[i];
						if (g_bLogged[target])
						{
							if (0 > amount)
							{
								g_iUserKeys[target] += amount
								if (0 > g_iUserKeys[target])
								{
									g_iUserKeys[target] = 0
								}
							}
							else
							{
								g_iUserKeys[target] += amount
							}

							if(g_CvarStatsCountCmds)
							{
								AddStatistics(target, DROPPED_KEYS, amount, .line = __LINE__)
							}
						}
						i++
					}
					if (0 < amount)
					{
						console_print(id, "%s You have %d keys to @ALL", CONSOLE_PREFIX, amount);
					}
					else
					{
						console_print(id, "%s You substracted %d keys from @ALL", CONSOLE_PREFIX, amount)
					}
				}
				case 3:
				{
					new i;
					while (i < n)
					{
						target = Pl[i];
						if (g_bLogged[target])
						{
							if (0 > amount)
							{
								g_iUserScraps[target] += amount
								if (0 > g_iUserScraps[target])
								{
									g_iUserScraps[target] = 0
								}
							}
							else
							{
								g_iUserScraps[target] += amount
							}

							if(g_CvarStatsCountCmds)
							{
								AddStatistics(target, RECEIVED_SCRAPS, amount, .line = __LINE__)
							}
						}
						i++;
					}
					if (0 < amount)
					{
						console_print(id, "%s You gave %d scraps to @ALL", CONSOLE_PREFIX, amount);
					}
					else
					{
						console_print(id, "%s You substracted %d scraps from @ALL", CONSOLE_PREFIX, amount);
					}
				}
				case 4:
				{
					new i;
					while (i < n)
					{
						target = Pl[i];
						if (g_bLogged[target])
						{
							if (0 > amount)
							{
								g_iCommonNameTag[target] += amount
								if (0 > g_iCommonNameTag[target])
								{
									g_iCommonNameTag[target] = 0
								}
							}
							else
							{
								g_iCommonNameTag[target] += amount
							}

							if(g_CvarStatsCountCmds)
							{
								AddStatistics(target, DROPPED_NAMETAG_COMMON, amount, .line = __LINE__)
							}
						}
						i++;
					}
					if (0 < amount)
					{
						console_print(id, "%s You gave %d Common name-tag to @ALL", CONSOLE_PREFIX, amount);
					}
					else
					{
						console_print(id, "%s You substracted %d Common name-tag from @ALL", CONSOLE_PREFIX, amount);
					}
				}

				case 5:
				{
					new i;
					while (i < n)
					{
						target = Pl[i];
						if (g_bLogged[target])
						{
							if (0 > amount)
							{
								g_iRareNameTag[target] += amount
								if (0 > g_iRareNameTag[target])
								{
									g_iRareNameTag[target] = 0
								}
							}
							else
							{
								g_iRareNameTag[target] += amount
							}

							if(g_CvarStatsCountCmds)
							{
								AddStatistics(target, DROPPED_NAMETAG_RARE, amount, .line = __LINE__)
							}
						}
						i++;
					}
					if (0 < amount)
					{
						console_print(id, "%s You gave %d Rare name-tag to @ALL", CONSOLE_PREFIX, amount);
					}
					else
					{
						console_print(id, "%s You substracted %d Rare name-tag from @ALL", CONSOLE_PREFIX, amount);
					}
				}

				case 6:
				{
					new i;
					while (i < n)
					{
						target = Pl[i];
						if (g_bLogged[target])
						{
							if (0 > amount)
							{
								g_iMythicNameTag[target] += amount
								if (0 > g_iMythicNameTag[target])
								{
									g_iMythicNameTag[target] = 0
								}
							}
							else
							{	
								g_iMythicNameTag[target] += amount
							}

							if(g_CvarStatsCountCmds)
							{
								AddStatistics(target, DROPPED_NAMETAG_MYTHICS, amount, .line = __LINE__)
							}
						}
						i++;
					}
					if (0 < amount)
					{
						console_print(id, "%s You gave %d Mythic name-tag to @ALL", CONSOLE_PREFIX, amount);
					}
					else
					{
						console_print(id, "%s You substracted %d Mythic name-tag from @ALL", CONSOLE_PREFIX, amount);
					}
				}

				case 7:
				{
					new i;
					while (i < n)
					{
						target = Pl[i];
						if (g_bLogged[target])
						{
							if (0 > amount)
							{
								g_iNameTagCapsule[target] += amount
								if (0 > g_iNameTagCapsule[target])
								{
									g_iNameTagCapsule[target] = 0
								}
							}
							else
							{	
								g_iNameTagCapsule[target] += amount
							}

							if(g_CvarStatsCountCmds)
							{
								AddStatistics(target, DROPPED_NAMETAG_CAPSULES, amount, .line = __LINE__)
							}
						}
						i++;
					}
					if (0 < amount)
					{
						console_print(id, "%s You gave %d Name-tag Capsule to @ALL", CONSOLE_PREFIX, amount);
					}
					else
					{
						console_print(id, "%s You substracted %d Name-tag Capsule from @ALL", CONSOLE_PREFIX, amount);
					}
				}

				case 8:
				{
					new i;
					while (i < n)
					{
						target = Pl[i];
						if (g_bLogged[target])
						{
							if (0 > amount)
							{
								g_iGlovesCases[target] += amount
								if (0 > g_iGlovesCases[target])
								{
									g_iGlovesCases[target] = 0
								}
							}
							else
							{	
								g_iGlovesCases[target] += amount
							}

							if(g_CvarStatsCountCmds)
							{
								AddStatistics(target, DROPPED_GLOVE_CASES, amount, .line = __LINE__)
							}
						}
						i++;
					}
					if (0 < amount)
					{
						console_print(id, "%s You gave %d Glove Cases to @ALL", CONSOLE_PREFIX, amount);
					}
					else
					{
						console_print(id, "%s You substracted %d Glove Cases from @ALL", CONSOLE_PREFIX, amount);
					}
				}
			}
		}
		else
		{
			console_print(id, "%s No players found in the chosen category [%s]", CONSOLE_PREFIX, arg1);
		}
		return PLUGIN_HANDLED;
	}
	console_print(id, "%s Index <amount> must not be 0", CONSOLE_PREFIX);
	return PLUGIN_HANDLED;
}

public concmd_setrank(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[8];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 7);
	new target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}
	new rank = str_to_num(arg2);
	if (rank < 0 || rank >= g_iRanksNum)
	{
		console_print(id, "%s Wrong RankID [0 - %d]", CONSOLE_PREFIX, g_iRanksNum + -1);
		return 1;
	}
	g_iUserRank[target] = rank;
	if (rank)
	{
		g_iUserKills[target] = ArrayGetCell(g_aRankKills, rank + -1);
	}
	else
	{
		g_iUserKills[target] = 0;
	}
	new szRank[32];
	ArrayGetString(g_aRankName, g_iUserRank[target], szRank, 31);
	console_print(id, "%s %s has been promoted to %s", CONSOLE_PREFIX, arg1, szRank);
	return 1;
}

public concmd_giveglove(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[16];
	new arg3[16];
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 2);
	read_argv(3, arg3, 3);
	new target;
	if (arg1[0] == 64)
	{
		_GiveToAll(id, arg1, arg2, 9);
		return 1;
	}
	target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}
	new amount = str_to_num(arg3);
	new iGloveID = str_to_num(arg2);
	if ( iGloveID < 0 || iGloveID > 4)
	{
		console_print(id, "%s Invalid Glove ID (0-4)", CONSOLE_PREFIX);
		return PLUGIN_HANDLED;
	}

	if (0 > amount)
	{
		g_iUserGloves[target][iGloveID] -= amount;
		if (0 > g_iUserGloves[target][iGloveID])
		{
			g_iUserGloves[target][iGloveID] = 0;
		}
		console_print(id, "%s Substracted %d Glove Cases from %s", CONSOLE_PREFIX, amount, arg1)
	}
	else
	{
		if (0 < amount)
		{
			new eGlove[GLOVESINFO];
			ArrayGetArray(g_aGloves, iGloveID, eGlove);
			g_iUserGloves[target][iGloveID] += amount;
			console_print(id, "%s You gave %s %d %s", CONSOLE_PREFIX, arg1, amount, eGlove[szGloveName])
		}
	}

	if(g_CvarStatsCountCmds)
	{
		AddStatistics(target, DROPPED_GLOVES, amount, .gloveid = iGloveID, .line = __LINE__)
	}

	save_user_gloves(target)

	return 1;
}

public concmd_giveskins(id, level, cid)
{
	if (!cmd_access(id, level, cid, 5, false))
	{
		return 1;
	}
	new arg1[32];
	new arg2[8];
	new arg3[16];
	new arg4[2]
	read_argv(1, arg1, 31);
	read_argv(2, arg2, 7);
	read_argv(3, arg3, 15);
	read_argv(4, arg4, 1);
	new target = cmd_target(id, arg1, 3);
	if (!target)
	{
		console_print(id, "%s %s was not found", CONSOLE_PREFIX, arg1)
		return 1;
	}

	if(!g_bLogged[target])
	{
		console_print(id, "%s %s is not logged in", CONSOLE_PREFIX, arg1)
		return 1
	}

	new skin = str_to_num(arg2), bool:bAll = bool:(arg2[0] == '@')
	if (!bAll && (skin < 0 || skin >= g_iSkinsNum))
	{
		console_print(id, "%s Wrong skin ID [0 - %d]", CONSOLE_PREFIX, g_iSkinsNum - 1);
		return 1;
	}

	new amount = str_to_num(arg3);
	new szSkin[32];
	
	if(!bAll)
	{
		ArrayGetString(g_aSkinName, skin, szSkin, 31);
	}
	
	if (0 > amount)
	{
		g_iUserSkins[target][skin] -= amount;
		if (0 > g_iUserSkins[target][skin])
		{
			g_iUserSkins[target][skin] = 0;
		}
		
		new bool:bStt = bool:str_to_num(arg4)
		if(bStt)
		{
			if(bAll)
			{
				for(new i;i <= g_iSkinsNum;i++)
				{
					g_bIsWeaponStattrak[target][i] = false
					g_iUserStattrakKillCount[target][i] = 0
				}
			}
			else
			{
				g_bIsWeaponStattrak[target][skin] = false
				g_iUserStattrakKillCount[target][skin] = 0
			}
			
			format(szSkin, charsmax(szSkin), "StatTrak %s", szSkin)
		}
		
		if(bAll)
		{
			szSkin = "Everything"
		}	

		console_print(id, "%s You substracted %d pieces of %s from %s", CONSOLE_PREFIX, amount, szSkin, arg1)
	}
	else
	{
		if (0 < amount)
		{
			if(amount > SKIN_LIMIT)
			{
				amount = SKIN_LIMIT
			}
			
			new bool:bStt = bool:str_to_num(arg4)

			new iSkinLimit = SKIN_LIMIT

			if(bAll)
			{
				for(new i;i <= g_iSkinsNum;i++)
				{
					if(g_iUserSkins[target][i] + amount >= SKIN_LIMIT)
					{			
						if(g_CvarStatsCountCmds)
						{
							if(g_iUserSkins[target][i] < SKIN_LIMIT)
							{
								if(bStt && !g_bIsWeaponStattrak[target][i])
								{
									AddStatistics(target, DROPPED_STT_SKINS, 1, i, .line = __LINE__)
									AddStatistics(target, DROPPED_SKINS, iSkinLimit - g_iUserSkins[target][i] - 1, i, .line = __LINE__)
								}
								else 
								{
									AddStatistics(target, DROPPED_SKINS, iSkinLimit - g_iUserSkins[target][i], i, .line = __LINE__)
								}
							}
						}

						g_iUserSkins[target][i] = SKIN_LIMIT
					}
					else 
					{
						if(g_CvarStatsCountCmds)
						{
							AddStatistics(target, (bStt && !g_bIsWeaponStattrak[target][i]) ? DROPPED_STT_SKINS : DROPPED_SKINS, amount, i, .line = __LINE__)
						}

						g_iUserSkins[target][i] += amount
					}
					
					if(!bStt && g_bIsWeaponStattrak[target][i])
						continue
						
					g_bIsWeaponStattrak[target][i] = bStt

				}
			}
			else
			{
				g_iUserSkins[target][skin] += amount
				if(g_iUserSkins[target][skin] > SKIN_LIMIT)
				{
					g_iUserSkins[target][skin] = SKIN_LIMIT
				}

				if(bStt)
				{
					g_bIsWeaponStattrak[target][skin] = true

				}

				if(g_CvarStatsCountCmds)
				{
					AddStatistics(target, bStt ? DROPPED_STT_SKINS : DROPPED_SKINS, amount, skin, .line = __LINE__)
				}
			}

			
			if(bStt)
			{
				format(szSkin, charsmax(szSkin), "StatTrak %s", bAll ? "Everything" : szSkin)
			}
			else
			{
				format(szSkin, charsmax(szSkin), "%s", bAll ? "Everything" : szSkin)
			}

			console_print(id, "%s You gave %s %d pieces of %s", CONSOLE_PREFIX, arg1, amount, szSkin);
		}
	}
	return PLUGIN_HANDLED;
}

public native_is_warmup(iPluginID, iParamNum)
{
	return g_bWarmUp;
}

public native_get_warmup_time(iPluginID, iParamNum)
{
	return g_iTimer;
}

public native_get_weapon_max_skins(iPluginID, iParamNum)
{
	new iWeaponID = get_param(1);
	return getMaxSkinsOfWeapon(iWeaponID);
}

public native_get_skin_weaponid(iPluginID, iParamNum)
{
	new index = get_param(1)
	return ArrayGetCell(g_aSkinWeaponID, index);
}

public native_get_skin_name(iPluginID, iParamNum)
{
	new iWeaponID = get_param(1);
	new szSkinName[100];
	_GetItemName(iWeaponID, szSkinName, charsmax(szSkinName));
	set_string(2, szSkinName, get_param(3));

	return 1;
}

public native_get_skins_num(iPluginID, iParamNum)
{
	return g_iSkinsNum;
}

public native_get_skin_level(iPluginID, iParamNum)
{
	new id = get_param(1);
	new iWeaponID = get_param(2);

	return g_iNameTagSkinLevel[id][iWeaponID];
}

public native_csgo_get_prefixes(iPluginID, iParamNum)
{
	set_string(1, CHAT_PREFIX, get_param(2))
	set_string(3, MENU_PREFIX, get_param(4))
}

public any:native_csgo_directory(iPluginID, iParamNum)
{
	set_string(1, CSGO_CONFIG_DIRECTORY, get_param(2))
}

public any:native_display_menu(iPluginID, iParamNum)
{
	new id = get_param(1);

	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	if(!g_bLogged[id])
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not logged in [%d]", id);
		return NativeErrorCode:USER_NOT_LOGGED;
	}

	new MenuCode:menu_code = MenuCode:get_param(2)

	switch(MenuCode:menu_code)
	{
		case MENU_MAIN:
		{
			_ShowMainMenu(id)
		}

		case MENU_INVENTORY:
		{
			ShowInventoryMenu(id)
		}
		
		case MENU_GAMBLING:
		{
			_ShowGamesMenu(id)
		}

		case MENU_SETTINGS:
		{
			OpenSettingsMenu(id)
		}

		default:
		{
			log_error(AMX_ERR_NATIVE, "[CSGO Classy] Menu code is invalid [%d]", _:menu_code)
			return NativeErrorCode:INVALID_MENU_CODE
		}
	}

	return 1
}

public native_is_in_preview(iPluginID, iParamNum)
{
	new id = get_param(1);

	return bool:g_bIsInPreview[id];
}

public native_has_skin_tag(iPluginID, iParamNum)
{
	new id = get_param(1);
	new iWeaponID = get_param(2);

	return g_bHasSkinTag[id][iWeaponID];
}

public native_get_skin_tag(iPluginID, iParamNum)
{
	new id = get_param(1);
	new index = get_param(2);
	new buffermaxlength = get_param(4);

	set_string(3, g_szSkinsTag[id][index], buffermaxlength);

	return 1;
}

public native_was_warmup(iPluginID, iParamNum)
{
	return g_bWasWarmUp;
}

public native_force_user_log_in(iPluginID, iParamNum)
{
	new id = get_param(1);
	new bool:value = bool:get_param(2);

	_LoadData(id);

	if(!g_szUserSavedPass[id][0])
		return -1;

	switch(value)
	{
		case false:
		{
			g_bLogged[id] = value;
			fadescreen(id, 70, 1);
		}
		case true:
		{
			g_bLogged[id] = value;
			ExecuteForward(g_eForwards[LOGIN], _, id);

			set_task_ex(1.0, "playerAddTime", id + TASK_PLAYED_TIME, .flags = SetTask_Repeat)
		}
	}

	return 1;
}

public native_round_num(iPluginID, iParamNum)
{
	return g_iRoundNum;
}

public any:native_get_user_capsules(iPluginID, iParamNum)
{
	new id = get_param(1);
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	return g_iNameTagCapsule[id];
}

public any:native_get_user_common(iPluginID, iParamNum)
{
	new id = get_param(1);

	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	return g_iCommonNameTag[id];
}

public any:native_get_user_rare(iPluginID, iParamNum)
{
	new id = get_param(1);

	if(!g_bLogged[id])
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not logged in [%d]", id);
		return NativeErrorCode:USER_NOT_LOGGED;
	}

	return g_iRareNameTag[id];
}

public any:native_get_user_mythic(iPluginID, iParamNum)
{
	new id = get_param(1);
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	return g_iMythicNameTag[id];
}

public any:native_csgo_get_mysql(iPluginID, iParamNum)
{
	if(g_CvarSaveType == NVAULT)
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid save type. Must be MySQL")
		return NativeErrorCode:INVALID_SAVE_TYPE 
	}

	new iLengths[4]

	iLengths[0] = get_param(2)
	iLengths[1] = get_param(4)
	iLengths[2] = get_param(6)
	iLengths[3] = get_param(8)

	if(iLengths[0] > 0)
	{
		set_string(1, MYSQL[SQL_HOST], iLengths[0])
	}
	if(iLengths[1] > 0)
	{
		set_string(3, MYSQL[SQL_USER], iLengths[1])
	}
	
	if(iLengths[2] > 0)
	{
		set_string(5, MYSQL[SQL_PASS], iLengths[2])
	}
	
	if(iLengths[3] > 0)
	{
		set_string(7, MYSQL[SQL_DB], iLengths[3])
	}
	
	return g_SqlTuple;
}

public any:native_get_user_password(iPluginID, iParamNum)
{
	new id = get_param(1);

	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	set_string(2, g_szUserSavedPass[id], get_param(3));

	return 1;
}


public any:native_get_user_money(iPluginID, iParamNum)
{
	new id = get_param(1);
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	return g_iUserMoney[id];
}

public any:native_set_user_money(iPluginID, iParamNum)
{
	new id = get_param(1);
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	if(!g_bLogged[id])
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not logged in [%d]", id);
		return NativeErrorCode:USER_NOT_LOGGED;
	}

	new amount = get_param(2);
	if (0 > amount)
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid amount value [%d]", amount);
		return NativeErorCode:INVALID_PARAM_VALUE;
	}

	g_iUserMoney[id] = amount;

	return 1;
}

public any:native_get_user_cases(iPluginID, iParamNum)
{
	new id = get_param(1)
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	return g_iUserCases[id];
}

public any:native_set_user_cases(iPluginID, iParamNum)
{
	new id = get_param(1);
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	if(!g_bLogged[id])
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not logged in [%d]", id);
		return NativeErrorCode:USER_NOT_LOGGED;
	}

	new amount = get_param(2);
	if (0 > amount)
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid amount value [%d]", amount);
		return NativeErrorCode:INVALID_PARAM_VALUE;
	}

	g_iUserCases[id] = amount;

	return 1;
}

public any:native_get_user_keys(iPluginID, iParamNum)
{
	new id = get_param(1);
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	return g_iUserKeys[id];
}

public any:native_set_user_keys(iPluginID, iParamNum)
{
	new id = get_param(1);
	
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	if(!g_bLogged[id])
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not logged in [%d]", id);
		return NativeErrorCode:USER_NOT_LOGGED;
	}

	new amount = get_param(2);
	if (0 > amount)
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid amount value [%d]", amount);
		return NativeERrorCode:INVALID_PARAM_VALUE;
	}

	g_iUserKeys[id] = amount;

	return 1;
}

public any:native_get_user_scraps(iPluginID, iParamNum)
{
	new id = get_param(1);
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	return g_iUserScraps[id];
}

public any:native_set_user_scraps(iPluginID, iParamNum)
{
	new id = get_param(1);
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	if(!g_bLogged[id])
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not logged in [%d]", id);
		return NativeErrorCode:USER_NOT_LOGGED;
	}

	new amount = get_param(2);
	if (0 > amount)
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid amount value [%d]", amount);
		return NativeErrorCode:INVALID_PARAM_VALUE;
	}

	g_iUserScraps[id] = amount;

	return 1;
}

public any:native_get_user_rank(iPluginID, iParamNum)
{
	new id = get_param(1);

	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	new szRank[32];
	ArrayGetString(g_aRankName, g_iUserRank[id], szRank, charsmax(szRank));
	
	set_string(2, szRank, get_param(3));
	return g_iUserRank[id];
}

public any:native_get_user_rank_id(iPluginID, iParamNum)
{
	new id = get_param(1);

	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	return g_iUserRank[id];
}

public any:native_is_using_default_skins(iPluginID, iParamNum)
{
	new id = get_param(1);

	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	return g_bUserDefaultModels[id];
}

public any:native_set_user_rank(iPluginID, iParamNum)
{	
	new id = get_param(1);
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED
	}

	if(!g_bLogged[id])
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not logged in [%d]", id);
		return NativeErrorCode:USER_NOT_LOGGED;
	}

	new rank = get_param(2);
	if (rank < 0 || rank >= g_iRanksNum)
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid RankID [%d]", rank);
		return NativeErrorCode:INVALID_PARAM_VALUE;
	}

	g_iUserRank[id] = rank;
	g_iUserKills[id] = ArrayGetCell(g_aRankKills, rank + -1);
	return 1;
}

public any:native_get_user_skins(iPluginID, iParamNum)
{
	new id = get_param(1);
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	new skin = get_param(2);
	if (skin < 0 || skin >= g_iSkinsNum)
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid SkinID [%d]", skin);
		return NativeErrorCode:INVALID_PARAM_VALUE;
	}
	new amount = g_iUserSkins[id][skin];
	return amount;
}

public _getCurrentSkin()
{
	return g_iUserSelectedSkin[get_param(1)][get_param(2)]
}

public any:native_csgo_register_menu(iPluginID, iParams)
{
	new eMenuData[MENU_DATA]; eMenuData[iMinRankAccess] = get_param(3)

	if(eMenuData[iMinRankAccess] < -1 || eMenuData[iMinRankAccess] > ArraySize(g_aRankName))
	{
		log_error(AMX_ERR_NATIVE, fmt("[CSGO Classy] Minimum rankid is too %s [%d]", eMenuData[iMinRankAccess] < 0 ? "small" : "high", eMenuData[iMinRankAccess]))
		return NativeErrorCode:INVALID_RANK_ID
	}

	get_string(2, eMenuData[szMenuName], charsmax(eMenuData[szMenuName]))

	new const MenuCode:menu_code = MenuCode:get_param(1)

	eMenuData[tUserMenuData] = TrieCreate()

	ArrayPushArray(g_aeMenus[MENU_ITEMS:menu_code], _:eMenuData)
	new iReturnedMenuID = ArraySize(g_aeMenus[MENU_ITEMS:menu_code])

	return g_cItemCounter[_:menu_code] + iReturnedMenuID - 1
}

public any:native_csgo_additional_menu_name(iPluginID, iParams)
{
	new const MenuCode:menu_code = MenuCode:get_param(1)

	if(_:menu_code < 0 || MENU_ITEMS:menu_code > MENU_ITEMS)
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid menu code [%d]", _:menu_code)
		return NativeErrorCode:INVALID_MENU_ID
	}

	new const id = get_param(3)

	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	new const iMenuID = get_param(2)

	if(iMenuID < g_cItemCounter[_:menu_code] || iMenuID > (ArraySize(g_aeMenus[MENU_ITEMS:menu_code]) + g_cItemCounter[_:menu_code]))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid menu id [%s]", iMenuID)
		return NativeErrorCode:INVALID_MENU_ID
	}

	new eMenuData[MENU_DATA], szParamString[MAX_MENU_ADDITIONAL_NAME_LENGTH]
	ArrayGetArray(g_aeMenus[MENU_ITEMS:menu_code], iMenuID - g_cItemCounter[_:menu_code], eMenuData)

	get_string(4, szParamString, charsmax(szParamString))


	if(MenuCode:menu_code == MenuCode:MENU_INVENTORY)
	{
		new eUserMenuData[USER_MENU_DATA]

		TrieGetArray(eMenuData[tUserMenuData], fmt("%d", id), eUserMenuData, sizeof(eUserMenuData))

		copy(eUserMenuData[szAdditionalName], charsmax(eUserMenuData[szAdditionalName]), szParamString)

		TrieSetArray(eMenuData[tUserMenuData], fmt("%d", id), eUserMenuData, sizeof(eUserMenuData))
	}
	else 
	{
		TrieSetString(eMenuData[tUserMenuData], fmt("%d", id), szParamString)
	}

	ArraySetArray(g_aeMenus[MENU_ITEMS:menu_code], iMenuID - g_cItemCounter[_:menu_code], eMenuData)

	return 1;
}

public any:native_csgo_add_inventory_item_value(iPluginID, iParams)
{
	new const id = get_param(1)
	
	if (!IsValidPlayer(id) || !is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED;
	}

	new const MenuCode:menu_code = MenuCode:MENU_INVENTORY
	new const iMenuID = get_param(2)

	if(iMenuID < g_cItemCounter[_:menu_code] || iMenuID > (ArraySize(g_aeMenus[MENU_ITEMS:menu_code]) + g_cItemCounter[_:menu_code]))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid menu id [%s]", iMenuID)
		return NativeErrorCode:INVALID_MENU_ID
	}

	new eMenuData[MENU_DATA]

	ArrayGetArray(g_aeMenus[MENU_ITEMS:menu_code], iMenuID - g_cItemCounter[_:menu_code], eMenuData)
	
	new eUserMenuData[USER_MENU_DATA]
	eUserMenuData[iInventoryValue] = get_param(3)

	TrieSetArray(eMenuData[tUserMenuData], fmt("%d", id), eUserMenuData, sizeof(eUserMenuData))
	ArraySetArray(g_aeMenus[MENU_ITEMS:menu_code], iMenuID - g_cItemCounter[_:menu_code], eMenuData)

	return 1
}

public any:native_set_user_skins(iPluginID, iParamNum)
{
	new id = get_param(1)
	if(!g_bLogged[id])
	{
		log_error(AMX_ERR_NATIVE, "User is not logged in (set_user_skins)")
		return NativeErrorCode:USER_NOT_LOGGED
	}

	new iSkinID = get_param(2)

	if(iSkinID < 0 || iSkinID > g_iSkinsNum)
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid SkinID [%d]", iSkinID);
		return NativeErrorCode:INVALID_PARAM_VALUE
	}

	if(!is_user_connected(id) || !IsValidPlayer(id))
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Player is not connected [%d]", id);
		return NativeErrorCode:USER_NOT_CONNECTED
	}


	if(get_param(3) > SKIN_LIMIT)
	{
		log_error(AMX_ERR_NATIVE, "[CSGO Classy] Invalid skin amount [%d]. Maximum is %d", get_param(3), SKIN_LIMIT);
		return NativeErrorCode:INVALID_PARAM_VALUE
	}

	g_iUserSkins[id][iSkinID] = get_param(3)

	g_bIsWeaponStattrak[id][iSkinID] = bool:get_param(4)

	return 1
}

public any:native_is_user_logged(iPluginID, iParamNum)
{
	return g_bLogged[get_param(1)];
}

public _allow()
{
	new id = get_param(1)
	
	_LoadData(id)
	g_bLogged[id] = true;
	
	fadescreen(id, 70, 2);


	if(is_user_alive(id))
	{
		new iActiveItem = get_member_s(id, m_pActiveItem)
		ExecuteHamB(Ham_Item_Deploy, iActiveItem);
	}	
	
	ExecuteForward(g_eForwards[LOGIN], _, id);

	set_task_ex(1.0, "playerAddTime", id + TASK_PLAYED_TIME, .flags = SetTask_Repeat)
	_ShowMainMenu(id)
}

public _checku()
{
	return g_bUsingM4A4[get_param(1)]
}

public _setRandom()
{
	new id = get_param(1), iRandomSkin = random_num(0, g_iSkinsNum)
	g_iUserSkins[id][iRandomSkin]++

	new model[256];
	ArrayGetString(g_aSkinName, iRandomSkin, model, charsmax(model))
	set_string(2, model, charsmax(model))
}

public _update()
{
	new id = get_param(1), iWeaponID = get_param(2), userskin = get_param(3)
	if(get_user_weapon(id) == iWeaponID)
	{
		if(userskin == -1)
			return
			
		if(userskin == DEFAULT_SKIN)
			return

		new model[256];
		ArrayGetString(g_aSkinModel, userskin, model, charsmax(model))
	}
}

public _getSkinName()
{
	new id = get_param(1)
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
		
	new iWeaponId = get_param(2)
	if(g_iUserSelectedSkin[id][iWeaponId] == -1)
		return PLUGIN_HANDLED
		
	new szSkin[50]
	new i, num, iKillCount
	while (i < g_iSkinsNum)
	{
		num = g_iUserSkins[id][i];
		if (num > 0)
		{
			if (i == g_iUserSelectedSkin[id][iWeaponId])
			{
				if(g_bIsWeaponStattrak[id][i] && g_bShallUseStt[id][iWeaponId])
				{
					iKillCount = g_iUserStattrakKillCount[id][i]
					ArrayGetString(g_aSkinName, i, szSkin, charsmax(szSkin))
					break
				}
			}
		}
		i++
	}
	
	set_string(3, szSkin, charsmax(szSkin))
	return iKillCount
}

public concmd_finddata(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2, false))
	{
		return 1
	}
	new arg1[32]
	read_argv(1, arg1, 31)
	if (g_nVaultAccounts == -1)
	{
		console_print(id, "%s Reading from vault has failed", CONSOLE_PREFIX)
		return 1
	}
	new Data[64]
	new Timestamp
	if (nvault_lookup(g_nVaultAccounts, arg1, Data, 63, Timestamp))
	{
		new userData[9][16]
		new password[16]
		new buffer[48]

		strtok(Data, password, 15, Data, 63, 61, 0)
		strtok(Data, buffer, 47, Data, 63, 42, 0)
		new i
		while (i < sizeof(userData))
		{
			strtok(buffer, userData[i], 15, buffer, 47, 44, 0)
			i++
		}
		new rank = str_to_num(userData[5])
		new szRank[32]
		ArrayGetString(g_aRankName, rank, szRank, 31)
		console_print(id, "[CSGO Classy]========================>")
		console_print(id, "%s Name: %s", CONSOLE_PREFIX, arg1)
		console_print(id, "%s Password: %s", CONSOLE_PREFIX, password)
		console_print(id, "%s Money: %s$", CONSOLE_PREFIX, userData[0])
		console_print(id, "%s Rank: %s", CONSOLE_PREFIX, szRank)
		console_print(id, "%s Keys: %s", CONSOLE_PREFIX, userData[2])
		console_print(id, "%s Cases: %s", CONSOLE_PREFIX, userData[3])
		console_print(id, "%s Scraps: %s", CONSOLE_PREFIX, userData[1])
		console_print(id, "%s Total kills: %s", CONSOLE_PREFIX, userData[4])
		console_print(id, "%s Name-Tag Capsules: %s", CONSOLE_PREFIX, userData[5]);
		console_print(id, "%s Common Name-Tags: %s", CONSOLE_PREFIX, userData[6]);
		console_print(id, "%s Rare Name-Tags: %s", CONSOLE_PREFIX, userData[7]);
		console_print(id, "%s Mythic Name-Tags: %s", CONSOLE_PREFIX, userData[8]);
		console_print(id, "[CSGO Classy]========================>")
	}
	else
	{
		console_print(id, "%s This account was not found [%s]", CONSOLE_PREFIX, arg1)
	}
	return 1
}

public concmd_resetdata(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}

	new szArgName[MAX_NAME_LENGTH], bool:bFound
	read_argv(1, szArgName, charsmax(szArgName))

	switch(g_CvarSaveType)
	{
		case SQL:
		{
			new szArgSqlName[192]
			
			copy(szArgSqlName, charsmax(szArgSqlName), szArgName)
			mysql_escape_string(szArgSqlName, charsmax(szArgSqlName))

			new szQuery[512], szData[256]
			formatex(szQuery, charsmax(szQuery), "DELETE %s, %s FROM %s JOIN %s ON %s.uname = %s.uname WHERE %s.uname = '%s'",
			g_szTables[PLAYER_DATA], g_szTables[PLAYER_SKINS], g_szTables[PLAYER_DATA], g_szTables[PLAYER_SKINS], g_szTables[PLAYER_DATA], g_szTables[PLAYER_SKINS], g_szTables[PLAYER_DATA], szArgSqlName)

			formatex(szData, charsmax(szData), "%d ^"%s^"", id, szArgName)
			SQL_ThreadQuery(g_SqlTuple, "ResetSQLData", szQuery, szData, sizeof(szData))
		}

		case NVAULT:
		{
			new szData[2], iTs;

			if(nvault_lookup(g_nVaultAccounts, szArgName, szData, charsmax(szData), iTs))
			{
				nvault_remove(g_nVaultAccounts, szArgName)
				nvault_remove(g_nVaultSkinTags, szArgName)
				nvault_remove(g_nVaultPlayerTags, szArgName)
				nvault_remove(g_nVaultNameTagsLevel, szArgName)
				nvault_remove(g_nVaultGloves, szArgName)
				nvault_remove(g_nVaultWeaponGloves, szArgName)
				nvault_remove(g_nVaultStattrak, szArgName)
				nvault_remove(g_nVaultStattrakKills, szArgName)
				
				bFound = true 
			}
		}
	}

	if(g_CvarSaveType == NVAULT)
	{
		if(!bFound)
		{
			client_print(id, print_console, "%s %l", CONSOLE_PREFIX, "DATA_RESET_NOT_FOUND", szArgName)
		}
		else 
		{
			client_print(id, print_console, "%s %l", CONSOLE_PREFIX, "DATA_RESETED_CONSOLE", szArgName)
		}
	}

	new iPlayer = find_player_ex(FindPlayer_MatchName, szArgName)

	if(iPlayer)
	{
		if(is_user_connected(iPlayer))
		{
			client_print_color(0, print_team_default, "^4-^3--------------------------^4-")
			client_print_color(0, print_team_default, "%s %l", CHAT_PREFIX, "DATA_RESETED_CONNECTED_USER_CHAT", szArgName)
			client_print_color(0, print_team_default, "^4-^3--------------------------^4-")
			g_bAccountReseted[iPlayer] = true
		}

		if(g_bLogged[iPlayer])
		{
			g_bLogged[iPlayer] = false
		}

		if(is_user_alive(iPlayer))
		{
			fadescreen(id, 70, 1);
		}
	}

	return PLUGIN_HANDLED
}

public ResetSQLData(FailState, Handle:Query, szError[], ErrorCode, szData[], iSize)
{
	if(FailState || ErrorCode)
	{
		log_to_file(LOG_FILE, "[LINE: %i] An SQL Error has been encoutered. Error code %i^nError: %s", __LINE__, ErrorCode, szError);
		SQL_FreeHandle(Query)
		return
	}

	new id, szId[5], szArgName[MAX_NAME_LENGTH]

	parse(szData, szId, charsmax(szId), szArgName, charsmax(szArgName))
	id = str_to_num(szId)

	new iAffectedRows = SQL_AffectedRows(Query)

	if(iAffectedRows > 0)
	{
		client_print(id, print_console, "%s %l", CONSOLE_PREFIX, "DATA_RESETED_SQL", szArgName, iAffectedRows)
	}
	else 
	{
		client_print(id, print_console, "%s %l", CONSOLE_PREFIX, "DATA_RESET_NOT_FOUND", szArgName)
	} 

	SQL_FreeHandle(Query);

	return
}

public concmd_kill(id)
{
	console_print(id, "[CSGO Classy] You can not commit suicide")
	return FMRES_SUPERCEDE
}

public client_death(killer, victim, weapon, hitplace)
{	
	if(killer == victim)
	{
		g_iRangExp[killer] -= 10
		return PLUGIN_CONTINUE
	}
	
	if(!(hitplace == HIT_HEAD) && !(weapon == CSW_HEGRENADE) && !(weapon == CSW_KNIFE))
	{
		g_iRangExp[killer]++;
	}

	if(hitplace == HIT_HEAD && weapon != CSW_KNIFE)
	{
		g_iRangExp[killer] += 3;
	}

	if(weapon == CSW_KNIFE && hitplace != HIT_HEAD)
	{
		g_iRangExp[killer] += 5;
	}

	if(weapon == CSW_KNIFE && hitplace == HIT_HEAD)
	{
		g_iRangExp[killer] += 7;
	}

	if(weapon == CSW_HEGRENADE)
	{
		g_iRangExp[killer] += 5;
	}

	check_level(killer)

	return PLUGIN_CONTINUE
}

public check_level(id)
{
	new szRangName[MAX_RANG_NAME_LENGTH]

	while(g_iRang[id] + 1 < ArraySize(g_aRangExp) && ArrayGetCell(g_aRangExp, g_iRang[id] + 1) <= g_iRangExp[id])
	{
		g_iRang[id]++

		g_iUserMoney[id] += g_CvarRangUpBonus

		ArrayGetString(g_aRangName, g_iRang[id], szRangName, charsmax(szRangName))

		client_print_color(0, print_team_default, "%s^3 %l", CHAT_PREFIX, "CHAT_RANG_UP", id, szRangName, AddCommas(g_CvarRangUpBonus), AddCommas(g_iRangExp[id]))
	}
}

public showStatus(id)
{
	if(!is_user_bot(id) && is_user_connected(id)) 
	{
		new name[MAX_NAME_LENGTH]
		new pid = read_data(2);
		
		new szRank[32];
		ArrayGetString(g_aRankName, g_iUserRank[pid], szRank, charsmax(szRank));
		
		get_user_name(pid, name, charsmax(name));
	
		if (get_user_team(id) == get_user_team(pid)) 
		{
			set_hudmessage(47, 79, 79, -1.0, 0.57, 0, 1.0, 2.0)
		}
		else 
		{
			set_hudmessage(255, 0, 0, -1.0, 0.57, 0, 1.0, 2.0)
		}

		new szRangName[MAX_RANG_NAME_LENGTH]
		ArrayGetString(g_aRangName, rank[pid], szRangName, charsmax(szRangName))
		
		new iNeededExp
		
		if(rank[pid] >= ArraySize(g_aRangExp))
		{
			iNeededExp = ArrayGetCell(g_aRangExp, rank[pid])
		}
		else 
		{
			iNeededExp = ArrayGetCell(g_aRangExp, rank[pid] + 1)
		}
		
		ShowSyncHudMsg(id, g_status_sync, "%s ^n%s ^n%s [%d/%d]", name, szRank, szRangName, g_iRangExp[pid], iNeededExp)
	}
}

public hideStatus(id)
{
	ClearSyncHud(id, g_status_sync);
}

stock bool:notAnySkins(id)
{
	new iTotal = 0;

	for(new i; i < g_iSkinsNum; i++)
	{
		if(g_iUserSkins[id][i] > 0)
		{
			iTotal++
		}
	}

	return iTotal == 0 ? true : false
}

public joinGiveaway(id)
{
	if(g_bGiveAwayStarted)
	{
		client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "GIVEAWAY_INFO", g_GiveawayDelay - 3)
		return PLUGIN_HANDLED
	}
	
	new iMenu = menu_create(fmt("%s \wGiveaway", MENU_PREFIX), "ga_handler"), szItem[128]

	if(total_players() >= g_CvarGiveawayMinPlayers)
	{
		formatex(szItem, charsmax(szItem), "Skin \r[StatTrak %s]", g_szSkinName)
		menu_additem(iMenu, szItem)

		formatex(szItem, charsmax(szItem), "Players \r[%d]", getGiveAwayPlayersNum())
		menu_additem(iMenu, szItem)

		if((g_GiveawayDelay - g_iCurrentRound) == 0)
		{
			formatex(szItem, charsmax(szItem), "Countdown \r[Now]^n", (g_GiveawayDelay - g_iCurrentRound))
		}
		else
		{
			formatex(szItem, charsmax(szItem), "Countdown \r[%d rounds left]^n", (g_GiveawayDelay - g_iCurrentRound))
		}

		menu_additem(iMenu, szItem)

		if(g_bJoinedGiveAway[id] == true)
		{
			formatex(szItem, charsmax(szItem), "%L", id, "GIVEAWAY_ALREADY_JOINED")
		}
		else
		{
			formatex(szItem, charsmax(szItem), "%L", id, "GIVEAWAY_JOIN")
		}
		
		menu_additem(iMenu, szItem)
	}
	else 
	{
		menu_additem(iMenu, "\dNot enough players to start giveaway")
	}


	if(is_user_connected(id))
	{
		menu_display(id, iMenu)
	}
	else 
	{
		menu_destroy(iMenu)
	}

	return PLUGIN_HANDLED
}

public ga_handler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		_ShowMainMenu(id)
		return PLUGIN_HANDLED
	}

	if(total_players() < g_CvarRoundEndSounds)
	{
		menu_destroy(iMenu);
		joinGiveaway(id);
		return PLUGIN_HANDLED;
	}

	switch(iItem)
	{
		case 0, 1, 2: 
		{
			joinGiveaway(id)
			menu_destroy(iMenu)
			return PLUGIN_HANDLED
		}
		case 3:
		{
			if(g_bJoinedGiveAway[id])
			{
				joinGiveaway(id)
				menu_destroy(iMenu)
				return PLUGIN_HANDLED
			}
			
			if(g_iUserSkins[id][g_iSkinID] >= SKIN_LIMIT)
			{
				client_print_color(id, id, "^4%s^1 %L", CHAT_PREFIX, id, "CANT_JOIN_GIVEAWAY", g_szSkinName)
				joinGiveaway(id)
				return PLUGIN_HANDLED
			}
				
			g_bJoinedGiveAway[id] = true
			new szName[32]
			get_user_name(id, szName, charsmax(szName))
			client_print_color(0, id, "^4%s^1 %L", CHAT_PREFIX, id, "JOINED_GIVEAWAY", szName)
		}
	}
	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}

public event_RoundStart(id)
{
	if(g_bGiveAwayStarted)
		return
	
	if(g_bWarmUp)
	{
		g_bGiveAwayStarted = true
	}

	if(total_players() >= 2)
		g_iCurrentRound++

	if(g_iCurrentRound >= g_GiveawayDelay)
	{
		if(!getGiveAwayPlayersNum())
		{
			g_bGiveAwayStarted = true
			client_print_color(0, 0, "^4%s^1 %L", CHAT_PREFIX, id, "NOBODY_JOINED_GIVEAWAY")
			return
		}
		set_task(1.0, "countDown", .flags = "a", .repeat = 10)
	}
}

total_players()
{
	new iNum;

	get_players_ex(_, iNum, GetPlayers_ExcludeBots|GetPlayers_ExcludeHLTV);

	return iNum;
}

public countDown()
{
	static iTime

	if(!iTime)
	{
		iTime = 10
	}

	set_hudmessage(random(255), random(255), random(255), 0.02, 0.30, 0, 0.0, 0.8)
	show_dhudmessage(0, "The Giveaway winner will be choosen in %d second%s", iTime, iTime < 2 ? "" : "s")

	iTime--
	
	if(!iTime)
	{
		new iWinner = getRandomWinner()

		if(iWinner == -1)
			return

		g_iUserSkins[iWinner][g_iSkinID]++
		g_bIsWeaponStattrak[iWinner][g_iSkinID] = true
		
		AddStatistics(iWinner, DROPPED_STT_SKINS, 1, g_iSkinID, .line = __LINE__)
		AddStatistics(iWinner, TOTAL_GIVEAWAYS, 1, .line = __LINE__)

		new szWinnerName[MAX_PLAYERS]
		get_user_name(iWinner, szWinnerName, charsmax(szWinnerName))
		client_print_color(0, 0, "^4%s^1 ^4%s^1 won^3 StatTrak %s^1 at the ^4Giveaway", CHAT_PREFIX, szWinnerName, g_szSkinName)

		new iPlayers[MAX_PLAYERS], iNum
		get_players(iPlayers, iNum, "ch")

		for(new i;i < iNum;i++)
		{
			g_bJoinedGiveAway[iPlayers[i]] = false
		}
		
		remove_task(TASK_GIVEAWAY)
		g_bGiveAwayStarted = true
	}
}

getRandomWinner()
{
	if(!getGiveAwayPlayersNum())
		return -1
		
	new iPlayers[MAX_PLAYERS], iNum, iPlayer
	get_players(iPlayers, iNum, "ch")
	
	do 
	{
		iPlayer = iPlayers[random(iNum)]
	}
	while(!g_bJoinedGiveAway[iPlayer] || !is_user_connected(iPlayer))
	
	return g_bJoinedGiveAway[iPlayer] ? iPlayer : iPlayers[random(iNum)]
}

getGiveAwayPlayersNum()
{
	new iPlayers[MAX_PLAYERS], iNum, iCount
	get_players(iPlayers, iNum, "ch")
	
	for(new i;i < iNum;i++)
	{
		if(!g_bJoinedGiveAway[iPlayers[i]])
			continue
			
		iCount++
	}
	return iCount
}

checkInstantDefault(id, iItemID)
{
	new iWeaponId = ArrayGetCell(g_aSkinWeaponID, iItemID)
	if(iItemID == g_iUserSelectedSkin[id][iWeaponId])
	{
		if(get_user_weapon(id) == iWeaponId)
		{
			if(g_bIsWeaponStattrak[id][iItemID] && !g_bShallUseStt[id][iWeaponId])
				return
			
			SetUserSkin(id, SET_DEFAULT_MODEL, iWeaponId)
		}

		g_iUserSelectedSkin[id][iWeaponId] = -1

		if(g_bIsWeaponStattrak[id][iItemID] && g_bShallUseStt[id][iWeaponId] && (g_iUsedSttC[id][0] > -1))
		{
			g_bIsWeaponStattrak[id][iItemID] = false
		}
	}
}

//lexzor
getGiveawaySkin(szSkinName[])
{
	new iRandomSkin = -1;
	new model[256];
	new iChance

	while(!szSkinName[0])
	{
		iRandomSkin = random_num(0, g_iSkinsNum - 1);
		iChance = ArrayGetCell(g_aSkinChance, iRandomSkin)

		if((g_CvarUndroppableChance != -1 && iChance >= g_CvarUndroppableChance) || (iChance == 101))
		{
			continue
		}

		ArrayGetString(g_aSkinName, iRandomSkin, model, charsmax(model))
		copy(szSkinName, 100, model);
		break
	}

	return iRandomSkin;
}

public client_disconnected(id)  
{
	if(is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_HANDLED

	g_iKills[id] = 0 
	g_iHS[id] = 0
	g_fDmg[id] = 0.0

	if(g_bLogged[id] && !g_bWaitingResponse[id] && !g_bWaitingSkins[id])
	{
		if(task_exists(id + TASK_PLAYED_TIME))
		{
			remove_task(id + TASK_PLAYED_TIME)
		}

		_SaveData(id)
	}

	return PLUGIN_CONTINUE;
}

public OnTakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits)  
{  
    if(is_user_connected(iAttacker) && iAttacker != iVictim && is_user_connected(iVictim))
    {
        if(cs_get_user_team(iAttacker) != cs_get_user_team(iVictim))  
            g_fDmg[iAttacker] += fDamage
        else
            g_fDmg[iAttacker] -= fDamage
    }
}

public OnPlayerKilled()
{  
    new iAttacker = read_data(1), iVictim = read_data(2)  
      
    if(is_user_connected(iAttacker) && iAttacker != iVictim && is_user_connected(iVictim))
    {
        if(cs_get_user_team(iAttacker) != cs_get_user_team(iVictim))
        {
            g_iKills[iAttacker]++
            
            if(read_data(3))
                g_iHS[iAttacker]++
        }
        else
        {
            g_iKills[iAttacker]--
            
            if(read_data(3))
                g_iHS[iAttacker]--
        }
    }
}

public OnRoundEnd()
{
	new id = get_best_player()
	
	if(id == -1)
		return
		

	if(g_CvarMVPSystem)
	{
		_GiveBonus(id, 1)
	}
	
	arrayset(g_iKills, 0, sizeof(g_iKills))
	arrayset(g_iHS, 0, sizeof(g_iHS))
	
	for(new i; i < sizeof(g_fDmg); i++)
		g_fDmg[i] = 0.0
}

get_best_player()
{
	new iPlayers[32], iPnum, id
	get_players(iPlayers, iPnum)
    
	for(new i, iPlayer; i < iPnum; i++)
	{
		iPlayer = iPlayers[i]
        
		if(g_iKills[iPlayer] > g_iKills[id])
		{
			id = iPlayer
		}
		else if(g_iKills[iPlayer] == g_iKills[id])
		{
			if(g_fDmg[iPlayer] > g_fDmg[id])
			{
				id = iPlayer
			}
		}
	}
	return g_iKills[id] ? id : -1
} 


public CBaseEntity_Touch(pWeaponEnt, pPlayerId)
{
	return HAM_SUPERCEDE;
}

public Zoom(id)
{
	if(is_user_alive(id))
	{
		ScopeData[id][ScopeTime] = _:get_gametime()
	}
}

public fw_EvCurWeapon(id)
{
	if(is_user_alive(id))
	{
		ScopeData[id][ScopeType] = cs_get_user_zoom(id)
	}
}

public checkQuickScopeKill(id)
{
	if(!g_quick_enable)
		return
    
	new KillerName[32]
	new VictimName[32]
	new iKiller = read_data(1)
	new iVictim = read_data(2)
	new Float:GameTime = get_gametime()
	new bool:bQuickScope = bool:(GameTime - ScopeData[iKiller][ScopeTime] <= 0.20)
	
	if(bQuickScope)
	{
		get_user_name(iKiller,KillerName,charsmax(KillerName))
		get_user_name(iVictim,VictimName,charsmax(VictimName))
		ExecuteForward(PluginForwardQuick, _, iKiller, iVictim, get_user_weapon(iKiller))

		if(g_quick_type == 0)
		{
			client_print_color(0, id, "^4[CSGO Classy] %s^1 quick scoped^4 %s", KillerName, VictimName)
		}
		else
		{
			set_hudmessage(47, 79, 79, 0.10, 0.65, 0, 0.75, 1.0, 0.1, 0.1 , -1)
			show_hudmessage(0, "%s quick scoped %s", KillerName, VictimName)
		}
	}
}

stock fadescreen(id, ammount, color)
{    
	if (ammount > 255)
		ammount = 255;
	
	message_begin(MSG_ONE_UNRELIABLE, msgScreenFade, {0,0,0}, id);
	write_short(ammount * 100);  
	write_short(0);  
	write_short(0);

	switch(color)
	{
		case 1: 
		{
			write_byte(255);   
			write_byte(0);    
			write_byte(0);    
		}

		case 2:
		{
			write_byte(0);    
			write_byte(255);    
			write_byte(0);    
		}

		case 3:
		{
			write_byte(0);    
			write_byte(0);  
			write_byte(255);
		}

		default:
		{
			server_print("[CSGO Classy] Invalid fade color (0-red, 1-green, 2-blue)");
			return PLUGIN_HANDLED;
		}
	}

	write_byte(ammount);
	message_end();

	return PLUGIN_CONTINUE;
}  

mysql_escape_string(dest[],len)
{
	replace_all(dest,len,"\\","\\\\");
	replace_all(dest,len,"\0","\\0");
	replace_all(dest,len,"\n","\\n");
	replace_all(dest,len,"\r","\\r");
	replace_all(dest,len,"\x1a","\Z");
	replace_all(dest,len,"'","\'");
	replace_all(dest,len,"^"","\^"");
}