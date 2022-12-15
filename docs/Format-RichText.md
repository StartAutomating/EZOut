Format-RichText
---------------
### Synopsis
Formats the text color of output

---
### Description

Formats the text color of output

* ForegroundColor
* BackgroundColor
* Bold
* Underline

---
### Parameters
#### **InputObject**

The input object



> **Type**: ```[PSObject]```

> **Required**: false

> **Position**: 1

> **PipelineInput**:true (ByValue)



---
#### **ForegroundColor**

The foreground color



> **Type**: ```[String]```

> **Required**: false

> **Position**: 2

> **PipelineInput**:false



---
#### **BackgroundColor**

The background color



> **Type**: ```[String]```

> **Required**: false

> **Position**: 3

> **PipelineInput**:false



---
#### **Bold**

If set, will render as bold



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Italic**

If set, will render as italic.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Faint**

If set, will render as faint



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Hide**

If set, will render as hidden text.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Blink**

If set, will render as blinking (not supported in all terminals or HTML)



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Strikethru**

If set, will render as strikethru



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Underline**

If set, will underline text



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **DoubleUnderline**

If set, will double underline text.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Invert**

If set, will invert text



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Link**

If provided, will create a hyperlink to a given uri



> **Type**: ```[Uri]```

> **Required**: false

> **Position**: 4

> **PipelineInput**:false



---
#### **NoClear**

If set, will not clear formatting



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Alignment**

The alignment.  Defaulting to Left.
Setting an alignment will pad the remaining space on each line.



Valid Values:

* Left
* Right
* Center



> **Type**: ```[String]```

> **Required**: false

> **Position**: 5

> **PipelineInput**:false



---
#### **LineLength**

The length of a line.  By default, the buffer width



> **Type**: ```[Int32]```

> **Required**: false

> **Position**: 6

> **PipelineInput**:false



---
### Outputs
* [String](https://learn.microsoft.com/en-us/dotnet/api/System.String)




---
### Syntax
```PowerShell
Format-RichText [[-InputObject] <PSObject>] [[-ForegroundColor] <String>] [[-BackgroundColor] <String>] [-Bold] [-Italic] [-Faint] [-Hide] [-Blink] [-Strikethru] [-Underline] [-DoubleUnderline] [-Invert] [[-Link] <Uri>] [-NoClear] [[-Alignment] <String>] [[-LineLength] <Int32>] [<CommonParameters>]
```
---
### Notes
Stylized Output works in two contexts at present:
* Rich consoles (Windows Terminal, PowerShell.exe, Pwsh.exe) (when $host.UI.SupportsVirtualTerminal)
* Web pages (Based off the presence of a $Request variable, or when $host.UI.SupportsHTML (you must add this property to $host.UI))
