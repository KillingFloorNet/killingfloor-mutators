This mutator adds options to disable auto-reload and to make the reload animation interruptible. 

Options 

Allow to interrupt: allow actions, which can be changed in the config file (see below), to interrupt the reload animation. If interrupted, it has to start over. If the magazine has been removed during the animation, interrupting it will set the amount of ammo in the magazine to zero (the ammo won't be lost). 
Disable auto-reload: play a dry-fire sound instead of triggering auto-reload. 
Options to display in-game messages when the animation is interrupted and when your weapon needs to be reloaded or has no ammo.

Config file 

For an action to interrupt the reload animation, the corresponding alias has to be added to the mutator's config file. For example: 


ReloadOptionsMut.ini 

InterruptAliases=Jump
InterruptAliases=GetWeapon


User.ini 

Space=Jump
X=GetWeapon Knife | Say Take that, auto-reload!
