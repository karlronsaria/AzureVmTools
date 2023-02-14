
# SCRIPT: New-AzureService.ps1
# ============================
# Creates a new Microsoft Azure service.
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
        Creates a new Microsoft Azure service.
    .DESCRIPTION
        See New-AzureService cmdlet.
    .PARAMETER ServiceName
        Specifies the name of the new service. The name must be unique to the subscription.
    .PARAMETER Location
        Specifies the location for the service. A location is required if there isn't a specified Affinity Group. (The default location is "West US".)
    .PARAMETER Label
        Specifies a label for the service. The label may be up to 100 characters in length.
    .PARAMETER Description
        Specifies a description for the service. The description may be up to 1024 characters in length.
    .EXAMPLE
        PS C:\> .\New-AzureService.ps1 -ServiceName "MySvc1" -Label "MyTestService" -Location "South Central US"
        This command creates a new service named "MySvc1" in the South Central US location.
#>


[CmdletBinding()]
Param
(
    [String] $ServiceName,
    [String] $Location = "West US",
    [String] $Label,
    [String] $Description
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    if(Test-AzureName -Service -Name $ServiceName)
    {
        Throw "The service name $ServiceName is not available."
    }
    else
    {
        Write-Output ("Creating new Cloud Service: $ServiceName...")
        
        $command = "New-AzureService -ServiceName $ServiceName -Location $Location" + `
                   {$true=""; $false="-Label $Label"            }[[String]::IsNullOrWhitespace($Label)]  + `
                   {$true=""; $false="-Description $Description"}[[String]::IsNullOrWhitespace($Description)]
        
        Invoke-Expression -Command $command
    }
}
Catch [System.Exception]
{
    Throw $_
}
