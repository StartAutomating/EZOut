<#
.Synopsis
    Renders a HorizontalRule
.Description
    Renders a HorizontalRule.

    If $request or $host.UI.SupportsHTML, this will render a <hr/> tag.

    Otherwise, this will render a line filled with a given -Character (by default, a '-')
.Notes
    IsFormatPart: true
#>
param(
# The Character used for a Horizontal Rule
[char]
$Character = '-',

# The CSS Class used for the Horizontal Rule (If ($request -or $host.SupportsHTML))
[string]
$Class
)
$canUseHTML = $Request -or $host.UI.SupportsHTML

if ($canUseHTML) {
    if (-not $Class) {
        '<hr/>'
    } else {
        "<hr class='$class' />"
    }
    return
}

return (([string]$Character) * ($Host.UI.RawUI.BufferSize.Width - 1))
