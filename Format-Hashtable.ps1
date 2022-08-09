function Format-Hashtable {
    <#
    .Synopsis
        Takes an creates a script to recreate a hashtable
    .Description
        Allows you to take a hashtable and create a hashtable you would embed into a script.
        
        Handles nested hashtables and indents nested hashtables automatically.        
    .Example
        # Corrects the presentation of a PowerShell hashtable
        [Ordered]@{Foo='Bar';Baz='Bing';Boo=@{Bam='Blang'}} | Format-Hashtable
    .Outputs
        [string]
    .Outputs
        [ScriptBlock]   
    .Link
        about_hash_tables
    #>    
    [OutputType([string], [ScriptBlock])]
    [Management.Automation.Cmdlet("Format", "Object")]
    [ValidateScript({return $true})]
    param(
    # The hashtable or PSObject that will be written as a PowerShell Hashtable
    [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [PSObject]
    $InputObject,

    # Returns the content as a script block, rather than a string
    [Alias('ScriptBlock')]
    [switch]$AsScriptBlock,

    # If set, will return the hashtable and all nested hashtables as custom objects.
    [switch]$AsPSObject,

    # If set, items in the hashtable will be sorted alphabetically
    [Switch]$Sort,
    
    # If set, credentials will be expanded out into a hashtable containing the username and password.          
    [Switch]$ExpandCredential,

    # If set, the outputted hashtable will not contain any extra whitespace.
    [switch]$Compress,

    # If set, will embed ScriptBlocks as literal strings,
    # so that the resulting hashtable could work in data language mode.
    [switch]$Safe,

    # The maximum depth to enumerate.
    # Beneath this depth, items will simply be returned as $null.
    [int]$Depth
    )

    begin {
        $myCmd = $MyInvocation.MyCommand
    }

    process {
        if (-not $Compress) {
            $psCallstack = @(Get-PSCallStack)
            $callstack = @(foreach ($cs in $psCallstack) {
                if ($cs.InvocationInfo.MyCommand.ScriptBlock -eq $myCmd.ScriptBlock) {
                    $cs
                }
            })
        } else {
            $callstack = @()
        }

        $myParams = @{} + $PSBoundParameters
        $myParams.Remove('InputObject')
        $CurrentDepth = $callStack.Count
        
        if ($Depth -and $CurrentDepth -gt $Depth) {
            return '$null'
        }

        if ($inputObject -isnot [Collections.IDictionary]) {
            $newInputObject = [Ordered]@{
                PSTypeName=@($inputobject.pstypenames)[0]
            }
            if ('System.Object', 'System.Management.Automation.PSCustomObject' -contains 
                $newInputObject.pstypename) {
                $newInputObject.Remove('PSTypeName')
            } 
            foreach ($prop in $inputObject.psobject.properties) {                
                $newInputObject[$prop.Name] = $prop.Value
            }            
            $inputObject = $newInputObject
        }
        
        if ($inputObject -is [Collections.IDictionary]) {
            #region Indent
            $scriptString = ""
            $indent = $CurrentDepth * 4
            $scriptString+= 
                if ($Compress) {
                    "@{"
                } else {
                    "@{
"
                }        
            
            #endregion Indent
            #region Include
            $items = $inputObject.GetEnumerator()

            if ($Sort) {
                $items = $items | Sort-Object Key
            }
            

            foreach ($kv in $items) {
                if (-not $Compress) {
                    $scriptString+=" " * $indent
                }
                if ($kv.Key -eq 'keywords') {
                    $null = $null
                }
                $keyString = "$($kv.Key)"
                if ($keyString.IndexOfAny(" _.#-+:;()'!?^@#$%&=|".ToCharArray()) -ne -1) {
                    if ($keyString.IndexOf("'") -ne -1) {
                        $scriptString+="'$($keyString.Replace("'","''"))' = "
                    } else {
                        $scriptString+="'$keyString' = "
                    }                    
                } elseif ($keyString) {
                    $scriptString+="$keyString = "
                }
                                                                
                $value = $kv.Value                
                $value =
                    if ($value -is [string]) {                
                        "'"  + 
                        $value.Replace("'","''").Replace("’", "’’").Replace("‘", "‘‘") +
                        "'"
                    } elseif (
                        $value -is [ScriptBlock] -or $value -is [Management.Automation.Language.Ast]
                    ) {
                        if ($safe) { 
                            "@'" + [Environment]::NewLine +
                            $value
                            [Environment]::NewLine + "'@'"
                        }  else {
                            "{$value}"
                        } 
                    } elseif ($value -is [switch]) {
                        if ($value) { '$true' } else { '$false' }
                    } elseif ($value -is [DateTime]) {
                        "[DateTime]'$($value.ToString("o"))'"
                    } 
                    elseif ($value -is [Timespan]) {                        
                            if ($Safe) { 
                                "'$($value.ToString())'"
                            } else {
                                "[Timespan]'$($value.ToString())'"
                            }
                    } 
                    elseif ($value -is [bool]) {
                        if ($value) { '$true'} else { '$false' }
                    } elseif ($value -and $value.GetType -and (
                        $value.GetType().IsArray -or $value -is [Collections.IList] -or
                        ($value -is [Collections.IEnumerable] -and $value -isnot [Collections.IDictionary])
                    )) {
                        $joiner =
                            if ($Compress) {
                                ','
                            } else {
                                "," + [Environment]::NewLine + (' ' * ($indent + 4))
                            }
                        @(foreach ($v in $value) {
                            if ($v -is [Collections.IDictionary]) {                            
                                & $myCmd -InputObject $v @myParams
                            } elseif ($v -is [ScriptBlock] -or $v -is [Management.Automation.Language.Ast]) {
                                if ($Safe) {

                                } else {
                                    "{$v}"
                                }
                            } elseif ($v -is [Object] -and $v -isnot [string]) {
                                & $myCmd -InputObject $v @myParams
                            } elseif ($v -is [bool] -or $v -is [switch]) {
                                "`$$v"
                            } elseif ($null -ne ($v -as [float])) {
                                $v
                            } else {
                                ("'"  + "$v".Replace("'","''").Replace("’", "’’").Replace("‘", "‘‘") + "'")
                            }
                        }) -join $joiner                                        
                    } elseif ($value -as [Collections.IDictionary[]]) {
                        @(foreach ($v in $value) {
                            & $myCmd $v @myParams
                        }) -join ","                    
                    } elseif ($value -is [Collections.IDictionary]) {
                        "$(& $myCmd $value @myParams)"
                    } elseif ($value -as [Double]) {
                        "$value"
                    } elseif ($value -is [Management.Automation.PSCredential] -and $ExpandCredential) {
                        & $myCmd -InputObject ([Ordered]@{
                                Username = $value.Username
                                Password = $value.GetNetworkCredential().Password
                        }) @myParams
                    } else {
                        $valueString = "'$($value -replace "'", "''")'"
                        if ($valueString[0] -eq "'" -and 
                            $valueString[1] -eq "@" -and 
                            $valueString[2] -eq "{") {
                            & $myCmd -InputObject $value @myParams
                        } else {
                            $valueString
                        }                        
                    }

                $scriptString+=
                    if ($Compress) {
                        "$value;"
                    } else {
                        "$value" + [Environment]::NewLine
                    }                                
            }

            if (-not $Compress) {
                $scriptString += " " * ($CurrentDepth - 1) * 4
            }          
            $scriptString += "}"
            if ($AsPSObject -and -not $Safe) {
                $scriptString = "[PSCustomObject][Ordered]$ScriptString"
            }
            
            if ($AsScriptBlock) {
                [ScriptBlock]::Create($scriptString)
            } else {                
                $scriptString
            }
            #endregion Include
        }          
   }
}         

