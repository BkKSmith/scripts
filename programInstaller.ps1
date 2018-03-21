


$programNumber = Read-Host -Prompt "How many programs do you wish to install?"


if($startMain -le $programNumber){
    $fileLocation = Read-Host -Prompt "What is the fully qualified location of the install file?"
   Start-Process "$fileLocation" -ArgumentList "/S" -Wait
   
   $startMain = $startMain + 1

}
else{
Write-Host "You are done installing"
}