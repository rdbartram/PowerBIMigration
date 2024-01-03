function Export-ScoreCards {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    process {
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        
        Remove-Item "$OutputPath\Scorecards.json" -Force -ErrorAction SilentlyContinue
        Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)/scorecards" -Method Get -OutFile "$OutputPath\Scorecards.json"

        $scorecards = Get-Content "$OutputPath\Scorecards.json" | ConvertFrom-Json

        # Get the goals for each scorecard
        $scorecards.Value | ForEach-Object {
            $scorecard = $_
            Export-Goals -ScoreCardId $scorecard.Id -workspaceId $workspace.Id -OutputPath $OutputPath
        }
    }
}