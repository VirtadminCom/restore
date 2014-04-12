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

Do {
$vmname = read-host -prompt "Enter the name of the VM to restore files from"
} while ($vmname -eq $null)

$logicaldrives = Get-WmiObject win32_logicaldisk -ComputerName $vmname -Credential administrator | Where-Object {$_.DeviceType -eq '3'} | foreach { $_.DeviceID }

$selectedDrive = $false
Do {
    Write-Host ""
    foreach($d in $logicaldrives)
    {
        
            Write-Host $d
        
    }
    $choice1 = read-host -prompt "Select a drive letter (example C:)"
    foreach($d in $logicaldrives)
    {
        if($d -eq $choice1)
           {
                $selectedDrive = $true
           }
    }
} until ($selectedDrive -eq $true )