<#
.Synopsis
    GitHub Action for EZOut
.Description
    GitHub Action for EZOut.  This will:

    * Import EZOut
    * Run all *.EZOut.ps1 files beneath the workflow directory
    * Run a .EZOutScript parameter
    * If a Formatting or Types directory is found, and an .ezout file is not, run the output of Write-EZFormatFile

    Any files changed can be outputted by the script, and those changes can be checked back into the repo.
    Make sure to use the "persistCredentials" option with checkout.
#>

param(
# A PowerShell Script that uses EZOut.  
# Any files outputted from the script will be added to the repository.
# If those files have a .Message attached to them, they will be committed with that message.
[string]
$EZOutScript,

# If set, will not process any files named *.EZOut.ps1
[switch]
$SkipEZOutPS1,

# The name of the module for which types and formats are being generated.
# If not provided, this will be assumed to be the name of the root directory.
[string]
$ModuleName,

# If provided, will commit any remaining changes made to the workspace with this commit message.
[string]
$CommitMessage,

# The user email associated with a git commit.
[string]
$UserEmail,

# The user name associated with a git commit.
[string]
$UserName
)

#region Initial Logging

# Output the parameters passed to this script (for debugging)
"::group::Parameters" | Out-Host
[PSCustomObject]$PSBoundParameters | Format-List | Out-Host
"::endgroup::" | Out-Host

# Get the GitHub Event
$gitHubEvent = 
    if ($env:GITHUB_EVENT_PATH) {
        [IO.File]::ReadAllText($env:GITHUB_EVENT_PATH) | ConvertFrom-Json
    } else { $null }

# Log the GitHub Event
@"
::group::GitHubEvent
$($gitHubEvent | ConvertTo-Json -Depth 100)
::endgroup::
"@ | Out-Host

# Check that there is a workspace (and throw if there is not)
if (-not $env:GITHUB_WORKSPACE) { throw "No GitHub workspace" }

#endregion Initial Logging

#region Configure UserName and Email
if (-not $UserName)  {
    $UserName =  
        if ($env:GITHUB_TOKEN) {
            Invoke-RestMethod -uri "https://api.github.com/user" -Headers @{
                Authorization = "token $env:GITHUB_TOKEN"
            } |
                Select-Object -First 1 -ExpandProperty name
        } else {
            $env:GITHUB_ACTOR
        }
}

if (-not $UserEmail) { 
    $GitHubUserEmail = 
        if ($env:GITHUB_TOKEN) {
            Invoke-RestMethod -uri "https://api.github.com/user/emails" -Headers @{
                Authorization = "token $env:GITHUB_TOKEN"
            } |
                Select-Object -First 1 -ExpandProperty email
        } else {''}
    $UserEmail = 
        if ($GitHubUserEmail) {
            $GitHubUserEmail
        } else {
            "$UserName@github.com"
        }    
}
git config --global user.email $UserEmail
git config --global user.name  $UserName
#endregion Configure UserName and Email

# Check to ensure we are on a branch
$branchName = git rev-parse --abrev-ref HEAD
# If we were not, return.
if (-not $branchName) {
    "::notice title=ModuleLoaded::$actionModuleName Loaded from Path - $($actionModulePath)" | Out-Host
    return
}

git pull | Out-Host


#region Load Action Module
$ActionModuleName     = "EZOut"
$ActionModuleFileName = "$ActionModuleName.psd1"

# Try to find a local copy of the action's module.
# This allows the action to use the current branch's code instead of the action's implementation.
$PSD1Found = Get-ChildItem -Recurse -Filter "*.psd1" |
    Where-Object Name -eq $ActionModuleFileName | 
    Select-Object -First 1

$ActionModulePath, $ActionModule = 
    # If there was a .PSD1 found
    if ($PSD1Found) {
        $PSD1Found.FullName # import from there.
        Import-Module $PSD1Found.FullName -Force -PassThru
    } 
    # Otherwise, if we have a GITHUB_ACTION_PATH
    elseif ($env:GITHUB_ACTION_PATH) 
    {
        $actionModulePath = Join-Path $env:GITHUB_ACTION_PATH $ActionModuleFileName
        if (Test-path $actionModulePath) {
            $actionModulePath
            Import-Module $actionModulePath -Force -PassThru
        } else {
            throw "$actionModuleName not found"
        }
    } 
    elseif (-not (Get-Module $ActionModuleName)) {
        throw "$actionModulePath could not be loaded."
    }

"::notice title=ModuleLoaded::$actionModuleName Loaded from Path - $($actionModulePath)" | Out-Host
#endregion Load Action Module

#region Declare Functions and Variables
$anyFilesChanged = $false
filter ProcessScriptOutput {
    $out = $_
    $outItem = Get-Item -Path $out -ErrorAction SilentlyContinue
    $fullName, $shouldCommit = 
        if ($out -is [IO.FileInfo]) {
            $out.FullName, (git status $out.Fullname -s)
        } elseif ($outItem) {
            $outItem.FullName, (git status $outItem.Fullname -s)
        }
    if ($shouldCommit) {
        git add $fullName
        if ($out.Message) {
            git commit -m "$($out.Message)"
        } elseif ($out.CommitMessage) {
            git commit -m "$($out.CommitMessage)"
        } elseif ($gitHubEvent.head_commit.message) {
            git commit -m "$($gitHubEvent.head_commit.message)"
        }
        $anyFilesChanged = $true
    }
    $out
}

#endregion Declare Functions and Variables


#region Actual Action

$EZOutScriptStart = [DateTime]::Now
if ($EZOutScript) {
    Invoke-Expression -Command $EZOutScript |
        . processScriptOutput |
        Out-Host
}
$EZOutScriptTook = [Datetime]::Now - $EZOutScriptStart
"::set-output name=EZOutScriptRuntime::$($EZOutScriptTook.TotalMilliseconds)"   | Out-Host

$EZOutPS1Start = [DateTime]::Now
$EZOutPS1List  = @()
if (-not $SkipEZOutPS1) {
    $ezOutFiles = @(
    Get-ChildItem -Recurse -Path $env:GITHUB_WORKSPACE |
        Where-Object Name -Match '\.EZ(Out|Format)\.ps1$')
        
    if ($ezOutFiles) {
        $ezOutFiles|        
        ForEach-Object {
            $EZOutPS1List += $_.FullName.Replace($env:GITHUB_WORKSPACE, '').TrimStart('/')
            $EZOutPS1Count++
            "::notice title=Running::$($_.Fullname)" | Out-Host
            . $_.FullName |            
                . processScriptOutput  | 
                Out-Host
        }
    } else {
        Write-EZFormatFile -ModuleName $ModuleName | Set-Content "$moduleName.ezout.ps1" -Encoding utf8
        $anyFilesChanged = $true
    }
}

$EZOutPS1EndStart = [DateTime]::Now
$EZOutPS1Took = [Datetime]::Now - $EZOutPS1Start
"::set-output name=EZOutPS1Count::$($EZOutPS1List.Length)"   | Out-Host
"::set-output name=EZOutPS1Files::$($EZOutPS1List -join ';')"   | Out-Host
"::set-output name=EZOutPS1Runtime::$($EZOutPS1Took.TotalMilliseconds)"   | Out-Host
if ($CommitMessage -or $anyFilesChanged) {
    if ($CommitMessage) {
        dir $env:GITHUB_WORKSPACE -Recurse |
            ForEach-Object {
                $gitStatusOutput = git status $_.Fullname -s
                if ($gitStatusOutput) {
                    git add $_.Fullname
                }
            }

        git commit -m $ExecutionContext.SessionState.InvokeCommand.ExpandString($CommitMessage)
    }    

    $checkDetached = git symbolic-ref -q HEAD
    if (-not $LASTEXITCODE) {
        "::notice::Pulling Updates" | Out-Host
        git pull
        "::notice::Pushing Changes" | Out-Host        
        git push        
        "Git Push Output: $($gitPushed  | Out-String)"
    } else {
        "::notice::Not pushing changes (on detached head)" | Out-Host
        $LASTEXITCODE = 0
        exit 0
    }
}

#endregion Actual Action
