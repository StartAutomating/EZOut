#requires -Module PSDevOps
#requires -Module EZOut
Import-BuildStep -ModuleName EZOut
New-GitHubAction -Name "UseEZOut" -Description 'Generate Formatting and Types .ps1xml for PowerShell Modules, using EZOut' -Action EZOutAction -Icon code  -ActionOutput ([Ordered]@{
    EZOutScriptRuntime = [Ordered]@{
        description = "The time it took the .EZOutScript parameter to run"
        value = '${{steps.EZOutAction.outputs.EZOutScriptRuntime}}'
    }
    EZOutPS1Runtime = [Ordered]@{
        description = "The time it took all .EZOut.ps1 files to run"
        value = '${{steps.EZOutAction.outputs.EZOutPS1Runtime}}'
    }
    EZOutPS1Files = [Ordered]@{
        description = "The .EZOut.ps1 files that were run (separated by semicolons)"
        value = '${{steps.EZOutAction.outputs.EZOutPS1Files}}'
    }
    EZOutPS1Count = [Ordered]@{
        description = "The number of .EZOut.ps1 files that were run"
        value = '${{steps.EZOutAction.outputs.EZOutPS1Count}}'
    }
}) |
    Set-Content .\action.yml -Encoding UTF8 -PassThru
