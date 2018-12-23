@echo off & setlocal enabledelayedexpansion

if exist %~dp0build (
	echo Warning: this will delete all contents of the build folder and replace them
	echo with the contents of the includedfiles and modfolders directories. If you have
	echo done any work on any of this folder's contents you would like to keep please 
	echo make sure you have a backup and/or have moved/unpacked them to their appropriate
	echo places in the includedfiles and modfolders directories.
	@RD /S %~dp0build
)

rem // Move includedfiles to build folder
robocopy %~dp0includedfiles %~dp0build /MIR
rem // Move modfolders contents excluding non-unpacked archives to build folder
robocopy %~dp0modfolders %~dp0build\mods\ /XD *.ar /MIR

cd %CD%\modfolders\	

for /D /r %%G in ("*.ar") do (
	set curr=%%~G
	set curr=!curr:%CD%=!
	echo !curr!
	
	rem // Pack folders into archives
	..\ar0pack.exe %%~G
	
	rem // Move to build folder
	for /l %%x in (0, 1, 99) do (
		rem // Check for and move split files
		if %%x LSS 10 (
			if exist %%~G.ar.0%%x (
				move /Y %%~G.ar.0%%x %~dp0build\mods\!curr!.0%%x
			) else (
				break
			)
		) else (
			if exist %%~G.ar.%%x (
				move /Y %%~G.ar.%%x %~dp0build\mods\!curr!.%%x
			) else (
				break
			)
		)
	)
	move /Y %%~G.arl %~dp0build\mods\!curr!l
)
pause
