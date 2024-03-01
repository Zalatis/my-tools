@echo off
setlocal enabledelayedexpansion

set "DiscordPath=%localappdata%\Discord"
set "LatestVersion="

for /d %%d in ("%DiscordPath%\app-*") do (
    set "Version=%%~nxd"
    set "Version=!Version:app-=!"
    if "!Version!" gtr "!LatestVersion!" (
        set "LatestVersion=!Version!"
    )
)

if defined LatestVersion (
    set "DiscordExe=%DiscordPath%\app-!LatestVersion!\Discord.exe"
    if exist "!DiscordExe!" (
        start "" "!DiscordExe!" --multi-instance
    ) else (
        echo L'ex‚cutable Discord n'est pas trouv‚ pour la version !LatestVersion!
        pause
    )
) else (
    echo Discord n'est pas install‚ dans %localappdata%\Discord
    pause
)

endlocal
