$colorNameAndMemberType = 
    {
        if ($_.MemberType -like '*property*') {        
            "Success"
        }
        elseif ($_.MemberType -like '*method' -or $_.MemberType -eq 'Event') {
            "Warning"
        }        
    }

Write-FormatView -TypeName Microsoft.PowerShell.Commands.MemberDefinition -Property Name, MemberType, Definition -ColorProperty @{
    Name = $colorNameAndMemberType
    MemberType = $colorNameAndMemberType    
} -GroupByProperty TypeName -VirtualProperty @{
    Definition = {
        $findOverloads = [Regex]::new('(?<=^|\))[\s\p{P}]{0,}(?<Type>\S{1,})\s{1,}(?<Name>\w{1,})', 'IgnoreCase', '00:00:01')
        $definition = $_.definition
        
        $foundOverloads = @(foreach ($m in $findOverloads.Matches($Definition)) {$m.Groups["Type","Name"]})
        
        
        $chars         = $definition.ToCharArray()
        $overload      = $null
        $overloadIndex = 0 
        @(for($i = 0; $i -lt $chars.length; $i++) {
            if (-not $overload) {
                if ($foundOverloads[$overloadIndex].Index -eq $i) {                    
                    $overload = $foundOverloads[$overloadIndex]
                    if ($overload.Name -eq 'Type') {
                        . $setOutputStyle -ForegroundColor 'Verbose'
                    } else {
                        . $setOutputStyle -ForegroundColor 'Warning'
                    }
                }

            }
            $chars[$i]
            if ($overload -and ($i -eq ($overload.Index + $overload.Length))) {
                $overload = $null
                $overloadIndex++
                . $clearOutputStyle
            }
            
        }) -join ''
    }
} -AutoSize
