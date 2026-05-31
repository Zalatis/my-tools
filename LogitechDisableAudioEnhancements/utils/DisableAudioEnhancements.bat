@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ----------------------------------------
rem LOG : 1 = enable output.log
rem       0 = disable output.log
rem ----------------------------------------
set "LOG=0"
set "LOGFILE=%~dp0output.log"

set "LGHUB_DIR=C:\Program Files\LGHUB"
set "LGHUB_AGENT=%LGHUB_DIR%\lghub_agent.exe"
set "LGHUB_GL=%LGHUB_DIR%\lghub_gl.exe"
set "WAIT_SECONDS=5"

if "%LOG%"=="1" type nul > "%LOGFILE%"

call :log [INFO] Started at %DATE% %TIME%
call :log.

rem ----------------------------------------
rem Wait for LGHUB processes first, but only if all exe files exist
rem ----------------------------------------
call :wait_for_lghub
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

:wait_for_lghub
set "ALL_EXIST=1"

if not exist "%LGHUB_AGENT%" (
    call :log [INFO] Missing file: %LGHUB_AGENT%
    set "ALL_EXIST=0"
)
if not exist "%LGHUB_GL%" (
    call :log [INFO] Missing file: %LGHUB_GL%
    set "ALL_EXIST=0"
)

if "%ALL_EXIST%" NEQ "1" (
    call :log [INFO] LGHUB not fully installed. Continuing without waiting.
    goto :eof
)

call :log [INFO] LGHUB executables found on disk.
call :log [INFO] Waiting for lghub_agent.exe and lghub_gl.exe...

:wait_loop
set "RUN_LGHUB=0"
set "RUN_AGENT=0"
set "RUN_GL=0"

tasklist /fi "IMAGENAME eq lghub_agent.exe" /fo csv /nh 2>nul | find /i "lghub_agent.exe" >nul
if not errorlevel 1 set "RUN_AGENT=1"

tasklist /fi "IMAGENAME eq lghub_gl.exe" /fo csv /nh 2>nul | find /i "lghub_gl.exe" >nul
if not errorlevel 1 set "RUN_GL=1"

if "!RUN_AGENT!!RUN_GL!" NEQ "11" (
    timeout /t %WAIT_SECONDS% /nobreak >nul
    goto wait_loop
)

call :log [INFO] lghub_agent.exe and lghub_gl.exe are running.
goto :eof

:log
if "%~1"=="" (
    echo.
    if "%LOG%"=="1" >> "%LOGFILE%" echo.
    goto :eof
)
echo %*
if "%LOG%"=="1" >> "%LOGFILE%" echo %*
goto :eof