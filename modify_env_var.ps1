[cmdletbinding()]
Param (
    [switch]$Force = $false
)

function Set-EnvPath {
    param (
        [string]$scriptPath
    )

    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $currentPathValues = $currentPath -split ";"

    if (-not ($currentPathValues -contains $scriptPath)) {
        $newPath = $currentPath + ";" + $scriptPath
        [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Verbose "Agregado a las variables de entorno: $scriptPath"
    }
}

function Set-ScriptPath {
    param (
        [string]$scriptPath,
        [switch]$Force
    )

    if (-not $Force -and (Test-Path -Path $scriptPath)) {
        $reinstallChoice = Read-Host "La carpeta $scriptPath ya existe. ¿Quieres reinstalar? (Y/N)"

        if ($reinstallChoice -eq "N") {
            return $false
        }
    }


    Remove-Item -Path $scriptPath -ErrorAction SilentlyContinue -Force -Recurse
    New-Item -Path $scriptPath -ItemType Directory -Force | Out-Null
    
    return $true
}

$scriptPath = "$env:USERPROFILE\.python_apps\win_manual_recon"
$buildScriptPath = "$PSScriptRoot\build.ps1"
$buildPath = ".\dist"

$result = Set-ScriptPath $scriptPath -Force:$Force
if (-not $result) {
    Write-Verbose "Instalación cancelada por el usuario"
    Exit
}

Set-EnvPath $scriptPath
Start-Process powershell.exe -ArgumentList "-File `"$buildScriptPath`"" -Wait -NoNewWindow
Copy-Item -Path $buildPath\* -Destination $scriptPath