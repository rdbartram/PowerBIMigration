function Export-Goals {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$ScoreCardId,

        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$workspaceId,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    process {
        Remove-Item "$OutputPath\Goals.json" -Force -ErrorAction SilentlyContinue
        Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspaceId)/scorecards/$ScoreCardId/goals" -Method Get -OutFile "$OutputPath\Goals.json"

        $goals = Get-Content "$OutputPath\Goals.json" | ConvertFrom-Json

        # Get the goal details for each goal
        $goals.Value | ForEach-Object {
            $goal = $_
            Export-GoalValues -GoalId $goal.Id -ScoreCardId $ScoreCardId -workspaceId $workspaceId -OutputPath $OutputPath
            Export-GoalStatusRules -GoalId $goal.Id -ScoreCardId $ScoreCardId -workspaceId $workspaceId -OutputPath $OutputPath
        }
    }
}

function Export-GoalValues {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$GoalId,

        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$ScoreCardId,

        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$workspaceId,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    process {
        Remove-Item "$OutputPath\GoalValues.json" -Force -ErrorAction SilentlyContinue
        Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspaceId)/scorecards/$ScoreCardId/goals/$GoalId/goalvalues" -Method Get -OutFile "$OutputPath\GoalValues.json"
    }
}

function Export-GoalStatusRules {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$GoalId,

        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$ScoreCardId,

        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$workspaceId,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    process {
        Remove-Item "$OutputPath\GoalStatusRules.json" -Force -ErrorAction SilentlyContinue
        Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspaceId)/scorecards/$ScoreCardId/goals/$GoalId/statusrules" -Method Get -OutFile "$OutputPath\GoalStatusRules.json"
    }
}