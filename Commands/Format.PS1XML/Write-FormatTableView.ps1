function Write-FormatTableView
{
    <#
    .Synopsis
        Writes a view for Format-Table
    .Description
        Writes the XML for a PowerShell Format TableControl.
    .Example
        Write-FormatTableView -Property myFirstProperty,mySecondProperty -TypeName MyPropertyBag
    .Example
        Write-FormatTableView -Property "Friendly Property Name" -RenameProperty @{
            "Friendly Property Name" = 'SystemName'
        }
    .Example
        Write-FormatTableView -Property Name, Bio -Width 20 -Wrap
    .Example
        Write-FormatTableView -Property Number, IsEven, IsOdd -AutoSize -ColorRow {if ($_.N % 2) { "#ff0000"} else {"#0f0"} } -VirtualProperty @{
            IsEven = { -not ($_.N % 2)}
            IsOdd = { ($_.N % 2) -as [bool] }
        } -AliasProperty @{
            Number = 'N'
        }
    .Link
        Write-FormatView
    #>
    [OutputType([string])]
    param(
    # The list of properties to display.
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
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


    # If provided, will set the alignment used to display a given property.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or 'left', 'right', 'center' -notcontains $kv.Value) {
                throw 'The alignment property may only contain property names and the values: left, right, and center'
            }
        }
        return $true
    })]
    [Collections.IDictionary]$AlignProperty,

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

    # If provided, will colorize all rows in a table, according to the script block.
    # If the script block returns a value, it will be treated either as an ANSI escape sequence or up to two hexadecimal colors
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('ColourRow')]
    [ScriptBlock]$ColorRow,

    # If provided, will style all rows in a table, according to the script block.
    # If the script block returns a value, it will be treated as a value on $PSStyle.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ScriptBlock]$StyleRow,

    # If set, the table will be autosized.
    [switch]
    $AutoSize,

    # If set, the table headers will not be displayed.
    [Alias('HideTableHeaders','HideTableHeader')]
    [switch]
    $HideHeader,

    # The width of any the properties.  This parameter is optional, and cannot be used with -AutoSize.
    # A negative width is a right justified table.
    # A positive width is a left justified table
    # A width of 0 will not include an alignment hint.
    [ValidateRange(-100,100)]
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [int[]]$Width,

     # If wrap is set, then items in the table can span multiple lines
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [switch]$Wrap,

    # If provided, the table view will only be used if the the typename includes this value.
    # This is distinct from the overall typename, and can be used to have different table views for different inherited objects.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $ViewTypeName,

    # If provided, the table view will only be used if the the typename is in a SelectionSet.
    # This is distinct from the overall typename, and can be used to have different table views for different inherited objects.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $ViewSelectionSet,

    # If provided, will selectively display items.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ScriptBlock]
    $ViewCondition)

    begin {
        $rowEntries = @()

        filter EmbedColorValue {
            if ($_ -is [scriptblock]) { "`$(`$Script:_LastCellStyle = `$(`$__ = `$_;. {$($_)};`$_ = `$__);`$Script:_LastCellStyle)"}
            else { "`$(`$Script:_LastCellStyle ='$($_)';`$Script:_LastCellStyle)" }
        }
    }

    process {
        $tableHeader = ''
        $rowColumns =
            @(for ($i =0; $i -lt $property.Count; $i++) {
                $p = $property[$i]
                if ($Width -and $Width[$i]) {
                    if ($Width[$i] -lt 0) {
                        $widthTag = "<Width>$([Math]::Abs($Width[$i]))</Width>"
                        $alignment = "<Alignment>right</Alignment>"
                    } else {
                        $widthTag = "<Width>$([Math]::Abs($Width[$i]))</Width>"
                        $alignment = "<Alignment>left</Alignment>"
                    }
                } else {
                    $widthTag = ''
                }

                if ($AlignProperty.$p) {
                    $alignment = "<Alignment>$($AlignProperty.$p)</Alignment>"
                }

                $format =
                    if ($FormatProperty.$p) {
                        "<FormatString>$($FormatProperty.$p)</FormatString>"
                    } else { '' }


                if ($ColorProperty.$p -or $ColorRow -or $StyleProperty.$p -or $StyleRow) {
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
                                            if (
                                                ($targetObject.psobject.Members['Item'] -and 
                                                    ($targetObject.Item -is [Management.Automation.PSMethodInfo])
                                                ) -or 
                                                $targetObject -is [Collections.IDictionary]
                                            ) {
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

                    $ColorizerInfo = if ($ColorRow) {
                        if ($i -eq 0) {
                            $ColorRow | EmbedColorValue                            
                        } else {
                            '$Script:_LastCellStyle'
                        }                        
                    } elseif ($StyleRow) {
                        if ($i -eq 0) {
                            $styleRow | EmbedColorValue
                        } else {
                            '$Script:_LastCellStyle'
                        }                        
                    }
                    elseif ($ColorProperty.$p) {
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

                if ($ColorProperty.$p) {
                    "<!-- {ConditionalColor:`"$([Security.SecurityElement]::Escape($ColorProperty.$p))`"}-->"
                }
                if ($StyleProperty.$p) {
                    "<!-- {ConditionalStyle:`"$([Security.SecurityElement]::Escape($StyleProperty.$p))`"}-->"
                }
                $label = ""
                # If there was an alias defined for this property, use it
                if ($AliasProperty.$p -or $VirtualProperty.$p) {
                    $label = "<Label>$p</Label>"
                    if ($VirtualProperty.$p) {
                        "<TableColumnItem><ScriptBlock>$([Security.SecurityElement]::Escape($VirtualProperty.$p))</ScriptBlock>$format</TableColumnItem>"
                    } else {
                        "<TableColumnItem><PropertyName>$($AliasProperty.$p)</PropertyName>$Format</TableColumnItem>"
                    }
                } else {
                    "<TableColumnItem><PropertyName>$p</PropertyName>$Format</TableColumnItem>"
                }
                $TableHeader += "<TableColumnHeader>${Label}${alignment}${WidthTag}</TableColumnHeader>"
            })

        $rowEntries += @(
            if ($ColorRow) {
                "<!-- {ConditionalColor:`"$([Security.SecurityElement]::Escape($ColorRow))`"}-->"
            }
            "<TableRowEntry>"
            $(if ($Wrap) { "<Wrap/>" })
            if ($PSBoundParameters.ViewTypeName -or $PSBoundParameters.ViewSelectionSet) {
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
            "<TableColumnItems>"
            $rowColumns
            "</TableColumnItems></TableRowEntry>"
        ) -join ''
    }
    end {
        $theTableControl = @(
            '<TableControl>'
            if ($AutoSize) {'<AutoSize/>'}
            if ($HideHeader) {'<HideTableHeaders/>'}
            '<TableHeaders>'
            $tableHeader
            '</TableHeaders>'
            '<TableRowEntries>'
            $rowEntries
            '</TableRowEntries>'
            '</TableControl>'
        ) -join ''

        $xml=[xml]$theTableControl
        if (-not $xml) { return }
        $xOut=[IO.StringWriter]::new()
        $xml.Save($xOut)
        "$xOut".Substring('<?xml version="1.0" encoding="utf-16"?>'.Length + [Environment]::NewLine.Length)
        $xOut.Dispose()
    }
}
