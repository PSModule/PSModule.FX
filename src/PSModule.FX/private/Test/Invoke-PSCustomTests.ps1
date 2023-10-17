function Invoke-PSCustomTests {
    [CmdletBinding()]
    param(
        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $ModuleFolder,

        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $TestFolderPath
    )

    $containerParams = @{
        Path = $TestFolderPath
        Data = @{
            Path = $ModuleFolder
        }
    }
    Write-Verbose 'ContainerParams:'
    Write-Verbose "$($containerParams | ConvertTo-Json -Depth 5)"


    $pesterParams = @{
        Configuration = @{
            Run        = @{
                Container = New-PesterContainer @containerParams
                PassThru  = $false
            }
            TestResult = @{
                TestSuiteName = 'PSSA'
                OutputPath    = '.\outputs\CustomTest.Results.xml'
                OutputFormat  = 'NUnitXml'
                Enabled       = $true
            }
            Output     = @{
                Verbosity           = 'Detailed'
                StackTraceVerbosity = 'None'
            }
        }
        ErrorAction   = 'Stop'
    }

    Write-Verbose 'PesterParams:'
    Write-Verbose "$($pesterParams | ConvertTo-Json -Depth 5)"

    Invoke-Pester @pesterParams

}
