<#
.SYNOPSIS
Ce script installe et configure Active Directory pour l'entreprise EntrepriseXYZ.

.DESCRIPTION
Ce script doit être lancé deux dois consécutivement, la première fois pour installer Active Directory, la seconde pour configurer les utilisateurs, groupes et dossiers partagés.
#>

# ============================================

# Démarrer la transcription pour enregistrer toutes les sorties dans un fichier de log
Start-Transcript -Path "O:\transcriptAD_admin.txt" -Append

# =================================================================================================================
# - INSTALLATION D'ACTIVE DIRECTORY
# =================================================================================================================

Write-Host "Installation du rôle Active Directory Domain Services..." -ForegroundColor Green 
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Étape 2 : Définition du fichier marqueur
$markerFile = "C:\Users\Administrateur\installationAD.txt"
$markerFile2 = "C:\Users\Administrateur\installationAD2.txt"

# Étape 3 : Vérification SI l'installation a déjà été faite AVANT de demander le mot de passe
if (-not (Test-Path $markerFile)) {
    # Le marqueur n'existe PAS, l'installation doit donc être effectuée.
    Write-Host "Installation AD requise..." -ForegroundColor Cyan
        try {
            Write-Host "Lancement de la promotion du contrôleur de domaine (Install-ADDSForest)..." -ForegroundColor Yellow

            Install-ADDSForest -DomainName "EntrepriseXYZ.local" `
                               -SafeModeAdministratorPassword (Read-Host -Prompt "Mot de passe DSRM :" -AsSecureString) `
                               -InstallDNS `
                               -DomainNetbiosName "ENTREPRISEXYZ" `
                               -Force
            
            # Créer le fichier marqueur UNIQUEMENT après le succès de l'installation
            "Active Directory a été installé le $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File $markerFile -Encoding UTF8 -Force
            Write-Host "Installation AD terminée." -ForegroundColor Green
        }
        catch {
            # Catch gère les erreurs pendant Install-ADDSForest
            Write-Host "ERREUR lors de l'installation AD : $_" -ForegroundColor Red
            Write-Host "Veuillez vérifier les logs et le mot de passe DSRM." -ForegroundColor Red
        }
    
}
else {
    # Le marqueur existe, on ne fait rien.
    Write-Host "Installation AD déjà effectuée." -ForegroundColor Yellow
}
Import-Module ActiveDirectory
   
# ============================================
# 1. CRÉATION DES OU (ORGANIZATIONAL UNITS)
# ============================================

New-ADOrganizationalUnit -Name "Direction" -Path "DC=EntrepriseXYZ,DC=local" -ProtectedFromAccidentalDeletion $true
Write-Host "OU créée : Direction" -ForegroundColor Cyan
New-ADOrganizationalUnit -Name "RH" -Path "DC=EntrepriseXYZ,DC=local" -ProtectedFromAccidentalDeletion $true
Write-Host "OU créée : RH" -ForegroundColor Cyan
New-ADOrganizationalUnit -Name "Informatique" -Path "DC=EntrepriseXYZ,DC=local" -ProtectedFromAccidentalDeletion $true
Write-Host "OU créée : Informatique" -ForegroundColor Cyan
Write-Host "Création des Unités Organisationnelles terminée." -ForegroundColor Green


# ============================================
# 2 . Créer des utilisateurs dans chaque OU
# ============================================

New-ADUser -Name "Marc Dupont" -GivenName "Marc" -Surname "Dupont" -SamAccountName "mdupont" -UserPrincipalName "mdupont@entreprisexyz.local" -Path "OU=Direction,DC=EntrepriseXYZ,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "Claire Lemoine" -GivenName "Claire" -Surname "Lemoine" -SamAccountName "clemoine" -UserPrincipalName "clemoine@entreprisexyz.local" -Path "OU=Direction,DC=EntrepriseXYZ,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "Paul Bernard" -GivenName "Paul" -Surname "Bernard" -SamAccountName "pbernard" -UserPrincipalName "pbernard@entreprisexyz.local" -Path "OU=Direction,DC=EntrepriseXYZ,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "Sophie Durand" -GivenName "Sophie" -Surname "Durand" -SamAccountName "sdurand" -UserPrincipalName "sdurand@entreprisexyz.local" -Path "OU=RH,DC=EntrepriseXYZ,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "Luc Meyer" -GivenName "Luc" -Surname "Meyer" -SamAccountName "lmeyer" -UserPrincipalName "lmeyer@entreprisexyz.local" -Path "OU=RH,DC=EntrepriseXYZ,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "Anne Legrand" -GivenName "Anne" -Surname "Legrand" -SamAccountName "alegrand" -UserPrincipalName "alegrand@entreprisexyz.local" -Path "OU=RH,DC=EntrepriseXYZ,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "Jean Martin" -GivenName "Jean" -Surname "Martin" -SamAccountName "jmartin" -UserPrincipalName "jmartin@entreprisexyz.local" -Path "OU=Informatique,DC=EntrepriseXYZ,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "Eva Petit" -GivenName "Eva" -Surname "Petit" -SamAccountName "epetit" -UserPrincipalName "epetit@entreprisexyz.local" -Path "OU=Informatique,DC=EntrepriseXYZ,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "David Moreau" -GivenName "David" -Surname "Moreau" -SamAccountName "dmoreau" -UserPrincipalName "dmoreau@entreprisexyz.local" -Path "OU=Informatique,DC=EntrepriseXYZ,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true
Write-Host "Utilisateurs créés dans les OU." -ForegroundColor Green

# ============================================
# 3. CRÉATION DES Groupes
# ============================================

New-ADGroup -Name "GRP_Direction" -Path "OU=Direction,DC=EntrepriseXYZ,DC=local" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "GRP_RH" -Path "OU=RH,DC=EntrepriseXYZ,DC=local" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "GRP_IT" -Path "OU=Informatique,DC=EntrepriseXYZ,DC=local" -GroupScope Global -GroupCategory Security
Write-Host "Groupes créés : GRP_Direction, GRP_RH, GRP_IT" -ForegroundColor Green

# ============================================
# 4. Assigner les utilisateurs aux groupes.
# ============================================

Add-ADGroupMember -Identity "GRP_IT" -Members "jmartin"
Add-ADGroupMember -Identity "GRP_IT" -Members "epetit"
Add-ADGroupMember -Identity "GRP_IT" -Members "dmoreau"
Add-ADGroupMember -Identity "GRP_RH" -Members "sdurand"
Add-ADGroupMember -Identity "GRP_RH" -Members "lmeyer"
Add-ADGroupMember -Identity "GRP_RH" -Members "alegrand"
Add-ADGroupMember -Identity "GRP_Direction" -Members "mdupont"
Add-ADGroupMember -Identity "GRP_Direction" -Members "clemoine"
Add-ADGroupMember -Identity "GRP_Direction" -Members "pbernard"
Write-Host "Utilisateurs assignés aux groupes correspondants." -ForegroundColor Green


# ============================================
# 5. Créer des dossiers partagés et permissions NTFS.
# ============================================

Import-Module SmbShare
Import-Module ActiveDirectory
New-Item -ItemType Directory -Path "C:\Users\Partages" -Force
New-Item -ItemType Directory -Path "C:\Users\Partages\Direction" -Force
New-Item -ItemType Directory -Path "C:\Users\Partages\RH" -Force
New-Item -ItemType Directory -Path "C:\Users\Partages\Informatique" -Force
New-SmbShare -Name "Direction" -Path "C:\Users\Partages\Direction" -FullAccess "GRP_Direction"
New-SmbShare -Name "RH" -Path "C:\Users\Partages\RH" -FullAccess "GRP_RH"
New-SmbShare -Name "Informatique" -Path "C:\Users\Partages\Informatique" -FullAccess "GRP_IT"
icacls "C:\Users\Partages\Direction" /grant "GRP_Direction:(OI)(CI)F" /T
icacls "C:\Users\Partages\RH" /grant "GRP_RH:(OI)(CI)F" /T
icacls "C:\Users\Partages\Informatique" /grant "GRP_IT:(OI)(CI)F" /T


if (-not (Test-Path $markerFile2)) {  
    Write-Host "Modification du mot de passe administrateur du domaine..." -ForegroundColor Cyan
    
    
     try {
        # Le marqueur n'existe PAS, alors le mot de passe administrateur doit être saisi.
        $password = Read-Host -AsSecureString "Entrez le mot de passe administrateur du domaine"
        Set-ADAccountPassword -Identity "Administrateur" -Reset -NewPassword $password
        # Créer le fichier marqueur UNIQUEMENT après le succès de la modification du mot de passe
        "Active Directory a été configuré le $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File $markerFile2 -Encoding UTF8 -Force
        
    }
    catch {
        Write-Host "ERREUR lors de la modification du mot de passe administrateur : $_" -ForegroundColor Red
    }
}
else {
    Write-Host "Le mot de passe administrateur a déjà été modifié." -ForegroundColor Yellow
}

Write-Host "Configuration Active Directory terminée." -ForegroundColor Green
Write-Host "N'oubliez pas de redémarrer le serveur pour appliquer toutes les modifications." -ForegroundColor Yellow

# Arrêter la transcription
Stop-Transcript