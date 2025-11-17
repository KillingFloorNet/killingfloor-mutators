===============================================================================
1. DOWNLOADING
===============================================================================
Make sure you have downloaded both ScrnBundle parts:
https://www.dropbox.com/s/wi78chqqr8xw8ja/ScrnBundlePart1.zip?dl=1
https://www.dropbox.com/s/z6wrj53khsj3prx/ScrnBundlePart2.zip?dl=1
For dedicated servers download also Part3 (optional):
https://www.dropbox.com/s/73kh9uaaizttj7w/ScrnBundlePart3.zip?dl=1

Unzip all parts into your KillingFloor folder.
Bundle contains NO replacement of original KF files. If system ask you to
overwrite, then it means you already have some of custom content installed
(maybe via Steam Workshop). Just click "Overwrite" to ensure that you will
have correct version.


===============================================================================
2. INITIAL CONFIGURATION
===============================================================================

There are only a few changes must be done to make this bundle work.

#1. Open your (server's) KillingFloor.ini with text editor.
#2. Look fo VotingHandlerType line under [Engine.GameInfo] category and
    REPLACE it with the line below:
VotingHandlerType=KFMapVoteV2.KFVotingHandler

#3. Look for ServerActors lines under [Engine.GameEngine] category and
    ADD the following line beneath them:
ServerActors=NetReduceSE.NetReduceSE

That's all of configuration!

===============================================================================
3a. RUNNING THE GAME VIA CONSOLE COMMAND (Fast way)
===============================================================================
1.  Copy the line below (select line and press Ctrl+C):

start KF-WestLondon.rom?Listen?Game=ScrnBalanceSrv.ScrnGameType?Difficulty=7?GameLength=2?VACSecured=true?MaxPlayers=6?Mutator=ScrnSP.ServerPerksMutSE,ScrnBalanceSrv.ScrnBalance

2. Launch KF.
3. Open console (tilde by default) and press Ctrl+V to paste it, then ENTER.

That's it, You're ready to play :)
You can switch difficulty and game modes right in the game:
click "Main Menu" -> "Map Voting" and select config you wish.

===============================================================================
3b. RUNNING THE GAME VIA STEAM LAUNCH OPTIONS (Fastest way)
===============================================================================
If you don't have plans to play stupid vanilla, then you can set launch command
in steam to skip copy-pasting console command every time:
1.  Right-click on Killing Floor game in your Steam Library and select
    "Properties" from popup menu.
3.  Press "SET LAUNCH OPTIONS..." button.
4.  Copy the following line there:

KF-WestLondon.rom?Listen?Game=ScrnBalanceSrv.ScrnGameType?Difficulty=7?GameLength=2?VACSecured=true?MaxPlayers=6?Mutator=ScrnSP.ServerPerksMutSE,ScrnBalanceSrv.ScrnBalance

5. OK, then Close.

Now every time you launch KF, it will automatically launch ScrN Bundle game.

===============================================================================
3c. RUNNING THE GAME VIA GUI MENUS (Usual and slow way)
===============================================================================
If you want to play ScrN Bundle in Solo more or Listen a server, then do them
following steps:

1.  Launch the game.
2.  Click "Host the game". Do NOT click Solo, because it may crash the game.
3.  Choose "ScrN Floor" game type.
4.  Select Map. Game length selection is not available there, but we will fix
    it later.
5.  Go to "Mutators" page.
6.  Add the following mutators:
        ScrN Server Veterancy Handler
        The ScrN Balance Server
7.  Go to "Server Rules" page.
8.  Check "View Advanced Options"
9.  If you want to play Solo, then set Max Players = 1 and Max Spectators = 0.
    This will emulate Solo mode, but won't crash your game on some maps.
10. Go to "Sandbox" page. We won't use Sandbox mode. It is just a workaround
    how to set game length in custom game modes (ScrN Floor).
11. Select Difficulty and Game Length (do NOT use Custom!).
12. Click "LISTEN" button without leaving "Sandbox" page (or length will reset)


===============================================================================
4. FIRST TIME GAME SETUP
===============================================================================
When map is loaded but before you click "Ready" and start enjoying the action
I recommend to click "Main Menu" -> "ScrN Features" and customize your gameplay
experience. There you can enable/disable manual reload, damage number popups,
grenade cooking, switch between Classic and ScrN Cool HUD etc.
After that click "Settings" -> "Controls" and scroll down the control list
until you see "ScrN Features". There you can assign key for Quick Melee Bash,
Clear Zoom and other cool commands.


===============================================================================
5. SETTING UP DEDICATED SERVER
===============================================================================
This manual assumes that you already know how to setup KF dedicated server and
already have vanilla KF server installed.
Procedure for server installation is the same as for local machine:

a)  Do steps 1 and 2: download, unzip and configure KillingFloor.ini.
b)  Make sure you have downloaded Part3 too.
c)  Extract UZ2 folder from ScrnBundleUZ2.zip into your KillingFloor main folder.
d)  Goto UZ2 folder and launch "make_ScrnBundle_uz2.cmd"
    This will create all .uz2 files you need to put on your Fast-Redirect Server.
    "make_ScrnBundle_uz2.cmd" script is for Windows. I hope Linux admins are
    smart enough to figure out how to modify it for bash.
3)  Example of server launch command line:

ucc server KF-WestLondon.rom?Game=ScrnBalanceSrv.ScrnGameType?Difficulty=7?GameLength=2?VACSecured=true?MaxPlayers=12?Port=7707?Mutator=ScrnSP.ServerPerksMutSE,ScrnBalanceSrv.ScrnBalance log=KillingFloorServer.log
