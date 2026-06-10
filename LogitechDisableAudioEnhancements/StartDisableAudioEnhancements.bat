@echo off
setlocal EnableExtensions

:: ----------------------------------------
:: Auto-Elevation
:: ----------------------------------------
net session >nul 2>&1
if errorlevel 1 (
    echo [INFO] Les droits administrateur sont requis. Demande d'‚l‚vation...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Start-Process -FilePath '%~f0' -WorkingDirectory '%~dp0' -Verb RunAs"
    if errorlevel 1 (
        echo [ERREUR] La demande d'‚l‚vation a ‚t‚ annul‚e ou a ‚chou‚.
        echo Veuillez faire un clic droit sur ce fichier puis choisir "Ex‚cuter en tant qu'administrateur".
        pause
        exit /b 1
    )
    exit /b
)

:: ----------------------------------------
:: Chemins
:: ----------------------------------------
set "BASEDIR=%~dp0"
if "%BASEDIR:~-1%"=="\" set "BASEDIR=%BASEDIR:~0,-1%"

set "TASKNAME=LogitechDisableAudioEnhancements"
set "CMD=%SystemRoot%\System32\cmd.exe"
set "SCRIPT=%BASEDIR%\utils\DisableAudioEnhancements.bat"

:: ----------------------------------------
:: Verification des fichiers
:: ----------------------------------------

if not exist "%CMD%" (
    echo [ERREUR] Fichier introuvable :
    echo %CMD%
    pause
    exit /b 1
)

if not exist "%SCRIPT%" (
    echo [ERREUR] Fichier introuvable :
    echo %SCRIPT%
    pause
    exit /b 1
)

:: ----------------------------------------
:: Verifie si la tache existe deja
:: ----------------------------------------
schtasks /query /tn "%TASKNAME%" >nul 2>&1
if not errorlevel 1 goto :run_existing

:: ----------------------------------------
:: Cr‚ation de la tƒche
:: ----------------------------------------
echo [INFO] La tƒche planifi‚e "%TASKNAME%" n'existe pas encore.
echo [INFO] Cr‚ation de la tƒche...

schtasks /create ^
 /tn "%TASKNAME%" ^
 /tr "\"%CMD%\" /c \"%SCRIPT%\"" ^
 /delay 0000:30 ^
 /rl HIGHEST ^
 /sc onlogon ^
 /ru SYSTEM ^
 /f

if errorlevel 1 (
    echo [ERREUR] Impossible de cr‚er la tƒche planifi‚e "%TASKNAME%".
    pause
    exit /b 1
)

echo [OK] Tƒche planifi‚e cr‚‚e : %TASKNAME%
echo [INFO] Script      : %SCRIPT%
echo.

choice /m "Voulez-vous lancer la tƒche maintenant"
if errorlevel 2 goto :end
goto :run_task

:run_existing
echo [INFO] La tƒche planifi‚e "%TASKNAME%" existe d‚j….
echo [INFO] Lancement direct de la tƒche...
goto :run_task

:run_task
schtasks /run /tn "%TASKNAME%"
if errorlevel 1 (
    echo [AVERTISSEMENT] La tƒche existe mais n'a pas pu ˆtre lanc‚e imm‚diatement.
    pause
    exit /b 1
)

echo [OK] Tƒche lanc‚e.
echo.
echo [INFO] Fermeture dans 5 secondes...
timeout /t 5 /nobreak >nul
exit /b 0

:end
echo [INFO] Aucune ex‚cution demand‚e.
pause
exit /b 0