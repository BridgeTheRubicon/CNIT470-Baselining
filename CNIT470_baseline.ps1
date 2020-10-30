<#
.SYNOPSIS
A baselining script for incident response on Windows machines. This is specifically for CNIT470.
REQUIERMENTS: must be run as an NT authority admin
.Notes
Version:  1.0
Author: Andrew Burmeister
Creation Date:  10/16/20
Purpose/Change: Initial script development
#>
# initialize functions
function makeNewFile($fName)
  {
    Get-Child -Path C:\Temp\
    New-Item -Path * -Name $fName+":"+(Get-Date -Format o)+.txt -ItemType File
  }
# create the file
$out = makeNewFile((hostname)) | Out-File -FilePath .\$out
#
# get the baseline data
$a = systeminfo
$b = wmic.exe product get name, version
$c = Get-Process
$d = Get-CimInstance Win32_StartupCommand | Select-Object Name, command, Location, User |
  Format-List
$e = Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 4 -MaxSamples 5
$f = systeminfo | find "Available Physical Memory"
$g = systeminfo | find "Virtual Memory: Available"
$h = Get-Volume
$i = Get-Counter -Counter (Get-Counter -ListSet ipv4).paths -SampleInterval 10 -MaxSamples 5
Set-Location -Path C:\Windows\System32
$j = ls | Get-FileHash -Algorithm SHA384 | Format-List
Set-Location -Path C:\Windows\System32\drivers
$k = ls | Get-FileHash -Algorithm SHA384 | Format-List
Set-Location -Path C:\Windows\System32\drivers\etc
$l = ls | Get-FileHash -Algorithm SHA384 | Format-List
#
#write to the File
Write-Output "Basic system information:"
Write-Output $a | Out-File -FilePath .\$out
Write-Output "`nInstalled Programs:"
Write-Output $b | Out-File -FilePath .\$out
Write-Output "`nRunning Services:"
Write-Output $c | Out-File -FilePath .\$out
Write-Output "`nStartup Programs:"
Write-Output $d | Out-File -FilePath .\$out
Write-Output "`nProcessor Utilization:"
Write-Output $e | Out-File -FilePath .\$out
Write-Output "`nMemory Utilization:"
Write-Output $f | Out-File -FilePath .\$out
Write-Output $g | Out-File -FilePath .\$out
Write-Output "`nStorage Utilization:"
Write-Output $h | Out-File -FilePath .\$out
Write-Output "`nNetwork Utilization:"
Write-Output $i | Out-File -FilePath .\$out
Write-Output "`nFile Integrity:"
Write-Output $j | Out-File -FilePath .\$out
Write-Output $k | Out-File -FilePath .\$out
Write-Output $l | Out-File -FilePath .\$out
#
# create the FtpWebRequest and configure the connection
$ftp = [System.Net.FtpWebRequest]::Create("ftp://10.51.32.80/home/blueteam/baseline/$out")
$ftp = [System.Net.FtpWebRequest]$ftp
$ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
$ftp.Credentials = new-object System.Net.NetworkCredential("blueteam","HandsNoSwiping!")
$ftp.UseBinary = $true
$ftp.UsePassive = $true
# read in the file to upload as a byte array
$content = [System.IO.File]::ReadAllBytes("$out")
$ftp.ContentLength = $content.Length
# get the request stream, and write the compiled content into it
try
{
  $rs = $ftp.GetRequestStream()
  $rs.Write($content, 0, $content.Length)
}
catch [System.Net.WebException]
{
  "Unable to upload the file."
}
# close the connections and help reset the state
$rs.Close()
$rs.Dispose()
