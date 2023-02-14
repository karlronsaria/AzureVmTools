
:: SCRIPT: AzurePublishSettings_Download.bat
:: =========================================
:: Imports the publish settings file that allows the user to connect to his
:: Microsoft Azure account or opens the online portal to download it
:: if none exists.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell Version 3
::                 PowerShell Module Azure
::                 Import-AzurePublishSettingsFile.ps1

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

ECHO Downloads the publish settings file that allows the user to connect to his Microsoft Azure account from the online portal.
ECHO.
GOTO :EOF


:script

:: Enables PowerShell scripts to run (if not already enabled).
powershell Set-ExecutionPolicy Unrestricted

:: Runs the command.
powershell -Command "Get-AzurePublishSettingsFile"
