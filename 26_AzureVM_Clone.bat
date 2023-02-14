
:: SCRIPT: AzureVM_Clone.bat
:: =========================
:: Creates a backup clone of a virtual machine in Azure.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell Version 3
::                 PowerShell Module Azure
::                 Clone-AzureVM.ps1, Get-AzureVM.ps1

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

ECHO Creates a backup clone of a virtual machine in Azure.
ECHO.
ECHO AzureVM_Clone.bat [service name] [VM name]
ECHO.
GOTO :EOF


:script

:: Sets the root directory of the PowerShell scripts.
SET ps=PowerShell\

:: Enables PowerShell scripts to run (if not already enabled).
powershell Set-ExecutionPolicy Unrestricted

:: Extracts the command-line arguments.
IF [%1]==[] GOTO default
IF [%2]==[] GOTO default
SET  serviceName=%1
SET       vmName=%2
GOTO execute

:default
:: Sets the default arguments.
SET  serviceName=NewService
SET       vmName=NewVM

:execute
powershell -Command "%~dp0%ps%Get-AzureVM.ps1 %serviceName% %vmName% | %~dp0%ps%Clone-AzureVM.ps1"
