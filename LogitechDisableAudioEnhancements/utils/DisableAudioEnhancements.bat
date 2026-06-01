@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "LOG=1"
set "LOGFILE=%~dp0output.log"

set "LGHUB_DIR=C:\Program Files\LGHUB"
set "LGHUB_AGENT=%LGHUB_DIR%\lghub_agent.exe"
set "LGHUB_GL=%LGHUB_DIR%\lghub_gl.exe"
set "WAIT_SECONDS=5"

set "ROOT=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render"
set "MATCH=Logitech HX2E Surround Sound Effect"
set "IGNORE=Yeti"
set "VALUE={1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5"
set "DATA=1"

rem Retry behavior
set "MAX_PASSES=30"
set "PASS_DELAY=10"
set "STABLE_NEEDED=6"

if "%LOG%"=="1" type nul > "%LOGFILE%"

call :log [INFO] Started at %DATE% %TIME%
call :log.

call :wait_for_lghub
call :log.

whoami /user | findstr /i "S-1-5-18" >nul 2>&1
if errorlevel 1 (
    call :log [WARNING] Script is not running as SYSTEM.
) else (
    call :log [INFO] Running as SYSTEM.
)
call :log.

set /a PASS=0
set /a STABLE=0

:retry_loop
set /a PASS+=1
call :log [INFO] Pass !PASS!/%MAX_PASSES%

set /a FOUND=0
set /a SKIPPED=0
set /a UPDATED=0
set /a VERIFIED=0

call :process_devices

call :log [INFO] Matching devices : !FOUND!
call :log [INFO] Skipped devices  : !SKIPPED!
call :log [INFO] Updated devices  : !UPDATED!
call :log [INFO] Verified devices : !VERIFIED!

if !FOUND! GTR 0 if !FOUND! EQU !VERIFIED! (
    set /a STABLE+=1
    call :log [INFO] Stable pass count: !STABLE!/%STABLE_NEEDED%
) else (
    set /a STABLE=0
    call :log [INFO] Stability reset.
)

if !STABLE! GEQ %STABLE_NEEDED% (
    call :log [INFO] Registry value remained correct across consecutive passes.
    goto done
)

if !PASS! GEQ %MAX_PASSES% (
    call :log [WARN] Reached maximum passes before full stabilization.
    goto done
)

timeout /t %PASS_DELAY% /nobreak >nul
call :log.
goto retry_loop

:done
call :log.
call :log [INFO] Finished at %DATE% %TIME%
call :log ----------------------------------------
endlocal
exit /b 0

:process_devices
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

                call :ensure_value "!FX!"
            )
        )
    )
)

del "%TMPFILE%" >nul 2>&1
del "%TMPFILE%.filtered" >nul 2>&1
goto :eof

:ensure_value
set "TARGETKEY=%~1"

reg add "%TARGETKEY%" /v "%VALUE%" /t REG_DWORD /d %DATA% /f >nul 2>&1
if errorlevel 1 (
    call :log [WARN] Failed to write %TARGETKEY%
    goto :eof
)

set /a UPDATED+=1

set "CURRENT="
for /f "tokens=3" %%V in ('reg query "%TARGETKEY%" /v "%VALUE%" 2^>nul ^| find /i "%VALUE%"') do (
    set "CURRENT=%%V"
)

if /i "!CURRENT!"=="0x1" (
    call :log [OK] Verified %VALUE%=1 on %TARGETKEY%
    set /a VERIFIED+=1
) else (
    call :log [WARN] Value did not verify on %TARGETKEY% ^(current=!CURRENT!^)
)
goto :eof

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