function Invoke-PSModuleTest {
    <#
        .SYNOPSIS
        Performs tests on a module.

        .DESCRIPTION
        Performs tests on a module.

        .EXAMPLE
        Invoke-PSModuleTest -ModuleFolderPath $ModuleFolderPath

        Performs tests on a module located at $ModuleFolderPath.
    #>
    [OutputType([int])]
    [CmdletBinding()]
    param(
        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $ModuleFolderPath
    )
    $containers = @()
    Write-Verbose "ModuleFolderPath - [$ModuleFolderPath]"

    $moduleName = Split-Path -Path $ModuleFolderPath -Leaf
    Write-Host "::group::[$moduleName] - Invoke-ScriptAnalyzer"
    $containerParams = @{
        Path = (Join-Path -Path $PSScriptRoot -ChildPath 'tests' 'PSScriptAnalyzer' 'PSScriptAnalyzer.Tests.ps1')
        Data = @{
            Path             = $ModuleFolderPath
            SettingsFilePath = (Join-Path -Path $PSScriptRoot -ChildPath 'tests' 'PSScriptAnalyzer' 'PSScriptAnalyzer.Tests.psd1')
        }
    }
    Write-Verbose 'ContainerParams:'
    Write-Verbose "$($containerParams | ConvertTo-Json)"
    $containers += New-PesterContainer @containerParams
    Write-Host "::endgroup::"

    Write-Host "::group::[$moduleName] - Invoke-PSCustomTests - PSModule defaults"
    $testFolderPath = Join-Path -Path $PSScriptRoot -ChildPath 'tests' 'PSModule'
    $containerParams = @{
        Path = $testFolderPath
        Data = @{
            Path = $ModuleFolderPath
        }
    }
    Write-Verbose 'ContainerParams:'
    Write-Verbose "$($containerParams | ConvertTo-Json -Depth 5)"
    $containers += New-PesterContainer @containerParams
    Write-Host "::endgroup::"

    Write-Host "::group::[$moduleName] - Invoke-PSCustomTests - Specific tests"
    $testFolderPath = Join-Path -Path (Split-Path -Path (Split-Path -Path $ModuleFolderPath -Parent) -Parent) -ChildPath 'tests' $moduleName
    Write-Verbose "[$moduleName] - [$testFolderPath] - Checking for tests"
    if (Test-Path -Path $testFolderPath) {
        $containerParams = @{
            Path = $testFolderPath
            Data = @{
                Path = $ModuleFolderPath
            }
        }
        Write-Verbose 'ContainerParams:'
        Write-Verbose "$($containerParams | ConvertTo-Json -Depth 5)"
        $containers += New-PesterContainer @containerParams
    } else {
        Write-Warning "[$moduleName] - [$testFolderPath] - No tests found"
    }
    Write-Host '::endgroup::'

    $pesterParams = @{
        Configuration = @{
            Run          = @{
                Container = $containers
                PassThru  = $false
            }
            TestResult   = @{
                Enabled       = $true
                OutputFormat  = 'NUnitXml'
                OutputPath    = '.\outputs\PSModuleTest.Results.xml'
                TestSuiteName = 'PSModule Test'
            }
            CodeCoverage = @{
                Enabled               = $true
                OutputPath            = '.\outputs\CodeCoverage.xml'
                OutputFormat          = 'JaCoCo'
                OutputEncoding        = 'UTF8'
                CoveragePercentTarget = 75
            }
            Output       = @{
                CIFormat            = 'Auto'
                StackTraceVerbosity = 'None'
                Verbosity           = 'Detailed'
            }
        }
        Verbose       = $false
    }

    Write-Verbose 'PesterParams:'
    Write-Verbose "$($pesterParams | ConvertTo-Json -Depth 5)"

    Invoke-Pester @pesterParams
    $failedTests = $LASTEXITCODE

    if ($failedTests -gt 0) {
        Write-Error "[$moduleName] - [$failedTests] tests failed"
    } else {
        Write-Verbose "[$moduleName] - All tests passed"
    }

    Write-Verbose "[$moduleName] - Done"
    return $failedTests
}

# <#
# Run tests from ".\tests\$moduleName.Tests.ps1"
# # Import the module using Import-Module $moduleManifestFilePath,
# # Do not not just add the outputted module file to the PATH of the runner (current context is enough) $env:PATH += ";.\outputs\$moduleName" as the import-module will actually test that the module is importable.
# #>

# <#
# Run tests from ".\tests\$moduleName.Tests.ps1"
# #>

# <#
# Test-ModuleManifest -Path $Path
# #>
