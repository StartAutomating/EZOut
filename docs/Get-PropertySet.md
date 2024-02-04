Get-PropertySet
---------------

### Synopsis
Gets the property sets

---

### Description

Gets the property sets.  Property sets are predefined views of an object.

---

### Examples
> EXAMPLE 1

```PowerShell
Get-PropertySet
```
> EXAMPLE 2

```PowerShell
Get-PropertySet -TypeName System.Diagnostics.Process
```

---

### Parameters
#### **TypeName**
The name of the typename to get

|Type        |Required|Position|PipelineInput|
|------------|--------|--------|-------------|
|`[String[]]`|false   |1       |false        |

---

### Outputs
* [Management.Automation.PSObject](https://learn.microsoft.com/en-us/dotnet/api/System.Management.Automation.PSObject)

---

### Syntax
```PowerShell
Get-PropertySet [[-TypeName] <String[]>] [<CommonParameters>]
```
