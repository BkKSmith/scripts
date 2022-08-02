<#
    Created to update the Shopedge software on the client software as they do not provide one
    Created and owned by: Kyle J Smith II 
    Updated: 7/27/2022
    Version: 1.0
#>
   
<#Make sure that the below location is changed when using for another install#>
$computerArray = @(Get-Content \\wfs01\users\ksmith\ShopEdgeInstaller\machineUpdateList.txt)



    Foreach($i in $computerArray){
        Write-Host "Attempting to connnect to: $i"
        #Test Connection to host
        $connectionPass = Test-Connection -Quiet $i
        
        If ($connectionPass -eq $True){
            Write-Host "Connection Completed"
    
            Remove-Item -Path "\\$i\C$\ShopEdge\*" -Recurse
            Write-Host "Old Binaries erased"
            Copy-Item -Path "\\wap01\c$\ShopEdgeDist\Binaries\" -Recurse -Destination "\\$i\C$\ShopEdge"
            Write-Host "New Binaries updated"
    
    
        }
    
        ElseIf($connectionPass -eq $False){
           Write-Host "The following machine has failed updating: $i"
            
        }
    }
    