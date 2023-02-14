
# SCRIPT: Write-Full.ps1
# ======================
# Converts a query to an expanded table format that doesn't truncate any data.
#
# Type          : Script
# Using         : Windows PowerShell (*.ps1)
#
# Written by    : Andrew D
# Last modified : 01/14/2016

#Requires -Version 3

<#
    .SYNOPSIS
        Converts a query to an expanded table format that doesn't truncate any data.
    .DESCRIPTION
        This script receives a command (or query) to be executed in order to avoid printing its result to the console window. Using this script ensures that no data is truncated or abbreviated.
    .PARAMETER ScriptBlock
        A script block to be executed.
    .EXAMPLE
        PS C:\> .\Write-Full.ps1 -ScriptBlock { Get-Process }
        This example queries for running processes.
    .EXAMPLE
        PS C:\> { Import-Module Azure; Get-AzureStorageBlob -Container vhds } | .\Write-Full.ps1 > blob_data.txt; start notepad++ ".\blob_data.txt"
        This example queries for storage blobs in a Windows Azure storage container and redirects the result to a text file, "blob_data.txt", before opening it in Notepad++.
#>


[CmdletBinding()]
Param
(
    [Parameter(ValueFromPipeline)]
    [ScriptBlock]
    $ScriptBlock
)

$query = $ScriptBlock.Invoke()

return $query | Format-Table -AutoSize | Out-String -Width ($query | Out-String | Measure-Object -Maximum -Property Length).Maximum
