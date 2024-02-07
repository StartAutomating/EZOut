Write-FormatView
----------------

### Synopsis
Creates a format XML that will be used to display a type.

---

### Description

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

---

### Related Links
* [Out-FormatData](Out-FormatData.md)

* [Add-FormatData](Add-FormatData.md)

---

### Examples
> EXAMPLE 1

```PowerShell
Write-FormatView -TypeName MyType -Property Property1, Property2
```
> EXAMPLE 2

```PowerShell
Write-FormatView -TypeName ColorizedRow -Property Number, IsEven, IsOdd -AutoSize -ColorRow {if ($_.N % 2) { "#ff0000"} else {"#0f0"} } -VirtualProperty @{
    IsEven = { -not ($_.N % 2)}
    IsOdd = { ($_.N % 2) -as [bool] }
} -AliasProperty @{
    Number = 'N'
} | 
    Out-FormatData | 
    Add-FormatData
# Colorized formatting will not work in the ISE
foreach ($n in 1..5) {
    [PSCustomObject]@{
        PSTypeName='ColorizedRow'
        N = $n
    }
}
```
> EXAMPLE 3

```PowerShell
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
```

---

### Parameters
#### **TypeName**
One or more type names.

|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[String[]]`|true    |1       |true (ByPropertyName)|

#### **Property**
One or more properties to include in the default type view.

|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[String[]]`|true    |2       |true (ByPropertyName)|

#### **AliasProperty**
If set, will rename the properties in the table.
The oldname is the name of the old property, and value is either the new header

|Type         |Required|Position|PipelineInput        |Aliases                           |
|-------------|--------|--------|---------------------|----------------------------------|
|`[Hashtable]`|false   |3       |true (ByPropertyName)|RenamedProperty<br/>RenameProperty|

#### **VirtualProperty**
If set, will create a number of virtual properties within a table

|Type         |Required|Position|PipelineInput        |
|-------------|--------|--------|---------------------|
|`[Hashtable]`|false   |4       |true (ByPropertyName)|

#### **FormatProperty**
If set, will be used to format the value of a property.

|Type         |Required|Position|PipelineInput        |
|-------------|--------|--------|---------------------|
|`[Hashtable]`|false   |5       |true (ByPropertyName)|

#### **AlignProperty**
If provided, will set the alignment used to display a given property.

|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[IDictionary]`|false   |named   |true (ByPropertyName)|

#### **ColorProperty**
If provided, will conditionally color the property.
This will add colorization in the hosts that support it, and act normally in hosts that do not.
The key is the name of the property.  The value is a script block that may return one or two colors as strings.
The color strings may be ANSI escape codes or two hexadecimal colors (the foreground color and the background color)

|Type           |Required|Position|PipelineInput        |Aliases       |
|---------------|--------|--------|---------------------|--------------|
|`[IDictionary]`|false   |named   |true (ByPropertyName)|ColourProperty|

#### **ColorRow**
If provided, will colorize all rows in a table, according to the script block.
If the script block returns a value, it will be treated either as an ANSI escape sequence or up to two hexadecimal colors

|Type        |Required|Position|PipelineInput|Aliases  |
|------------|--------|--------|-------------|---------|
|`[PSObject]`|false   |named   |false        |ColourRow|

#### **StyleProperty**
If provided, will use $psStyle to style the property.
# This will add colorization in the hosts that support it, and act normally in hosts that do not.
The key is the name of the property.  The value is a script block that may return one or more $psStyle property names.

|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[IDictionary]`|false   |named   |true (ByPropertyName)|

#### **StyleRow**
If provided, will style all rows in a table, according to the script block.
If the script block returns a value, it will be treated as a value on $PSStyle.

|Type        |Required|Position|PipelineInput|
|------------|--------|--------|-------------|
|`[PSObject]`|false   |named   |false        |

#### **AsList**
If set, then the content will be rendered as a list

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|true    |named   |true (ByPropertyName)|

#### **AutoSize**
If set, the table will be autosized.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **HideHeader**
If set, the table headers will not be displayed.

|Type      |Required|Position|PipelineInput|Aliases         |
|----------|--------|--------|-------------|----------------|
|`[Switch]`|false   |named   |false        |HideTableHeaders|

#### **Width**
The width of any the properties.  This parameter is optional, and cannot be used with
AutoSize
A negative width is a right justified table.
A positive width is a left justified table
A width of 0 will be ignored.

|Type       |Required|Position|PipelineInput        |
|-----------|--------|--------|---------------------|
|`[Int32[]]`|false   |named   |true (ByPropertyName)|

#### **ConditionalProperty**
If provided, will only display a list property if the condition is met.

|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[IDictionary]`|false   |named   |true (ByPropertyName)|

#### **Action**
The script block used to fill in the contents of a custom control.
The script block can either be an arbitrary script, which will be run, or it can include a
number of speicalized commands that will translate into parts of the formatter.

|Type             |Required|Position|PipelineInput        |
|-----------------|--------|--------|---------------------|
|`[ScriptBlock[]]`|true    |named   |true (ByPropertyName)|

#### **Indent**
The indentation depth of the custom control

|Type     |Required|Position|PipelineInput        |
|---------|--------|--------|---------------------|
|`[Int32]`|false   |named   |true (ByPropertyName)|

#### **FormatXML**
Passes thru the provided Format XML.
This can be used to include PowerShell formatter features not yet supported by EZOut.

|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[XmlDocument]`|true    |named   |true (ByPropertyName)|

#### **IsSelectionSet**
If set, it will treat the type name as a selection set (a set of predefined types)

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **Wrap**
If wrap is set, then items in the table can span multiple lines

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **GroupByProperty**
If this is set, then the view will be grouped by a property.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |named   |false        |

#### **GroupByScript**
If this is set, then the view will be grouped by the result of a script block

|Type           |Required|Position|PipelineInput|
|---------------|--------|--------|-------------|
|`[ScriptBlock]`|false   |named   |false        |

#### **GroupLabel**
If this is set, then the view will be labeled with the value of this parameter.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |named   |false        |

#### **GroupAction**
If this is set, then the view will be rendered with a custom action.  The custom action can
be defined by using the -AsControl parameter in Write-FormatView.  The action does not have
to be defined within the same format file.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |named   |false        |

#### **AsControl**
If set, will output the format view as an action (a view that can be reused again and again)

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|

#### **Name**
If the format view is going to be outputted as a control, it will require a name

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |named   |true (ByPropertyName)|

---

### Outputs
* [string]

---

### Syntax
```PowerShell
Write-FormatView [-TypeName] <String[]> [-Property] <String[]> [[-AliasProperty] <Hashtable>] [[-VirtualProperty] <Hashtable>] [[-FormatProperty] <Hashtable>] [-AlignProperty <IDictionary>] [-ColorProperty <IDictionary>] [-ColorRow <PSObject>] [-StyleProperty <IDictionary>] [-StyleRow <PSObject>] [-AutoSize] [-HideHeader] [-Width <Int32[]>] [-IsSelectionSet] [-Wrap] [-GroupByProperty <String>] [-GroupByScript <ScriptBlock>] [-GroupLabel <String>] [-GroupAction <String>] [-Name <String>] [<CommonParameters>]
```
```PowerShell
Write-FormatView [-TypeName] <String[]> [-Property] <String[]> [[-AliasProperty] <Hashtable>] [[-VirtualProperty] <Hashtable>] [[-FormatProperty] <Hashtable>] [-ColorProperty <IDictionary>] [-StyleProperty <IDictionary>] [-StyleRow <PSObject>] -AsList [-ConditionalProperty <IDictionary>] [-IsSelectionSet] [-GroupByProperty <String>] [-GroupByScript <ScriptBlock>] [-GroupLabel <String>] [-GroupAction <String>] [-Name <String>] [<CommonParameters>]
```
```PowerShell
Write-FormatView [-TypeName] <String[]> [-StyleRow <PSObject>] [-AutoSize] [-IsSelectionSet] [-GroupByProperty <String>] [-GroupByScript <ScriptBlock>] [-GroupLabel <String>] [-GroupAction <String>] [-Name <String>] [<CommonParameters>]
```
```PowerShell
Write-FormatView [-TypeName] <String[]> [-StyleRow <PSObject>] -Action <ScriptBlock[]> [-Indent <Int32>] [-IsSelectionSet] [-GroupByProperty <String>] [-GroupByScript <ScriptBlock>] [-GroupLabel <String>] [-GroupAction <String>] [-AsControl] [-Name <String>] [<CommonParameters>]
```
```PowerShell
Write-FormatView [-TypeName] <String[]> [-StyleRow <PSObject>] -FormatXML <XmlDocument> [-IsSelectionSet] [-GroupByProperty <String>] [-GroupByScript <ScriptBlock>] [-GroupLabel <String>] [-GroupAction <String>] [-Name <String>] [<CommonParameters>]
```
