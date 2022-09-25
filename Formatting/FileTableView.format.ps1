Write-FormatView -TypeName FileSystemTypes -Property LastWriteTime, Length, Name -AlignProperty @{
    LastWriteTime = "Right"
    Length        = "Right"
    Name          = "Left"
} -VirtualProperty @{
    Length       = {
        if ($_.Length) {
            if ($_.Length / 1gb -eq 1) {
                '' + $([Math]::Round($_.Length / 1gb, 2)) + 'gb'
            }
            elseif ($_.Length / 1mb -ge 1) {
                '' + $([Math]::Round($_.Length / 1mb, 2)) + 'mb'
            }
            elseif ($_.Length -gt 1kb) {
                '' + $([Math]::Round($_.Length / 1kb, 2)) + 'kb'
            } elseif ($_ -isnot [IO.DirectoryInfo]) {
                $_.Length
            }
        }
    }
} -IsSelectionSet -GroupAction FileSystemTypes-GroupingFormat