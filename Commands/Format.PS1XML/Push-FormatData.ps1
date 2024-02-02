function Push-FormatData
{
    <#
    .Synopsis
        Pushes formatting to the current session.
    .Description
        Push-FormatData pushes formatting data into the current session.

        The formatting data is defined in .Format.ps1xml files (such as those in the $pshome directory).
        Add-FormatData will take one or more XML documents containing format data and will create a
        temporary module to use the formatting file.
    .Link
        Clear-FormatData
    .Link
        Pop-FormatData
    .Link
        Out-FormatData
    .Example
        # Let's start off by looking at how something like XML is rendered in PowerShell
        [xml]"<a an='anattribute'><b d='attribute'><c/></b></a>"

        # It's not very intuitive.
        # I cannot really only see the element I am looking at, instead of a chunk of data

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
            Out-FormatData |
            Push-FormatData

        # Now let's take a look at how the xml renders
        [xml]"<a an='anattribute'><b d='attribute'><c /></b></a>"

        # In case we want to go back to the original formatter, we can use Clear-FormatData to return
        # to the old formatting data
        Clear-FormatData

        # And we're back to the original formatting
        [xml]"<a an='anattribute'><b d='attribute'><c/></b></a>"
    #>
    [OutputType([Nullable], [PSModuleInfo])]
    [Alias('Add-FormatData')]
    param(
    # The Format XML Document.  The XML document can be supplied directly,
    # but it's easier to use Write-FormatView to create it
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
    [ValidateScript({
        if ((-not $_.Configuration)) {
            throw "The root of a format XML most be a Configuration element"
        }
        return $true
    })]
    [Xml]
    $FormatXml,

    # The name of the format module.  If the name is not provided, the name of the module will be the first
    # type name encountered.  If no typename is encountered, the name of the module will be FormatModuleN, where
    # N is the number of modules loaded so far
    [string]
    $Name,

    # If set, the module that contains the format files will be outputted to the pipeline
    [Switch]
    $PassThru
    )

    begin {
        # Create a list of all of the format files that will be loaded in this batch.
        $formatFiles = @()
    }

    process {
        #region Create a temporary file to hold each of the formatters
        $tempDir = $env:Temp, '/tmp' -ne '' | Select-Object -First 1
        $tempFile = Join-Path $tempDir ([IO.Path]::GetRandomFileName())
        $formatFileName = "${tempFile}.Format.ps1xml"
        $FormatXml.Save($FormatFileName)
        $formatFiles += (Get-Item $formatFileName).Name
        #endregion Create a temporary file to hold each of the formatters
    }

    end {
        #region Generate Module for the Type
        if (-not $name) {
            $typeName = $FormatXml.SelectSingleNode("//TypeName")
            if ($typeName) {
                $name = $typeName.'#text'
            } else {
                $name = "FormatModule$($FormatModules.Count + 1)"
            }

        }

        $Name = $Name.Replace("#","").Replace("\","").Replace("/","").Replace(":","")

        $tempFile = Join-Path $tempDir $name
        $tempFile = "${tempFile}.psd1"

        Get-Module $name -ErrorAction SilentlyContinue |
            Remove-Module
        $ModuleManifestParameters = @{
            FormatsToProcess = $FormatFiles
            NestedModules = @()
            Author = $env:UserName
            CompanyName = ""
            Copyright = Get-Date
            ModuleToProcess =  ""
            RequiredModules = @()
            Description = ""
            RequiredAssemblies = @()
            TypesToProcess = @()
            FileList = $FormatFiles
            Path = $tempFile
        }
        New-ModuleManifest @ModuleManifestParameters
        if ($script:FormatModules.Count) {
            $script:FormatModules.Values | Where-Object { $_ } |Import-Module -Force
        }
        $module = Import-Module $tempFile -Force -PassThru
        $script:formatModules[$name] = $module
        if ($passThru) { $module }
        #endregion Generate Module for the Type
    }
}
