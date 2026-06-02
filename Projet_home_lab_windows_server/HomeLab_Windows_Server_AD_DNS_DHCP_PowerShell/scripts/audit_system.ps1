$Date = Get-Date -Format "dd/MM/yyyy HH:mm"
$ComputerName = $env:COMPUTERNAME
$User = $env:USERNAME
$OS = (Get-ComputerInfo).OsName
$CPU = (Get-WmiObject Win32_Processor).Name
$RAM = (Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB
$Rapport = @"
===== RAPPORT SYSTEME =====
Machine : $ComputerName
Utilisateur : $User
OS : $OS
Processeur : $CPU
RAM (Go) : $([math]::Round($RAM,2))
Date : $Date
===========================
"@
New-Item -Path "C:\Users\Administrateur\Documents\exports" -ItemType Directory -Force
$OutDir  = "C:\Users\Administrateur\Documents\exports"
$OutFile = Join-Path $OutDir "system_info.txt"

$Rapport | Out-File -FilePath $OutFile -Encoding UTF8 -Force
Write-Host "Rapport généré dans $OutFile" -ForegroundColor Green

