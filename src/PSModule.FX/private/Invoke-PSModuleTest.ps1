function Invoke-PSModuleTest {
    param(
        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $ModuleFolderPath
    )
    $failedTests = 0
    Write-Output "::endgroup::"
    Write-Verbose "ModuleFolderPath - [$ModuleFolderPath]"

    $moduleName = Split-Path -Path $ModuleFolderPath -Leaf
    Write-Verbose "[$moduleName] - Invoke-ScriptAnalyzer"
    $moduleFolder = Get-Item -Path $ModuleFolderPath
    $failedTests += Invoke-PSScriptAnalyzerTest -ModuleFolder $moduleFolder -Verbose:$false

    Write-Verbose "[$moduleName] - Invoke-PSCustomTests - PSModule defaults"
    $testFolderPath = Join-Path -Path $PSScriptRoot -ChildPath 'tests' 'PSModule'
    $failedTests += Invoke-PSCustomTests -ModuleFolder $moduleFolder -TestFolderPath $TestFolderPath -Verbose:$false

    Write-Verbose "[$moduleName] - Invoke-PSCustomTests - Specific tests"
    $testFolderPath = Join-Path -Path (Split-Path -Path (Split-Path -Path $ModuleFolderPath -Parent) -Parent) -ChildPath 'tests' $moduleName
    Write-Verbose "[$moduleName] - [$testFolderPath] - Checking for tests"
    if (Test-Path -Path $testFolderPath) {
        $failedTests += Invoke-PSCustomTests -ModuleFolder $moduleFolder -TestFolderPath $testFolderPath -Verbose:$false
    } else {
        Write-Warning "[$moduleName] - [$testFolderPath] - No tests found"
    }

    if ($failedTests -gt 0) {
        Write-Error "[$moduleName] - [$failedTests] tests failed"
        exit $failedTests
    } else {
        Write-Verbose "[$moduleName] - All tests passed"
    }

    Write-Verbose "[$moduleName] - Done"
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
