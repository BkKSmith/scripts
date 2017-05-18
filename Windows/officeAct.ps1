


Write-Host "When entering the year below please only enter the last two digits for the year. Example 2016 = 16"

    $year = Read-Host -Prompt "What year of office do you have?"
   $startMain = Read-Host "This pc is running office $year correct?(true/false)"

if($startMain -eq $true){
    $ErrorActionPreference = 'SilentlyContinue'
    Write-host "works"
    try{
        c:\windows\system32\cscript.exe "c:\program files\microsoft office\office$year\ospp.vbs" /sethst:kms01.sys.oakland.edu
        c:\windows\system32\cscript.exe "c:\program files\microsoft office\office$year\ospp.vbs" /act 
        }

    Catch [system.exception]{
        c:\windows\system32\cscript.exe "c:\program files\microsoft office\office$year\ospp.vbs" /act
        c:\windows\system32\cscript.exe "c:\program files\microsoft office\office$year\ospp.vbs" /sethst:kms01.sys.oakland.edu
    }

}
else{
    if($startMain -eq $false){
        
        $year = Read-Host -Prompt "What year of office do you have?"
        $startMain = Read-Host "This pc is running office $year correct?(true/false)"

        if($startMain -eq $true){
    $ErrorActionPreference = 'SilentlyContinue'
    Write-host "works"
    try{
        c:\windows\system32\cscript.exe "c:\program files\microsoft office\office$year\ospp.vbs" /sethst:kms01.sys.oakland.edu
        c:\windows\system32\cscript.exe "c:\program files\microsoft office\office$year\ospp.vbs" /act 
        }

    Catch [system.exception]{
        c:\windows\system32\cscript.exe "c:\program files\microsoft office\office$year\ospp.vbs" /act
        c:\windows\system32\cscript.exe "c:\program files\microsoft office\office$year\ospp.vbs" /sethst:kms01.sys.oakland.edu
    }

}

    }
  
}