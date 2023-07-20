Out-Mermaid
-----------




### Synopsis
Outputs Mermaid



---


### Description

Outputs Mermaid Diagrams.



---


### Examples
#### EXAMPLE 1
```PowerShell
Out-Mermaid "flowchart TD
    Start --> Stop"
```

#### EXAMPLE 2
```PowerShell
[Ordered]@{
    title="Pets Adopted By Owners"
    Dogs=386
    Cats=85
    Rats=15
} | 
    Out-Mermaid pie
```

#### EXAMPLE 3
```PowerShell
[Ordered]@{
    title = "A Gantt Diagram"
    dateFormat = "YYYY-MM-DD"
    "section Section" = [Ordered]@{
        "A task" = "a1,2014-01-01,30d"
        "Another Task" = "after a1, 20d"
    }
    "section Another" = [Ordered]@{
        "Task in Another" = "2014-01-12",'12d'
        "Another Task" =  "24d"
    }        
} | Out-Mermaid -Diagram "gantt"
```

#### EXAMPLE 4
```PowerShell
'
Alice->>John: Hello John, how are you?
John-->>Alice: Great!
Alice-)John: See you later!    
'| 
Out-Mermaid -Diagram sequenceDiagram
```



---


### Parameters
#### **Diagram**

The mermaid diagram.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |



#### **InputObject**

Any input to the diagram.
This will be appended to the diagram definition.
This tries to serialize properties and arrays into their appropriate format in Mermaid.
Strings will be included inine.  Keys/values will be joined with either spaces or colons (depending on depth and type).






|Type      |Required|Position|PipelineInput |
|----------|--------|--------|--------------|
|`[Object]`|false   |named   |true (ByValue)|



#### **AsHtml**

If set, will include the Mermaid diagram within a `pre` element with the css class `mermaid`.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Raw**

If set, will not include either a markdown code fence or an HTML control around the Mermaid.






|Type      |Required|Position|PipelineInput|Aliases        |
|----------|--------|--------|-------------|---------------|
|`[Switch]`|false   |named   |false        |Sparse<br/>Bare|



#### **StringValueSeparator**

The String Value Separator (the value that separates a key from it's value).
If set, this will override any presumptions Out-Mermaid might make.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |named   |false        |





---


### Notes
This will also attempt to transform non-string objects into the appropriate input for a diagram.



---


### Syntax
```PowerShell
Out-Mermaid [[-Diagram] <String>] [-InputObject <Object>] [-AsHtml] [-Raw] [-StringValueSeparator <String>] [<CommonParameters>]
```
