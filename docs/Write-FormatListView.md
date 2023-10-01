Write-FormatListView
--------------------




### Synopsis
Writes a view for Format-List



---


### Description

Writes the XML for a PowerShell Format ListControl



---


### Related Links
* [Write-FormatView](Write-FormatView.md)





---


### Examples
> EXAMPLE 1

```PowerShell
Write-FormatListView -Property N
```


---


### Parameters
#### **Property**

The list of properties to display.






|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[String[]]`|true    |named   |true (ByPropertyName)|



#### **AliasProperty**

If set, will rename the properties in the table.
The oldname is the name of the old property, and value is either the new header






|Type           |Required|Position|PipelineInput        |Aliases                           |
|---------------|--------|--------|---------------------|----------------------------------|
|`[IDictionary]`|false   |named   |true (ByPropertyName)|RenamedProperty<br/>RenameProperty|



#### **VirtualProperty**

If set, will create a number of virtual properties within a table






|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[IDictionary]`|false   |named   |true (ByPropertyName)|



#### **FormatProperty**

If set, will be used to format the value of a property.






|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[IDictionary]`|false   |5       |true (ByPropertyName)|



#### **ColorProperty**

If provided, will conditionally color the property.
This will add colorization in the hosts that support it, and act normally in hosts that do not.
The key is the name of the property.  The value is a script block that may return one or two colors as strings.
The color strings may be ANSI escape codes or two hexadecimal colors (the foreground color and the background color)






|Type           |Required|Position|PipelineInput        |Aliases       |
|---------------|--------|--------|---------------------|--------------|
|`[IDictionary]`|false   |named   |true (ByPropertyName)|ColourProperty|



#### **StyleProperty**

If provided, will use $psStyle to style the property.
# This will add colorization in the hosts that support it, and act normally in hosts that do not.
The key is the name of the property.  The value is a script block that may return one or more $psStyle property names.






|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[IDictionary]`|false   |named   |true (ByPropertyName)|



#### **ConditionalProperty**

If provided, will only display a property if the condition is met.






|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[IDictionary]`|false   |named   |true (ByPropertyName)|



#### **ViewTypeName**

If provided, the view will only be used if the the typename includes this value.
This is distinct from the overall typename, and can be used to have different views for different inherited objects.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |named   |true (ByPropertyName)|



#### **ViewSelectionSet**

If provided, the view will only be used if the the typename is in a SelectionSet.
This is distinct from the overall typename, and can be used to have different views for different inherited objects.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |named   |true (ByPropertyName)|



#### **ViewCondition**

If provided, will use this entire view if this condition returns a value.
More than one view must be provided via the pipeline for this to work,
and at least one of these views must not havea condition.






|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[ScriptBlock]`|false   |named   |true (ByPropertyName)|





---


### Syntax
```PowerShell
Write-FormatListView -Property <String[]> [-AliasProperty <IDictionary>] [-VirtualProperty <IDictionary>] [[-FormatProperty] <IDictionary>] [-ColorProperty <IDictionary>] [-StyleProperty <IDictionary>] [-ConditionalProperty <IDictionary>] [-ViewTypeName <String>] [-ViewSelectionSet <String>] [-ViewCondition <ScriptBlock>] [<CommonParameters>]
```
