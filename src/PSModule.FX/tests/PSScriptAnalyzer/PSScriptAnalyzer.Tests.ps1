[CmdLetBinding()]
Param(
    [Parameter(Mandatory)]
    [string] $Path
)

# Get all PSScript Analyzer Rules and save them in an array
$scriptAnalyzerRules = Get-ScriptAnalyzerRule
$Rules = @()
$scriptAnalyzerRules | ForEach-Object {
    $Rules += @{
        RuleName    = $_.RuleName
        CommonName  = $_.CommonName
        Description = $_.Description
        SourceType  = $_.SourceType
        SourceName  = $_.SourceName
        Severity    = $_.Severity
    }
}

$settingsPath = Join-Path $PSScriptRoot 'PSScriptAnalyzer.Settings.psd1'

# Create an array of the types of rules
$Severities = @('Information', 'Warning', 'Error')

foreach ($Severity in $Severities) {
    Describe "Testing PSSA $Severity Rules" -Tag $Severity {
        It '<CommonName> (<RuleName>)' -ForEach ($Rules | Where-Object Severity -EQ $Severity) {
            param ($RuleName)
            #Test all scripts for the given rule and if there is a problem display this problem in a nice an reabable format in the debug message and let the test fail
            $issues = Invoke-ScriptAnalyzer -Path $Path -Settings $settingsPath -IncludeRule $RuleName -Recurse | ForEach-Object {
                    "$([Environment]::NewLine)$($_.ScriptPath):L$($_.Line): $($_.Message)"
                }
            $issues += $_.SuggestedCorrections
            $issues | Should -BeNullOrEmpty
        }
    }
}
