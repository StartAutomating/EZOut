Write-FormatView -TypeName Hello.EZOut -Action {
    if ($_.Message) {
        $_.Message
    } else {
        "Hello World"
    }
}

Write-FormatView -TypeName Hello.EZOut -Property Message

Write-FormatView -TypeName Hello.EZOut -Property Message -AsList