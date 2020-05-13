Write-FormatView -TypeName System.Type -Property FullName, BaseType, IsPublic, IsSerializable -AutoSize 

Write-FormatView -TypeName System.Type -Action {
    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -ScriptBlock { '-' * ($Host.UI.RawUI.BufferSize.Width - 1) }
    Write-FormatViewExpression -ScriptBlock { ' ' * 1 } 
    Write-FormatViewExpression -ForegroundColor 'Verbose' -ScriptBlock { $_ } -ControlName TypeNameControl
    Write-FormatViewExpression -ScriptBlock { ' ' * 1 }
    Write-FormatViewExpression -If { $_.BaseType -and -not $_.IsValueType } -ScriptBlock { 
        ':'
    }
    Write-FormatViewExpression -If { $_.BaseType -and -not $_.IsValueType -and $_.BaseType -ne [Object] } -Property BaseType -ControlName TypeBase      
    Write-FormatViewExpression -If { $_.GetInterfaces() } -ScriptBlock { $_.GetInterfaces() | Sort-Object Name} -Enumerate -ControlName TypeBase
} -GroupLabel 'Type Summary' -GroupByScript { '| Format-Custom -View System.Type.Full for more'} -Name System.Type.Summary

Write-FormatView -TypeName System.Type -Action {
    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -ScriptBlock { '-' * ($Host.UI.RawUI.BufferSize.Width - 1) }
    Write-FormatViewExpression -ScriptBlock { ' ' * 1 } 
    Write-FormatViewExpression -ForegroundColor 'Verbose' -ScriptBlock { $_ } -ControlName TypeNameControl
    Write-FormatViewExpression -ScriptBlock { ' ' * 1 }
    Write-FormatViewExpression -If { $_.BaseType -and -not $_.IsValueType -and $_.BaseType -ne [Object] } -ScriptBlock { 
        ':'
    }
    Write-FormatViewExpression -If { $_.BaseType -and -not $_.IsValueType -and $_.BaseType -ne [Object] } -Property BaseType -ControlName TypeBase      
    Write-FormatViewExpression -If { $_.GetInterfaces() } -ScriptBlock { $_.GetInterfaces() | Sort-Object Name} -Enumerate -ControlName TypeBase

    Write-FormatViewExpression -If { $_.GetConstructors('Instance,Public') } -ScriptBlock { 
        [Environment]::NewLine + ('#' * 3) + ' Constructors:'           
    }
    Write-FormatViewExpression -If { $_.GetConstructors('Instance,Public') } -ScriptBlock {
        $_.GetConstructors('Instance,Public')
    } -Enumerate -ControlName TypeMethodControl
    Write-FormatViewExpression -If { $_.GetEvents('Instance,Public') } -ScriptBlock {
        [Environment]::NewLine + ('#' * 3) + ' Events:'    
    }
    Write-FormatViewExpression -If { $_.GetEvents('Instance,Public') } -ScriptBlock {
        $_.GetEvents('Instance,Public') | Sort-Object Name
    } -Enumerate -ControlName TypeEventControl
    Write-FormatViewExpression -If { $_.GetProperties('Static,Public') } -ScriptBlock {
        [Environment]::NewLine + ('#' * 3) + ' Static Properties:'
    }
    Write-FormatViewExpression -If { $_.GetProperties('Static,Public')} -ScriptBlock {
        $_.GetProperties('Static,Public') | Sort-Object Name
    } -Enumerate -ControlName TypePropertyControl
    Write-FormatViewExpression -If { $_.GetProperties('Instance,Public') } -ScriptBlock {
        [Environment]::NewLine + ('#' * 3) + ' Properties:'
    }
    Write-FormatViewExpression -If { $_.GetProperties('Instance,Public')} -ScriptBlock {
        $_.GetProperties('Instance,Public') | Sort-Object Name
    } -Enumerate -ControlName TypePropertyControl
    Write-FormatViewExpression -If { $_.GetMethods('Static,Public') } -ScriptBlock {
        [Environment]::NewLine + ('#' * 3) + ' Static Methods:'
    }
    Write-FormatViewExpression -If { $_.GetMethods('Static,Public') } -ScriptBlock {
        $_.GetMethods('Static,Public') | Sort-Object Name | Where-Object { -not $_.IsSpecialName }
    } -Enumerate -ControlName TypeMethodControl
    Write-FormatViewExpression -If { $_.GetMethods('Instance,Public') } -ScriptBlock {
        [Environment]::NewLine + ('#' * 3) + ' Methods:'
    }
    Write-FormatViewExpression -If { $_.GetMethods('Instance,Public') } -ScriptBlock {
        $_.GetMethods('Instance,Public') | Sort-Object Name | Where-Object { -not $_.IsSpecialName } 
    } -Enumerate -ControlName TypeMethodControl
} -Name System.Type.Full