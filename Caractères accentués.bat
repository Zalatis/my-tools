@echo off
setlocal enabledelayedexpansion

:: Prompt user for input
set /p input=Enter text with accented characters: 

:: Initialize variable to store converted output
set "converted="

:: Loop through each character in the input
for /l %%i in (0,1,1000) do (
    set "char=!input:~%%i,1!"
    if "!char!"=="" goto doneLoop

    :: Replace accented characters with your specific mappings
    if "!char!"=="é" (
        set "char=‚"
    ) else if "!char!"=="ç" (
        set "char=‡"
    )

    :: Append to converted string
    set "converted=!converted!!char!"
)

:doneLoop
:: Save to characters.txt
echo %converted% > characters.txt

echo Converted text saved to characters.txt

:: Open the file automatically
start "" characters.txt

pause
