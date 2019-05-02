<#
This Program was made to help keep track of Uniplot licenses that we have out and which ones may not be in use
Created By:
    Kyle Smith II

#>

#This initiates the variables needed

$goodValues =@()
$retryLater = @()
$computerArray = @(Get-Content \\USS001\public\Smith_Ky\machineNames.txt)

#For each loop goes through each item in the computer $computerArray
Foreach($i in $computerArray){
    Write-Host "$i"
    #Test Connection to host
    $connectionPass = Test-Connection -Quiet $i
    
    If ($connectionPass -eq $True){
        Write-Host "Working"

        #If the connection was established test to see if the path below exists
        If ((Test-Path "\\$i\c$\Program Files (x86)\UniPlot Software") -eq $True){
            $goodValues = $goodValues + "$i Path_Found"
            Write-Host "32bit Path Exists"
            }

        ElseIf ((Test-Path "\\$i\c$\Program Files\UniPlot Software")-eq $True){
            $goodValues = $goodValues + "$i Path_Found"
            Write-Host "64bit Path Exists"
            }

        Else{

            $goodValues = $goodValues + "$i No"
            Write-Host "Path Not Found"
            }

    }

    ElseIf($connectionPass -eq $False){
       $retryLater = $retryLater + $i 
        
    }
}

$goodValues | Out-File -Append \\uss001\public\Smith_Ky\verfiedMachines.csv
$retryLater | Out-File \\uss001\public\Smith_ky\machineNames.txt