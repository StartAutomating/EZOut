
Import-TypeView
---------------
### Synopsis
Imports a Type View

---
### Description

Imports a Type View, defined in a external file .method or .property file

---
### Related Links
* [Write-TypeView](Write-TypeView.md)
---
### Examples
#### EXAMPLE 1
```PowerShell
Import-TypeView .\Types
```

---
### Parameters
#### **FilePath**

|Type            |Requried|Postion|PipelineInput        |
|----------------|--------|-------|---------------------|
|```[String[]]```|true    |1      |true (ByPropertyName)|
---
#### **Deserialized**

If set, will generate an identical typeview for the deserialized form of each typename.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
### Syntax
```PowerShell
Import-TypeView [-FilePath] <String[]> [-Deserialized] [<CommonParameters>]
```
---


