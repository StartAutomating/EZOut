
Add-TypeData
------------
### Synopsis
Adds type data to the current session.

---
### Description

The Add-TypeData command adds type data to the current session.

---
### Related Links
* [Clear-TypeData](Clear-TypeData.md)
* [Remove-TypeData](Remove-TypeData.md)
* [Out-TypeData](Out-TypeData.md)
---
### Parameters
#### **TypeXml**

The Format XML Document.  The XML document can be supplied directly,
but it's easier to use Write-FormatView to create it



|Type               |Requried|Postion|PipelineInput |
|-------------------|--------|-------|--------------|
|```[XmlDocument]```|true    |1      |true (ByValue)|
---
#### **Name**

The name of the format module.  If the name is not provided, the name of the module will be the first
type name encountered.  If no typename is encountered, the name of the module will be FormatModuleN, where
N is the number of modules loaded so far



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[String]```|false   |2      |false        |
---
#### **PassThru**

If set, the module that contains the format files will be outputted to the pipeline



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
### Outputs
System.Nullable


System.Management.Automation.PSModuleInfo


---
### Syntax
```PowerShell
Add-TypeData [-TypeXml] <XmlDocument> [[-Name] <String>] [-PassThru] [<CommonParameters>]
```
---


