<#
    This module is made to help make termination work be more automated. As things are completed
    and the code is testd, more features will be added



#>

Write-Host "Hello there, please enter the computer you would like to run a script on"
$targetComputer = Read-Host

If($targetComputer -ne $null){
    Write-Host "Enter the number with the corresponding task you want to complete
    Enter 1 for pulling Member Information
    Enter 2 to copy the data to a backing up commands Not Completed yet
    Enter 3 to Search for data on a drive
    Enter 4 to backup data to external drive 
    More Options Coming soon"
    
    $decisionTime = Read-Host


    If($decisionTime -eq 1){
        Get-ADComputer $targetComputer -Properties "MemberOf" > C:\Users\smith_ky\Desktop\testFile3.txt


    }

    if($decisionTime -eq 2){
        Write-Host "This will create the backup folders for a machine with little input
        First Enter the ticket number for the machine you are working on
        If there isn't a ticket then enter 00000"
        $tNumber = Read-Host
        
  
        
        Write-Host "Enter the drive you want to use store the data"
        $driveName = Read-Host 
        $testDesired = Test-Path -Path "$driveName$tNumber$targetComputer"
        
        If($testDesired -eq 'True'){


        }


    }

    If($decisionTime -eq 3){

        write-Host "---------------------------------------------" -ForegroundColor Green
        $filePath = Read-Host "Please Enter File Path to Search"
        write-Host "---------------------------------------------" -ForegroundColor Green 
        $fileName = Read-Host "Please Enter File Name to Search" 
        write-Host "---------------------------------------------" -ForegroundColor Green 
        "`n" 
 
        Get-ChildItem -Recurse -Force $filePath -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*$fileName*") } | Select-Object Name,Directory| Format-Table -AutoSize * 
 
        write-Host "------------END of Result--------------------" -ForegroundColor Red
 
        # end of the script

    }

    If($decisionTime -eq 4){
       Write-Host "This will back up the data under the users folder and the D:\
       and push that to a back up drive of your selection."

       $ticketNumber = Read-Host "Please enter the ticket number that you are working on"
       $backupHome = Read-Host "Please enter the path where the root drive should be saved"
       
       $yellowBrickRoad = $backupHome + $ticketNumber + "_" + $targetComputer
       $pathTester = Test-Path -Path $yellowBrickRoad

       If($pathTester -eq $true){
            $backupHome = Read-Host "Error, path already exists. Pleast enter a unique entry"
        
       }

       else{

           $CdriveBack = $yellowBrickRoad + "\CDrive"
            New-Item -ItemType Directory -Path $CdriveBack
        
           $DdriveBack = $yellowBrickRoad + "\DDrive"
            New-Item -ItemType Directory -Path $DdriveBack

            Write-Host "-----------Finished Creating Folders---------" -ForegroundColor Green
        
           $copyUser = Read-Host "Please enter the user's profiles that you would like to move over"

           Copy-Item -Path "C:\Users\$copyUser" -Destination "$CdriveBack" -Recurse

           Write-Host "-----------Finished Copying User Folders---------" -ForegroundColor Green

           Copy-Item -Path D:\* -Destination "$DdriveBack" -Recurse

           Write-Host "___________Fininhed Copying D Drive Over_________" -ForegroundColor Green
       
       }

       
       #Copy-Item "Path\to\file" -Destination "final\resting\place" -Recurse
    
    
    }

}
