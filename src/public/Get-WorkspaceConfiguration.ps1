using module ../private/classes.psm1

function Get-WorkspaceConfiguration {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName
    )

    process {
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        $workspaceConfig = Get-PowerBIWorkspace -Id $workspace.Id -Include All -Scope Organization

        return $workspaceConfig
    }
}
