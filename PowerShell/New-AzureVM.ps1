
# SCRIPT: New-AzureVM.ps1
# =======================
# Creates a new Azure virtual machine.
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
        Creates a new Azure virtual machine.
    .DESCRIPTION
        See cmdlets:
			Add-AzureProvisioningConfig
			New-AzureVM
			New-AzureVMConfig
    .PARAMETER VM
        Specifies a virtual machine object.
    .PARAMETER StorageAccountName
        Specifies a name for the storage account. The storage account name must be unique to Azure and must be between 3 and 24 characters in length and use lowercase letters and numbers only.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER ImageName
        Specifies the name of the virtual machine image to use for the operating system disk.
    .PARAMETER InstanceSize
        Specifies the size of the virtual machine. For a list of virtual machine sizes, see https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-size-specs/.
    .PARAMETER AvailabilitySetName
        Specifies the name of the availability set.
    .PARAMETER IPAddress
        Specifies the new machine's static VNet IP Address.
    .PARAMETER SubnetNames
        Specifies the list of subnet names.
    .PARAMETER VNetName
        Specifies the virtual network name where the new virtual machine will be deployed.
    .PARAMETER Location
        Specifies the location where the new service will be hosted.
    .PARAMETER AdminUsername
        Specifies the name for the user account to create for administrative access to the virtual machine.
    .PARAMETER Password
        Specifies the password of the administrative account for the virtual machine.
    .PARAMETER CredentialAction
        Specifies whether to terminate with a message or prompt the user for username and password if they weren't passed in.
    .EXAMPLE
        PS C:\> .\New-AzureVM.ps1 -StorageAccountName "mytestaccount" -ServiceName "MySrvc" -VMName "MyNewVM" -InstanceSize ExtraSmall -ImageName (Get-AzureVMImage)[4].ImageName
        This example creates a new Azure virtual machine, "MyNewVM".
#>


[CmdletBinding()]
Param
(
    [Parameter(ParameterSetName="ByVMObject", ValueFromPipeline=$true)]
    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.IPersistentVM]
    $VM,

    [Parameter(ParameterSetName="ByVMName", Mandatory=$true)]
    [String]
    $StorageAccountName,
    
    [Parameter(ParameterSetName="ByVMName", Mandatory=$true)]
    [String]
    $ServiceName,
    
    [Parameter(ParameterSetName="ByVMName", Mandatory=$true)]
    [String]
    $ImageName,
    
    [Parameter(ParameterSetName="ByVMName", Mandatory=$true)]
    [String]
    $InstanceSize,
    
    [Parameter(ParameterSetName="ByVMName", Mandatory=$true)]
    [String]
    $VMName,
    
    [String]   $MediaLocation,
    [String]   $AvailabilitySetName,
    [String]   $IPAddress,
    [String[]] $SubnetNames,
    [String]   $VNetName,
    [String]   $AdminUsername,
    [String]   $Password,
    
    [ValidateSet("Fail", "Prompt")]
    [String]   $CredentialAction = "Fail"
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    # Determines whether or not to terminate due to lack of credentials.
    if($CredentialAction -eq "Fail")
    {
        if([String]::IsNullOrWhitespace($AdminUsername) -and `
           [String]::IsNullOrWhitespace($Password))
        {
            Throw "AdminUsername and Password not set."
        }

        if([String]::IsNullOrWhitespace($AdminUsername))
        {
            Throw "AdminUsername not set."
        }
        
        if([String]::IsNullOrWhitespace($Password))
        {
            Throw "Password not set."
        }
    }

    # Sets the default storage account.
    Set-AzureSubscription -SubscriptionName (Get-AzureSubscription).SubscriptionName `
                          -CurrentStorageAccountName $StorageAccountName
                           
    if($PSCmdlet.ParameterSetName -eq "ByVMName")
    {
        if([String]::IsNullOrWhitespace($MediaLocation))
        {
            # Creates a new VM configuration.
            $VM = New-AzureVMConfig  -Name           $VMName `
                                     -InstanceSize   $InstanceSize `
                                     -ImageName      $ImageName
        }
        else
        {
            # Creates a new VM configuration with a location for the OS disk.
            $VM = New-AzureVMConfig  -Name           $VMName `
                                     -InstanceSize   $InstanceSize `
                                     -ImageName      $ImageName `
                                     -MediaLocation  $MediaLocation
        }
    }

    # Prompts the user for credentials if none were specified,
    # only if specified by CredentialAction.
    if([String]::IsNullOrWhitespace($AdminUsername) -or `
       [String]::IsNullOrWhitespace($Password))
    {
        $cred = Get-Credential -Message "Type the name and password of the local administrator account."
        $AdminUsername = $cred.GetNetworkCredential().Username
        $Password      = $cred.GetNetworkCredential().Password
    }

    # Configures the virtual machine as a Windows system with the given credentials.
    $VM | Add-AzureProvisioningConfig -Windows -AdminUsername $AdminUsername -Password $Password

    # Sets the availability set name if specified.
    if(![String]::IsNullOrWhitespace($AvailabilitySetName))
    {
        $VM | Set-AzureAvailabilitySet -AvailabilitySetName $AvailabilitySetName
    }

    # Sets the IP address if specified.
    if(![String]::IsNullOrWhitespace($IPAddress)){ $VM | Set-AzureStaticVNetIP -IPAddress $IPAddress }

    # Sets the list of subnets if specified.
    if(![String]::IsNullOrWhitespace($SubnetNames)){ $VM | Set-AzureSubnet -SubnetNames $SubnetNames }

    Write-Output ("Creating new Virtual Machine: $($VMName)...")

    if(![String]::IsNullOrWhitespace($VNetName))
    {
        # Creates a new virtual machine.
        New-AzureVM -ServiceName $ServiceName -VMs $VM -WarningAction SilentlyContinue
    }
    else
    {
        # Creates a new virtual machine with the name of a virtual network
        # where it will be deployed.
        New-AzureVM -ServiceName $ServiceName -VMs $VM -VNetName $VNetName -WarningAction SilentlyContinue
    }
}
Catch [System.Exception]
{
    Throw $_
}
