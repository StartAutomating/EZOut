
Format-YAML
-----------
### Synopsis
Formats objects as YAML

---
### Description

Formats an object as YAML.

---
### Examples
#### EXAMPLE 1
```PowerShell
Format-Yaml -InputObject @(&quot;a&quot;, &quot;b&quot;, &quot;c&quot;)
```

#### EXAMPLE 2
```PowerShell
@{a=&quot;b&quot;;c=&quot;d&quot;;e=@{f=@(&#39;g&#39;)}} | Format-Yaml
```

---
### Parameters
#### **InputObject**

The InputObject.



> **Type**: ```[PSObject]```

> **Required**: false

> **Position**: 1

> **PipelineInput**:true (ByValue)



---
#### **YamlHeader**

If set, will make a YAML header by adding a YAML Document tag above and below output.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Indent**

> **Type**: ```[Int32]```

> **Required**: false

> **Position**: 2

> **PipelineInput**:false



---
#### **Depth**

The maximum depth of objects to include.
Beyond this depth, an empty string will be returned.



> **Type**: ```[Int32]```

> **Required**: false

> **Position**: 3

> **PipelineInput**:false



---
### Syntax
```PowerShell
Format-YAML [[-InputObject] &lt;PSObject&gt;] [-YamlHeader] [[-Indent] &lt;Int32&gt;] [[-Depth] &lt;Int32&gt;] [&lt;CommonParameters&gt;]
```
---


