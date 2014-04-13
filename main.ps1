## Logging Function
Function Log ($logText){
     $date = Get-Date
     Add-Content -Path .\restore.log -Value "$date    $logText" -Force
}

#Delete the old log file
If(Test-Path ".\restore.log"){del .\restore.log} 

#Load the VMware Snapin if not already loaded
if ( (Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null )
{
Add-PsSnapin VMware.VimAutomation.Core
Log("Added VMware modules because they weren't already loaded")
}

#Load Modules
Import-Module .\Get-VMDiskMap.ps1 -Force
Log("Imported Get-VMDiskMap module")

#Collect credentials
Write-Host -ForegroundColor Green "Enter FQDN of vCenter to connect to: " -NoNewLine 
$VCserver = Read-Host
Log("Specified vCenter is: $VCserver")
Write-Host -ForegroundColor Yellow "You will now be prompted to enter your credentials for connecting to vCenter"
Sleep 3
$VCcreds = Get-Credential $null
Log("Recieved vCenter credentials from user")
Write-Host -ForegroundColor Yellow "You will now be prompted to enter your credentials to connect to domain computers"
Sleep 3
$ADcreds = Get-Credential $null
Log("Recieved AD credentials from user")

#Connect to vCenter Server
Log("Attempting to connect to vCenter: $VCserver")
Connect-VIServer $VCserver -Credential $VCcreds > $NUL
Log("Connected successfully!")

#Get the VMDK file to operate on
Write-Host -ForegroundColor Green "Enter the name of the VM to restore a disk from: "  -NoNewLine 
$SrcVM = Read-Host
Log("User wants to restore a disk from the VM: $SrcVM")
Try
{
    $disks = Get-VMDiskMap $SrcVM $ADcreds -ErrorAction Stop | Select *
}
Catch [System.Runtime.InteropServices.COMException]
{
    $errMsg = "Could not connect for WMI query. Check firewalls/RPC service and try again! Exiting..."
    Write-Host -ForegroundColor Red $errMsg
    Log("$errMsg")
    Log("The specific error was:")
    Log($error[0])
    return
}
Log("The disks on $SrcVM are:")
$disks | Select DiskName,SCSI_Id,DiskFile,DiskSize | %{Log($_)}
[int]$VMDKchoice = 0
while ( $VMDKchoice -lt 1 -or $VMDKchoice -gt $disks.Count){
    $diskno = 0
    Foreach ($disk in $disks){
        $diskno = $diskno + 1
        Write-Host $diskno. $disk.WindowsDisks,"    "$disk.DiskSize GB
    }
Write-Host -ForegroundColor Green "Please enter the menu number of the disk to restore: " -NoNewLine 
[Int]$VMDKchoice = Read-Host }
$SrcDisk = $disks[$VMDKchoice-1].DiskFile
Log("The user wants to restore the VMDK: $SrcDisk")
$SrcDisk