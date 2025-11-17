THIS IS NOT A LOCALIZATION. 
NOT whitelisted (yet).

Features: 
[+] Resolves all tilde characters to proper characters.
[+] Allows sending & receiving in-game text messages in any language
[+] Resolves jumbled player names if they are not ASCII-compliant, allowing them to show up properly in lobby, in-game chat and scoreboard. (Requires mutator to be activated)

NOTE: READ THE ENTIRE DESCRIPTION BELOW AND DON'T JUST CLICK SUBSCRIBE
YOUR GAME MAY FAIL TO LAUNCH IF YOU DON'T FOLLOW THE INSTRUCTIONS CAREFULLY.

This replaces the fonts in game with Noto Sans font. 
It fixes the annoying junk replacement characters when there are non-Latin characters.

Due to huge texture size only 2 font heights are used to conserve memory: 7 and 11. 
Therefore, it does have a side-effect of smaller text when it should be large.


The screenshot is provided as example only. The author is in no shape or form affliated with the servers presented.


1. Download font texture (MyUnicodeFont.utx) here: (3MB Compressed zip, uncompressed size 144MB) 
https://drive.google.com/file/d/0B-uxR8AhT03bTUdIOU1LNUF3UmM/view?usp=sharing 
The above goes to your Textures folder. 

2. Download mutator to fix player names here: (this goes to your System folder)
https://drive.google.com/open?id=0B-uxR8AhT03baFpTVHQ5NjBobVE

3a. To install, download these files and replace the same files in System folder: 
https://drive.google.com/file/d/0B-uxR8AhT03bTi1hSk9hcDZCcnM/view?usp=sharing 

3b. To UNINSTALL, download these files and replace the same files in System folder: 
https://drive.google.com/file/d/0B-uxR8AhT03bbTRKTVV0SWdCZzA/view?usp=sharing 

NOTE: The subscribe button will download int files and mutator only, you have to download the texture with the link provided above manually. 

Your thumbs up will show your support to the development and update to this feature.

Known Issues: 
- Outside gameplay, some strings are still not resolved.
- Side-effect of small text
- Noticable FPS drop at server menus (not fixable as I don't know how Tripwire coded it natively)
- For multiplayer, if the server does not run this mutator, all non-ASCII player names on the server will remain jumbled... d'oh.

Internal notes:
- DXT5 compression doesn't help with FPS (although it halved the uncompressed font texture size)
- FPS drop is due to CPU load not memory
- XInterface.GUIStyles.DrawText need a massive performance revamp
- DrawText is a native(C++) function, so it is impossible to optimize at UnrealScript level
- FPS drop is not fixable