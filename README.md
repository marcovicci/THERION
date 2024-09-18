# wot is dis

Second Life nonsense

THERION_HUD controls the HUD object, which has many beautiful buttons.

THERION_RECEIVER controls the head itself, with dynamic or idle animations, selectable deformers etc and can also find parts of itself to toggle on/off.

Some buttons exist in groups where only one can be toggled. Others are toggles that can coexist. Yay!

## Just added:

Receiver script first pass. Slightly changed the way animation info is sent (now only send the type of animation and the anim number, the receiver can figure out the animation prefix on its own).

The safelyStartAnimation() function in the receiver is my baby that I've used in previous HUDs; given a type of animation and an integer all those animations end with, it will go through and turn off everything you don't want playing. For example, sending a directive to play Ear5 will turn off Ear0-Ear7 too or whatever. In this case it's all a little uglier because we're also using an animation prefix but it works great, including with deformers!

# wot is next

TODO: Clean up safelyAnimate() function so that it handles animation prefixes by itself

TODO: clarify with Foe which teeth parts are button controlled/can coexist

TODO: clarify with Foe whether head fluff buttons control separate types of fluff or asymmetrical, and whether they can coexist

TODO: sending instructions for dynamic animations and idle twitches

TODO: See which persistent storage is actually necessary for the head and what can be cut, most of it I just have there as a backup but it's probably extraneous with the help of the HUD.
