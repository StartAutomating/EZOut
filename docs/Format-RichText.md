
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



|Type            |Requried|Postion|PipelineInput |
|----------------|--------|-------|--------------|
|```[PSObject]```|false   |1      |true (ByValue)|
---
#### **ForegroundColor**

The foreground color



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[String]```|false   |2      |false        |
---
#### **BackgroundColor**

The background color



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[String]```|false   |3      |false        |
---
#### **Bold**

If set, will render as bold



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **Blink**

If set, will render as blinking (not supported in all terminals or HTML)



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **Strikethru**

If set, will render as strikethru



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **Underline**

If set, will underline text



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **Invert**

If set, will invert text



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **NoClear**

If set, will not clear formatting



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
### Syntax
```PowerShell
Format-RichText [[-InputObject] <PSObject>] [[-ForegroundColor] <String>] [[-BackgroundColor] <String>] [-Bold] [-Blink] [-Strikethru] [-Underline] [-Invert] [-NoClear] [<CommonParameters>]
```
---
### Notes
Stylized Output works in two contexts at present:
* Rich consoles (Windows Terminal, PowerShell.exe, Pwsh.exe) (when $host.UI.SupportsVirtualTerminal)
* Web pages (Based off the presence of a $Request variable, or when $host.UI.SupportsHTML (you must add this property to $host.UI))



