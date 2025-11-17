To install -

Drop KFMod20 directory from zip directly into your root UT2004 install dir.

ex. 

C:\UT2004\


you would have

C:\UT2004\KFMod20\


Do not move any of the items inside the KFMod20 folder OUTSIDE of it for any reason. 

To Run the mod click "RunKF".bat out of the KFmod20 root folder.



To Add Bots to your server -

You need to log in as an administrator.

1. Open KFMod20.ini in your system folder ( you will need to start the game once to regenerate it)
2. Look for the "Engine.GameReplicationInfo"  section of the file
3. Change server name to something you like. 
4. Under AdminName, enter a name.  
5. Scroll to the "UWeb.Webserver"  part of the file, and make sure "benabled" is set "true"
6. Scroll to Engine.AccessControl and set "AdminPassword" to something you can remember.
7. Save the file, and close it.


That's it!  Now all you have to do is start your server up, and when you get inside the game, bring down the 
console with "~" and type "AdminLogin AdminName AdminPass"

ex.  if I set my name to be "SuperAdminMan" and Pass to be "CheeseNibbleys", my AdminLogin would require

"AdminLogin SuperAdminMan CheeseNibbleys"  , and that should do it.

When you are logged in the BotControl portion of the lobby menu will become available. You should select a choice from
the bot menu to initialize it before clicking "add bot", or it may not work immediately (bug).

Have Fun!



still having trouble?
go here :

http://geeks.beyondunreal.com/ut2004/docs-dedicatedlinux.php