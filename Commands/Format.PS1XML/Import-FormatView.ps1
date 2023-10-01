function Import-FormatView
{
    <#
    .Synopsis
        Imports a Format View
    .Description
        Imports a Format View defined in .format or .view .ps1 files
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

        $FormatFilePattern = '\.(?>format|type|view|control)\.ps1$'

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
            $inferredTypeName = $fileName -replace $FormatFilePattern

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
            # If the file is a [PipeScript](https://github.com/StartAutomating/PipeScript) source generator.
            if ($fi.Name -match '"\.ps1{0,1}\.(?<ext>[^.]+$)"') {
                continue # then skip it
                # (this can simplify development of complex formatting)
            }

            

            if ($fi.Extension -eq '.xml') {
                $innerFormat[$fi.Name] = [xml][IO.File]::ReadAllText($fi.FullName)
            } else {
                $scriptBlock = $ExecutionContext.SessionState.InvokeCommand.GetCommand($fi.FullName, 'ExternalScript').ScriptBlock                 
                
                if ($fi.Name -notmatch $FormatFilePattern) {
                    if (@($ScriptBlock.Attributes.PSTypeName)) {
                        $innerFormat[$fi.FullName] = $scriptBlock
                    }                                        
                } else {
                    $innerFormat[$fi.FullName] = $scriptBlock
                }
                
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

                


                if (-not $typeName) { # If no typename has been determined by now,
                    # Infer the type name from the file name.                    
                    $formatFileName = $if.Key | Split-Path -Leaf
                    if ($formatFileName -notmatch $FormatFilePattern) {
                        continue
                    }
                    $inferredTypeName = $formatFileName -replace $FormatFilePattern
                    
                    $typeName = $inferredTypeName # then use the inferred type name.
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
                        
                        $psTypeNameFile = $null
                        if ($scriptBlock.File) {
                            $psTypeNameFile = 
                                $scriptBlock.File | 
                                    Split-Path | 
                                    Get-ChildItem |
                                    Where-Object Name -Match '^(?:PS)?TypeNames{0,1}\.txt$' | 
                                    Select-Object -First 1
                            if ($psTypeNameFile) {
                                $global:ExecutionContext.SessionState.PSVariable.Set('PSTypeName', @(Get-Content $psTypeNameFile))
                            }
                        }

                        & $scriptBlock
                        foreach ($unset in $toUnset) {
                            $Global:PSDefaultParameterValues.Remove($unset)
                        }
                        if ($psTypeNameFile) {
                            $global:ExecutionContext.SessionState.PSVariable.Remove('PSTypeName')
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