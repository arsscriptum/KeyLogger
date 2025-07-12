function Install-FASM {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    # Define constants
    $fasmUrl = "https://flatassembler.net/fasmw17332.zip"
    $tempDir = Join-Path -Path $env:TEMP -ChildPath ("FASM_" + [guid]::NewGuid().ToString())
    $zipFile = Join-Path -Path $tempDir -ChildPath "fasmw.zip"
    $destDir = "C:\FASM"

    Write-Host "Creating temporary folder: $tempDir"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    # Download ZIP
    Write-Host "Downloading FASM from $fasmUrl"
    Invoke-WebRequest -Uri $fasmUrl -OutFile $zipFile

    # Ensure target directory exists
    if (-Not (Test-Path $destDir)) {
        Write-Host "Creating folder $destDir"
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    } else {
        Write-Host "Folder $destDir already exists."
    }

    # Extract ZIP
    Write-Host "Extracting archive to $destDir"
    Expand-Archive -Path $zipFile -DestinationPath $destDir -Force

    # Clean up
    Write-Host "Removing temporary folder..."
    Remove-Item -Path $tempDir -Recurse -Force

    # Add to User PATH if not present
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")

    if ($userPath -notmatch [regex]::Escape($destDir)) {
        $newPath = $userPath.TrimEnd(';') + ";$destDir"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "Added $destDir to user PATH."
    } else {
        Write-Host "$destDir is already in the user PATH."
    }

    # Set environment variables
    $fasmInclude = Join-Path $destDir "INCLUDE"
    $fasmExe = Join-Path $destDir "FASM.EXE"

    [Environment]::SetEnvironmentVariable("INCLUDE", $fasmInclude, "User")
    Write-Host "Created environment variable INCLUDE = $fasmInclude"

    [Environment]::SetEnvironmentVariable("FASM_EXE", $fasmExe, "User")
    Write-Host "Created environment variable FASM_EXE = $fasmExe"

    Write-Host "Installation complete."
}

Install-FASM