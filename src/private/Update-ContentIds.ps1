function Update-ContentIds {
    param(
        [parameter(Mandatory, ParameterSetName = 'ContentPath')]
        $ContentPath,

        [parameter(Mandatory, ParameterSetName = 'Content')]
        $Content,

        [parameter(Mandatory)]
        $WorkspaceConfiguration
    )

    process {
        if ($ContentPath) {
            $Content = Get-Content -Path $ContentPath
        }

        $Content = $Content.Replace($WorkspaceConfiguration.Id, $WorkspaceConfiguration.NewId)

        $WorkspaceConfiguration.Reports | ForEach-Object {
            $Content = $Content.Replace($_.Id, $_.NewId)
        }

        $WorkspaceConfiguration.Datasets | ForEach-Object {
            $Content = $Content.Replace($_.Id, $_.NewId)
        }

        if ($ContentPath) {
            $Content | Set-Content -Path $ContentPath -Force
        }
        else {
            return $Content
        }
    }
}