function Out-FormatData
{
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
    $ModuleName = 'EZOut')

    begin {
        $views = ""
        $controls = ""
        $selectionSets = ""

        #region <-- ?<PowerShell_Invoke_Variable>
        $PowerShell_Invoke_Variable = [Regex]::new(@'
(?<![\w\)`])                                            # If the text before the invoke is a word, closing paranthesis, or backtick, do not match
(?<CallOperator>[\.\&])                                 # Match the <CallOperator> (either a . or a &)
\s{0,}                                                  # Followed by Optional Whitespace
\$                                                      # Followed by a Dollar Sign
((?<Variable>\w+)                                       # Followed by a <Variable> (any number of repeated word characters)
|                                                       # Or a <Variable> enclosed in curly brackets
(?:(?<!`){(?<Variable>(?:.|\s)*?(?=\z|(?<!`)}))(?<!`)}) # using backtick as an escape
)
'@, 'IgnoreCase,IgnorePatternWhitespace', '00:00:05')
        #endregion <-- ?<PowerShell_Invoke_Variable>

        $PowerShell_Rename_Invoke = {
            param($match)
            $callOperator = $match.Groups["CallOperator"].Value

            return ($callOperator + ' ' + $(if ($newPartNames.($match.Groups["Variable"].Value)) {
                $newPartNames[$match.Groups["Variable"].Value]
            } else {
                '$' + $match.Groups["Variable"].Value
            })
        )
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
            @($configurationXml.SelectNodes("//ScriptBlock")) |
                    & $FindUsedParts -FromModule $modulesThatMayHaveParts

        if ($foundParts) { # If any parts are found, we'll need to embed them and bootstrap the loader

            if (-not $moduleName) # To do this, we need a -ModuleName, so we if we still don't have one.
            {
                Write-Error "A -ModuleName must be provided to use advanced features" # error
                return # and return.
            }

            $alreadyEmbedded = @()

            $newPartNames = @{}
            $embedControls =
                @(foreach ($part in $foundParts) { # and embed each part in a comment
                    if ($alreadyEmbedded -contains $part.Name) { continue }


                    $partName =
                        if ($part.Name -match '\w+' -or $moduleName -match '\w+') {
                            "`${${ModuleName}_$($part.Name)}"
                        } else {
                            "`$${ModuleName}_$($part.Name)"
                        }


                    if ($partName -and $part.ScriptBlock) {
                        $newPartNames[$part.Name]= $partName
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
                        & $FindUsedParts -FromModule $modulesThatMayHaveParts
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
                        $PowerShell_Invoke_Variable.Replace($fp.FindInput.InnerText, $PowerShell_Rename_Invoke)
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

        $strWrite = [IO.StringWriter]::new()
        $configurationXml.Save($strWrite)
        return "$strWrite"
    }
}
