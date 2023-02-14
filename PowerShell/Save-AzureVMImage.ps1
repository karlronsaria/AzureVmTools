
# SCRIPT: Save-AzureVMImage.ps1
# =============================
# Captures and saves the image of a stopped Azure virtual machine.
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
        Captures and saves the image of a stopped Azure virtual machine.
    .DESCRIPTION
        See Save-AzureVMImage cmdlet.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER ImageName
        Specifies the name of the image.
    .PARAMETER ImageLabel
        Specifies a label for the image.
    .PARAMETER OSState
        Specifies the operation system state for the virtual machine image. Valid values are: Generalized and Specialized. Use this parameter if you intend to capture a virtual machine image to Azure.
    .EXAMPLE
        PS C:\> Get-AzureVM "MySrvc" "MyVM" | .\Save-AzureVMImage.ps1 -ImageName "Win2012Server_BaseImage" -ImageLabel "ServerBaseImage" -OSState Generalized
        This example captures an existing virtual machine and deletes it from the deployment.
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
    
    [Parameter(Mandatory=$true)]
    [String]
    $ImageName,
    
    [Parameter(Mandatory=$true)]
    [String]
    $ImageLabel,
    
    [String]
    $OSState
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    # If the source VM is still running, it's shut down.
    $previouslyPoweredOn = & "$PSScriptRoot\Stop-AzureVM.ps1" $ServiceName $VMName `
                                -StayProvisioned -Wait

    if([String]::IsNullOrWhitespace($OSState))
    {
        Save-AzureVMImage -ServiceName $ServiceName -Name $VMName -ImageName $ImageName
    }
    else
    {
        Save-AzureVMImage -ServiceName $ServiceName -Name $VMName -ImageName $ImageName -OSState $OSState
    }

    # If the machine was previously powered on, restart the machine.
    if($previouslyPoweredOn)
    {
        Write-Output "Starting $VMName..."
        
        Start-AzureVM $ServiceName $VMName | Out-Null
    }
}
Catch [System.Exception]
{
    Throw $_
}
