function Merge-WorkspaceConfiguration {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        $BaseConfiguration,

        [Parameter(Mandatory = $true)]
        $Configuration
    )

    process {
        if ($Configuration.Description) {
            $BaseConfiguration.Description = $Configuration.Description
        }

        if ($Configuration.CapacityId) {
            $BaseConfiguration.CapacityId = $Configuration.CapacityId
        }

        if ($Configuration.Users) {
            $BaseConfiguration.Users = $Configuration.Users
        }

        if ($Configuration.Users) {
            $BaseConfiguration.Users = $Configuration.Users
        }

        $BaseConfiguration
    }

}