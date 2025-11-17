@echo off

call :do_compress u
call :do_compress uax
call :do_compress ukx
call :do_compress usx
call :do_compress utx

goto :end

:do_compress
:: Check if files exists
dir /A-D /B .\INPUT\*.%1 2>nul
if errorlevel 1 EXIT /B 1

for /f "tokens=*" %%a in ('dir /A-D /B .\INPUT\*.%1') do (
    call uz2 ..\uz2\INPUT\%%a
)
EXIT /B %ERRORLEVEL%

:end
pause

endlocal
