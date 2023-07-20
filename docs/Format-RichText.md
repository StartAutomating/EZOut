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






|Type        |Required|Position|PipelineInput |
|------------|--------|--------|--------------|
|`[PSObject]`|false   |1       |true (ByValue)|



#### **ForegroundColor**

The foreground color






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |



#### **BackgroundColor**

The background color






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |3       |false        |



#### **Bold**

If set, will render as bold






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Italic**

If set, will render as italic.






|Type      |Required|Position|PipelineInput|Aliases|
|----------|--------|--------|-------------|-------|
|`[Switch]`|false   |named   |false        |Italics|



#### **Faint**

If set, will render as faint






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Hide**

If set, will render as hidden text.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Blink**

If set, will render as blinking (not supported in all terminals or HTML)






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Strikethru**

If set, will render as strikethru






|Type      |Required|Position|PipelineInput|Aliases                   |
|----------|--------|--------|-------------|--------------------------|
|`[Switch]`|false   |named   |false        |Strikethrough<br/>Crossout|



#### **Underline**

If set, will underline text






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **DoubleUnderline**

If set, will double underline text.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Invert**

If set, will invert text






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Link**

If provided, will create a hyperlink to a given uri






|Type   |Required|Position|PipelineInput|Aliases           |
|-------|--------|--------|-------------|------------------|
|`[Uri]`|false   |4       |false        |Hyperlink<br/>Href|



#### **NoClear**

If set, will not clear formatting






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Alignment**

The alignment.  Defaulting to Left.
Setting an alignment will pad the remaining space on each line.



Valid Values:

* Left
* Right
* Center






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |5       |false        |



#### **LineLength**

The length of a line.  By default, the buffer width






|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |6       |false        |





---


### Outputs
* [String](https://learn.microsoft.com/en-us/dotnet/api/System.String)






---


### Notes
Stylized Output works in two contexts at present:
* Rich consoles (Windows Terminal, PowerShell.exe, Pwsh.exe) (when $host.UI.SupportsVirtualTerminal)
* Web pages (Based off the presence of a $Request variable, or when $host.UI.SupportsHTML (you must add this property to $host.UI))



---


### Syntax
```PowerShell
Format-RichText [[-InputObject] <PSObject>] [[-ForegroundColor] <String>] [[-BackgroundColor] <String>] [-Bold] [-Italic] [-Faint] [-Hide] [-Blink] [-Strikethru] [-Underline] [-DoubleUnderline] [-Invert] [[-Link] <Uri>] [-NoClear] [[-Alignment] <String>] [[-LineLength] <Int32>] [<CommonParameters>]
```
