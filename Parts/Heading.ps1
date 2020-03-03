<#
.Synopsis
    Renders a heading
.Description
    Renders a heading.

    If $request or $host.UI.SupportsHTML, this will render heading tags.

    Otherwise, this will render Markdown style headings
.Notes
    IsFormatPart: true
#>
param(
# The text inside of the heading
[string]
$Text,

# The level of heading
[ValidateRange(1,6)]
[int]
$Level = 2,

# If using SeText style headings (a line followed by a line of equals or a line of dashes)
# -UnderlineLength will adjust the length of the second line.
[int]
$UnderlineLength,

# If set, will render all markdown headings as ATX style, rather than SeText style
# (ATX style always starts with a comment, SeText styles are underlined)
[switch]
$NoSeText
)

if ($Request -or $Host.UI.SupportsHTML) {
    "<h$level>$text</h$level>"
} else {
    if ($Level -eq 1 -and -not $NoSeText) {
        $text + [Environment]::NewLine + ('=' * $(if ($UnderlineLength) { $UnderlineLength } else {$Text.Length})) + [Environment]::NewLine
    } elseif ($Level -eq 2 -and -not $NoSeText) {
        $text + [Environment]::NewLine + ('-' * $(if ($UnderlineLength) { $UnderlineLength } else {$Text.Length})) + [Environment]::NewLine
    } else {
        [Environment]::NewLine + ('#' * $Level) + ' ' + $Text
    }
}