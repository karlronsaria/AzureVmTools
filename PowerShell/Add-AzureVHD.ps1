
# SCRIPT: Add-AzureVHD.ps1
# ========================
# Uploads a virtual hard disk (in .vhd file format) from an on-premises virtual
# machine to a blob in a cloud storage account in Azure.
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
        Uploads a virtual hard disk (in .vhd file format) from an on-premises virtual machine to a blob in a cloud storage account in Azure.
    .DESCRIPTION
        See Add-AzureVHD cmdlet.
    .PARAMETER DiskName
        Specifies the name of a virtual hard disk.
    .PARAMETER LocalFilePath
        Specifies the path to the local .vhd file.
    .PARAMETER Destination
        Specifies the resulting URI of a blob in Blob Storage.
    .PARAMETER NumberOfThreads
        Determines the number of uploader threads to be used when uploading the .vhd file.
    .PARAMETER Overwrite
        Specifies that you want to delete an existing file, if one exists as specified by the destination.
    .EXAMPLE
        PS C:\> .\Add-AzureVHD.ps1 -LocalFilePath C:\vhd\MyWin7Image.vhd -Destination http://mytestaccount.blob.core.windows.net/vhdstore/win7baseimage.vhd
        This example uses a destination URI to a specific blob to upload a .vhd file to the blob.
    .EXAMPLE
        PS C:\> .\Add-AzureVHD.ps1 -DiskName MyWin7Image.vhd -LocalFilePath C:\vhd\ -Destination http://mytestaccount.blob.core.windows.net/vhdstore/
        This example appends a specified disk name to the local file path and destination.
    .EXAMPLE
        PS C:\> .\Add-AzureVHD.ps1 -LocalFilePath C:\vhd\MyWin7Image.vhd -Destination http://mytestaccount.blob.core.windows.net/vhdstore/win7baseimage.vhd -Overwrite
        This example uploads a .vhd file and also overwrites any existing blob in the specified destination URI.
    .EXAMPLE
        PS C:\> .\Add-AzureVHD.ps1 -LocalFilePath C:\vhd\MyWin7Image.vhd -Destination http://mytestaccount.blob.core.windows.net/vhdstore/win7baseimage.vhd -NumberOfThreads 32
        This example uploads a .vhd file and specifies the number of uploader threads.
    .EXAMPLE
        PS C:\> Get-ChildItem C:\vhd\ -Filter *.vhd | foreach { $_.FullName | .\Add-AzureVHD.ps1 -Destination http://mytestaccount.blob.core.windows.net/vhdstore/ }
        This example uploads every .vhd file found in "C:\vhd\".
#>


[CmdletBinding()]
Param
(
    [Parameter( Mandatory         = $true,
                Position          = 0,
                ValueFromPipeline = $true )]
    [String]
    $LocalFilePath,
    
    [Parameter( Mandatory         = $true,
                Position          = 1 )]
    [String]
    $Destination,
    
    [String]
    $DiskName,
    
    [Int32]
    $NumberOfThreads = 4,
    
    [Switch]
    $Overwrite
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    if(![String]::IsNullOrWhitespace($DiskName))
    {
        if(!$DiskName.EndsWith(".vhd")) { $DiskName += ".vhd" }
    }
    elseif(($LocalFilePath).EndsWith(".vhd"))
    {
        $DiskName = $LocalFilePath.Split("\")[-1]
    }

    if(!($LocalFilePath).EndsWith(".vhd"))
    {
        $LocalFilePath += @{$true  = "\" + $DiskName; `
                            $false =       $DiskName}[!([String]$LocalFilePath).EndsWith('\')]
    }

    if(!($Destination).EndsWith(".vhd"))
    {
        $Destination += @{$true  = "/" + $DiskName; `
                          $false =       $DiskName}[!([String]$Destination).EndsWith('/')]
    }

    return Add-AzureVHD -Destination $Destination -LocalFilePath $LocalFilePath `
                        -NumberOfUploaderThreads $NumberOfThreads -Overwrite:$Overwrite
}
Catch [System.Exception]
{
    Throw $_
}
