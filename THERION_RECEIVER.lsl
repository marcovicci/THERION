// I usually give everything a "product name" that is unique, so that the listener can discard anything for other products that may otherwise use the same channel
// It doesn't matter what this is set to as long as the same string is in the receiver and the HUD
string productName = "THERION_NYX_DEER";
string animationPrefix = "deer";
integer channel = 42069; 
integer listenHandle;
key owner;

// Timers for emotes n blinks
integer blink_rate = 50;
integer blink_timer;
integer emote_rate = 150;
integer emote_timer;

// Handle current states for deformers, toggles, animations
integer brow;
integer ear;
integer lip;
integer tongue;
integer jaw;
integer lid;

integer typing;
integer blink;
integer twitch_full;
integer twitch_lil;
integer breathe;
integer flehmen;

integer fluff_ear;
integer fluff_head;
integer fluff_muzzle;
integer fluff_neck;

integer lash_upper;
integer lash_middle;
integer lash_lower;

integer teeth;
integer fangs;
integer tusks;

integer bridge_deform;

integer bom;

integer eye_rot;

integer is_talking;
integer talk_time;

init()
{
    owner = llGetOwner();
    listenHandle = llListen(channel, "", "", "");
    loadStoredData();
    llRequestPermissions(owner, PERMISSION_TRIGGER_ANIMATION);
}

loadStoredData()
{
    // This function is for writing / reading stored data. 
    // I use it to store things like what deformer is playing,
    // and it will survive even if the script resets!
    
    if (llLinksetDataCountKeys() == 0)
    {
        // This will only happen if there's no stored data at all. 
        // If so, we'll write initial values in.
        
        llLinksetDataWrite("brow","0");
        llLinksetDataWrite("ear","0");
        llLinksetDataWrite("lip","0");
        llLinksetDataWrite("tongue","0");
        llLinksetDataWrite("jaw","0");
        llLinksetDataWrite("lid","0");
    
        llLinksetDataWrite("typing","1");
        llLinksetDataWrite("blink","1");
        llLinksetDataWrite("twitch_full","0");
        llLinksetDataWrite("twitch_lil","0");
        llLinksetDataWrite("breathe","1");
        llLinksetDataWrite("flehmen","0");
    
        llLinksetDataWrite("fluff_ear","0");
        llLinksetDataWrite("fluff_head","0");
        llLinksetDataWrite("fluff_muzzle","0");
        llLinksetDataWrite("fluff_neck","0");
    
        llLinksetDataWrite("lash_upper","0");
        llLinksetDataWrite("lash_middle","0");
        llLinksetDataWrite("lash_lower","0");
    
        llLinksetDataWrite("teeth","0");
        llLinksetDataWrite("fangs","0");
        llLinksetDataWrite("tusks","0");
    
        llLinksetDataWrite("bridge_deform","0");
    
        llLinksetDataWrite("bom","0");
    
        llLinksetDataWrite("eye_rot","0");
    }
    
     brow = (integer)llLinksetDataRead("brow");
    ear = (integer)llLinksetDataRead("ear");
    lip = (integer)llLinksetDataRead("lip");
    tongue = (integer)llLinksetDataRead("tongue");
    jaw = (integer)llLinksetDataRead("jaw");
    lid = (integer)llLinksetDataRead("lid");

    typing = (integer)llLinksetDataRead("typing");
    blink = (integer)llLinksetDataRead("blink");
    twitch_full = (integer)llLinksetDataRead("twitch_full");
    twitch_lil = (integer)llLinksetDataRead("twitch_lil");
    breathe = (integer)llLinksetDataRead("breathe");
    flehmen = (integer)llLinksetDataRead("flehmen");

    fluff_ear = (integer)llLinksetDataRead("fluff_ear");
    fluff_head = (integer)llLinksetDataRead("fluff_head");
    fluff_muzzle = (integer)llLinksetDataRead("fluff_muzzle");
    fluff_neck = (integer)llLinksetDataRead("fluff_neck");

    lash_upper = (integer)llLinksetDataRead("lash_upper");
    lash_middle = (integer)llLinksetDataRead("lash_middle");
    lash_lower = (integer)llLinksetDataRead("lash_lower");

    teeth = (integer)llLinksetDataRead("teeth");
    fangs = (integer)llLinksetDataRead("fangs");
    tusks = (integer)llLinksetDataRead("tusks");

    bridge_deform = (integer)llLinksetDataRead("bridge_deform");

    bom = (integer)llLinksetDataRead("bom");

    eye_rot = (integer)llLinksetDataRead("eye_rot");
   
}


stop_all_animations()
{
    // Stops all animations found in the objects contents.
    integer inv_count = llGetInventoryNumber(INVENTORY_ANIMATION);
    while(inv_count--){
        string inv_name = llGetInventoryName(INVENTORY_ANIMATION, inv_count);
        if(inv_name){
            llStopAnimation(inv_name);
        }
    }
}

toggleThisFace(integer prim, integer face, integer on)
{
    float alpha = 0.0;
    if (on) alpha = 1.0;
    llSetLinkPrimitiveParamsFast(prim,  [ PRIM_COLOR, face, <1.000, 1.000, 1.000>, alpha ] );
}

playCurrentAnims()
{
    safelyStartAnimation(animationPrefix + "Lid", lid);
    safelyStartAnimation(animationPrefix + "Jaw", jaw);
    safelyStartAnimation(animationPrefix + "Brow", brow);
    safelyStartAnimation(animationPrefix + "Ear", ear);
    safelyStartAnimation(animationPrefix + "Lip", lip);
    safelyStartAnimation(animationPrefix + "Tongue", tongue);
    safelyStartAnimation(animationPrefix + "NoseDeform", bridge_deform);
    
}

animate()
{
    // Idle animations and breathing will go in here 
    // TODO actually animate twitches
    
    if (twitch_full)
    {
        // Idles
        emote_timer++;
        if (emote_timer > emote_rate)
        {
            emote_timer = 0;
            
            
        }
    }
    
    if (twitch_lil)
    {
      
        emote_timer++;
        if (emote_timer > emote_rate)
        {
            emote_timer = 0;
           
        }
    }
    
    // Controls typing ... this looks like a bunch of fuck but it's so that it also works properly with voice controlled gestures
    if (typing)
    {
        if(is_talking && talk_time > 0)
        {
            if (llGetInventoryType(animationPrefix + "Talk") == 20) llStartAnimation(animationPrefix + "Talk");
            talk_time--;
        }
        else if(llGetAgentInfo(owner) & AGENT_TYPING)
        {
            if (llGetInventoryType(animationPrefix + "Talk") == 20) llStartAnimation(animationPrefix + "Talk");
        }
        else
        {
            is_talking = FALSE;
            if (llGetInventoryType(animationPrefix + "Talk") == 20) llStopAnimation(animationPrefix + "Talk");
        }
    }
    else
    {
        is_talking = FALSE;
        if (llGetInventoryType(animationPrefix + "Talk") == 20) llStopAnimation(animationPrefix + "Talk");
    }
    
    // Starting and stopping breathing anims and flehmen response
    if (breathe)
    {
        if (llGetInventoryType(animationPrefix + "Breathe") == 20) llStartAnimation(animationPrefix + "Breathe");
    }
    
    else
    {
        if (llGetInventoryType(animationPrefix + "Breathe") == 20) llStopAnimation(animationPrefix + "Breathe");
    }
    
    if (flehmen)
    {
        if (llGetInventoryType(animationPrefix + "Flehmen") == 20) llStartAnimation(animationPrefix + "Flehmen");
    }
    
    else
    {
        if (llGetInventoryType(animationPrefix + "Flehmen") == 20) llStopAnimation(animationPrefix + "Flehmen");
    }
    
}


safelyStartAnimation(string prefix, integer number)
{
    integer i;
    for (i = 1; i < 7; i++)
    {
        string anim = prefix + (string)i;
        if (llGetInventoryType(anim) == 20) llStopAnimation(anim);
    }
    string anim = prefix + (string)number;
    if (llGetInventoryType(anim) == 20) llStartAnimation(anim);
}

integer findThatPart(string name)
{

    // In case we need to target named parts of the head
     integer i; 
     for (i = 0; i <= llGetNumberOfPrims(); i++)
     {
      string primName = llGetLinkName(i);
      if (primName == name) return i;
     }
     return -1;


}

receiveMsg(string message)
{
    list instructions = llCSV2List(message);
    
    // Instructions go in this order: product name, instruction type, then details
    
    // If the product name doesn't match, stop now!
    if (llList2String(instructions, 0) != productName) return;
    
    // Otherwise, we can start to process the instructions!
    string instructionType = llList2String(instructions, 1);
 
    if (instructionType == "Talk")
    {
        //For voice gestures!
        is_talking = TRUE;
        talk_time = 10;
    }
    if (instructionType == "Refresh")
    {
        // Just refresh current animations. 
    
        playCurrentAnims();
    }
    
    else if (instructionType == "Eye_Rotate")
    {
        // Eye rotation script will go here :) I can guess at it...
        
        integer eye_prim = findThatPart("Eyeballs");
        if (eye_prim == -1) return; //ABORT, NO EYEBALLS
        
        eye_rot = !eye_rot;
        
        if (eye_rot)
        {
            // Furry eyes
            llSetLinkPrimitiveParamsFast(eye_prim, [ PRIM_TEXTURE, ALL_SIDES, "52cc6bb6-2ee5-e632-d3ad-50197b1dcb8a", <1.0,1.0,0.0>, <0.0,0.0,0.0>, 0.0] );
        }
        else
        {
            // Human eyes
            llSetLinkPrimitiveParamsFast(eye_prim, [ PRIM_TEXTURE, ALL_SIDES, "52cc6bb6-2ee5-e632-d3ad-50197b1dcb8a", <1.0,1.0,0.0>, <0.0,0.0,0.0>, 0.0] );
        }
        
        
    }
    else if (instructionType == "animation")
    {
        // Next instruction will tell us which part we're animating
        string bodypart = llList2String(instructions, 2);
        // And finally animation number
        integer anim_number = llList2Integer(instructions, 3);
        
        if (bodypart == "Lid")
        {
             lid = anim_number;
             llLinksetDataWrite("lid",(string)anim_number);
        }
        else if (bodypart == "Jaw")
        {
             jaw = anim_number;
             llLinksetDataWrite("jaw",(string)anim_number);
        } 
        else if (bodypart == "Brow")
        {
             brow = anim_number;
             llLinksetDataWrite("brow",(string)anim_number);
        } 
        else if (bodypart == "Ear")
        {
             ear = anim_number;
             llLinksetDataWrite("ear",(string)anim_number);
        } 
        else if (bodypart == "Lip")
        {
             lip = anim_number;
             llLinksetDataWrite("lip",(string)anim_number);
        } 
        else if (bodypart == "Tongue")
        {
             tongue = anim_number;
             llLinksetDataWrite("tongue",(string)anim_number);
        } 
        
        safelyStartAnimation(animationPrefix + bodypart, anim_number);
        
    }
    
    else if (instructionType == "deformer")
    {
        // Toggle off previous bridge deformers and toggle on this one
        bridge_deform = (integer)llList2String(instructions, 2);
        llLinksetDataWrite("bridge_deform",(string)bridge_deform);
        safelyStartAnimation(animationPrefix + "NoseDeform", bridge_deform);
    }
    
    else if (instructionType == "Lash")
    {
        // Turning on/off different lashes
        string toggleType = llList2String(instructions, 2);
        string onOff = llList2String(instructions, 3);
        
        integer lash_prim = findThatPart("lashes");
        if (lash_prim == -1) return; //ABORT, NO LASHES
        
        if (toggleType == "0")
        {
            
            lash_upper = (integer)onOff;
            
            toggleThisFace(lash_prim, 2, (integer)onOff);
            toggleThisFace(lash_prim, 5, (integer)onOff);

            
        }
        else if (toggleType == "1")
        {
            
            lash_middle = (integer)onOff;
            toggleThisFace(lash_prim, 1, (integer)onOff);
            toggleThisFace(lash_prim, 4, (integer)onOff);

            
        }
        else if (toggleType == "2")
        {
            
            lash_lower = (integer)onOff;
            toggleThisFace(lash_prim, 0, (integer)onOff);
            toggleThisFace(lash_prim, 3, (integer)onOff);
            
        }
    }
    
    else if (instructionType == "Teeth")
    {
        integer whichTooth = (integer)llList2String(instructions, 2);
        if (whichTooth < 2)
        {
            // TODO two "Teeth" buttons, toggling between jaw sets?
        }
        else if (whichTooth < 4)
        {
            // two "Fangs" buttons... double check what these do from Foe
        }
         else
        {
            // three "Tusks" buttons... double check what these do from Foe
        }
    }
    
    else if (instructionType == "MiscAnim")
    {
        // Turning on/off blink, typing, breath, twitches, flehmen
        string toggleType = llList2String(instructions, 2);
        string onOff = llList2String(instructions, 3);
        
        // TODO make sure these are actually triggering animations! will need to adjust timers and differentiate between the two types of twitches
        
        if (toggleType == "Blink")
        {
        blink = (integer)onOff;
        }
        if (toggleType == "Flehmen")
        {
        flehmen = (integer)onOff;     
        }
        else if (toggleType == "Typing")
        {
            typing = (integer)onOff;
        }
        else if (toggleType == "Breathe")
        {
            breathe = (integer)onOff;
        }
        else if (toggleType == "twitch_full")
        {
            twitch_full = (integer)onOff;
        }
        else if (toggleType == "twitch_lil")
        {
            twitch_lil = (integer)onOff;
        }
        
        
         llLinksetDataWrite(toggleType, onOff);

    }
    
    else if (instructionType == "Dynamic")
    {
       // TODO dynamic animations, five ear and 3 face

    }

}


default
{
    // This will run our startup/init function if the owner changed
    changed(integer change)
    {
        if(change & CHANGED_OWNER || CHANGED_TELEPORT) init();
    }

    on_rez(integer start_param)
    {
         init();
    }
    
    state_entry()
    {
         init();
    }

    listen( integer channel, string name, key id, string message )
    {
           // Cool fix here to allow gestures: this checks if either the OWNER of the talking object is the you, or if the talking object is you. So messages sent from YOUR HUD and messages sent from ... your ... you ... both count.
        if (llGetOwnerKey(id) == owner || id == owner) receiveMsg(message);
    }
    
    run_time_permissions(integer perm)
    {
        if(perm & PERMISSION_TRIGGER_ANIMATION)
        {
            // my disgusting, hopefully not too laggy microtimer
            llSetTimerEvent(0.1);  
            playCurrentAnims();
        }
        else
        {
            llRequestPermissions(owner, PERMISSION_TRIGGER_ANIMATION);
        }
    }
    
    timer()
    {
       animate();
    }
    
    
}
