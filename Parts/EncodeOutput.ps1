<#
.Synopsis
    Encodes output (if required)
.Description
    Encodes output, if required by the host.

    If a $request variable is present, or $host.UI.SupportsHTML, each argument will be HTML encoded.
    Otherwise, each argument will be passed thru.
.Notes
    IsFormatPart: true
#>
param()
if ($request -or $Host.UI.SupportsHTML) 
{
    foreach ($a in $args) {
        [Net.WebUtility]::HtmlEncode("$a")
    }
}
else 
{
    foreach ($a in $args) {
        $a
    }
}