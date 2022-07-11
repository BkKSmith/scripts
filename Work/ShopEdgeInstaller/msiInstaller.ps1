

#Moved copy over to main installer script to see if the installation is failing at the copy point
#Copy-Item -Path "\\wap01\ShopEdgeDist\Redist\RS Report Viewer version 12" -Recurse -Destination "C:\Temp"
Start-Process C:\Windows\System32\msiexec.exe -ArgumentList '/i "C:\Temp\RS Report Viewer version 12\SQLSysClrTypes_x64.msi" /quiet /qn /norestart' -Wait -verb runAS
Start-Process msiexec.exe -ArgumentList '/i "C:\Temp\RS Report Viewer version 12\ReportViewer.msi" /quiet /qn /norestart' -Wait -verb runAS


#Write-Host "Install complete"


<#

msiexec.exe /i C:\Temp\SQLSysClrTypes_x64.msi /quiet /qn /norestart /log C:\Temp\installTest.log PROPERTY1=value1 PROPERTY2=value2
msiexec.exe /i C:\Temp\ReportViewer.msi /quiet /qn /norestart /log C:\Temp\installTest.log

#>