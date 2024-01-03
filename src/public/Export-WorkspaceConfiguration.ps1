function Export-WorkspaceConfiguration {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    process {
        $Folder = New-Item -ItemType Directory -Name $WorkspaceName -Path $OutputPath -Force

        $workspaceConfig = Get-WorkspaceConfiguration -WorkspaceName $WorkspaceName
        $workspaceConfig | ConvertTo-Json | Out-File "$($Folder.FullName)\Configuration.json"

        $ReportFolder = New-Item -ItemType Directory -Name "Reports" -Path $Folder.FullName -Force
        $DataFlowFolder = New-Item -ItemType Directory -Name "DataFlows" -Path $Folder.FullName -Force

        Get-ChildItem $ReportFolder | Remove-Item -Recurse -Force
        Get-ChildItem $DataFlowFolder | Remove-Item -Recurse -Force

        Export-Reports -WorkspaceName $WorkspaceName -OutputPath $ReportFolder.FullName
        Export-Dataflows -WorkspaceName $WorkspaceName -OutputPath $DataFlowFolder.FullName

    }
}