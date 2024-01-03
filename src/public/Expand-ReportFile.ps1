function Expand-ReportFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ReportFile,
        [Parameter(Mandatory = $true)]
        [string]$OutputFolder
    )

    $zip = [System.IO.Compression.ZipFile]::OpenRead($ReportFile)
    $zip.Entries | ForEach-Object {
        $outputPath = Join-Path $OutputFolder $_.FullName.Replace('/', '\')
        if ($_.Length -eq 0) {
            New-Item -ItemType Directory -Path $outputPath -Force
        }
        else {
            $outputDir = Split-Path $outputPath -Parent
            if (!(Test-Path $outputDir)) {
                New-Item -ItemType Directory -Path $outputDir -Force
            }
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $outputPath, $true)
        }
    }
    $zip.Dispose()

    Get-ChildItem -Path $OutputFolder | ForEach-Object {
        switch ($_.Name) {
            'DataModelSchema' { Rename-Item -Path $_.FullName -NewName 'DataModelSchema.json' }
            'DiagramLayout' { Rename-Item -Path $_.FullName -NewName 'DiagramLayout.json' }
            'DiagramState' { Rename-Item -Path $_.FullName -NewName 'DiagramState.json' }
            'Metadata' { Rename-Item -Path $_.FullName -NewName 'Metadata.json' }
            'Connections' { Rename-Item -Path $_.FullName -NewName 'Connections.json' }
            'Settings' { Rename-Item -Path $_.FullName -NewName 'Settings.json' }
            'Version' { Rename-Item -Path $_.FullName -NewName 'Version.txt' }
            'DataMashup' {
                Write-Verbose "Expanding DataMashup file $($_.FullName)" -Verbose
                Expand-DataMashup -DataMashupFile $_.FullName -OutputFolder "$OutputFolder/DataMashupExtraction"
            }
        }
    }
}

function Expand-DataMashup {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DataMashupFile,
        [Parameter(Mandatory = $true)]
        [string]$OutputFolder
    )

    if (!(Test-Path $OutputFolder)) {
        New-Item -Path $OutputFolder -ItemType Directory
    }

    $DataMashupFile = Resolve-Path $DataMashupFile
    try {

        $mashupStream = [System.IO.File]::Open($DataMashupFile, [System.IO.FileMode]::Open)

        $mashupBinaryReader = New-Object System.IO.BinaryReader ($mashupStream)

        $mshcnt = $mashupBinaryReader.ReadInt32()

        if ($mshcnt -eq 0) {
            $mshcnt = $mashupBinaryReader.ReadInt32()
        }

        $mshBytes = $mashupBinaryReader.ReadBytes($mshcnt)

        $mshMS = New-Object System.IO.MemoryStream(, $mshBytes)
                    
        $mashupPackage = [System.IO.Packaging.Package]::Open($mshMS, [System.IO.FileMode]::Open)

        $muExtraMs = New-Object System.IO.MemoryStream

        $extraCount = 0

        while (!($muExtraEof)) {
            try {
                $muExtraMs.WriteByte($mashupBinaryReader.ReadByte())
                $extraCount ++
            }
            catch {
                $muExtraEof = $true
            }
        }

        [System.IO.File]::WriteAllBytes((Join-Path $OutputFolder "extraBytes"), $muExtraMs.ToArray())

        $mashupPackage.GetParts() | Export-ZipPackagePartToFile -OutputDirectoryPath $outputFolder
    }
    finally {
        $mashupPackage.Close()
        $muExtraMs.Close()
        $mashupBinaryReader.Close()
        $mashupStream.Close()
    }
}

function Export-ZipPackagePartToFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.IO.Packaging.ZipPackagePart] $ZipPackagePart,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $OutputDirectoryPath
    )

    process {
        try {
            # Ensure output directory exists
            if (-not (Test-Path -Path $OutputDirectoryPath)) {
                New-Item -ItemType Directory -Path $OutputDirectoryPath | Out-Null
            }

            $outputFilePath = Join-Path -Path $OutputDirectoryPath -ChildPath $ZipPackagePart.Uri.OriginalString.TrimStart('/')

            # Create the necessary subdirectories
            $outputFileDirectory = Split-Path -Path $outputFilePath -Parent
            if (-not (Test-Path -Path $outputFileDirectory)) {
                New-Item -ItemType Directory -Path $outputFileDirectory -Force | Out-Null
            }

            # Extract content and write to file
            $partStream = $ZipPackagePart.GetStream([System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
            $fileStream = [System.IO.File]::Create($outputFilePath)
            $partStream.CopyTo($fileStream)

        }
        catch {
            throw $_
        }
        finally {
            if ($partStream) {
                $partStream.Close()
            }
            if ($fileStream) {
                $fileStream.Close()
            }
        }
    }
}