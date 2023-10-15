function Build-PSModuleDocumentation {
    [CmdletBinding()]
    param(
        # Path to the folder where the module source code is located.
        [Parameter(Mandatory)]
        [string] $SourceFolderPath,

        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $OutputFolderPath
    )

    $moduleName = Split-Path -Path $SourceFolderPath -Leaf
    Write-Output "::group::[$moduleName] - Build documentation"

    $manifestFile = Get-PSModuleManifest -SourceFolderPath $SourceFolderPath -As FileInfo -Verbose:$false
    Resolve-PSModuleDependencies -ManifestFilePath $manifestFile

    Write-Verbose "[$moduleName] - Importing module"
    $env:PSModulePath += ";$SourceFolderPath"
    Import-Module $moduleName

    Write-Verbose "[$moduleName] - List loaded modules"
    $availableModules = Get-Module -Verbose:$false
    $availableModules | Select-Object Name, Version, PreRelease, ModuleType, Author, CompanyName

    if ($moduleName -notin $availableModules) {
        throw "[$moduleName] - Module not found"
    }
    New-MarkdownHelp -Module $moduleName -OutputFolder $OutputFolderPath -Force
    Write-Output '::endgroup::'

}
