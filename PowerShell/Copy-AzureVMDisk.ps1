
# SCRIPT: Copy-AzureVMDisk.ps1
# ============================
# Creates an online copy of a virtual machine's disk.
# The date and time and disk type can be added to the name of the .vhd copy:
# 
# "yyyyMMdd-HHmmss-TTT-MyVirtualHardDisk.vhd"
# 
# In place of "TTT":
# 
#    OSD - The operating system disk.
#    DD0 - A data disk attached at LUN 0.
#    DD1 - A data disk attached at LUN 1.
#    ...
#
# Type          : Script
# Using         : Windows PowerShell (*.ps1)
#
# Written by    : Garreth J, Andrew D
# Last modified : 01/14/2016

#Requires -Version 3
#Requires -Modules Azure

<#
    .SYNOPSIS
        Creates an online copy of a virtual machine's disk.
    .DESCRIPTION
        The date and time and disk type can be added to the name of the .vhd copy:
		
        "yyyyMMdd-HHmmss-TTT-MyVirtualHardDisk.vhd"
		
        In place of TTT:
		
			OSD - The operating system disk.
			DD0 - A data disk attached at LUN 0.
			DD1 - A data disk attached at LUN 1.
			...
			
        See Start-CopyAzureStorageBlob cmdlet.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER VM
        Specifies a virtual machine object.
    .PARAMETER CopyOSDisk
        Specifies that you want to copy the OS disk in particular.
    .PARAMETER LUN
        Specifies particular data disks to copy, identified by their logical unit numbers.
    .PARAMETER DestStorageName
        Specifies the name for the destination's storage account. If not specified, the account name will match the name of the source virtual machine's storage account.
    .PARAMETER Container
        Specifies the container to store the backup disks.
    .PARAMETER Prefix
        Specifies the string each new disk name will start with. Codes ":DATE():" and ":TYPE:" are given for varying data.
        In place of ":DATE():",
        a date-time string: ":DATE(yyyy-MM-dd-HH-mm-ss):" -> "2016-01-14-17-27-54"
        In place of ":TYPE:",
        OSD - The operating system disk.
        DD0 - A data disk attached at LUN 0.
        DD1 - A data disk attached at LUN 1.
        ...
    .EXAMPLE
        PS C:\> Get-AzureVM -ServiceName "MySvc" -Name "MyVM" | .\Copy-AzureVMDisk.ps1
        This example creates backups of all disks attached to "MyVM".
    .EXAMPLE
        PS C:\> Get-AzureVM -ServiceName "MySvc" -Name "MyVM" | .\Copy-AzureVMDisk.ps1 -Location "backups"
        This example creates backups of all disks attached to "MyVM" and stores them in "backups".
    .EXAMPLE
        PS C:\> Get-AzureVM -ServiceName "MySvc" -Name "MyVM" | .\Copy-AzureVMDisk.ps1 -CopyOSDisk
        This example creates a backup of just the OS disk attached to "MyVM".
    .EXAMPLE
        PS C:\> Get-AzureVM -ServiceName "MySvc" -Name "MyVM" | .\Copy-AzureVMDisk.ps1 -LUN 0, 2
        This example creates backups of just the data disks attached to "MyVM" at LUN's 0 and 2.
    .EXAMPLE
        PS C:\> Get-AzureVM -ServiceName "MySvc" -Name "MyVM" | .\Copy-AzureVMDisk.ps1 -CopyOSDisk -LUN 0, 2
        This example creates backups of OS disk and the data disks attached to "MyVM" at LUN's 0 and 2.
    .Example
        PS C:\> Get-AzureVM -ServiceName "MySvc" -Name "MyVM" | .\Copy-AzureVMDisk.ps1 -Prefix ":DATE(yyyy-MM-dd-HH-mm-ss):-"
        This example creates backups of all disks attached to "MyVM" and adds the date and time to the beginning of each name.
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
    
    [Switch]
    $CopyOSDisk,
    
    [Int64[]]
    $LUN,
    
    [String]
    $DestStorageName,
    
    [String]
    $Container = "vhds",
    
    [String]
    $Prefix = ":DATE(yyyyMMdd-HHmmss):-:TYPE:-"
)

# Returns the prefix for the backup name of a .vhd file, replacing codes,
# :DATE(): and :TYPE: , which stand in for varying information.
#
# Example: ":DATE(yyyy-MM-dd):_:TYPE:_", "OSD"               -> "2016-01-14_OSD_"
#          "VhdCopy-:TYPE:-:DATE(MM-dd-yy):-", "DataDisk-L1" -> "VhdCopy-DataDisk-L1-01-14-16"

function Get-Prefix
{
    Param
    (
        [String] $Pattern,        
        [String] $TypeReplace
    )

    if($Pattern.Length -gt 0)
    {
        $dateStart = ":DATE("
        $dateEnd   = "):"

        # Replaces all insances of :DATE(): with the appropriate date-time.
        while($Pattern -like "*$dateStart*")
        {
            $str   = $Pattern

            $begin = $str.IndexOf($dateStart)
            
            $str   = $str.Substring($begin + $dateStart.Length)
                   
            $end   = $str.IndexOf($dateEnd)
                   
            $str   = $str.Substring(0, $end)
            
            $Pattern = $Pattern.Substring(0, $begin) + `
                       (Get-Date).ToString($str) + `
                       $Pattern.Substring($begin + $dateStart.Length + $end + $dateEnd.Length)
        }
    }
    
    # Returns the string with all instances of :TYPE: replaced.
    return $Pattern.Replace(":TYPE:", $TypeReplace)
}

$ErrorActionPreference = "Stop"

Try
{
    # Check if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    # Retrieves the virtual machine by parameter if it wasn't passed
    # through the pipeline.
    if($VM -eq $null) { $VM = & "$PSScriptRoot\Get-AzureVM.ps1" $ServiceName $VMName }

    # Retrieve the storage account name.
    $sourceStorageName = $VM | Invoke-Expression "$PSScriptRoot\Get-AzureStorageAccountName.ps1"

    # Keeps the new VM in the source VM's storage account if a new one isn't specified.
    # Else, a new storage account is created if the one provided doesn't exist.
    if($DestStorageName -eq "" -or $DestStorageName -eq $null)
    {
        $DestStorageName = $sourceStorageName
    }
    else
    {
        $location = (Get-AzureStorageAccount -StorageAccountName $sourceStorageName -WarningAction SilentlyContinue).Location

        & "$PSScriptRoot\New-AzureStorageAccount.ps1" -StorageAccountName $sourceStorageName -Location $location -MistypeAction "Fail"
    }

    # Retrieves the primary keys for both storage accounts.
    $sourceStorageKey = Get-AzureStorageKey $sourceStorageName | %{$_.Primary}
    $destStorageKey   = Get-AzureStorageKey $DestStorageName   | %{$_.Primary}

    # Creates storage contexts for both storage accounts.
    $sourceContext  = New-AzureStorageContext -StorageAccountName $sourceStorageName -StorageAccountKey $sourceStorageKey
    $destContext    = New-AzureStorageContext -StorageAccountName $DestStorageName   -StorageAccountKey $destStorageKey

    # Creates a new container for .vhd's if the destination account does not have one.
    if((Get-AzureStorageContainer -Context $destContext -Name $Container -ErrorAction SilentlyContinue) -eq $null)
    {
        New-AzureStorageContainer -Context $destContext -Name $Container | Out-Null
    }

    # If the source VM is still running, it's shut down.
    $previouslyPoweredOn = $VM | & "$PSScriptRoot\Stop-AzureVM.ps1" -StayProvisioned -Wait

    # Retrieve all disks attached to the virtual machine.
    $disks = $VM | & "$PSScriptRoot\Get-AzureVMDisk.ps1" -CopyOSDisk:$CopyOSDisk -LUN $LUN

    # Get the date.
    $date = (Get-Date).ToString("yyyyMMdd-HHmmss")

    # Initialize the list of blobs being copied.
    $copies = @{}

    Write-Output("Copying disks...")

    # Copy each disk in the list.
    foreach($disk in $disks)
    {
        # Get the code for the disk's type.
        $type = @{$true = "OSD"; $false = "DD$($disk.LUN)"}[$disk.GetType().Name -eq "OSVirtualHardDisk"]

        # Create the name for the backup disk.
        $backupName = (Get-Prefix -Pattern $Prefix -TypeReplace $type) + `
                      $disk.MediaLink.Segments[-1]
        
        # Start copying the disk over.
        $blob = Start-CopyAzureStorageBlob -SrcContext    $sourceContext `
                                           -SrcUri        $disk.MediaLink `
                                           -DestContainer $Container `
                                           -DestBlob      $backupName `
                                           -DestContext   $destContext
        
        # Add the disk to the list of blobs to be checked for progress.
        $copies.Add($disk, $blob)
    }

    $copies | & "$PSScriptRoot\Wait-AzureDiskCopy.ps1"

    # If the machine was previously powered on, restart the machine:
    if($previouslyPoweredOn)
    {
        Write-Output "Starting $VMName..."
        
        $VM | Start-AzureVM | Out-Null
    }

    Write-Output ("Copy completed.")

    return $copies
}
Catch [System.Exception]
{
    Throw $_
}
