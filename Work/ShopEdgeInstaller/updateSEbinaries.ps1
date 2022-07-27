<#
    Created to update the Shopedge software on the client software as they do not provide one
    Created and owned by: Kyle J Smith II 
    Updated: 7/27/2022
    Version: 1.0
#>
   
    Remove-Item -Path "\\$i\C$\ShopEdge\Binaries\" -Recurse
    Copy-Item -Path "\\wap01\c$\ShopEdgeDist\Binaries\" -Recurse -Destination "\\$i\C$\ShopEdge"
    Copy-Item -Path "\\wfs01\Users\ksmith\public\ShopEdge.ERP.lnk" -Destination "\\$i\C$\users\public\Desktop\"
    Write-Host "Folder created and software installed"