
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
    &quot;hello world&quot;
}
```

#### EXAMPLE 2
```PowerShell
Write-FormatViewExpression -If { $_.Complete } -ScriptBlock { &quot;Complete&quot; }
```

#### EXAMPLE 3
```PowerShell
Write-FormatViewExpression -Text &#39;Hello World&#39;
```

#### EXAMPLE 4
```PowerShell
# This will render the property &#39;Name&#39; property of the underlying object
Write-FormatViewExpression -Property Name
```

#### EXAMPLE 5
```PowerShell
# This will render the property &#39;Status&#39; of the current object,
# if the current object&#39;s &#39;Complete&#39; property is $false.
Write-FormatViewExpression -Property Status -If { -not $_.Complete }
```

---
### Parameters
#### **ControlName**

The name of the control.  If this is provided, it will be used to display the property or script block.



> **Type**: ```[String]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **Property**

If a property name is provided, then the custom action will show the contents
of the property



> **Type**: ```[String]```

> **Required**: true

> **Position**: 1

> **PipelineInput**:true (ByPropertyName)



---
#### **ScriptBlock**

If a script block is provided, then the custom action shown in formatting
will be the result of the script block.



> **Type**: ```[ScriptBlock]```

> **Required**: true

> **Position**: 1

> **PipelineInput**:true (ByPropertyName)



---
#### **If**

If provided, will make the expression conditional.  -If it returns a value, the script block will run



> **Type**: ```[ScriptBlock]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **Text**

If provided, will output the provided text.  All other parameters are ignored.



> **Type**: ```[String]```

> **Required**: true

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **AssemblyName**

If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.



> **Type**: ```[String]```

> **Required**: true

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **BaseName**

If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.



> **Type**: ```[String]```

> **Required**: true

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **ResourceID**

If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.



> **Type**: ```[String]```

> **Required**: true

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **Newline**

If provided, will output a <NewLine /> element.  All other parameters are ignored.



> **Type**: ```[Switch]```

> **Required**: true

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **Bold**

If set, will bold the -Text, -Property, or -ScriptBlock.
This is only valid in consoles that support ANSI terminals ($host.UI.SupportsVirtualTerminal),
or while rendering HTML



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Underline**

If set, will underline the -Text, -Property, or -ScriptBlock.
This is only valid in consoles that support ANSI terminals, or in HTML



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Invert**

If set, will invert the -Text, -Property, -or -ScriptBlock
This is only valid in consoles that support ANSI terminals, or in HTML.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **FormatString**

If provided, will output the format using this format string.



> **Type**: ```[String]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Enumerate**

If this is set, collections will be enumerated.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **ForegroundColor**

If provided, will display the content using the given foreground color.
This will only be displayed on hosts that support rich color.
Colors can be:
* An RGB color
* The name of a color stored in a .Colors section of a .PrivateData in a manifest
* The name of a Standard Concole Color
* The name of a PowerShell stream, e.g. Output, Warning, Debug, etc



> **Type**: ```[String]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **BackgroundColor**

If provided, will display the content using the given background color.
This will only be displayed on hosts that support rich color.
Colors can be:
* An RGB color
* The name of a color stored in a .Colors section of a .PrivateData in a manifest
* The name of a Standard Concole Color
* The name of a PowerShell stream, e.g. Output, Warning, Debug, etc



> **Type**: ```[String]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Count**

The number of times the item will be displayed.
With script blocks, the variables $N and $Number will be set to indicate the current iteration.



> **Type**: ```[UInt32]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
### Outputs
System.String


---
### Syntax
```PowerShell
Write-FormatViewExpression [-ControlName &lt;String&gt;] [-ScriptBlock] &lt;ScriptBlock&gt; [-If &lt;ScriptBlock&gt;] [-Bold] [-Underline] [-Invert] [-FormatString &lt;String&gt;] [-Enumerate] [-ForegroundColor &lt;String&gt;] [-BackgroundColor &lt;String&gt;] [-Count &lt;UInt32&gt;] [&lt;CommonParameters&gt;]
```
```PowerShell
Write-FormatViewExpression [-ControlName &lt;String&gt;] [-Property] &lt;String&gt; [-If &lt;ScriptBlock&gt;] [-Bold] [-Underline] [-Invert] [-FormatString &lt;String&gt;] [-Enumerate] [-ForegroundColor &lt;String&gt;] [-BackgroundColor &lt;String&gt;] [-Count &lt;UInt32&gt;] [&lt;CommonParameters&gt;]
```
```PowerShell
Write-FormatViewExpression [-ControlName &lt;String&gt;] [-If &lt;ScriptBlock&gt;] -Text &lt;String&gt; [-Bold] [-Underline] [-Invert] [-FormatString &lt;String&gt;] [-Enumerate] [-ForegroundColor &lt;String&gt;] [-BackgroundColor &lt;String&gt;] [-Count &lt;UInt32&gt;] [&lt;CommonParameters&gt;]
```
```PowerShell
Write-FormatViewExpression [-ControlName &lt;String&gt;] [-If &lt;ScriptBlock&gt;] -AssemblyName &lt;String&gt; -BaseName &lt;String&gt; -ResourceID &lt;String&gt; [-Bold] [-Underline] [-Invert] [-FormatString &lt;String&gt;] [-Enumerate] [-ForegroundColor &lt;String&gt;] [-BackgroundColor &lt;String&gt;] [-Count &lt;UInt32&gt;] [&lt;CommonParameters&gt;]
```
```PowerShell
Write-FormatViewExpression [-ControlName &lt;String&gt;] [-If &lt;ScriptBlock&gt;] -Newline [-Bold] [-Underline] [-Invert] [-FormatString &lt;String&gt;] [-Enumerate] [-ForegroundColor &lt;String&gt;] [-BackgroundColor &lt;String&gt;] [-Count &lt;UInt32&gt;] [&lt;CommonParameters&gt;]
```
---


