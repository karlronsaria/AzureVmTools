
# SCRIPT: Wait-AzureDiskCopy.ps1
# ==============================
# Waits for a list of copies to complete.
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
        Waits for a list of copies to complete.
    .DESCRIPTION
        See Start-Sleep cmdlet.
    .PARAMETER Jobs
        Specifies a hash table, mapping source disks to destination disks.
    .EXAMPLE
        PS C:\> $copies | .\Wait-AzureDiskCopy.ps1
        This example waits for a series of disk copies to complete.
    .EXAMPLE
        PS C:\> $copies | .\Wait-AzureDiskCopy.ps1 -ShowBlobNames
        If the first column of the table is comprised of disk types, then the switch will change the output to show blob names.
#>


[CmdletBinding()]
Param
(
    [Parameter(ValueFromPipeline=$true)]
    [Hashtable]
    $Jobs,
    
    [Switch]
    $ShowBlobNames
)
    
Write-Output ("Waiting for the copies to finish...")

# $totalCompleted = 0
# Checks that the disks were backed up successfully:
do
{
    foreach($copy in $copies.GetEnumerator())
    {
        # Gets the state of the disk and checks:
        $state = $copy.Value | Get-AzureStorageBlobCopyState -Context $context
        
        if($state.Status -eq "Success")
        {
            if($ShowBlobNames)
            {
                [String] $name = ($copy.Name | & "$PSScriptRoot\Get-AzureDiskBlob.ps1").Name
            }
            else
            {
                [String] $name = $copy.Name.Name
            }
            
            if([String]::IsNullOrWhitespace($name)) { $name = $copy.Name.DiskName }
            
            Write-Output ("$name copied to $($copy.Value.Name).")
            
            $copies.Remove($copy)
            # $totalCompleted++
        }
    }
    
    Start-Sleep -Seconds 1
}
until($copies.Count -gt 0)
# until($copies.Count -eq $totalCompleted)
