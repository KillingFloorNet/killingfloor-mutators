-----------------------------------------------------------------------------
                                  ServerAdsKF
                                  Version 101
                                  by DeeZNutZ
                              deeznutz@san.rr.com
-----------------------------------------------------------------------------
ServerAdsKF is the successor of ServerAds2K4. This server add-on is only for 
Killing Floor Servers. ServerAdsKF gives you the ability to display advertisements,
news (or what ever kind of messages you want) on your server. Players will 
see these messages in their chat console. It's also possible to display so 
called "Admin messages".

Contents:
- New in this version
- How to install
- Configuration
- Admin Messages
- Web Downloads
- Source code
- Contact information

------------------------------ NEW IN THIS VERSION---------------------------
Version 101:
First release in Killing Floor version

Previously released under UT2004, so much testing has gone into this Server Actor.

-------------------------------- HOW TO INSTALL -----------------------------
You have to extract the contents of this zip file to your Killing Floor directory.
Keep the directory names intact: the "Web" files belong in the "Web" directory. No files will be
overwritten.
Place the ServerAdsKF.u file into your \killingfloor\system directory.

Now you have to edit your server configuration (KillingFloor.ini by default), make 
sure the server is no longer running.
Add the following lines to the configuration:

[Engine.GameEngine]
ServerActors=ServerAdsKF.ServerAdsKF

If you want to make use of the WebAdmin feature of ServerAdsKF you will also 
have to add these lines to the configuration (KillingFloor.ini):

[UWeb.WebServer]
Applications[2]=ServerAdsKF.WebAdmin
ApplicationPaths[2]=/ServerAdsKF

Note  : Replace the "2" with the first unused number
Note 2: The WebAdmin doesn't need any extra configuration, the Admin 
username and password are the same as the username and password of the normal
WebAdmin.

You have now installed ServerAdsKF. There are two ways to configure 
ServerAdsKF: edit the configuration file or via the WebAdmin. If you are 
going to use the WebAdmin (it's the easiest form) you have to start the 
server, otherwise the server should stay down.

To check if ServerAdsKF is correctly installed you only have to check the 
server's log file when it has been started. The following lines should be 
visible:

If you installed the WebAdmin portion:  
[~] ServerAdsKF WebAdmin loaded
And the server actor loading:
[~] Starting ServerAdsKF version: 101
[~] DeeZNutZ - deeznutz@san.rr.com
[~] BadStreak - http://www.badstreak.com
[~] There are 5 lines in the list


-----------------------------------------------------------------------------
TO ACCESS THIS FROM THE WebAdmin console, you will need to point your browser
at your Killing Floor WebAdmin console AND the ServerAdsKF control panel.  

By default it will look like the following:
http://xx.xx.xx.xx:8075/ServerAdsKF/

Your normal login/password credentials will then be required.

-------------------------------- CONFIGURATION ------------------------------
The configuration of ServerAdsKF belongs in the server configuration files 
(KillingFloor.ini by default). Here's an example configuration:

[ServerAdsKF.ServerAdsKF]
bEnabled=True
fDelay=30.000000
sLines[0]=First message
sLines[1]=Second message
sLines[2]=Third message
sLines[3]=Fourth message
sLines[4]=ServerAdsKF Made Specifically for KF Servers
sLines[5]=
.....
sLines[24]=
iGroupSize=1
iAdType=0
bWrapAround=True
iAdminMsgDuration=4
cAdminMsgColor=(B=0,G=255,R=255,A=127)
bUseURL=False
sURLHost=localhost
iURLPort=80
sURLRequest=/serverads.txt

bEnabled
  True/False
  With this you can turn ServerAds on and off
fDelay
  Number (floating point)
	The number of seconds between the messages (1 = one second, 1.5 = one and a 
  half second)
sLines[#]
  sLines[0] to sLines[24]
  The linex ServerAdsKF will display (25 max), prefix a line with a '#' to 
  make it an Admin Message
iAdType
  0,1,2
	There are 3 diffirent types for displaying the lines
	0 = Normal
  	  Lines are displayed the order they appear in the list.
	1 = Random lines
    	Lines are picked at random from the list.
	2 = Random groups
    	The starting line is randomly picked on every cycle. (With a group size 
      of one this type will behave the same way as "Random lines")
iGroupSize
  Number (integer)
	The number of lines to show in every cycle.
bWrapAround
  True/False
	With this option enabled ServerAdsKF will continue to the begining of the 
  list after it reached the end of the list.
iAdminMsgDuration
  Number (integer)
	The number of seconds an "Admin message" will stay visible.
cAdminMsgColor
  Color (B=0,G=255,R=255)
	The color of the "Admin message", use RGB values from 0 to 255.
bUseURL
  True/False
	Download the lines to use from a website, this will overwrite the lines in 
  the config file on every map change.
sURLHost
	The hostname of the webserver where the lines are located.
iURLPort
  Number (integer)
  The port where the webserver is running, usualy 80.
sURLRequest
  The relative URL from the root of the webserver, it as to start with a '/'.


------------------------------- ADMIN MESSAGES ------------------------------
When you are logged in as an admin on the game server you can send "Admin 
messages" by prefixing the chat message with a '#'. An admin message is just 
like a normal chat message except that it is displayed on the middle of the 
player's screen in a large font. ServerAdsKF also has the ability to display 
admin messages, just prefix the line you want to be an admin message with a 
'#'.
These messages are quite annoying so use them with caution.

-------------------------------- WEB DOWNLOADS ------------------------------
ServerAdsKF has the ability to download the lines you want to display on the 
server from a website. To do this you only have to point ServerAdsKF to the 
server and the location of the file that you want to be downloaded. The file 
MUST be a plain text file, you can use a script to generate this text file, 
but be sure you set the content type to "text/plain".
The result of the download will be saved in the configuration file, so the 
next time ServerAdsKF is started it will use the old lines until the news 
lines have been downloaded from the server.

--------------------------------- SOURCE CODE -------------------------------
ServerAdsKF is provided under the GPL. The complete source code is available
from the ServerAdsKF homepage. Please respect the GPL:
                      http://www.gnu.org/licenses/gpl.txt

----------------------------- CONTACT INFORMATION ---------------------------
ServerAdsKF has been written by DeeZNutZ <deeznutz@san.rr.com> 
DeeZNutZ is a member of BadStreak (BS for short, yeah, I know...)
If you have any questions you can contact me, but I will not reply to 
questions where the answers can be found in this document.

The latest version of this server add-on can be downloaded from: 
http://www.badstreak.com/UTFiles/KF/ServerAdsKF.zip
-----------------------------------------------------------------------------
Copyright / Permissions
-----------------------
ServerAdsKF has been created by DeeZNutZ specifically for Killing Floor Servers
-----------------------------------------------------------------------------
