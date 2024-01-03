# PowerBIMigration (BETA)

The PowerBI Migration Workspace module provides functionality for managing PowerBI migrations. It includes two main functions: `Export-WorkspaceConfiguration` and `Import-WorkspaceConfiguration`. These functions allow you to export and import PowerBI workspaces, reports, dataflows, linked datasets, paginated reports, and scorecards.

To use the module, you need to install the `MicrosoftPowerBIMgmt` module from the PowerShell Gallery. Once installed, you can connect to a specific PowerBI instance using the `Connect-PowerBIServiceAccount` command.

The module supports exporting and importing various component types, such as workspaces, reports, paginated reports, dataflows, and scorecards. However, there are some limitations, such as the inability to export dashboard/tile configurations and row-level permissions in datasets.

The module provides functions for exporting and importing specific components, as well as compressing and expanding report files. Detailed usage instructions for each function can be found in the individual script files.

Overall, the PowerBI Migration Workspace module simplifies the process of migrating PowerBI components between different environments and allows for targeted migrations with the ability to override data transformations.

## Supported Component Types

* Workspaces
    Name, Description and ability to assign Capacity Plan
* Reports
    Reports that are able to be exported to PBIX format
* Paginated Reports
* Dataflows
    * Schedules (Import only i.e. we can't export the current values)
* Datasets that are a part of exported PBIX reports
* Scorecards

## API Limitations

Not an exhaustive list

* Dashboard/Tile export/Imports
* Row Level Permissions in Datasets
* Reports that are unable to be exported to PBIX format


## Functions

### `Export-WorkspaceConfiguration`
Exports the configuration of a PowerBI workspace.
### `Export-ScoreCards`
Exports scorecards from a PowerBI workspace.
### `Export-Reports`
Exports reports from a PowerBI workspace.
### `Export-Dataflows`
Exports dataflows from a PowerBI workspace.
### `Import-WorkspaceConfiguration`
Imports a workspace configuration into PowerBI.
### `Import-ScoreCards`
Imports scorecards into a PowerBI workspace.
### `Import-Reports`
Imports reports into a PowerBI workspace.
### `Import-PaginatedReports`
Imports paginated reports into a PowerBI workspace.
### `Import-Dataflows`
Imports dataflows into a PowerBI workspace.
### `Compress-ReportFile`
Compresses a report file. Used after altering the internals of a PBIX file
### `Expand-ReportFile`
Expands a compressed report file. Allows you to review and modify the contents of a PBIX

## Usage

This module for managing PowerBI migrations. There are essentially 2 main functions namely `Export-WorkspaceConfiguration` and `Import-WorkspaceConfiguration`. There are several of publicly accessible functions is you feel the need to do more targeted migration, but the initial design was for a simple export import process.

The module requires the `MicrosoftPowerBIMgmt` module. This can be installed from the PowerShell Gallery with the following command:

```powershell
# machines wide
Install-Module MicrosoftPowerBIMgmt

# current user scope
Install-Module MicrosoftPowerBIMgmt -Scope CurrentUser
```

Once installed you will need to connect to particulat PowerBI instance in order to read or write data

```powershell
Connect-PowerBIServiceAccount
```

Since we write all the data locally, you are able to export components from one PowerBI tenant and import them directly into another.

One additional feature that has been added, is the ability to use transformations. This means that you can override certain data i.e. between dev and prod environments.

To Export an environment use something like the following:

```powershell
Export-WorkspaceConfiguration -WorkspaceName Workspace1 -OutputPath .\backup\worxspace1
```

To Import it again you can use the import command:

```powershell
Import-WorkspaceConfiguration -WorkspaceName "Test Restore" -Components Dataflows, Reports, PaginatedReports, ScoreCards -ConfigurationPath .\backup\worxspace1\Configuration.json -TranslationsPath .\backup\worxspace1\translations.json -BackupFolder .\backup\worxspace1
```

## Acknowledgements

This code was possible by the help of the repo [74bravo/PowerBi-Workspace-Intra-Tenant-Migration-Scripts](https://github.com/74bravo/PowerBi-Workspace-Intra-Tenant-Migration-Scripts).

Many thanks to his public repo as this was a good starting point for this module.