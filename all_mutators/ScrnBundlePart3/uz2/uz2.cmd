@echo off
if .%1.==.. goto :noparam
if not exist %1 goto :nofile

..\system\ucc.exe compress %1
if errorlevel 1 goto :failed
move /y %1.uz2 .\OUTPUT\
GOTO:eof

:noparam
echo USAGE: uz2.cmd Path\filename.ext
exit /B 1

:nofile
echo ERROR! File %1 does not exists
exit /B 2

:failed
echo Compression failed
exit /B 3
