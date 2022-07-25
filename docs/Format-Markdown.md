
Format-Markdown
---------------
### Synopsis
Formats an object as Markdown

---
### Description

Formats an object as Markdown, with many options to work with

---
### Examples
#### EXAMPLE 1
```PowerShell
Format-Markdown -ScriptBlock {
    Get-Process
}
```

#### EXAMPLE 2
```PowerShell
1..6 | Format-Markdown  -HeadingSize { $_ }
```

---
### Parameters
#### **InputObject**

|Type            |Requried|Postion|PipelineInput                 |
|----------------|--------|-------|------------------------------|
|```[PSObject]```|false   |1      |true (ByValue, ByPropertyName)|
---
#### **MarkdownParagraph**

If set, will treat the -InputObject as a paragraph.
This is the default for strings, booleans, numbers, and other primitive types.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[Switch]```|false   |named  |true (ByPropertyName)|
---
#### **MarkdownTable**

If set, will generate a markdown table.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[Switch]```|false   |named  |true (ByPropertyName)|
---
#### **MarkdownTableAlignment**

If provided, will align columnns in a markdown table.



Valid Values:

* Left
* Right
* Center
* 
|Type            |Requried|Postion|PipelineInput        |
|----------------|--------|-------|---------------------|
|```[String[]]```|false   |2      |true (ByPropertyName)|
---
#### **Property**

An array of properties.  Providing this implies -MarkdownTable



|Type              |Requried|Postion|PipelineInput        |
|------------------|--------|-------|---------------------|
|```[PSObject[]]```|false   |3      |true (ByPropertyName)|
---
#### **Heading**

A heading.
If provided without -HeadingSize, -HeadingSize will default to 2.
If provided with -InputObject, -Heading will take priority.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|false   |4      |true (ByPropertyName)|
---
#### **HeadingSize**

The heading size (1-6)
If provided without -Heading, the -InputObject will be considered to be a heading.



|Type         |Requried|Postion|PipelineInput        |
|-------------|--------|-------|---------------------|
|```[Int32]```|false   |5      |true (ByPropertyName)|
---
#### **Link**

If set, will create a link.  The -InputObject will be used as the link content



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|false   |6      |true (ByPropertyName)|
---
#### **ImageLink**

If set, will create an image link.  The -Inputobject will be used as the link content.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|false   |7      |true (ByPropertyName)|
---
#### **BulletPoint**

If set, will generate a bullet point list.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[Switch]```|false   |named  |true (ByPropertyName)|
---
#### **Checkbox**

If set, bullet or numbered list items will have a checkbox.
Each piped -InputObject will be an additional list item.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[Switch]```|false   |named  |true (ByPropertyName)|
---
#### **Checked**

If set, bullet or numbered list items will be checked.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[Switch]```|false   |named  |true (ByPropertyName)|
---
#### **NumberedList**

If set, will generate a numbered list.
Each piped -InputObject will be an additional list item.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[Switch]```|false   |named  |true (ByPropertyName)|
---
#### **BlockQuote**

If set, will generate a block quote.
Each line of the -InputObject will be block quoted.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[Switch]```|false   |named  |true (ByPropertyName)|
---
#### **BlockQuoteDepth**

If set, will generate a block quote of a particular depth.
Each line of the -InputObject will be block quoted.



|Type         |Requried|Postion|PipelineInput        |
|-------------|--------|-------|---------------------|
|```[Int32]```|false   |8      |true (ByPropertyName)|
---
#### **Number**

If provided, will create a markdown numbered list with this particular item as the number.



|Type         |Requried|Postion|PipelineInput        |
|-------------|--------|-------|---------------------|
|```[Int32]```|false   |9      |true (ByPropertyName)|
---
#### **HorizontalRule**

If set, will generate a horizontal rule.  
If other parameters are provided, the horiztonal rule will be placed after.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[Switch]```|false   |named  |true (ByPropertyName)|
---
#### **Code**

If set, will output the -InputObject as a Markdown code block



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[Switch]```|false   |named  |true (ByPropertyName)|
---
#### **CodeLanguage**

If set, will output the -InputObject as a Markdown code block, with a given language
If the -InputObject is a ScriptBlock, -CodeLanguage will be set to PowerShell.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|false   |10     |true (ByPropertyName)|
---
#### **ScriptBlock**

If provided, will output a script block as a Markdown code block.



|Type               |Requried|Postion|PipelineInput        |
|-------------------|--------|-------|---------------------|
|```[ScriptBlock]```|false   |11     |true (ByPropertyName)|
---
### Syntax
```PowerShell
Format-Markdown [[-InputObject] <PSObject>] [-MarkdownParagraph] [-MarkdownTable] [[-MarkdownTableAlignment] <String[]>] [[-Property] <PSObject[]>] [[-Heading] <String>] [[-HeadingSize] <Int32>] [[-Link] <String>] [[-ImageLink] <String>] [-BulletPoint] [-Checkbox] [-Checked] [-NumberedList] [-BlockQuote] [[-BlockQuoteDepth] <Int32>] [[-Number] <Int32>] [-HorizontalRule] [-Code] [[-CodeLanguage] <String>] [[-ScriptBlock] <ScriptBlock>] [<CommonParameters>]
```
---


