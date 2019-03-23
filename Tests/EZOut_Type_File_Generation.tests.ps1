describe "EZOut can create selection sets" {
    it "Write-PropertySet can create a property set" {
        $propertySet = 
            Write-PropertySet -typename System.IO.FileInfo -name filetimes -propertyName Name, LastAccessTime, CreationTime, LastWriteTime

        $propertySet = [xml]$propertySet

        $propertySet.SelectNodes("//PropertySet/Name").'#text' | should be filetimes
    }

    it "ConvertTo-PropertySet converts Select-Object output into a property set" {
        $propertySet = 
            Get-ChildItem | 
                Select-Object Name, LastAccessTime, CreationTime, LastWriteTime | 
                ConvertTo-PropertySet -Name filetimes


        $propertySet | 
            Select-Xml -XPath "//PropertySet/Name" | 
            %{$_.node.'#text'} | 
            should be filetimes
    }

    it "Can get and set a virtual property" {
        $tn = "t$(Get-Random)"
        Write-TypeView -TypeName $tn -ScriptProperty @{
            foo = {
                "bar" # get
            }, {
                $global:set = $args # set
            }
        } |
            Out-TypeData |
            Add-TypeData

        $o = New-Object PSObject -Property @{PSTypeName=$tn}

        $o.foo | should be bar

        $o.foo = 'baz'
        $Global:set | should be baz
    }

    
}
