
:: SCRIPT: AzureCloudService_Create.bat
:: ====================================
:: Creates a new Microsoft Azure service.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell Version 3
::                 PowerShell Module Azure
::                 New-AzureService.ps1

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

ECHO Creates a new Microsoft Azure service.
ECHO.
ECHO AzureCloudService_Create.bat [ServiceName]
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
SET serviceName=NewService

:execute
:: Runs the command.
powershell -Command "%~dp0%ps%New-AzureService.ps1 -ServiceName %serviceName%"
