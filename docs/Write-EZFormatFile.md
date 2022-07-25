
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



|Type                 |Requried|Postion|PipelineInput|
|---------------------|--------|-------|-------------|
|```[ScriptBlock[]]```|false   |1      |false        |
---
#### **Type**

Any -TypeView commands.



|Type                 |Requried|Postion|PipelineInput|
|---------------------|--------|-------|-------------|
|```[ScriptBlock[]]```|false   |2      |false        |
---
#### **ModuleName**

The name of the module.  By default, this will be inferred from the name of the file.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[String]```|false   |3      |false        |
---
#### **SourcePath**

The source path.  By default, the script's root.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[String]```|false   |4      |false        |
---
#### **DestinationPath**

The destination path.  By default, the script's root.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[String]```|false   |5      |false        |
---
### Syntax
```PowerShell
Write-EZFormatFile [[-Format] <ScriptBlock[]>] [[-Type] <ScriptBlock[]>] [[-ModuleName] <String>] [[-SourcePath] <String>] [[-DestinationPath] <String>] [<CommonParameters>]
```
---


