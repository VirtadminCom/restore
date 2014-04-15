Function Get-NetAppLunSerial{
#Take VMware's naa indentifier as input
    [Cmdletbinding()]
    param([Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)][string]$naa)
    #Prepare array to contain all separate ASCII characters
    $LunSerialArray=@()
    #Check if the naa has the NetApp prefix of "60a98000" and cut it. 
    If (($NAA.Split(".")[1].Substring(0,8)) -eq "600a0980") {
        #Cut the prefix
        $WWN=($NAA.Split(".")[1]).Substring(8,24)
        # Cut the string in to one byte blocks
        $WWN -split "(\w{2})"|ForEach-Object {
            If ($_ -ne "") {
                $ThisHex=$_
                #Convert Hex block to Decimal Number
                $ThisDec=[Convert]::ToInt16($ThisHex,16)
                #Convert Decimal Number to ASCII Character
                $ThisChar=[CHAR][BYTE]$ThisDec
                $LunSerialArray+=$ThisChar
                }
            }
        }
    #Read the LunSerialArray as a continues string
    $LunSerial=$LunSerialArray -join ''
    #Expose the serial string outside the function
    $LunSerial
}