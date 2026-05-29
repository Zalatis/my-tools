@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ----------------------------------------
rem LOG : 1 = enable output.log
rem       0 = disable output.log
rem ----------------------------------------
set "LOG=0"
set "LOGFILE=%~dp0output.log"

if "%LOG%"=="1" type nul > "%LOGFILE%"

call :log [INFO] Started at %DATE% %TIME%
call :log.

set "ROOT=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render"
set "MATCH=Logitech HX2E Surround Sound Effect"
set "IGNORE=Yeti"
set "VALUE={1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5"
set "DATA=1"

whoami /user | findstr /i "S-1-5-18" >nul 2>&1
if errorlevel 1 (
    call :log [WARNING] Script is not running as SYSTEM.
) else (
    call :log [INFO] Running as SYSTEM.
)
call :log.

set /a FOUND=0
set /a SKIPPED=0
set /a UPDATED=0

set "TMPFILE=%TEMP%\mmdevices_keys.txt"
reg query "%ROOT%" > "%TMPFILE%" 2>nul
findstr /r /i "\\{[^}]*}$" "%TMPFILE%" > "%TMPFILE%.filtered" 2>nul

for /f "usebackq delims=" %%K in ("%TMPFILE%.filtered") do (
    set "KEYPATH=%%K"
    set "FX=%%K\FxProperties"

    reg query "!FX!" >nul 2>&1
    if not errorlevel 1 (
        reg query "!FX!" /f "%IGNORE%" /d /s >nul 2>&1
        if not errorlevel 1 (
            call :log [SKIP] Ignored device ^(matched %IGNORE%^): !KEYPATH!
            set /a SKIPPED+=1
        ) else (
            reg query "!FX!" /f "%MATCH%" /d /s >nul 2>&1
            if not errorlevel 1 (
                call :log [MATCH] Found %MATCH%: !KEYPATH!
                set /a FOUND+=1

                reg add "!FX!" /v "%VALUE%" /t REG_DWORD /d %DATA% /f >nul 2>&1
                if errorlevel 1 (
                    call :log [WARN] Failed to write !FX!
                ) else (
                    call :log [OK] Set %VALUE%=%DATA% on !FX!
                    set /a UPDATED+=1
                )
            )
        )
    )
)

del "%TMPFILE%" >nul 2>&1
del "%TMPFILE%.filtered" >nul 2>&1

call :log.
call :log [INFO] Matching devices : %FOUND%
call :log [INFO] Skipped devices  : %SKIPPED%
call :log [INFO] Updated devices  : %UPDATED%

call :log.
call :log [INFO] Finished at %DATE% %TIME%
call :log ----------------------------------------

endlocal
exit /b 0

:log
if "%~1"=="" (
    echo.
    if "%LOG%"=="1" >> "%LOGFILE%" echo.
    goto :eof
)
echo %*
if "%LOG%"=="1" >> "%LOGFILE%" echo %*
goto :eof