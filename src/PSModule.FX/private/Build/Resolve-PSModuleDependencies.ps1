function Resolve-PSModuleDependencies {
    <#
    .SYNOPSIS
    Resolve dependencies for a module based on the manifest file.

    .DESCRIPTION
    Resolve dependencies for a module based on the manifest file, following PSModuleInfo structure

    .EXAMPLE
    Resolve-PSModuleDependencies -Path 'C:\MyModule\MyModule.psd1'

    Installs all modules defined in the manifest file, following PSModuleInfo structure.

    .NOTES
    Should later be adapted to support both pre-reqs, and dependencies.
    Should later be adapted to take 4 parameters sets: specific version ("requiredVersion" | "GUID"), latest version ModuleVersion, and latest version within a range MinimumVersion - MaximumVersion.
    #>
    [CmdletBinding()]
    param(
        # The path to the manifest file.
        [Parameter(Mandatory)]
        [string] $ManifestFilePath
    )
    $action = $MyInvocation.MyCommand.Name

    $manifest = Import-PowerShellDataFile -Path $ManifestFilePath
    Write-Verbose "[$action] - Reading [$ManifestFilePath]"
    Write-Verbose "[$action] - Found [$($manifest.RequiredModules.Count)] modules to install"

    foreach ($requiredModule in $manifest.RequiredModules) {
        $installParams = @{}

        if ($requiredModule -is [string]) {
            $installParams.Name = $requiredModule
        } else {
            $installParams.Name = $requiredModule.ModuleName
            $installParams.MinimumVersion = $requiredModule.ModuleVersion
            $installParams.RequiredVersion = $requiredModule.RequiredVersion
            $installParams.MaximumVersion = $requiredModule.MaximumVersion
        }
        $installParams.Verbose = $false
        $installParams.Force = $true

        Write-Verbose "[$action] - [$($installParams.Name)] - Installing module"
        Install-Module @installParams
        Write-Verbose "[$action] - [$($installParams.Name)] - Done"
    }
    Write-Verbose "[$action] - Done"
}
