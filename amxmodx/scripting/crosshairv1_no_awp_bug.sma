/*

    Some Scripter, hellmonja, ConnorMcLeod eklentilerinden alinti yapilmistir.
	Assault Scope: https://gamebanana.com/gamefiles/4885
	Eklentinin Orijinali: Win Team Sprite
	Yararlanılan konular;
		https://wiki.alliedmods.net/CS_WeaponList_Message_Dump
		https://wiki.alliedmods.net/CS_Weapons_Information
		https://forums.alliedmods.net/showthread.php?t=191512

			VATANGAMING.COM

		* 2.1 Uzun model isimlerindeki cokme hatasi duzeltildi
		* 2.2
			- Normal crosshaire fov ayarı eklendi
			- Sniperlarda durbun acip kapatinca olusan fov bozulmasi duzeltildi
		* 2.3
			- Sunucu doluyken olusan degisken hatasi duzeltildi
			- amxmodx surumu 1.8.3 surumunden dusuk olanlar artik eklentiyi kullanabilecek
		*2.4
			- aug ve sg552 dürbünlerindeki sorun üzerinde düzeltme yapıldı
*/


#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
//#include <cstrike>
#include <engine>
#include <nvault>
#include <csgoclassy>

native cs_get_user_zoom(index);
#define CSW_SHIELD  2
#define DEFAULT_FOV 90
#define SetPlayerBit(%1,%2)    ( %1 |=  ( 1 << ( %2 & 31 ) ) )
#define ClearPlayerBit(%1,%2)  ( %1 &= ~( 1 << ( %2 & 31 ) ) )
#define CheckPlayerBit(%1,%2)  ( %1 &   ( 1 << ( %2 & 31 ) ) )

#define HUD_HIDE_CROSS (1<<6)
#define HUD_DRAW_CROSS (1<<7)

native aug_sg_unscope(id);

new const AUG_SCOPE[] = "models/v_augscope.mdl";
new const SIG_SCOPE[] = "models/v_sigscope.mdl";
//new const AUG[] = "models/v_aug.mdl";
//new const SG552[] = "models/v_sg552.mdl";
new weapon_weapon[][] =
{
	"weapon_aug",
	"weapon_sg552"
}

new g_Zoom[33], Float:g_ZoomTime[33]

new const silah_listesi[][][] = 
{
	{"","","","","","","","",""},
	{"weapon_p228",9,52,-1,-1,1,3,1,0},
	{"","","","","","","","",""},
	{"weapon_scout",2,90,-1,-1,0,9,3,0},
	{"weapon_hegrenade",12,1,-1,-1,3,1,4,24},
	{"weapon_xm1014",5,32,-1,-1,0,12,5,0},
	{"weapon_c4",14,1,-1,-1,4,3,6,24},
	{"weapon_mac10",6,100,-1,-1,0,13,7,0},
	{"weapon_aug",4,90,-1,-1,0,14,8,0},
	{"weapon_smokegrenade",13,1,-1,-1,3,3,9,24},
	{"weapon_elite",10,120,-1,-1,1,5,10,0},
	{"weapon_fiveseven",7,100,-1,-1,1,6,11,0},
	{"weapon_ump45",6,100,-1,-1,0,15,12,0},
	{"weapon_sg550",4,90,-1,-1,0,16,13,0},
	{"weapon_galil",4,90,-1,-1,0,17,14,0},
	{"weapon_famas",4,90,-1,-1,0,18,15,0},
	{"weapon_usp",6,100,-1,-1,1,4,16,0},
	{"weapon_glock18",10,120,-1,-1,1,2,17,0},
	{"weapon_awp",1,30,-1,-1,0,2,18,0},
	{"weapon_mp5navy",10,120,-1,-1,0,7,19,0},
	{"weapon_m249",3,200,-1,-1,0,4,20,0},
	{"weapon_m3",5,32,-1,-1,0,5,21,0},
	{"weapon_m4a1",4,90,-1,-1,0,6,22,0},
	{"weapon_tmp",10,120,-1,-1,0,11,23,0},
	{"weapon_g3sg1",2,90,-1,-1,0,3,24,0},
	{"weapon_flashbang",11,2,-1,-1,3,2,25,24},
	{"weapon_deagle",8,35,-1,-1,1,1,26,0},
	{"weapon_sg552",4,90,-1,-1,0,10,27,0},
	{"weapon_ak47",2,90,-1,-1,0,1,28,0},
	{"weapon_knife",-1,-1,-1,-1,2,1,29,0},
	{"weapon_p90",7,100,-1,-1,0,8,30,0}
	
}
enum _: ImlecBilgileri 
{
	SeciliCrosshair,
	AssaultKontrol,
	SniperKontrol,
	FovKontrol
}

#define MAX_FOV 25 // 5 VE 5'in katlarini girin, kapatmak icin 0 yazin.
#define MAX_CROSSHAIR 12
new ImlecKontrol[33][ImlecBilgileri];
new zoomkontrol[33]

new const genel_bilgiler[][][] = {
	{"CS:GO Default 1","sprites/vatan_toplu_imlecler1.txt","vatan_toplu_imlecler1"},
	{"CS:GO Default 2","sprites/vatan_toplu_imlecler2.txt","vatan_toplu_imlecler2"},
	{"FalleN","sprites/vatan_toplu_imlecler3.txt","vatan_toplu_imlecler3"},
	{"KennyS","sprites/vatan_toplu_imlecler4.txt","vatan_toplu_imlecler4"},
	{"Taco","sprites/vatan_toplu_imlecler5.txt","vatan_toplu_imlecler5"},
	{"Skadoodle","sprites/vatan_toplu_imlecler6.txt","vatan_toplu_imlecler6"},
	{"KRIMZ","sprites/vatan_toplu_imlecler7.txt","vatan_toplu_imlecler7"},
	{"Rip","sprites/vatan_toplu_imlecler8.txt","vatan_toplu_imlecler8"},
	{"XANTARES","sprites/vatan_toplu_imlecler9.txt","vatan_toplu_imlecler9"},
	{"woxic","sprites/vatan_toplu_imlecler10.txt","vatan_toplu_imlecler10"},
	{"coldzera","sprites/vatan_toplu_imlecler11.txt","vatan_toplu_imlecler11"},
	{"s1mple","sprites/vatan_toplu_imlecler12.txt","vatan_toplu_imlecler12"},

	{"","sprites/vatan_toplu_imlecler.spr",""},
	{"","sprites/weapon_vtn_awp.txt",""},
	{"","sprites/vatan_durbunspr.spr",""},
	{"","sprites/vatan_aug_nokta.txt",""}
}
new const awp_zoom[] = {"weapon_vtn_awp"}
new const aug_nokta[] = {"vatan_aug_nokta"}

new g_bSomeBool

enum _:MESSAGES {
    g_iMsg_WeaponList,
    g_iMsg_CurWeapon,
    g_iMsg_ForceCam,
    g_iMsg_SetFOV
}

new g_Messages_Name[MESSAGES][] = {
    "WeaponList",
    "CurWeapon",
    "ForceCam",
    "SetFOV"
}
new const MenuKomutlari[][] = { "say /tinta", "say_team /tinta","say /ch", "say_team /ch","say /crosshair", "say_team /crosshair" };

new g_Messages[MESSAGES],g_msgHideWeapon, iMsgCrosshair,imlecvault,giristecrosshair;
new modelismiaug[80][33],modelismisg[80][33]

new CHAT_PREFIX[32], MENU_PREFIX[32]
new g_iMenuID
new g_bOpenedFromMain[MAX_PLAYERS + 1]

public plugin_init(){
	register_plugin("CSGO Classy Crosshair", "2.4", "? enhanced by lexzor")
	for (new i; i < sizeof MenuKomutlari; i++) register_clcmd(MenuKomutlari[i], "genelmenu");

	csgo_get_prefixes(CHAT_PREFIX, charsmax(CHAT_PREFIX), MENU_PREFIX, charsmax(MENU_PREFIX))

	for(new i; i < sizeof(g_Messages); i++)
	{
		g_Messages[i] = get_user_msgid(g_Messages_Name[i]);
		register_message(g_Messages[i], "block");
	}
	register_message(g_Messages[g_iMsg_SetFOV], "message_setfov") 
	#if AMXX_VERSION_NUM >= 183
		new cvarayar = create_cvar("varsayilan_imlec","1", FCVAR_NONE, "Cursor to be selected to players 0-11")
		bind_pcvar_num(cvarayar, giristecrosshair)
	#else
		giristecrosshair = get_pcvar_num(register_cvar("varsayilan_imlec", "1"))
	#endif
	g_msgHideWeapon = get_user_msgid("HideWeapon");
	iMsgCrosshair = get_user_msgid("Crosshair");
	register_event("CurWeapon", "HookCurWeapon2", "be", "1=1")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	register_event("HLTV", "Event_New_Round", "a", "1=0", "2=0");
	register_forward(FM_CmdStart, "FW_CmdStart")
	imlecvault = nvault_open("vatanimlecbilgisi")
	RegisterHam(Ham_Item_Deploy, "weapon_aug", "assault_deploy_aug", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_sg552", "assault_deploy_sg552", 1)
	RegisterHam( Ham_Item_PostFrame, "weapon_aug", "Atakla", 1 );
	RegisterHam( Ham_Item_PostFrame, "weapon_sg552", "AtaklaSG", 1 );
	for(new i = 0; i < sizeof weapon_weapon; i++)
		RegisterHam(Ham_Weapon_Reload, weapon_weapon[i], "fw_Weapon_Reload_Post", 1)

	g_iMenuID = csgo_register_menu(MenuCode:MENU_MAIN, "\rCrosshair")
}

public csgo_menu_item_selected(const id, const MenuCode:menu_code, const itemid)
{
	if(menu_code != MenuCode:MENU_MAIN || itemid != g_iMenuID)
	{
		return
	}

	g_bOpenedFromMain[id] = true
	genelmenu(id)

	return
}

public Atakla(Ent)
{
	static id; id = get_pdata_cbase(Ent, 41, 4)
	if(ImlecKontrol[id][AssaultKontrol])
	{
		if(g_Zoom[id] == 1)
			ScopeTekrar(id)
	}	
}

public AtaklaSG(Ent)
{
	static id; id = get_pdata_cbase(Ent, 41, 4)
	if(ImlecKontrol[id][AssaultKontrol])
	{
		if(g_Zoom[id] == 2)
			ScopeTekrar(id)
	}	
}

public message_setfov(msg_id, msg_dest, id)
{
	if (!is_user_alive(id))
		return;

	zoomkontrol[id] = get_msg_arg_int(1)
	if(get_msg_arg_int(1) == 90)
		set_msg_arg_int(1, get_msg_argtype(1), DEFAULT_FOV+ImlecKontrol[id][FovKontrol])
}

public fw_Weapon_Reload_Post(ent)
{
	static id;
	id = pev(ent, pev_owner);
	new zoom = cs_get_user_zoom(id);
	
	if(get_user_weapon(id) == CSW_AUG || get_user_weapon(id) == CSW_SG552)
		if(zoom == 1)
			UnScope(id);
		
	return HAM_HANDLED
}

public Event_New_Round()
{
	new id, players[32], num;
	get_players(players, num, "ac");
	for (new i = 0; i < num; i++)
	{
		id = players[i];
		if(get_user_weapon(id) == CSW_AUG || get_user_weapon(id) == CSW_SG552)
			UnScope(id);
	}
}

public FW_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED
		
	if(is_user_bot(id))
		return FMRES_IGNORED

	static NewButton, zoom;
	NewButton = get_uc(uc_handle, UC_Buttons);
	
	if(NewButton & IN_ATTACK2)
	{
		if(get_user_weapon(id) == CSW_AUG || get_user_weapon(id) == CSW_SG552)
		{
			if(get_gametime() > g_ZoomTime[id])
			{
				zoom = cs_get_user_zoom(id);
				if(g_Zoom[id] && zoom == 1)
					UnScope(id);
				else if (!g_Zoom[id] && zoom == 4)
				{
					Scope(id);
				}
				g_ZoomTime[id] = get_gametime();
			}
		}
		else
			g_Zoom[id] = 0
	}
	
	return FMRES_HANDLED
}

public assault_deploy_aug(Ent)
{
	static id; id = get_pdata_cbase(Ent, 41, 4)
	set_task(0.1,"silahmodelinicekaug",id)	
}

public silahmodelinicekaug(id)
{
	pev(id,pev_viewmodel2, modelismiaug[id],charsmax(modelismiaug))
	if(equali(modelismiaug[id],AUG_SCOPE))
		modelismiaug[id] = "models/v_aug.mdl"
}
public silahmodeliniceksg(id)
{
	pev(id,pev_viewmodel2, modelismisg[id],charsmax(modelismisg))
	if(equali(modelismisg[id],SIG_SCOPE))
		modelismisg[id] = "models/v_sg552.mdl"
}

public assault_deploy_sg552(Ent)
{
	static id; id = get_pdata_cbase(Ent, 41, 4)
	set_task(0.1,"silahmodeliniceksg",id)
}

public fw_PlayerKilled(victim, attacker)
{
	set_task(0.1, "sifirla", victim)
}

public sifirla(id)
{
	ClearPlayerBit(g_bSomeBool,id);
	Msg_CurWeapon(id,0,0,0);
	Hide_NormalCrosshair(id, 0);
	show_crosshair(id, 0)
	new w = get_user_weapon(id)
	if((w == CSW_AUG && g_Zoom[id] == 1) || (w == CSW_SG552 && g_Zoom[id] == 2))
		return

	if(g_Zoom[id])
		UnScope(id);
}

public genelmenu(id)
{
	if(!is_user_connected(id))
		return
	
	new menu = menu_create(fmt("%s Crosshair Settings", MENU_PREFIX),"genelmenu2")
	new ekleme[128]
	if(ImlecKontrol[id][SeciliCrosshair] == -1)
		formatex(ekleme,127,"\wCrosshair Style \w[\rDefault\w]")
	else
		formatex(ekleme,127,"\wCrosshair Style \w[\r%s\w]",genel_bilgiler[ImlecKontrol[id][SeciliCrosshair]][0][0])

	menu_additem(menu,ekleme,"1",0)
	formatex(ekleme,127,"\wSniper Scope (\ySSG 08 \w& \yAWP\w) \w[%s\w]",ImlecKontrol[id][SniperKontrol] ? "\rON":"\dOFF")
	menu_additem(menu,ekleme,"2",0)
	formatex(ekleme,127,"\wAssault Scope (\yAUG \w& \ySG 553\w) \w[%s\w]",ImlecKontrol[id][AssaultKontrol] ? "\rON":"\dOFF")
	menu_additem(menu,ekleme,"3",0)
	formatex(ekleme,127,"\wFOV \w[\r%i / \y%i\w]^n^n",ImlecKontrol[id][FovKontrol],MAX_FOV)

	menu_additem(menu,ekleme,"4",0)

	menu_setprop(menu, MPROP_EXITNAME, "Exit");
	menu_display(id, menu, 0);

}


public genelmenu2(id,menu,item)
{
	if(item==MENU_EXIT)
	{
		if(g_bOpenedFromMain[id])
		{
			g_bOpenedFromMain[id] = false
			display_menu(id, MenuCode:MENU_MAIN)
		}

		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	new key = str_to_num(data)
	switch(key)
	{
		case 1:{
			imlecsecim(id)
			return PLUGIN_HANDLED
		}
		case 2:{
			ImlecKontrol[id][SniperKontrol] = ImlecKontrol[id][SniperKontrol] ? 0 : 1
		}
		case 3:{
			ImlecKontrol[id][AssaultKontrol] = ImlecKontrol[id][AssaultKontrol] ? 0 : 1
			client_cmd(id,"weapon_knife;wait;wait;wait;weapon_aug;weapon_sg552")
		}
		case 4:{
			ImlecKontrol[id][FovKontrol] += 5
			if(ImlecKontrol[id][FovKontrol] > MAX_FOV || ImlecKontrol[id][FovKontrol] < 0)
				 ImlecKontrol[id][FovKontrol] = 0
		}
	}
	genelmenu(id)
	bilgilerikaydet(id)
	HookCurWeapon2(id)
		
	return PLUGIN_HANDLED
}


public imlecsecim(id)
{
	if(!is_user_connected(id))
		return
	
	new cevir[10];
	new menu = menu_create(fmt("%s Crosshair Settings", MENU_PREFIX),"imlecsecim2")
	num_to_str(MAX_CROSSHAIR+1,cevir,9)
	menu_additem(menu,"\wNormal Crosshair",cevir,0)
	for (new i; i < MAX_CROSSHAIR; i++)
	{
		num_to_str(i,cevir,9)
		menu_additem(menu,genel_bilgiler[i][0][0],cevir,0)
	}

	menu_setprop(menu, MPROP_EXITNAME, "Exit");
	menu_setprop(menu, MPROP_BACKNAME, "Back");
	menu_setprop(menu, MPROP_NEXTNAME, "Next");
	menu_display(id, menu, 0);

}


public imlecsecim2(id,menu,item)
{
	if(item==MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	new key = str_to_num(data)
	if(key > MAX_CROSSHAIR)
	{
		sifirla(id)
		ImlecKontrol[id][SeciliCrosshair] = -1
		HookCurWeapon2(id)
		client_print_color(id,id,"%s Your crosshair style has been successfully reset!", CHAT_PREFIX)
	}
	else
	{
		ImlecKontrol[id][SeciliCrosshair] = key
		HookCurWeapon2(id)
	}
	bilgilerikaydet(id)
		
	return PLUGIN_HANDLED
}


public client_putinserver(id)
{
	client_cmd(id, "crosshair 1")
	bilgiler(id)
}

public bilgiler(id)
{
	new toplam[64],bilgilertoplam[15],steamid[32],cross[5],assault[5],sniper[5],fov[5]
	get_user_authid( id, steamid, charsmax(steamid))
	formatex(toplam,63,"%s-STEAMID",steamid)
	nvault_get(imlecvault, toplam, bilgilertoplam, charsmax(bilgilertoplam)) 
	parse(bilgilertoplam,cross,4,assault,4,sniper,4,fov,4)
	ImlecKontrol[id][SeciliCrosshair] = str_to_num(cross)
	ImlecKontrol[id][AssaultKontrol] = str_to_num(assault)
	ImlecKontrol[id][SniperKontrol] = str_to_num(sniper)
	ImlecKontrol[id][FovKontrol] = str_to_num(fov)
	if(ImlecKontrol[id][FovKontrol] > MAX_FOV || ImlecKontrol[id][FovKontrol] < 0)
		ImlecKontrol[id][FovKontrol] = 0

	if(equali(bilgilertoplam,""))
	{
		if(giristecrosshair < -1 || giristecrosshair > MAX_CROSSHAIR)
			ImlecKontrol[id][SeciliCrosshair] = 0
		else
			ImlecKontrol[id][SeciliCrosshair] = giristecrosshair
		ImlecKontrol[id][AssaultKontrol] = 1
		ImlecKontrol[id][SniperKontrol] = 1
		ImlecKontrol[id][FovKontrol] = 0
	}
}

public bilgilerikaydet(id)
{
	new toplam[64],bilgilertoplam[15],steamid[32]
	get_user_authid( id, steamid, charsmax(steamid))
	if(ImlecKontrol[id][FovKontrol] > MAX_FOV || ImlecKontrol[id][FovKontrol] < 0)
		ImlecKontrol[id][FovKontrol] = 0

	formatex(bilgilertoplam,14,"%i %i %i %i",ImlecKontrol[id][SeciliCrosshair],ImlecKontrol[id][AssaultKontrol],ImlecKontrol[id][SniperKontrol],ImlecKontrol[id][FovKontrol])
	formatex(toplam,63,"%s-STEAMID",steamid)
	nvault_set(imlecvault,toplam,bilgilertoplam)
}


public HookCurWeapon2(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE

	if(ImlecKontrol[id][SeciliCrosshair] != -1)
		Hide_NormalCrosshair(id, 1);

	new clip, ammo
	new w = get_user_weapon(id, clip, ammo)

	if(w == CSW_AWP || w == CSW_SCOUT || w == CSW_G3SG1 || w == CSW_SG550)
	{
		Hide_NormalCrosshair(id, 1)
		if(g_Zoom[id])
		{
			Msg_SetFOV(id,DEFAULT_FOV+ImlecKontrol[id][FovKontrol]);
			g_Zoom[id] = 0
		}
		else if(zoomkontrol[id] >= 90)
			Msg_SetFOV(id,DEFAULT_FOV+ImlecKontrol[id][FovKontrol])

		ClearPlayerBit(g_bSomeBool, id);
		Msg_CurWeapon(id,0,0,0);
		if(ImlecKontrol[id][SniperKontrol])
			Msg_WeaponList(id,awp_zoom,silah_listesi[w][1][0],silah_listesi[w][2][0],silah_listesi[w][3][0],silah_listesi[w][4][0],silah_listesi[w][5][0],0,CSW_SHIELD,silah_listesi[w][8][0]);
		else
			Msg_WeaponList(id,"weapon_awp",silah_listesi[w][1][0],silah_listesi[w][2][0],silah_listesi[w][3][0],silah_listesi[w][4][0],silah_listesi[w][5][0],0,CSW_SHIELD,silah_listesi[w][8][0]);

		ClearPlayerBit(g_bSomeBool, id);
		Msg_CurWeapon(id,1,2,clip);

		return PLUGIN_CONTINUE
	}
	else if(ImlecKontrol[id][SeciliCrosshair] == -1)
	{
		sifirla(id)
		if((g_Zoom[id] == 1 && w == CSW_AUG) || (g_Zoom[id] == 2 && w == CSW_SG552))
		{
			Msg_SetFOV(id,55)
		}
		else
		{
			if(g_Zoom[id])
				UnScope(id)

			Msg_SetFOV(id,DEFAULT_FOV+ImlecKontrol[id][FovKontrol])
		}
		return PLUGIN_CONTINUE
	}
	else if(w == CSW_AUG || w == CSW_SG552)
	{
		if(g_Zoom[id] && ImlecKontrol[id][AssaultKontrol] && ((g_Zoom[id] == 1 && w == CSW_AUG) || (g_Zoom[id] == 2 && w == CSW_SG552)))
			Msg_WeaponList(id,aug_nokta,silah_listesi[w][1][0],silah_listesi[w][2][0],silah_listesi[w][3][0],silah_listesi[w][4][0],silah_listesi[w][5][0],0,CSW_SHIELD,silah_listesi[w][8][0]);
		else
			Msg_WeaponList(id,genel_bilgiler[ImlecKontrol[id][SeciliCrosshair]][2][0],silah_listesi[w][1][0],silah_listesi[w][2][0],silah_listesi[w][3][0],silah_listesi[w][4][0],silah_listesi[w][5][0],0,CSW_SHIELD,silah_listesi[w][8][0]);

		Msg_SetFOV(id,DEFAULT_FOV-1);
		ClearPlayerBit(g_bSomeBool, id);
		Msg_CurWeapon(id,1,2,clip);
		SetPlayerBit(g_bSomeBool,id);
		if((g_Zoom[id] == 1 && w == CSW_AUG) || (g_Zoom[id] == 2 && w == CSW_SG552))
		{
			Msg_SetFOV(id,55)
			/*if(ImlecKontrol[id][AssaultKontrol])
			{
				ScopeTekrar(id)
			}*/
		}
		else
		{
			if(g_Zoom[id])
				UnScope(id)
			
			Msg_SetFOV(id,DEFAULT_FOV+ImlecKontrol[id][FovKontrol])
		}

		return PLUGIN_HANDLED_MAIN
	}

	if(g_Zoom[id])
		UnScope(id)

	Msg_WeaponList(id,genel_bilgiler[ImlecKontrol[id][SeciliCrosshair]][2][0],silah_listesi[w][1][0],silah_listesi[w][2][0],silah_listesi[w][3][0],silah_listesi[w][4][0],silah_listesi[w][5][0],0,CSW_SHIELD,silah_listesi[w][8][0]);
	Msg_SetFOV(id,DEFAULT_FOV-1);
	ClearPlayerBit(g_bSomeBool, id);
	Msg_CurWeapon(id,1,2,clip);
	SetPlayerBit(g_bSomeBool,id);
	Msg_SetFOV(id,DEFAULT_FOV+ImlecKontrol[id][FovKontrol]);
	return PLUGIN_CONTINUE
}


public Scope(id)
{
	new clip, ammo
	new w = get_user_weapon(id, clip, ammo)
	if(w == CSW_AUG)
		g_Zoom[id] = 1;
	else if (w == CSW_SG552)
		g_Zoom[id] = 2;

	if(!ImlecKontrol[id][AssaultKontrol])
	{
		HookCurWeapon2(id)
		return
	}

	if(w == CSW_AUG)
	{
		entity_set_string(id, EV_SZ_viewmodel, AUG_SCOPE);
	}
	else if (w == CSW_SG552)
	{
		entity_set_string(id, EV_SZ_viewmodel, SIG_SCOPE);
	}
	HookCurWeapon2(id)
}

public ScopeTekrar(id)
{
	new clip, ammo
	new w = get_user_weapon(id, clip, ammo)

	if(w == CSW_AUG)
	{
		entity_set_string(id, EV_SZ_viewmodel, AUG_SCOPE);
	}
	else if (w == CSW_SG552)
	{
		entity_set_string(id, EV_SZ_viewmodel, SIG_SCOPE);
	}
}

stock UnScope(id)
{	
	g_Zoom[id] = 0;
	if(!ImlecKontrol[id][AssaultKontrol])
	{
		HookCurWeapon2(id)
		return
	}

	// new w = get_user_weapon(id)
	// if(w == CSW_AUG)
	// 	entity_set_string(id, EV_SZ_viewmodel, modelismiaug[id]);
	// else if(w == CSW_SG552)
	// 	entity_set_string(id, EV_SZ_viewmodel, modelismisg[id])

	aug_sg_unscope(id)

	HookCurWeapon2(id)		
}

stock show_crosshair(id, flag)
{
	message_begin(MSG_ONE_UNRELIABLE, iMsgCrosshair, _, id);
	write_byte(flag);
	message_end();
}

new bool:g_bDraw[MAX_PLAYERS + 1]

stock Hide_NormalCrosshair(id, flag)
{
	if(flag == 1)
	{
		message_begin(MSG_ONE, g_msgHideWeapon, _, id);
		write_byte(HUD_HIDE_CROSS);
		message_end();

		g_bDraw[id] = false
	}
	else
	{
		if(!g_bDraw[id])
		{
			message_begin(MSG_ONE, g_msgHideWeapon, _, id);
			write_byte(HUD_DRAW_CROSS);
			message_end();
		}

		g_bDraw[id] = true
	}
}

public plugin_precache(){
	for(new i; i < sizeof(genel_bilgiler); i++)
		precache_generic(genel_bilgiler[i][1][0]);

	precache_model(AUG_SCOPE);
	precache_model(SIG_SCOPE);
}



public block(iMsgID,iMsgType,iPlrID){
    if(CheckPlayerBit(g_bSomeBool,iPlrID))
		return PLUGIN_HANDLED;

    return PLUGIN_CONTINUE;
}

stock Msg_WeaponList(id,const WeaponName[],PrimaryAmmoID,PrimaryAmmoMaxAmount,SecondaryAmmoID,SecondaryAmmoMaxAmount,
                        SlotID,NumberInSlot,WeaponID,Flags){
    message_begin(MSG_ONE,g_Messages[g_iMsg_WeaponList],_, id);
    {
        write_string(WeaponName);
        write_byte(PrimaryAmmoID);
        write_byte(PrimaryAmmoMaxAmount);
        write_byte(SecondaryAmmoID);
        write_byte(SecondaryAmmoMaxAmount);
        write_byte(SlotID);
        write_byte(NumberInSlot);
        write_byte(WeaponID);
        write_byte(Flags);
    }
    message_end();
}

stock Msg_CurWeapon(id,IsActive,WeaponID, ClipAmmo)
{
    message_begin(MSG_ONE,g_Messages[g_iMsg_CurWeapon],_,id);
    {
        write_byte(IsActive);
        write_byte(WeaponID);
        write_byte(ClipAmmo);
    }
    message_end();
}

stock Msg_SetFOV(id,Degrees){
    message_begin(MSG_ONE,g_Messages[g_iMsg_SetFOV], _,id);
    {
        write_byte(Degrees);
    }
    message_end();
}

public plugin_natives()
{
	register_native("open_crosshair_menu", "native_open_crosshair_menu", 0);
}

public native_open_crosshair_menu(iPluginID, iParams)
{
	genelmenu(get_param(1));
}