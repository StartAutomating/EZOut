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

> **Type**: ```[String[]]```

> **Required**: true

> **Position**: 1

> **PipelineInput**:true (ByPropertyName)



---
#### **Deserialized**

If set, will generate an identical typeview for the deserialized form of each typename.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
### Syntax
```PowerShell
Import-TypeView [-FilePath] <String[]> [-Deserialized] [<CommonParameters>]
```
---
