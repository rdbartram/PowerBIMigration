function Import-Goals {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true)]
        [string]$sourcescorecardid,

        [Parameter(Mandatory = $true)]
        [string]$targetscorecardid,

        [Parameter(Mandatory = $true)]
        [string]$InputPath
    )

    process {
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        $goals = Get-Content $InputPath | ConvertFrom-Json

        $goalValuesJsonPath = Join-Path (Split-Path $InputPath -Parent) "GoalValues.json"
        $goalStatusRulesJsonPath = Join-Path (Split-Path $InputPath -Parent) "GoalStatusRules.json"

        $goals.Value | Where-Object { $_.scorecardid -eq $sourcescorecardid }  | ForEach-Object {
            $goal = $_
            $goalJson = $goal | ConvertTo-Json -Depth 10

            $newGoal = Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)/scorecards/$($targetscorecardId)/goals" -Method Post -Body $goalJson | ConvertFrom-Json

            # Import the goal values for the goal
            Import-GoalValues -WorkspaceName $WorkspaceName -scorecardid $targetscorecardid -sourcegoalid $goal.id -targetgoalid $newGoal.Id -InputPath $goalValuesJsonPath

            # Import the goal status rules for the goal
            Import-GoalStatusRules -WorkspaceName $WorkspaceName -scorecardid $targetscorecardid -sourcegoalid $goal.id -targetgoalid $newGoal.Id -InputPath $goalStatusRulesJsonPath
        }
    }
}

function Import-GoalValues {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true)]
        [string]$scorecardid,

        [Parameter(Mandatory = $true)]
        [string]$sourcegoalid,

        [Parameter(Mandatory = $true)]
        [string]$targetgoalid,

        [Parameter(Mandatory = $true)]
        [string]$InputPath
    )

    process {
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        $goalValues = Get-Content $InputPath | ConvertFrom-Json

        $goalValues.Value | Where-Object { $_.goalid -eq $sourcegoalid } | ForEach-Object {
            $goalValue = $_
            $goalValueJson = $goalValue | ConvertTo-Json -Depth 10

            Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)/scorecards/$($scorecardId)/goals/$($targetgoalid)/goalvalues" -Method Post -Body $goalValueJson | Out-Null
        }
    }
}

function Import-GoalStatusRules {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true)]
        [string]$scorecardid,

        [Parameter(Mandatory = $true)]
        [string]$sourcegoalid,

        [Parameter(Mandatory = $true)]
        [string]$targetgoalid,

        [Parameter(Mandatory = $true)]
        [string]$InputPath
    )

    process {
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        $goalStatusRules = Get-Content $InputPath | ConvertFrom-Json

        $goalStatusRules.Value | Where-Object { $_.goalid -eq $sourcegoalid }  | ForEach-Object {
            $goalStatusRule = $_
            $goalStatusRuleJson = $goalStatusRule | ConvertTo-Json -Depth 10

            Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)/scorecards/$($scorecardId)/goals/$($targetgoalid)/goalstatusrules" -Method Post -Body $goalStatusRuleJson | Out-Null
        }
    }
}