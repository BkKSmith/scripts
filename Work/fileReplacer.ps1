<#
    Created to update the Shopedge software on the client software as they do not provide one
    Created and owned by: Kyle J Smith II 
    Updated: 7/27/2022
    Version: 1.2
#>
   
<#Make sure that the below location is changed when using for another install#>
$computerArray = @(Get-Content \\wfs01\users\ksmith\ShopEdgeInstaller\repairList.txt)
$installLog = @()


    Foreach($i in $computerArray){
        Write-Host "Attempting to connnect to: $i" -ForegroundColor Blue
        #Test Connection to host
        $connectionPass = Test-Connection -Quiet $i
        
        If ($connectionPass -eq $True){
            Write-Host "Connection Completed" -ForegroundColor Green
            try{
                Write-Host "Attempting to delete old file" -ForegroundColor Blue
                Remove-Item -Path "\\$i\C$\ShopEdge\Binaries\ShopEdge.ERP.exe.config" -ErrorAction Stop
                $continueUpdate = $True
            }
            
            catch [System.UnauthorizedAccessException]{
                Write-Host "Unable to remove file" -ForegroundColor Red
                $installLog = $installLog + "$i,Update failed during deletion" 
                $continueUpdate = $False
            }

            if ($continueUpdate -eq $True){
                Write-Host "Old file deleted" -ForegroundColor Green
                Copy-Item -Path "\\wfs01\users\ksmith\public\ShopEdge.ERP.exe.config" -Recurse -Destination "\\$i\C$\ShopEdge\Binaries"
                Write-Host "New File installed" -ForegroundColor Green
                $installLog = $installLog + "$i,Installation completed"
            }

    
        }
    
        ElseIf($connectionPass -eq $False){
           Write-Host "The following machine has failed updating: $i" -ForegroundColor Red
           $installLog = $installLog + "$i,Unable to connect"
        } 
    }
    
    $installLog | Out-File \\wfs01\users\ksmith\public\seUpdateLog.csv