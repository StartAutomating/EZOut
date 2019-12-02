### EZOut helps you to control the look of output from content in PowerShell.

#### EZOut simplifies the process of making PowerShell Formatting(.format.ps1xml) and Type(.types.ps1xml) files by letting you write PowerShell formatting with simple commands. 

#### EZOut can be used to change formatting on the fly, and it is indispensible in creating quality PowerShell modules.


To get started, download EZOut, and then try some cool tricks:

    Import-Module EZOut

    Write-FormatView -TypeName 'System.Management.ManagementObject#root\cimv2\Win32_VideoController -Property Name, Memory, Mode -Width 30,15,40 -VirtualProperty @{
        "Memory" = {
            "$($_.AdapterRAM / 1mb) mb"
        }
    } -RenamedProperty @{
        "Mode" = "VideoModeDescription"
    }| 
        Out-FormatData |
        Add-FormatData
    
    Get-WmiObject Win32_VideoController