<#

Written for FEV by Kyle Smith II
version: 1.2
2/22/2019

#>




<# Copy Spiceworks Agent to installation machine
        **The copy lines can be uncommented out and the local location can be used instead
 
New-Item -ItemType "directory" -Path "D:\SpiceworksInstall"
Copy-Item "\\uss001\it\Software\Spiceworks\Spiceworks_TLS_Agent.msi" -Destination "D:\SpiceworksInstall"
#>


#Setting the paramaters for msiexec inside of the start-process command
$param = '/i', '\\uss001\it_us\Software\Spiceworks\Spiceworks_TLS_Agent.msi', 'SPICEWORKS_SERVER=172.26.1.11', 'SPICEWORKS_PORT=443', 'SPICEWORKS_AUTH_KEY="H6IkSsb6p/3J6wmFqHpSrPvfp6w="', 'ADDLOCAL="FeatureService,FeatureTray"', 'TRAY_CLICK_URL="http://helpdesk-us/portal"', 'TRAY_CLICK_LABEL="FEV_Helpdesk"', '/q', '/norestart'

#Wait is needed below so that the process in the try catch statement does not error out and waits for the install to be completed
Start-Process 'msiexec.exe' -ArgumentList $param -NoNewWindow -Wait


try{

#The Spiceworks 
Start-Process "C:\Program Files (x86)\Spiceworks\Agent\Spiceworks Agent App.exe"


}

catch [InvalidOperationException]{
Write-Host "Location Not Available"


}