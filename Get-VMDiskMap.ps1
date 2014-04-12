Function Get-VMDiskMap {
    [Cmdletbinding()]
    param([Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)][string]$VM)
    begin {
    }
    process {
        if ($VM) {
            $VmView = Get-View -ViewType VirtualMachine -Filter @{"Name" = $VM}    
            foreach ($VirtualSCSIController in ($VMView.Config.Hardware.Device | where {$_.DeviceInfo.Label -match "SCSI Controller"})) {
                foreach ($VirtualDiskDevice in ($VMView.Config.Hardware.Device | where {$_.ControllerKey -eq $VirtualSCSIController.Key})) {
                    $VirtualDisk = "" | Select VM,SCSIController, DiskName, SCSI_Id, DiskFile,  DiskSize, WindowsDisks
                    $VirtualDisk.VM = $VM
                    $VirtualDisk.SCSIController = $VirtualSCSIController.DeviceInfo.Label
                    $VirtualDisk.DiskName = $VirtualDiskDevice.DeviceInfo.Label
                    $VirtualDisk.SCSI_Id = "$($VirtualSCSIController.BusNumber) : $($VirtualDiskDevice.UnitNumber)"
                    $VirtualDisk.DiskFile = $VirtualDiskDevice.Backing.FileName
                    $VirtualDisk.DiskSize = $VirtualDiskDevice.CapacityInKB * 1KB / 1GB

                    $LogicalDisks = @()
                    # Look up path for this disk using WMI.
                    $thisVirtualDisk = get-wmiobject -class "Win32_DiskDrive" -namespace "root\CIMV2" -computername $VM | where {$_.SCSIBus -eq $VirtualSCSIController.BusNumber -and $_.SCSITargetID -eq $VirtualDiskDevice.UnitNumber}
                    # Look up partition using WMI.
                    $Disk2Part = Get-WmiObject Win32_DiskDriveToDiskPartition -computername $VM | Where {$_.Antecedent -eq $thisVirtualDisk.__Path}
                    foreach ($thisPartition in $Disk2Part) {
                        #Look up logical drives for that partition using WMI.
                        $Part2Log = Get-WmiObject -Class Win32_LogicalDiskToPartition -computername $VM | Where {$_.Antecedent -eq $thisPartition.Dependent}
                        foreach ($thisLogical in $Part2Log) {
                            if ($thisLogical.Dependent -match "[A-Z]:") {
                                $LogicalDisks += $matches[0]
                            }
                        }
                    }

                    $VirtualDisk.WindowsDisks = $LogicalDisks
                    Write-Output $VirtualDisk
                }
            }
        }
    }
    end {
    }
}