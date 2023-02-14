
:: SCRIPT: AzurePublishSettings_Install.bat
:: ========================================
:: Imports the publish settings file that allows the user to connect to his
:: Microsoft Azure account.
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

ECHO Imports the publish settings file that allows the user to connect to his Microsoft Azure account or opens the online portal to download it if none exists.
ECHO.
ECHO AzurePublishSettings_Install.bat [[drive:][path]filename[ ...]]
ECHO.
GOTO :EOF


:script

:: Sets the root directory of the PowerShell scripts.
SET ps=PowerShell\

:: Enables PowerShell scripts to run (if not already enabled).
powershell Set-ExecutionPolicy Unrestricted

:: Extracts the command-line argument.
IF [%1]==[] GOTO default
SET localFilePath=%1
GOTO execute

:default
:: Sets the default argument.
SET localFilePath=%~dp0.\Visual Studio Ultimate with MSDN-9-30-2015-credentials.publishsettings

:execute
:: Runs the command.
powershell -Command "%~dp0%ps%Import-AzurePublishSettingsFile.ps1 -PublishSettingsFile '%localFilePath%'"
