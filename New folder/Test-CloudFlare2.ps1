<#
.Synopsis
Ping tests remote computer
.Description
Sends ICMP requests to a remote machine
.Parameter Path
Path is the the working file directory
.Parameter Computername
This is a mandatory parameter for the working computer
.Notes

#>

[Cmdletbinding()]

Param (
    [Parameter(mandatory=$true)]
    [string[]]$Computername,
#choose computer for test
    [Parameter(Mandatory=$false)]
    [string]$Path = "$env:USERPROFILE"
#changing working directory

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
#Adding content and information

notepad.exe .\RemTestNet.txt

Write-Verbose "Finished Ping Test."

Remove-PSSession $Session
Remove-Item ".\RemTestNet.txt"

