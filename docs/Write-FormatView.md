
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
#### EXAMPLE 1
```PowerShell
Write-FormatView -TypeName MyType -Property Property1, Property2
```

#### EXAMPLE 2
```PowerShell
Write-FormatView -TypeName ColorizedRow -Property Number, IsEven, IsOdd -AutoSize -ColorRow {if ($_.N % 2) { &quot;#ff0000&quot;} else {&quot;#0f0&quot;} } -VirtualProperty @{
    IsEven = { -not ($_.N % 2)}
    IsOdd = { ($_.N % 2) -as [bool] }
} -AliasProperty @{
    Number = &#39;N&#39;
} | 
    Out-FormatData | 
    Add-FormatData
```
# Colorized formatting will not work in the ISE
foreach ($n in 1..5) {
    [PSCustomObject]@{
        PSTypeName='ColorizedRow'
        N = $n
    }
}
#### EXAMPLE 3
```PowerShell
Write-FormatView -TypeName &quot;System.Xml.XmlNode&quot; -Wrap -Property &quot;Xml&quot; -VirtualProperty @{
    &quot;Xml&quot; = {
        $strWrite = New-Object IO.StringWriter
        ([xml]$_.Outerxml).Save($strWrite)
        &quot;$strWrite&quot;
    }
} |
    Out-FormatData |
    Add-FormatData
```
[xml]"<a an='anattribute'><b d='attribute'><c /></b></a>"
---
### Parameters
#### **TypeName**

One or more type names.



> **Type**: ```[String[]]```

> **Required**: true

> **Position**: 1

> **PipelineInput**:true (ByPropertyName)



---
#### **Property**

One or more properties to include in the default type view.



> **Type**: ```[String[]]```

> **Required**: true

> **Position**: 2

> **PipelineInput**:true (ByPropertyName)



---
#### **AliasProperty**

If set, will rename the properties in the table.
The oldname is the name of the old property, and value is either the new header



> **Type**: ```[Hashtable]```

> **Required**: false

> **Position**: 3

> **PipelineInput**:true (ByPropertyName)



---
#### **VirtualProperty**

If set, will create a number of virtual properties within a table



> **Type**: ```[Hashtable]```

> **Required**: false

> **Position**: 4

> **PipelineInput**:true (ByPropertyName)



---
#### **FormatProperty**

If set, will be used to format the value of a property.



> **Type**: ```[Hashtable]```

> **Required**: false

> **Position**: 5

> **PipelineInput**:true (ByPropertyName)



---
#### **AlignProperty**

If provided, will set the alignment used to display a given property.



> **Type**: ```[IDictionary]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **ColorProperty**

If provided, will conditionally color the property.
This will add colorization in the hosts that support it, and act normally in hosts that do not.
The key is the name of the property.  The value is a script block that may return one or two colors as strings.
The color strings may be ANSI escape codes or two hexadecimal colors (the foreground color and the background color)



> **Type**: ```[IDictionary]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **ColorRow**

If provided, will colorize all rows in a table, according to the script block.
If the script block returns a value, it will be treated either as an ANSI escape sequence or up to two hexadecimal colors



> **Type**: ```[ScriptBlock]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **AsList**

If set, then the content will be rendered as a list



> **Type**: ```[Switch]```

> **Required**: true

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **AutoSize**

If set, the table will be autosized.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **HideHeader**

If set, the table headers will not be displayed.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Width**

The width of any the properties.  This parameter is optional, and cannot be used with
AutoSize
A negative width is a right justified table.
A positive width is a left justified table
A width of 0 will be ignored.



> **Type**: ```[Int32[]]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **ConditionalProperty**

If provided, will only display a list property if the condition is met.



> **Type**: ```[IDictionary]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **Action**

The script block used to fill in the contents of a custom control.
The script block can either be an arbitrary script, which will be run, or it can include a
number of speicalized commands that will translate into parts of the formatter.



> **Type**: ```[ScriptBlock[]]```

> **Required**: true

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **Indent**

The indentation depth of the custom control



> **Type**: ```[Int32]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **FormatXML**

Passes thru the provided Format XML.
This can be used to include PowerShell formatter features not yet supported by EZOut.



> **Type**: ```[XmlDocument]```

> **Required**: true

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **IsSelectionSet**

If set, it will treat the type name as a selection set (a set of predefined types)



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Wrap**

If wrap is set, then items in the table can span multiple lines



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **GroupByProperty**

If this is set, then the view will be grouped by a property.



> **Type**: ```[String]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **GroupByScript**

If this is set, then the view will be grouped by the result of a script block



> **Type**: ```[ScriptBlock]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **GroupLabel**

If this is set, then the view will be labeled with the value of this parameter.



> **Type**: ```[String]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **GroupAction**

If this is set, then the view will be rendered with a custom action.  The custom action can
be defined by using the -AsControl parameter in Write-FormatView.  The action does not have
to be defined within the same format file.



> **Type**: ```[String]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **AsControl**

If set, will output the format view as an action (a view that can be reused again and again)



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **Name**

If the format view is going to be outputted as a control, it will require a name



> **Type**: ```[String]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
### Outputs
[string]


---
### Syntax
```PowerShell
Write-FormatView [-TypeName] &lt;String[]&gt; [-Property] &lt;String[]&gt; [[-AliasProperty] &lt;Hashtable&gt;] [[-VirtualProperty] &lt;Hashtable&gt;] [[-FormatProperty] &lt;Hashtable&gt;] [-AlignProperty &lt;IDictionary&gt;] [-ColorProperty &lt;IDictionary&gt;] [-ColorRow &lt;ScriptBlock&gt;] [-AutoSize] [-HideHeader] [-Width &lt;Int32[]&gt;] [-IsSelectionSet] [-Wrap] [-GroupByProperty &lt;String&gt;] [-GroupByScript &lt;ScriptBlock&gt;] [-GroupLabel &lt;String&gt;] [-GroupAction &lt;String&gt;] [-Name &lt;String&gt;] [&lt;CommonParameters&gt;]
```
```PowerShell
Write-FormatView [-TypeName] &lt;String[]&gt; [-Property] &lt;String[]&gt; [[-AliasProperty] &lt;Hashtable&gt;] [[-VirtualProperty] &lt;Hashtable&gt;] [[-FormatProperty] &lt;Hashtable&gt;] [-ColorProperty &lt;IDictionary&gt;] [-ColorRow &lt;ScriptBlock&gt;] -AsList [-ConditionalProperty &lt;IDictionary&gt;] [-IsSelectionSet] [-GroupByProperty &lt;String&gt;] [-GroupByScript &lt;ScriptBlock&gt;] [-GroupLabel &lt;String&gt;] [-GroupAction &lt;String&gt;] [-Name &lt;String&gt;] [&lt;CommonParameters&gt;]
```
```PowerShell
Write-FormatView [-TypeName] &lt;String[]&gt; [-AutoSize] [-IsSelectionSet] [-GroupByProperty &lt;String&gt;] [-GroupByScript &lt;ScriptBlock&gt;] [-GroupLabel &lt;String&gt;] [-GroupAction &lt;String&gt;] [-Name &lt;String&gt;] [&lt;CommonParameters&gt;]
```
```PowerShell
Write-FormatView [-TypeName] &lt;String[]&gt; -Action &lt;ScriptBlock[]&gt; [-Indent &lt;Int32&gt;] [-IsSelectionSet] [-GroupByProperty &lt;String&gt;] [-GroupByScript &lt;ScriptBlock&gt;] [-GroupLabel &lt;String&gt;] [-GroupAction &lt;String&gt;] [-AsControl] [-Name &lt;String&gt;] [&lt;CommonParameters&gt;]
```
```PowerShell
Write-FormatView [-TypeName] &lt;String[]&gt; -FormatXML &lt;XmlDocument&gt; [-IsSelectionSet] [-GroupByProperty &lt;String&gt;] [-GroupByScript &lt;ScriptBlock&gt;] [-GroupLabel &lt;String&gt;] [-GroupAction &lt;String&gt;] [-Name &lt;String&gt;] [&lt;CommonParameters&gt;]
```
---


