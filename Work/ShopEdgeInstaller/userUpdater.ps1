<#
    Created to update the Shopedge software on the client software as they do not provide one
    Created and owned by: Kyle J Smith II 
    Updated: 7/27/2022
    Version: 1.0
#>

            Remove-Item -Path "C:\ShopEdge\*" -Recurse
            Write-Host "Old Binaries erased"
            Copy-Item -Path "\\wap01\c$\ShopEdgeDist\Binaries\" -Recurse -Destination "C:\ShopEdge\"
            Write-Host "New Binaries Installed"