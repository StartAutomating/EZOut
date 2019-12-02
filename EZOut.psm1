[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="Using Within the Module")]
param()
$Script:FormatModules = @{}
$script:TypeModules = @{}


#region Formatters
. $psScriptRoot\Add-FormatData.ps1
. $psScriptRoot\Clear-FormatData.ps1
. $psScriptRoot\Remove-FormatData.ps1

. $psScriptRoot\Out-FormatData.ps1
. $psScriptRoot\Write-FormatView.ps1

. $psScriptRoot\Write-FormatCustomView.ps1
. $psScriptRoot\Write-FormatListView.ps1
. $psScriptRoot\Write-FormatTableView.ps1
. $psScriptRoot\Write-FormatTreeView.ps1
. $psScriptRoot\Write-FormatViewExpression.ps1
. $psScriptRoot\Write-FormatWideView.ps1
Set-Alias Write-CustomAction Write-FormatCustomView
Set-Alias Show-CustomAction Write-FormatViewExpression
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

#region TypeData
. $psScriptRoot\Add-TypeData.ps1
. $psScriptRoot\Clear-TypeData.ps1
. $psScriptRoot\Remove-TypeData.ps1

. $psScriptRoot\Out-TypeData.ps1
. $psScriptRoot\Write-TypeView.ps1
#endregion TypeData

. $PSScriptRoot\Write-EzFormatFile.ps1

. $psScriptRoot\@.ps1 # Import Splatter



$myInvocation.MyCommand.ScriptBlock.Module.pstypenames.insert(0,'EZOut.RichModuleInfo')



# This little scriptblock is used a number of places.
$ConvertCiToEscapeSequence = {
    if ($ci -and -not $Host.ui.SupportsVirtualTerminal) { $ci = $null }
    if ($ci -like '#*') {
        $n =0
        $ci =@(foreach ($hc in $ci) {
            if (-not $hc.StartsWith('#')) { continue }
            $r,$g,$b = if ($hc.Length -eq 7) {
                [int]::Parse($hc[1..2]-join'', 'HexNumber')
                [int]::Parse($hc[3..4]-join '', 'HexNumber')
                [int]::Parse($hc[5..6] -join'', 'HexNumber')
            }elseif ($hc.Length -eq 4) {
                [int]::Parse($hc[1], 'HexNumber') * 16
                [int]::Parse($hc[2], 'HexNumber') * 16
                [int]::Parse($hc[3], 'HexNumber') * 16
            }
            if ($n -eq 1) { [char]0x1b+"[48;2;$r;$g;${b}m" }
            elseif (-not $n) { [char]0x1b+"[38;2;$r;$g;${b}m" }
            $n++
        }) -join ';'
    } elseif ($ct -like ([string][char]0x1b +'*')) {
        $ci
    }
}

$outputAndClearCI = {
    $outParts = @() + $ci + $output + $(
        if ($ci) {[char]0x1b + "[39m" + [char]0x1b + "[49m"}
    )
    $outParts -join ''
}
Export-ModuleMember -Function * -Alias *
$myInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    Clear-FormatData
    Clear-TypeData
}