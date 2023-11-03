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
        [string] $ModuleFolderPath,

        # Path to the folder where the custom tests are located.
        [Parameter()]
        [string] $CustomTestsPath
    )
    $containers = @()
    Write-Verbose "ModuleFolderPath - [$ModuleFolderPath]"

    $moduleName = Split-Path -Path $ModuleFolderPath -Leaf
    Write-Host "::group::[$moduleName] - PSScriptAnalyzer"
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
    Write-Host '::endgroup::'

    Write-Host "::group::[$moduleName] - PSModule"
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
    Write-Host '::endgroup::'

    Write-Host "::group::[$moduleName] - Module specific tests"
    if ($CustomTestsPath) {
        Write-Verbose "[$moduleName] - [$CustomTestsPath] - Checking for tests"
        if (Test-Path -Path $CustomTestsPath) {
            $containerParams = @{
                Path = $CustomTestsPath
                Data = @{
                    Path = $ModuleFolderPath
                }
            }
            Write-Verbose 'ContainerParams:'
            Write-Verbose "$($containerParams | ConvertTo-Json -Depth 5)"
            $containers += New-PesterContainer @containerParams
        } else {
            Write-Warning "[$moduleName] - [$CustomTestsPath] - No tests found"
        }
    } else {
        Write-Warning "[$moduleName] - No custom tests path specified"
    }
    Write-Host '::endgroup::'

    Write-Host "::group::[$moduleName] - Invoke-Pester"
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
    Write-Verbose "$($pesterParams | ConvertTo-Json)"
    Write-Host '::endgroup::'

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
