Push-TypeData
-------------

### Synopsis
Pushes type data into the current session.

---

### Description

Push-TypeData pushes type data into the current session.

This creates a temporary module to store information declared in a types file and imports it.

---

### Related Links
* [Clear-TypeData](Clear-TypeData.md)

* [Pop-TypeData](Pop-TypeData.md)

* [Out-TypeData](Out-TypeData.md)

---

### Parameters
#### **TypeXml**
The Format XML Document.  The XML document can be supplied directly,
but it's easier to use Write-FormatView to create it

|Type           |Required|Position|PipelineInput |
|---------------|--------|--------|--------------|
|`[XmlDocument]`|true    |1       |true (ByValue)|

#### **Name**
The name of the format module.
If the name is not provided, the name of the module will be the first type name encountered.
If no typename is encountered, the name of the module will be FormatModuleN
(where N is the number of modules loaded so far).

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

#### **PassThru**
If set, the module that contains the format files will be outputted to the pipeline

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

---

### Outputs
* [Nullable](https://learn.microsoft.com/en-us/dotnet/api/System.Nullable)

* [Management.Automation.PSModuleInfo](https://learn.microsoft.com/en-us/dotnet/api/System.Management.Automation.PSModuleInfo)

---

### Syntax
```PowerShell
Push-TypeData [-TypeXml] <XmlDocument> [[-Name] <String>] [-PassThru] [<CommonParameters>]
```
