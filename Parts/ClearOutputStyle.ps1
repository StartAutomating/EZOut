<#
.Synopsis
    Clears the output style
.Description
    Clears ANSI output style or closes the most recent span element.

    ANSI stylization can be toggled off individually (for instance, to stop applying an -Underline but leave the color unchanged)
.Notes
    IsFormatPart: true
#>
param(
# If set, will explicitly clear ANSI Bold
[switch]
$Bold,
# If set, will explicitly clear ANSI Underline
[switch]
$Underline,
# If set, will explicitly clear ANSI Invert
[switch]
$Invert,
# If set, will explicitly clear ANSI Foreground Color
[switch]
$ForegroundColor,
# If set, will explicitly clear ANSI Background Color
[switch]
$BackgroundColor
)
@(if ($request -or $host.UI.SupportsHTML) {
    "</span>"
} elseif ($Host.UI.SupportsVirtualTerminal) {
    if ($Underline) {
        [char]0x1b + "[24m"
    }
    if ($Bold) {        
        [char]0x1b + "[21m"
    }
    if ($Invert) {
        [char]0x1b + '[27m'
    }
    if ($ForegroundColor) {
        [char]0x1b + '[39m'
    }
    if ($BackgroundColor) {
        [char]0x1b + '[49m'
    }

    if (-not ($Underline -or $Bold -or $Invert -or $ForegroundColor -or $BackgroundColor)) {
        [char]0x1b + '[0m'
    }
    
}) -join ''