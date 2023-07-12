#requires -Module EZOut
#requires -Module PSDevOps
Import-BuildStep -ModuleName EZOut
Push-Location ($PSScriptRoot | Split-Path)
New-GitHubWorkflow -Name "Test, Tag, Release, and Publish" -On Demand, Push -Job PowerShellStaticAnalysis, 
    TestPowerShellOnLinux,
    TagReleaseAndPublish,
    BuildEZOut -OutputPath (
        Join-Path $pwd .\.github\workflows\TestReleaseAndPublish.yml
    )    

New-GitHubWorkflow -On Issue, Demand -Job RunGitPub -Name OnIssueChanged -OutputPath (
    Join-Path $pwd .github\workflows\OnIssue.yml
)

Pop-Location