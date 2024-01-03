function Import-Reports {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true)]
        [string]$InputPath,

        [Parameter(Mandatory = $true)]
        $WorkspaceConfiguration
    )

    process {
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        $reports = Get-ChildItem -Path $InputPath -Filter *.pbix

        $updatedReports = @()

        $reports | ForEach-Object {
            Write-Verbose "Importing $($_.FullName)" -Verbose
            $reportname = $_.BaseName

            $newReport = New-PowerBIReport -Path $_.FullName -WorkspaceId $workspace.Id -ConflictAction CreateOrOverwrite -Name $reportname

            $WorkspaceConfiguration.Reports | Where-Object { $_.Name -eq $reportname } | ForEach-Object {
                $updatedReports += $_ | Add-Member -NotePropertyName NewId -NotePropertyValue $newReport.id -Force -PassThru
            }

            $WorkspaceConfiguration.Reports.Where{ $_.Name -eq $reportname } | ForEach-Object {
                $_ | Add-Member -NotePropertyName NewId -NotePropertyValue $newReport.id -Force
            }
        }

        $currentDatasets = Get-PowerBIDataset -WorkspaceId $workspace.Id -Scope Organization

        $updatedDatasets = @()

        $WorkspaceConfiguration.Datasets | ForEach-Object {
            $oldDataset = $_
            $dataset = $currentDatasets | Where-Object { $_.Name -eq $oldDataset.Name }

            $updatedDatasets += $_ | Add-Member -NotePropertyName NewId -NotePropertyValue $dataset.Id -Force -PassThru
        }

        $WorkspaceConfiguration | Add-Member -NotePropertyName Reports -NotePropertyValue $updatedReports -Force
        $WorkspaceConfiguration | Add-Member -NotePropertyName Datasets -NotePropertyValue $updatedDatasets -Force

        return $WorkspaceConfiguration
    }
}