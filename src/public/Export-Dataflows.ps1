function Export-Dataflows {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    process {
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        $dataflows = Get-PowerBIDataflow -WorkspaceId $workspace.Id

        $dataflows | ForEach-Object {
            Export-PowerBIDataflow -Id $_.Id -WorkspaceId $workspace.Id -OutFile "$OutputPath\$($_.Name).json" -Scope Organization

            $json = Get-Content "$OutputPath\$($_.Name).json" -Raw | ConvertFrom-Json

            New-Item "$OutputPath\$($_.Name).m" -Value $json."pbi:mashup".document -ItemType File -Force | Out-Null
        }
    }
}