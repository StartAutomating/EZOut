#requires -Module PipeScript

Push-Location ($PSScriptRoot | Split-Path)

if (-not $gumCmd) {
    "::group::Installing Gum" | Out-Host
    $goInstallGum = go install 'github.com/charmbracelet/gum@latest'
    $goInstallGum | Out-Host
    "::endgroup::" | Out-Host

    $gumCmd = $ExecutionContext.SessionState.InvokeCommand.GetCommand('gum', 'Application')

    if (-not $gumCmd) {
        if (-not $env:GOPATH) {
            
            $null, $env:GOPATH = @(go env) -like 'set GOPath*' -split '=', 2
            "Setting `$ENV:GOPATH to '$ENV:GoPath'" | Out-Host
        } 
        if ($env:GOPATH) {
            $gumExeFound  = Get-ChildItem -Path $env:GOPATH -Recurse -Filter "gum.exe"
            if ($gumExeFound) {
                $gumCmd = $ExecutionContext.SessionState.InvokeCommand.GetCommand($gumExeFound.FullName, 'Application')
            }
        }
        if (-not $gumCmd) {
            throw "Gum not installed"
            return
        }        
    }
}


$dontCare, $commandsList = @(& $gumCmd -h) -join [Environment]::Newline -split "(?m)^Commands\:"

$commandsList = $commandsList -split '(?>\r\n|\n)'
$commandsList = $commandsList[1..($commandsList.Length - 2)]
    
$GumCommandTable = @(
    '|CommandName|Description|'
    '|-|-|'
)

$GumCommandNames = @()
  
$GumCommandTable += foreach ($line in $commandsList -split '(?>\r\n|\n)') {
    if (-not $line) { continue }
    $CommandName, $Description = $line -replace '^\s{1,}' -split '\s{1,}'
    
    if (-not $CommandName) { break}
    '|' + $CommandName + '|' + $($Description -join ' ') + '|'
    $GumCommandNames+= $CommandName  
}

$GumParameters = [Ordered]@{
    "Command" = @{
        ParameterType = [string]
        ValidValue = $GumCommandNames
        Help = @(
            "The Command in Gum."
            $GumCommandTable
        ) -join [Environment]::Newline
        Attributes = "[Parameter(Mandatory,Position=0)]"
    }
    
    "InputObject" = @{
        ParameterType = [PSObject]
        Attributes = 'ValueFromPipeline'
        Help = "The input object."
    }

    "GumArgument" = @{
        Alias = 'GumArguments'
        ParameterType = [string[]]
        Attributes = @('ValueFromRemainingArguments')
        Help = "Any additional arguments to gum (and any remaining arguments)"
    }
}


$newScript = New-PipeScript -Parameter $GumParameters -FunctionName "Out-Gum" -Begin {
    $accumulateInput = [Collections.Queue]::new()
} -Process {
    if ($inputObject) {
        $accumulateInput.Enqueue($inputObject)
    }
} -End {
    $gumCmd = $ExecutionContext.SessionState.InvokeCommand.GetCommand('gum', 'Application')
    if (-not $gumCmd) {
        Write-Error "Gum not installed"
        return
    }

    #region Fix Gum Arguments
    $allGumArgs = @(
        foreach ($gumArg in $gumArgument) {
            # Fix single dashing / slashing parameter convention.
            if ($gumArg -match '^[-/]\w') {
                $gumArg -replace '^[-/]', '--'
            } else {
                $gumArg
            }
        }
    )
    #endregion Fix Gum Arguments

    Write-Verbose "Calling gum with $allGumArgs"

    if ($accumulateInput.Count) {
        $MustConvert = $false
        $filteredInput = @(
        foreach ($inputObject in $accumulateInput) {
            if (-not $inputObject.GetType) { continue } 
            if ($inputObject -is [string] -or $inputObject.IsPrimitive) {
                $inputObject
            } else {
                $MustConvert = $true
                $inputObject
            }
        })
        if ($MustConvert) {
            $filteredInput = $filteredInput | ConvertTo-Csv
        }

        if ($isPipedFrom) {
            $gumOutput = $filteredInput | & $gumCmd $Command @allGumArgs
            $gumOutput
        } else {
            $filteredInput | & $gumCmd $Command @allGumArgs
        }

    } else {
        if ($isPipedFrom) {
            $gumOutput = $filteredInput | & $gumCmd $Command @allGumArgs
            $gumOutput
        } else {
            & $gumCmd $Command @allGumArgs
        }
    }
} -Noun "Gum" -Verb "Format" -Attribute @(
    '[CmdletBinding(PositionalBinding=$false)]'
    '[Management.Automation.Cmdlet("Format", "Object")]'
    '[Alias("gum")]'
) -Synopsis "Outputs using Gum" -Description "
Allows you to format objects using [CharmBraclet's Gum](https://github.com/charmbracelet/gum).
" -Example @(
    "'live', 'die' | Out-Gum choose"
    "'What is best in life?' | Out-Gum -Command input"
) -Link "https://github.com/charmbraclet/gum"


$newScript | Set-Content .\Out-Gum.ps1
Get-Item -Path .\Out-Gum.ps1