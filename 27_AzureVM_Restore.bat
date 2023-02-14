
:: SCRIPT: AzureVM_Restore.bat
:: ===========================
:: Restores the original virtual machine from a backup, if it exists.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell Version 3
::                 PowerShell Module Azure
::                 Get-AzureVM.ps1, Clone-AzureVM.ps1

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

ECHO Restores the original virtual machine from a backup, if it exists.
ECHO.
ECHO AzureVM_Restore.bat [service name] [VM name] [0...]
ECHO.
ECHO   0 ...  Searches for a clone of the VM to restor from, given by the number.
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

:: Extracts the index of the copy from the command-line arguments
:: or sets it using the default.
IF [%3]==[] (
    SET number=0
) ELSE (
    SET number=%3
)

GOTO execute

:default
:: Sets the default arguments.
SET  serviceName=NewService
SET       vmName=NewVM       REM Specifies the name of the original VM.
SET       number=0           REM Specifies the number of the VM's copy,
                             REM   (Copy-%number%-Of-%vmName%).

:execute
:: Runs the command.
powershell -Command "%~dp0%ps%Get-AzureVM.ps1 %serviceName% Copy-%number%-Of-%vmName% | %~dp0%ps%Clone-AzureVM.ps1 -RestoreOriginal"
