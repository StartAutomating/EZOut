function Import-FormatView
{
    <#
    .Synopsis
        Imports a Format View
    .Description
        Imports a Format View from a script block or external file
    .Link
        Write-FormatView
    #>
    param(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('FullName')]
    [string[]]
    $FilePath
    )

    begin {
        # Loop over the input files
        # When it's a directory, recursively call yourself
        # When it's a file that doesn't match our pattern, return
        # When it's a .ps1, search attributes from [OutputType()] and [PSTypeName]
        # If the file contained EZOut cmds, run it
        # Otherwise, make it a custom action (convert it to XML)
        # If it was XML, use it directly
        # Pipe to Out-FormatData
        $MySelf = $MyInvocation.MyCommand.ScriptBlock



        $ezOutCommands=
            @(
            $ezOutModule =  $MyInvocation.MyCommand.ScriptBlock.Module
            foreach ($_ in $ezOutModule.ExportedCommands.Values) {
                $_.Name
            })

        $getViewFileInfo = {
            param(
                [Parameter(Mandatory=$true)][string]$fileName,
                [Parameter(Mandatory=$true)][ScriptBlock]$ScriptBlock
            )

            $typeName = @(foreach ($attr in $ScriptBlock.Attributes) { # check the attributes.
                if ($attr -is [Management.Automation.PSTypeNameAttribute]) { # A typename can come from the PSTypeName attribute
                    $attr.PSTypeName
                }
                if ($attr -is [Management.Automation.OutputTypeAttribute]) { # or the [OutputType] attribute.
                    foreach ($t in $attr.Type) {
                        $t.Name
                    }
                }
            }) | Select-Object -Unique

            # Infer the type name from the file name.
            $inferredTypeName = $fileName -replace '\.(format|type|view|control)\.ps1'

            if (-not $typeName) { # If no typename has been determined by now,
                $typeName = $inferredTypeName # use the inferred type name.
            }

            @{
                TypeName = $typeName
                InferredTypeName = $inferredTypeName
            }
        }
    }

    process {
        $innerFormat = @{}
        $formatterByTypeName = @{}



        foreach ($fp in $FilePath) {
            if ([IO.Directory]::Exists($fp)) {
                $fp |
                    Get-ChildItem |
                    & $MySelf
                continue
            }
            $fi =
                if ([IO.File]::Exists($fp)) {
                    [IO.FileInfo]::new($fp)
                } else {
                    $rp = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($fp)
                    if (-not $rp) { continue }
                    [IO.FileInfo]::new("$rp")
                }

            if (-not $fi.Length) {
                continue
            }
            if ('.xml', '.ps1' -notcontains $fi.Extension) { continue }

            if ($fi.Extension -eq '.xml') {
                $innerFormat[$fi.Name] = [xml][IO.File]::ReadAllText($fi.FullName)
            } else {
                $innerFormat[$fi.Name] = [ScriptBlock]::Create([IO.File]::ReadAllText($fi.FullName))
            }
        }


        foreach ($if in $innerFormat.GetEnumerator()) {
            if ($if.Value -is [ScriptBlock]) {
                $viewFileInfo = (& $getViewFileInfo $if.Key $if.Value)
                $typeName, $inferredTypeName =
                    $viewFileInfo.TypeName, $viewFileInfo.InferredTypeName
                $scriptBlock = $if.Value
                $typeName = @(foreach ($attr in $ScriptBlock.Attributes) { # check the attributes.
                    if ($attr -is [Management.Automation.PSTypeNameAttribute]) { # A typename can come from the PSTypeName attribute
                        $attr.PSTypeName
                    }
                    if ($attr -is [Management.Automation.OutputTypeAttribute]) { # or the [OutputType] attribute.
                        foreach ($t in $attr.Type) {
                            $t.Name
                        }
                    }
                }) | Select-Object -Unique

                # Infer the type name from the file name.
                $inferredTypeName = $if.Key -replace '\.(format|type|view)\.ps1'


                if (-not $typeName) { # If no typename has been determined by now,
                    $typeName = $inferredTypeName # use the inferred type name.
                }

                if ($typeName -ne $inferredTypeName) { # If the typename is not the inferred type name,
                    # the last item before . will denote a known condition.
                    $pluginName = @($inferredTypeName -split '\.')[-1]
                }





                if (-not $formatterByTypeName[$typeName]) {
                    $formatterByTypeName[$typeName] = @()
                }
                $formatterByTypeName[$typeName] += $if
            } elseif ($if.Value -is [xml]) {
                $if.Value
            }
        }

        foreach ($formatterGroup in $formatterByTypeName.GetEnumerator()) {
            foreach ($fileNameAndScriptBlock in $formatterGroup.Value) {
                $fileName, $scriptBlock = $fileNameAndScriptBlock.Key, $fileNameAndScriptBlock.Value
                if (-not $scriptBlock)  {continue }
                $usesEzOutCommands = $scriptBlock.Ast.FindAll({param($ast)
                    $ast -is [Management.Automation.Language.CommandAst] -and $ezOutCommands -contains $ast.CommandElements[0].Value
                }, $true) | & {
                    begin {
                        $ezOutCmds = [Ordered]@{}
                    }
                    process {
                        $ezOutCmds[$_.CommandElements[0].Value] = $ExecutionContext.SessionState.InvokeCommand.GetCommand($_.CommandElements[0].Value, 'Function,Alias')
                    }
                    end {
                        $ezOutCmds
                    }
                }

                $formatParams = $null
                if ($usesEzOutCommands.Count) { # What commands are used dictate how the formatter will be created.
                    if (@($usesEzOutCommands.Keys)[0] -eq 'Write-FormatViewExpression') {
                        $formatParams = @{
                            Action = [ScriptBlock]::Create($scriptBlock.ToString().Substring($scriptBlock.Ast.ParamBlock.Extent.EndOffset))
                            TypeName = $typeName
                        }
                    } else {
                        $toUnset=
                            @(foreach ($ezOutCmd in $ezOutCommands.GetEnumerator()) {
                                if ($ezOutCmd.Value.Parameters.TypeName) {
                                    $defaultValueName = "$($ezOutCmd.Key):TypeName"
                                    $Global:PSDefaultParameterValues[$defaultValueName] = $typeName
                                    $defaultValueName
                                }
                            })
                        & $scriptBlock
                        foreach ($unset in $toUnset) {
                            $Global:PSDefaultParameterValues.Remove($unset)
                        }
                    }
                } else {
                    $formatParams = @{
                        Action = [ScriptBlock]::Create($scriptBlock.ToString().Substring($scriptBlock.Ast.ParamBlock.Extent.EndOffset))
                        TypeName = $typeName
                    }
                }

                if ($formatParams) {
                    Write-FormatView @formatParams
                }
            }
        }

        return
    }
}