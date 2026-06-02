<#
.SYNOPSIS
Ce script met en place et configure le service DHCP pour l'entreprise EntrepriseXYZ.

.DESCRIPTION
Ce script installe le rôle DHCP, crée une étendue DHCP, configure les options nécessaires et crée une réservation pour un poste administratif.
#>

# ============================================

Start-Transcript -Path "O:\logDHCP.txt" -Append

# ==============================================================================
# Objectif : Installer et configurer le service DHCP sur le contrôleur de domaine.
# ==============================================================================

# -----------------------------------------------------
# 1. PARAMÈTRES ET VARIABLES
# Ces variables permettent de modifier facilement la configuration.
# -----------------------------------------------------

# Adresse IP du Contrôleur de Domaine (DC) et futur serveur DHCP
$DHCP_IP = "192.168.147.10"
# Nom FQDN (Full Qualified Domain Name) du DC/DHCP
$DHCP_FQDN = "srv-dc1.entreprisexyz.local"
# Nom du domaine Active Directory
$AD_DOMAIN = "entreprisexyz.local"

# Paramètres de l'Étendue (Scope)
$SCOPE_ID = "192.168.147.0"
$SCOPE_NAME = "LAN_EntrepriseXYZ"
$PLAGE_DEBUT = "192.168.147.200"
$PLAGE_FIN = "192.168.147.220"
$MASQUE = "255.255.255.0"

# Options distribuées aux clients
$PASSERELLE = "192.168.147.1"
$DNS_SERVER = "192.168.147.10" # Le serveur DNS est le DC lui-même

# Paramètres de la Réservation Administrative
$RES_IP = "192.168.147.216"
$RES_MAC = "000C29B1F2DE" # Mac Address sans tiret ni point
$RES_NOM = "RES-PosteAdmin"


# ==============================================================================
# 2. INSTALLATION DU RÔLE DHCP
# Commande simple pour installer la fonctionnalité DHCP et les outils de gestion.
# ==============================================================================
Write-Host "--- ÉTAPE 1 : Installation du rôle DHCP ---" -ForegroundColor Yellow
Install-WindowsFeature DHCP -IncludeManagementTools

# Remarque : Les groupes de sécurité DHCP sont souvent créés à l'étape suivante.


# ==============================================================================
# 3. AUTORISATION DU SERVEUR DHCP DANS ACTIVE DIRECTORY
# Cette étape est OBLIGATOIRE lorsque le DHCP est sur le DC pour qu'il puisse démarrer.
# ==============================================================================
Write-Host "--- ÉTAPE 2 : Autorisation DHCP dans le Domaine ---" -ForegroundColor Yellow

# Autorisation du serveur dans la base de données Active Directory
Add-DhcpServerInDC -DnsName $DHCP_FQDN -IPAddress $DHCP_IP
Write-Host "Le serveur DHCP a été déclaré et autorisé dans l'AD." -ForegroundColor Green


# ==============================================================================
# 4. CRÉATION ET ACTIVATION DE L'ÉTENDUE (SCOPE)
# Cette commande définit la plage d'adresses IP à distribuer.
# ==============================================================================
Write-Host "--- ÉTAPE 3 : Création de l'étendue $SCOPE_NAME ---" -ForegroundColor Yellow

Add-DhcpServerv4Scope -Name $SCOPE_NAME `
    -StartRange $PLAGE_DEBUT `
    -EndRange $PLAGE_FIN `
    -SubnetMask $MASQUE `
    -State Active
    
Write-Host "Étendue $SCOPE_NAME créée et activée." -ForegroundColor Green


# ==============================================================================
# 5. CONFIGURATION DES OPTIONS DU DHCP
# Ces options sont envoyées aux clients DHCP (DNS, Passerelle, Domaine).
# ==============================================================================
Write-Host "--- ÉTAPE 4 : Configuration des options DHCP ---" -ForegroundColor Yellow

# On utilise une seule commande pour configurer toutes les options du scope $SCOPE_ID
Set-DhcpServerv4OptionValue -ScopeId $SCOPE_ID `
    -DnsServer $DNS_SERVER `
    -Router $PASSERELLE `
    -DnsDomain $AD_DOMAIN

Write-Host "Options Router, DNS et Domaine configurées pour l'étendue $SCOPE_ID." -ForegroundColor Green


# ==============================================================================
# 6. CRÉATION DE LA RÉSERVATION IP FIXE
# Permet de garantir qu'une machine spécifique reçoive toujours la même IP.
# ==============================================================================
Write-Host "--- ÉTAPE 5 : Création de la Réservation $RES_NOM ---" -ForegroundColor Yellow

Add-DhcpServerv4Reservation -ScopeId $SCOPE_ID `
    -IPAddress $RES_IP `
    -ClientId $RES_MAC `
    -Name $RES_NOM `
    -Description "Réservation permanente pour le poste administratif."
    
Write-Host "Réservation créée : $RES_IP liée à la MAC $RES_MAC" -ForegroundColor Green

# ============================================
# VÉRIFICATION DE LA CONFIGURATION
# ============================================

Write-Host "`n=== VÉRIFICATION DE LA CONFIGURATION DHCP ===" -ForegroundColor Cyan

# Afficher l'étendue créée
Get-DhcpServerv4Scope -ScopeId $SCOPE_ID

# Afficher les options configurées
Write-Host "`nOptions DHCP configurées :" -ForegroundColor Cyan
Get-DhcpServerv4OptionValue -ScopeId $SCOPE_ID

# Afficher les réservations
Write-Host "`nRéservations DHCP :" -ForegroundColor Cyan
Get-DhcpServerv4Reservation -ScopeId $SCOPE_ID

Write-Host "`nConfiguration DHCP terminée avec succès!" -ForegroundColor Green
Stop-Transcript