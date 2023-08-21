function Write-FormatListView
{
    <#
    .Synopsis
        Writes a view for Format-List
    .Description
        Writes the XML for a PowerShell Format ListControl
    .Link
        Write-FormatView
    .Example
        Write-FormatListView -Property N
    #>
    param(
    # The list of properties to display.
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [String[]]$Property,

    # If set, will rename the properties in the table.
    # The oldname is the name of the old property, and value is either the new header
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('RenamedProperty', 'RenameProperty')]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [string]) {
                throw "All keys and values in the property rename map must be strings"
            }
        }
        return $true
    })]
    [Collections.IDictionary]$AliasProperty,

    # If set, will create a number of virtual properties within a table
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [ScriptBlock]) {
                throw "May only contain property names and script blocks"
            }
        }
        return $true
    })]
    [Collections.IDictionary]$VirtualProperty = @{},

    # If set, will be used to format the value of a property.
    [Parameter(Position=4,ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [string]) {
                throw "The FormatProperty parameter must contain only strings"
            }
        }
        return $true
    })]
    [Collections.IDictionary]$FormatProperty,

    # If provided, will conditionally color the property.
    # This will add colorization in the hosts that support it, and act normally in hosts that do not.
    # The key is the name of the property.  The value is a script block that may return one or two colors as strings.
    # The color strings may be ANSI escape codes or two hexadecimal colors (the foreground color and the background color)
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [ScriptBlock]) {
                throw "May only contain property names and script blocks"
            }
        }
        return $true
    })]
    [Alias('ColourProperty')]
    [Collections.IDictionary]$ColorProperty,

    # If provided, will use $psStyle to style the property.
    # # This will add colorization in the hosts that support it, and act normally in hosts that do not.
    # The key is the name of the property.  The value is a script block that may return one or more $psStyle property names.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Collections.IDictionary]$StyleProperty,

    # If provided, will only display a property if the condition is met.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [ScriptBlock]) {
                throw "May only contain property names and script blocks"
            }
        }
        return $true
    })]
    [Collections.IDictionary]$ConditionalProperty,

    # If provided, the view will only be used if the the typename includes this value.
    # This is distinct from the overall typename, and can be used to have different views for different inherited objects.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $ViewTypeName,

    # If provided, the view will only be used if the the typename is in a SelectionSet.
    # This is distinct from the overall typename, and can be used to have different views for different inherited objects.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $ViewSelectionSet,

    # If provided, will use this entire view if this condition returns a value.
    # More than one view must be provided via the pipeline for this to work,
    # and at least one of these views must not havea condition.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ScriptBlock]
    $ViewCondition
    )

    begin {
        $listEntries = @()

        filter EmbedColorValue {
            if ($_ -is [scriptblock]) { "`$(`$__ = `$_;. {$($_)};`$_ = `$__))"}
            else { "'$($_)'" }
        }
    }

    process {
        $listItems =
            @(for ($i =0; $i -lt $property.Count; $i++) {
                $p = $property[$i]

                $format =
                    if ($FormatProperty.$p) {
                        "<FormatString>$($FormatProperty.$p)</FormatString>"
                    } else { '' }


                if ($ColorProperty.$p -or $StyleProperty.$p) {
                    $existingScript =
                        if ($VirtualProperty.$p) {
                            $VirtualProperty.$p
                        }
                        elseif ($AliasProperty.$p) {
                            "`$_.'$($AliasProperty.$p.Replace("'","''"))'"
                        } else {
                            "`$_.'$($p.Replace("'","''"))'"
                        }

                    $interpretCellStyle =
                        if ($ColorRow -or $ColorProperty.$p) {
                            {
                            if ($CellColorValue -and $CellColorValue -is [string]) {
                                $CellColorValue = Format-RichText -NoClear -ForegroundColor $CellColorValue
                            } elseif (`$CellColorValue -is [Collections.IDictionary]) {
                                $CellColorValue = Format-RichText -NoClear @CellColorValue
                            }
                            }
                        }
                        elseif ($StyleRow -or $StyleProperty.$p) {
                            {
                            $CellColorValue = if ($psStyle) {
                                @(foreach ($styleProp in $CellColorValue) {
                                    if ($styleProp -match '^\$') {
                                        $ExecutionContext.SessionState.InvokeCommand.InvokeScript($styleProp)
                                    }
                                    elseif ($styleProp -match '\.') {
                                        $targetObject = $psStyle
                                        foreach ($dotProperty in $styleProp -split '(?<!\.)\.') {
                                            if ($targetObject.Item -is [Management.Automation.PSMethodInfo] -or 
                                                $targetObject -is [Collections.IDictionary]) {
                                                $targetObject = $targetObject[$dotProperty]
                                            } else {
                                                $targetObject = $targetObject.$dotProperty
                                            }
                                        }
                                        if ($targetObject) {
                                            $targetObject
                                        }
                                    }
                                    else {
                                        $psStyle.$styleProp
                                    }
                                }) -join ''
                            }
                            }
                        }

                    $ColorizerInfo = if ($ColorProperty.$p) {
                        $ColorProperty.$p | EmbedColorValue
                        
                    }
                    elseif ($StyleProperty.$p) {
                        $StyleProperty.$p | EmbedColorValue                        
                    }

                    $cellResetScript = 
                        if ($ColorRow -or $ColorProperty.$p) {
                            'Format-RichText'                        
                        }
                        elseif ($StyleRow -or $StyleProperty.$p) {
                            '$psStyle.Reset'
                        }

                    $colorizedScript =
                        "                        
                        `$CellColorValue = $ColorizerInfo
                        $InterpretCellStyle                        
                        `$output = . {$existingScript}
                        @(`$CellColorValue; `$output; $cellResetScript) -join ''
                        "
                    
                    
                    $VirtualProperty.$p = $colorizedScript
                }
                <#
                if ($ColorProperty.$p) {
                    $existingScript =
                        if ($VirtualProperty.$p) {
                            $VirtualProperty.$p
                        }
                        elseif ($AliasProperty.$p) {
                            "`$_.'$($AliasProperty.$p.Replace("'","''"))'"
                        } else {
                            "`$_.'$($p.Replace("'","''"))'"
                        }
                    $colorizedScript = "
                `$__ = `$_
                `$ci = . {$($ColorProperty.$p)}
                `$_ = `$__
                if (`$ci -is [string]) {
                    `$ci = Format-RichText -NoClear -ForegroundColor `$ci
                } else {                    
                    `$ci = Format-RichText -NoClear @ci
                }
                `$output = . {" + $existingScript + '}
                @($ci; $output; Format-RichText) -join ""
                '
                    $VirtualProperty.$p = $colorizedScript
                }
                #>

                if ($ColorProperty.$p) {
                    "<!-- {ConditionalColor:`"$([Security.SecurityElement]::Escape($ColorProperty.$p))`"}-->"
                }
                if ($StyleProperty.$p) {
                    "<!-- {ConditionalStyle:`"$([Security.SecurityElement]::Escape($StyleProperty.$p))`"}-->"
                }
                $propCondition = if ($ConditionalProperty.$p) {
                    "<ItemSelectionCondition><ScriptBlock>$([Security.SecurityElement]::Escape($ConditionalProperty.$p))</ScriptBlock></ItemSelectionCondition>"
                }
                $label = ""
                # If there was an alias defined for this property, use it
                if ($AliasProperty.$p -or $VirtualProperty.$p) {
                    $label = "<Label>$p</Label>"
                    if ($VirtualProperty.$p) {
                        "<ListItem>$propCondition $label<ScriptBlock>$([Security.SecurityElement]::Escape($VirtualProperty.$p))</ScriptBlock>$format</ListItem>"
                    } else {
                        "<ListItem>$propCondition $label<PropertyName>$($AliasProperty.$p)</PropertyName>$Format</ListItem>"
                    }
                } else {
                    "<ListItem>$propCondition <PropertyName>$p</PropertyName>$Format</ListItem>"
                }
            })

        $listEntries += @(
            "<ListEntry>"
            if ($ViewTypeName -or $ViewSelectionSet) {
                "<EntrySelectedBy>"
                    if ($ViewCondition) {
                        "<SelectionCondition>"
                    }
                    if ($ViewTypeName) {
                        "<TypeName>$([Security.SecurityElement]::Escape($ViewTypeName))</TypeName>"
                    } else {
                        "<SelectionSetName>$([Security.SecurityElement]::Escape($ViewSelectionSet))</SelectionSetName>"
                    }
                    if ($viewCondition) {
                        "<ScriptBlock>$([Security.SecurityElement]::Escape($viewCondition))</ScriptBlock></SelectionCondition>"
                    }
                "</EntrySelectedBy>"
            }
            "<ListItems>"
            $listitems
            "</ListItems></ListEntry>"
        ) -join ''
    }


    end {
        $thelistControl= @(
            '<ListControl>'
            '<ListEntries>'
            $listEntries
            '</ListEntries>'
            '</ListControl>'
        ) -join ''

        $xml=[xml]$thelistControl
        if (-not $xml) { return }
        $xOut=[IO.StringWriter]::new()
        $xml.Save($xOut)
        "$xOut".Substring('<?xml version="1.0" encoding="utf-16"?>'.Length + [Environment]::NewLine.Length)
        $xOut.Dispose()
    }
}