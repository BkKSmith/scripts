<#
    This module is made to help make termination work be more automated. As things are completed
    and the code is testd, more features will be added

    Ver. 1.1


#>
$programRun = "yes"

While($programRun -eq "yes"){

    $targetComputer = $env:COMPUTERNAME

    Write-Host "Running on $targetComputer (enter y for yes)?"
    $differentComputer = Read-Host

    If($differentComputer -ne "y"){
        Write-Host "Please enter the computer name:  "
        $targetComputer = Read-Host
    }



If($targetComputer -ne $null){
    Write-Host "Enter the number with the corresponding task you want to complete
    Enter 1 for pulling Member Information
    Enter 2 Change Title and Description(Change Notifications)
    Enter 3 to Search for data on a drive
    Enter 4 to backup data to external drive 
    More Options Coming soon"
    
    $decisionTime = Read-Host


    If($decisionTime -eq 1){

        #Make sure to set $FormatEnumerationLimit to -1 or it will not dislay the entire list.This is an env var.
        $FormatEnumerationLimit=-1
        Get-ADComputer $targetComputer -Properties "MemberOf" > C:\Users\smith_ky\Desktop\testFile3.txt


    }

    if($decisionTime -eq 2){
    
        <# targetAccount takes user input. Try to make sure that you are using the user's username,
           not their First or last name#>
        Write-Host "Please enter the user's name that you are going to change"
        $targetAccount = Read-Host
        
        Get-ADUser $targetAccount

        Write-Host "Please verify that is the correct user"

        $correctUser = Read-Host
        
        If($correctUser -eq 'yes'){

            Write-Host "Enter what the new job position will be"
            $titleChange = Read-Host
            Set-ADUser $targetAccount -Title $titleChange -Description $titleChange

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

       $userLName = Read-Host "Please Enter the last name of the user's machine that you are working on"
       
       
       $backupHome = "\\wico0002\Cold_Storage\"

       Write-Host "Are you backing this up to the normal location, $backupHome (y for yes)?"

       $correctLocation = Read-Host

       If($correctLocation -ne "y"){
        Write-Host "Where is the location that you want to back this up to?"
        $backupHome = Read-Host
       }
       
       $yellowBrickRoad = $backupHome + $userLName + "_" + $targetComputer
       $pathTester = Test-Path -Path $yellowBrickRoad

       If($pathTester -eq $true){
            $backupHome = Read-Host "Error, path already exists. Pleast enter a unique entry"
        
       }

       else{

           $CdriveBack = $yellowBrickRoad + "\CDrive"
            New-Item -ItemType Directory -Path $CdriveBack
        
           #$DdriveBack = $yellowBrickRoad + "\DDrive"
            #New-Item -ItemType Directory -Path $DdriveBack

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

Write-Host "Task completed! Thank You for Using this tool, 
if you are done you can close out at this point. 
Otherwise it will continue from the main menu

" -ForegroundColor Green
}