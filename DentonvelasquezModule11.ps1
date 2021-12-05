Function Test-Cloudflare {
#Enables script as Function

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
Version 1.1 - Added for each loop and a switch construct
            - Enabled cmdlet binding and created function
Version 1.2 - Added try/catch error handling
            - Employed accelerators
            - improved comments

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
    [Parameter(mandatory=$true, ValueFromPipeline=$True)]
    [Alias('CN','Name')][String]$computername,
    [Parameter(Mandatory=$false)][string]$path = "$env:USERPROFILE",
    [ValidateSet('Host','Text','CSV')][string]$output = "Host"
    

)
#Sets Paramters and enables ByValue input

foreach ($computer in $computername ) {
    Try {
        $remotesession = New-PsSession -computername $computername -ea Stop
    Enter-PsSession $remotesession
    #enters session unless invalid computer
    } 
    Catch {
        Write-Host "Remote connection to $computer failed." -ForegroundColor red
        Continue
    } #error handling
    
    $datetime = Get-date
    $TestCF = test-netconnection -computername 'one.one.one.one' -informationlevel Detailed
    $obj = [pscustomobject]@{
        'Computername' = $computername
        'PingSuccess' = $TestCF.Pingsucceded
        'NameResolve' = $TestCF.NameResolutionSucceded
        'ResolvedAddresses' = $TestCF.ResolvedAddresses
    }#splatting params

exit-psSession $remotesession
}



switch ($output) {
    'csv' {
        Write-Verbose "Generating Results"
        $obj | Export-CSV .\TestResults.csv }
    'text'{
            Write-Verbose "Generating Results"
            $obj | out-file '.\TestResults.txt'
            Add-Content .\RemTestNet.txt -Value "Computer Name: $Computername"
            Add-Content .\RemTestNet.txt -Value "Date & time: $datetime"
            Add-Content .\RemTestNet.txt -Value (Get-Content -path '.\TestResults.txt')
            notepad.exe .\RemTestNet.txt
            Remove-Item '.\TestResults.txt'}
    'host' {
        Write-Verbose "Generating Results"

        get-content .\RemTestNet.txt}
    default { Write-Host "$output is an invalid output type."} 
   }#EndsSwitch
 

Write-Verbose "Finished Ping Test."
Start-sleep -s 5
Remove-Item ".\RemTestNet.txt"

} #EndsFunction