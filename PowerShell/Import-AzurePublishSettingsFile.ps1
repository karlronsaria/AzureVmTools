
# SCRIPT: Import-AzurePublishSettingsFile.ps1
# ===========================================
# Imports a publish-settings file with a certificate to connect to your
# Windows Azure account.
#
# Type          : Script
# Using         : Windows PowerShell (*.ps1)
#
# Written by    : Andrew D
# Last modified : 01/14/2016

#Requires -Version 3
#Requires -Modules Azure

<#
    .SYNOPSIS
        Imports a publish-settings file with a certificate to connect to your Windows Azure account.
    .DESCRIPTION
        See Import-AzurePublishSettingsFile cmdlet.
    .PARAMETER PublishSettingsFile
        Specifies the full path and filename for the .publishsettings file for the Windows Azure account.
    .PARAMETER SubscriptionDataFile
        Specifies the path to a file where the subscription data is stored. This parameter is optional. If it is not provided, the subscription data is imported into a default file in the user's profile.
    .EXAMPLE
        PS C:\> Import-AzurePublishSettingsFile.ps1 -PublishSettingsFile "C:\Temp\MyAccountName-date-credentials.publishsettings"
        This example imports the "C:\Temp\MyAccountName-date-credentials.publishsettings" file for a Windows Azure account, including the encoded certificate used for management of the account.
    .EXAMPLE
        PS C:\> Import-AzurePublishSettingsFile.ps1 -PublishSettingsFile "C:\Temp\MyAccountName-date-credentials.publishsettings" –SubscriptionDataFile c:\Subs\Subscriptions.xml"
        This example imports the "C:\Temp\MyAccountName-date-credentials.publishsettings" file for a Windows Azure account, including the encoded certificate used for management of the account.
#>


[CmdletBinding()]
Param
(
    [Parameter(Position=0)]
    [String]
    $PublishSettingsFile,
    
    [String]
    $SubscriptionDataFile
)

$ErrorActionPreference = "Stop"

Try
{
    $literalPathPattern = ".*\.publishsettings$"
    
    if($PublishSettingsFile -notmatch $literalPathPattern)
    {
        Throw "Provide the literal path to the publish settings file."
    }

    Import-Module Azure

    if([String]::IsNullOrWhitespace($SubscriptionDataFile))
    {
        Import-AzurePublishSettingsFile -PublishSettingsFile $PublishSettingsFile
    }
    else
    {
        Import-AzurePublishSettingsFile -PublishSettingsFile $PublishSettingsFile -SubscriptionDataFile $SubscriptionDataFile
    }
    
    Write-Output "Publish settings imported successfully."
}
Catch [System.Exception]
{
    Throw $_
}
