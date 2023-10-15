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
    Write-Verbose "   PowerShell       $($PSVersionTable.PSVersion.ToString())" -Verbose
    Write-Verbose "   Pester           $($pesterModule.version)" -Verbose
    Write-Verbose "   PSScriptAnalyzer $($PSSAModule.version)" -Verbose

    $containerParams = @{
        Path = (Join-Path $repoRootPath $moduleTestFilePath)
        Data = @{
            Path = $moduleFolder.FullName
        }
    }
    $container = New-PesterContainer @containerParams

    

    Invoke-Pester -Configuration @{
        Run        = @{
            Container = $container
            PassThru  = $true
        }
        TestResult = @{
            TestSuiteName = 'PSSA'
            OutputPath    = 'C:\Repos\GitHub\PSModule\Demo\outputs\PSSA.Results.xml'
            OutputFormat  = 'NUnitXml'
            Enabled       = $true
        }
        Output     = @{
            Verbosity = 'Detailed'
        }
    } -ErrorAction 'Stop'
}
