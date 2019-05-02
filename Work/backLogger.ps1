<#$creationDate = @()
$backupFolders = @()


 Get-Date -UFormat %x

 #>

Write-Host "Getting the size of the used space on \\USN015 for backups. Please wait"
Write-Host "
"

((Get-ChildItem -Force -Path "\\USN015\Backups\" -Recurse -File | Measure-Object -Sum Length | Select-Object Sum).sum / 1GB) | Out-File -Append -FilePath "\\USN015\Backups\logfile.txt"

Get-Date | Out-File -Append -FilePath "\\USN015\Backups\logfile.txt"



Write-Host "=======================Completed=======================" -ForegroundColor Green