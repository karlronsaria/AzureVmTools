
:: SCRIPT: AzureCmdlets_Install.bat
:: ================================
:: Quietly installs the PowerShell command tools for Microsoft Azure
:: from an online repository.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell

:: FLAGS
:: =====
:: /help        : Help. Displays the script documentation.
:: /restart /r  : Restart. Restarts the command prompt in order to
::                allow use of the new cmdlets.

:: CURRENT SOURCE
:: ==============
:: Article     : https://kencenerelli.wordpress.com/2015/05/21/azure-powershell-cmdlets-version-updates/
:: Repository  : https://github.com/Azure/azure-powershell/releases/
::               (Keep clicking 'Next'.)
:: Alternative : http://aka.ms/webpi-azps


@ECHO OFF

:: VARIABLES
:: =========
:: Previous: SET  "latest=v1.0.2-December2015/azure-powershell.1.0.2.msi"
SET  "latest=v1.2.1-February2016/azure-powershell.1.2.1.msi"
SET "logName=install"

FOR %%A IN (%*) DO (
    IF "%%A"=="/help" GOTO help
    IF "%%A"=="/HELP" GOTO help
)

GOTO script


:help

ECHO Quietly installs the PowerShell command tools for Microsoft Azure from an online repository.
ECHO.
ECHO AzureCmdlets_Install.bat [/R]
ECHO.
ECHO   /R[ESTART]  Restarts the command prompt in order to allow use of the new cmdlets.
ECHO.
GOTO :EOF


:script

msiexec /i https://github.com/Azure/azure-powershell/releases/download/%latest% /quiet /qn /norestart /log %~dp0%logName%.log

FOR %%b IN (%*) DO (
    IF "%%A"=="/r"       GOTO restart
    IF "%%A"=="/R"       GOTO restart
    IF "%%A"=="/restart" GOTO restart
    IF "%%A"=="/RESTART" GOTO restart
)

ECHO [^!] YOU NEED TO RESTART CMD.EXE IF YOU WANT TO USE THE AZURE POWERSHELL CMDLETS
ECHO.
GOTO :EOF


:restart

:: Resets the command prompt.
start cmd.exe & exit
