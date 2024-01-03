function Import-PaginatedReports {
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
        $reports = Get-ChildItem -Path $InputPath -Filter *.rdl

        $updatedReports = @()

        $reports | ForEach-Object {
            $reportname = $_.BaseName

            $existingReport = Get-PowerBIReport -Name $reportname -WorkspaceId $workspace.Id -Scope Organization -ErrorAction SilentlyContinue
            if ($existingReport) {
                Write-Verbose "Deleting existing report $($reportname)" -Verbose
                Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)/reports/$($existingReport.Id)" -Method Delete | Out-Null
                Start-Sleep 2
            }

            write-verbose "Importing $($_.FullName)" -Verbose

            Update-ContentIds -ContentPath $_.FullName -WorkspaceConfiguration $WorkspaceConfiguration

            $newReport = New-PowerBIReport -Path $_.FullName -WorkspaceId $workspace.Id -ConflictAction Abort -Name $_.Name

            $WorkspaceConfiguration.Reports | Where-Object { $_.Name -eq $reportname } | ForEach-Object {
                $updatedReports += $_ | Add-Member -NotePropertyName NewId -NotePropertyValue $newReport.id -Force -PassThru
            }
        }

        $WorkspaceConfiguration | Add-Member -NotePropertyName Reports -NotePropertyValue $updatedReports -Force

        return $WorkspaceConfiguration
    }
}