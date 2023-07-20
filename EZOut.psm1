[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="Using Within the Module")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="Allowing Extensibility")]
param()
$Script:FormatModules = @{}
$script:TypeModules = @{}

$commandsPath = Join-Path $psScriptRoot "Commands"

:ToIncludeFiles foreach ($file in (Get-ChildItem -Path "$commandsPath" -Filter "*-*" -Recurse)) {
    if ($file.Extension -ne '.ps1')      { continue }  # Skip if the extension is not .ps1
    foreach ($exclusion in '\.[^\.]+\.ps1$') {
        if (-not $exclusion) { continue }
        if ($file.Name -match $exclusion) {
            continue ToIncludeFiles  # Skip excluded files
        }
    }
    . $file.FullName
}

. $psScriptRoot\@.ps1 # Import Splatter

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
    $myModule = Get-Module EZOut
    $debuggingTypeNames = $myModule.DebuggingTypeNames
    if ($debuggingTypeNames) {
        
        foreach ($typeName in $debuggingTypeNames | Select-Object -Unique) {
            try {
                Remove-TypeData -TypeName $typeName -Confirm:$false -ErrorAction Ignore
            } catch {
                Write-Debug "$_"
            }
        }
    }
    Clear-FormatData
    Clear-TypeData
}