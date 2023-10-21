﻿function Show-FileContent {
    <#
        .SYNOPSIS
        Prints the content of a file with line numbers in front of each line.

        .DESCRIPTION
        Prints the content of a file with line numbers in front of each line.

        .EXAMPLE
        $Path = 'C:\Repos\GitHub\PSModule\Framework\PSModule.FX\src\PSModule.FX\private\Utilities\Show-FileContent.ps1'
        Show-FileContent -Path $Path

        Shows the content of the file with line numbers in front of each line.
    #>
    [CmdletBinding()]
    param (
        # The path to the file to show the content of.
        [Parameter(Mandatory)]
        [string]$Path
    )

    $content = Get-Content -Path $Path
    $lineNumber = 1
    # Foreach line print the line number in front of the line with [    ] around it. The linenumber should dynamically adjust to the number of digits with the length of the file.
    foreach ($line in $content) {
        $lineNumberFormatted = $lineNumber.ToString().PadLeft($content.Count.ToString().Length)
        '[{0}] {1}' -f $lineNumberFormatted, $line
        $lineNumber++
    }
}
