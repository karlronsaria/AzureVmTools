
# SCRIPT: Remove-AzureStorageBlob.ps1
# ===================================
# Removes the specified storage blob.
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
        Removes the specified storage blob.
    .DESCRIPTION
        See Remove-AzureStorageBlob cmdlet.
    .PARAMETER BlobName
        Specifies the name of the blob to remove.
    .PARAMETER Container
        Specifies the name of the container the blob is using.
    .PARAMETER Blob
        Specifies a cloud bob object from the Azure Storage Client library. You can use the Get-AzureStorageBlob cmdlet to get it.
    .PARAMETER Force
        Forces the command to run without asking for confirmation.
    .PARAMETER PassThru
        Returns an object representing the item with which you ar working. By default, this cmdlet does not generate any output.
    .PARAMETER Confirm
        Prompts for confirmation before running the cmdlet.
    .PARAMETER WhatIf
        Show what would happen if the cmdlet runs. The cmdlet is not run.
    .EXAMPLE
        PS C:\> .\Remove-AzureStorageBlob.ps1 -Container containername -Blob blobname
        This example removes a blob identified by its name.
    .EXAMPLE
        PS C:\> .\Get-AzureStorageBlob -Container containername -Blob blobname | .\Remove-AzureStorageBlob.ps1
        This example uses the pipeline.
    .EXAMPLE
        PS C:\> Get-AzureStorageContainer container* | .\Remove-AzureStorageBlob blobname
        This example uses the wildcard character and the pipeline to retrieve the blob or blobs and then removes them.
#>


[CmdletBinding()]
Param
(
    [Parameter(ParameterSetName = "NamePipeline", valueFromPipeline = $true)]
    [String]
    $BlobName,
    
    [Parameter(ParameterSetName = "NamePipeline")]
    [String]
    $Container,
    
    [Parameter(ParameterSetName = "BlobPipeline", valueFromPipeline = $true)]
    [System.Object]
    $Blob,
    
    [Switch] $Force,
    [Switch] $PassThru,
    [Switch] $Confirm,
    [Switch] $WhatIf
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    switch($PSCmdlet.ParameterSetName)
    {
        "NamePipeline"
        {
            $context = (Get-AzureStorageBlob -Blob $BlobName -Container $Container).Context

            return Remove-AzureStorageBlob -Blob $BlobName -Container $Container `
                                           -Context $context `
                                           -Force:$Force -PassThru:$PassThru -Confirm:$Confirm -WhatIf:$WhatIf
        }
        "BlobPipeline"
        {
            $context = (Get-AzureStorageBlob -Blob $Blob.Name -Container $Blob.Container.Name).Context
            
            return Remove-AzureStorageBlob -ICloudBlob $Blob -Context $context
        }
    }
}
Catch [System.Exception]
{
    Throw $_
}
