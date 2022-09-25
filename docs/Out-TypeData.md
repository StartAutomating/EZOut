
Out-TypeData
------------
### Synopsis
Takes a series of type views and format actions and outputs a type data XML

---
### Description

Takes a series of type views and format actions and outputs a type data XML

---
### Examples
#### EXAMPLE 1
```PowerShell
# Create a quick view for any XML element.
# Piping it into Out-FormatData will make one or more format views into a full format XML file
# Piping the output of that into Add-FormatData will create a temporary module to hold the formatting data
# There&#39;s also a Remove-FormatData and
Write-FormatView -TypeName &quot;System.Xml.XmlNode&quot; -Wrap -Property &quot;Xml&quot; -VirtualProperty @{
    &quot;Xml&quot; = {
        $strWrite = New-Object IO.StringWriter
        ([xml]$_.Outerxml).Save($strWrite)
        &quot;$strWrite&quot;
    }
} |
    Out-FormatData
```

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
### Syntax
```PowerShell
Out-TypeData [-TypeXml] &lt;XmlDocument&gt; [&lt;CommonParameters&gt;]
```
---


