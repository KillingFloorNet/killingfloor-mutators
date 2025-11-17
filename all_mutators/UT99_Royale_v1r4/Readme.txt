Name: UTRoyale
Version: 1r4
Author: Francesco Biscazzo
Date: 2019
Description: UTRoyale is a last man standing gametype where players have only 1 life. A zone is spawned and shrinks through the match, every player outside of it will get hit.

INDEX:
- Notes for players;
- Instructions for mappers;
- Configurable settings (Game ini);
- Configurable settings (User ini);
- Debug features;
- Information for developers;
- Changelogs;

Notes for players:
- Console commands:
-- cmd - Displays all the available commands;
-- stopmusic - Stops the music which is currently being played;
-- radarlegend - Shows the legend for the icons displayed on the radar;
-- radarpos <position> - Moves the radar to the specified position that can be a mix between a pair of words from this list 'top', 'left', 'right', 'bottom', 'middle' or just 'center';
-- resetradarsize - Resets the size of the radar;
-- radarsizedec [amount] - Decreases the radar size by the specified amount;
-- radarsizeinc [amount] - Increases the radar size by the specified amount;
-- togglePath - Toggles the visibility of the arrow that indicates the zone's center;
- Debug console commands:
-- [mutate] debugTeleport [<x> <y> <z>] - Teleports the player to a location, based on the radar and the mouse cursor coordinates unless 'mutate' is used;
-- [mutate] debugBlip [<lifespan> <type> <subtype> <x> <y> <z>] - Spawns a blip on a location, based on the radar and the mouse cursor coordinates unless 'mutate' is used;
-- debugToggleWallhack - Toggles wallhack;
-- mutate debugkilled - Simulate the killing of the viewing actor by a random bot;
- Input commands:
-- Jump - If you've been killed and you're currently viewing your killer in a killcam, takes a screenshot. NOTE: Screenshots are saved with the "sshot" command;

Instructions for mappers:
- The zone location relies on the playerstarts, so you should not add a playerstart to an unreachable location.
|
NOTE: When the zone starts shrinking every actor with "UTR_ZONE_SHRINKING_START" as tag will be triggered. Same happens when the zone stops shrinking with "UTR_ZONE_SHRINKING_STOP".
NOTE: When an actor stays right out of the zone and close to it and its tag is "UTR_OUT_OF_ZONE" it will be triggered. NOTE: A moving actor may move too fast and skip the trigger zone or may move inside the trigger zone multiple times;

Configurable settings (Game ini):
- [<UTRoyale_package>.UTRoyale]
-- config (subclasses will have their own value):
--- bDebug: If true the debug features will be enabled (see "Debug features");
--- bBotWeaponFix: Bots throws errors when having no weapon in the inventory, if bBotWeaponFix is set to True bots will be equipped with an inventory item;
--- bNoBots: If True bots won't be able to join the match;
--- bStartAlone: If True the match can be started even when only one player is on. (Used just because MinPlayers is globalconfig instead of config);
--- bStealth: If True, players will have their AmbientGlow set to 0;
--- bUseCentroid: If True the zone's center will be at the centroid between all the PlayerStart locations;
--- bUsePSNearCentroid: If True and if bUseCentroid is True then the zone's center will be at the PlayerStart which is the nearest to the centroid;
--- bUseRandomPS: If True the zone's center will be at a random picked PlayerStart;
--- zoneCountDown: Max countdown time in seconds before the zone spawns;
--- bUseMostBottomPSLevel: If True the zone's center will be at the most bottom level a PlayerStart have been placed in the map. Can work conjunction with the above zone's center settings;
--- bAdjSpeedByPlayersCount: If true the shrinking speed of the zone may increase by the players count. (e.g. when a player logs out the shrinking speed will increase);
--- speedIncByPlayersCount, speedMulByMapSize, speedIncByMapSizeDivByPlayers;
--- offZoneCheckRate: Interval time that has to pass before TakeDamage() is called on every actor outside of the zone;
--- extraInitialRadiusMulByMapSize: Extra radius to apply to the zone when spawned.
--- minRadius: Minimum radius the zone can shrink to;
--- damageMulByDist: Damage amount every actor outside of the zone gets depending on the distance from the zone's center;
--- bSpawnOutsideZone: If True players will be able to spawn outside of the zone;
--- actualMaxPlayers: Specifies how many players should be able to spawn based on factors like the map size and the amount of PlayerStarts in the map;
--- initialHealth: If not 0, specifies the health players will spawn with;
--- initialArmor: Specifies the armor charge players will spawn with;
--- bDrawItemsOnRadar: If True, inventory items will be visible on the radar;
--- bDrawSoundsOnRadar: If True, noises will be represented on the radar. NOTE: It won't work if bNoMonsters is set to True;
--- radarStepHearingDistMulByMapSize: Distance from the player a footstep sound needs to be represented on the radar;
--- radarOtherHearingDistMulByMapSize: Distance from the player a misc sound needs to be represented on the radar;
--- radarStepLoudnessAddTo: Loudness adjustment amount for footstep sounds on the radar;
--- radarOtherLoudnessAddTo: Loudness adjustment amount for misc sounds on the radar;
--- radarSightDistMulByMapSize: Maximum distance from the player in which an inventory item can be revealed on the radar;
--- radarMulBySightDistZ: Maximum distance on the Z axis from the player in which an inventory item can be revealed on the radar;
--- radarMinDistToShowZLevel: Maximum distance on the Z axis from the player in which an inventory item can be displayed on the radar as a up/down blip;
--- nearOutOfRadarMaxDist: Maximum distance between the zone center and the player before this last's opacity is 0;
--- deathBlipTime: Time in seconds a death representation on the radar can be visible;
--- bEnableKillCam: If True, killcam is enabled. NOTE: This is a beta feature and may have bugs;
--- killCamResolution: FPS of the killcam dolly zoom. NOTE: It is inversely proportional to the killcam's zoom fps;
--- killCamSpeed: Speed of the killcam dolly zoom;

Configurable settings (User ini):
- [<UTRoyale_package>.UTRHUD]
-- globalconfig (subclasses will share the same value):
--- bHideRadar: If True the radar is hidden, visible otherwise;
--- bRadarTop: If True the radar will be positioned at the top of the screen. If bRadarBottom is also True the radar will be positioned at the vertical middle of the screen;
--- bRadarBottom: If True the radar will be positioned at the bottom of the screen. If bRadarTop is also True the radar will be positioned at the vertical middle of the screen;
--- bRadarLeft: If True the radar will be positioned at the left of the screen. If bRadarRight is also True the radar will be positioned at the horizontal middle of the screen;
--- bRadarRight: If True the radar will be positioned at the right of the screen. If bRadarLeft is also True the radar will be positioned at the horizontal middle of the screen;
--- radarMarginMulByScreenX: Horizontal margin of the radar from the screen;
--- radarMarginMulByScreenY: Vertical margin of the radar from the screen;
--- radarSize: Size of the radar;
--- blipSize: Desired radar's blips size;

Debug features:
- Debug commands (See "Notes for players">"Debug console commands")

Information for developers:
- UTRoyale provides a base mutator class called UTRBaseMutator with these callbacks:
-- settingZoneLocation: Called when the location of the zone is being set;
-- settingInitialZoneRadius: Called when the initial radius of the zone is being set;
-- settingInitialShrinkingSpeed: Called when the initial speed of the zone is being set;
-- zoneSpawned: Called when the zone is spawned;
-- zoneShrinkingStarted: Called when the zone starts shrinking;
-- zoneShrinkingStopped: Called when the zone stops shrinking;
-- actorOutOfZone: Called for any actor that stays right out of the zone and close to it. NOTE: A moving actor may move too fast and skip the trigger zone or may move inside the trigger zone multiple times;
-- takeDamageOutOfZone: Called everytime an actor takes damage cause of being out of the zone;
-- manageNoise: Called when before a sound gets represented on the radar;
|
Classes descriptions:
- UTRArrow: Arrow used to indicate locations. E.g. The center of the zone;
- UTRBaseMutator: Base mutator of all the UTRoyale mutators (for its callbacks see "UTRBaseMutator callbacks");
- UTRBlip: Actor that can be shown as a blip on the radar and will be interpreted basing on its type and subtype;
- UTRDummyActor: Sometimes you just need an empty actor, this is for those cases;
- UTRHUD: Displays a radar and other features to improve UTRoyale gameplay;
- UTRInterpolationTimer: Interpolates its owner to the target location;
- UTRKillCamManager: Manages the interpolation an dolly zoom for the killcam;
- UTRKillCamTimer: Lets the owner view an interpolator until it reaches a killer and then lets the owner view the killer directly;
- UTRMutator: Shows a blip of type 'DEATH' on the radar when players die, also destroys the sound managers of the bots who died as they won't respawn anymore;
- UTRoyale: A last man standing gametype where players have only 1 life. A zone is spawned and shrinks through the match, every player outside of it will get hit;
- UTReplicationInfo: Manages UTRoyale's variables that need to be replicated;
- UTRSoundManager: Represents sounds as blips in the radar;
- UTRZone: A cool Icosphere;
- UTRTimerInfo: Basically a timer that stops after the specified maxIter(ation)s, unless they are set to 0 then it will loop forever until stopTimer() will be called;
- UTRUtils: Generally static functions;

Changelogs:
[v1r4]
- Removed a log;
[v1r3]
- Fixed the dolly zoom;
- Fixed the wallhack;
[v1r2]
- Changed the default value for killCamResolution;