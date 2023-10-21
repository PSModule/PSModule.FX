function Invoke-PSModuleTest {
    param(
        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $ModuleFolderPath
    )
    Write-Output "::endgroup::"
    Write-Verbose "ModuleFolderPath - [$ModuleFolderPath]"


    $moduleName = Split-Path -Path $ModuleFolderPath -Leaf
    Write-Verbose "[$moduleName] - Invoke-ScriptAnalyzer"
    $moduleFolder = Get-Item -Path $ModuleFolderPath
    Invoke-PSScriptAnalyzerTest -ModuleFolder $moduleFolder -Verbose:$false

    Write-Verbose "[$moduleName] - Invoke-PSCustomTests - PSModule defaults"
    $testFolderPath = Join-Path -Path $PSScriptRoot -ChildPath 'tests' 'PSModule'
    Invoke-PSCustomTests -ModuleFolder $moduleFolder -TestFolderPath $TestFolderPath -Verbose:$false

    Write-Verbose "[$moduleName] - Invoke-PSCustomTests - Specific tests"
    $testFolderPath = Join-Path -Path $PSScriptRoot -ChildPath 'tests' $moduleName
    if (Test-Path -Path $testFolderPath) {
        Invoke-PSCustomTests -ModuleFolder $moduleFolder -TestFolderPath $testFolderPath -Verbose:$false
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
