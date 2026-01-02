<#
.SYNOPSIS
    Script de nettoyage sécurisé pour Windows.
    
.DESCRIPTION
    Ce script analyse et nettoie les caches npm/pip, les logs système et identifie les fichiers vidéo volumineux non utilisés.
    Il privilégie la sécurité en demandant confirmation ou en déplaçant les fichiers vers un dossier temporaire.

.NOTES
    Auteur: Manus (Expert Administration Système)
    Version: 1.0
#>

$ErrorActionPreference = "SilentlyContinue"

# --- Configuration ---
$VideoSizeThresholdMB = 500 # Taille minimale pour considérer une vidéo comme "volumineuse"
$DaysSinceLastAccess = 30   # Nombre de jours d'inactivité pour les vidéos
$TempCleanupDir = Join-Path $env:TEMP "WindowsCleanup_Staging"

# --- Fonctions de support ---
function Write-Header($Title) {
    Write-Host "`n=== $Title ===" -ForegroundColor Cyan
}

function Write-Success($Message) {
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Info($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Gray
}

# --- 1. Nettoyage des caches de développement (npm & pip) ---
Write-Header "Nettoyage des caches de développement"

# npm cache
if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Info "Analyse du cache npm..."
    $npmCacheSize = (npm cache verify | Out-String)
    Write-Host "Statut npm: $npmCacheSize"
    $confirmNpm = Read-Host "Voulez-vous vider le cache npm ? (O/N)"
    if ($confirmNpm -eq 'O') {
        npm cache clean --force
        Write-Success "Cache npm nettoyé."
    }
} else {
    Write-Info "npm n'est pas installé sur ce système."
}

# pip cache
if (Get-Command pip -ErrorAction SilentlyContinue) {
    Write-Info "Analyse du cache pip..."
    $confirmPip = Read-Host "Voulez-vous vider le cache pip ? (O/N)"
    if ($confirmPip -eq 'O') {
        pip cache purge
        Write-Success "Cache pip nettoyé."
    }
} else {
    Write-Info "pip n'est pas installé sur ce système."
}

# --- 2. Nettoyage des journaux système (Logs) ---
Write-Header "Nettoyage des journaux système"
$confirmLogs = Read-Host "Voulez-vous vider les journaux d'événements Windows ? (O/N)"
if ($confirmLogs -eq 'O') {
    $logs = Get-EventLog -List
    foreach ($log in $logs) {
        Clear-EventLog -LogName $log.Log
        Write-Info "Journal $($log.Log) vidé."
    }
    Write-Success "Journaux système nettoyés."
}

# --- 3. Identification des fichiers vidéo volumineux ---
Write-Header "Analyse des fichiers vidéo volumineux"
Write-Info "Recherche de fichiers > $VideoSizeThresholdMB Mo non accédés depuis $DaysSinceLastAccess jours..."

$videoExtensions = "*.mp4", "*.mkv", "*.avi", "*.mov", "*.wmv"
$userProfile = $env:USERPROFILE
$largeVideos = Get-ChildItem -Path $userProfile -Include $videoExtensions -Recurse -ErrorAction SilentlyContinue | 
               Where-Object { $_.Length -gt ($VideoSizeThresholdMB * 1MB) -and $_.LastAccessTime -lt (Get-Date).AddDays(-$DaysSinceLastAccess) }

if ($largeVideos) {
    Write-Host "`nFichiers identifiés :" -ForegroundColor Yellow
    $largeVideos | Select-Object Name, @{Name="Size(GB)";Expression={"{0:N2}" -f ($_.Length / 1GB)}}, LastAccessTime | Format-Table -AutoSize

    $action = Read-Host "Actions : [D]éplacer vers dossier temporaire, [S]upprimer définitivement, [I]gnorer"
    
    if ($action -eq 'D') {
        if (!(Test-Path $TempCleanupDir)) { New-Item -ItemType Directory -Path $TempCleanupDir | Out-Null }
        foreach ($file in $largeVideos) {
            Move-Item -Path $file.FullName -Destination $TempCleanupDir -Force
            Write-Info "Déplacé : $($file.Name) -> $TempCleanupDir"
        }
        Write-Success "Fichiers déplacés vers $TempCleanupDir"
    } elseif ($action -eq 'S') {
        $confirmDelete = Read-Host "Êtes-vous SÛR de vouloir supprimer ces fichiers ? (O/N)"
        if ($confirmDelete -eq 'O') {
            $largeVideos | Remove-Item -Force
            Write-Success "Fichiers supprimés."
        }
    } else {
        Write-Info "Aucune action effectuée sur les vidéos."
    }
} else {
    Write-Info "Aucun fichier vidéo volumineux correspondant aux critères n'a été trouvé."
}

Write-Header "Nettoyage terminé"
Pause
