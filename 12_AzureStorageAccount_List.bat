
:: SCRIPT: AzureStorageAccount_List.bat
:: ====================================
:: Displays all storage accounts created on the user's currently connected
:: subscription to Microsoft Azure.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell Version 3
::                 PowerShell Module Azure
::                 Write-Full.ps1

:: FLAGS
:: =====
:: /help  : Help. Displays the script documentation.


@ECHO OFF

FOR %%A IN (%*) DO (
    IF "%%A"=="/help" GOTO help
    IF "%%A"=="/HELP" GOTO help
)

GOTO script


:help

ECHO Displays all storage accounts created on the user's currently connected subscription to Microsoft Azure.
ECHO.
GOTO :EOF


:script

:: Sets the root directory of the PowerShell scripts.
SET ps=PowerShell\

:: Enables PowerShell scripts to run (if not already enabled).
powershell Set-ExecutionPolicy Unrestricted

:: Runs the command.
powershell -Command "{ Get-AzureStorageAccount -WarningAction SilentlyContinue " ^
                            " | Select -Property StorageAccountName, Location, AccountType } " ^
                        " | %~dp0%ps%Write-Full.ps1"
