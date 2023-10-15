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

    Write-Verbose 'Testing with:'
    Write-Verbose "   PowerShell       $($PSVersionTable.PSVersion.ToString())"
    Write-Verbose "   Pester           $($pesterModule.version)"
    Write-Verbose "   PSScriptAnalyzer $($PSSAModule.version)"

    $containerParams = @{
        Path = (Join-Path $PSScriptRoot 'tests' 'PSSA.Tests.ps1')
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
        Verbose       = $false
    }
    Write-Verbose 'PesterParams:'
    Write-Verbose "$($pesterParams | ConvertTo-Json -Depth 5)"

    Invoke-Pester @pesterParams

}
