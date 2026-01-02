# Windows Cleanup Script Generator (v2.0)

## Description du Projet

Ce projet propose une version **avancée et sécurisée** du script PowerShell (`Invoke-WindowsCleanup.ps1`) pour l'optimisation de l'espace disque sur Windows.

Le script a été transformé en un outil de maintenance complet, intégrant des fonctionnalités de **journalisation**, de **gestion des erreurs**, et un **mode simulation** pour une utilisation professionnelle et sécurisée.

## Fonctionnalités Avancées (v2.0)

Le script `Invoke-WindowsCleanup.ps1` effectue désormais les opérations de nettoyage suivantes :

| Catégorie | Cibles de Nettoyage | Nouvelles Fonctionnalités |
| :--- | :--- | :--- |
| **Développement** | Caches **npm** et **pip**. | Ajout du nettoyage des caches **Docker** (`docker system prune`). |
| **Système** | Fichiers temporaires Windows (`%TEMP%`, `C:\Windows\Temp`), Corbeille, Journaux d'événements Windows. | Nettoyage des caches **VS Code** et des fichiers de vignettes (`thumbcache`). |
| **Vidéos** | Fichiers vidéo volumineux (> 500 Mo) non accédés depuis 30 jours. | Option de **Mise en Staging** (déplacement temporaire) ou de **Suppression** sécurisée. |
| **Robustesse** | - | **Journalisation** complète des actions dans un fichier `.log`. **Gestion des erreurs** (`Try/Catch`) pour éviter les arrêts inopinés. |
| **Contrôle** | - | **Mode Simulation** (`-DryRun`) pour visualiser les actions sans les exécuter. **Mode Silencieux** (`-Silent`) pour l'automatisation. |
| **Rapport** | - | Calcul et affichage de l'**Espace Disque Total Libéré** (estimation). |

## Utilisation du Script

### Prérequis

*   Système d'exploitation : Windows 7 ou supérieur.
*   Environnement d'exécution : Windows PowerShell (version 5.1 ou PowerShell Core).
*   Droits d'administrateur : **Fortement recommandés** pour le nettoyage des logs et des fichiers système.

### Exécution

1.  Téléchargez le fichier `Invoke-WindowsCleanup.ps1`.
2.  Ouvrez PowerShell (en tant qu'Administrateur si possible).
3.  Naviguez jusqu'au répertoire où le script est enregistré.
4.  Exécutez le script avec les paramètres souhaités :

    \`\`\`powershell
    # Exécution interactive (par défaut)
    .\Invoke-WindowsCleanup.ps1

    # Exécution en mode simulation (recommandé pour la première fois)
    .\Invoke-WindowsCleanup.ps1 -DryRun

    # Exécution silencieuse (pour la planification de tâches)
    .\Invoke-WindowsCleanup.ps1 -Silent
    \`\`\`

### Paramètres

| Paramètre | Type | Description |
| :--- | :--- | :--- |
| \`-DryRun\` | `[switch]` | Simule toutes les actions de suppression/déplacement. **Aucun fichier n'est modifié.** |
| \`-Silent\` | `[switch]` | Exécute le script sans demander de confirmation. **À utiliser avec prudence**, idéal pour la planification de tâches. |

## Journalisation et Rapports

Chaque exécution génère un fichier de journal (`.log`) dans le dossier `%TEMP%` (ex: `WindowsCleanup_20260102_103000.log`). Ce fichier contient l'horodatage de chaque action, les avertissements et les erreurs, assurant une traçabilité complète.

À la fin de l'exécution, le script affiche l'espace disque total estimé qui a été libéré.

## Avertissement de Sécurité

**Utilisez ce script à vos risques et périls.** Le mode interactif et le mode `-DryRun` sont là pour garantir votre sécurité. Le mode `-Silent` doit être réservé à des environnements de confiance ou à des tâches planifiées après validation.
