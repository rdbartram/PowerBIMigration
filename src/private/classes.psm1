class PowerBIWorkspaceConfiguration {
    [string]$Id
    [string]$Name
    [bool]$IsReadOnly
    [bool]$IsOnDedicatedCapacity
    [string]$CapacityId
    [string]$Description
    [string]$Type
    [string]$State
    [bool]$IsOrphaned
    [PowerBIWorkspaceUser[]]$Users
    [PowerBIWorkspaceReport[]]$Reports
    [PowerBIWorkspaceDashboard[]]$Dashboards
    [PowerBIWorkspaceDataset[]]$Datasets
    [PowerBIWorkspaceDataflow[]]$Dataflows
    [PowerBIWorkspacePaginatedReport[]]$PaginatedReports
    [PowerBIWorkspaceRefreshSchedule[]]$RefreshSchedules
    
    PowerBIWorkspaceConfiguration([System.Object]$InputObject) {
        $this.Id = $InputObject.Id
        $this.Name = $InputObject.Name
        $this.IsReadOnly = $InputObject.IsReadOnly
        $this.IsOnDedicatedCapacity = $InputObject.IsOnDedicatedCapacity
        $this.CapacityId = $InputObject.CapacityId
        $this.Description = $InputObject.Description
        $this.Type = $InputObject.Type
        $this.State = $InputObject.State
        $this.IsOrphaned = $InputObject.IsOrphaned
        $this.Users = $InputObject.Users
        $this.Reports = $InputObject.Reports
        $this.Dashboards = $InputObject.Dashboards
        $this.Datasets = $InputObject.Datasets
        $this.Dataflows = $InputObject.Dataflows
        $this.PaginatedReports = $InputObject.PaginatedReports
        $this.RefreshSchedules = $InputObject.RefreshSchedules
    }
}

class PowerBIWorkspaceUser {
    [string]$AccessRight
    [string]$UserPrincipalName
    [string]$Identifier
    [string]$PrincipalType
}

class PowerBIWorkspaceReport {
    [string]$Id
    [string]$Name
    [string]$WebUrl
    [string]$EmbedUrl
    [string]$DatasetId
}

class PowerBIWorkspaceDashboard {
    [string]$Id
    [string]$DisplayName
    [string]$EmbedUrl
}

class PowerBIWorkspaceDataset {
    [string]$Id
    [string]$Name
    [string]$ConfiguredBy
    [string]$DefaultRetentionPolicy
    [bool]$AddRowsApiEnabled
    [PowerBIWorkspaceTable[]]$Tables
    [string]$WebUrl
    [PowerBIWorkspaceRelationship[]]$Relationships
    [PowerBIWorkspaceDatasource[]]$Datasources
    [string]$DefaultMode
    [bool]$IsRefreshable
    [bool]$IsEffectiveIdentityRequired
    [bool]$IsEffectiveIdentityRolesRequired
    [bool]$IsOnPremGatewayRequired
    [int]$TargetStorageMode
    [string]$ActualStorage
    [datetime]$CreatedDate
    [string]$ContentProviderType
}

class PowerBIWorkspaceDataflow {

}

class PowerBIWorkspacePaginatedReport {

}

class PowerBIWorkspaceRefreshSchedule {

}

class PowerBIWorkspaceTable {
    [string]$Name
    [PowerBIWorkspaceColumn[]]$Columns
}

class PowerBIWorkspaceColumn {
    [string]$Name
    [string]$DataType
}

class PowerBIWorkspaceRelationship {
}

class PowerBIWorkspaceDatasource {
}

