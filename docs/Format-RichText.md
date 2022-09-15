
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
#### **Invert**

If set, will invert text



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **NoClear**

If set, will not clear formatting



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
### Syntax
```PowerShell
Format-RichText [[-InputObject] &lt;PSObject&gt;] [[-ForegroundColor] &lt;String&gt;] [[-BackgroundColor] &lt;String&gt;] [-Bold] [-Blink] [-Strikethru] [-Underline] [-Invert] [-NoClear] [&lt;CommonParameters&gt;]
```
---
### Notes
Stylized Output works in two contexts at present:
* Rich consoles (Windows Terminal, PowerShell.exe, Pwsh.exe) (when $host.UI.SupportsVirtualTerminal)
* Web pages (Based off the presence of a $Request variable, or when $host.UI.SupportsHTML (you must add this property to $host.UI))



