﻿#Requires -Modules platyPS

function Publish-PSModule {
    <#
        .SYNOPSIS
        Publishes a module to the PowerShell Gallery and GitHub Pages.

        .DESCRIPTION
        Publishes a module to the PowerShell Gallery and GitHub Pages.

        .EXAMPLE
        Publish-PSModule -Name 'PSModule.FX' -APIKey $env:PSGALLERY_API_KEY
    #>
    [Alias('Release-Module')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Name of the module to process.
        [Parameter()]
        [string] $Name = '*',

        # The API key for the destination repository.
        [Parameter(Mandatory)]
        [string] $APIKey
    )
    $task = New-Object System.Collections.Generic.List[string]
    #region Publish-Module
    $task.Add('Release-Module')
    Write-Host "::group::[$($task -join '] - [')] - Starting..."

    Import-Module PackageManagement, PowerShellGet -Verbose:$false -ErrorAction Stop

    ########################
    # Gather some basic info
    ########################

    $modulesOutputFolderPath = Join-Path -Path 'outputs' 'modules'
    Write-Verbose "Getting module output folder [$modulesOutputFolderPath]"
    $modulesOutputFolder = Get-Item -Path $modulesOutputFolderPath
    Add-PSModulePath -Path $modulesOutputFolder

    $moduleFolders = Get-ChildItem -Path $modulesOutputFolder -Directory | Where-Object { $_.Name -like $Name }

    foreach ($module in $moduleFolders) {
        $moduleName = $module.Name
        $manifestFilePath = "$module\$moduleName.psd1"
        $task.Add($moduleName)
        Write-Host "::group::[$($task -join '] - [')] - Starting..."

        #region Generate-Version
        $task.Add('Generate-Version')
        Write-Host "::group::[$($task -join '] - [')]"
        Write-Verbose "[$($task -join '] - [')] - Generate version"

        [Version]$newVersion = '0.0.0'

        try {
            $onlineVersion = [Version](Find-Module $moduleName -Verbose:$false).Version
        } catch {
            $onlineVersion = $newVersion
            Write-Warning "Could not find module online. Using [$($onlineVersion.ToString())]"
        }
        Write-Warning "Online: [$($onlineVersion.ToString())]"
        $manifestVersion = [Version](Test-ModuleManifest $manifestFilePath -Verbose:$false).Version
        Write-Warning "Manifest: [$($manifestVersion.ToString())]"

        Write-Verbose "branch is: [$env:GITHUB_REF_NAME]"

        if ($manifestVersion.Major -gt $onlineVersion.Major) {
            $newVersionMajor = $manifestVersion.Major
            $newVersionMinor = 0
            $newVersionBuild = 0
        } else {
            $newVersionMajor = $onlineVersion.Major
            if ($manifestVersion.Minor -gt $onlineVersion.Minor) {
                $newVersionMinor = $manifestVersion.Minor
                $newVersionBuild = 0
            } else {
                $newVersionMinor = $onlineVersion.Minor
                $newVersionBuild = $onlineVersion.Build + 1
            }
        }
        [Version]$newVersion = [version]::new($newVersionMajor, $newVersionMinor, $newVersionBuild)
        Write-Warning "newVersion: [$($newVersion.ToString())]"

        Write-Verbose "[$($task -join '] - [')] - Create draft release with version"
        gh release create $newVersion --title $newVersion --generate-notes --draft --target $env:GITHUB_REF_NAME

        if ($env:GITHUB_REF_NAME -ne 'main') {
            Write-Verbose "[$($task -join '] - [')] - Not on main, but on [$env:GITHUB_REF_NAME]"
            Write-Verbose "[$($task -join '] - [')] - Generate pre-release version"
            $prerelease = $env:GITHUB_REF_NAME -replace '[^a-zA-Z0-9]', ''
            Write-Verbose "[$($task -join '] - [')] - Prerelease is: [$prerelease]"
            if ($newVersion -ge [version]'1.0.0') {
                Write-Verbose "[$($task -join '] - [')] - Version is greater than 1.0.0 -> Update-ModuleManifest with prerelease [$prerelease]"
                Update-ModuleManifest -Path $manifestFilePath -Prerelease $prerelease -ErrorAction Continue
                gh release edit $newVersion -tag "$newVersion-$prerelease" --prerelease
            }
        }

        Write-Verbose "[$($task -join '] - [')] - Bump module version -> module metadata: Update-ModuleMetadata"
        Update-ModuleManifest -Path $manifestFilePath -ModuleVersion $newVersion -ErrorAction Continue

        Write-Host "::group::[$($task -join '] - [')] - Done"
        $task.RemoveAt($task.Count - 1)
        #endregion Generate-Version

        #region Publish-Docs
        $task.Add('Publish-Docs')
        Write-Host "::group::[$($task -join '] - [')]"
        Write-Host "::group::[$($task -join '] - [')] - Do something"

        Write-Verbose "[$($task -join '] - [')] - Publish docs to GitHub Pages"
        Write-Verbose "[$($task -join '] - [')] - Update docs path: Update-ModuleMetadata"
        # What about updateable help? https://learn.microsoft.com/en-us/powershell/scripting/developer/help/supporting-updatable-help?view=powershell-7.3

        Write-Host "::group::[$($task -join '] - [')] - Done"
        $task.RemoveAt($task.Count - 1)
        #endregion Publish-Docs

        #region Publish-ToPSGallery
        $task.Add('Publish-ToPSGallery')
        Write-Host "::group::[$($task -join '] - [')]"
        Write-Host "::group::[$($task -join '] - [')] - Do something"

        Write-Verbose "[$($task -join '] - [')] - Publish module to PowerShell Gallery using [$APIKey]"
        Publish-Module -Path "$module" -NuGetApiKey $APIKey

        Write-Verbose "[$($task -join '] - [')] - Publish GitHub release for [$newVersion]"
        gh release edit $newVersion --draft=false

        Write-Verbose "[$($task -join '] - [')] - Doing something"
        Write-Host "::group::[$($task -join '] - [')] - Done"
        $task.RemoveAt($task.Count - 1)
        #endregion Publish-ToPSGallery

    }

    $task.RemoveAt($task.Count - 1)
    Write-Host "::group::[$($task -join '] - [')] - Stopping..."
    Write-Host '::endgroup::'
    #endregion Publish-Module

}
