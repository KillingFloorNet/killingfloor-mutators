@echo off
set sp=M82A1LLImut
set gf=D:\Steam\steamapps\common\killingfloor\System
echo -------------------------------Killing Processes-------------------------------
taskkill /F /IM killingfloor.exe > nul
taskkill /F /IM RUN_KF.exe > nul
echo -------------------------------Clearing Old Stuff------------------------------
del /f /q %sp%.u > nul
del /f /q %sp%.ucl > nul
del /f /q %sp%.u.uz2 > nul

del /f /q %gf%%sp%.u
del /f /q %gf%%sp%.ucl
echo -----------------------------------Compiling-----------------------------------
ucc make
echo ------------------------------------Copying------------------------------------
copy /Y %sp%.u "%gf%"
copy /Y %sp%.ucl "%gf%"
echo --------------------------------------Exit-------------------------------------
pause