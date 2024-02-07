Out-Gum
-------

### Synopsis
Outputs using Gum

---

### Description

Allows you to format objects using [CharmBraclet's Gum](https://github.com/charmbracelet/gum).

---

### Related Links
* [https://github.com/charmbraclet/gum](https://github.com/charmbraclet/gum)

---

### Examples
> EXAMPLE 1

```PowerShell
'live', 'die' | Out-Gum choose
```
> EXAMPLE 2

```PowerShell
'What is best in life?' | Out-Gum -Command input
```

---

### Parameters
#### **Command**
The Command in Gum.
|CommandName|Description|
|-|-|
|choose|Choose an option from a list of choices|
|confirm|Ask a user to confirm an action|
|file|Pick a file from a folder|
|filter|Filter items from a list|
|format|Format a string using a template|
|input|Prompt for some input|
|join|Join text vertically or horizontally|
|pager|Scroll through a file|
|spin|Display spinner while running a command|
|style|Apply coloring, borders, spacing to text|
|table|Render a table of data|
|write|Prompt for long-form text|
|log|Log messages to output|
Valid Values:

* choose
* confirm
* file
* filter
* format
* input
* join
* pager
* spin
* style
* table
* write
* log

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|true    |1       |false        |

#### **InputObject**
The input object.

|Type        |Required|Position|PipelineInput |
|------------|--------|--------|--------------|
|`[PSObject]`|false   |named   |true (ByValue)|

#### **GumArgument**
Any additional arguments to gum (and any remaining arguments)

|Type        |Required|Position|PipelineInput|Aliases     |
|------------|--------|--------|-------------|------------|
|`[String[]]`|false   |named   |false        |GumArguments|

---

### Syntax
```PowerShell
Out-Gum [-Command] <String> [-InputObject <PSObject>] [-GumArgument <String[]>] [<CommonParameters>]
```
