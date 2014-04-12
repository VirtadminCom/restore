#Load the VMware Snapin if not already loaded
if ( (Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null )
{
Add-PsSnapin VMware.VimAutomation.Core
}

#Load Modules
Import-Module .\Get-VMDiskMap.ps1

#Collect credentials
$VCserver = Read-Host -prompt "Enter FQDN of vCenter to connect to" 
Write-Host -ForegroundColor Green "You will now be prompted to enter your credentials for connecting to vCenter"
Sleep 3
$VCcreds = Get-Credential $null
Write-Host -ForegroundColor Green "You will now be prompted to enter your credentials to connect to domain computers"
Sleep 3
$ADcreds = Get-Credential $null

#Connect to vCenter Server
Connect-VIServer $VCserver -Credential $VCcreds > $NUL 