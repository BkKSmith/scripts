
<#

This was created to be able to push a msi install needed for shopedge. Origninal version needed to be ran locally on the computer. This one however, just
needs the computer to have PSRemoting enabled. Once enabled, then it will run properly. 

Created and owned by: Kyle J Smith II 
    Updated: 10/6/2022
    Version: 2.1
#>


#Moved copy over to main installer script to see if the installation is failing at the copy point
#Copy-Item -Path "\\wap01\ShopEdgeDist\Redist\RS Report Viewer version 12" -Recurse -Destination "C:\Temp"

Write-Host "Please enter the computer name:  "
$targetComputer = Read-Host

Invoke-Command -ComputerName $targetComputer -ScriptBlock{Start-Process C:\Windows\System32\msiexec.exe -ArgumentList '/i "C:\Temp\RS Report Viewer version 12\SQLSysClrTypes_x64.msi" /quiet /qn /norestart' -Wait -verb runAS}
Invoke-Command -ComputerName $targetComputer -ScriptBlock{Start-Process msiexec.exe -ArgumentList '/i "C:\Temp\RS Report Viewer version 12\ReportViewer.msi" /quiet /qn /norestart' -Wait -verb runAS}




