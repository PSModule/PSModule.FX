function Invoke-PSModuleTest {
    param(
        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $ModuleFolderPath
    )

    $moduleName = Split-Path -Path $ModuleFolderPath -Leaf

    Write-Output "::group::[$moduleName]"
    Write-Verbose "ModuleFolderPath - [$ModuleFolderPath]"

    Write-Verbose "[$moduleName] - Invoke-ScriptAnalyzer"
    $moduleFolder = Get-Item -Path $ModuleFolderPath
    Invoke-PSScriptAnalyzerTest -ModuleFolder $moduleFolder -Verbose:$false

    Write-Verbose "[$moduleName] - Invoke-PSCustomTests - PSModule defaults"
    $TestFolderPath = Join-Path -Path $PSScriptRoot -ChildPath 'tests' 'PSModule'
    Invoke-PSCustomTests -ModuleFolder $moduleFolder -TestFolderPath $TestFolderPath -Verbose:$false

    # Write-Output "::group::[$moduleName] - Invoke-PSCustomTests - [$moduleName] specific tests"
    # $TestFolderPath = Join-Path -Path $ModuleFolderPath -ChildPath 'tests' $moduleName

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
