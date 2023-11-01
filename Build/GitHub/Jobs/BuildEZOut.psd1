@{
    "runs-on" = "ubuntu-latest"    
    if = '${{ success() }}'
    steps = @(
        @{
            name = 'Check out repository'
            uses = 'actions/checkout@v2'
        }, 
        @{
            name = 'Setup GO'
            uses = 'actions/setup-go@v4'
        },
        @{    
            name = 'Use PSSVG Action'
            uses = 'StartAutomating/PSSVG@main'
            id = 'PSSVG'
        },
        'RunPiecemeal',
        @{    
            name = 'Initialize Splatter'
            uses = 'StartAutomating/Splatter@main'
            id = 'Splatter'
        },
        'RunPipeScript',
        @{
            name = 'Run EZOut  (on master)'
            if   = '${{github.ref_name == ''master''}}'
            uses = 'StartAutomating/EZOut@master'
            id = 'EZOutMaster'
        },
        @{
            name = 'Run EZOut (on branch)'
            if   = '${{github.ref_name != ''master''}}'
            uses = './'
            id = 'EZOutBranch'
        },
        'RunHelpOut',        
        @{
            name = 'GitLogger'
            uses = 'GitLogging/GitLoggerAction@main'
            id = 'GitLogger'
        },
        @{
            name = 'PSA'
            uses = 'StartAutomating/PSA@main'
            id = 'PSA'
        }
    )
}