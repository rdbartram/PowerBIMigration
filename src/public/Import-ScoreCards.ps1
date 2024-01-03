function Import-ScoreCards {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true)]
        [string]$InputPath
    )

    process {
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        $scorecards = Get-Content $InputPath | ConvertFrom-Json
        $goalJsonPath = Join-Path (Split-Path $InputPath -Parent) "Goals.json"

        $scorecards.Value | ForEach-Object {
            $scorecard = $_

            $existingScorecard = Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)/scorecards/$($scorecard.Id)" -Method Get -ErrorAction SilentlyContinue
            if($existingScorecard) {
                Write-Verbose "Deleting existing scorecard $($_.name)" -Verbose
                Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)/scorecards/$($existingScorecard.Id)" -Method Delete | Out-Null
                Start-Sleep 2
            }

            Write-Verbose "Importing $($_.name)" -Verbose
            $scorecardJson = $scorecard | ConvertTo-Json -Depth 10

            $newScorecard = Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)/scorecards" -Method Post -Body $scorecardJson | ConvertFrom-Json

            # Import the goals for the scorecard
            Import-Goals -WorkspaceName $WorkspaceName -sourcescorecardid $scorecard.id -targetscorecardid $newScorecard.Id -InputPath $goalJsonPath
        }
    }
}