
Write-FormatTableView
---------------------
### Synopsis
Writes a view for Format-Table

---
### Description

Writes the XML for a PowerShell Format TableControl.

---
### Related Links
* [Write-FormatView](Write-FormatView.md)



---
### Examples
#### EXAMPLE 1
```PowerShell
Write-FormatTableView -Property myFirstProperty,mySecondProperty -TypeName MyPropertyBag
```

#### EXAMPLE 2
```PowerShell
Write-FormatTableView -Property &quot;Friendly Property Name&quot; -RenameProperty @{
    &quot;Friendly Property Name&quot; = &#39;SystemName&#39;
}
```

#### EXAMPLE 3
```PowerShell
Write-FormatTableView -Property Name, Bio -Width 20 -Wrap
```

#### EXAMPLE 4
```PowerShell
Write-FormatTableView -Property Number, IsEven, IsOdd -AutoSize -ColorRow {if ($_.N % 2) { &quot;#ff0000&quot;} else {&quot;#0f0&quot;} } -VirtualProperty @{
    IsEven = { -not ($_.N % 2)}
    IsOdd = { ($_.N % 2) -as [bool] }
} -AliasProperty @{
    Number = &#39;N&#39;
}
```

---
### Parameters
#### **Property**

The list of properties to display.



> **Type**: ```[String[]]```

> **Required**: true

> **Position**: 1

> **PipelineInput**:true (ByPropertyName)



---
#### **AliasProperty**

If set, will rename the properties in the table.
The oldname is the name of the old property, and value is either the new header



> **Type**: ```[IDictionary]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **VirtualProperty**

If set, will create a number of virtual properties within a table



> **Type**: ```[IDictionary]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **FormatProperty**

If set, will be used to format the value of a property.



> **Type**: ```[IDictionary]```

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

The width of any the properties.  This parameter is optional, and cannot be used with -AutoSize.
A negative width is a right justified table.
A positive width is a left justified table
A width of 0 will not include an alignment hint.



> **Type**: ```[Int32[]]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **Wrap**

If wrap is set, then items in the table can span multiple lines



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **ViewTypeName**

If provided, the table view will only be used if the the typename includes this value.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.



> **Type**: ```[String]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **ViewSelectionSet**

If provided, the table view will only be used if the the typename is in a SelectionSet.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.



> **Type**: ```[String]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **ViewCondition**

If provided, will selectively display items.



> **Type**: ```[ScriptBlock]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
### Outputs
System.String


---
### Syntax
```PowerShell
Write-FormatTableView [-Property] &lt;String[]&gt; [-AliasProperty &lt;IDictionary&gt;] [-VirtualProperty &lt;IDictionary&gt;] [[-FormatProperty] &lt;IDictionary&gt;] [-AlignProperty &lt;IDictionary&gt;] [-ColorProperty &lt;IDictionary&gt;] [-ColorRow &lt;ScriptBlock&gt;] [-AutoSize] [-HideHeader] [-Width &lt;Int32[]&gt;] [-Wrap] [-ViewTypeName &lt;String&gt;] [-ViewSelectionSet &lt;String&gt;] [-ViewCondition &lt;ScriptBlock&gt;] [&lt;CommonParameters&gt;]
```
---


