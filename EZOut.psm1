
$Script:FormatModules = @{}
$script:TypeModules = @{}


#region Formatters
. $psScriptRoot\Add-FormatData.ps1
. $psScriptRoot\Clear-FormatData.ps1
. $psScriptRoot\Remove-FormatData.ps1

. $psScriptRoot\Out-FormatData.ps1
. $psScriptRoot\Show-CustomAction.ps1
. $psScriptRoot\Write-FormatView.ps1
. $psScriptRoot\Write-CustomAction.ps1
. $psScriptRoot\Write-FormatTableView.ps1
#endregion Formatters

#region Format Discovery
. $psScriptRoot\Get-FormatFile.ps1
. $psScriptRoot\Find-FormatView.ps1
#endregion Format Discovery

#region Property Sets
. $psScriptRoot\ConvertTo-PropertySet.ps1
. $psScriptRoot\Get-PropertySet.ps1
. $psScriptRoot\Write-PropertySet.ps1

Set-Alias ConvertTo-TypePropertySet ConvertTo-PropertySet
#endregion Property Sets

. $psScriptRoot\Write-PowerShellHashtable.ps1
. $psScriptRoot\Write-CommandOverload.ps1

#region TypeData
. $psScriptRoot\Add-TypeData.ps1
. $psScriptRoot\Clear-TypeData.ps1
. $psScriptRoot\Remove-TypeData.ps1

. $psScriptRoot\Out-TypeData.ps1
. $psScriptRoot\Write-TypeView.ps1
#endregion TypeData

Export-ModuleMember -Function * -Alias *


$myInvocation.MyCommand.ScriptBlock.Module.OnRemove = { 
    Clear-FormatData
    Clear-TypeData
}
