# If there is a .PSTypeName.txt file in the same directory, $PSTypeName will be set

if (-not $PSTypeName) {  
    $PSTypeName = "Hello.EZOut", "Hi.EZOut"
}

Write-FormatView -TypeName $PSTypeName -Action {
    if ($_.Message) {
        $_.Message
    } else {
        "Hello World"
    }
}

Write-FormatView -TypeName $PSTypeName -Property Message

Write-FormatView -TypeName $PSTypeName -Property Message -AsList