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

The path containing type information.






|Type        |Required|Position|PipelineInput        |Aliases |
|------------|--------|--------|---------------------|--------|
|`[String[]]`|true    |1       |true (ByPropertyName)|FullName|



#### **Deserialized**

If set, will generate an identical typeview for the deserialized form of each typename.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |





---


### Syntax
```PowerShell
Import-TypeView [-FilePath] <String[]> [-Deserialized] [<CommonParameters>]
```
