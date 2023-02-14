
# SCRIPT: Clone-AzureVM.ps1
# =========================
# Creates a backup clone of a virtual machine in Azure.
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
        Creates a backup clone of a virtual machine in Azure.
    .DESCRIPTION
        See cmdlets:
			Add-AzureDisk
			New-AzureVM
			Start-CopyAzureStorageBlob
    .LINK
        http://blogs.msdn.com/b/microsoft_press/archive/2014/01/29/from-the-mvps-copying-a-virtual-machine-from-one-windows-azure-subscription-to-another-with-powershell.aspx
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER VM
        Specifies a virtual machine object.
    .PARAMETER DestStorageName
        Specifies the name for the destination's storage account. If not specified, the account name will match the name of the source virtual machine's storage account.
    .PARAMETER DestServiceName
        Specifies the destination's service name.
    .PARAMETER RestoreOriginal
        Specifies that you want to restore the original virtual machine.
    .PARAMETER SaveXML
        Specifies that you want to save the .xml files of the source and backup machines' configurations.
    .EXAMPLE
        PS C:\> $vm1 | .\Clone-AzureVM.ps1 -SaveXML
        This example creates a clone of a VM given by the object reference and saves the configuration as of the original and the copy as .xml files.
    .EXAMPLE
        PS C:\> $vm1 | .\Clone-AzureVM.ps1 -DestStorageName "otherstorageaccnt" -DestServiceName "OtherSrvc"
        This example clones a VM, associates it with a different service, "OtherSrvc", stores the virtual disks in "otherstorageaccnt".
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
    $VM,
    
    [String]
    $DestStorageName,
    
    [String]
    $DestServiceName = $VM.ServiceName,
    
    [Switch]
    $RestoreOriginal,
    
    [Switch]
    $SaveXML
)

[Pattern] $pattern   = "^Copy-[0-9]+-Of-" # Pattern to determine if a given name is a copy of another name.
[String]  $container = "vhds"             # The default container name for a virtual machine's .vhd's.
[Int64]   $threshold = 5                  # Specifies how many times to retry an algorithm if it continually fails.

# Returns which iteration of this script a virtual machine was created by,
# given as a number in the VM's name.
#
# Example: Get-Index("Copy-3-Of-VMName") -> 3

function Get-Index
{
    Param( [String] $Name )
    
    return [Int64]$Name.Split("-")[1]
}

# Returns the name of the next iteration of this script on a virtual machine.
#
# Example: Get-NameOfCopy("VMName")           -> "Copy-0-Of-VMName"
#          Get-NameOfCopy("Copy-0-Of-VMName") -> "Copy-1-Of-VMName"

function Get-NameOfCopy
{
    Param( [String] $Name )
    
    if($Name -Match $pattern)
    {
        return $Name -Replace $pattern, "Copy-$((Get-Index($Name)) + 1)-Of-"
    }
    
    return "Copy-0-Of-$Name"
}

# Returns the name of the previous iteration of this script on a virtual machine.
#
# Example: Get-NameOfPrevious("Copy-1-Of-VMName") -> "Copy-0-Of-VMName"
#          Get-NameOfPrevious("Copy-0-Of-VMName") -> "VMName"
#          Get-NameOfPrevious("VMName")           -> "VMName"

function Get-NameOfPrevious
{
    Param( [String] $Name )
    
    if($Name -Match $pattern -And Get-Index($Name) -eq 0)
    {
        return $Name -Replace "Copy-0-Of-", ""
    }
    
    return $Name -Replace $pattern, "Copy-$((Get-Index($Name)) - 1)-Of-"
}

# Returns the name of the original virtual machine that had been run through
# this script.
#
# Example: Get-NameOfOriginal("Copy-4-Of-VMName") -> "VMName"
#          Get-NameOfOriginal("VMName")           -> "VMName"

function Get-NameOfOriginal
{
    Param( [String] $Name )
    
    return $Name -Replace $pattern, ""
}

# Decides what to call the clone virtual machine, based on user input.

function Get-NameOfClone
{
    Param( [String] $Name )

    if($RestoreOriginal)
    {
        return Get-NameOfOriginal($Name)
    }
    else
    {
        return Get-NameOfCopy($Name)
    }
}

# Returns the decided string URI for the clone of a disk.

function CloneDiskName
{
    Param( [URI] $U ) # A disk URI.
    
    $seg = $U.Segments
    
    return "$($U.Scheme)://$($U.Host)/$($seg[-2])$(Get-NameOfClone($seg[-1]))"
}

# Attempts to create the virtual machine copy.

function Clone-AzureVMFromXML
{
    Param
    (
        [String] $SConfigPath,
        [String] $DConfigPath,
        [String] $ServiceName,
        [String] $SStorageName,
        [String] $DStorageName,
        [String] $ServiceLoc
    )
    
    # Retrieves the content of the export .xml file.
    $xml = [XML](Get-Content $SConfigPath)
    
    # Changes the configuration of the new VM to match the new machine and disk names.
    # The endpoint port numbers are incremented.
    if($DStorageName -eq $SStorageName)
    {
        $xml.SelectNodes("//RoleName") | foreach { $_."#text" = Get-NameOfClone($_."#text") }
        $xml.SelectNodes("//DiskName") | foreach { $_."#text" = Get-NameOfClone($_."#text") }
        $xml.SelectNodes("//Port")     | foreach { $_."#text" = [String]([Int64]$_."#text" + 1) }
    }
    
    # Saves the new configuration as an import file.
    $xml.Save($DConfigPath)
    
    # Imports the new configuration.
    $vmConfiguration = Import-AzureVM -Path $DConfigPath

    # Creates the new VM.
    New-AzureVM -ServiceName $ServiceName -Location $ServiceLoc -VMs $vmConfiguration -WarningAction SilentlyContinue
}

$ErrorActionPreference = "Stop"

# Checks if the user is connected.
Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

# Retrieves the virtual machine by parameter if it wasn't passed
# through the pipeline.
if($VM -eq $null) { $VM = & "$PSScriptRoot\Get-AzureVM.ps1" $ServiceName $VMName }

# Decides whether or not to keep the .xml files in the script root.
if($SaveXML) { $xmlRoot = $PSScriptRoot } else { $xmlRoot = $env:TEMP }

# Checks to see if the original VM exists if the user chooses to restore it.
if($RestoreOriginal -and (& "$PSScriptRoot\Get-AzureVM.ps1" `
    -ServiceName  $VM.ServiceName `
    -VMName       (Get-NameOfOriginal($VM.Name)) `
    -ErrorAction  SilentlyContinue) -ne $null)
{
    Throw "The original virtual machine $(Get-NameOfOriginal($VM.Name)) still exists."
}

# Matches the destination's service to the source VM's if none is specified.
if([String]::IsNullOrWhitespace($DestServiceName))
{
    $DestServiceName = $VM.ServiceName
}

# Retrieves the last copy that was made of the original source VM.
while(($copy = (& "$PSScriptRoot\Get-AzureVM.ps1" `
    -ServiceName  $DestServiceName `
    -VMName       (Get-NameOfClone($VM.Name)) `
    -ErrorAction  SilentlyContinue)) -ne $null)
{
    $VM = $copy
}
Remove-Variable copy

$VMName = $VM.Name

# Retrieves the disk information from the source VM.
$srcOSDisk    = $VM.VM.OSVirtualHardDisk
$srcDataDisks = $VM.VM.DataVirtualHardDisks

# Exports the source VM's configuration.
$vmConfigurationPath = "$xmlRoot\$VMName-export.xml"
$VM | Export-AzureVM -Path $vmConfigurationPath | Out-Null

# Retrieves the information for the source VM's storage account.
$srcStorageName    = $srcOSDisk.MediaLink.Host -Split "\." | Select -First 1
$srcStorageAccount = Get-AzureStorageAccount -StorageAccountName $srcStorageName -WarningAction SilentlyContinue
$location          = $srcStorageAccount.Location

# If the source VM is still running, it's shut down.
$previouslyPoweredOn = $VM | & "$PSScriptRoot\Stop-AzureVM.ps1" -StayProvisioned -Wait

# Keeps the new VM in the source VM's storage account if a new one isn't specified.
# Else, a new storage account is created if the one provided doesn't exist.
if([String]::IsNullOrWhitespace($DestStorageName))
{
    $DestStorageName = $srcStorageName
}
else
{
    & "$PSScriptRoot\New-AzureStorageAccount.ps1" `
                        -StorageAccountName $srcStorageName `
                        -Location           $Location `
                        -MistypeAction      "Fail"
}

# Retrieves the primary key of the new storage account.
$srcStorageKey  = (Get-AzureStorageKey -StorageAccountName $srcStorageName).Primary
$destStorageKey = (Get-AzureStorageKey -StorageAccountName $DestStorageName).Primary

# Creates storage contexts for both storage accounts.
$srcContext  = New-AzureStorageContext -StorageAccountName $srcStorageName  -StorageAccountKey $srcStorageKey
$destContext = New-AzureStorageContext -StorageAccountName $DestStorageName -StorageAccountKey $destStorageKey

# Creates a new container for .vhd's if the new account does not have one.
if((Get-AzureStorageContainer -Context $destContext -Name vhds -ErrorAction SilentlyContinue) -eq $null)
{
    New-AzureStorageContainer -Context $destContext -Name vhds
}

# Starts a list of data disk blobs, a table of copy tasks, and a table of names.
$dataDiskBlobs = @()
$copies        = @{}
$names         = @{}

Write-Output ("Copying disks...")

Try
{
    # Copies all disks to the new storage location.
    foreach($disk in ($srcDataDisks + $srcOSDisk))
    {
        # Gets the names of the source and destination blobs.
        $srcBlobName  = $disk.MediaLink.Segments[-1]
        $destBlobName = Get-NameOfClone($srcBlobName)
        
        # Starts copying a disk.
        $blob = Start-CopyAzureStorageBlob `
                     -SrcContainer  $container  -SrcBlob     $srcBlobName `
                     -DestContainer $container  -DestBlob    $destBlobName `
                     -Context       $srcContext -DestContext $destContext -Force
        
        # Adds the disk to the table of blobs to be checked for progress.
        $copies.Add($disk, $blob)
        
        # Adds the name of the blob and disk to the table of names.
        $names.Add($destBlobName, (Get-NameOfClone($disk.DiskName)))
        
        # Separates the new OS disk from the new data disks.
        if($disk -eq $srcOSDisk) { $osDiskBlob = $blob } else { $dataDiskBlobs += $blob }
    }
}
Catch [System.Exception]
{
    Write-Warning ("Exception was thrown for blob: $srcBlobName and its copy: $destBlobName.")
    Throw $_
}

# Forces execution to wait until all copies are complete.
$copies | & "$PSScriptRoot\Wait-AzureDiskCopy.ps1" -ShowBlobNames

Try
{
    # Registers the new OS disk.
    Add-AzureDisk -OS             $srcOSDisk.OS `
                  -DiskName       $names[$osDiskBlob.Name] `
                  -MediaLocation  $osDiskBlob.ICloudBlob.URI | Out-Null

    foreach($dataDiskBlob in $dataDiskBlobs)
    {
        # Registers the new data disk.
        Add-AzureDisk -DiskName       $names[$dataDiskBlob.Name] `
                      -MediaLocation  $diskBlob.ICloudBlob.URI | Out-Null
    }

    # If the machine was previously powered on, restart the machine.
    if($previouslyPoweredOn)
    {
        Write-Output ("Starting $VMName...")
        
        $VM | Start-AzureVM | Out-Null
    }

    # Sets the new storage account.
    Get-AzureSubscription -Current -ExtendedDetails | `
        Set-AzureSubscription `
           -CurrentStorageAccountName  $DestStorageName `
           -WarningAction              SilentlyContinue

    # Sets the name of the new configuration path.
    $newVMConfigurationPath = ($xmlRoot + "\" + (Get-NameOfClone("$VMName-import.xml")))

    Write-Output ("Creating $(Get-NameOfClone($VMName))...")

    # A VM copy is created from the .xml of the source VM with the port numbers
    # of the source's endpoints incremented. Different port numbers will be
    # attempted if the copy fails, until the number of attempts exceeds
    # the threshold.
    $attempts = 1
    do
    {
        Try
        {
            # Attempts to create a new virtual machine.
            Clone-AzureVMFromXML -SConfigPath  $vmConfigurationPath `
                                 -DConfigPath  $newVMConfigurationPath `
                                 -ServiceName  $DestServiceName `
                                 -SStorageName $srcStorageName `
                                 -DStorageName $DestStorageName `
                                 -ServiceLoc   $location
            
            $conflictingPorts = $false
        }
        Catch [System.Exception]
        {
            # Caches the exception.
            $exception = $_
        
            # Attempts to reload the function with the new configuration in place of the source.
            if(Test-Path $newVMConfigurationPath) { $vmConfigurationPath = $newVMConfigurationPath }
            else { Throw $_ }
            
            $conflictingPorts = $true
        }
    }
    while($conflictingPorts -and $attempts++ -le $threshold)

    # Throws the latest exception if cloning the VM was unsuccessful.
    if($attempts -gt $threshold) { Throw $exception }
}
Catch [System.Exception]
{
    Write-Warning ("An error occurred while creating the VM. Removing all disk copies...")

    # Removes all disks that were created through the execution of the script.
    foreach($name in $names.GetEnumerator())
    {
        & "$PSScriptRoot\Break-AzureBlobLease.ps1" `
                -StorageAccountName  $DestStorageName `
                -ContainerName       $container `
                -BlobName            $name.Name | Out-Null

        & "$PSScriptRoot\Remove-AzureStorageBlob.ps1" `
                -BlobName            $name.Name `
                -Container           $container `
                -Force | Out-Null
        
        Remove-AzureDisk $name.Value | Out-Null
    }
    
    Throw $_
}
