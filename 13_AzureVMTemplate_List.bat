
:: SCRIPT: AzureVMTemplate_List.bat
:: ================================
:: Displays the entire list of VM templates available in Azure repository
:: by image name and family.
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

ECHO Displays the entire list of VM templates available in Azure repository by image name and family.
ECHO.
GOTO :EOF


:script

:: Sets the root directory of the PowerShell scripts.
SET ps=PowerShell\

:: Enables PowerShell scripts to run (if not already enabled).
powershell Set-ExecutionPolicy Unrestricted

:: Runs the command.
powershell -Command "{ Get-AzureVMImage | Select -Property ImageName, ImageFamily } | %~dp0%ps%Write-Full.ps1"
