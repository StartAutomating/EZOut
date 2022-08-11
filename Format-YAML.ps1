function Format-YAML
{
    <#
    .SYNOPSIS
        Formats objects as YAML
    .DESCRIPTION
        Formats an object as YAML.
    .EXAMPLE
        Format-Yaml -InputObject @("a", "b", "c")
    .EXAMPLE
        @{a="b";c="d";e=@{f=@('g')}} | Format-Yaml
    #>
    [Management.Automation.Cmdlet("Format","Object")]
    [ValidateScript({return $true})]
    param(
    # The InputObject.
    [Parameter(ValueFromPipeline)]
    [PSObject]
    $InputObject,

    # If set, will make a YAML header by adding a YAML Document tag above and below output.
    [Alias('YAMLDocument')]
    [switch]
    $YamlHeader,

    [int]
    $Indent = 0,

    # The maximum depth of objects to include.
    # Beyond this depth, an empty string will be returned.    
    [int]
    $Depth
    )

    begin {
        $toYaml = {
            param(
            [Parameter(ValueFromPipeline,Position=0)]$Object,
            [Object]$Parent,
            [Object]$GrandParent,
            [int]$Indent = 0)
            
            begin { $n = 0; $mySelf = $myInvocation.MyCommand.ScriptBlock }
            process {
                $n++
                if ($Object -eq $null) { return }

                if ($depth) {
                    $myDepth = $indent / 2
                    if ($myDepth -gt $depth) {
                        return ''
                    }
                }
            
                if ($Parent -and $Parent -is [Collections.IList]) {
                    if ($Parent.IndexOf($Object) -gt 0) { ' ' * $Indent }
                    '- '
                }
            
                #region Primitives
                if ( $Object -is [string] ) { # If it's a string
                    if ($object -match '\n') { # see if it's a multline string.
                        "|" # If it is, emit the multiline indicator
                        $indent +=2
                        foreach ($l in $object -split '(?>\r\n|\n)') { # and emit each line indented
                            [Environment]::NewLine
                            ' ' * $indent
                            $l
                        }
                        $indent -=2
                    } elseif ("$object".Contains('*')) {
                        "'$($Object -replace "'","''")'"
                    } else {
                        $object
                    }
            
                    if ($Parent -is [Collections.IList]) { # If the parent object was a list
                        [Environment]::NewLine # emit a newline.
                    }
                    return # Once the string has been emitted, return.
                }
                if ( $Object.GetType().IsPrimitive ) { # If it is a primitive type
                    "$Object".ToLower()  # Emit it in lowercase.
                    if ($Parent -is [Collections.IList]) {
                        [Environment]::NewLine
                    }
                    return
                }
                #endregion Primitives
            
                #region KVP
                if ( $Object -is [Collections.DictionaryEntry] -or $object -is [Management.Automation.PSPropertyInfo]) {
                    if ($Parent -isnot [Collections.IList] -and
                        ($GrandParent -isnot [Collections.IList] -or $n -gt 1)) {
                        [Environment]::NewLine + (" " * $Indent)
                    }
                    if ($object.Key -and $Object.Key -is [string]) {
                        $Object.Key +": "
                    } elseif ($object.Name -and $object.Name -is [string]) {
                        $Object.Name +": "
                    }
                }
            
                if ( $Object -is [Collections.DictionaryEntry] -or $Object -is [Management.Automation.PSPropertyInfo]) {
                    & $mySelf -Object $Object.Value -Parent $Object -GrandParent $parent -Indent $Indent
                    return
                }
                #endregion KVP
            
            
                #region Nested
                if ($parent -and ($Object -is [Collections.IDictionary] -or $Object  -is [PSObject])) {
                    $Indent += 2
                } 
                elseif ($object -is [Collections.IList]) {
                    $allPrimitive = 1
                    foreach ($Obj in $Object) { 
                        $allPrimitive = $allPrimitive -band (
                            $Obj -is [string] -or 
                            $obj.GetType().IsPrimitive
                        ) 
                    }
                    if ($parent -and -not $allPrimitive) {
                        $Indent += 2
                    }
                }
            
            
                if ( $Object -is [Collections.IDictionary] ) {
                    $Object.GetEnumerator() |
                        & $mySelf -Parent $Object -GrandParent $Parent -Indent $Indent
                } elseif ($Object -is [Collections.IList]) {
            
                    [Environment]::NewLine + (' ' * $Indent)
            
                    $Object |
                        & $mySelf -Parent $Object -GrandParent $Parent -Indent $Indent
            
                } elseif ($Object.PSObject.Properties) {
                    $Object.psobject.properties |
                        & $mySelf -Parent $Object -GrandParent $Parent -Indent $Indent
                }
            
                if ($Object -is [Collections.IDictionary] -or $Object  -is [PSCustomObject] -or $Object -is [Collections.IList]) {
                    if ($Parent -is [Collections.IList]) { [Environment]::NewLine }
                    $Indent -= 2;
                }
                #endregion Nested
            }                
        }
        function IndentString([string]$String,[int]$Indent) {
            @(foreach ($line in @($String -split '(?>\r\n|\n)')) {
                (' ' * $indent) + $line 
            }) -join [Environment]::NewLine
        }
        $inputWasNotPiped = $PSBoundParameters.InputObject -as [bool]
        $allInputObjects  = @()
    }

    process {
        if ($inputWasNotPiped) {
            IndentString ('' + $(if ($YamlHeader) { '---' + [Environment]::NewLine })  + (
                (& $toYaml -object $inputObject) -join '' -replace 
                    "$([Environment]::NewLine * 2)", [Environment]::NewLine
            ) + $(if ($YamlHeader) { [Environment]::NewLine  + '---'})) -Indent $Indent
        } else {
            $allInputObjects += $inputObject
        }
    }

    end {
        if (-not $allInputObjects) { return }
        if ($allInputObjects.Length -eq 1) {
            IndentString ('' + $(if ($YamlHeader) { '---' + [Environment]::NewLine}) + (
                (& $toYaml -object $inputObject) -join '' -replace 
                    "$([Environment]::NewLine * 2)", [Environment]::NewLine
            ) + $(if ($YamlHeader) { [Environment]::NewLine  + '---'})) -Indent $Indent
        } else {
            IndentString ('' + $(if ($YamlHeader) { '---' + [Environment]::NewLine})  + (
                (& $toYaml -object $allInputObjects) -join '' -replace 
                    "$([Environment]::NewLine * 2)", [Environment]::NewLine
            ) + $(if ($YamlHeader) { [Environment]::NewLine  + '---'})) -Indent $Indent
        }
    }
}


