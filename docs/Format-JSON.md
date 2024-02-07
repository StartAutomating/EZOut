Format-JSON
-----------

### Synopsis
Formats objects as JSON

---

### Description

Formats an object as JSON.    
This is a light wrapper around ConvertTo-Json with a few key differences:    
1. It defaults -Depth to 100 (the maximum)    
2. It will not encode strings that look like JSON.  Format-JSON can have raw JSON as input without it being converted.    
3. It allows you to force single values into a list with -AsList    
4. If there is nothing to convert, it outputs an empty JSON object.    
Using Format-JSON inside of an EZOut command will pack Format-JSON into your exported .ps1xml.

---

### Examples
> EXAMPLE 1

```PowerShell
Format-JSON -InputObject @("a", "b", "c")
```
> EXAMPLE 2

```PowerShell
[Ordered]@{a="b";c="d";e=[Ordered]@{f=@('g')}} | Format-JSON
```

---

### Parameters
#### **AsList**
If set, will always Format-JSON as a list.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

---

### Syntax
```PowerShell
Format-JSON [-AsList] [<CommonParameters>]
```
