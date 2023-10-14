function Set-PSModuleManifestRootModule {
    [CmdletBinding()]
    param(
        # Path to the module manifest file.
        [Parameter(Mandatory)]
        [string] $ManifestPath,

        # Path to the folder where the module source code is located.
        [Parameter(Mandatory)]
        [string] $SourceFolderPath,

        [Parameter()]
        [string] $RootModule
    )

    $moduleName = Split-Path -Path $SourceFolderPath -Leaf

    $moduleFileName = $(Get-ChildItem -Path $PSScriptRoot -File | Where-Object { $_.BaseName -like $_.Directory.BaseName -and ($_.Extension -in '.psm1', '.ps1', '.dll', '.cdxml', '.xaml') } | Select-Object -First 1 -ExpandProperty Name )
    $moduleFilePath = Join-Path -Path $SourceFolderPath $moduleFileName
    if (Test-Path -Path $moduleFilePath) {
        $RootModule = [string]::IsNullOrEmpty($RootModule) ? $moduleFileName : $RootModule
    } else {
        $RootModule = $null
    }
    Write-Verbose "[$moduleName] - [RootModule] - [$RootModule]"

    $moduleType = switch -Regex ($manifest.RootModule) {
        '\.(ps1|psm1)$' { 'Script' }
        '\.dll$' { 'Binary' }
        '\.cdxml$' { 'CIM' }
        '\.xaml$' { 'Workflow' }
        default { 'Manifest' }
    }
    Write-Verbose "[$moduleName] - [ModuleType] - [$moduleType]"

    $supportedModuleTypes = @('Script', 'Manifest')
    if ($moduleType -notin $supportedModuleTypes) {
        throw "[$moduleName] - [ModuleType] - [$moduleType] - Module type not supported"
    }

    Update-ModuleManifest -Path $ManifestPath -RootModule $RootModule
}

