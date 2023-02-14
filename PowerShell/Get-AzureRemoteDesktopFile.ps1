
# SCRIPT: Get-AzureRemoteDesktopFile.ps1
# ======================================
# Gets a remote desktop connection file (.rdp) for the specified Azure virtual machine.
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
        Gets a remote desktop connection file (.rdp) for the specified Azure virtual machine.
    .DESCRIPTION
        See Get-AzureRemoteDesktopFile cmdlet.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER LocalPath
        Specifies the path and name of the downloaded .rdp file on the local disk. 
    .PARAMETER Launch
        When specified, launches a remote desktop session to the specified virtual machine.
    .EXAMPLE
        PS C:\> .\Get-AzureRemoteDesktopFile.ps1 -ServiceName "myservice" -VMName "MyVM-01_IN_0" -LocalPath "c:\temp\MyVM01.rdp"
        This command gets an .rdp file for the "MyVM-01_IN_0" virtual machine running on the "myservice" service and stores it as "c:\temp\MyVM01.rdp". 
    .EXAMPLE
        PS C:\> .\Get-AzureRemoteDesktopFile.ps1 -ServiceName "myservice" -VMName "MyVM-01_IN_0" –Launch
        This command gets an .rdp connection file for the "MyVM-01_IN_0" virtual machine running on the "myservice" service and launches a remote desktop connection to the specified virtual machine. The .rdp file is deleted when the connection is closed.
#>


[CmdletBinding()]
Param
(
    [Parameter( Mandatory                       = $true,
                Position                        = 0,
                ValueFromPipelineByPropertyName = $true )]
    [String]
    $ServiceName,
    
    [Alias("Name")]
    [Parameter( Mandatory                       = $true,
                Position                        = 1,
                ValueFromPipelineByPropertyName = $true )]
    [String]
    $VMName,
    
    [String]
    $LocalPath = "$PSScriptRoot",
    
    [Switch]
    $Launch
)

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    if($LocalPath -notmatch "(\.rdp)$") { $LocalPath += "\$VMName.rdp" }

    Get-AzureRemoteDesktopFile -ServiceName $ServiceName `
                               -Name        $VMName `
                               -LocalPath   $LocalPath `
                               -Launch:     $Launch
}
Catch [System.Exception]
{
    Throw $_
}
