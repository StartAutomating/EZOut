#requires -Module EZOut
#requires -Module PSDevOps
New-GitHubWorkflow -Name "Test, Tag, Release, and Publish" -On Demand, Push -Job PowerShellStaticAnalysis, TestPowerShellOnLinux, TagReleaseAndPublish |
    Set-Content .\.github\workflows\TestReleaseAndPublish.yml -Encoding UTF8
