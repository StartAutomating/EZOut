
Add-FormatData
--------------
### Synopsis
Adds formatting to the current session.

---
### Description

The Add-FormatData command gets the formatting data for the current session.

The formatting data is defined in .Format.ps1xml files (such as those in the $pshome directory).
Add-FormatData will take one or more XML documents containing format data and will create a
temporary module to use the formatting file.

---
### Related Links
* [Clear-FormatData](Clear-FormatData.md)
* [Remove-FormatData](Remove-FormatData.md)
* [Out-FormatData](Out-FormatData.md)
---
### Examples
#### EXAMPLE 1
```PowerShell
# Let's start off by looking at how something like XML is rendered in PowerShell
[xml]"<a an='anattribute'><b d='attribute'><c/></b></a>"
```
# It's not very intuitive.
# I cannot really only see the element I am looking at, instead of a chunk of data

# Create a quick view for any XML element.
# Piping it into Out-FormatData will make one or more format views into a full format XML file
# Piping the output of that into Add-FormatData will create a temporary module to hold the formatting data
# There's also a Remove-FormatData and
Write-FormatView -TypeName "System.Xml.XmlNode" -Wrap -Property "Xml" -VirtualProperty @{
    "Xml" = {
        $strWrite = New-Object IO.StringWriter
        ([xml]$_.Outerxml).Save($strWrite)
        "$strWrite"
    }
} |
    Out-FormatData |
    Add-FormatData

# Now let's take a look at how the xml renders
[xml]"<a an='anattribute'><b d='attribute'><c /></b></a>"

# In case we want to go back to the original formatter, we can use Clear-FormatData to return
# to the old formatting data
Clear-FormatData

# And we're back to the original formatting
[xml]"<a an='anattribute'><b d='attribute'><c/></b></a>"
---
### Parameters
#### **FormatXml**

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
Add-FormatData [-FormatXml] <XmlDocument> [[-Name] <String>] [-PassThru] [<CommonParameters>]
```
---


