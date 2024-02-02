function Push-TypeData
{
    <#
    .Synopsis
        Pushes type data into the current session.
    .Description
        Push-TypeData pushes type data into the current session.

        This creates a temporary module to store information declared in a types file and imports it.
    .Link
        Clear-TypeData
    .Link
        Pop-TypeData
    .Link
        Out-TypeData
    #>
    [OutputType([Nullable],[PSModuleInfo])]
    [Alias('Add-TypeData')]
    param(
    # The Format XML Document.  The XML document can be supplied directly,
    # but it's easier to use Write-FormatView to create it
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
    [ValidateScript({
        if ((-not $_.Types)) {
            throw "The root of a types XML most be a types element"
        }
        return $true
    })]
    [Xml]
    $TypeXml,

    <#
    The name of the format module.
    If the name is not provided, the name of the module will be the first type name encountered.
    If no typename is encountered, the name of the module will be FormatModuleN
    (where N is the number of modules loaded so far).
    #>
    [string]
    $Name,

    # If set, the module that contains the format files will be outputted to the pipeline
    [Switch]
    $PassThru
    )

    begin {
        # Create a list of all of the format files that will be loaded in this batch.
        $typeFiles = @()
    }

    process {
        #region Create a temporary file to hold each of the type files
        $tempDir = $env:Temp, '/tmp' -ne '' | Select-Object -First 1
        $tempFile = Join-Path $tempDir ([IO.Path]::GetRandomFileName())
        $typeFileName = "${tempFile}.Type.ps1xml"
        $TypeXml.Save($typeFileName)
        $typeFiles += (Get-Item $typeFileName).Name
        #endregion Create a temporary file to hold each of the type files
    }

    end {
        #region Generate a Module to hold the item
        if (-not $name) {
            $typeName = $TypeXml.SelectSingleNode("//Name")
            if ($typeName) {
                $name = $typeName.'#text'
            } else {
                $name = "TypeModule$($TypeModules.Count + 1)"
            }
        }

        $Name = $Name.Replace("#","").Replace("\","").Replace("/","")

        $tempFile = Join-Path $tempDir $name
        $tempFile = "${tempFile}.psd1"
        Get-Module $name -ErrorAction SilentlyContinue |
            Remove-Module
        $ModuleManifestParameters = @{
            FormatsToProcess = @()
            NestedModules = @()
            Author = $env:UserName
            CompanyName = ""
            Copyright = Get-Date
            ModuleToProcess =  ""
            RequiredModules = @()
            Description = ""
            RequiredAssemblies = @()
            TypesToProcess = $TypeFiles
            FileList = $TypeFiles
            Path = $tempFile
        }
        New-ModuleManifest @ModuleManifestParameters
        if ($script:TypeModules.Count) {
            $script:TypeModules.Values | Import-Module -Force
        }
        $module = Import-Module $tempFile -Force -PassThru
        $script:TypeModules[$name] = $module
        if ($passThru) { $module }

        #endregion Generate a Module to hold the item
    }
}
