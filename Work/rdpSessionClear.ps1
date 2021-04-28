Clear-Host
Write-Host "This program was created to clear redp sessions that are stuck in a disconnected status"
Write-Host "Please pick from the list of machines below"

$machineSelect = Read-Host "1)201 `n2)202 `n3)203 `n4)204 `n5)205 `n6)206 `n"

if($machineSelect -eq 1){
    $machineName = "wicow10pvm01"
}

if ($machineSelect -eq 2){
    $machineName = "wicow10pvm02"
}

if ($machineSelect -eq 3){
    $machineName = "wicow10pvm03"
}

if ($machineSelect -eq 4){
    $machineName = "wicow10pvm04"
}

if ($machineSelect -eq 5){
    $machineName = "wicow10pvm05"
}

if ($machineSelect -eq 6){
    $machineName = "wicow10pvm06"
}

if ($machineSelect -eq 7){
    $machineName = "ediRemote"
}

$sessionQuery= qwinsta /server:$machineName

<#$sessionObject = New-Object [PSCustomObject]@{
    ComputerName = $machineName
    SessionName = $outDisplay[0]
    UserName = $outDisplay[1]
    ID = $outDisplay[2]
    State = $outDisplay[3]
    Type = $outDisplay[4]
}#>
ForEach ($line in $sessionQuery[1..$sessionQuery.count]){
  $outDisplay = $line.split(" ") | Where-Object{$_.length -gt 0}
  if(($line[19] -ne " ")){
    If($line[48] -eq "A"){
        $outData = [PSCustomObject]@{
         ComputerName = $machineName
         SessionName = $outDisplay[0]
         UserName = $outDisplay[1]
         ID = $outDisplay[2]
         State = $outDisplay[3]
         Type = $outDisplay[4]
        }
        $outData
        
    }
    Else{
        $outData = [PSCustomObject]@{
            ComputerName = $machineName
            SessionName = $null
            UserName = $outDisplay[0]
            ID = $outDisplay[1]
            State = $outDisplay[2]
            Type = $null
           }
           Clear-Host
           Write-Host "The Following connection has a disconnected status`n"
           $outData
           Write-Host "`n`nAttempting to clear the disconnected session, please wait"
           Try{
               rwinsta $outData.ID /server:$machineName
           }
           Catch{
               Write-Host "An error occured. Please contact your IT Administrator for more help"
           }
        }
    }
        }



