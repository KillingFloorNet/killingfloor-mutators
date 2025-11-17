# Glass House

[![GitHub all releases](https://img.shields.io/github/downloads/InsultingPros/Glassmutator/total)](https://github.com/InsultingPros/Glassmutator/releases)

KF Team Deathmatch:

> Both teams spawn with M79 grenade launchers and must blow up the opposing team's building floor by floor. Respawns are infinite, but each time a floor is destroyed you will spawn on the next available floor down. Once the last spawn area in your building is destroyed you will not be able to respawn if you die. Oh and i guess I should also mention that there are dozens of angry fleshpounds at street level.

## Installation

```cpp
Game=Glassmutator.GlasshouseGameInfo
```

## Building and Dependancies

At the moment of 2021.11.05 there are no dependencies. Make sure you have `GlassHouse_Tex.utx` in your compile directory's `Texture` folder / install the package.

Use [KF Compile Tool](https://github.com/InsultingPros/KFCompileTool) for easy compilation.

**EditPackages**

```cpp
EditPackages=Glassmutator
```

## Credits

All credits to [KF Alex](https://steamcommunity.com/profiles/76561197968508560). Original, outdated version lies here: [Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=98035013), [TWI Forum](https://forums.tripwireinteractive.com/index.php?threads/outskirts.79224/).

My edits:

- Fixed few function redefinitions which were causing game crashes.
- Converted all hard linked classes.
- Recompiled the package for KF 1065.
- Changed messy commenting style.
