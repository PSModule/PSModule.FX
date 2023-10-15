function Add-PSModulePath {
    [CmdletBinding()]
    param(
        # Path to the folder where the module source code is located.
        [Parameter(Mandatory)]
        [string] $Path
    )

    if ($IsWindows) {
        $PSModulePathSeparator = ';'
    } else {
        $PSModulePathSeparator = ':'
    }
    $env:PSModulePath += "$PSModulePathSeparator$Path"

    Write-Verbose "PSModulePath:"
    $env:PSModulePath.Split($PSModulePathSeparator) | ForEach-Object {
        Write-Verbose " - [$_]"
    }
}
