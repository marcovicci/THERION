// I usually give everything a "product name" that is unique, so that the listener can discard anything for other products that may otherwise use the same channel
// It doesn't matter what this is set to as long as the same string is in the receiver and the HUD
string productName = "THERION_NYX_DEER";
string animationPrefix = "deer";
integer channel = 42069;
integer listenHandle;
key owner;

string ears_texture = "2b83ca01-404f-f13c-96ce-bc381fede319";
string mouth_texture = "10c08abb-a62b-ba20-d5b0-1a98108ad617";
string neck_texture = "c71d6d74-b6f9-2fd1-8470-995f4ffc7940";
string head_texture = "d6c057cb-78fb-04f1-bfd3-b0853b773172";

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

integer ear_idle;
integer face_idle;

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

    ear_idle = (integer)llLinksetDataRead("ear_idle");
    face_idle = (integer)llLinksetDataRead("face_idle");

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
    if (ear_idle) safelyStartIdle(animationPrefix + "Ear", ear);
    else safelyStartAnimation(animationPrefix + "Ear", ear);
    if (face_idle) safelyStartIdle(animationPrefix + "Face", ear);
    else
    {
        safelyStartAnimation(animationPrefix + "Lid", lid);
        safelyStartAnimation(animationPrefix + "Jaw", jaw);
        safelyStartAnimation(animationPrefix + "Brow", brow);
        safelyStartAnimation(animationPrefix + "Lip", lip);
        safelyStartAnimation(animationPrefix + "Tongue", tongue);
    }

    safelyStartAnimation(animationPrefix + "NoseDeform", bridge_deform);

}

animate()
{
    // Idle animations in here

    if (blink)
    {
        blink_timer++;
        if (blink_timer > blink_rate)
        {
            blink_timer = 0;
            if (llGetInventoryType(animationPrefix + "Blink") == 20) llStartAnimation(animationPrefix + "Blink");

        }
    }

    if (twitch_full)
    {
        // Idles
        emote_timer++;
        if (emote_timer > emote_rate)
        {
            emote_timer = 0;
            if (llGetInventoryType(animationPrefix + "EarFlick0") == 20) llStartAnimation(animationPrefix + "EarFlick0");

        }
    }

    else if (twitch_lil)
    {

        emote_timer++;
        if (emote_timer > emote_rate)
        {
            emote_timer = 0;
           // Coin flip between ear flicks
           string ear;
           float coinFlip = llFrand(10.0);
           if (coinFlip > 5.0) ear = "L";
           else ear = "R";
           if (llGetInventoryType(animationPrefix + "EarFlick" + ear) == 20) llStartAnimation(animationPrefix + "EarFlick" + ear);
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

safelyStartIdle(string prefix, integer number)
{
    integer i;
    for (i = 1; i < 7; i++)
    {
        string anim = prefix + (string)i;
        if (llGetInventoryType(anim) == 20) llStopAnimation(anim);
    }
    string anim = prefix + "Idle" + (string)number;
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

    else if (instructionType == "bom")
    {
        if (bom)
        {

            // set all relevant faces to non bom channels
        integer i;

        // Head textures
        integer prim = findThatPart("1head");
        if (prim != -1) llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, ALL_SIDES, head_texture, <1.0,1.0,0.0>, <0.0,0.0,0.0>, 0.0] );
        prim = findThatPart("headfluff");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether fluff is toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, head_texture, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
     }

     // Neck textures
     prim = findThatPart("neck");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether fluff is toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, neck_texture, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
     }

     // Earses
     prim = findThatPart("ears");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether fluff is toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, ears_texture, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
     }
     prim = findThatPart("earsmuley");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether fluff is toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, ears_texture, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
     }

     // Mouth
     prim = findThatPart("teeth");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether teeth are toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, mouth_texture, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );

     }
     prim = findThatPart("tongue");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether teeth are toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, mouth_texture, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );

     }
     prim = findThatPart("fangs");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether teeth are toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, mouth_texture, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
     }
        }
        else
        {
            // set all relevant faces to BOM channels
        integer i;

        // BAKED HEAD
        integer prim = findThatPart("1head");
        if (prim != -1)
        {
            llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, ALL_SIDES, IMG_USE_BAKED_HEAD, <1.0,1.0,0.0>, <0.0,0.0,0.0>, 0.0] );
            llSetLinkPrimitiveParamsFast(prim, [PRIM_ALPHA_MODE, ALL_SIDES, PRIM_ALPHA_MODE_MASK,100] );
    }
        prim = findThatPart("headfluff");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether fluff is toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, IMG_USE_BAKED_HEAD, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
if (cur_alpha == 1.0) llSetLinkPrimitiveParamsFast(prim, [PRIM_ALPHA_MODE, i, PRIM_ALPHA_MODE_MASK,100] );
     }

     // BAKED LEFTLEG FOR NECK
     prim = findThatPart("neck");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether fluff is toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, IMG_USE_BAKED_LEFTLEG, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
if (cur_alpha == 1.0) llSetLinkPrimitiveParamsFast(prim, [PRIM_ALPHA_MODE, i, PRIM_ALPHA_MODE_MASK,100] );
     }

     // BAKED AUX1 FOR EARS
     prim = findThatPart("ears");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether fluff is toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, IMG_USE_BAKED_AUX1, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
if (cur_alpha == 1.0) llSetLinkPrimitiveParamsFast(prim, [PRIM_ALPHA_MODE, i, PRIM_ALPHA_MODE_MASK,100] );
     }
     prim = findThatPart("earsmuley");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether fluff is toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, IMG_USE_BAKED_AUX1, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
if (cur_alpha == 1.0) llSetLinkPrimitiveParamsFast(prim, [PRIM_ALPHA_MODE, i, PRIM_ALPHA_MODE_MASK,100] );
     }

     // BAKED AUX2 FOR MOUTH
     prim = findThatPart("teeth");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether teeth are toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, IMG_USE_BAKED_AUX2, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
if (cur_alpha == 1.0) llSetLinkPrimitiveParamsFast(prim, [PRIM_ALPHA_MODE, i, PRIM_ALPHA_MODE_MASK,100] );
     }
     prim = findThatPart("tongue");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether teeth are toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, IMG_USE_BAKED_AUX2, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
if (cur_alpha == 1.0) llSetLinkPrimitiveParamsFast(prim, [PRIM_ALPHA_MODE, i, PRIM_ALPHA_MODE_MASK,100] );
     }
     prim = findThatPart("fangs");
        if (prim != -1) for (i = 0; i <= llGetLinkNumberOfSides(prim); i++)
     {
      // Smartly recall whether teeth are toggled on and off
      float cur_alpha = (float)llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, i ]),1);
      llSetLinkPrimitiveParamsFast(prim, [ PRIM_TEXTURE, i, IMG_USE_BAKED_AUX2, <1.0,1.0,0.0>, <0.0,0.0,0.0>, cur_alpha] );
if (cur_alpha == 1.0) llSetLinkPrimitiveParamsFast(prim, [PRIM_ALPHA_MODE, i, PRIM_ALPHA_MODE_MASK,100] );
     }
        }
        bom = !bom;
        llLinksetDataWrite("bom",(string)bom);
    }
    else if (instructionType == "Eye_Rotate")
    {
        // Eye rotation script will go here :) I can guess at it...

        integer eye_prim = findThatPart("forwardseyes");
        if (eye_prim == -1)
            {
                // try another
                eye_prim = findThatPart("sidewayseyes");
                if (eye_prim == -1) return; //ABORT
            }

        eye_rot = !eye_rot;
        llLinksetDataWrite("eye_rot",(string)eye_rot);

        if (eye_rot)
        {
            // Furry eyes
            llSetLinkPrimitiveParamsFast(eye_prim, [ PRIM_TEXTURE, ALL_SIDES, "52cc6bb6-2ee5-e632-d3ad-50197b1dcb8a", <1.0,1.0,0.0>, <0.0,0.0,0.0>, 0.0] );
        }
        else
        {
            // Human eyes
            llSetLinkPrimitiveParamsFast(eye_prim, [ PRIM_TEXTURE, ALL_SIDES, "52cc6bb6-2ee5-e632-d3ad-50197b1dcb8a", <1.0,1.0,0.0>, <0.0,0.0,0.0>, -90.0] );
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

    else if (instructionType == "Fluff")
    {
        integer whichFluff = (integer)llList2String(instructions, 2);
        string onOff = llList2String(instructions, 3);
        if (whichFluff < 2)
        {
            // earses
            integer fluff_prim = findThatPart("earsmuley");
            if (fluff_prim == -1)
            {
                // try another
                fluff_prim = findThatPart("ears");
                if (fluff_prim == -1) return; //ABORT
            }
            if (whichFluff == 0)
            {
                // tips
                toggleThisFace(fluff_prim, 1, (integer)onOff);
                toggleThisFace(fluff_prim, 4, (integer)onOff);
            }
            else if (whichFluff == 1)
            {
                // insides
                toggleThisFace(fluff_prim, 2, (integer)onOff);
                toggleThisFace(fluff_prim, 5, (integer)onOff);
            }
        }
        else if (whichFluff < 4)
        {
            // head
            integer fluff_prim = findThatPart("headfluff");
            if (fluff_prim == -1) return; //ABORT
            if (whichFluff == 2)
            {
                // skull
                toggleThisFace(fluff_prim, 2, (integer)onOff);
                toggleThisFace(fluff_prim, 6, (integer)onOff);
            }
            else if (whichFluff == 3)
            {
                // cheeks
                toggleThisFace(fluff_prim, 0, (integer)onOff);
                toggleThisFace(fluff_prim, 4, (integer)onOff);
            }
        }
        else if (whichFluff < 6)
        {
            // muzzle
            integer fluff_prim = findThatPart("headfluff");
            if (fluff_prim == -1) return; //ABORT
            if (whichFluff == 4)
            {
                // mouth
                toggleThisFace(fluff_prim, 3, (integer)onOff);
                toggleThisFace(fluff_prim, 7, (integer)onOff);
            }
            else if (whichFluff == 5)
            {
                // chin
                toggleThisFace(fluff_prim, 1, (integer)onOff);
                toggleThisFace(fluff_prim, 5, (integer)onOff);
            }
        }
        else
        {
            // neck
            integer fluff_prim = findThatPart("neck");
            if (fluff_prim == -1) return; //ABORT
            if (whichFluff == 6)
            {
                // whole neck
                toggleThisFace(fluff_prim, 1, (integer)onOff);
                toggleThisFace(fluff_prim, 3, (integer)onOff);
            }
        }
    }

    else if (instructionType == "Teeth")
    {
        integer whichTooth = (integer)llList2String(instructions, 2);
        string special = llList2String(instructions, 3);
        if (whichTooth < 2)
        {

            integer tooth_prim = findThatPart("teeth");
            if (tooth_prim == -1) return;

            // Toggle off both jawsets
            toggleThisFace(tooth_prim, 0, 0);
            toggleThisFace(tooth_prim, 3, 0);

            // Toggle on chosen jawset
            if (special != "OFF")
            {
               if (whichTooth == 0) toggleThisFace(tooth_prim, 0, 1);
               else if (whichTooth == 1) toggleThisFace(tooth_prim, 3, 1);
            }

        }
        else if (whichTooth < 4)
        {
            // two "Fangs" buttons...
            integer tooth_prim = findThatPart("teeth");
            if (tooth_prim == -1) return;

            // Toggle off both jawsets
            toggleThisFace(tooth_prim, 4, 0);
            toggleThisFace(tooth_prim, 2, 0);

            // Toggle on chosen jawset
            if (special != "OFF")
            {
            if (whichTooth == 2) toggleThisFace(tooth_prim, 4, 1);
            else if (whichTooth == 3) toggleThisFace(tooth_prim, 2, 1);
        }
        }
         else
        {
            // three "Tusks" buttons...
            integer tooth_prim = findThatPart("fangs");
            if (tooth_prim == -1) return;

            // Toggle off both jawsets
            toggleThisFace(tooth_prim, 0, 0);
            toggleThisFace(tooth_prim, 1, 0);
            toggleThisFace(tooth_prim, 2, 0);

            // Toggle on chosen jawset
            if (special != "OFF")
            {
            if (whichTooth == 4) toggleThisFace(tooth_prim, 0, 1);
            else if (whichTooth == 5) toggleThisFace(tooth_prim, 1, 1);
            else if (whichTooth == 6) toggleThisFace(tooth_prim, 2, 1);
        }
        }
    }

    else if (instructionType == "MiscAnim")
    {
        // Turning on/off blink, typing, breath, twitches, flehmen
        string toggleType = llList2String(instructions, 2);
        string onOff = llList2String(instructions, 3);

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
            // Set other twitch off
            twitch_lil = 0;
            llLinksetDataWrite("twitch_lil", (string)0);

            twitch_full = (integer)onOff;
        }
        else if (toggleType == "twitch_lil")
        {
            // Set other twitch off
            twitch_full = 0;
            llLinksetDataWrite("twitch_full", (string)0);

            twitch_lil = (integer)onOff;
        }


         llLinksetDataWrite(toggleType, onOff);

    }

    else if (instructionType == "Dynamic")
    {
       // dynamic animations, five ear and 3 face

        string toggleType = llList2String(instructions, 2);
        string anim = llList2String(instructions, 3);
        string special = llList2String(instructions, 4);
        if (toggleType == "Ears")
        {
            if (special == "OFF")
            {
                ear_idle = FALSE;
                llLinksetDataWrite("ear_idle", "0");
                stop_all_animations();
            }
            else
            {
               ear_idle = TRUE;
               llLinksetDataWrite("ear_idle", "1");
               safelyStartIdle(animationPrefix + "Ear", (integer)anim);
            }
        }
        else if (toggleType == "Face")
        {
            if (special == "OFF")
            {
                face_idle = FALSE;
                llLinksetDataWrite("face_idle", "0");
                stop_all_animations();
            }
            else
            {

                integer correctedAnim = (integer)anim - 5;
               face_idle = TRUE;
               llLinksetDataWrite("face_idle", "1");
               safelyStartIdle(animationPrefix + "Face", correctedAnim);

            }
        }
        playCurrentAnims();

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
