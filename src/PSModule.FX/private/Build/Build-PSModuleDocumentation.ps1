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
    Import-Module $moduleName

    Write-Verbose "[$moduleName] - List loaded modules"
    $availableModules = Get-Module -ListAvailable -Refresh -Verbose:$false
    $availableModules | Select-Object Name, Version, Path | Sort-Object Name | Format-Table -AutoSize

    if ($moduleName -notin $availableModules.Name) {
        throw "[$moduleName] - Module not found"
    }

    New-MarkdownHelp -Module $moduleName -OutputFolder $OutputFolderPath -Force -Verbose
    Write-Output '::endgroup::'

    Write-Output "::group::[$moduleName] - Build documentation - Result"
    Get-ChildItem -Path $OutputFolderPath -Recurse -Force -Include '*.md' | ForEach-Object {
        Write-Output "::debug::[$moduleName] - [$_] - [$(Get-FileHash -Path $_.FullName -Algorithm SHA256)]"
    }
    Write-Output '::endgroup::'
}
