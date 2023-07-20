# It's a piece of cake to do colorized formatting and output in PowerShell: once you know the right tricks.
# List Views and Table views are kind of obvious.  To do something like colorized output, you need to use a CustomControl.
# A Custom Control can do any action you'd like in response to that type being rendered. 
# This very short custom control will put an * on the screen in green if $_.Good is found on a type
Write-FormatView -TypeName GoodOrBad -Action {
    if ($_.Good) { 
        Write-Host "*" -ForegroundColor Green 
    } else {
        Write-Host "*" -ForegroundColor Red 
    } 
    # Output null, so that nothing is rendered and no brackets appear (indicating output was expected)
    $null
}

# To highlight the whole line, you will need to use the host object, and pad each line to the right size
Write-FormatView -TypeName GoodOrBad -Action {
    $background = 'White'
    $width = $host.UI.RawUI.BufferSize.Width
    if ($_.Good) { 
        Write-Host "*".PadRight($width) -ForegroundColor Green 
    } else {
        Write-Host "*".PadRight($width) -ForegroundColor Red 
    } 
    # Output null, so that nothing is rendered and no brackets appear (indicating output was expected)
    $null
}

# That's it.  There's really not that much to colorized formatting in PowerShell, once you know the trick.
# To use a view like this in your module, use some code like this:
$views = @()
$views += Write-FormatView -TypeName GoodOrBad -Action {
    $background = 'White'
    $width = $host.UI.RawUI.BufferSize.Width
    if ($_.Good) { 
        Write-Host "*".PadRight($width) -ForegroundColor Green 
    } else {
        Write-Host "*".PadRight($width) -ForegroundColor Red 
    } 
    # Output null, so that nothing is rendered and no brackets appear (indicating output was expected)
    $null
}
$views | Out-FormatData | Set-Content .\YourModule.Format.ps1xml
