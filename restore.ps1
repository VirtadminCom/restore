#Load the VMware Snapin if not already loaded
if ( (Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null )
{
Add-PsSnapin VMware.VimAutomation.Core
}

#Load Modules
Import-Module .\Get-VMDiskMap.ps1

#Collect credentials
Write-Host "Please enter the credentials for connecting to vCenter"
$VCcreds = Get-Credential
Write-Host "Please enter the credentials to connect to domain computers"
$ADcreds = Get-Credential

#Connect to vCenter Server
Connect-VIServer vcenter -Credential $creds > $NUL 

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
