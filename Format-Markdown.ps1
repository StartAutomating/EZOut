function Format-Markdown
{
    <#
    .SYNOPSIS
        Formats an object as Markdown
    .DESCRIPTION
        Formats an object as Markdown, with many options to work with
    .EXAMPLE
        Format-Markdown -ScriptBlock {
            Get-Process
        }
    .EXAMPLE
         1..6 | Format-Markdown  -HeadingSize { $_ }
    #>
    [Management.Automation.Cmdlet("Format","Object")]
    [ValidateScript({return $true})]
    param(
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [PSObject]
    $InputObject,
    
    # If set, will treat the -InputObject as a paragraph.
    # This is the default for strings, booleans, numbers, and other primitive types.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $MarkdownParagraph,

    # If set, will generate a markdown table.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $MarkdownTable,

    # An array of properties.  Providing this implies -MarkdownTable
    [Parameter(ValueFromPipelineByPropertyName)]
    [PSObject[]]
    $Property,

    # A heading.
    # If provided without -HeadingSize, -HeadingSize will default to 2.
    # If provided with -InputObject, -Heading will take priority.
    [Parameter(ValueFromPipelineByPropertyName)]    
    [string]
    $Heading,

    # The heading size (1-6)
    # If provided without -Heading, the -InputObject will be considered to be a heading.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateRange(1,6)]
    [int]
    $HeadingSize,

    # If set, will create a link.  The -InputObject will be used as the link content    
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Link,

    # If set, will generate a bullet point list.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('BulletpointList')]
    [switch]
    $BulletPoint,
    
    # If set, bullet or numbered list items will have a checkbox.
    # Each piped -InputObject will be an additional list item.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $Checkbox,

    # If set, bullet or numbered list items will be checked.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $Checked,

    # If set, will generate a numbered list.
    # Each piped -InputObject will be an additional list item.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $NumberedList,

    # If set, will generate a block quote.
    # Each line of the -InputObject will be block quoted.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $BlockQuote,

    # If set, will generate a block quote of a particular depth.
    # Each line of the -InputObject will be block quoted.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateRange(1,3)]
    [int]
    $BlockQuoteDepth,
        
    # If provided, will create a markdown numbered list with this particular item as the number.
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $Number,

    # If set, will generate a horizontal rule.  
    # If other parameters are provided, the horiztonal rule will be placed after.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $HorizontalRule,

    # If set, will output the -InputObject as a Markdown code block
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $Code,

    # If set, will output the -InputObject as a Markdown code block, with a given language
    # If the -InputObject is a ScriptBlock, -CodeLanguage will be set to PowerShell.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $CodeLanguage,

    # If provided, will output a script block as a Markdown code block.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ScriptBlock]
    $ScriptBlock
    )

    begin {
        $numberedListCounter = 0
        $IsFirst = $true
        filter LinkInput {
            $in = $_
            if ($Image -and $link) {
                "![$in]($link)"
            } elseif ($link) {
                "[$in]($link)"
            } else {
                "$in"
            }
        }

        $markdownLines = @()
    }

    process {
        
        if ($ScriptBlock) {  # If a -ScriptBlock was provided
            $CodeLanguage = 'PowerShell' # use PowerShell as a Code Language.
        }

        # If a -HeadingSize or a -Heading were provided, render a heading.
        if ($HeadingSize -or $Heading) 
        {  
            if (-not $HeadingSize) { $HeadingSize = 2} # If the -HeadingSize was not set, set it to 2.
            $headingContent = "$(if ($Heading) { $Heading} else { $inputObject | LinkInput})"
            $markdownLines += 
                if ($HeadingSize -eq 1) {                
                    $headingContent
                    '=' * [Math]::Max($headingContent.Length, 3)
                }
                elseif ($HeadingSize -eq 2) {
                    $headingContent
                    '-' * [Math]::Max($headingContent.Length, 3)
                }
                else  {
                    ("#"*$HeadingSize) + " $headingContent" # Output the -Heading or the -InputObject.
                }
        }
        # If -Code or -CodeLanguage was provided, render a Markdown code block.
        elseif ($Code -or $CodeLanguage)
        { 
            # If the -InputObject was a [ScriptBlock] or there is a -ScriptBlock 
            if ($InputObject -is [scriptblock] -or $ScriptBlock) {
                $CodeLanguage  = 'PowerShell' # set the code language to PowerShell.
            }
            $markdownLines += (
                '```' + # Start the code fence,
                    $(if ($CodeLanguage) { $CodeLanguage}) + # add the language,
                    [Environment]::newline + # then a newline,
                    $(if ($ScriptBlock) { "$scriptBlock" } else { $inputObject | LinkInput}) +  # then the -ScriptBlock or -InputObject
                    [Environment]::newline + # then a newline
                '```' # then close the code fence.
            )
        }
        # If -BulletPoint was passed, render a Bullet Point list.
        elseif ($BulletPoint) 
        { 
            $markdownLines += "*$(if ($Checkbox) { "[$(if ($Checked) {"x"} else {" "})]"}) $($inputObject | LinkInput)"
        }
        # If -NumberedList was passed, render a numbered list.
        elseif ($NumberedList -or $Number) 
        {
            $numberedListCounter++ # Increment the counter
            $markdownLines += "$(if ($number) { $number } else {$numberedListCounter}).$(if ($Checkbox) {" [$(if ($Checked) {"x"} else {" "})]"}) $($inputObject | LinkInput)"
        }
        elseif ($BlockQuote -or $BlockQuoteDepth) {
            if (-not $BlockQuoteDepth) { $BlockQuoteDepth = 1 }
            $markdownLines += (">" * $BlockQuoteDepth) + ' ' + (
                "$inputObject" -split '(?>\r\n|\n)' -join (
                    [Environment]::NewLine + (">" * $BlockQuoteDepth) + ' '
                )
            )
        }
        # Otherwise, we have to determine if -InputObject should be a -MarkdownTable or a -MarkdownParagraph.
        else
        {
            if (($inputObject.GetType -and $inputObject.GetType().IsPrimitive) -or 
                $inputObject -is [string]) {
                $MarkdownParagraph = $true
            }
            elseif ($inputObject -is [Collections.IDictionary]) {
                $MarkdownTable = $true
            }
            elseif ($inputObject -is [Object[]] -or $InputObject -is [PSObject[]]) {
                $allPrimitives = 1
                foreach ($in in $InputObject) {
                    $allPrimitives = $allPrimitives -band (
                        ($in.GetType -and $in.GetType().IsPrimitive) -or $in -is [string]
                    )
                }
                if ($allPrimitives) {
                    $MarkdownParagraph = $true
                }
            }                     
            else {
                $MarkdownTable = $true
            }
        }

        if ($MarkdownParagraph) {
            $inputObject | LinkInput
        } elseif ($MarkdownTable) {            
            foreach ($in in $InputObject) {
                $propertyList = @(
                    if ($Property) {
                        foreach ($prop in $Property) {
                            if ($prop -is [string]) {
                                $prop
                            } elseif ($prop.Name -and $prop.Expression -and $prop.Expression -is [scriptblock]) {
                                $_ = $psItem = $in
                                @{name=$prop.Name;Value = . $prop.Expression}
                            }
                        }
                    } elseif ($in -is [Collections.IDictionary]) {
                        foreach ($k in $in.Keys) {
                            if ($MyInvocation.MyCommand.Parameters[$k]) { continue }
                            $k
                        }                        
                    }
                    else {
                        foreach ($psProp in $In.psobject.properties) {
                            if ($psProp.Name -notin $MyInvocation.MyCommand.Parameters.Keys) {
                                $psProp
                            }
                        }
                    }
                )

                if ($IsFirst) {
                    $markdownLines +=
                        '|' + (@(foreach ($prop in $propertyList) {
                            if ($prop -is [string]) {
                                $prop
                            } else {
                                $prop.Name
                            }
                        }) -replace ([Environment]::newline), '<br/>' -replace '\|', '`|' -join '|') + '|'
                    $markdownLines +=
                        '|' + (@(foreach ($prop in $propertyList) {
                            if ($prop -is [string]) {
                                "-" * $prop.Length
                            } else {
                                "-" * $prop.Name.Length
                            }
                        }) -replace ([Environment]::newline), '<br/>' -replace '\|', '`|' -join '|') + '|'
                    $IsFirst = $false
                }
                
                $markdownLines += '|' + (@(foreach ($prop in $propertyList) {
                    if ($prop -is [string]) {
                        $in.$prop | LinkInput
                    } else {
                        $prop.Value | LinkInput
                    }
                }) -replace ([Environment]::newline), '<br/>' -replace '\|', '`|' -join '|') + '|'
            }                                    
        }

            
        if (  # There are a few combinations of parameters that make us want to write the -InputObject as a paragraph:
            ($ScriptBlock -and $inputObject) -or # * If -ScriptBlock and -InputObject were both provided.
            ($Heading -and $inputObject)         # * if -Heading and -InputObject were both provided
        ) {
            $markdownLines += $InputObject | LinkInput
        }


        if ($HorizontalRule -and -not $MarkdownTable) {
            if ($host.UI.RawUI.BufferSize.Width) {
                $markdownLines += (([string]$HorizontalRuleCharacter) * ($Host.UI.RawUI.BufferSize.Width - 1))
            } else {
                $markdownLines += "---"
            }                        
        }
    }

    end {
        if ($markdownLines -match '^\|') {
            $maxColumnSize  = @{}
            foreach ($ml in $markdownLines) {
                if ($ml -match '\^|') {
                    $partCount = 0
                    foreach ($tablePart in $ml -split '\|' -ne '') {
                        if ((-not $maxColumnSize[$partCount]) -or $maxColumnSize[$partCount] -lt $tablePart.Length) {
                            $maxColumnSize[$partCount] = $tablePart.Length
                        }
                        $partCount++
                    }
                }
            }
            $markdownLines = @(foreach ($ml in $markdownLines) {
                if ($ml -match '\^|') {
                    $partCount = 0
                    '|' + (@(foreach ($tablePart in $ml -split '\|' -ne '') {
                        if ($tablePart -match '^[:\-]+$') {
                            if ($tablePart -match '\:$') {
                                $tablePart.PadLeft($maxColumnSize[$partcount], '-')
                            } else {
                                $tablePart.PadRight($maxColumnSize[$partcount], '-')
                            }
                        } else {
                            $tablePart.PadRight($maxColumnSize[$partcount], ' ')
                        }
                        $partCount++                                            
                    }) -join '|') + '|'
                } else {
                    $ml
                }
            })
        }
        $markdownLines -join [Environment]::NewLine        
    }
}
