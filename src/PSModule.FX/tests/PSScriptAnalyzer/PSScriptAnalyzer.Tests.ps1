[CmdLetBinding()]
Param(
    [Parameter(Mandatory)]
    [string] $Path,

    [Parameter(Mandatory)]
    [string] $SettingsFilePath
)
BeforeDiscovery {
    # Get all PSScript Analyzer Rules and save them in an array
    $rules = Get-ScriptAnalyzerRule | Sort-Object -Property Severity
    Write-Warning "Discovered [$($rules.Count)] rules"
}

BeforeAll {
    $testResults = Invoke-ScriptAnalyzer -Path $Path -Settings $SettingsFilePath -Recurse
    Write-Warning "Found [$($testResults.Count)] issues"
}
# Line                 : 20
# Column               : 21
# Message              : Use space before and after binary and assignment operators.
# Extent               : =
# RuleName             : PSUseConsistentWhitespace
# Severity             : Warning
# ScriptName           : PSScriptAnalyzer.Tests.ps1
# ScriptPath           : C:\Repos\GitHub\PSModule\Framework\PSModule.FX\src\PSModule.FX\tests\PSScriptAnalyzer\PSScriptAnalyzer.Tests.ps1
# RuleSuppressionID    :
# SuggestedCorrections : {Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent}
# IsSuppressed         : False

Describe "PSScriptAnalyzer tests using settings file [$SettingsFilePath]" {
    It '<CommonName> (<RuleName>)' -ForEach $rules {
        param ($RuleName)

        $issues = $testResults | Where-Object -Property RuleName -eq $RuleName | ForEach-Object {
            $relativePath = $_.ScriptPath.Replace($Path, '')
            $suggestion = $_.SuggestedCorrections
            "$([Environment]::NewLine)$relativePath`:L$($_.Line):C$($_.Column): $($_.Message)"
        }
        $issues | Should -BeNullOrEmpty -Because $suggestion
    }
}
