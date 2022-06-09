# Package AAH Installer for nuget
cd E:\installer_22.1.1

gci -path "C:\" -rec -file *.dll | Where-Object {$_.LastWriteTime -lt (Get-Date).AddYears(-20)} | %  { try { $_.LastWriteTime = '01/01/2020 00:00:00' } catch {} }

c:\tools\nuget.exe pack AahInstaller.nuspec


c:\tools\nuget.exe push AahInstaller.22.1.1.1.nupkg -src https://pkgs.dev.azure.com/agltd/_packaging/AAH/nuget/v3/index.json -Timeout 900



## Check for files with bad timestamps
gci -path "E:\installer_22.1.1\AahInstaller" -rec -file *.* | Where-Object {$_.LastWriteTime -lt (Get-Date).AddYears(-10)} | %  { try { write-host $_.Name + " " + $_.LastWriteTime } catch {write-host "error"} }

gci -path "E:\installer_22.1.1\AahInstaller" -rec -file *.* | Where-Object {$_.LastWriteTime -lt (Get-Date).AddYears(-10)} | %  { try { $_.LastWriteTime = '01/01/2020 00:00:00' } catch {write-host "error"} }