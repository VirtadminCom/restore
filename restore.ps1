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