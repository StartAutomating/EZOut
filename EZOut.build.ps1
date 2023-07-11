#requires -Module PipeScript

if (-not $gumCmd) {
    "::group::Installing Gum" | Out-Host
    $goInstallGum = go install 'gum@latest'
    $goInstallGum | Out-Host
    "::endgroup::" | Out-Host
    
    $gumCmd = $ExecutionContext.SessionState.InvokeCommand.GetCommand('gum', 'Application')

    if (-not $gumCmd) { 
        throw "Gum not installed"
        return
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

    "GumArgumentList" = @{
        ParameterType = [string[]]
        Attributes = 'ValueFromRemainingArguments'
        Help = "Any additional arguments"
    }
}
$gumCmdHelps = @{}

foreach ($gumCommandName in $GumCommandNames) {
    $gumCmdHelp = & $gumCmd -h $gumCommandName
    $gumCmdHelps[$gumCommandName] = $gumCmdHelp
    
    foreach ($helpLine in $gumCmdHelp) {
        if ($helpline -notmatch '^\s{1,}.{0,}?\--(?<N>[\S-[\=]]+)') {
            continue
        }
        $bindingTo  = $matches.n        
        $dontCare, $paramDescription = $helpline -split "$bindingTo\S{0,}\s{0,}"
        $parameterName = [Regex]::Replace($bindingTo, "[\.\-]\p{L}", {
            "$args".Substring(1).ToUpper()
        })
        $parameterName = $parameterName.Substring(0,1).ToUpper() + $parameterName.Substring(1)
        $parameterType = [PSObject]
        if ($helpLine -match '=\d\.') {
            $parameterType = [double]
        }
        elseif ($helpLine -notmatch "$bindingTo=") {
            $parameterType = [switch]
        }        
        if ($parameterName -match '\p{P}') {
            if ($parameterName -match '--\[') {

            } 
            
        } else {
            if (-not $GumParameters.$parameterName) {

                $GumParameters.$parameterName = [Ordered]@{
                    Name = $parameterName
                    Description = $paramDescription
                    Binding = $bindingTo
                    Type = $parameterType
                }
    
            }
        }
    }
}

$newScript = New-PipeScript -Parameter $GumParameters -FunctionName "Format-Gum" -Begin {
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

    $myCmd = $MyInvocation.MyCommand
    $myParameters = [Ordered]@{} + $PSBoundParameters
    $gumArgs = @(
    :nextParameter foreach ($parameterKV in $MyInvocation.MyCommand.Parameters.GetEnumerator()) {

        if (-not $myParameters.Contains($parameterKV.Key)) {
            continue
        }
        foreach ($attr in $parameterKV.Value.Attributes) {
            if ($attr -is [ComponentModel.DefaultBindingPropertyAttribute]) {
                "--$($attr.Name)"
                if ($myParameters[$parameterKV.Key] -isnot [switch]) {
                    $myParameters[$parameterKV.Key]
                }
                continue nextParameter
            }
        }
    })

    $allGumArgs = @() + $gumArgs + $gumArgumentList

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
            $filteredInput | ConvertTo-Csv | & $gumCmd $Command @allGumArgs
        }
        else {
            $filteredInput | & $gumCmd $Command @allGumArgs
        }
    } else {
        & $gumCmd $Command @allGumArgs
    }
} -Noun "Gum" -Verb "Format" -Attribute @(
    '[CmdletBinding(PositionalBinding=$false)]'
    '[Management.Automation.Cmdlet("Format", "Object")]'
)


$newScript | Set-Content .\Format-Gum.ps1
Get-Item -Path .\Format-Gum.ps1