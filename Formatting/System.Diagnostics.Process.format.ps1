Write-FormatControl -Name ProcessGroupControl -Action {
    Write-FormatViewExpression -ScriptBlock {
        . $Indent $_.ProcessName
    }
    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -ScriptBlock {
        . $Indent $_.Path
    }
}

Write-FormatView -TypeName System.Diagnostics.Process -Property Handles, 'NPM(K)', 'PM(K)','WS(K)','CPU(S)', 'ID', 'SI' -GroupByProperty ProcessName -GroupAction ProcessGroupControl -VirtualProperty @{
    'NPM(K)' = { [long]($_.NPM / 1024) } 
    'PM(K)' = { [long]($_.PM / 1024) }
    'WS(K)' = { [long]($_.WS / 1024) }
    'CPU(S)' = { 
        if ($_.CPU -ne $()) { 
            $_.CPU.ToString("N") 
        }
    }
} -ColorProperty @{
    'NPM(K)' = {
        . $Heatmap $_.NPM -Min 16mb -Mid .5gb -Max 1gb 
<#        if ($_.NPM -le 1MB) { '#00FF00'}
        elseif ($_.NPM -le 256mb) { '#ffff00' }
        else {
            '#FF0000'
        }#>
    }
    'PM(K)' = { 
        . $Heatmap $_.PM -Min 16mb -Mid .5GB -Max 1gb 
        <#if ($_.PM -le 1MB) { '#00FF00'}
        elseif ($_.PM -le 256mb) { '#ffff00' }
        else {
            '#FF0000'
        }#>
    }
    'WS(K)' = {
        . $Heatmap $_.WS -Min 16mb -Mid 512mb -Max 1gb 
        <#if ($_.PM -le 1MB) { '#00FF00'}
        elseif ($_.PM -le 256mb) { '#ffff00' }
        else {
            '#FF0000'
        }#>
    }  
} -Name Process.Heatmap


Write-FormatView -TypeName System.Diagnostics.Process -Property ID -AsList -GroupByProperty ProcessName -GroupAction ProcessGroupControl -Name process