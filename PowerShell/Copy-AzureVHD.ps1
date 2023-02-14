
[CmdletBinding()]
Param
(
    [Parameter(ValueFromPipeline=$true)]
    [System.Object] $Disk,

    [URI]           $URI = $Disk.MediaLink,
    
    [Parameter(Mandatory=$true)]
    [String]        $Name,
    
    [Parameter(Mandatory=$true)]
    [String]        $Container,
    
    [Parameter(Mandatory=$true, ParameterSetName="ByContext")]
    [String]        $SrcContext,
    
    [Parameter(Mandatory=$true, ParameterSetName="ByContext")]
    [String]        $DestContext,
    
    [Parameter(Mandatory=$true, ParameterSetName="ByStorageAccount")]
    [String]        $SrcStorageName,
    
    [Parameter(Mandatory=$true, ParameterSetName="ByStorageAccount")]
    [String]        $DestStorageName,
    
    [Switch]        $Force
)

$ErrorActionPreference = "Stop"

Try
{
    # Check if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    if($PSCmdlet.ParameterSetName -eq "ByStorageAccount")
    {
        # Retrieves the primary keys for both storage accounts.
        $srcStorageKey  = Get-AzureStorageKey $SrcStorageName  | %{$_.Primary}
        $destStorageKey = Get-AzureStorageKey $DestStorageName | %{$_.Primary}

        # Creates storage contexts for both storage accounts.
        $SrcContext  = New-AzureStorageContext -StorageAccountName $SrcStorageName  -StorageAccountKey $srcStorageKey
        $DestContext = New-AzureStorageContext -StorageAccountName $DestStorageName -StorageAccountKey $destStorageKey
    }

    # Start copying the disk over.
    return Start-AzureStorageBlobCopy -SrcUri        $URI `
                                      -DestBlob      $Name `
                                      -DestContainer $Container `
                                      -SrcContext    $SrcContext `
                                      -DestContext   $DestContext `
                                      -Force         $Force
}
Catch [System.Exception]
{
    Throw $_
}
