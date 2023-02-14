
# SCRIPT: Get-AzureStorageContainer.ps1
# =====================================
# Lists the storage containers.
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
        Lists the storage containers.
    .DESCRIPTION
        See Get-AzureStorageContainer cmdlet.
    .PARAMETER StorageAccountName
        Specifies the name of a storage account.
    .PARAMETER ContainerName
        Specifies the name of a storage container.
    .PARAMETER SetCurrentAccount
        Specifies to set the current storage account to the one given.
    .EXAMPLE
        PS C:\> .\Get-AzureStorageContainer.ps1
        This example lists all storage containers created in the current storage account.
    .EXAMPLE
        PS C:\> .\Get-AzureStorageContainer.ps1 container*
        This example lists all storage containers in the current storage account beginning with "container".
    .EXAMPLE
        PS C:\> .\Get-AzureStorageContainer.ps1 -StorageAccountName "mystorageaccount"
        This example lists all storage containers created in "mystorageaccount".
    .EXAMPLE
        PS C:\> .\Get-AzureStorageContainer.ps1 -StorageAccountName "mystorageaccount" -SetCurrentAccount
        This example lists all storage containers created in "mystorageaccount" and sets it as the current storage account.
#>


[CmdletBinding()]
Param
(
    [String]
    $StorageAccountName,
    
    [Parameter(Position = 0)]
    [Alias("Name")]
    [String]
    $ContainerName,
    
    [Switch]
    $SetCurrentAccount
)

$ErrorActionPreference = "Stop"

# Checks if the user is connected.
Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

Try
{
    if(![String]::IsNullOrWhitespace($StorageAccountName))
    {
        if($SetCurrentAccount)
        {
            # Sets the current storage account.
            Set-AzureSubscription -SubscriptionName (Get-AzureSubscription -Default).SubscriptionName `
                                  -CurrentStorageAccountName $StorageAccountName
        }
        else
        {
            # Gets the storage context of the specified account.
            $storageAccountKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary
            $context           =  New-AzureStorageContext `
                                    -StorageAccountName $StorageAccountName `
                                    -StorageAccountKey  $storageAccountKey
        }
    }

    if(![String]::IsNullOrWhitespace($ContainerName))
    {
        if(![String]::IsNullOrWhitespace($context))
        {
            # Retrieves storage containers based on a specified context.
            return Get-AzureStorageContainer -Name $ContainerName -Context $context
        }
    
        # Retrieves storage containers based on the current default context.
        return Get-AzureStorageContainer -Name $ContainerName
    }

    # Retrieves all storage containers based on the current default context.
    return Get-AzureStorageContainer
}
Catch [System.Exception]
{
    Throw $_
}
