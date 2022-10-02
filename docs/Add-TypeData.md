
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



> **Type**: ```[XmlDocument]```

> **Required**: true

> **Position**: 1

> **PipelineInput**:true (ByValue)



---
#### **Name**

The name of the format module.  If the name is not provided, the name of the module will be the first
type name encountered.  If no typename is encountered, the name of the module will be FormatModuleN, where
N is the number of modules loaded so far



> **Type**: ```[String]```

> **Required**: false

> **Position**: 2

> **PipelineInput**:false



---
#### **PassThru**

If set, the module that contains the format files will be outputted to the pipeline



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
### Outputs
* [Nullable](https://learn.microsoft.com/en-us/dotnet/api/System.Nullable)


* [Management.Automation.PSModuleInfo](https://learn.microsoft.com/en-us/dotnet/api/System.Management.Automation.PSModuleInfo)




---
### Syntax
```PowerShell
Add-TypeData [-TypeXml] <XmlDocument> [[-Name] <String>] [-PassThru] [<CommonParameters>]
```
---


