function Get-PSModuleAliasesToExport {
    [CmdletBinding()]
    param(
        # Path to the folder where the module source code is located.
        [Parameter(Mandatory)]
        [string] $SourceFolderPath
    )

    $moduleName = Split-Path -Path $SourceFolderPath -Leaf
    $manifestPropertyName = 'AliasesToExport'

    $manifest = Get-PSModuleManifest -SourceFolderPath $SourceFolderPath -Verbose:$false

    Write-Verbose "[$moduleName] - [$manifestPropertyName]"
    $aliasesToExport = ($manifest.AliasesToExport).count -eq 0 ? '' : @($manifest.AliasesToExport)
    $aliasesToExport | ForEach-Object { Write-Verbose "[$moduleName] - [$manifestPropertyName] - [$_]" }
    $aliasesToExport
}
