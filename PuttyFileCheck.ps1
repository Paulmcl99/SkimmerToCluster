# Stop any existing Putty sessions and delete log files
#Stop-Process -Name "putty"
#Remove-Item "C:\Users\paul\Desktop\putty.Log"


#infinite loop
for(;;)
{
#Start Putty and connect to Skimmer
Start-Process -filepath "C:\Program Files\PuTTY\putty.exe" -WindowStyle Minimized -ArgumentList "-load skimmer"

# Start Timer
$seconds = 30
1..$seconds | ForEach-Object {
    Write-Progress -Activity "Sleeping..." -Status "$_ seconds elapsed" -PercentComplete ($_/$seconds*100)
    Start-Sleep -Seconds 1
}


#Set Variables
$FilePathPutty = "C:\Users\paul\Desktop\putty.Log"
$FileContentsPutty = Get-Content -Path $FilePathPutty

$FilePathTopDX = "C:\Users\paul\Desktop\TopDX.txt"
$FileContentsTopDX = Get-Content -Path $FilePathTopDX

# Skip first 2 lines of putty log file
$iPutty = 2



#Loop through each line in the Putty file
ForEach ($Line in $FileContentsPutty) {
  	$intro1, $intro2, $skimmer, $freq, $dx, $snr, $wpm, $wpm2, $type, $cq, $utc = $FileContentsPutty[$iPutty] -split '\s+'
       
    #Reset band variable to None
    $Band = "None"
    
    #Check freq and band
        $freqchk = [decimal]$freq
       
        if ($freqchk -gt 1800 -and $freqchk -lt 1850) {
       
            $Band = "160"
        }
       
        if ($freqchk -gt 3500 -and $freqchk -lt 3574) {
       
            $Band = "80"
        }
       
        if ($freqchk -gt 7000 -and $freqchk -lt 7074) {
       
            $Band = "40"
        }
         
        if ($freqchk -gt 10100 -and $freqchk -lt 10140) {
       
            $Band = "30"
        }
       
        if ($freqchk -gt 14000 -and $freqchk -lt 14074) {
       
            $Band = "20"
        }
       
        if ($freqchk -gt 18068 -and $freqchk -lt 18100) {
       
            $Band = "17"
        }  
       
        if ($freqchk -gt 21000 -and $freqchk -lt 21074) {
       
            $Band = "15"
        }
       
        if ($freqchk -gt 24890 -and $freqchk -lt 24915) {
       
            $Band = "12"
        }
       
        if ($freqchk -gt 28000 -and $freqchk -lt 28380) {
       
            $Band = "10"
        }     

       # if ($Band = "None") {
        #    Continue
      #      }

# Compare line with Top DX file entres
        ForEach ($TopDX in $FileContentsTopDX) {

            $TopDX, $TopDXBand = $TopDX -split ','

            if ($dx -like $TopDX -and ($TopDXBand -eq $Band -or $TopDXBand -eq "any"))  {
      
                #Telnet to cluster
                $Socket = New-Object System.Net.Sockets.TcpClient("gb7mbc.spoo.org",8000)
                If ($Socket)
                {  $Stream = $Socket.GetStream()
                   $Writer = New-Object System.IO.StreamWriter($Stream)
                   $Buffer = New-Object System.Byte[] 1024
                   $Encoding = New-Object System.Text.AsciiEncoding

                # cluster login and wait
                 $Writer.WriteLine("mm0zbh")
                 Start-Sleep -Seconds 1
 
                # send spot and wait
                 $writer.WriteLine("DX " + $freq + " " + $DX + " CW")
                 Start-Sleep -Seconds 1

                #disconnect
                 $writer.WriteLine("bye")
                 $Writer.Flush()
 
                }
        
            $dx + " spotted at " + $utc + " on frequency " + $freq + " " + $Band
            #Add-Content "C:\Users\paul\Desktop\SpotsUploaded.txt" $dx + " spotted at " + $utc + " on frequency " + $freq 
       		}
   		else{
   		# Do nothing
		} 
		}
	
	#increase counter by one for next line in Putty text file	
	$iPutty++ 
}
#Stop Putty and delete Putty.log file
Stop-Process -Name "putty"

}
