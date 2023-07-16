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
Write-FormatTableView -Property "Friendly Property Name" -RenameProperty @{
    "Friendly Property Name" = 'SystemName'
}
```

#### EXAMPLE 3
```PowerShell
Write-FormatTableView -Property Name, Bio -Width 20 -Wrap
```

#### EXAMPLE 4
```PowerShell
Write-FormatTableView -Property Number, IsEven, IsOdd -AutoSize -ColorRow {if ($_.N % 2) { "#ff0000"} else {"#0f0"} } -VirtualProperty @{
    IsEven = { -not ($_.N % 2)}
    IsOdd = { ($_.N % 2) -as [bool] }
} -AliasProperty @{
    Number = 'N'
}
```



---


### Parameters
#### **Property**

The list of properties to display.






|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[String[]]`|true    |1       |true (ByPropertyName)|



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



#### **StyleProperty**

If provided, will use $psStyle to style the property.
# This will add colorization in the hosts that support it, and act normally in hosts that do not.
The key is the name of the property.  The value is a script block that may return one or more $psStyle property names.






|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[IDictionary]`|false   |named   |true (ByPropertyName)|



#### **ColorRow**

If provided, will colorize all rows in a table, according to the script block.
If the script block returns a value, it will be treated either as an ANSI escape sequence or up to two hexadecimal colors






|Type           |Required|Position|PipelineInput        |Aliases  |
|---------------|--------|--------|---------------------|---------|
|`[ScriptBlock]`|false   |named   |true (ByPropertyName)|ColourRow|



#### **StyleRow**

If provided, will style all rows in a table, according to the script block.
If the script block returns a value, it will be treated as a value on $PSStyle.






|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[ScriptBlock]`|false   |named   |true (ByPropertyName)|



#### **AutoSize**

If set, the table will be autosized.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **HideHeader**

If set, the table headers will not be displayed.






|Type      |Required|Position|PipelineInput|Aliases                             |
|----------|--------|--------|-------------|------------------------------------|
|`[Switch]`|false   |named   |false        |HideTableHeaders<br/>HideTableHeader|



#### **Width**

The width of any the properties.  This parameter is optional, and cannot be used with -AutoSize.
A negative width is a right justified table.
A positive width is a left justified table
A width of 0 will not include an alignment hint.






|Type       |Required|Position|PipelineInput        |
|-----------|--------|--------|---------------------|
|`[Int32[]]`|false   |named   |true (ByPropertyName)|



#### **Wrap**

If wrap is set, then items in the table can span multiple lines






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|



#### **ViewTypeName**

If provided, the table view will only be used if the the typename includes this value.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |named   |true (ByPropertyName)|



#### **ViewSelectionSet**

If provided, the table view will only be used if the the typename is in a SelectionSet.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |named   |true (ByPropertyName)|



#### **ViewCondition**

If provided, will selectively display items.






|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[ScriptBlock]`|false   |named   |true (ByPropertyName)|





---


### Outputs
* [String](https://learn.microsoft.com/en-us/dotnet/api/System.String)






---


### Syntax
```PowerShell
Write-FormatTableView [-Property] <String[]> [-AliasProperty <IDictionary>] [-VirtualProperty <IDictionary>] [[-FormatProperty] <IDictionary>] [-AlignProperty <IDictionary>] [-ColorProperty <IDictionary>] [-StyleProperty <IDictionary>] [-ColorRow <ScriptBlock>] [-StyleRow <ScriptBlock>] [-AutoSize] [-HideHeader] [-Width <Int32[]>] [-Wrap] [-ViewTypeName <String>] [-ViewSelectionSet <String>] [-ViewCondition <ScriptBlock>] [<CommonParameters>]
```
