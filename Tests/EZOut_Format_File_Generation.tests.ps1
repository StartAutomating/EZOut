describe "Formatting Tests" {
    it "Can make virtual properties" {
        $tn = "type$(Get-random)"
        
        Write-FormatView -TypeName $tn -VirtualProperty @{foo={'bar'}} -Property foo |
            Out-FormatData |
            Add-FormatData


        New-Object PSObject -Property @{PSTypeName=$tn;n=1} | Out-String | should belike *foo*bar*
    }
    it "Can take action" {
        $tn = "type$(Get-Random)"

        Write-FormatView -TypeName $tn -Action { "foobar" } |
            Out-FormatData |
            Add-FormatData

        New-Object PSObject -Property @{PSTypeName=$tn;n=1} | Out-String | should belike *foobar*
    }
} 
