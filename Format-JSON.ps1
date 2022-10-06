function Format-JSON {
<#
    .SYNOPSIS
        Formats objects as JSON
    .DESCRIPTION
        Formats an object as JSON.
        This is a light wrapper around ConvertTo-Json with a few key differences:
        1. It defaults -Depth to 100 (the maximum)
        2. It will not encode strings that look like JSON.  Format-JSON can have raw JSON as input without it being converted.
        3. It allows you to force single values into a list with -AsList
        4. If there is nothing to convert, it outputs an empty JSON object.
        Using Format-JSON inside of an EZOut command will pack Format-JSON into your exported .ps1xml.
    .EXAMPLE
        Format-JSON -InputObject @("a", "b", "c")
    .EXAMPLE
        [Ordered]@{a="b";c="d";e=[Ordered]@{f=@('g')}} | Format-JSON
    
#>
    
    [Management.Automation.Cmdlet("Format", "Object")]
[CmdletBinding(HelpUri='https://go.microsoft.com/fwlink/?LinkID=2096925', RemotingCapability='None')]
    param(
# If set, will always Format-JSON as a list.
    [switch]
    $AsList
    )
dynamicParam {
    $baseCommand = 
        if (-not $script:ConvertToJSON) {
            $script:ConvertToJSON = 
                $executionContext.SessionState.InvokeCommand.GetCommand('ConvertTo-JSON','Cmdlet')
            $script:ConvertToJSON
        } else {
            $script:ConvertToJSON
        }
    $IncludeParameter = @()
    $ExcludeParameter = @()
    $DynamicParameters = [Management.Automation.RuntimeDefinedParameterDictionary]::new()            
    :nextInputParameter foreach ($paramName in ([Management.Automation.CommandMetaData]$baseCommand).Parameters.Keys) {
        if ($ExcludeParameter) {
            foreach ($exclude in $ExcludeParameter) {
                if ($paramName -like $exclude) { continue nextInputParameter}
            }
        }
        if ($IncludeParameter) {
            $shouldInclude = 
                foreach ($include in $IncludeParameter) {
                    if ($paramName -like $include) { $true;break}
                }
            if (-not $shouldInclude) { continue nextInputParameter }
        }
        
        $DynamicParameters.Add($paramName, [Management.Automation.RuntimeDefinedParameter]::new(
            $baseCommand.Parameters[$paramName].Name,
            $baseCommand.Parameters[$paramName].ParameterType,
            $baseCommand.Parameters[$paramName].Attributes
        ))
    }
    $DynamicParameters
}
    begin {
        $accumulateInput = [Collections.Queue]::new()
        $rawJSON         = [Collections.Queue]::new()
    
}
    process {
        if ($_ -is [string] -and $_ -match '^\s{0,}[\[\{"]' -and $_ -match '[\]\}"]\s{0,}$') {
            $rawJSON.Enqueue($_)
        } else {
            $accumulateInput.Enqueue($_)        
        }        
    
}
    end {
        $joiner = "," + $(
            if (-not $PSBoundParameters["Compress"]) {
                [System.Environment]::NewLine
            }            
        )
        $null = $PSBoundParameters.Remove('AsList')
        if ($accumulateInput.Count) {
            if (-not $PSBoundParameters["Depth"]) {
                $PSBoundParameters["Depth"] = 100
            }
            $PSBoundParameters['InputObject'] = 
                if ($accumulateInput.Count -eq 1) {
                    $accumulateInput[0]
                } else {
                    $accumulateInput.ToArray()
                }
            
            $rawJSON.Enqueue((& $baseCommand @PSBoundParameters))
        }
        if ($rawJSON.Count -gt 1 -or $AsList) {
            "[$($rawJSON.ToArray() -join $joiner)]"
        } elseif ($rawJSON.Count -eq 1) {
            $rawJSON[0]
        } else {
            "{}"
        }
    
    }
}

