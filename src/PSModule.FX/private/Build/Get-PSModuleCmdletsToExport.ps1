function Get-PSModuleCmdletsToExport {
    [CmdletBinding()]
    param(
        # Path to the folder where the module source code is located.
        [Parameter(Mandatory)]
        [string] $SourceFolderPath
    )

    $moduleName = Split-Path -Path $SourceFolderPath -Leaf
    $manifestPropertyName = 'CmdletsToExport'

    $manifest = Get-PSModuleManifest -SourceFolderPath $SourceFolderPath -Verbose:$false

    Write-Verbose "[$moduleName] - [$manifestPropertyName]"
    $cmdletsToExport = ($manifest.CmdletsToExport).count -eq 0 ? @() : @($manifest.CmdletsToExport)
    $cmdletsToExport | ForEach-Object { Write-Verbose "[$moduleName] - [$manifestPropertyName] - [$_]" }
    $cmdletsToExport
}
