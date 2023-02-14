
# SCRIPT: Start-AzureVMRemoteDesktopConnection.ps1
# ================================================
# Starts a Remote Desktop Connection to a virtual machine.
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
        Starts a Remote Desktop Connection to a virtual machine.
    .DESCRIPTION
        See mstsc command-line tool.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER VM
        Specifies a virtual machine object.
    .EXAMPLE
        PS C:\> .\Start-AzureVMRemoteDesktopConnection.ps1 -ServiceName "myservice" -VMName "MyVM-01_IN_0"
        This command starts a Remote Dekstop Connection to "MyVM-01_IN_0".
    .EXAMPLE
        PS C:\> Get-AzureVM -ServiceName "myservice" -VMName "MyVM-01_IN_0" | .\Start-AzureVMRemoteDesktopConnection.ps1
        This command starts a Remote Dekstop Connection to "MyVM-01_IN_0".
#>


[CmdletBinding()]
Param
(
    [Parameter( ParameterSetName  = "ByVMName",
                Mandatory         = $true,
                Position          = 0 )]
    [String]
    $ServiceName,
    
    [Parameter( ParameterSetName  = "ByVMName",
                Mandatory         = $true,
                Position          = 1 )]
    [String]
    $VMName,
    
    [Parameter( ParameterSetName  = "ByVMObject",
                ValueFromPipeline = $true )]
    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.IPersistentVM]
    $VM
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    # Retrieves the virtual machine by parameter if it wasn't passed
    # through the pipeline.
    if($VM -eq $null) { $VM = & "$PSScriptRoot\Get-AzureVM.ps1" $ServiceName $VMName }

    # Writes a connection string using the DNS name and port number of the VM.
    $connectStr  = "/v:"
    $connectStr += ($VM.DNSName).Split("/")[-2] + ":"
    $connectStr += ($VM | Get-AzureEndpoint | Where { $_.Name -eq "RemoteDesktop" }).Port

    # Runs the Remote Desktop Connection command-line tool.
    mstsc "/admin" $connectStr
}
Catch [System.Exception]
{
    Throw $_
}
