
:: SCRIPT: AzureVM_Start.bat
:: =========================
:: Starts up a virtual machine.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell Version 3
::                 PowerShell Module Azure

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

ECHO Starts up a virtual machine.
ECHO.
ECHO AzureVM_Start.bat [ServiceName] [VMName]
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
:: Runs the command.
powershell -Command "& { Start-AzureVM -ServiceName %serviceName% -Name %vmName% } "
