Clear-Host
$installDestination=Read-Host -Prompt 'Input Destination'

Copy-Item -Path "\\wfs01\IT DEPT\Software\VLC\vlc-3.0.16-win64.exe" -Destination "\\$installDestination\C$\Temp"

Invoke-Command -Computer $installDestination -ScriptBlock {Start-Process -FilePath 'C:\Temp\vlc-3.0.16-win64.exe' -ArgumentList '/L=1033','/S' -Wait}