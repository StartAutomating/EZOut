#requires -Module PSDevOps
#requires -Module EZOut
Import-BuildStep -ModuleName EZOut
Push-Location $PSScriptRoot
New-GitHubAction -Name "UseEZOut" -Description @'
Generate Formatting and Types .ps1xml for PowerShell Modules, using EZOut
'@ -Action EZOutAction -Icon code -OutputPath .\action.yml
Pop-Location