@{
    Rules = @{
        PSAlignAssignmentStatement         = @{
            Enable         = $true
            CheckHashtable = $true
        }
        PSAvoidLongLines                   = @{
            Enable            = $true
            MaximumLineLength = 120
        }
        PSAvoidSemicolonsAsLineTerminators = @{
            Enable = $true
        }
        PSPlaceCloseBrace                  = @{
            Enable             = $true
            NoEmptyLineBefore  = $false
            IgnoreOneLineBlock = $true
            NewLineAfter       = $true
        }
        PSPlaceOpenBrace                   = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }
        PSProvideCommentHelp               = @{
            Enable                  = $true
            ExportedOnly            = $false
            BlockComment            = $true
            VSCodeSnippetCorrection = $false
            Placement               = 'begin'
        }
        PSUseConsistentIndentation         = @{
            Enable              = $true
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind                = 'space'
        }
        PSUseConsistentWhitespace          = @{
            Enable                                  = $true
            CheckInnerBrace                         = $true
            CheckOpenBrace                          = $true
            CheckOpenParen                          = $true
            CheckOperator                           = $true
            CheckPipe                               = $true
            CheckPipeForRedundantWhitespace         = $true
            CheckSeparator                          = $true
            CheckParameter                          = $true
            IgnoreAssignmentOperatorInsideHashTable = $false
        }
    }
}
