Clear-Host
$installLocation=Read-Host -Prompt "Input the pc Name"
$printerName=Read-Host -Prompt "Please enter the name of the printer you would like to add"






Invoke-Command -ComputerName $installLocation -ScriptBlock {Add-Printer -ConnectionName "\\WPS01\$printerName"}