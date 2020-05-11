do {
    $lm = Get-Module -Name $moduleName -ErrorAction Ignore
    if (-not $lm) { continue } 
    if ($lm.FormatPartsLoaded) { break }
    $wholeScript = @(foreach ($formatFilePath in $lm.exportedFormatFiles) {         
        foreach ($partNodeName in Select-Xml -LiteralPath $formatFilePath -XPath "/Configuration/Controls/Control/Name[starts-with(., '$')]") {
            $ParentNode = $partNodeName.Node.ParentNode
            "$($ParentNode.Name)={
$($ParentNode.CustomControl.CustomEntries.CustomEntry.CustomItem.ExpressionBinding.ScriptBlock)}"
        }
    }) -join [Environment]::NewLine
    New-Module -Name "${ModuleName}.format.ps1xml" -ScriptBlock ([ScriptBlock]::Create(($wholeScript + ';Export-ModuleMember -Variable *'))) |
        Import-Module -Global
    $onRemove = [ScriptBlock]::Create("Remove-Module '${ModuleName}.format.ps1xml'")
    
    if (-not $lm.OnRemove) {
        $lm.OnRemove = $onRemove
    } else {
        $lm.OnRemove = [ScriptBlock]::Create($onRemove.ToString() + ''  + [Environment]::NewLine + $lm.OnRemove)
    }
    $lm | Add-Member NoteProperty FormatPartsLoaded $true -Force

} while ($false)
