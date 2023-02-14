
Supported Operating Systems
---------------------------
- Windows 2012 R2
- Windows 8.1


Important files in this directory
---------------------------------
```
[!] You must be connected to an Azure subscription in order to use
    these scripts. See AzureSetupNotes.docx and
    PowerShell\Connect-AzureSubscription.ps1.

    Command scripts
    ---------------
    01_AzureCmdlets_Install.bat
    02_AzurePublishSettings_Download.bat
    03_AzurePublishSettings_Install.bat
    11_AzureCloudService_List.bat
    12_AzureStorageAccount_List.bat
    13_AzureVMTemplate_List.bat
    14_AzureVM_List.bat
    15_AzureStorageContainer_List.bat
    16_AzureStorageContainer_Show.bat
    17_AzureCloudService_Create.bat
    18_AzureStorageAccount_Create.bat
    21_AzureVM_Create.bat
    22_AzureVM_RemoteConnect.bat
    23_AzureVM_StopAll.bat
    24_AzureVM_DeallocateAll.bat
    25_AzureVM_Start.bat
    26_AzureVM_Clone.bat
    27_AzureVM_Restore.bat

    Configuration files
    -------------------
    20_AzureVMConfiguration.txt

    References
    ----------
    VMRoleSizes_Reference.txt
```


Getting Started
---------------

1. ConnectToAzure.ps1 - Takes you to the portal and downloads the Publish-Settings file.

2. Import-PublishSettings.bat - Runs the default Publish-Settings file. If you downloaded a new one, you should edit the script.

3. StorageAccount_List.bat - Select a storage account from the list (or spec a new one in Step 6 -- must edit step 6 bat and change arg).
4. CloudService_List.bat - Select a cloud service from the list (or spec a new one in Step 6 -- must edit step 6 bat and change arg).
5. VMTemplate_List.bat - Select a virtual machine template (image name) from the list -- must edit step 6 bat and change arg.

6. New-AzureVM.bat


Help
----
Use the \help flag to show documentation for each script:

```
    Example: C:\> CreateAzureVM.bat /help
```


Virtual Machine Roles (States)
------------------------------
```
                                                   -------------
                                                  |             |
                               -----------------> |   RUNNING   |
                              |  ---------------- |             |
       -------------   START  | |   DEALLOCATE     -------------
      |             | --------  |                     /\   ||
      | DEALLOCATED | <---------                START ||   || STOP
      |             | <-------                        ||   \/
       -------------          |                    -------------
                              |                   |             |
                               ------------------ |   STOPPED   |
                                    DEALLOCATE    |             |
                                                   -------------
```
