$root = $PSScriptRoot ? $PSScriptRoot : 'C:\Repos\GitHub\PSModule\Framework\PSModule.FX'


$modulePath = (Join-Path -Path (Split-Path $root -Parent) -ChildPath 'src' 'PSModule.FX')
$containerParams = @{
    Path = (Join-Path -Path $modulePath -ChildPath 'tests' 'PSScriptAnalyzer' 'PSScriptAnalyzer.Tests.ps1')
    Data = @{
        Path             = $modulePath
        SettingsFilePath = (Join-Path -Path $modulePath -ChildPath 'tests' 'PSScriptAnalyzer' 'PSScriptAnalyzer.Settings.psd1')
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
            Enabled       = $true
            TestSuiteName = 'PSScriptAnalyzer'
            OutputPath    = (Join-Path -Path $root -ChildPath 'outputs' 'PSScriptAnalyzer.Results.xml')
            OutputFormat  = 'NUnitXml'
        }
        Output     = @{
            CIFormat            = 'Auto'
            Verbosity           = 'Detailed'
            StackTraceVerbosity = 'None'
        }
    }
    ErrorAction   = 'Stop'
}
Write-Verbose 'PesterParams:'
Write-Verbose "$($pesterParams | ConvertTo-Json -Depth 5)"

Invoke-Pester @pesterParams
