function Out-TypeData {
    <#
    .Synopsis
        Takes a series of type views and format actions and outputs a type data XML
    .Description
        Takes a series of type views and format actions and outputs a type data XML
    .Example
        # Create a quick view for any XML element.
        # Piping it into Out-FormatData will make one or more format views into a full format XML file
        # Piping the output of that into Add-FormatData will create a temporary module to hold the formatting data
        # There's also a Remove-FormatData and
        Write-FormatView -TypeName "System.Xml.XmlNode" -Wrap -Property "Xml" -VirtualProperty @{
            "Xml" = {
                $strWrite = New-Object IO.StringWriter
                ([xml]$_.Outerxml).Save($strWrite)
                "$strWrite"
            }
        } |
            Out-FormatData
    #>
    param(
    # The Format XML Document.  The XML document can be supplied directly,
    # but it's easier to use Write-FormatView to create it
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
    [ValidateScript({
        if ((-not $_.Type)) {
            throw "The root of a types XML most be a type element"
        }
        return $true
    })]
    [Xml]
    $TypeXml,
    # The output path.
    # This can be a string or a dictionary.
    # If it is a dictionary, the keys must a be a `[string]` or `[regex]` defining a pattern, and the value will be the path.
    [ValidateScript({
    $validTypeList = [System.String],[System.Collections.IDictionary]
    $thisType = $_.GetType()
    $IsTypeOk =
        $(@( foreach ($validType in $validTypeList) {
            if ($_ -as $validType) {
                $true;break
            }
        }))
    if (-not $isTypeOk) {
        throw "Unexpected type '$(@($thisType)[0])'.  Must be 'string','System.Collections.IDictionary'."
    }
    return $true
    })]
        
    [PSObject]
    $OutputPath
    )
    begin {
        $type = ""
    }
    process {
        if ($TypeXml.Type) {
            $type+= "<Type>$($TypeXml.Type.InnerXml)</Type>"
        }
    }
    end {
        $xml = [xml]"
        <!-- Generated with EZOut $($MyInvocation.MyCommand.Module.Version): Install-Module EZOut or https://github.com/StartAutomating/EZOut -->
        <Types>
        $type
        </Types>
        "
        if ($OutputPath) {            
            if ($outputPath -is [string]) {
                $createdOutputFile = New-Item -ItemType File -Path $OutputPath -Force
                if (-not $createdOutputFile) { return }
                $xml.Save($createdOutputFile.FullName)
                Get-Item -LiteralPath $createdOutputFile.FullName                
            }
            else {
                $fileOutputs = [Ordered]@{}  
                $alreadyExportedTypeNames = @{}
                $allTypeNames = @()
                
                :nextType foreach ($typeXml in $xml.Types.Type) {                    
                    $viewTypeNames = @($typeXml.Name)
                    $allTypeNames += $viewTypeNames                    
                    if (($OutputPath -isnot [Collections.IDictionary])) { continue } 
                    foreach ($outPath in $OutputPath.GetEnumerator()) {
                        if ($alreadyExportedTypeNames[$viewTypeNames]) { 
                                    continue nextType                        
                                } 
                        if (($outPath.Key -isnot [regex] -and $outPath.Key -isnot [string])) { continue } 
                        if (($outPath.Key -is [string] -and -not ($viewTypeNames -like $outPath.Key))) { continue } 
                        if (($outPath.Key -is [Regex] -and -not ($viewTypeNames -match $outPath.Key))) { continue } 
                                                
                        if (-not $fileOutputs[$outPath.Value]) {
                            $fileOutputs[$outPath.Value] = @()
                        }
                        $fileOutputs[$outPath.Value] += $typeXml.OuterXml
                        $alreadyExportedTypeNames[$viewTypeNames] = $kv.Value
                        continue nextType
                    }                                   
                }
                foreach ($fileOut in $fileOutputs.GetEnumerator()) {                    
                    $fileXml = "
                    <!-- Generated with EZOut $($MyInvocation.MyCommand.Module.Version): Install-Module EZOut or https://github.com/StartAutomating/EZOut -->
                    <Types>$($fileOut.Value -join [Environment]::NewLine)</Types>
                    "                                    
                    if (-not $fileXml) { continue }
                    $filePath = $fileOut.Key
                    $createdOutputFile = New-Item -ItemType File -Path $filePath -Force
                    if (-not $createdOutputFile) { continue }
                    ($fileXml -as [xml]).Save($createdOutputFile.FullName)
                    Get-Item -LiteralPath $createdOutputFile.FullName
                }                
            }            
        } else {
            $strWrite = [IO.StringWriter]::new()
            $xml.Save($strWrite)
            return "$strWrite"
        }        
    }
}
