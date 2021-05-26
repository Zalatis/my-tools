@echo off
chcp 65001
cls
Title Windows Terminal par défaut lors du lancement de fichiers bat
REM  --> Verification des permissions admin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> Si error flag, pas les droits admins.
if '%errorlevel%' NEQ '0' (
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:menu
cls
echo *************************************************
echo *                                               *
echo *            Quel est votre choix ?             *
echo *                                               *
echo *************************************************
echo.
echo 1 - Définir Windows Terminal par défaut
echo 2 - Définir CMD par défaut
echo.
SET /p choice="Your choice‖Votre choix : "
If /i "%choice%"=="1" goto :WindowsTerminal
If /i "%choice%"=="2" goto :DefaultCMD
echo.
echo "%choice%" is not a valid number‖n'est pas un numéro valide !
echo Press any key to return to the menu‖Appuyez sur une touche pour retourner au menu.
pause > nul
cls
goto language

:WindowsTerminal
reg add "HKEY_CLASSES_ROOT\batfile\shell\open\command" /ve /d "\"%LocalAppdata%\Microsoft\WindowsApps\wt.exe\" \"%%1\" \"%%*\"" /f
exit

:DefaultCMD
reg add "HKEY_CLASSES_ROOT\batfile\shell\open\command" /ve /d "\"%%1\" \"%%*\"" /f
exit