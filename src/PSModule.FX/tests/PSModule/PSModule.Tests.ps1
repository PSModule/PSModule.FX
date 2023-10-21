[CmdLetBinding()]
Param(
    [Parameter(Mandatory)]
    [string] $Path
)
BeforeDiscovery {
    $scriptFiles = Get-ChildItem -Path $Path -Filter '*.ps1' -Recurse -File | ForEach-Object {
        $fileContent = Get-Content -Path $_.FullName -Raw
        if ($fileContent -match '(?:function|filter)\s+([a-zA-Z][a-zA-Z0-9-]*)') {
            $functionName = $matches[1]
            Write-Host "Function/filter name is: $functionName"
            $item = @{
                fileName     = $_.BaseName
                filePath     = $_.FullName.Replace($Path, '').Trim('\').Trim('/')
                functionName = $functionName
            }
            $item
        }
    }
}

Describe 'Module design tests' {
    It 'File name and function name should match' -ForEach $scriptFiles {
        $fileName | Should -BeExactly $functionName -Because "Script files should be called the same as the function they contain"
    }

    # It 'Script file should only contain max one function or filter' {}
}
