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

"::group::Parameters" | Out-Host
[PSCustomObject]$PSBoundParameters | Format-List | Out-Host
"::endgroup::" | Out-Host

$gitHubEvent = if ($env:GITHUB_EVENT_PATH) {
    [IO.File]::ReadAllText($env:GITHUB_EVENT_PATH) | ConvertFrom-Json
} else { $null }

$PSD1Found = Get-ChildItem -Recurse -Filter "*.psd1" |
    Where-Object Name -eq 'EZOut.psd1' | 
    Select-Object -First 1

if ($PSD1Found) {
    $EZOutModulePath = $PSD1Found
    Import-Module $PSD1Found -Force -PassThru | Out-Host
} 
elseif ($env:GITHUB_ACTION_PATH) {
    $EZOutModulePath = Join-Path $env:GITHUB_ACTION_PATH 'EZOut.psd1'
    if (Test-path $EZOutModulePath) {
        Import-Module $EZOutModulePath -Force -PassThru | Out-String
    } else {
        throw "EZOut not found"
    }
} 
elseif (-not (Get-Module EZOut)) {
    throw "Action Path not found"
}

"::notice title=ModuleLoaded::EZOut Loaded from Path - $($EZOutModulePath)" | Out-Host

$anyFilesChanged = $false
$processScriptOutput = { process { 
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
} }


if (-not $UserName) { $UserName = $env:GITHUB_ACTOR }
if (-not $UserEmail) { $UserEmail = "$UserName@github.com" }
git config --global user.email $UserEmail
git config --global user.name  $UserName

if (-not $env:GITHUB_WORKSPACE) { throw "No GitHub workspace" }

git pull | Out-Host

$EZOutScriptStart = [DateTime]::Now
if ($EZOutScript) {
    Invoke-Expression -Command $EZOutScript |
        . $processScriptOutput |
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
                . $processScriptOutput  | 
                Out-Host
        }
    } else {
        Write-EZFormatFile -ModuleName $ModuleName | Invoke-Expression
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
        "::notice::Pushing Changes" | Out-Host
        git push        
        "Git Push Output: $($gitPushed  | Out-String)"
    } else {
        "::notice::Not pushing changes (on detached head)" | Out-Host
        $LASTEXITCODE = 0
        exit 0
    }
}
