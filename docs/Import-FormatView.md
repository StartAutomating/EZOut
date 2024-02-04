Import-FormatView
-----------------

### Synopsis
Imports a Format View

---

### Description

Imports a Format View defined in .format or .view .ps1 files

---

### Related Links
* [Write-FormatView](Write-FormatView.md)

---

### Examples
Imports any formatting in the formatting directory

```PowerShell
Import-FormatView -FilePath ./Formatting/
```
Imports any formatting in the types directory

```PowerShell
Import-FormatView -FilePath ./Types/
```

---

### Parameters
#### **FilePath**
The path containing one or more formatting files.

|Type        |Required|Position|PipelineInput        |Aliases |
|------------|--------|--------|---------------------|--------|
|`[String[]]`|true    |1       |true (ByPropertyName)|FullName|

#### **FormatFilePattern**
The format file pattern.  
This is used to explicitly indicate a file contains PowerShell formatting.
By default, it is `'\.(?>format|type|view|control)\.ps1$'`, or:
Any `*.format.ps1`, `*.type.ps1`, `*.view.ps1`, or `*.control.ps1`

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

---

### Syntax
```PowerShell
Import-FormatView [-FilePath] <String[]> [[-FormatFilePattern] <String>] [<CommonParameters>]
```
