Write-FormatViewExpression
--------------------------

### Synopsis
Writes a Format XML View Expression

---

### Description

Writes an expression for a Format .PS1XML.
Expressions are used by custom format views and controls to conditionally display content.

---

### Examples
> EXAMPLE 1

```PowerShell
Write-FormatViewExpression -ScriptBlock {
    "hello world"
}
```
> EXAMPLE 2

```PowerShell
Write-FormatViewExpression -If { $_.Complete } -ScriptBlock { "Complete" }
```
> EXAMPLE 3

```PowerShell
Write-FormatViewExpression -Text 'Hello World'
```
This will render the property 'Name' property of the underlying object

```PowerShell
Write-FormatViewExpression -Property Name
```
This will render the property 'Status' of the current object,
if the current object's 'Complete' property is $false.

```PowerShell
Write-FormatViewExpression -Property Status -If { -not $_.Complete }
```

---

### Parameters
#### **ControlName**
The name of the control.  If this is provided, it will be used to display the property or script block.

|Type      |Required|Position|PipelineInput        |Aliases            |
|----------|--------|--------|---------------------|-------------------|
|`[String]`|false   |named   |true (ByPropertyName)|ActionName<br/>Name|

#### **Property**
If a property name is provided, then the custom action will show the contents
of the property

|Type      |Required|Position|PipelineInput        |Aliases     |
|----------|--------|--------|---------------------|------------|
|`[String]`|true    |1       |true (ByPropertyName)|PropertyName|

#### **ScriptBlock**
If a script block is provided, then the custom action shown in formatting
will be the result of the script block.

|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[ScriptBlock]`|true    |1       |true (ByPropertyName)|

#### **If**
If provided, will make the expression conditional.  -If it returns a value, the script block will run

|Type           |Required|Position|PipelineInput        |Aliases               |
|---------------|--------|--------|---------------------|----------------------|
|`[ScriptBlock]`|false   |named   |true (ByPropertyName)|ItemSelectionCondition|

#### **Text**
If provided, will output the provided text.  All other parameters are ignored.

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|true    |named   |true (ByPropertyName)|

#### **AssemblyName**
If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|true    |named   |true (ByPropertyName)|

#### **BaseName**
If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|true    |named   |true (ByPropertyName)|

#### **ResourceID**
If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|true    |named   |true (ByPropertyName)|

#### **Newline**
If provided, will output a <NewLine /> element.  All other parameters are ignored.

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|true    |named   |true (ByPropertyName)|

#### **Frame**
If set, will put the expression within a <Frame> element.

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|

#### **LeftIndent**
If provided, will indent by a number of characters.  This implies -Frame.

|Type     |Required|Position|PipelineInput        |Aliases|
|---------|--------|--------|---------------------|-------|
|`[Int32]`|false   |named   |true (ByPropertyName)|Indent |

#### **RightIndent**
If provided, will indent the right by a number of characters.  This implies -Frame.

|Type     |Required|Position|PipelineInput        |
|---------|--------|--------|---------------------|
|`[Int32]`|false   |named   |true (ByPropertyName)|

#### **FirstLineHanging**
Specifies how many characters the first line of data is shifted to the left.  This implies -Frame.

|Type     |Required|Position|PipelineInput        |
|---------|--------|--------|---------------------|
|`[Int32]`|false   |named   |true (ByPropertyName)|

#### **FirstLineIndent**
Specifies how many characters the first line of data is shifted to the right.  This implies -Frame.

|Type     |Required|Position|PipelineInput        |
|---------|--------|--------|---------------------|
|`[Int32]`|false   |named   |true (ByPropertyName)|

#### **Style**
The name of one or more $psStyle properties to apply.
If $psStyle is present, this will use put these properties prior to an expression.
A $psStyle.Reset will be outputted after the expression.

|Type        |Required|Position|PipelineInput|Aliases             |
|------------|--------|--------|-------------|--------------------|
|`[String[]]`|false   |named   |false        |PSStyle<br/>PSStyles|

#### **Bold**
If set, will bold the -Text, -Property, or -ScriptBlock.
This is only valid in consoles that support ANSI terminals ($host.UI.SupportsVirtualTerminal),
or while rendering HTML

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **Underline**
If set, will underline the -Text, -Property, or -ScriptBlock.
This is only valid in consoles that support ANSI terminals, or in HTML

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **DoubleUnderline**
If set, will double underline the -Text, -Property, or -ScriptBlock.
This is only valid in consoles that support ANSI terminals, or in HTML

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **Italic**
If set, make the -Text, -Property, or -ScriptBlock Italic.
This is only valid in consoles that support ANSI terminals, or in HTML

|Type      |Required|Position|PipelineInput|Aliases|
|----------|--------|--------|-------------|-------|
|`[Switch]`|false   |named   |false        |Italics|

#### **Hide**
If set, will hide  the -Text, -Property, or -ScriptBlock.
This is only valid in consoles that support ANSI terminals, or in HTML

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **Invert**
If set, will invert the -Text, -Property, -or -ScriptBlock
This is only valid in consoles that support ANSI terminals, or in HTML.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **Strikethru**
If set, will cross out the -Text, -Property, -or -ScriptBlock
This is only valid in consoles that support ANSI terminals, or in HTML.

|Type      |Required|Position|PipelineInput|Aliases                   |
|----------|--------|--------|-------------|--------------------------|
|`[Switch]`|false   |named   |false        |Strikethrough<br/>Crossout|

#### **FormatString**
If provided, will output the format using this format string.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |named   |false        |

#### **Enumerate**
If this is set, collections will be enumerated.

|Type      |Required|Position|PipelineInput        |Aliases            |
|----------|--------|--------|---------------------|-------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|EnumerateCollection|

#### **ForegroundColor**
If provided, will display the content using the given foreground color.
This will only be displayed on hosts that support rich color.
Colors can be:
* An RGB color
* The name of a color stored in a .Colors section of a .PrivateData in a manifest
* The name of a Standard Concole Color
* The name of a PowerShell stream, e.g. Output, Warning, Debug, etc

|Type      |Required|Position|PipelineInput|Aliases                |
|----------|--------|--------|-------------|-----------------------|
|`[String]`|false   |named   |false        |FG<br/>ForegroundColour|

#### **BackgroundColor**
If provided, will display the content using the given background color.
This will only be displayed on hosts that support rich color.
Colors can be:
* An RGB color
* The name of a color stored in a .Colors section of a .PrivateData in a manifest
* The name of a Standard Concole Color
* The name of a PowerShell stream, e.g. Output, Warning, Debug, etc

|Type      |Required|Position|PipelineInput|Aliases                |
|----------|--------|--------|-------------|-----------------------|
|`[String]`|false   |named   |false        |BG<br/>BackgroundColour|

#### **Count**
The number of times the item will be displayed.
With script blocks, the variables $N and $Number will be set to indicate the current iteration.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[UInt32]`|false   |named   |false        |

---

### Outputs
* [String](https://learn.microsoft.com/en-us/dotnet/api/System.String)

---

### Syntax
```PowerShell
Write-FormatViewExpression [-ControlName <String>] [-ScriptBlock] <ScriptBlock> [-If <ScriptBlock>] [-Frame] [-LeftIndent <Int32>] [-RightIndent <Int32>] [-FirstLineHanging <Int32>] [-FirstLineIndent <Int32>] [-Style <String[]>] [-Bold] [-Underline] [-DoubleUnderline] [-Italic] [-Hide] [-Invert] [-Strikethru] [-FormatString <String>] [-Enumerate] [-ForegroundColor <String>] [-BackgroundColor <String>] [-Count <UInt32>] [<CommonParameters>]
```
```PowerShell
Write-FormatViewExpression [-ControlName <String>] [-Property] <String> [-If <ScriptBlock>] [-Frame] [-LeftIndent <Int32>] [-RightIndent <Int32>] [-FirstLineHanging <Int32>] [-FirstLineIndent <Int32>] [-Style <String[]>] [-Bold] [-Underline] [-DoubleUnderline] [-Italic] [-Hide] [-Invert] [-Strikethru] [-FormatString <String>] [-Enumerate] [-ForegroundColor <String>] [-BackgroundColor <String>] [-Count <UInt32>] [<CommonParameters>]
```
```PowerShell
Write-FormatViewExpression [-ControlName <String>] [-If <ScriptBlock>] -Text <String> [-Frame] [-LeftIndent <Int32>] [-RightIndent <Int32>] [-FirstLineHanging <Int32>] [-FirstLineIndent <Int32>] [-Style <String[]>] [-Bold] [-Underline] [-DoubleUnderline] [-Italic] [-Hide] [-Invert] [-Strikethru] [-FormatString <String>] [-Enumerate] [-ForegroundColor <String>] [-BackgroundColor <String>] [-Count <UInt32>] [<CommonParameters>]
```
```PowerShell
Write-FormatViewExpression [-ControlName <String>] [-If <ScriptBlock>] -AssemblyName <String> -BaseName <String> -ResourceID <String> [-Frame] [-LeftIndent <Int32>] [-RightIndent <Int32>] [-FirstLineHanging <Int32>] [-FirstLineIndent <Int32>] [-Style <String[]>] [-Bold] [-Underline] [-DoubleUnderline] [-Italic] [-Hide] [-Invert] [-Strikethru] [-FormatString <String>] [-Enumerate] [-ForegroundColor <String>] [-BackgroundColor <String>] [-Count <UInt32>] [<CommonParameters>]
```
```PowerShell
Write-FormatViewExpression [-ControlName <String>] [-If <ScriptBlock>] -Newline [-Frame] [-LeftIndent <Int32>] [-RightIndent <Int32>] [-FirstLineHanging <Int32>] [-FirstLineIndent <Int32>] [-Style <String[]>] [-Bold] [-Underline] [-DoubleUnderline] [-Italic] [-Hide] [-Invert] [-Strikethru] [-FormatString <String>] [-Enumerate] [-ForegroundColor <String>] [-BackgroundColor <String>] [-Count <UInt32>] [<CommonParameters>]
```
