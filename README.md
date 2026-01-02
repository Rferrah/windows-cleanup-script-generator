# Windows Cleanup Script Generator

## Description du Projet

Ce projet propose un **script PowerShell sécurisé** (`Invoke-WindowsCleanup.ps1`) conçu pour aider les administrateurs système et les utilisateurs avancés de Windows à optimiser l'espace disque.

Le script cible spécifiquement les sources courantes d'encombrement, tout en intégrant des mécanismes de sécurité pour prévenir la suppression accidentelle de données importantes.

## Fonctionnalités Clés

Le script `Invoke-WindowsCleanup.ps1` effectue les opérations de nettoyage suivantes :

1.  **Nettoyage des Caches de Développement** :
    *   Vide le cache du gestionnaire de paquets **npm** (`npm cache clean --force`).
    *   Vide le cache du gestionnaire de paquets **pip** (`pip cache purge`).
    *   *Sécurité* : Ces opérations sont soumises à une confirmation de l'utilisateur.

2.  **Nettoyage des Journaux Système (Logs)** :
    *   Vide tous les journaux d'événements Windows (Application, Security, System, etc.).
    *   *Sécurité* : Cette opération est soumise à une confirmation de l'utilisateur.

3.  **Gestion des Fichiers Vidéo Volumineux** :
    *   Identifie les fichiers vidéo (`.mp4`, `.mkv`, `.avi`, `.mov`, `.wmv`) dont la taille dépasse un seuil configurable (par défaut : **500 Mo**).
    *   Filtre ces fichiers s'ils n'ont pas été accédés depuis un nombre de jours configurable (par défaut : **30 jours**), les considérant comme "non utilisés".
    *   *Sécurité* : L'utilisateur a le choix entre :
        *   **Déplacer** les fichiers vers un dossier temporaire de staging (`%TEMP%\WindowsCleanup_Staging`) pour une vérification ultérieure.
        *   **Supprimer** définitivement les fichiers (avec une confirmation supplémentaire).
        *   **Ignorer** l'opération.

## Utilisation du Script

### Prérequis

*   Système d'exploitation : Windows 7 ou supérieur.
*   Environnement d'exécution : Windows PowerShell (version 5.1 ou PowerShell Core).
*   Droits d'administrateur : Nécessaires pour vider les journaux d'événements Windows.

### Exécution

1.  Téléchargez le fichier `Invoke-WindowsCleanup.ps1`.
2.  Ouvrez PowerShell en tant qu'**Administrateur**.
3.  Naviguez jusqu'au répertoire où le script est enregistré.
4.  Exécutez le script :

    \`\`\`powershell
    .\Invoke-WindowsCleanup.ps1
    \`\`\`

Le script vous guidera à travers les différentes étapes de nettoyage en demandant votre confirmation pour chaque action critique.

## Personnalisation

Vous pouvez modifier les variables suivantes au début du script `Invoke-WindowsCleanup.ps1` pour ajuster les critères de recherche des vidéos :

| Variable | Description | Valeur par Défaut |
| :--- | :--- | :--- |
| \`$VideoSizeThresholdMB\` | Taille minimale (en Mo) pour qu'un fichier vidéo soit considéré comme volumineux. | \`500\` |
| \`$DaysSinceLastAccess\` | Nombre de jours d'inactivité (dernière date d'accès) pour qu'un fichier soit considéré comme "non utilisé". | \`30\` |
| \`$TempCleanupDir\` | Chemin du dossier temporaire pour le déplacement des fichiers. | \`%TEMP%\WindowsCleanup_Staging\` |

## Avertissement de Sécurité

**Utilisez ce script à vos risques et périls.** Bien que des mesures de sécurité (confirmations, déplacement temporaire) aient été intégrées, il est de votre responsabilité de vérifier les fichiers avant toute suppression définitive. Le script ne cible que les caches et les logs qui sont généralement sûrs à supprimer, mais la section vidéo nécessite une attention particulière.
