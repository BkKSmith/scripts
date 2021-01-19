<#

This program was created to remove a stuck lock file from the AIM software. 
Created By:
    Kyle Smith II

    version 0.8

#>

#Get User list
$userList = Get-ChildItem C:\users\ | sort LastWriteTime -Descending

#User folder with the most recent file change should be current user
$currentUser = $userList[0].Name


#Search Temp Folder for the current user account for the lock file
$deleteList = Get-ChildItem -Recurse -Path "C:\users\$currentUser\AppData\local\Temp\" -Filter "mmmain.lck" 

#For each Aim lock file found delete
foreach($i in $deleteList){
    
    $deletePath = $i.DirectoryName
    Remove-Item "$deletePath\mmmain.lck"

}

