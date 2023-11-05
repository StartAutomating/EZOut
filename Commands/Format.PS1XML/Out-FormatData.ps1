function Out-FormatData {
    <#
    .Synopsis
        Takes a series of format views and format actions and outputs a format data XML
    .Description
        A Detailed Description of what the command does
    .Example
        # Create a quick view for any XML element.
        # Piping it into Out-FormatData will make one or more format views into a full format XML file
        # Piping the output of that into Add-FormatData will create a temporary module to hold the formatting data
        # There's also a Remove-FormatData and
        Write-FormatView -TypeName "System.Xml.XmlNode" -Wrap -Property "Xml" -VirtualProperty @{
            "Xml" = {
                $strWrite = New-Object IO.StringWriter
                ([xml]$_.Outerxml).Save($strWrite)
                "$strWrite"
            }
        } |
            Out-FormatData
    #>
    [OutputType([string])]
    param(
    # The Format XML Document.  The XML document can be supplied directly,
    # but it's easier to use Write-FormatView to create it
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
    [ValidateScript({
        if ((-not $_.View) -and (-not $_.Control) -and (-not $_.SelectionSet)) {
            throw "The root of a format XML most contain either a View or a Control element"
        }
        return $true
    })]
    [Xml]
    $FormatXml,
    # The name of the module the format.ps1xml applies to.
    # This is required if you are using colors.
    # This is required if you use any dynamic parts (named script blocks stored a /Parts) directory.
    [string]
    $ModuleName = 'EZOut',
    
    
    # The output path.
    # This can be a string or a dictionary.
    # If it is a dictionary, the keys must a be a `[string]` or `[regex]` defining a pattern, and the value will be the path.
    [ValidateScript({
    $validTypeList = [System.String],[System.Collections.IDictionary]
    $thisType = $_.GetType()
    $IsTypeOk =
        $(@( foreach ($validType in $validTypeList) {
            if ($_ -as $validType) {
                $true;break
            }
        }))
    if (-not $isTypeOk) {
        throw "Unexpected type '$(@($thisType)[0])'.  Must be 'string','System.Collections.IDictionary'."
    }
    return $true
    })]
        
    [PSObject]
    $OutputPath
    )
    begin {
       
$Aspect = {
                                                param($ast)
                                
                                                if ($ast -is [Management.Automation.Language.CommandAst]) {
                                                    $ast
                                                }
                                            }
 $views = ""
        $controls = ""
        $selectionSets = ""
        
        function findUsedParts {
                            param(
                                [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
                                [Alias('InnerText','ScriptBlock','ScriptContents')]
                                [string]$InScript,
                                
                                [PSModuleInfo[]]
                                $FromModule = @(Get-Module),
                                
                                # If set, will look for a part globally if it does not find in any of the modules.
                                [switch]
                                $AllowGlobal
                                )
                                
                                begin {
                                    if (-not $script:LookedUpCommands) {
                                        $script:LookedUpCommands = @{}
                                    }
                                    if (-not $script:CommandModuleLookup) {
                                        $script:CommandModuleLookup = @{}
                                    }
                                    $GetVariableValue = {
                                        param($name)
                                        $ExecutionContext.SessionState.PSVariable.Get($name).Value
                                    }            
                                }
                                
                                    process {
                                        $in = $_
                                
                                        $inScriptBlock = try { [scriptblock]::Create($InScript) } catch { $null }
                                
                                        if ($inScriptBlock.Ast) {
                                            $cmdRefs = @($inScriptBlock.Ast.FindAll($Aspect, $true))
                                
                                            foreach ($cmd in $cmdRefs) {
                                                $variableName = 
                                                    if ($cmd.CommandElements[0].VariablePath) {
                                                        "$($cmd.CommandElements[0].VariablePath)"
                                                    } else { '' }
                                                $commandName =
                                                    if ($cmd.CommandElements[0].Value) {
                                                        $cmd.CommandElements[0].Value
                                                    }
                                
                                                if (-not ($variableName -or $commandName)) { continue }
                                                $foundCommand = 
                                                    foreach ($module in $FromModule) {
                                                        $foundIt = 
                                                            if ($variableName) {
                                                                & $module $GetVariableValue $variableName
                                                            } elseif ($commandName) {
                                                                $script:CommandModuleLookup["$commandName"] = $module
                                                                $module.ExportedCommands[$commandName]
                                                            }
                                                        if ($foundIt -and $variableName) {
                                                            $script:CommandModuleLookup[$variableName] = $module
                                                            if ($foundIt -is [ScriptBlock]) {
                                                                $PSBoundParameters.InScript = "$foundIt"
                                                                if ("$foundIt") {
                                                                    & $MyInvocation.MyCommand.ScriptBlock @PSBoundParameters
                                                                }
                                                            }
                                                            $foundIt; break
                                                        } elseif ($foundIt -and $commandName) {
                                                            $script:CommandModuleLookup[$commandName] = $module
                                                            $foundIt
                                                        }
                                                    }
                                
                                                if (-not $foundCommand -and $AllowGlobal) {
                                                    $foundCommand = & $getVariableValue $variableName
                                                }
                                                if ($variableName) {
                                                    $script:LookedUpCommands["$variableName"] = $foundCommand
                                                    $PartName = "$variableName"
                                                } elseif ($commandName) {
                                                    $script:LookedUpCommands["& $commandName"]  = 
                                                        if ($foundCommand.ScriptBlock) {
                                                            $foundCommand.ScriptBlock
                                                        } 
                                                        elseif ($foundCommand.ResolvedCommand.ScriptBlock) {
                                                            $foundCommand.ResolvedCommand.ScriptBlock
                                                        }
                                                        else {
                                                            $isOk = $false
                                                        }
                                                        $PartName = "& $commandName"
                                
                                                    $isOk =
                                                        foreach ($attr in $foundCommand.ScriptBlock.Attributes) {
                                                            if ($attr -is [Management.Automation.CmdletAttribute]){
                                                                $extensionCommandName = (
                                                                    ($attr.VerbName -replace '\s') + '-' + ($attr.NounName -replace '\s')
                                                                ) -replace '^\-' -replace '\-$'
                                                                if ('Format-Object' -match $extensionCommandName) {
                                                                    $true
                                                                    break
                                                                }
                                                            }
                                                        }
                                
                                                    if (-not $isOk) { continue }
                                                }
                                
                                                
                                                if ($script:LookedUpCommands[$partName] -and $script:LookedUpCommands[$partName] -isnot [ScriptBlock]) {
                                                    continue 
                                                }
                                                [PSCustomObject][Ordered]@{
                                                    Name = $PartName
                                                    CommandName = $commandName
                                                    VariableName = $variableName
                                                    ScriptBlock = $script:LookedUpCommands[$PartName]
                                                    Module = $script:CommandModuleLookup[$PartName]                    
                                                    FindInput = $in
                                                }                
                                            }
                                        }                                        
                                }
                        
                
        }
        filter ReplaceParts {
                            if ($DebugPreference -ne 'silentlyContinue') {
                                $in = $_
                                if ($in.InnerText) { return $in.InnerText}
                                else { return $in }
                            }
                            $inScriptBlock = try { [scriptblock]::Create($_) } catch { $null }
                            $inScriptString = "$inScriptBlock"
                            $cmdRefs = @($inScriptBlock.Ast.FindAll($Aspect, $true))
                            $replacements = @()
                            foreach ($cmd in $cmdRefs) {
                                $partName = 
                                    if ($cmd.CommandElements[0].VariablePath) {
                                        "$($cmd.CommandElements[0].VariablePath)"
                                    } elseif ($cmd.CommandElements[0].Value) {
                                        "& $($cmd.CommandElements[0].Value)"
                                    } else  { ''}
                                
                                foreach ($part in $foundParts) {
                                    if ("$($part.Name)" -eq $partName) {
                                        $replacements += @{
                                            Ast = $cmd.CommandElements[0]
                                            ReplacementText = if ($newPartNames.$partName) { $newPartNames.$partName} else {$partName}
                                        }
                                        break
                                    }
                                }
                            }
                            $stringBuilder = [Text.StringBuilder]::new()
                            $stringIndex   =0            
                            $null = for ($rc = 0; $rc -lt $replacements.Length; $rc++) {
                                if ($replacements[$rc].Ast.Extent.StartOffset -gt $stringIndex) {
                                    $stringBuilder.Append($inScriptString.Substring($stringIndex, $replacements[$rc].Ast.Extent.StartOffset - $stringIndex))
                                }
                                $stringBuilder.Append($replacements[$rc].ReplacementText)
                                $stringIndex = $replacements[$rc].Ast.extent.Endoffset
                            }
                            $null = $stringBuilder.Append($inScriptString.Substring($stringIndex))
                            "$stringBuilder"
                        
                
        }
        $importFormatParts = {
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
            
        }
    }
    process {
        if ($FormatXml.View) {
            $views += "<View>$($FormatXml.View.InnerXml)</View>"
        } elseif ($FormatXml.Control) {
            $controls += "<Control>$($FormatXml.Control.InnerXml)</Control>"
        } elseif ($FormatXml.SelectionSet) {
            $selectionSets += "<SelectionSet>$($FormatXml.SelectionSet.InnerXml)</SelectionSet>"
        }
    }
    end {
        $newPartNames = @{}
        $configuration = "
        <!-- Generated with EZOut $($MyInvocation.MyCommand.Module.Version): Install-Module EZOut or https://github.com/StartAutomating/EZOut -->
        <Configuration>
        "
        if ($selectionSets) {
            $configuration += "<SelectionSets>$selectionSets</SelectionSets>"
        }
        if ($Controls) {
            $Configuration+="<Controls>$Controls</Controls>"
        }
        if ($Views) {
            $Configuration+="<ViewDefinitions>$Views</ViewDefinitions>"
        }
        $configuration += "</Configuration>"
        $configurationXml = [xml]$configuration
        if (-not $configurationXml) { return }
        
        # Now we need to go looking parts used within <ScriptBlock> elements.
        # Before we do, we need to determine where to look.
        if (-not $PSBoundParameters.ContainsKey('ModuleName')) # If no -ModuleName was provided,
        {
            $callStackPeek = @(Get-PSCallStack) # use call stack peeking
            $callingFile = $callStackPeek[1].InvocationInfo.MyCommand.ScriptBlock.File # to find the calling file
            $fromEzOutFile =  $callingFile -like '*.ez*.ps1' # and see if it's an EZOut file
            if ($fromEzOutFile)
            {   # If it is,
                $moduleName = ($callingFile | Split-Path -Leaf) -replace '\.ezformat\.ps1','' # guess
                Write-Warning "No -ModuleName provided, guessing $ModuleName"  # then warn that we guessed.
            }
        }
        $modulesThatMayHaveParts =
            @(
            $theModule = $null
            $theModuleExtensions = @()
            $myModule = $MyInvocation.MyCommand.ScriptBlock.Module
            $myModuleExtensions = @()
            $loadedModules = Get-Module
            foreach ($lm in $loadedModules) {
                if ($moduleName -and $lm.Name -eq $moduleName) {
                    $theModule = $lm
                    foreach ($_ in $theModule.RequiredModules) {
                        if ($moduleName -and (
                            ($_.Name -eq $moduleName) -or
                            ($_.PrivateData.PSData.Tags -contains $ModuleName))
                        ) {
                            $theModuleExtensions += $lm
                        }
                    }
                }
                foreach ($_ in $lm.RequiredModules) {
                    if ($myModule -and (
                        ($_.Name -eq $myModule.Name) -or
                        ($_.PrivateData.PSData.Tags -contains $myModule.Name))
                    ) {
                        $myModuleExtensions += $lm
                    }
                }
            }
            $theModule
            $theModuleExtensions
            $myModule
            $myModuleExtensions
            ) | Select-Object -Unique
        $foundParts = # See if the XML refers to any parts
            @($configurationXml.SelectNodes("//ScriptBlock") | Where-Object InnerText) |
                    findUsedParts -FromModule $modulesThatMayHaveParts
        # If any parts are found, we'll need to embed them and bootstrap the loader
        if ($foundParts -and $DebugPreference -eq 'silentlyContinue') { 
            if (-not $moduleName) # To do this, we need a -ModuleName, so we if we still don't have one.
            {
                Write-Error "A -ModuleName must be provided to use advanced features" # error
                return # and return.
            }
            $alreadyEmbedded = @()
            $embedControls =
                @(foreach ($part in $foundParts) { # and embed each part in a comment
                    if ($alreadyEmbedded -contains $part.Name) { continue }
                    $partName =
                        if ($part.Name -match '\w+' -or $moduleName -match '\w+') {
                            "`${${ModuleName}_$($part.Name -replace '^[&\.] ')}"
                        } else {
                            "`$${ModuleName}_$($part.Name -replace '^[&\.] ')"
                        }
                    if ($partName -and $part.ScriptBlock -and $alreadyEmbedded -notcontains $partName) {
                        $newPartNames["$($part.Name)"]= if ($part.CommandName) { "& $partName" } else { "$partName"}
                        if (-not ($part.ScriptBlock -as [ScriptBLock[]])) {
                            continue
                        }                        
                        Write-FormatView -AsControl -Name "$partName" -Action $part.ScriptBlock -TypeName 'n/a'
                    }
                    $alreadyEmbedded += $part.Name
                })
            $controlsElement =
                if (-not $configurationXml.Configuration.Controls) {
                    $configurationXml.CreateNode([Xml.XmlNodeType]::Element,'Controls','')
                } else {
                    $configurationXml.Configuration.Controls
                }
            foreach ($ec in $embedControls) {
                $ecx = [xml]$ec
                $controlsElement.InnerXml += $ecx.Control.OuterXml
            }
            if (-not $configurationXml.Configuration.Controls) { # If we didn't already have controls
                $null = $configurationXml.Configuration.AppendChild($controlsElement) # add the <Controls> element
            } else {
                $foundParts = # Otherwise, we need to find our parts again, because the XML has changed
                    @($configurationXml.SelectNodes("//ScriptBlock")) | # and we want to rewrite the part references.
                        findUsedParts -FromModule $modulesThatMayHaveParts
            }
            $lastEntryNode = $null
            $replacedItIn = @()
            foreach ($fp in $foundParts) {
                if (-not $fp.ScriptBlock) {
                    continue
                }
                $newScriptText = @(
                    if ($lastEntryNode -ne $fp.FindInput.ParentNode.ParentNode.ParentNode) {
                        # If the grandparent node is a distinct <Entry>,
                        # we need to bootload the parts (because this is a potential entry point)
                        "`$moduleName = '$($ModuleName.Replace("'","''"))'"
                        "$ImportFormatParts"
                    }
                    if ($replacedItIn -notcontains $fp.FindInput) {
                        $fp.FindInput.InnerText | ReplaceParts
                        $replacedItIn += $fp.FindInput
                    } else {
                        $fp.FindInput.InnerText
                    }
                ) -join [Environment]::NewLine
                $lastEntryNode = $fp.FindInput.ParentNode.ParentNode.ParentNode
                $fp.FindInput.InnerText = $newScriptText
            }
        }
        if (-not $configurationXml) { return }
        
        if ($OutputPath) {
            $alreadyExportedTypeNames = @{}
            $allTypeNames = @()
            if ($outputPath -is [string]) {
                $createdOutputFile = New-Item -ItemType File -Path $OutputPath -Force
                if (-not $createdOutputFile) { return }
                $configurationXml.Save($createdOutputFile.FullName)
                Get-Item -LiteralPath $createdOutputFile.FullName                
            }
            else {                
                $fileOutputs = [Ordered]@{}  
                $viewsXml = "<Views>$views</Views>" -as [xml]
                if (-not $viewsXml) { return }
                :nextView foreach ($view in $viewsXml.Views.View) {                    
                    $viewTypeNames = @($view.ViewSelectedBy.TypeName)
                    if (($OutputPath -isnot [Collections.IDictionary])) { continue } 
                    foreach ($outPath in $OutputPath.GetEnumerator()) {
                        if ($alreadyExportedTypeNames[$viewTypeNames]) { 
                                    continue nextView                        
                                } 
                        if (($outPath.Key -isnot [regex] -and $outPath.Key -isnot [string])) { continue } 
                        if (($outPath.Key -is [string] -and -not ($viewTypeNames -like $outPath.Key))) { continue } 
                        if (($outPath.Key -is [Regex] -and -not ($viewTypeNames -match $outPath.Key))) { continue } 
                                                
                        if (-not $fileOutputs[$outPath.Value]) {
                            $fileOutputs[$outPath.Value] = @()
                        }
                        $fileOutputs[$outPath.Value] += $view
                        $alreadyExportedTypeNames[$viewTypeNames] = $kv.Value
                        continue nextView
                    }                                   
                }
                foreach ($fileOut in $fileOutputs.GetEnumerator()) {
                    $controlsInThisFile = [Ordered]@{}
                    
                    $fileViews = "
                    <ViewDefinitions>$(foreach ($view in $fileOut.Value) {
                        $customControlReferences = $view.SelectNodes(".//CustomControlName")
                        if (-not $customControlReferences) { continue }
                        $controlsXml = "<Controls>$Controls</Controls>" -as [xml]
                        foreach ($controlRef in $customControlReferences) {
                            $refName = $controlRef.InnerText.Trim()
                            if (-not $controlsInThisFile[$refName]) {
                                $controlsInThisFile[$refName] = $controlsXml.SelectSingleNode("./Controls/Control[Name='$refname']").OuterXml
                            }                                 
                        }
                        $view.OuterXml                        
                    })</ViewDefinitions>
                    "
                    $fileControls = if ($controlsInThisFile.Count) {
                        "<Controls>$(@($controlsInThisFile.Values))</Controls>"
                    } else { $null }
                    $fileXml = "
                    <!-- Generated with EZOut $($MyInvocation.MyCommand.Module.Version): Install-Module EZOut or https://github.com/StartAutomating/EZOut -->
                    <Configuration>${FileViews}${FileControls}</Configuration>
                    " -as [xml]
                    if (-not $fileXml) { continue }
                    $filePath = $fileOut.Key
                    $createdOutputFile = New-Item -ItemType File -Path $filePath -Force
                    if (-not $createdOutputFile) { continue }
                    $fileXml.Save($createdOutputFile.FullName)
                    Get-Item -LiteralPath $createdOutputFile.FullName
                }                
            }            
        } else {
            $strWrite = [IO.StringWriter]::new()
            $configurationXml.Save($strWrite)
            return "$strWrite"
        }
        
    }
}


