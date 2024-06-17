<#
This Program was made to push the Shop Edge installer to machines connected to the network

Created and owned By:
    Kyle Smith II
1
#>

#This initiates the variables needed

$goodValues =@()
$retryLater = @()
#Set below value equal to location of the machine list text file
$computerArray = @(Get-Content \\wfs01\users\ksmith\ShopEdgeInstaller\installList.txt)

#For each loop goes through each item in the computer $computerArray
Foreach($i in $computerArray){
    Write-Host "$i" -ForegroundColor Blue
    #Test Connection to host
    $connectionPass = Test-Connection -Quiet $i
    
    If ($connectionPass -eq $True){
        Write-Host "Working" -ForegroundColor Green

        #If the connection was established test to see if the path below exists
        If ((Test-Path "\\$i\c$\ShopEdge") -eq $True){
            Copy-Item -Path "\\wap01\c$\ShopEdgeDist\Binaries\" -Recurse -Destination "\\$i\C$\ShopEdge"
            Copy-Item -Path "\\wfs01\Users\ksmith\public\ShopEdge.ERP.lnk" -Destination "\\$i\C$\users\public\Desktop\"
            
            $goodValues = $goodValues + "$i Install_Completed"
            
            Copy-Item -Path "\\wap01\ShopEdgeDist\Redist\RS Report Viewer version 12" -Recurse -Destination "\\$i\C$\Temp"
            Write-Host "Install Completed" -ForegroundColor Green
            }

        Else{
            New-Item -Path "\\$i\C$\ShopEdge" -ItemType Directory
            Copy-Item -Path "\\wap01\c$\ShopEdgeDist\Binaries\" -Recurse -Destination "\\$i\C$\ShopEdge"
            Copy-Item -Path "\\wfs01\Users\ksmith\public\ShopEdge.ERP.lnk" -Destination "\\$i\C$\users\public\Desktop\"

            $goodValues = $goodValues + "$i Fresh_Install_Completed"

            Copy-Item -Path "\\wap01\ShopEdgeDist\Redist\RS Report Viewer version 12" -Recurse -Destination "\\$i\C$\Temp"
            Write-Host "Folder created and software installed" -ForegroundColor Green
            }


    }

    ElseIf($connectionPass -eq $False){
       $retryLater = $retryLater + $i 
        
    }
}

$goodValues | Out-File -Append \\wfs01\users\ksmith\public\installCompleted.csv
$retryLater | Out-File \\wfs01\users\ksmith\public\notOnline.txt