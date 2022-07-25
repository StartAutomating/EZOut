
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
#### EXAMPLE 1
```PowerShell
Write-FormatViewExpression -ScriptBlock {
    "hello world"
}
```

#### EXAMPLE 2
```PowerShell
Write-FormatViewExpression -If { $_.Complete } -ScriptBlock { "Complete" }
```

#### EXAMPLE 3
```PowerShell
Write-FormatViewExpression -Text 'Hello World'
```

#### EXAMPLE 4
```PowerShell
# This will render the property 'Name' property of the underlying object
Write-FormatViewExpression -Property Name
```

#### EXAMPLE 5
```PowerShell
# This will render the property 'Status' of the current object,
# if the current object's 'Complete' property is $false.
Write-FormatViewExpression -Property Status -If { -not $_.Complete }
```

---
### Parameters
#### **ControlName**

The name of the control.  If this is provided, it will be used to display the property or script block.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|false   |named  |true (ByPropertyName)|
---
#### **Property**

If a property name is provided, then the custom action will show the contents
of the property



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|true    |1      |true (ByPropertyName)|
---
#### **ScriptBlock**

If a script block is provided, then the custom action shown in formatting
will be the result of the script block.



|Type               |Requried|Postion|PipelineInput        |
|-------------------|--------|-------|---------------------|
|```[ScriptBlock]```|true    |1      |true (ByPropertyName)|
---
#### **If**

If provided, will make the expression conditional.  -If it returns a value, the script block will run



|Type               |Requried|Postion|PipelineInput        |
|-------------------|--------|-------|---------------------|
|```[ScriptBlock]```|false   |named  |true (ByPropertyName)|
---
#### **Text**

If provided, will output the provided text.  All other parameters are ignored.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|true    |named  |true (ByPropertyName)|
---
#### **AssemblyName**

If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|true    |named  |true (ByPropertyName)|
---
#### **BaseName**

If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|true    |named  |true (ByPropertyName)|
---
#### **ResourceID**

If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|true    |named  |true (ByPropertyName)|
---
#### **Newline**

If provided, will output a <NewLine /> element.  All other parameters are ignored.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[Switch]```|true    |named  |true (ByPropertyName)|
---
#### **Bold**

If set, will bold the -Text, -Property, or -ScriptBlock.
This is only valid in consoles that support ANSI terminals ($host.UI.SupportsVirtualTerminal),
or while rendering HTML



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **Underline**

If set, will underline the -Text, -Property, or -ScriptBlock.
This is only valid in consoles that support ANSI terminals, or in HTML



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **Invert**

If set, will invert the -Text, -Property, -or -ScriptBlock
This is only valid in consoles that support ANSI terminals, or in HTML.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **FormatString**

If provided, will output the format using this format string.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[String]```|false   |named  |false        |
---
#### **Enumerate**

If this is set, collections will be enumerated.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[Switch]```|false   |named  |true (ByPropertyName)|
---
#### **ForegroundColor**

If provided, will display the content using the given foreground color.
This will only be displayed on hosts that support rich color.
Colors can be:
* An RGB color
* The name of a color stored in a .Colors section of a .PrivateData in a manifest
* The name of a Standard Concole Color
* The name of a PowerShell stream, e.g. Output, Warning, Debug, etc



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[String]```|false   |named  |false        |
---
#### **BackgroundColor**

If provided, will display the content using the given background color.
This will only be displayed on hosts that support rich color.
Colors can be:
* An RGB color
* The name of a color stored in a .Colors section of a .PrivateData in a manifest
* The name of a Standard Concole Color
* The name of a PowerShell stream, e.g. Output, Warning, Debug, etc



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[String]```|false   |named  |false        |
---
#### **Count**

The number of times the item will be displayed.
With script blocks, the variables $N and $Number will be set to indicate the current iteration.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[UInt32]```|false   |named  |false        |
---
### Outputs
System.String


---
### Syntax
```PowerShell
Write-FormatViewExpression [-ControlName <String>] [-ScriptBlock] <ScriptBlock> [-If <ScriptBlock>] [-Bold] [-Underline] [-Invert] [-FormatString <String>] [-Enumerate] [-ForegroundColor <String>] [-BackgroundColor <String>] [-Count <UInt32>] [<CommonParameters>]
```
```PowerShell
Write-FormatViewExpression [-ControlName <String>] [-Property] <String> [-If <ScriptBlock>] [-Bold] [-Underline] [-Invert] [-FormatString <String>] [-Enumerate] [-ForegroundColor <String>] [-BackgroundColor <String>] [-Count <UInt32>] [<CommonParameters>]
```
```PowerShell
Write-FormatViewExpression [-ControlName <String>] [-If <ScriptBlock>] -Text <String> [-Bold] [-Underline] [-Invert] [-FormatString <String>] [-Enumerate] [-ForegroundColor <String>] [-BackgroundColor <String>] [-Count <UInt32>] [<CommonParameters>]
```
```PowerShell
Write-FormatViewExpression [-ControlName <String>] [-If <ScriptBlock>] -AssemblyName <String> -BaseName <String> -ResourceID <String> [-Bold] [-Underline] [-Invert] [-FormatString <String>] [-Enumerate] [-ForegroundColor <String>] [-BackgroundColor <String>] [-Count <UInt32>] [<CommonParameters>]
```
```PowerShell
Write-FormatViewExpression [-ControlName <String>] [-If <ScriptBlock>] -Newline [-Bold] [-Underline] [-Invert] [-FormatString <String>] [-Enumerate] [-ForegroundColor <String>] [-BackgroundColor <String>] [-Count <UInt32>] [<CommonParameters>]
```
---


