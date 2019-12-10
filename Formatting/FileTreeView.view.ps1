Write-FormatTreeView -SelectionSet FileSystemTypes -Branch ([char]9500 + [char]9472 + [char]9472) -Property Name -HasChildren {
        if (-not $_.EnumerateFiles) { return $false }
        foreach ($f in $_.EnumerateFiles()) {$f;break}
    },
    {
        if (-not $_.EnumerateDirectories) { return $false }
        foreach ($f in $_.EnumerateDirectories()) {$f;break}
    } -Children {
        $_.EnumerateFiles()
    }, {
        foreach ($d in $_.EnumerateDirectories()) {
            if ($d.Attributes -band 'Hidden') { continue }
            $d
        }
    }