@echo off
cscript //nologo "%~f0?.wsf" %1
exit /b

<job><script language="VBScript">
Const ForWriting = 2
Dim FSO, f
Set oShell = CreateObject("WScript.Shell")
Set FSO=CreateObject("Scripting.FileSystemObject")
Set f=FSO.OpenTextFile("C:\Program Files\WinRAR\rarreg.key", ForWriting,true)
f.write("RAR registration data" & VbNewLine & "MUMBAI" & VbNewLine & "Unlimited Company License" & VbNewLine & "UID=a9c95181cb1cc6bdfdbf" & VbNewLine & "6412212250fdbf15381d40c19821fe54e3f5e08e2bcbc0e74d54a9" & VbNewLine & "72c0821c2139608f499460fce6cb5ffde62890079861be57638717" & VbNewLine & "7131ced835ed65cc743d9777f2ea71a8e32c7e593cf66794343565" & VbNewLine & "b41bcf56929486b8bcdac33d50ecf77399606da079df26411b62ea" & VbNewLine & "f6783e809c95c1dd56a5247a31da28f019429fb93d2b01854f5757" & VbNewLine & "652f89ba86f989035f4471f39cfeba69c70f49a5978aef1c609ec7" & VbNewLine & "e904cb14db49edd730e5018853425596d8ec5ceefd0c4134353128")
WScript.Sleep 2000
if MsgBox ("Operation fini avec succes ! Veux-tu lancer Winrar ?",vbYesNo+Vbinformation,"Made by Zalati !") = Vbyes then
oShell.Run("""C:\Program Files\WinRAR\WinRAR.exe""")
else
Wscript.Quit
End if
</script></job>
exit