<#
.SYNOPSIS
Ce script configure le service DNS pour l'entreprise EntrepriseXYZ.

.DESCRIPTION
# Ce script supprime les anciennes zones DNS, crée les nouvelles zones directe et inversée, ajoute les enregistrements A et PTR nécessaires, et effectue des vérifications pour s'assurer que tout fonctionne correctement.
#>

# ============================================

Start-Transcript -Path "O:\transcriptDNS_config.txt" -Append

# 1. Vérification des prérequis
Write-Host "--- Vérification des services ---" -ForegroundColor Cyan
Get-WindowsFeature DNS
Get-Service -Name DNS

# 2. Nettoyage (Suppression des anciennes zones si elles existent)
Write-Host "--- Nettoyage des anciennes zones ---" -ForegroundColor Cyan
# On supprime sans demander confirmation (-Force) et on ignore si ça n'existe pas (-ErrorAction SilentlyContinue)
Remove-DnsServerZone -Name 'entreprisexyz.local' -Force -ErrorAction SilentlyContinue
Remove-DnsServerZone -Name '147.168.192.in-addr.arpa' -Force -ErrorAction SilentlyContinue

# 3. Création des Zones (Directe et Inversée)
Write-Host "--- Création des zones ---" -ForegroundColor Cyan
Add-DnsServerPrimaryZone -Name 'entreprisexyz.local' -ReplicationScope 'Domain' -DynamicUpdate Secure
Add-DnsServerPrimaryZone -NetworkID '192.168.147.0/24' -ReplicationScope 'Domain' -DynamicUpdate Secure

# 4. Ajout des enregistrements
Write-Host "--- Ajout des enregistrements A et PTR ---" -ForegroundColor Cyan
# Ajout du A (sans créer le PTR auto pour éviter l'erreur, car on le fait manuellement après)
Add-DnsServerResourceRecordA -Name 'srv-dc1' -ZoneName 'entreprisexyz.local' -IPv4Address '192.168.147.10'
# Ajout du PTR manuellement
Add-DnsServerResourceRecordPTR -Name '10' -ZoneName '147.168.192.in-addr.arpa' -PtrDomainName 'srv-dc1.entreprisexyz.local'

# 5. Vérifications
Write-Host "--- Vérification Finale ---" -ForegroundColor Green
Get-DnsServerZone
Write-Host "Test A:"
nslookup srv-dc1.entreprisexyz.local
Write-Host "Test PTR:"
nslookup 192.168.147.10
Get-DnsServerResourceRecord -ZoneName "147.168.192.in-addr.arpa" -RRType PTR
Resolve-DnsName 192.168.147.10
Stop-Transcript