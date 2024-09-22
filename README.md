# wot is dis

Second Life nonsense

THERION_HUD controls the HUD object, which has many beautiful buttons.

THERION_RECEIVER controls the head itself, with dynamic or idle animations, selectable deformers etc and can also find parts of itself to toggle on/off.

Some buttons exist in groups where only one can be toggled. Others are toggles that can coexist. Yay!

## Just added:

!! IMPORTANT !! I have renamed the deerEarFlap0 and deerEarFlap1 animations to deerEarIdle3 and deerEarIdle4. Forgive me ;_; it makes them really really easy to integrate into my new dynamic emotes system.

I took comprehensive notes of all the changes today and then accidentally deleted all of them. #winning

Teeth can now be toggled. They are mutually exclusive inside of their own categories (teeth, fangs, tusks) and if you toggle off one that is on, you have the option of having... none.

Head fluff can now be toggled. Doesn't use persistent storage, just checks the alpha of the button, because it's fluff, who care

Dynamic animations are a thing now. Dynamic animations override static animations if any are selected. Possible TODO: should selecting a static animation automatically override any dynamic animations, too?

BOM function added to toggle between BOMs and default textures. The defaults can be changed at the top. Toggling textures SHOULD keep any hidden parts hidden.

Eye rotation works now as long as the eyes contain a receiver.

You can now toggle on either a small (one ear at random) or big twitch which will go on an emote timer.

# wot is next

TODO: integrate Skull's idea for the HUD saving its open and closed position. Is this the last thing I need to do before actual release???

TODO: Clean up my disgusting BOM function, it has a lot of repeated code. I can make a separate function to

TODO: Clean up safelyAnimate() function so that it handles animation prefixes by itself

TODO: See which persistent storage is actually necessary for the head and what can be cut, most of it I just have there as a backup but it's probably extraneous with the help of the HUD.
