#include <amxmodx>

#pragma compress 1

new PLUGIN[]  = "Remove Radio Sprite"
new AUTHOR[]  = "renegade"
new VERSION[] = "1.0"

new g_iModelIndexRadio;

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_message(SVC_TEMPENTITY, "Msg_SVC_TempEntity")
}

public plugin_precache() 
{
    g_iModelIndexRadio = precache_model("sprites/radio.spr")
}

public Msg_SVC_TempEntity(iMsgId, iDest, id) 
{
    if(get_msg_arg_int(1) == TE_PLAYERATTACHMENT) 
    {
        if(get_msg_arg_int(4) == g_iModelIndexRadio) 
        {
            return PLUGIN_HANDLED
        }
    }
    
    return PLUGIN_CONTINUE
} 