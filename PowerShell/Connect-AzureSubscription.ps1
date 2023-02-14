
# SCRIPT: Connect-AzureSubscription.ps1
# =====================================
# Checks to see if the user is connected to an Azure account. Organization
# can be connected using a username and password, but a personal account user
# has to log in through the online portal and then download an import a
# publish settings file. If not connected, the user will be prompted to do so.
#
# Type          : Script
# Using         : Windows PowerShell (*.ps1)
#
# Written by    : Garreth J, Andrew D
# Last modified : 01/14/2016

#Requires -Version 3
#Requires -Modules Azure

<#
    .SYNOPSIS
        Downloads virtual hard disk (.vhd) a from a blob or virtual machine to a file.
    .DESCRIPTION
        See Save-AzureVHD cmdlet.
		
			Microsoft Azure PowerShell - Login Script
			
			"This script is executed by all other (completed) scripts to ensure that there
			is an active subscription to Microsoft Azure. If no current subscriptions 
			exist on the system, this script will download the new subscription 
			(prompting the user to sign in using their default internet browser) and 
			prompt the user on the download location.
			
			NOTE: Don't worry about calling this file manually. Other scripts should
				  call this file automatically."
			
			Gareth Jensen (9/8/2014)
			
    .PARAMETER Username
        Specifies the username of an organization account.
    .PARAMETER Password
        Specifies the password to an organization account.
    .EXAMPLE
        PS C:\> .\Connect-AzureSubscription.ps1
        This example checks to see if a publish settings file has been imported, allowing a PowerShell user to connect to his personal account. If a file has not been imported, the user will be prompted to download one from the onine portal.
    .EXAMPLE
        PS C:\> .\Connect-AzureSubscription.ps1 -Username companyname@msdn.com -Password securityisnotanissue
        This example connects the PowerShell user to an organization account without prompting for import settings.
#>

# Set these parameters to your default credentials if you have an organization account.
[CmdletBinding()]
Param
(
    [String] $Username = "",
    [String] $Password = ""
)

Try
{
    # Allows the user to run Microsoft Azure PowerShell tools.
    Import-Module Azure

    # Get all subscriptions registered on the system:
    if((Get-AzureSubscription).Count -lt 1)
    {
        if(![String]::IsNullOrWhitespace($Username) -and ![String]::IsNullOrWhitespace($Password))
        {
            # Automatically log in to an organization account.
            & "$PSScriptRoot\Add-AzureOrganizationAccount.ps1" $Username $Password
        }
        else
        {
            # Download a new subscription from Microsoft Azure:
            Write-Output "Opening default browser..."
            Get-AzurePublishSettingsFile
            Write-Output "Please login to your Azure account. After logging in, your settings file will be downloaded."
            
            # Get the settings file from the user:
            & "$PSScriptRoot\Import-AzurePublishSettingsFile.ps1" (Read-Host "Location of downloaded settings file")
        }
    }
}
Catch [System.Exception]
{
    Throw $_
}
