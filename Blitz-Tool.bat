@echo off
Title Install Blitz and Block ads, Script made by Zalati
:menu
cls
echo --------------------
echo -- Menu du Script --
echo --------------------
echo.
echo Que voulez-vous faire ? (Repondez avec le numero)
echo 1 - Installer Blitz
echo 2 - Bloquer/Debloquer les pubs
echo 3 - Quitter
echo.
SET /p reponse1="Votre choix : "
If /i "%reponse1%"=="1" GOTO :InstallBlitz
If /i "%reponse1%"=="2" GOTO :DisableAdsMenu
If /i "%reponse1%"=="3" GOTO :end
ECHO "%reponse1%" n'est pas valide !
GOTO :error1

:: Installe Blitz
:InstallBlitz
cls
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -command "Start-BitsTransfer -Source https://blitz.gg/download/win -Destination C:\%HOMEPATH%\Downloads\Blitz-latest.exe"
cls
start C:\%HOMEPATH%\Downloads\Blitz-latest.exe
cls
del "C:\%HOMEPATH%\Downloads\Blitz-latest.exe" /S /F /Q
cls
echo *************************************************
echo *      l'installation de Blitz est fini !     *
echo *************************************************
echo Appuyez sur une touche pour retourner au menu.
pause > nul
cls
GOTO menu

::Menu bloqueur de pubs
:DisableAdsMenu
cls
Rem Suppression de l'ancienne version de AdsManager
IF NOT EXIST "C:\%HOMEPATH%\Downloads\AdsManager-Blitz.bat" echo Notice: Pas d'ancienne version du AdsManager.
IF EXIST "C:\%HOMEPATH%\Downloads\AdsManager-Blitz.bat" del "C:\%HOMEPATH%\Downloads\AdsManager-Blitz.bat" /S /F /Q
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -command "Start-BitsTransfer -Source https://zalati.fr/tools/AdsManager-Blitz.bat -Destination C:\%HOMEPATH%\Downloads\AdsManager-Blitz.bat"
call C:\%HOMEPATH%\Downloads\AdsManager-Blitz.bat
cls
echo *************************************************
echo *         Execution de AdsManager...            *
echo *************************************************
echo Appuyez sur une touche pour retourner au menu.
pause > nul
goto menu

::Erreur
:error1
echo Appuyez sur une touche pour retourner au menu.
pause > nul
cls
goto menu

::Ferme le script
:end
exit