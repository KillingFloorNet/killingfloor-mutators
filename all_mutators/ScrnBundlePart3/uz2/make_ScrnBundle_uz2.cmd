@echo off
setlocal ENABLEEXTENSIONS

Title Making Compressed Versions of ScrN Bundle Files


if not exist ..\system\ucc.exe goto no_ucc

del .\OUTPUT\*.uz2 2>nul

echo.
echo Making compressed versions of ScrN Bundle Part 1 files

echo.
echo ======================================================================
echo Animations
echo ======================================================================
call uz2 ..\Animations\2009DoomMonstersAnims.ukx
call uz2 ..\Animations\HMG_A.ukx
call uz2 ..\Animations\HTec_A.ukx
call uz2 ..\Animations\ScrnWeaponPack_A.ukx
call uz2 ..\Animations\ScrnZedPack_A.ukx

echo.
echo ======================================================================
echo Maps
echo ======================================================================
call uz2 ..\Maps\KFO-Foundry-SE.rom
call uz2 ..\Maps\KF-ScrnTestGrounds.rom

echo.
echo ======================================================================
echo Sounds
echo ======================================================================
call uz2 ..\Sounds\2009DoomMonstersSounds.uax
call uz2 ..\Sounds\HMG_S.uax
call uz2 ..\Sounds\ScrNFoundry.uax
call uz2 ..\Sounds\ScrnWeaponPack_SND.uax
call uz2 ..\Sounds\ScrnZedPack_S.uax

echo.
echo ======================================================================
echo StaticMeshes
echo ======================================================================
call uz2 ..\StaticMeshes\2009DoomMonstersSM.usx
call uz2 ..\StaticMeshes\ScrnWeaponPack_SM.usx
call uz2 ..\StaticMeshes\ScrnZedPack_SM.usx

echo.
echo ======================================================================
echo System
echo ======================================================================
call uz2 ..\System\FoundryObj.u
call uz2 ..\System\KFMapVoteV2.u
call uz2 ..\System\LaSGunSkins.u
call uz2 ..\System\MutKillMessage.u
call uz2 ..\System\ScrnStoryGame.u
call uz2 ..\System\ScrnTestGroundsUtil.u

echo.
echo ======================================================================
echo Textures
echo ======================================================================
call uz2 ..\Textures\2009DoomMonstersTex.utx
call uz2 ..\Textures\BDFonts.utx
call uz2 ..\Textures\CountryFlagsTex.utx
call uz2 ..\Textures\GunSkins_T.utx
call uz2 ..\Textures\HMG_T.utx
call uz2 ..\Textures\LaSGunSkins_T.utx
call uz2 ..\Textures\ScrnEmoticons32and64.utx
call uz2 ..\Textures\ScrnWeaponPack_T.utx
call uz2 ..\Textures\ScrnZedPack_T.utx


echo.
echo Making compressed versions of ScrN Bundle Part 2 files

echo.
echo ======================================================================
echo Animations
echo ======================================================================
call uz2 ..\Animations\ScrnAnims.ukx

echo.
echo ======================================================================
echo Sounds
echo ======================================================================
call uz2 ..\Sounds\ScrnSnd.uax

echo.
echo ======================================================================
echo System
echo ======================================================================
call uz2 ..\System\NetReduce.u
call uz2 ..\System\NetReduceSE.u
call uz2 ..\System\ScrnBalanceSrv.u
call uz2 ..\System\ScrnD3Ach.u
call uz2 ..\System\ScrnDoom3KF.u
call uz2 ..\System\ScrnDoshGrab.u
call uz2 ..\System\ScrnHMG.u
call uz2 ..\System\ScrnHTec.u
call uz2 ..\System\ScrnSP.u
call uz2 ..\System\ScrnVotingHandlerV4.u
call uz2 ..\System\ScrnWeaponPack.u
call uz2 ..\System\ScrnZedPack.u
call uz2 ..\System\ServerPerks.u
call uz2 ..\System\ServerPerksMut.u

echo.
echo ======================================================================
echo Textures
echo ======================================================================
call uz2 ..\Textures\D3Ach_T.utx
call uz2 ..\Textures\ScrnAch_T.utx
call uz2 ..\Textures\ScrnTex.utx
call uz2 ..\Textures\TSC_T.utx

del ..\system\steam_appid.txt
echo.
echo COMPRESSED FILES READY!
echo Move out\*.uz2 files to your Fast-Redirect server
echo.
goto exit

:no_ucc
echo ERROR! UCC not found.
echo You need to install KF Server or SDK.


:exit
endlocal
pause