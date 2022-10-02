
Write-EZFormatFile
------------------
### Synopsis
Creates a new EZFormat file.

---
### Description

Creates a new EZFormat file.  EZFormat files use EZOut to create format and types files for a module.

---
### Parameters
#### **Format**

Any -FormatView commands.



> **Type**: ```[ScriptBlock[]]```

> **Required**: false

> **Position**: 1

> **PipelineInput**:false



---
#### **Type**

Any -TypeView commands.



> **Type**: ```[ScriptBlock[]]```

> **Required**: false

> **Position**: 2

> **PipelineInput**:false



---
#### **ModuleName**

The name of the module.  By default, this will be inferred from the name of the file.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 3

> **PipelineInput**:false



---
#### **SourcePath**

The source path.  By default, the script's root.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 4

> **PipelineInput**:false



---
#### **DestinationPath**

The destination path.  By default, the script's root.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 5

> **PipelineInput**:false



---
### Syntax
```PowerShell
Write-EZFormatFile [[-Format] <ScriptBlock[]>] [[-Type] <ScriptBlock[]>] [[-ModuleName] <String>] [[-SourcePath] <String>] [[-DestinationPath] <String>] [<CommonParameters>]
```
---


