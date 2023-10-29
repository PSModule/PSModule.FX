function Invoke-PSModuleBuild {
    <#
        .SYNOPSIS
        Builds a module.

        .DESCRIPTION
        Builds a module.

        .EXAMPLE
        Invoke-PSModuleBuild -ModuleFolderPath $ModuleFolderPath -ModulesOutputFolder $ModulesOutputFolder -DocsOutputFolder $DocsOutputFolder

        Builds a module located at $ModuleFolderPath and outputs the built module to $ModulesOutputFolder and the documentation to $DocsOutputFolder.
    #>
    [CmdletBinding()]
    param(
        # Path to the folder where the module source code is located.
        [Parameter(Mandatory)]
        [string] $ModuleFolderPath,

        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $ModulesOutputFolder,

        # Path to the folder where the built module documentation is outputted.
        [Parameter(Mandatory)]
        [string] $DocsOutputFolder
    )
    #DECISION: The manifest file = name of the folder.
    #DECISION: The basis of the module manifest comes from the defined manifest file.
    #DECISION: Values that are not defined in the module manifest file are generated from reading the module files.
    #DECISION: If no RootModule is defined in the manifest file, we assume a .psm1 file with the same name as the module is on root.
    #DECISION: Currently only Script and Manifest modules are supported.
    #DECISION: The output folder = .\outputs on the root of the repo.
    #DECISION: The module that is build is stored under the output folder in a folder with the same name as the module.
    #DECISION: A new module manifest file is created every time to get a new GUID, so that the specific version of the module can be imported.

    $moduleName = Split-Path -Path $ModuleFolderPath -Leaf

    Write-Output "::group::[$moduleName]"
    Write-Verbose "ModuleFolderPath - [$ModuleFolderPath]"

    $moduleSourceFolder = Get-Item -Path $ModuleFolderPath

    Build-PSModuleBase -SourceFolderPath $moduleSourceFolder -OutputFolderPath $modulesOutputFolder
    Build-PSModuleRootModule -SourceFolderPath $moduleSourceFolder -OutputFolderPath $modulesOutputFolder
    Build-PSModuleManifest -SourceFolderPath $moduleSourceFolder -OutputFolderPath $modulesOutputFolder

    Import-PSModule -SourceFolderPath $moduleSourceFolder -ModuleName $moduleName

    $moduleOutputFolder = Join-Path $modulesOutputFolder $moduleName
    $docOutputFolder = Join-Path $docsOutputFolder $moduleName
    Build-PSModuleDocumentation -SourceFolderPath $moduleOutputFolder -OutputFolderPath $docOutputFolder

    Write-Verbose "[$moduleName] - Done"
}
