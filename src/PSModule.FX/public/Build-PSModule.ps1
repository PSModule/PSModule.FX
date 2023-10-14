#Requires -Modules platyPS, PowerShellGet, PackageManagement

function Build-PSModule {
    <#
        .SYNOPSIS
        Builds a PowerShell module

        .DESCRIPTION
        Builds a PowerShell module

        .EXAMPLE
        Build-PSModule -Path 'src' -OutputPath 'outputs'

        Builds all modules in the 'src' folder and stores them in the 'outputs' folder

        .NOTES
        #DECISION: Modules are default located under the '.\src' folder which is the root of the repo.
        #DECISION: Module name = the name of the folder under src. Inherited decision from PowerShell team.
        #DECISION: The module manifest file = name of the folder.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Path to the folder where the modules are located.
        [Parameter()]
        [string] $Path = 'src',

        # Path to the folder where the built modules are outputted.
        [Parameter()]
        [string] $OutputPath = 'outputs'
    )

    Write-Output "::group::[Build-PSModule] - Starting..."

    $moduleFolders = Get-ModuleFolders -Path $Path
    Write-Verbose "[$($task -join '] - [')] - Found $($moduleFolders.Count) module(s)"
    $moduleFolders | ForEach-Object { Write-Verbose "[Build-PSModule] - [$($_.Name)]" }

    # foreach ($moduleFolder in $moduleFolders) {
    #     BuildModule -Path $moduleFolder.FullName -OutputPath $OutputPath
    # }
}
