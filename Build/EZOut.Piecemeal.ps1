#require -Module Piecemeal

# Push to this directory
Push-Location ($PSScriptRoot | Split-Path)

$commandsPath = Join-Path $PWD Commands

# Get-EZOutExtension is generated with Piecemeal
Install-Piecemeal -ExtensionModule 'EZOut' -ExtensionModuleAlias 'ez' -ExtensionTypeName 'EZOut.Extension' -OutputPath (
    Join-Path (
        Join-Path $pwd Commands
    ) "Get-EZOutExtension.ps1"
)
# Pop back to wherever we were
Pop-Location
