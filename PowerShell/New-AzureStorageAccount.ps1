
# SCRIPT: New-AzureStorageAccount.ps1
# ===================================
# Creates a new storage account in an Azure subscription.
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
        Creates a new storage account in an Azure subscription.
    .DESCRIPTION
        See New-AzureStorageAccount cmdlet.
    .PARAMETER StorageAccountName
        Specifies a name for the storage account. The storage account name must be unique to Azure and must be between 3 and 24 characters in length and use lowercase letters and numbers only.
    .PARAMETER Location
        Specifies the location of the Azure data center where the storage account is created. (The default location is "West US".)
    .PARAMETER Label
        Specifies a label for the service. The label may be up to 100 characters in length.
    .PARAMETER Description
        Specifies a description for the service. The description may be up to 1024 characters in length.
    .PARAMETER MistypeAction
        Specifies whether to change the given storage account name to a valid format or stop the script if the string is invalid.
    .EXAMPLE
        PS C:\> .\New-AzureStorageAccount.ps1 -StorageAccountName "azuretwo" -Label "AzureTwo" -Location "North Central US"
        This example creates a new storage account named "azuretwo" in the "North Central US" data center location.
    .EXAMPLE
        PS C:\> .\New-AzureStorageAccount.ps1 -StorageAccountName "Azure Two" -Label "AzureTwo" -Location "North Central US"
        This example creates a new storage account named "azuretwo" in the "North Central US" data center location.
    .EXAMPLE
        PS C:\> .\New-AzureStorageAccount.ps1 -StorageAccountName "Azure Two" -Label "AzureTwo" -Location "North Central US" -MistypeAction "Fail"
        This example will fail and display an error message because "Azure Two" is an invalid name for a storage account with the mistype action set to "Fail".
#>


[CmdletBinding()]
Param
(
    [String]
    $StorageAccountName,
    
    [String]
    $Location = "West US",
    
    [ValidateSet("Fail", "Correct")]
    [String]
    $MistypeAction = "Correct"
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    if($MistypeAction -eq "Correct")
    {
        $StorageAccountName = [Regex]::Replace($StorageAccountName.ToLower(), "[^(a-z0-9)]", "")
    }

    if(Test-AzureName -Storage -Name $StorageAccountName)
    {
        Throw "The storage account name $StorageAccountName is not available."
    }
    else
    {
        Write-Output ("Creating new Storage Account: $StorageAccountName...")
        
        $command = "New-AzureStorageAccount -StorageAccountName $StorageAccountName -Location $Location" + `
                   {$true=""; $false="-Label $Label"            }[[String]::IsNullOrWhitespace($Label)]  + `
                   {$true=""; $false="-Description $Description"}[[String]::IsNullOrWhitespace($Description)]
        
        Invoke-Expression -Command $command
    }
}
Catch [System.Exception]
{
    Throw $_
}
