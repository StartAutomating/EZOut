#requires -Module EZOut
#requires -Module PSDevOps

Import-BuildStep -SourcePath (
    Join-Path $PSScriptRoot 'GitHub'
) -BuildSystem GitHubWorkflow

Push-Location ($PSScriptRoot | Split-Path)
New-GitHubWorkflow -Name "Test, Tag, Release, and Publish" -On Demand, Push -Job PowerShellStaticAnalysis, 
    TestPowerShellOnLinux,
    TagReleaseAndPublish,
    BuildEZOut -OutputPath (
        Join-Path $pwd .\.github\workflows\TestReleaseAndPublish.yml
    ) -Env ([Ordered]@{
        "AT_PROTOCOL_HANDLE" = "mrpowershell.bsky.social"
        "AT_PROTOCOL_APP_PASSWORD" = '${{ secrets.AT_PROTOCOL_APP_PASSWORD }}'
        REGISTRY = 'ghcr.io'
        IMAGE_NAME = '${{ github.repository }}'
    })   

New-GitHubWorkflow -On Demand -Job RunGitPub -Name OnIssueChanged -OutputPath (
    Join-Path $pwd .github\workflows\GitPub.yml
)

New-GitHubWorkflow -On Demand -Name 'show-demo-psa' -Job SendPSA -OutputPath (
    Join-Path $pwd .\.github\workflows\SendPSA.yml
) -Env ([Ordered]@{
    "AT_PROTOCOL_HANDLE" = "mrpowershell.bsky.social"
    "AT_PROTOCOL_APP_PASSWORD" = '${{ secrets.AT_PROTOCOL_APP_PASSWORD }}'
    REGISTRY = 'ghcr.io'
    IMAGE_NAME = '${{ github.repository }}'
})


Pop-Location