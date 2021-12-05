<#
.Synopsis
Ping tests remote computer
.Description
Sends ICMP requests to a remote machine
.Parameters
-Computername <[]String>
    The name/IP address of the test computer

    Required?                       True
    Position?                       1
    Default value
    Accept pipeline input           False
    Accept wildcard Characters?     False

-Path <String>
    The name or path of the location to save output to. User home directory is default

    Required                        False
    Position?                       2
    Default value                   "$Env:USERPROFILE"
    Accept pipeline input?          False
    Accept wildcard Characters?     False

-Output <String>
    Specifies the destination of output when the script is ran. Accepted inputs are:
    -Host (On-Screen)
    -Text (.txt file)
    -CSV (.csv file)
    
    Required?                        False
    Position?                        3
    Defaulte value                   Host
    Accept pipeline input            False
    Accept wildcard characters       False

.Notes

Author: Dakota Denton-Velasquez
Last Edit: 10/24/2021
Version 1.0 - Initial Release of Test-Cloudflare

---------------Example 1---------------------
c:\>.\Test-Cloudflare - Computername Localhost

Example 1: Test connectivity to specific computer


---------------Example 2---------------------
C:\>.\Test-Cloudflare -Computername Localhost -output CSV

Example 2: Test connectivity and write results to a specific format (CSV,TEST,Host)

---------------Example 3----------------------
c:\>.\Test-Cloudflare -Computername Localhost -path c:\Temp

Example 3: Test connectivity and change the path where results are saved


#>

[Cmdletbinding()]

Param (
    [Parameter(mandatory=$true)]
    [string[]]$Computername,
    [Parameter(Mandatory=$false)]
    [string]$Path = "$env:USERPROFILE",
    [Parameter(mandatory=$true)]
    [string]$Output

)
Clear-Host
#Clears display
Set-Location $Path
# move working location
$DateTime = Get-Date
#Getting Date

$session = New-PSSession -ComputerName $Computername
Write-Verbose "Remotely connecting to $Computername" -Verbose
#create remote session while saving name as a variable

invoke-command -command { test-netconnection -Computername one.one.one.one -InformationLevel Detailed} -Session $session -AsJob -Jobname RemTestNet 
Write-Verbose "Sending ICMP packets to $Computername" -verbose
#start pings
start-sleep -s 10

Write-Verbose "Opening results" -Verbose

Receive-Job -Name RemTestNet | Out-File .\JobResults.txt

Add-Content .\RemTestNet.txt -Value "Computer Name: $Computername"
Add-Content .\RemTestNet.txt -Value "Date & time: $DateTime"
Add-Content .\RemTestNet.txt -Value (Get-Content .\JobResults.txt)
#Adding content and information to RemTestNet

switch ($Output) {
    'csv' { Out-File RemTestNet.Csv }
    'text' {notepad.exe .\RemTestNet.txt}
    'host' {get-content .\RemTestNet.txt}
    default { Write-Host "$output is an invalid output type."} 
   }
#Checks output types and changes behavior 

Write-Verbose "Finished Ping Test."
Start-sleep -s 5
Remove-PSSession $Session
Remove-Item ".\RemTestNet.txt"
