function Invoke-PSSATest {
    [CmdLetBinding()]
    param(
        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $ModuleFolder
    )

    $modules = Get-Module -ListAvailable
    $PSSAModule = $modules | Where-Object Name -EQ PSScriptAnalyzer | Sort-Object Version -Descending | Select-Object -First 1
    $pesterModule = $modules | Where-Object Name -EQ Pester | Sort-Object Version -Descending | Select-Object -First 1

    Write-Verbose 'Testing with:' -Verbose
    Write-Verbose "   PowerShell       $($PSVersionTable.PSVersion.ToString())" -Verbose
    Write-Verbose "   Pester           $($pesterModule.version)" -Verbose
    Write-Verbose "   PSScriptAnalyzer $($PSSAModule.version)" -Verbose

    $containerParams = @{
        Path = (Join-Path -Path $PSScriptRoot -ChildPath 'tests' 'PSScriptAnalyser' 'PSScriptAnalyser.Tests.ps1')
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
                OutputPath    = '.\outputs\PSSA.Results.xml'
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
