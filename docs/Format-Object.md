Format-Object
-------------
### Synopsis
Formats an Object

---
### Description

Formats any object, using any number of Format-Object extensions.

---
### Related Links
* [Get-EZOutExtension](Get-EZOutExtension.md)



* [Format-RichText](Format-RichText.md)



* [Format-Markdown](Format-Markdown.md)



* [Format-YAML](Format-YAML.md)



* [Format-Heatmap](Format-Heatmap.md)



---
### Examples
#### EXAMPLE 1
```PowerShell
"red" | Format-Object -ForegroundColor "red"
```

#### EXAMPLE 2
```PowerShell
1..10 | Format-Object -NumberedList
```

---
### Parameters
#### **InputObject**

> **Type**: ```[PSObject]```

> **Required**: false

> **Position**: 1

> **PipelineInput**:true (ByValue)



---
### Syntax
```PowerShell
Format-Object [[-InputObject] <PSObject>] [<CommonParameters>]
```
---
