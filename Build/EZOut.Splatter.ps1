Push-Location (Split-Path $PSScriptRoot)
Initialize-Splatter -Verb Get,Use -OutputPath .\@.ps1
Pop-Location
