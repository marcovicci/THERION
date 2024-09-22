// I usually give everything a "product name" that is unique, so that the listener can discard anything for other products that may otherwise use the same channel
// It doesn't matter what this is set to as long as the same string is in the receiver and the HUD
string productName = "THERION_NYX_DEER";
string animationPrefix = "deer";
integer channel = 42069;
integer listenHandle;

// Handle current states for deformers, toggles, animations
integer brow;
integer ear;
integer mouth;
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

string page;
integer closed = TRUE;

key owner;

vector closed_position = <0.0, 0.0, -0.5565>;
vector open_position = <0.0, 0.0, -0.19>;

init()
{
    owner = llGetOwner();

    listenHandle = llListen(channel, "", "", "");

   // Here I can also take the TAB_SETTINGS list, which is readable by humans, and make a version that's much faster for the script to run through (using actual link numbers).

    loadStoredData();

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
        llLinksetDataWrite("mouth","0");
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
        llLinksetDataWrite("page","anims");
    }

    brow = (integer)llLinksetDataRead("brow");
    ear = (integer)llLinksetDataRead("ear");
    mouth = (integer)llLinksetDataRead("mouth");
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

    page = llLinksetDataRead("page");

}

toggleThisFace(integer prim, integer face, integer on)
{
    float alpha = 0.0;
    if (on) alpha = 1.0;
    llSetLinkPrimitiveParamsFast(prim,  [ PRIM_COLOR, face, <1.000, 1.000, 1.000>, alpha ] );
}

rotateHud(string destination)
{
    closed = FALSE;
    if (destination == "anims")
    {
        page = destination;
        llLinksetDataWrite("page",destination);
        llSetLinkPrimitiveParamsFast(LINK_ROOT,[PRIM_ROTATION, llEuler2Rot(<0,0.0,180>*DEG_TO_RAD)]);
        llSetLinkPrimitiveParamsFast(LINK_ROOT,[PRIM_POSITION, open_position]);
    }
    else if (destination == "options")
    {
        page = destination;
        llLinksetDataWrite("page",destination);
        llSetLinkPrimitiveParamsFast(LINK_ROOT,[PRIM_ROTATION,llEuler2Rot(<0,0.0,270>*DEG_TO_RAD)]);
        llSetLinkPrimitiveParamsFast(LINK_ROOT,[PRIM_POSITION, open_position]);
    }
    else if (destination == "closed")
    {
        closed = TRUE;
        llSetLinkPrimitiveParamsFast(LINK_ROOT,[PRIM_ROTATION,llEuler2Rot(<0,270,270>*DEG_TO_RAD)]);
        llSetLinkPrimitiveParamsFast(LINK_ROOT,[PRIM_POSITION, closed_position]);
    }
}

buttonHandlers(integer prim, integer face, string name)
{
    // This will handle what our buttons do based on the prim name and the face touched.

    // Any instructions we might have to send to the receiver for head controls
    // These will always start with the product name.
    list instructions = [];
    instructions += productName;

    if (name == "Pages")
    {

        // rotate!
        if (face == 0 && page != "anims")
        {
            rotateHud("anims");
        }
        if (face == 1 && page != "options")
        {
           rotateHud("options");
        }

    }
    if (name == "Brow" || name == "Ear" || name == "Lip" || name == "Tongue" || name == "Jaw" || name == "Lid")
    {
        // We need to send a few instructions: One to play an animation,
        // AND an animation to play corresponding to the button
        instructions += "animation";
        instructions += name;
        instructions += (string)face;

        // We set animation prefix at the top (in this case deer).
        // Next we send the name of this button (like Jaw etc)
        // and finally the number of the face we touched.
        // Yay! This will correspond to an animation!

        // We'll also need to toggle the buttons visually and save the currently playing animation
        llLinksetDataWrite(llToLower(name), (string)face);

        // Turn all buttons here "off"
        toggleThisFace(prim, ALL_SIDES, 0);

        // Turn the touched button "on"
        toggleThisFace(prim, face, 1);

        llWhisper(channel, llList2CSV(instructions));
    }
    if (name == "Dynamic")
    {
        string cur_alpha = llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, face ]),1);
        instructions += name;
        integer i;
        // Dynamic anims
        if (face < 5)
        {
            instructions += "Ears";
            instructions += face;
            // earses

            //turn off other earses dynamics and turn this one on

            for (i = 0; i < 5; i++)
            {
                toggleThisFace(prim, i, 0);
            }
            if (cur_alpha == "0.000000")
            {
                toggleThisFace(prim, face, 1);
                llWhisper(channel, llList2CSV(instructions));
            }
            else
            {
                instructions += "OFF";
                llWhisper(channel, llList2CSV(instructions));
            }

        }
        else
        {
            // face
            instructions += "Face";
            instructions += face;

            //turn off other face dynamics and turn this one on
            for (i = 5; i < 8; i++)
            {
                toggleThisFace(prim, i, 0);
            }
            if (cur_alpha == "0.000000")
            {
                instructions += "on";
                toggleThisFace(prim, face, 1);
                llWhisper(channel, llList2CSV(instructions));
            }
            else
            {
                instructions += "OFF";
                llWhisper(channel, llList2CSV(instructions));
            }
        }

    }
    if (name == "MiscAnim")
    {
        instructions += name;
        if (face == 0)
        {
            // Typing
            instructions += "Typing";
            typing = !typing;
            if (typing) toggleThisFace(prim, face, 1);
            else toggleThisFace(prim, face, 0);
            llLinksetDataWrite("typing", (string)typing);
            instructions += (string)typing;
            llWhisper(channel, llList2CSV(instructions));
        }
        if (face == 1)
        {
            // Blink
            instructions += "Blink";
            blink = !blink;
            if (blink) toggleThisFace(prim, face, 1);
            else toggleThisFace(prim, face, 0);
            llLinksetDataWrite("blink", (string)blink);
            instructions += (string)blink;
            llWhisper(channel, llList2CSV(instructions));

        }
        if (face == 4)
        {
            // Breathe
            instructions += "Breathe";
            breathe = !breathe;
            if (breathe) toggleThisFace(prim, face, 1);
            else toggleThisFace(prim, face, 0);
            llLinksetDataWrite("breathe", (string)breathe);
            instructions += (string)breathe;
            llWhisper(channel, llList2CSV(instructions));
        }
        if (face == 5)
        {
            // Flehmen
            instructions += "Flehmen";
            flehmen = !flehmen;
            if (flehmen) toggleThisFace(prim, face, 1);
            else toggleThisFace(prim, face, 0);
            llLinksetDataWrite("flehmen", (string)flehmen);
            instructions += (string)flehmen;
            llWhisper(channel, llList2CSV(instructions));
        }
        else
        {
            // Twitch anims
            string cur_alpha = llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, face ]),1);
            toggleThisFace(prim, 2, 0);
            toggleThisFace(prim, 3, 0);
            if (face == 2) instructions += "twitch_lil";
            if (face == 3) instructions += "twitch_full";
            if (cur_alpha == "0.000000")
            {
                toggleThisFace(prim, face, 1);
                instructions += 1;
                llWhisper(channel, llList2CSV(instructions));
            }
            else
            {
                instructions += 0;
                llWhisper(channel, llList2CSV(instructions));
            }
        }
    }
    if (name == "Fluff")
    {
        instructions += name;
        instructions += face;
        // toggle
        string cur_alpha = llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, face ]),1);
        if (cur_alpha == "0.000000")
            {
                toggleThisFace(prim, face, 1);
                instructions += 1;
                llWhisper(channel, llList2CSV(instructions));
            }
            else
            {
                toggleThisFace(prim, face, 0);
                instructions += 0;
                llWhisper(channel, llList2CSV(instructions));
            }
    }

    else if (name == "Lash")
    {
        instructions += name;
        // toggle
        if (face == 0)
        {
            // upper
            instructions += face;
            lash_upper = !lash_upper;
            if (lash_upper) toggleThisFace(prim, face, 1);
            else toggleThisFace(prim, face, 0);
            llLinksetDataWrite("lash_upper", (string)lash_upper);
            instructions += (string)lash_upper;
            llWhisper(channel, llList2CSV(instructions));

        }
        else if (face == 1)
        {
            // middle
            instructions += face;
            lash_middle = !lash_middle;
            if (lash_middle) toggleThisFace(prim, face, 1);
            else toggleThisFace(prim, face, 0);
            llLinksetDataWrite("lash_middle", (string)lash_middle);
            instructions += (string)lash_middle;
            llWhisper(channel, llList2CSV(instructions));

        }
        else if (face == 2)
        {
            // lower
            instructions += face;
            lash_lower = !lash_lower;
            if (lash_lower) toggleThisFace(prim, face, 1);
            else toggleThisFace(prim, face, 0);
            llLinksetDataWrite("lash_lower", (string)lash_lower);
            instructions += (string)lash_lower;
            llWhisper(channel, llList2CSV(instructions));
        }
    }
    else if (name == "Teeth")
    {
        integer i;
        instructions += name;
        instructions += face;
        // toggle
        string special = llList2String(llGetLinkPrimitiveParams(prim, [ PRIM_COLOR, face ]),1);

        if (face < 2)
        {
            // teeth

            for (i = 0; i < 2; i++)
            {
                toggleThisFace(prim, i, 0);
            }
            if (special == "0.000000") toggleThisFace(prim, face, 1);
            else instructions += "OFF";
            llWhisper(channel, llList2CSV(instructions));
        }
        else if (face < 4)
        {
            // fangs
            for (i = 2; i < 4; i++)
            {
                toggleThisFace(prim, i, 0);
            }
            if (special == "0.000000") toggleThisFace(prim, face, 1);
            else instructions += "OFF";
            llWhisper(channel, llList2CSV(instructions));
        }
        else
        {
            // tusks
            for (i = 4; i < 7; i++)
            {
                toggleThisFace(prim, i, 0);
            }
            if (special == "0.000000") toggleThisFace(prim, face, 1);
            else instructions += "OFF";
            llWhisper(channel, llList2CSV(instructions));
        }
    }
    else if (name == "MiscOptions")
    {

        if (face == 4)
        {
            instructions += "bom";
            // Bom toggle
            llWhisper(channel, llList2CSV(instructions));
        }
        else if (face == 5)
        {
            // Eye rot
            instructions += "Eye_Rotate";
            llWhisper(channel, llList2CSV(instructions));
            // eye rotate
            eye_rot = !eye_rot;
            if (eye_rot) toggleThisFace(prim, face, 1);
            else if (eye_rot) toggleThisFace(prim, face, 0);
        }
        else
        {
            integer i;
            instructions += "deformer";
            // Bridge deformer

            instructions += face;
            llWhisper(channel, llList2CSV(instructions));

            for (i = 0; i < 4; i++)
            {
                toggleThisFace(prim, i, 0);
            }
            toggleThisFace(prim, face, 1);
        }
    }
}

default
{
    // This will run our startup/init function if the owner changed
    changed(integer change)
    {
        if(change & CHANGED_OWNER) init();
    }

    state_entry()
    {
        init();
    }

     // This is our button listener.
    touch_start(integer num_detected)
     {
      // First I grab the prim touched
      integer link = llDetectedLinkNumber(0);
      // If this is the root prim we should open/close the HUD
      if (link == 1)
      {
          // Open/close HUD
          if (closed) rotateHud(page);
          else rotateHud("closed");

      }
      else
      {
          // Let's continue
          integer face = llDetectedTouchFace(0);
          // I also want the name of the prim, since this will never change, but linkset order could :)
      string primName = llGetLinkName(link);

          // Now I can send this information up to my button handler function!
          buttonHandlers(link, face, primName);

      }


     }
}
