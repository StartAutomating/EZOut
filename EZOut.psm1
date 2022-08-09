[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="Using Within the Module")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="Allowing Extensibility")]
param()
$Script:FormatModules = @{}
$script:TypeModules = @{}

#region Formatters
. $psScriptRoot\Add-FormatData.ps1
. $psScriptRoot\Clear-FormatData.ps1
. $psScriptRoot\Remove-FormatData.ps1

. $psScriptRoot\Out-FormatData.ps1


. $psScriptRoot\Import-FormatView.ps1
. $psScriptRoot\Import-TypeView.ps1

. $psScriptRoot\Write-FormatControl.ps1
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

. $PSScriptRoot\Write-EZFormatFile.ps1

. $psScriptRoot\@.ps1 # Import Splatter




. $psScriptRoot\Get-EZOutExtension.ps1

. $psScriptRoot\Format-Object.ps1
. $psScriptRoot\Format-Heatmap.ps1
. $psScriptRoot\Format-RichText.ps1
. $psScriptRoot\Format-Markdown.ps1
. $psScriptRoot\Format-YAML.ps1
. $psScriptRoot\Format-Hashtable.ps1

$myInvocation.MyCommand.ScriptBlock.Module.pstypenames.insert(0,'EZOut.RichModuleInfo')

#region Import Parts

# Parts are simple .ps1 files beneath a /Parts directory that can be used throughout the module.
$partsDirectory = $( # Because we want to be case-insensitive, and because it's fast
    foreach ($dir in [IO.Directory]::GetDirectories($psScriptRoot)) { # [IO.Directory]::GetDirectories()
        if ($dir -imatch "\$([IO.Path]::DirectorySeparatorChar)Parts$") { # and some Regex
            [IO.DirectoryInfo]$dir;break # to find our parts directory.
        }
    })

if ($partsDirectory) { # If we have parts directory
    foreach ($partFile in $partsDirectory.EnumerateFileSystemInfos()) { # enumerate all of the files.
        if ($partFile.Extension -ne '.ps1') { continue } # Skip anything that's not a PowerShell script.
        $partName = # Get the name of the script.
            $partFile.Name.Substring(0, $partFile.Name.Length - $partFile.Extension.Length)
        $ExecutionContext.SessionState.PSVariable.Set( # Set a variable
            $partName, # named the script that points to the script (e.g. $foo = gcm .\Parts\foo.ps1)
            $ExecutionContext.SessionState.InvokeCommand.GetCommand($partFile.Fullname, 'ExternalScript').ScriptBlock
        )
    }
}
#endregion Import Parts



Update-FormatData -PrependPath $psScriptRoot\EZOut.format.ps1xml

Export-ModuleMember -Function * -Alias *
$myInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    Clear-FormatData
    Clear-TypeData
}