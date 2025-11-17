--Female Fleshpound v0.95--



--Description--
"Overtime you've grown stronger; we gained access to weapons cache's, upgraded gear, developed new tech and even found lost artifacts of power to counter the endless waves of clones. Well we weren't the only ones who've been upgrading. Kevin has been busy, he's brought something new along, oh it's happened before, you know him as the Husk, and you know how to deal with him. This time though, this time it's different. Refined technology to counter a unrefined nature, a temper that out matches even the Fleshpounds berzerker rage. Once that switch is flipped even a raging fleshpound runs for cover. Funny, those two may have made a cute couple had things been different. Well I hope your new toys are up to the job because she isn't going to hold back."
Trader just before last orders.

New custom ZED for Killing Floor. A Female Fleshpound, she isn't simply a a reskin, she has custom behavour and values to set her apart from the Fleshpound. She may be weaker, yet she is faster and a damn sight more pissed off.



--Install Instructions--

Download and install to your ...\steam\steamapps\common\killingfloor\ directory.
Select the game type Killing Floor
From mutators select Add Female Fleshpound
Launch game and enjoy. (Remember to come back and let us know what you think.)

Sandbox Code
Code:
FemaleFPZED_v095.FemaleFP
FemaleFPZED_v095.FemaleFP_MKII

--V0.95 Changelog-- (PooSH)
- Collision radius lowered to default
- Adjusted online head location
- VentEffects now are properly destroyed after FFP death
- Added Female Fleshpound MKII with adaptive skin feature: the more you shoot her the more resistance she gets to received damage type

--V0.93 Changelog-- (PooSH)
- FemaleFleshPound09_A.ukx, FemaleFleshPound_Snd.uax and FemaleFleshPound_T.utx renamed to FemaleFP_* to avoid further case mismatches.
- Lowered "Rage_Run" animation's rate (thanks to 3xzet)


--V0.92 Changelog-- (PooSH)
- New animation file: FemaleFleshPound09_A.ukx
- FemaleFleshPound_A.ukx is deprecated and can be deleted from Animations folder
- Windows clients check for Doom3Karma.ka file and enable/disable karma ragdoll animations depending of its existence
- Linux and Mac clients still are using bRagdolls config setting under [FemaleFPKarma FFPKarma] section in FemaleFPMut.ini.
- Both collision cylinders made wider (primary: 26->30, extended: 30->36)
- Head detection radius made slightly wider (7->8)
- Fixed hit animations
- FFP now plays hit animation only if received damage >= 100
- FFP can be flinch-locked only once in HoE, twice in Suicidal or 3 times on Hard and below
- Fixed a lot of Copy-Paste bugs that were referring to FP instead of FFP
- Fixed door breaking
- Modified DoorBash animation to call ClawDamageTarget() 3 times like male FP does
- Fixed Spin Damage
- Lowered Spin Damage to compensate bug fix
- Lowered damage of the first raged hit (52->45 on Normal, 91->78 on HoE)
- Fixed Rage Timer. 
- Rage Timer is set to 30[+5] seconds. This is 3x longer than male FP has but it doesn't reset on loosing LoS (same as SuperFP)
- Male and Female FPs are not fighting each other anymore, cuz you know...
  [todo] they should make love not war :)

  
--V0.82 Changelog-- (PooSH)
Fixed Karma config setting

  
--V0.81 Changelog--
Addressed pathing/colision issue
Addressed fast redirect issue with texture file.


--V0.8 Changelog--


Animations refined
-Door bash
-Headless walk

Texture Updates
-Skin texture was made dirtier
-Eyes are now emissive for the creep factor
-Red lights now more red.
-Metal less specular.

Custom Audio
-Krista Kangas (http://kristakangas.com/) provided the voice of the FFP.
-Movement/effects sounds.

Note about Voice.
I've purposely left it clean at this point. I plan to modulate in account for the mask. Any feedback or suggestions for further modulation will be taken into consideration.

 

--Known Issues---

Some audio levels are too high/low. (I have never come across such an awkward audio pipeline then in Unreal2)
Couple of animations still need refining.
Still clips through door when attacking it.


--Credits--

Hipnox - original concept, 3d assets, texture and animations
Whisky aka Gartley - asset management, sound & scripting
PooSH - scripting
Krista Kangas http://kristakangas.com/ - Voice Acting

Special thanks to ScaryGhost, 3xzet and Marco