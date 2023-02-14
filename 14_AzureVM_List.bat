
:: SCRIPT: AzureVM_List.bat
:: ========================
:: Displays all virtual machines created on the user's currently connected
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
::                 Query-AzureVM.ps1, Write-Full.ps1

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

ECHO Displays all virtual machines created on the user's currently connected subscription to Microsoft Azure.
ECHO.
GOTO :EOF


:script

:: Sets the root directory of the PowerShell scripts.
SET ps=PowerShell\

:: Enables PowerShell scripts to run (if not already enabled).
powershell Set-ExecutionPolicy Unrestricted

:: Runs the command.
powershell -Command "{ %~dp0%ps%Query-AzureVM.ps1 Name, ServiceName, PowerState, Status } | %~dp0%ps%Write-Full.ps1"
