
# SCRIPT: Add-AzureOrganizationAccount.ps1
# ========================================
# Connects the user to an organization Azure account by submitting credentials.
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
        Connects the user to an organization Azure account by submitting credentials.
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
        PS C:\> .\Add-AzureOrganizationAccount.ps1 -Username companyname@msdn.com -Password securityisnotanissue
        This example connects the PowerShell user to an organization account.
#>

[CmdletBinding()]
Param
(
    [String] $Username,
    [String] $Password
)

Try
{
    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    $cred = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)

    Add-AzureAccount -Credential $cred
}
Catch [System.Exception]
{
    Throw $_
}
