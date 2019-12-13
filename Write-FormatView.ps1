function Write-FormatView
{
    <#
    .Synopsis
        Creates a format XML that will be used to display a type.
    .Description
        Creates a format XML that will be used to display a type.

        Format XML is used by Windows PowerShell to determine how objects are displayed.

        Most items in PowerShell that come from built-in cmdlets make use of formatters in some
        way or another.  Write-FormatView simplifies the creation of formatting for a type.


        You can format information in three major ways in PowerShell:
            - As a table
            - As a list
            - As a custom action

        Write-FormatView supports displaying information in any of these ways.  This display
        will be applied to any information that would be displayed to the user (or piped into
        an Out- cmdlet) that has the typename you specify.  A typename can be anything you like,
        and it can be set in a short piece of PowerShell script:

            $object.psObject.Typenames.Clear()
            $null = $object.psObject.TypeNames.Add("MyTypeName").

        Since it is so simple to change the type names, it's equally simple to make your own way to
        display data, and to write functions that leverage the formatting system in PowerShell to help
        you write the information.  This can streamline your use of PowerShell, and open up many
        new possibilities.
    .Outputs
        [string]
    .Link
        Out-FormatData
    .Link
        Add-FormatData
    .Example
        Write-FormatView -TypeName "System.Xml.XmlNode" -Wrap -Property "Xml" -VirtualProperty @{
            "Xml" = {
                $strWrite = New-Object IO.StringWriter
                ([xml]$_.Outerxml).Save($strWrite)
                "$strWrite"
            }
        } |
            Out-FormatData |
            Add-FormatData

        [xml]"<a an='anattribute'><b d='attribute'><c /></b></a>"
    #>
    [CmdletBinding(DefaultParameterSetName="TableView")]
    [OutputType([string])]
    <#=> Write-FormatTreeView -Off 1 -ParameterSet TreeView #>
    <#=> Write-FormatTableView -Off 1 -ParameterSet TableView #>
    <#=> Write-FormatWideView -Off 1 -ParameterSet WideView #>
    <#=> Write-FormatListView -Off 1 -ParameterSet ListView #>
    param(
    # One or more type names.
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
    [String[]]
    $TypeName,

    # One or more properties to include in the default type view.
    [Parameter(ParameterSetName='TableView',Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ListView' ,Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
    [String[]]$Property,

    # If set, will rename the properties in the table.
    # The oldname is the name of the old property, and value is either the new header
    [Parameter(ParameterSetName='TableView', Position=2,ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ListView', Position=2,ValueFromPipelineByPropertyName=$true)]
    [Alias('RenamedProperty', 'RenameProperty')]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [string]) {
                throw "All keys and values in the property rename map must be strings"
            }
        }
        return $true
    })]
    [Hashtable]$AliasProperty,

    # If set, will create a number of virtual properties within a table
    [Parameter(ParameterSetName='TableView', Position=3,ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ListView', Position=3,ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [ScriptBlock]) {
                throw "The virtual property may only contain property names and the script blocks that will produce the property"
            }
        }
        return $true
    })]
    [Hashtable]$VirtualProperty,

    # If set, will be used to format the value of a property.
    [Parameter(ParameterSetName='TableView', Position=4,ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='ListView', Position=4,ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [string]) {
                throw "The FormatProperty parameter must contain only strings"
            }
        }
        return $true
    })]
    [Hashtable]$FormatProperty,

    # If provided, will set the alignment used to display a given property.
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='TableView')]
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
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='TableView')]
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ListView')]
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

    # If provided, will colorize all rows in a table, according to the script block.
    # If the script block returns a value, it will be treated either as an ANSI escape sequence or up to two hexadecimal colors
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='TableView')]
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ListView')]
    [Alias('ColourRow')]
    [ScriptBlock]$ColorRow,


    # If set, then the content will be rendered as a list
    [Parameter(Mandatory=$true,ParameterSetName='ListView' ,ValueFromPipelineByPropertyName=$true)]
    [Switch]$AsList,

    # If set, the table will be autosized.
    [Parameter(ParameterSetName='TableView')]
    [Parameter(ParameterSetName='WideView')]
    [Switch]
    $AutoSize,

    # If set, the table headers will not be displayed.
    [Parameter(ParameterSetName='TableView')]
    [Alias('HideTableHeaders')]
    [switch]
    $HideHeader,

    # The width of any the properties.  This parameter is optional, and cannot be used with
    # AutoSize
    # A negative width is a right justified table.
    # A positive width is a left justified table
    # A width of 0 will be ignored.
    [ValidateRange(-80,80)]
    [Parameter(ParameterSetName='TableView',ValueFromPipelineByPropertyName=$true)]
    [Int[]]$Width,

    # If provided, will only display a list property if the condition is met.
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ListView')]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [ScriptBlock]) {
                throw "May only contain property names and script blocks"
            }
        }
        return $true
    })]
    [Collections.IDictionary]$ConditionalProperty,


    # The script block used to fill in the contents of a custom control.
    # The script block can either be an arbitrary script, which will be run, or it can include a
    # number of speicalized commands that will translate into parts of the formatter.
    [Parameter(Mandatory=$true,ParameterSetName='Action',ValueFromPipelineByPropertyName=$true)]
    [ScriptBlock[]]
    $Action,

    # The indentation depth of the custom control
    [Parameter(ParameterSetName='Action',ValueFromPipelineByPropertyName=$true)]
    [int]
    $Indent,

    # Passes thru the provided Format XML.
    # This can be used to include PowerShell formatter features not yet supported by EZOut.
    [Parameter(Mandatory=$true,ParameterSetName='FormatXML',ValueFromPipelineByPropertyName=$true)]
    [xml]
    $FormatXML,

    # If set, it will treat the type name as a selection set (a set of predefined types)
    [Switch]$IsSelectionSet,

    # If wrap is set, then items in the table can span multiple lines
    [Parameter(ParameterSetName='TableView')]
    [Switch]$Wrap,

    # If this is set, then the view will be grouped by a property.
    [String]$GroupByProperty,

    # If this is set, then the view will be grouped by the result of a script block
    [ScriptBlock]$GroupByScript,

    # If this is set, then the view will be labeled with the value of this parameter.
    [String]$GroupLabel,

    # If this is set, then the view will be rendered with a custom action.  The custom action can
    # be defined by using the -AsControl parameter in Write-FormatView.  The action does not have
    # to be defined within the same format file.
    [string]$GroupAction,

    # If set, will output the format view as an action (a view that can be reused again and again)
    [Parameter(ParameterSetName='Action',ValueFromPipelineByPropertyName=$true)]
    [Switch]$AsControl,

    # If the format view is going to be outputted as a control, it will require a name
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [String]$Name)

    process {
        #region Generate Format Content
        [string]$FormatContent = ""
        if ($psCmdlet.ParameterSetName -eq "Action") {
            $FormatContent = $psBoundParameters | & ${.@} Write-FormatCustomView
        } elseif ($psCmdlet.ParameterSetName -eq 'TableView') {
            $formatContent = $PSBoundParameters | & ${.@} Write-FormatTableView
        } elseif ($psCmdlet.ParameterSetName -eq "ListView") {
            $formatContent = $psBoundParameters | & ${.@} Write-FormatListView
        }
        #endregion Generate Format Content

        if (-not $IsSelectionSet) {
            $typeNameElements = foreach ($t in $typeName) {
                "<TypeName>$T</TypeName>"
            }
        } else {
            $typeNameElements = foreach ($t in $typeName) {
                "<SelectionSet>$T</SelectionSet>"
            }

        }


        if ($psCmdlet.ParameterSetName -eq 'FormatXML') {
            $xOut = [IO.StringWriter]::new()
            $FormatXML.Save($xOut)
            $FormatContent = "$xOut".Substring('<?xml version="1.0" encoding="utf-16"?>'.Length + [Environment]::Newline.Length)
            if ($FormatXML.FirstChild.LocalName -notlike '*Control') {
                return $FormatContent
            }
        }

        if ($AsControl) {
            $xml = [xml]$formatContent
        } else {
            $ofs = ""
            $groupBy = ""
            $groupByPropertyOrScript = ""
            if ($GroupByProperty -or $GroupByScript) {
                if ($GroupByProperty) {
                    $groupByPropertyOrScript = "<PropertyName>$GroupByProperty</PropertyName>"
                } else {
                    $groupByPropertyOrScript = "<ScriptBlock>$groupByScript</ScriptBlock>"
                }
                if ($GroupLabel) {
                    $GroupByLabelOrControl = "<Label>$GroupLabel</Label>"
                } elseif ($GroupAction) {
                    $GroupByLabelOrControl = "<CustomControlName>$GroupAction</CustomControlName>"
                }

                $groupBy  = "<GroupBy>
            $GroupByPropertyOrScript
            $GroupByLabelOrControl
    </GroupBy>"
            }
    $viewName = $Name
    if (-not $viewName)  {
        $viewName = $typeName
    }
    $xml = [xml]"
    <View>
        <Name>$viewName</Name>
        <ViewSelectedBy>
            $typeNameElements
        </ViewSelectedBy>
        $GroupBy
        $FormatContent
    </View>
    "
        }

        $strWrite = [IO.StringWriter]::new()
        $xml.Save($strWrite)
        return "$strWrite"
    }

}
