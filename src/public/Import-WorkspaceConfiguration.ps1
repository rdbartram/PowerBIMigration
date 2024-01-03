using module ../private/classes.psm1

function Import-WorkspaceConfiguration {
    [cmdletbinding(defaultparametersetname = 'ConfigurationPath')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Dataflows', 'Reports', 'PaginatedReports', 'ScoreCards')]
        [string[]]$Components = @('Dataflows', 'Reports', 'PagintedReports', 'ScoreCards'),

        [Parameter(Mandatory = $false)]
        [string]$BackupFolder,

        # Path to the configuration file in one parameter set
        [Parameter(Mandatory = $true, ParameterSetName = 'ConfigurationPath')]
        [string]$ConfigurationPath,

        # Configuration object in another parameter set
        [Parameter(Mandatory = $true, ParameterSetName = 'Configuration')]
        $Configuration,

        [Parameter(Mandatory = $true)]
        [string]$TranslationsPath,

        [Parameter(Mandatory = $false)]
        $Translations,

        [Parameter(Mandatory = $false)]
        [switch]
        $CreateIfMissing
    )

    process {
        if ($ConfigurationPath) {
            $Configuration = Get-Content -Path $ConfigurationPath | ConvertFrom-Json
        } else {
            $Configuration = $Configuration | ConvertTo-Json -depth 10 -EnumsAsStrings | ConvertFrom-Json
        }

        if ($TranslationsPath) {
            $Translations = Get-Content -Path $TranslationsPath | ConvertFrom-Json
        }

        if ($Translations) {
            $Configuration = Merge-WorkspaceConfiguration -BaseConfiguration $Configuration -Configuration $Translations
        }

        # Set the configuration for the workspace
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName -ErrorAction SilentlyContinue
        if($null -eq $workspace) {
            if ($CreateIfMissing) {
                $workspace = New-PowerBIWorkspace -Name $WorkspaceName
            } else {
                throw "Workspace $WorkspaceName not found"
            }
        }
        $workspaceConfig = Get-PowerBIWorkspace -Id $workspace.Id -Include All -Scope Organization

        $Configuration = $Configuration | Add-Member -NotePropertyName NewId -NotePropertyValue $workspace.Id -Force -PassThru

        $workspaceConfig.Description = $Configuration.Description

        Set-PowerBIWorkspace -Workspace $workspaceConfig -Scope Organization

        if (-not [string]::IsNullOrEmpty($Configuration.CapacityId)) {
            # set capacity
            Set-PowerBIWorkspace -Id $workspace.Id -CapacityId $Configuration.CapacityId -Scope Organization
        }

        $Configuration.Users | ForEach-Object {
            Add-PowerBIWorkspaceUser -Id $workspace.Id -AccessRight $_.AccessRight -Identifier $_.Identifier -PrincipalType $_.PrincipalType -Scope Organization
        }

        # if backup folder is set, then import the reports, dashboards, datasets, dataflows, and scorecards
        if ($BackupFolder) {
            if ($Components -contains 'Dataflows') {
                $configuration = Import-Dataflows -WorkspaceName $WorkspaceName -InputPath "$BackupFolder\Dataflows" -translations $Translations -WorkspaceConfiguration $Configuration
            }
            if ($Components -contains 'Reports') {
                $configuration = Import-Reports -WorkspaceName $WorkspaceName -InputPath "$BackupFolder\Reports" -WorkspaceConfiguration $Configuration
            }
            if ($Components -contains 'PaginatedReports') {
                $configuration = Import-PaginatedReports -WorkspaceName $WorkspaceName -InputPath "$BackupFolder\Reports" -WorkspaceConfiguration $Configuration
            }
            if ($Components -contains 'ScoreCards') {
                Import-ScoreCards -WorkspaceName $WorkspaceName -InputPath "$BackupFolder\ScoreCards\Scorecards.json"
            }

            $Configuration | ConvertTo-Json -Depth 10 | Set-Content -Path "$BackupFolder\Configuration.json" -Force
        }
    }
}