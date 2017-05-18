<#
The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages.
#> 

#requires -Version 2

#Import Localized Data
Import-LocalizedData -BindingVariable Messages

Function New-OSCPSCustomErrorRecord
{
	#This function is used to create a PowerShell ErrorRecord
	[CmdletBinding()]
	Param
	(
	   [Parameter(Mandatory=$true,Position=1)][String]$ExceptionString,
	   [Parameter(Mandatory=$true,Position=2)][String]$ErrorID,
	   [Parameter(Mandatory=$true,Position=3)][System.Management.Automation.ErrorCategory]$ErrorCategory,
	   [Parameter(Mandatory=$true,Position=4)][PSObject]$TargetObject
	)
	Process
	{
	   $exception = New-Object System.Management.Automation.RuntimeException($ExceptionString)
	   $customError = New-Object System.Management.Automation.ErrorRecord($exception,$ErrorID,$ErrorCategory,$TargetObject)
	   return $customError
	}
}

Function Test-OSCUserPrivilege
{
	#This function is used to check whether the current user has enough privilege to run this script.
	$windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()  
	$windowsPrincipal = New-Object -TypeName System.Security.Principal.WindowsPrincipal($windowsIdentity)  
	$Administrator = [System.Security.Principal.WindowsBuiltInRole]::Administrator  
	$isElevated = $windowsPrincipal.IsInRole($Administrator)
	if ($isElevated) {
		return $true
	} else {
		return $false
	}
}

Function Get-OSCUserLogonDuration
{
	<#
		.SYNOPSIS
		Get-OSCUserLogonDuration is an advanced function which can be used to collect user logon duration from one computer.
		.DESCRIPTION
		Get-OSCUserLogonDuration is an advanced function which can be used to collect user logon duration from one computer.
		The user logon duration calculation is based on the general algorithm, Logon duration = Logoff date time - Logon date time.
		Please run this script in an elevated Windows PowerShell console.
		.PARAMETER ComputerName
		Indicates the name of a local or remote computer.
		.PARAMETER Credential
		Specifies a user account that has permission to perform this action. The default is the current user.		
		.PARAMETER StartDate
		Indicates only the events that occur after the specified date and time.
		.PARAMETER EndDate
		Indicates only the events that occur before the specified date and time.
		.PARAMETER IncludeRemoteInteractive
		Indicates the remote interactive logon event entries will be collected or not.
		.PARAMETER IncludeOrphanedEvents
		Indicates the single(orphaned) logon/logoff event entries will be collected or not.
		If the value of this parameter is $true, duplicate event entries may appear in the final result.
		.EXAMPLE
		#Get user logon duration data from last 30 days on a local computer.
		Get-OSCUserLogonDuration -Verbose | FT -AutoSize		
		.EXAMPLE
		#Get user logon duration data from a remote domain computer, remote interactive logon events will be collected.
		Get-OSCUserLogonDuration -ComputerName "computerName" -StartDate (Get-Date -Date "2012/02/01 00:00:00") -EndDate (Get-Date -Date "2012/02/14 23:59:59") -IncludeRemoteInteractive -Verbose | FT -AutoSize
		.EXAMPLE
		#Get user logon duration data from a remote workgroup computer or another domain computer, remote interactive logon events will not be collected.
		$cred = Get-Credential "computername\username"
		Get-OSCUserLogonDuration -ComputerName "computername" -Credential $cred -StartDate (Get-Date -Date "2012/02/01 00:00:00") -EndDate (Get-Date -Date "2012/02/14 23:59:59") -Verbose | FT -AutoSize
		.EXAMPLE
		#Get user logon duration data from a remote computer, including orphaned logon/logoff events.
		Get-OSCUserLogonDuration -ComputerName "computername" -StartDate (Get-Date -Date "2012/02/01 00:00:00") -EndDate (Get-Date -Date "2012/02/14 23:59:59") -IncludeOrphanedEvents -Verbose | FT -AutoSize
		.EXAMPLE
		#Get user logon duration data from multiple computers and generate a CSV file.
		$computers = "computername01","computername02"
		$reports = @()
		foreach ($computer in $computers) {
			$report = Get-OSCUserLogonDuration -Computer $computer -IncludeRemoteInteractive -StartDate (Get-Date -Date "2012/02/01 00:00:00") -EndDate (Get-Date -Date "2012/02/14 23:59:59") -Verbose
			$reports += $report
		}
		$reports | Format-Table -AutoSize
		$reports | Export-csv -Path C:\Scripts\report.csv -NoTypeInformation
		.LINK
		Windows PowerShell Advanced Function
		http://technet.microsoft.com/en-us/library/dd315326.aspx
		.LINK
		Description of security events in Windows 7 and in Windows Server 2008 R2
		http://support.microsoft.com/kb/977519
		.LINK
		Description of security events in Windows Vista and in Windows Server 2008
		http://support.microsoft.com/kb/947226
		.LINK
		Tracking User Logon Activity Using Logon Events
		http://blogs.msdn.com/b/ericfitz/archive/2008/08/20/tracking-user-logon-activity-using-logon-events.aspx		
	#>
	
	[CmdletBinding()]
	Param
	(
		#Define parameters
		[Parameter(Mandatory=$false,Position=1)]
		[string]$ComputerName=$env:COMPUTERNAME,
		[Parameter(Mandatory=$false,Position=2)]
		[System.Management.Automation.PSCredential]$Credential,
		[Parameter(Mandatory=$false,Position=3)]
		[datetime]$StartDate=(Get-Date).AddDays(-30),
		[Parameter(Mandatory=$false,Position=4)]
		[datetime]$EndDate=(Get-Date),
		[Parameter(Mandatory=$false,Position=5)]
		[switch]$IncludeRemoteInteractive,
		[Parameter(Mandatory=$false,Position=6)]
		[switch]$IncludeOrphanedEvents
	)
	Process
	{
		if (-not (Test-OSCUserPrivilege)) {
			$errorMsg = $Messages.PrivilegeTestFailedMsg
			$customError = New-OSCPSCustomErrorRecord `
			-ExceptionString $errorMsg `
			-ErrorCategory NotSpecified -ErrorID 1 -TargetObject $pscmdlet
			$pscmdlet.WriteError($customError)
			return $null
		}
		#Convert local time to universal time
		$startDate = (Get-Date $StartDate).ToUniversalTime()
		$endDate = (Get-date $EndDate).ToUniversalTime()
		#Convert universsal time from DateTime to DmtfDateTime, they will be used in WQL.
		$startDmtfDate = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($StartDate)
		$endDmtfDate = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($EndDate)
		#Create an array object for save the temporary data
		$rawEntries = @()
		#Connect to each target computer
		$verboseMsg = $Messages.ConnectToComputer
		$verboseMsg = $verboseMsg -replace "Placeholder01",$ComputerName
		$pscmdlet.WriteVerbose($verboseMsg)
		#Get the OS version number, this function will collect and process the logon/logoff data
		#from Windows Vista,Windows Server 2008,Windows 7 and Windows Server 2008 R2.
		Try
		{
			if ($Credential -ne $null) {
				$OSVersion = (Get-WmiObject -ComputerName $ComputerName -Credential $Credential -Namespace root\CIMV2 `
				-Class Win32_OperatingSystem -Property Version -ErrorAction Stop).Version
				$timeZoneBias = (Get-WmiObject -ComputerName $ComputerName -Credential $Credential -Namespace root\CIMV2 `
				-Class Win32_TimeZone -Property Bias -ErrorAction Stop).Bias
			} else {
				$OSVersion = (Get-WmiObject -ComputerName $ComputerName -Namespace root\CIMV2 `
				-Class Win32_OperatingSystem -Property Version -ErrorAction Stop).Version
				$timeZoneBias = (Get-WmiObject -ComputerName $ComputerName -Namespace root\CIMV2 `
				-Class Win32_TimeZone -Property Bias -ErrorAction Stop).Bias			
			}
		}
		Catch
		{
			$pscmdlet.WriteError($Error[0])
			return $null
		}
		if ($OSVersion -ne $null) {
			if ($OSVersion.SubString(0,1) -eq "6") {
				$evtFilter = "LogFile='Security' and (TimeGenerated > '$startDmtfDate' and TimeGenerated < '$endDmtfDate') and (EventCode='4624' or EventCode='4647')"
			} else {
				$warningMsg = $Messages.OSVersionPrompt
				$pscmdlet.WriteVerbose($warningMsg)
				return $null
			}
			#Display WQL string for troubleshooting purpose
			$verboseMsg = $Messages.WMIQueryString
			$verboseMsg = $verboseMsg -replace "Placeholder01",$evtFilter
			$pscmdlet.WriteVerbose($verboseMsg)
			#Collect event log entries from another computer with specified filter.
			Try
			{
				if ($Credential -ne $null) {
					$wmiEvents = Get-WmiObject -ComputerName $ComputerName -Credential $Credential -Class Win32_NTLogEvent -Filter $evtFilter `
					-Property "InsertionStrings,EventCode,TimeGenerated" -ErrorAction Stop
				} else {
					$wmiEvents = Get-WmiObject -ComputerName $ComputerName -Class Win32_NTLogEvent -Filter $evtFilter `
					-Property "InsertionStrings,EventCode,TimeGenerated" -ErrorAction Stop				
				}
			}
			Catch
			{
				$pscmdlet.WriteError($Error[0])
			}
			#If this function can collect the event log entries from another computer,
			#then start processing the data.
			if ($wmiEvents -ne $null) {
				$verboseMsg = $Messages.ProcessingPrompt
				$verboseMsg = $verboseMsg -replace "Placeholder01",$wmiEvents.Count
				$pscmdlet.WriteVerbose($verboseMsg)
				foreach ($wmiEvent in $wmiEvents) {
					#Convert DMTF date to DateTime
					$dtTimeGenerated = [System.Management.ManagementDateTimeConverter]::ToDateTime($($wmiEvent.TimeGenerated))
					$dtTimeGenerated = $dtTimeGenerated.ToUniversalTime().AddMinutes($timeZoneBias)
					#Create PSObject for saving the data
					$rawEntry = New-Object System.Management.Automation.PSObject
					$rawEntry | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $ComputerName
					#Process logon and logoff events
					if ($wmiEvent.EventCode -eq 4624) {
						#By default, remote interactive logon entries will not be collected.
						#2 - Interactive Logon; 10 - RemoteInteractive Logon
						if ($IncludeRemoteInteractive) {
							$logonTypeFlag = ($wmiEvent.InsertionStrings[8] -match "2|10")
						} else {
							$logonTypeFlag = ($wmiEvent.InsertionStrings[8] -eq "2")
						}
						#Keep user logon event entries only
						if (($wmiEvent.InsertionStrings[4].Length -gt 12) -and $logonTypeFlag) {
							$rawEntry | Add-Member -MemberType NoteProperty -Name "EventCode" -Value $($wmiEvent.EventCode)
							$rawEntry | Add-Member -MemberType NoteProperty -Name "TimeGenerated" -Value $dtTimeGenerated
							$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetUserID" -Value $($wmiEvent.InsertionStrings[4])
							$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetUserName" -Value $($wmiEvent.InsertionStrings[5])
							$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetDomainName" -Value $($wmiEvent.InsertionStrings[6])
							$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetLogonID" -Value $($wmiEvent.InsertionStrings[7])
							#Translate logon type from number to meaningful words
							if ($wmiEvent.InsertionStrings[8] -ne "") {
								Switch ($wmiEvent.InsertionStrings[8]) {
									2 {$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetLogonType" -Value "Interactive"}
								 	10 {$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetLogonType" -Value "RemoteInteractive"}
									Default {$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetLogonType" -Value $($wmiEvent.InsertionStrings[8])}
								}
								#Add each logon event entry to the temporary array object
								$rawEntries += $rawEntry
							} else {
								$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetLogonType" -Value "N/A"
							}
						}					
					} elseif ($wmiEvent.EventCode -eq 4647) {
						if (($wmiEvent.InsertionStrings[0].Length -gt 12)) {
							$rawEntry | Add-Member -MemberType NoteProperty -Name "EventCode" -Value $($wmiEvent.EventCode)
							$rawEntry | Add-Member -MemberType NoteProperty -Name "TimeGenerated" -Value $dtTimeGenerated
							$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetUserID" -Value $($wmiEvent.InsertionStrings[0])
							$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetUserName" -Value $($wmiEvent.InsertionStrings[1])
							$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetDomainName" -Value $($wmiEvent.InsertionStrings[2])
							$rawEntry | Add-Member -MemberType NoteProperty -Name "TargetLogonID" -Value $($wmiEvent.InsertionStrings[3])
							$rawEntries += $rawEntry
						}
					}
				}
			} else {
				#Cannot find logon/logoff WMI events within the specified time.
				$warningMsg = $Messages.CannotFindWMIEvents
				$warningMsg = $warningMsg -replace "Placeholder01",$ComputerName
				$pscmdlet.WriteWarning($warningMsg)					
			}
			$rawEntry = $null
		}
		#Sort raw logon/logoff entries by TimeGenerated property
		$rawEntries = ($rawEntries | Sort-Object -Property TimeGenerated)
		#Group raw logon/logoff entries by TargetLogonID property and remove any orphaned logon/logoff events.
		if ($IncludeOrphanedEvents) {
			$groupByLogonIDs = ($rawEntries | Group-Object -Property TargetLogonID)
		} else {
			$groupByLogonIDs = ($rawEntries | Group-Object -Property TargetLogonID | Where-Object {$_.Count -eq 2})
		}
		#Create an array object for save the final results
		$results = @()
		#Process the data to generate a final report
		if ($groupByLogonIDs -ne $null) {
			if ($groupByLogonIDs -is [array]) {
				#$groupByLogonIDs[$index].Group[0] contains the logon data
				#$groupByLogonIDs[$index].Group[1] contains the logoff data
				#For orphaned events, $groupByLogonIDs[$index].Group[0] contains logon or logoff data
				for ($index=0;$index -lt $groupByLogonIDs.Count;$index++) {
					$result = New-Object PSObject
					if ($groupByLogonIDs[$index].Group.Count -eq 2) {
						$logonDuration = $(($groupByLogonIDs[$index].Group[1].TimeGenerated - `
						$groupByLogonIDs[$index].Group[0].TimeGenerated).TotalMinutes.ToString("N2"))
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader01) `
						-Value $($groupByLogonIDs[$index].Group[0].ComputerName)
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader02) `
						-Value $($groupByLogonIDs[$index].Group[0].TargetDomainName)					
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader03) `
						-Value $($groupByLogonIDs[$index].Group[0].TargetUserName)
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader04) `
						-Value $($groupByLogonIDs[$index].Group[0].TargetLogonType)
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader05) `
						-Value $($groupByLogonIDs[$index].Group[0].TimeGenerated)
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader06) `
						-Value $($groupByLogonIDs[$index].Group[1].TimeGenerated)				
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader07) `
						-Value $logonDuration
					} else {
						$logonDuration = "N/A"
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader01) `
						-Value $($groupByLogonIDs[$index].Group[0].ComputerName)
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader02) `
						-Value $($groupByLogonIDs[$index].Group[0].TargetDomainName)					
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader03) `
						-Value $($groupByLogonIDs[$index].Group[0].TargetUserName)
						if ($($groupByLogonIDs[$index].Group[0].EventCode -eq 4624)) {
							$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader04) `
							-Value $($groupByLogonIDs[$index].Group[0].TargetLogonType)
						} else {
							$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader04) `
							-Value "N/A"
						}						
						if ($($groupByLogonIDs[$index].Group[0].EventCode -eq 4624)) {
							$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader05) `
							-Value $($groupByLogonIDs[$index].Group[0].TimeGenerated)
						} else {
							$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader05) `
							-Value "N/A"						
						}
						if ($($groupByLogonIDs[$index].Group[0].EventCode -eq 4647)) {
							$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader06) `
							-Value $($groupByLogonIDs[$index].Group[0].TimeGenerated)
						} else {
							$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader06) `
							-Value "N/A"						
						}
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader07) `
						-Value $logonDuration					
					}
					$results += $result
				}
			} else {
				$result = New-Object PSObject
				if ($groupByLogonIDs.Group.Count -eq 2) {
					$logonDuration = $(($groupByLogonIDs.Group[1].TimeGenerated - `
					$groupByLogonIDs.Group[0].TimeGenerated).TotalMinutes.ToString("N2"))
					$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader01) `
					-Value $($groupByLogonIDs.Group[0].ComputerName)
					$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader02) `
					-Value $($groupByLogonIDs.Group[0].TargetDomainName)
					$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader03) `
					-Value $($groupByLogonIDs.Group[0].TargetUserName)
					$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader04) `
					-Value $($groupByLogonIDs.Group[0].TargetLogonType)				
					$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader05) `
					-Value $($groupByLogonIDs.Group[0].TimeGenerated)
					$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader06) `
					-Value $($groupByLogonIDs.Group[1].TimeGenerated)
					$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader07) `
					-Value $logonDuration
				} else {
					$logonDuration = "N/A"
					$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader01) `
					-Value $($groupByLogonIDs.Group[0].ComputerName)
					$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader02) `
					-Value $($groupByLogonIDs.Group[0].TargetDomainName)
					$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader03) `
					-Value $($groupByLogonIDs.Group[0].TargetUserName)
					if ($($groupByLogonIDs.Group[0].EventCode -eq 4624)) {
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader04) `
						-Value $($groupByLogonIDs.Group[0].TargetLogonType)
					} else {
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader04) `
						-Value "N/A"					
					}
					if ($($groupByLogonIDs.Group[0].EventCode -eq 4624)) {
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader05) `
						-Value $($groupByLogonIDs.Group[0].TimeGenerated)
					} else {
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader05) `
						-Value "N/A"						
					}
					if ($($groupByLogonIDs.Group[0].EventCode -eq 4647)) {
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader06) `
						-Value $($groupByLogonIDs.Group[0].TimeGenerated)
					} else {
						$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader06) `
						-Value "N/A"					
					}
					$result | Add-Member -MemberType NoteProperty -Name $($Messages.ReportColumnHeader07) `
					-Value $logonDuration				
				}
				$results += $result
			}
		} else {
			$verboseMsg = $Messages.CannotFindInteractiveLogonEvents
			$verboseMsg = $verboseMsg -replace "Placeholder01",$ComputerName
			$pscmdlet.WriteVerbose($verboseMsg)
		}
		#Return the results
		return $results
	}
}

