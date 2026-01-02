<#
.SYNOPSIS
    Script de nettoyage Windows Avancé et Sécurisé.
    
.DESCRIPTION
    Ce script effectue une maintenance complète du système : caches dev, logs, fichiers temporaires, et gestion des vidéos volumineuses.
    Inclut la journalisation, la gestion des erreurs, et un mode simulation.

.PARAMETER DryRun
    Si présent, simule les actions sans supprimer de fichiers.

.PARAMETER Silent
    Si présent, exécute le script sans demander de confirmation (attention !).

.NOTES
    Auteur: Manus AI
    Version: 2.0
#>

param (
    [switch]$DryRun,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"
$LogFile = Join-Path $env:TEMP "WindowsCleanup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$TotalSpaceFreed = 0

# --- Fonctions de Support ---

function Write-Log($Message, $Level = "INFO") {
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$TimeStamp] [$Level] $Message"
    $LogEntry | Out-File -FilePath $LogFile -Append
    
    $Color = switch ($Level) {
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        "HEADER"  { "Cyan" }
        default   { "Gray" }
    }
    
    if ($Level -eq "HEADER") {
        Write-Host "`n=== $Message ===" -ForegroundColor $Color
    } else {
        Write-Host "[$Level] $Message" -ForegroundColor $Color
    }
}

function Get-AdminStatus {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Remove-FileSecurely($Path, $Size = 0) {
    try {
        if ($DryRun) {
            Write-Log "[SIMULATION] Suppression de : $Path" "INFO"
        } else {
            if (Test-Path $Path) {
                Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
                $script:TotalSpaceFreed += $Size
            }
        }
        return $true
    } catch {
        Write-Log "Impossible de supprimer $Path : $($_.Exception.Message)" "WARNING"
        return $false
    }
}

# --- Initialisation ---

Write-Log "Démarrage du script de nettoyage" "HEADER"
if ($DryRun) { Write-Log "MODE SIMULATION ACTIVÉ - Aucune modification réelle ne sera effectuée." "WARNING" }

if (-not (Get-AdminStatus)) {
    Write-Log "Le script n'est pas exécuté en tant qu'administrateur. Certaines fonctions seront limitées." "WARNING"
}

# --- 1. Caches de Développement ---
Write-Log "Nettoyage des Caches de Développement" "HEADER"

# npm
if (Get-Command npm -ErrorAction SilentlyContinue) {
    if ($Silent -or (Read-Host "Nettoyer le cache npm ? (O/N)") -eq 'O') {
        Write-Log "Nettoyage du cache npm..."
        if (-not $DryRun) { npm cache clean --force }
        Write-Log "Cache npm traité." "SUCCESS"
    }
}

# Docker
if (Get-Command docker -ErrorAction SilentlyContinue) {
    if ($Silent -or (Read-Host "Nettoyer les ressources Docker inutilisées ? (O/N)") -eq 'O') {
        Write-Log "Exécution de docker system prune..."
        if (-not $DryRun) { docker system prune -f }
        Write-Log "Docker nettoyé." "SUCCESS"
    }
}

# --- 2. Fichiers Temporaires et Système ---
Write-Log "Nettoyage Système et Temporaire" "HEADER"

$TempPaths = @(
    $env:TEMP,
    "C:\Windows\Temp",
    "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db",
    "$env:APPDATA\Code\Cache",
    "$env:APPDATA\Code\CachedData"
)

foreach ($Path in $TempPaths) {
    if (Test-Path $Path) {
        Write-Log "Traitement de : $Path"
        $Files = Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue
        foreach ($File in $Files) {
            Remove-FileSecurely $File.FullName $File.Length
        }
    }
}

# Corbeille
if ($Silent -or (Read-Host "Vider la corbeille ? (O/N)") -eq 'O') {
    Write-Log "Vidage de la corbeille..."
    if (-not $DryRun) { Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue }
    Write-Log "Corbeille vidée." "SUCCESS"
}

# --- 3. Vidage des Logs (Admin requis) ---
if (Get-AdminStatus) {
    if ($Silent -or (Read-Host "Vider les journaux d'événements Windows ? (O/N)") -eq 'O') {
        Write-Log "Nettoyage des Event Logs..."
        $Logs = Get-EventLog -List
        foreach ($Log in $Logs) {
            if (-not $DryRun) { Clear-EventLog -LogName $Log.Log }
        }
        Write-Log "Journaux système nettoyés." "SUCCESS"
    }
}

# --- 4. Analyse des Vidéos Volumineuses ---
Write-Log "Analyse des Vidéos Volumineuses" "HEADER"
$VideoThreshold = 500MB
$DaysOld = 30
$StagingArea = Join-Path $env:TEMP "Cleanup_Staging"

$Videos = Get-ChildItem -Path $env:USERPROFILE -Include *.mp4,*.mkv,*.avi -Recurse -ErrorAction SilentlyContinue |
          Where-Object { $_.Length -gt $VideoThreshold -and $_.LastAccessTime -lt (Get-Date).AddDays(-$DaysOld) }

if ($Videos) {
    Write-Log "$($Videos.Count) vidéos volumineuses trouvées." "INFO"
    $Videos | Select-Object Name, @{N="Size(MB)";E={"{0:N0}" -f ($_.Length/1MB)}}, LastAccessTime | Out-String | Write-Host
    
    $Action = if ($Silent) { "D" } else { Read-Host "Action pour les vidéos : [D]éplacer en staging, [S]upprimer, [I]gnorer" }
    
    if ($Action -eq 'D') {
        if (-not (Test-Path $StagingArea)) { New-Item -ItemType Directory -Path $StagingArea | Out-Null }
        foreach ($V in $Videos) {
            Write-Log "Mise en staging : $($V.Name)"
            if (-not $DryRun) { Move-Item $V.FullName $StagingArea -Force }
        }
        Write-Log "Vidéos déplacées vers $StagingArea" "SUCCESS"
    } elseif ($Action -eq 'S') {
        foreach ($V in $Videos) { Remove-FileSecurely $V.FullName $V.Length }
        Write-Log "Vidéos supprimées." "SUCCESS"
    }
} else {
    Write-Log "Aucune vidéo volumineuse non utilisée trouvée." "INFO"
}

# --- Conclusion ---
$FreedGB = "{0:N2}" -f ($TotalSpaceFreed / 1GB)
Write-Log "Nettoyage Terminé" "HEADER"
Write-Log "Espace total libéré (estimé) : $FreedGB Go" "SUCCESS"
Write-Log "Journal complet disponible ici : $LogFile" "INFO"

if (-not $Silent) { Pause }
