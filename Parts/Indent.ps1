<#
.Synopsis
    Indents content
.Description
    Indents content.

    In most scenarios, content is indented by a number of spaces

    If $request or $host.UI.SupportsHTML, this will render a div tag with margin-left set to $Length ex 
    (this is the equivilent of N characters of indentation in HTML)
.Notes
    IsFormatPart: true
#>
param(
$Content,

[ValidateRange(0,100)]
[Alias('Spaces')]
[uint32]
$Length = 4
)

if ($Request -or $Host.UI.SupportsHTML) {
    return "<div style='margin-left:${Length}ex'>$content</div>"
}

(' ' * $Length) + "$content"