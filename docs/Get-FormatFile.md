Get-FormatFile
--------------

### Synopsis
Gets format files

---

### Description

Gets loaded format files

---

### Examples
> EXAMPLE 1

```PowerShell
Get-FormatFile
```
> EXAMPLE 2

```PowerShell
Get-FormatFile -OnlyFromModule
```
> EXAMPLE 3

```PowerShell
Get-FormatFile -OnlyBuildIn
```

---

### Parameters
#### **OnlyFromModule**

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **OnlyBuiltIn**

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **FromSnapins**

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

---

### Syntax
```PowerShell
Get-FormatFile [-OnlyFromModule] [-OnlyBuiltIn] [-FromSnapins] [<CommonParameters>]
```
