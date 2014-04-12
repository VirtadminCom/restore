#Load the VMware Snapin if not already loaded
if ( (Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null )
{
Add-PsSnapin VMware.VimAutomation.Core
}

#Load Modules
Import-Module .\Get-VMDiskMap.ps1

#Collect credentials
Write-Host -ForegroundColor Green "Enter FQDN of vCenter to connect to: " -NoNewLine 
$VCserver = Read-Host 
Write-Host -ForegroundColor Yellow "You will now be prompted to enter your credentials for connecting to vCenter"
Sleep 3
$VCcreds = Get-Credential $null
Write-Host -ForegroundColor Yellow "You will now be prompted to enter your credentials to connect to domain computers"
Sleep 3
$ADcreds = Get-Credential $null

#Connect to vCenter Server
Connect-VIServer $VCserver -Credential $VCcreds > $NUL

#Get the VMDK file to operate on
Write-Host -ForegroundColor Green "Enter the name of the VM to restore a disk from: "  -NoNewLine 
$SrcVM = Read-Host 
$disks = Get-VMDiskMap $SrcVM $ADcreds | Select DiskFile,DiskSize,WindowsDisks
[int]$VMDKchoice = 0
while ( $VMDKchoice -lt 1 -or $VMDKchoice -gt $disks.Count){
    $diskno = 0
    Foreach ($disk in $disks){
        $diskno = $diskno + 1
        Write-Host $diskno. $disk.WindowsDisks
    }
Write-Host -ForegroundColor Green "Please enter the menu number of the disk to restore: " -NoNewLine 
[Int]$VMDKchoice = Read-Host }
$SrcDisk = $disks[$VMDKchoice-1].DiskFile
$SrcDisk
# Switch( $VMDKchoice ){
  # 1{#run an action or call a function here }
  # 2{<run an action or call a function here #>}
  # 3{<#run an action or call a function here #>}
# default{<#run a default action or call a function here #>}