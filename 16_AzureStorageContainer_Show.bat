
:: SCRIPT: AzureStorageContainer_Show.bat
:: ======================================
:: Shows a list of all storage blobs in the specified container.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell Version 3
::                 PowerShell Module Azure
::                 Get-AzureVMImageName.ps1, New-AzureVM.ps1

:: FLAGS
:: =====
:: /help       : Help. Displays the script documentation.
:: /table, /t  : Table. Shows the list in table format.
:: /full, /f   : Full. Shows the list in table format without
::               truncating information.


@ECHO OFF

FOR %%A IN (%*) DO (
    IF "%%A"=="/help" GOTO help
    IF "%%A"=="/HELP" GOTO help
)

GOTO script


:help

ECHO Shows a list of all storage blobs in the specified container.
ECHO.
ECHO AzureStorageContainer_Show.bat [/F] [/T]
ECHO.
ECHO   /F[ULL]   Shows the list in table format without truncating information.
ECHO   /T[ABLE]  Shows the list in table format.
ECHO.
GOTO :EOF


:script

:: Sets the root directory of the PowerShell scripts.
SET ps=PowerShell\

:: Sets the default container name and the command
:: with default properties selected.
SET container=vhds
SET   command=Get-AzureStorageBlob -Container vhds ^| Select Name, BlobType, Length, LastModified, SnapshotTime

:: Enables PowerShell scripts to run (if not already enabled).
powershell Set-ExecutionPolicy Unrestricted

IF "%1"=="/table" GOTO writetable
IF "%1"=="/TABLE" GOTO writetable
IF "%1"=="/t"     GOTO writetable
IF "%1"=="/T"     GOTO writetable

IF "%1"=="/full"  GOTO writefull
IF "%1"=="/FULL"  GOTO writefull
IF "%1"=="/f"     GOTO writefull
IF "%1"=="/F"     GOTO writefull

:: Runs the command normally.
powershell -Command "%command%"
GOTO :EOF

:writetable
:: Runs the command and outputs an abbreviated table.
powershell -Command "%command% | Format-Table"
GOTO :EOF

:writefull
:: Runs the command and outputs a full table with all information shown.
powershell -Command "{ %command% } | %~dp0%ps%Write-Full.ps1"
