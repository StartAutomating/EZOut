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

    # If provided, will align columnns in a markdown table.    
    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateSet("Left","Right","Center", "")]
    [string[]]
    $MarkdownTableAlignment,

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

    # If set, will create an image link.  The -Inputobject will be used as the link content.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $ImageLink,

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
            if ($ImageLink) {
                "![$in]($imageLink)"
            } elseif ($link) {
                "[$in]($link)"
            } else {
                "$in"
            }
        }

        $markdownLines = @()
    }

    process {
        
        if ($ScriptBlock -or $inputObject -is [scriptblock]) {  # If a -ScriptBlock was provided
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
                    $(
                        $codeContent = $(if ($ScriptBlock) { "$scriptBlock" } else { $inputObject | LinkInput})  # then the -ScriptBlock or -InputObject
                        [Web.HttpUtility]::HtmlEncode($codeContent)
                    ) +
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
            $markdownLines += (">" * $BlockQuoteDepth ) + ' ' + (
                "$inputObject" -split '(?>\r\n|\n)' -join (
                    [Environment]::NewLine + (">" * $BlockQuoteDepth) + ' '
                )
            )
        }
        # Otherwise, we have to determine if -InputObject should be a -MarkdownTable or a -MarkdownParagraph.
        else
        {
            # If the input is a primitive type or a string, it should be a markdown paragraph
            if (($inputObject.GetType -and $inputObject.GetType().IsPrimitive) -or 
                $inputObject -is [string]) {
                $MarkdownParagraph = $true
            }
            # If it is a dictionary, it should be a markdown table.
            elseif ($inputObject -is [Collections.IDictionary]) 
            {
                $MarkdownTable = $true
            }
            # If the input is an array, apply the same logic:
            elseif ($inputObject -is [Object[]] -or $InputObject -is [PSObject[]]) {
                $allPrimitives = 1
                # if the array was all primitives or strings                
                foreach ($in in $InputObject) {
                    $allPrimitives = $allPrimitives -band (
                        ($in.GetType -and $in.GetType().IsPrimitive) -or $in -is [string]
                    )
                }
                if ($allPrimitives) { # output as a paragraph.
                    $MarkdownParagraph = $true
                } else {
                    $MarkdownTable = $true
                }
            }
            # If we're still not sure, output as a table.                     
            else {
                $MarkdownTable = $true
            }
        }

        if ($MarkdownParagraph) {
            # If we're outputting as a paragraph, add the input and link it if needed.
            $markdownLines += $inputObject | LinkInput
        } elseif ($MarkdownTable) {
            # If we're rendering a table, we need to go row-by-row.
            foreach ($in in $InputObject) {
                $propertyList = @(
                    # we first need to get a list of properties.
                    # If there was a -Property parameter provided, use it.
                    if ($Property) {
                        foreach ($prop in $Property) {
                            if ($prop -is [string]) { # Strings in -Property should be taken as property names
                                $prop
                            } elseif ($prop.Name -and $prop.Expression -and $prop.Expression -is [scriptblock]) {
                                # and anything with a name and expression script block will run the expression script block.
                                $_ = $psItem = $in
                                @{name=$prop.Name;Value = . $prop.Expression}
                            }
                        }
                    } 
                    # Otherwise, if the input was a dictionary
                    elseif ($in -is [Collections.IDictionary]) 
                    {
                        foreach ($k in $in.Keys) { # take all keys from the dictionary
                            if ($MyInvocation.MyCommand.Parameters[$k]) { continue } # that are not parameters of this function.
                            $k
                        }                        
                    }
                    # Otherwise, walk over all properties on the object
                    else {
                        foreach ($psProp in $In.psobject.properties) {
                            # and skip any properties that are parameters of this function.
                            if ($psProp.Name -notin $MyInvocation.MyCommand.Parameters.Keys) {
                                $psProp
                            }
                        }
                    }
                )

                # If we're rendering the first row of a table
                if ($IsFirst) {
                    # Create the header
                    $markdownLines +=
                        '|' + (@(foreach ($prop in $propertyList) {
                            if ($prop -is [string]) {
                                $prop
                            } else {
                                $prop.Name
                            }
                        }) -replace ([Environment]::newline), '<br/>' -replace '\|', '`|' -join '|') + '|'
                    # Then create the alignment row.
                    $markdownLines +=
                        '|' + $(
                            $columnNumber =0 
                            @(
                                foreach ($prop in $propertyList) {
                                    $colLength = 
                                        if ($prop -is [string]) {
                                            $prop.Length
                                        } else {
                                            $prop.Name.Length
                                        }
                                    if ($MarkdownTableAlignment) {
                                        if ($MarkdownTableAlignment[$columnNumber] -eq 'Left') {
                                            ':' + ("-" * ([Math]::Max($colLength,2) - 1))
                                        }
                                        elseif ($MarkdownTableAlignment[$columnNumber] -eq 'Right') {
                                            ("-" * ([Math]::Max($colLength,2) - 1)) + ':'
                                        }
                                        elseif ($MarkdownTableAlignment[$columnNumber] -eq 'Center') {
                                            ':' + ("-" * ([Math]::max($colLength, 3) - 2)) + ':'
                                        } else {
                                            "-" * $colLength
                                        }
                                    } else {
                                        "-" * $colLength
                                    }
                                    
                                    $columnNumber++
                                }
                            ) -replace ([Environment]::newline), '<br/>' -replace '\|', '`|' -join '|') + '|'                    
                    $IsFirst = $false
                }
                
                # Now we create the row for this object.

                $markdownLine = '|' + (
                    @(
                        foreach ($prop in $propertyList) {
                            if ($prop -is [string]) {
                                $in.$prop | LinkInput
                            } else {
                                $prop.Value | LinkInput
                            }
                        }
                    ) -replace ([Environment]::newline), '<br/>' -replace '\|', '`|' -join '|') + '|'

                $markdownLines += $markdownLine
            }                                    
        }

            
        if (  # There are a few combinations of parameters that make us want to write the -InputObject as a paragraph:
            ($ScriptBlock -and $inputObject) -or # * If -ScriptBlock and -InputObject were both provided.
            ($Heading -and $inputObject)         # * if -Heading and -InputObject were both provided
        ) {
            $markdownLines += $InputObject | LinkInput
        }


        # If we're going to render a horizontal rule (and -MarkdownTable has not been set)
        if ($HorizontalRule -and -not $MarkdownTable) {
            # add the horizontal rule at the end.
            if ($host.UI.RawUI.BufferSize.Width) {                
                $markdownLines += (([string]$HorizontalRuleCharacter) * ($Host.UI.RawUI.BufferSize.Width - 1))
            } else {
                $markdownLines += "---"
            }                        
        }
    }

    end {
        # Now we need to make one last pass to normalize tables
        if ($markdownLines -match '^\|') { # (that is, if we have tables to normalize).
            $maxColumnSize  = @{} # To normalize the table, we need to track the maximum size per column
            foreach ($ml in $markdownLines) {
                if ($ml -match '\^|') {
                    $columnCount = 0
                    foreach ($tablePart in $ml -split '\|' -ne '') {
                        if ((-not $maxColumnSize[$columnCount]) -or $maxColumnSize[$columnCount] -lt $tablePart.Length) {
                            $maxColumnSize[$columnCount] = [Math]::Max($tablePart.Length, 2)
                        }
                        $columnCount++
                    }
                }
            }
            # One we know the maximum size per column, walk over each line
            $markdownLines = @(foreach ($ml in $markdownLines) {
                if ($ml -match '\^|') {
                    $columnCount = 0
                    # Recreate the line with the right amount of padding.
                    '|' + (@(foreach ($tablePart in $ml -split '\|' -ne '') {
                        if ($tablePart -match '^[:\-]+$') {
                            if ($tablePart -match '^\:-{0,}\:$') { # If it's an alignment column, make sure to keep the alignment.
                                if ($maxColumnSize[$columnCount] -gt 2) {
                                    ':' + ('-' * ($maxColumnSize[$columnCount] - 2)) + ':'
                                } else {
                                    '::'
                                }
                            }
                            elseif ($tablePart -match '\:$') {
                                $tablePart.PadLeft($maxColumnSize[$columnCount], '-')
                            } 
                            elseif ($tablePart -match '^\:') {
                                $tablePart.PadRight($maxColumnSize[$columnCount], '-')
                            }
                            else {
                                $tablePart.PadRight($maxColumnSize[$columnCount], '-')
                            }
                        } else {
                            $tablePart.PadRight($maxColumnSize[$columnCount], ' ')
                        }
                        $columnCount++                                            
                    }) -join '|') + '|'
                } else {
                    $ml
                }
            })
        }
        $markdownLines -join [Environment]::NewLine        
    }
}
