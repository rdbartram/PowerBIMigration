function Import-Dataflows {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true)]
        [string]$InputPath,

        [Parameter(Mandatory = $false)]
        $translations,

        [Parameter(Mandatory = $true)]
        $WorkspaceConfiguration
    )

    process {
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        $dataflows = Get-ChildItem -Path $InputPath -Filter *.json

        $updatedDataflows = @()

        $dataflows | ForEach-Object {
            $dataflow = $_

            $existingdataflow = Get-PowerBIDataflow -Name $dataflow.BaseName -WorkspaceId $workspace.Id -ErrorAction SilentlyContinue
            if ($existingdataflow) {
                Write-Verbose "Deleting existing dataflow $($_.BaseName)" -Verbose
                Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)/dataflows/$($existingdataflow.Id)" -Method Delete | Out-Null
                Start-Sleep 2
            }

            Write-Verbose "Importing $($_.FullName)" -Verbose

            Update-ContentIds -ContentPath $_.FullName -WorkspaceConfiguration $WorkspaceConfiguration

            New-PowerBIReport -Path $_.FullName -WorkspaceId $workspace.Id -Name $_.name | Out-Null
            $newDataflow = Get-PowerBIDataflow -Name $_.BaseName -WorkspaceId $workspace.Id

            $WorkspaceConfiguration.Dataflows | Where-Object { $_.name -eq $newDataflow.name } | ForEach-Object {
                $updatedDataflows += $_ | Add-Member -NotePropertyName NewId -NotePropertyValue $newDataflow.id -Force -PassThru
            }
            
            $translations.schedules.where{ $_.dataflow -eq $dataflow.BaseName } | ForEach-Object {
                Write-Verbose "Importing schedule for $($_.dataflow)" -Verbose
                $scheduleJson = @{ value = $_.schedule } | ConvertTo-Json -Depth 10
                
                Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)/dataflows/$($newDataflow.id)/refreshSchedule" -Method Patch -Body $scheduleJson | Out-Null
            }
        }
        
        $WorkspaceConfiguration | Add-Member -NotePropertyName Dataflows -NotePropertyValue $updatedDataflows -Force

        return $WorkspaceConfiguration
    }
}