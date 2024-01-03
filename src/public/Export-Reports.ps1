function Export-Reports {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    process {
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        $reports = Get-PowerBIReport -WorkspaceId $workspace.Id

        $reports | Where-Object { $_.EmbedUrl -match 'reportEmbed`?'} | ForEach-Object {
            $report = Get-PowerBIReport -Id $_.Id -WorkspaceId $workspace.Id -Scope Organization
            $report | Export-PowerBIReport -OutFile "$OutputPath\$($_.Name).pbix"
        }

        $reports | Where-Object { $_.EmbedUrl -match 'rdlEmbed`?'} | ForEach-Object {
            $report = Get-PowerBIReport -Id $_.Id -WorkspaceId $workspace.Id -Scope Organization
            $report | Export-PowerBIReport -OutFile "$OutputPath\$($_.Name).rdl"
        }
    }
}