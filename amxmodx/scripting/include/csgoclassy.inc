#if defined _csgoclassy_included
#endinput
#endif

//Max menu item string length.
#define MAX_MENU_ITEM_LENGTH 128

//Max menu additional string length. Additional menu names length won't be counted as a total value.
#define MAX_MENU_ADDITIONAL_NAME_LENGTH 128

//How many items can be in a MenuCode:MENU_*
#define MAX_CATEGORY_DYNAMIC_MENUS 32

/**
* Struct to be used as a error code that will be thrown when using natives and a error occurs.
*/
enum _:NativeErrorCode
{
	USER_NOT_LOGGED,			// User is not logged in.
	USER_NOT_CONNECTED,			// User is not connected on the server.
	USER_NOT_ALIVE,				// User is not alive.
	INVALID_PARAM_VALUE,		// A param is not used properly (value is too high or to low)
	INVALID_SAVE_TYPE,			// Returned when trying to get connection data for database and sqlx handle 
	INVALID_MENU_CODE,			// If the menu code is (somehow) incorrect, will return this error code.
	INVALID_MENU_ID,			// Occurs when trying to update menu inventory value amount, but the menu id is invalid
	INVALID_RANK_ID				// Rankid is smaller or higher than the existent rankids
}


/**
* Struct to be used for parameter 'menu_code' with Dynamic Menus API.
* Each value represent CSGO Classy menus.
*/

enum MenuCode
{
	MENU_MAIN,		
	MENU_INVENTORY,	
	MENU_GAMBLING,	
	MENU_SETTINGS	
}


/**
	---------------------------------------------------------------------------------------
	Forwards of the CSGO Classy mode. Can be used external and may be changed in the future.
	---------------------------------------------------------------------------------------
*/  

/**
* Called after a player have been logged in.
*
* @param id        Player index.
*
* @noreturn 
*/
forward user_log_in_post(const id);


/**
* Called after a player have been registered.
*
* @param id        Player index.
*
* @noreturn
*/
forward user_register_post(const id);


/**
* Called when a dynamic item from the menu has been selected.
*
* @param id        	Player index.
* @param menucode		The menu from where the item has been selected.
* @param itemid		Menu item id.	
*
* @noreturn
*/
forward csgo_menu_item_selected(const id, const MenuCode:menu_code, const itemid);


/**
* Called when a dynamic item from the menu has been selected.
*
* @note		This forward is called after de csgoclassy.cfg have been executed	
*
* @noreturn
*/
forward csgo_config_executed();

/**
	---------------------------------------------------------------------------------------
	Natives of the CSGO Classy mode. Can be used external and may be changed in the future.
	Not all of them are documented here, so this file may be changed in the future.
	
	*NOTES:
		- 'get_' 	natives are made to be used after the user is connected
		- 'set_' 	natives are made to be used after user has been logged in (already connected)
					use ther with specific post login/register forwards
					
	---------------------------------------------------------------------------------------
*/  


/**
* Retrieve CSGO Classy config directory name.
*
* @param buffer 			Buffer to copy name value in.
* @param bufferlen 		Size of the buffer.
*			
* @noreturn						
*/
native csgo_directory(buffer[], bufferlen);


/**
* Register a new item in CSGO Classy main menu.
*
* @param menu_code			The menu where the item will be added.
* @param item_name 			Item name that will be displayed.
* @param min_rankid 			Minimum rankid user must have to access the item.
*
* @note					-1 means there is no rank. Setting a value higher than -1
*						will add a text beside menu name with the minimum rank name.
*
* @note					If the user doesn't have the minimum rank, he will restricted from
*						accessing the menu and will be informed by a chat message. 
*
* @return					Menu item id or NativeErrorCode:INVALID_RANK_ID on invalid rankid.		
*/
native any:csgo_register_menu(const MenuCode:menu_code, const item_name[], const min_rankid = -1);


/**
* Used to register item inventory specific value to be calculated
* in inventory total value in menu user.
*
* @param id				Player index.
* @param item_id			The menu where the item will be added.
* @param new_value 		Item inventory new value.
*
*
* @return				1 on success or NativeErrorCode value on error.		
*/
native any:csgo_add_inventory_item_value(const id, const item_id, const new_value);


/**
* Add additional item name for a specific user.
*
* @param menu_code		The menu where the item additional name will be added or changed.
* @param item_id 			Item id which name will be added or changed.
* @param min_rank 		Minimum rankid that can access the item.
*
* @note				If the item location is MenuCode:MENU_INVENTORY the additional name
*					will be added after the item inventory price text. 
*
* @return				1 on success or NativeErrorCode value on error.		
*/
native any:csgo_additional_menu_name(const MenuCode:menu_code, const item_id, const id, const additional_name[]);


/**
* Get the chat and menu prefixes.
*
* @param buffer_chat			Buffer to copy chat value in.
* @param chat_buffer_len		Size of the chat buffer.	
* @param buffer_menu			Buffer to copy menu value in.
* @param menu_buffer_len		Size of the menu buffer.	
*
*			
* @noreturn						
*/
native csgo_get_prefixes(buffer_chat[] = "", const chat_buffer_len = 0, buffer_menu[] = "", const menu_buffer_len = 0);

/**
* Get the chat and menu prefixes.
*
* @param host			Buffer to copy database hostname value in.
* @param hostlen		Size of the database hostname buffer.	
* @param user			Buffer to copy database username value in.
* @param userlen		Size of the database username buffer.	
* @param pass			Buffer to copy database password value in.
* @param passlen		Size of the database password buffer.	
* @param db				Buffer to copy menu database name in.
* @param dblen			Size of the database name buffer.	
*
* @note					Will throw an NativeErrorCode if the data save type is nVault.
*			
* @return				Return database MySQL Tuple Handle on success. 
*						NativeErrorCode:INVALID_SAVE_TYPE on fail					
*/
native any:csgo_get_mysql(const host[] = "", const hostlen = 0, const user[] = "", const userlen = 0, const pass[] = "", const passlen = 0, const db[] = "", const dblen = 0);

/**
* Return a player's money.
*
* @param id        	Player index.
* @param itemid		Item id.	
*
* @note 			Will throw an error in console if the player
*					is not connected.
*
* @return			Amount of points. NativeErrorCode value on error.
*/
native any:get_user_money(const id);


/**
* Set a player's money.
*
* @param id        	Player index.
* @param amount		New amount.	
* 
* @note 			Will throw an error in console if the player
*				is not connected or logged in.
*
* @return			1 on success. NativeErrorCode value on error.		
*/
native any:set_user_money(const id, const amount);


/**
* Return a player's scraps.
*
* @param id        	Player index.
*
* @note 			Will throw an error in console if the player
*				is not connected.		
*
* @return			Amount of scraps. NativeErrorCode value on error.
*/
native any:get_user_scraps(const id);


/**
* Set a player's scraps.
*
* @param id        	Player index.
* @param amount		New amount.	
* 
* @note 			Will throw an error in console if the player
*				is not connected or logged in.
*
* @noreturn		
*/
native any:set_user_scraps(const id, const amount);


/**
* Return a player's keys.
*
* @param id        	Player index.	
*
* @note 			Will throw an error in console if the player
*				is not connected.	
*
* @return			1 on success. NativeErrorCode value on error.		
*/
native any:get_user_keys(const id);


/**
* Set a player's keys.
*
* @param id        	Player index.
* @param amount		New amount.	
* 
* @note 			Will throw an error in console if the player
*				is not connected or logged in.
*
* @return			1 on success. NativeErrorCode value on error.		
*/
native any:set_user_keys(const id, const amount);


/**
* Return a player's keys.
*
* @param id       	Player index.	
*
* @note 			Will throw an error in console if the player
*				is not connected.
*	
* @return			Amount of keys on success. NativeErrorCode value on error.		
*/
native any:get_user_cases(const id);


/**
* Set a player's cases.
*
* @param id        	Player index.
* @param amount		New amount.	
* 
* @note 			Will throw an error message in console if the player
*				is not connected or logged in.
*
* @return			1 on success. NativeErrorCode value on error.
*/
native any:set_user_cases(const id, const amount);


/**
* Return a player's keys.
*
* @param id        	Player index.	
* @param buffer		Buffer to copy the rank.
* @param len		Lenght of the buffer.
*
* @note 			Will throw an error in console if the player
*				is not connected.
*
* @return			User rankid on success. NativeErrorCode value on error.
*/
native any:get_user_rank(const id, const buffer[], const len);


/**
* Set a player's cases.
*
* @param id        	Player index.
* @param rankid		New rankid.	
* 
* @note 			Param rankid is from 0 to x where x represents
*				the position of the rank in [RANKS] section from
*				csgoclassy.ini.
*
* @return			1 on success. NativeErrorCode value on error.
*/
native any:set_user_rank(const id, const rankid);


/**
* Return the invalid amount of a specific skin.
*
* @param id        	Player index.	
* @param skinid 		Skin id to check for.
*
* @note 			Will throw an NativeErrorCode in console if the player
*				is not connected or the skinid is invalid.
*	
* @return			Amount of skins on succes. NativeErrorCode value on error.
*/
native any:get_user_skins(const id, const skinid);


/**
* Set.
*
* @param id        		Player index.	
* @param skinid 			Skin id to check for.
* @param amount 			New amount of skins.
* @param stattrack 		Skin is stattrack or not (boolean value).
*
* @note 				Will throw and return an NativeErrorCode error in console if the player
*					is not connected, logged in or the skinid is invalid.
*	
* @return				1 on succes. NativeErrorCode value on error.
*/
native any:set_user_skins(const id, const skinid, const amount, const bool:stattrack);


/**
* Return a boolean value representing the logged state of a player.
*
* @param id        	Player index.	
*
* @note 			Will throw an NativeErrorCode in console if the player
*				is not connected or the param is invalid.
*	
* @return			true/false if is/not logged in. NativeErrorCode value on error.
*/
native any:is_user_logged(id);


/**
* Return a player's skintag capsules.
*
* @param id        	Player index.	
*
* @note 			Will throw an error in console if the player
*				is not connected.
*	
* @return			Amount of skintag capsules on success. NativeErrorCode value on error.		
*/
native any:get_user_capsules(const id);


/**
* Return a player's common skintags.
*
* @param id        	Player index.	
*
* @note 			Will throw an error in console if the player is not connected.
*	
* @return			Amount of common skintags on success. NativeErrorCode value on error.		
*/
native any:get_user_common(const id);


/**
* Return a player's rare skintags.
*
* @param id        	Player index.	
*
* @note 			Will throw an error in console if the player is not connected.
*	
* @return			Amount of rare skintags on success. NativeErrorCode value on error.		
*/
native any:get_user_rare(const id);


/**
* Return a player's mythic skintags.
*
* @param id        	Player index.	
*
* @note 			Will throw an error in console if the player is not connected.
*	
* @return			Amount of mythic skintags on success. NativeErrorCode value on error.		
*/
native any:get_user_mythic(id);


/**
* Return a player's rankid.
*
* @param id        	Player index.	
*
* @note 			Will throw an error in console if the player is not connected.
*	
* @return			Rankid on success. NativeErrorCode value on error.		
*/
native any:get_user_rank_id(id);


/**
* Return a player's common skintags.
*
* @param id        	Player index.	
*
* @note 			This must be documented in future.
*	
* @return			Rankid on success. NativeErrorCode value on error.		
*/
native any:autologin_value(const id);


/**
* Toggle autologin system for a player.
*
* @param id        	Player index.	
*
* @note 			This must be documented in future.
*	
* @return			Amount of common skintags on success. NativeErrorCode value on error.		
*/
native any:toggle_autologin(const id);
 

/**
* Open a specific CSGO Classy menu from MenuCode structure.
*
* @param id 			User Index 
* @param menu_code 		Menu code value 
*
* @note 				User must be connected and logged in.
*
* @return				1 on success. NativeErrorCode value on error. 		
*/
native any:display_menu(const id, MenuCode:menu_code);

/**
* Check if a logged in user is using default skins.
*
* @param id 			User Index  
*
* @note 				User must be connected and logged in.
*
* @return				true or false. NativeErrorCode value on error. 		
*/
native any:csgo_is_using_default_skin(const id);

/**
* Used to format the price in the mode.
*
* @param iNum 			Number to format
*
* @note 				Number 1000 wil become a string "5.000".
* @note				Stock created by Bugsy from alliedmodders.
*
* @return				Formatted string. 		
*/
stock AddCommas( iNum )
{
    new szTmp[ 17 ] , iOutputPos , iNumPos , iNumLen;
    new szOutput[27], iLen = charsmax(szOutput)

    iNumLen = num_to_str( iNum , szTmp , charsmax( szTmp ) );
    
    if ( iNumLen <= 3 )
    {
        iOutputPos += copy( szOutput[ iOutputPos ] , iLen , szTmp );
    }
    else
    {
        while ( ( iNumPos < iNumLen ) && ( iOutputPos < iLen ) ) 
        {
            szOutput[ iOutputPos++ ] = szTmp[ iNumPos++ ];
            
            if( ( iNumLen - iNumPos ) && !( ( iNumLen - iNumPos ) % 3 ) ) 
                szOutput[ iOutputPos++ ] = '.';
        }
            
        szOutput[ iOutputPos ] = EOS;
    }
    
    return szOutput;
} 


native set_user_login_value(const id, bool:value);
native any:is_user_silver_vip(id);
native any:get_user_played_time(id);
native any:is_user_gold_vip(id);