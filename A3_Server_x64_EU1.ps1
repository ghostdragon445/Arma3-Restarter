# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# File:			A3_Restarter.ps1
# Version:		V3.0
# Author:		Kamaradski 2015 
# Contributers:	S0zi0p4th 2017
#               Ghostdragon 2018
# Arma3 Server (re)starter by Ahoyworld.net
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Write-Host ""
Write-Host -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Write-Host "             //" -ForegroundColor Red -NoNewline;
Write-Host "AhoyWorld.net" -NoNewline;
Write-Host " - Arma3 restarter by Kamaradski"
Write-Host -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Write-Host ""
Write-Host ""
Write-Host "Initizing..."

# Pharsing config-file:
$p = $MyInvocation.MyCommand.Definition; $p = $p.Substring(0,$p.Length-4); $r = $p + ".cfg"
$q = $MyInvocation.MyCommand.Definition
Get-Content "$r" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,' = '); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

#displayname:
$Script:ServerName=$h.Get_Item("ServerName")

#Synchronizing .bikeys folder
$Script:EnableKeySync=$h.Get_Item("EnableKeySync")
$Script:MasterPathKey=$h.Get_Item("MasterPathKey")

#Synchronizing MPMissions folder
$Script:EnableMissionSync=$h.Get_Item("EnableMissionSync")
$Script:MasterPathMissions=$h.Get_Item("MasterPathMissions")

#Synchronizing BEServer_x64.cfg
$Script:EnableBeSync=$h.Get_Item("EnableBeSync")
$Script:MasterPathBE=$h.Get_Item("MasterPathBE")

#Archive Server logs
$Script:EnableLogArchive=$h.Get_Item("EnableLogArchive")
$Script:PathCompressor=$h.Get_Item("PathCompressor")
$Script:VersionsToKeep=$h.Get_Item("VersionsToKeep")

#Archive BEC logs
$Script:EnableBECLogArchive=$h.Get_Item("EnableBECLogArchive")
$Script:VersionsToKeepBEC=$h.Get_Item("VersionsToKeepBEC")

#Backup options
$Script:EnableBackup=$h.Get_Item("EnableBackup")
$Script:PathBackupDestination=$h.Get_Item("PathBackupDestination")

#Steam Updater Options
$Script:EnableUpdateOnRestart=$h.Get_Item("EnableUpdateOnRestart")
$Script:SteamLogin=$h.Get_Item("SteamLogin")
$Script:SteamPassword=$h.Get_Item("SteamPassword")
$Script:PathSteamCMD=$h.Get_Item("PathSteamCMD")
$Script:SteamAppNumber=$h.Get_Item("SteamAppNumber")
$Script:UsePerformanceBranch=$h.Get_Item("UsePerformanceBranch")

#use TADST profiles
$Script:EnableTADSTProfileSync=$h.Get_Item("EnableTADSTProfileSync")
$Script:TADSTProfileName=$h.Get_Item("TADSTProfileName")

#Arma3server Startup parameters
$Script:AssignCPUCore=$h.Get_Item("AssignCPUCore")
$Script:ServerCPUAffinity=$h.Get_Item("ServerCPUAffinity")
$Script:ServerPath=$h.Get_Item("ServerPath")
$Script:ServerPort=$h.Get_Item("ServerPort")
$Script:RConPort=$h.Get_Item("RConPort")
$Script:ServerParameters=$h.Get_Item("ServerParameters")
$Script:ServerMods=$h.Get_Item("ServerMods")

#BEC
$Script:BECPath=$h.Get_Item("BECPath")
$Script:BECExe=$h.Get_Item("BECExe")
$Script:BECServerConfig=$h.Get_Item("BECServerConfig")


# Setting variables:
$p = $MyInvocation.MyCommand.Definition; $p = $p.Substring(0,$p.Length-4); $p = $p + ".log"
$Script:PathMasterTADSTConfig = "$ServerPath\TADST\$TADSTProfileName"
$Script:PathActiveBattlEye = "$ServerPath\BattlEye"
$Script:IntervalShort = 1
$Script:IntervalMedium = 5
$Script:IntervalLong = 20
$Script:PathRestarterLogFile = "$p"
$Script:PathLogArchive = "$($ServerPath)\Log-Archive"
$Script:FullPathArmaServerExe = "$($ServerPath)\arma3server_x64.exe"
$Script:FullPathBECExe = "$($BECPath)\$($BECExe)"
$Script:FullPathBECConfig = "$($BECPath)\Config\$($BECServerConfig)"
$t = $BECServerConfig.Substring(0,$BECServerConfig.Length-4)
$Script:FullPathBECLogFiles = "$($BECPath)\Log\$($t)"
$Script:FullPathActiveConfig = "$($PathActiveBattlEye)\TADST_config.cfg"
$Script:FullPathActiveBattlEyeConfig = "$($PathActiveBattlEye)\BEServer_x64.cfg"
$Script:FullPathBanFile = "$($PathActiveBattlEye)\bans.txt"
$Script:FullPathActiveBasicConfig = "$($PathActiveBattlEye)\TADST_basic.cfg"
$Script:PathActiveMPMissions = "$($ServerPath)\MPMissions"
$Script:PathActiveKeys = "$($ServerPath)\Keys"
$Script:FullPathTempLog = "$($ServerPath)\temp.log"
$Script:FullPathMasterBEconfig = "$($MasterPathBE)\BEServer_x64.cfg"
$Script:gamer = 'happy'

if ($EnableTADSTProfileSync -ne "YES") {
	$Script:PathActiveBattlEye = $h.Get_Item("ArmaParameterProfile")
	$Script:TADSTProfileName=$h.Get_Item("ArmaParameterName")
	$Script:FullPathActiveConfig = $h.Get_Item("ArmaParameterConfig")
	$Script:FullPathActiveBasicConfig = $h.Get_Item("ArmaParameterBasicConfig")
}

$host.ui.RawUI.WindowTitle = "Restarter: $ServerName - port: $ServerPort"




# Update Arma server via SteamCMD
Function RunSteamUpdate {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Checking Steam for updates... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Checking Steam for updates..."
	if ($UsePerformanceBranch -eq "YES") {
		Start-Process $PathSteamCMD\steamcmd.exe "+login $SteamLogin $SteamPassword +force_install_dir $ServerPath +app_update $SteamAppNumber -beta profiling -betapassword CautionSpecialProfilingAndTestingBranchArma3 -validate +quit" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
	}
	Else {
		Start-Process $PathSteamCMD\steamcmd.exe "+login $SteamLogin $SteamPassword +force_install_dir $ServerPath +app_update $SteamAppNumber -beta -validate +quit" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
	}
	add-content $PathRestarterLogFile -value (get-content $FullPathTempLog)
	del $FullPathTempLog
}




# Copy TADST profiles to BattlEye folder
Function RUNCopyTADSTProfile {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Copying TADST Profile... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Copying TADST Profile..."
	Start-Process robocopy "$PathMasterTADSTConfig $PathActiveBattlEye /mir /xf arma3server_x64*.mdmp arma3server_x64*.bidmp Compressor*.bat *archive.zip arma3server_x64*.rpt AntiHackLog*.log bans.txt BEServer.dll BEServer_x64.dll beserver*.cfg logfile_console*.log" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
	del $FullPathTempLog
	Start-Sleep -s $IntervalShort
}




# Copy Multiplayer missions to Server MPMissions folder
Function RUNCopyMissions {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Copying MPMissions... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Copying MPMissions..."
	Start-Process robocopy.exe "$MasterPathMissions $PathActiveMPMissions /mir" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
	del $FullPathTempLog
	Start-Sleep -s $IntervalShort
}




# Copy BiKeys to Server BiKey folder
Function RUNCopyKeys {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Copying Keys... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Copying Keys..."
	Start-Process robocopy "$MasterPathKey $PathActiveKeys /mir" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
	del $FullPathTempLog
	Start-Sleep -s $IntervalShort
 }




# Copy BEServer.cfg to Server BattlEye folder
 Function RUNCopyBEConfig { 
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Copying BE-config... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Copying BE-config..."
	Copy-Item $FullPathMasterBEconfig -Destination $PathActiveBattlEye
	Start-Sleep -s $IntervalShort
}




# Starting the server
Function RUNStartARMAServer {
	$Script:BECRestartCounter=1
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Starting: $ServerName on port: $ServerPort "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Starting: $ServerName on port: $ServerPort"
	
	$Script:ArmaServerID = Start-Process arma3server_x64.exe "$ServerParameters -port=$ServerPort -profiles=$PathActiveBattlEye -name=$TADSTProfileName -bepath=$PathActiveBattlEye -config=$FullPathActiveConfig -cfg=$FullPathActiveBasicConfig -mod=$ServerMods" -WorkingDirectory $ServerPath -passthru
	Start-Sleep -s $IntervalMedium
	
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  $ServerName started with PID: $($ArmaServerID.Id) "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  $ServerName started with PID: $($ArmaServerID.Id)" -ForegroundColor "Green"
	Start-Sleep -s $IntervalLong
	
	if ($AssignCPUCore -eq "YES") {
		$SetAffinity = Get-Process arma3server_x64 -ErrorAction SilentlyContinue | Where-Object {$_.Path -like "$ServerPath*"}
		$SetAffinity.ProcessorAffinity=[int]$ServerCPUAffinity
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  PID: $($ArmaServerID.Id) assigned to CPU-core(s): $ServerCPUAffinity"; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  PID: $($ArmaServerID.Id) assigned to CPU-core(s): $ServerCPUAffinity"
		Write-Host ''
	}
}




# Starting BEC
Function RUNStartBEC {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Starting: $BECExe with: $BECServerConfig "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Starting: $BECExe with: $BECServerConfig"
	
	$Script:BECID = Start-Process $BECExe "-f $BECServerConfig --dsc" -WorkingDirectory $BECPath -passthru
	Start-Sleep -s $IntervalMedium
	
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  $BECExe started with PID: $($BECID.Id) "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  $BECExe started with PID: $($BECID.Id)" -ForegroundColor "Green"
	Start-Sleep -s $IntervalMedium
	
	if ($AssignCPUCore -eq "YES") {
		$SetAffinity = Get-Process -Id $($BECID.Id) -ErrorAction SilentlyContinue
		$SetAffinity.ProcessorAffinity=[int]$ServerCPUAffinity
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  BEC PID: $($BECID.Id) assigned to CPU-core(s): $ServerCPUAffinity"; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  BEC PID: $($BECID.Id) assigned to CPU-core(s): $ServerCPUAffinity"
		Write-Host ''
	}
}




# Check if BEC is still running
Function IsBECStillRunning {
	$BECShortName = $BECExe.Substring(0,$BECExe.Length-4)
	$Script:CheckBECRunning = Get-Process $BECShortName -ErrorAction SilentlyContinue | Where-Object {$_.Id -eq $($BECID.Id)}
}




# Check if Server is still running
Function IsServerRunning {
	$Script:CheckArmaServerRunning  = Get-Process arma3server_x64 -ErrorAction SilentlyContinue | Where-Object {$_.Id -eq $($ArmaServerID.Id) } | Where-Object {$_.Responding -eq $true}
}




# Kill BEC process
Function KILLBEC {
	$BECShortName = $BECExe.Substring(0,$BECExe.Length-4)
	$Script:CheckBECRunning = Get-Process $BECShortName -ErrorAction SilentlyContinue | Where-Object {$_.Id -eq $($BECID.Id) }
	if ($CheckBECRunning) {
		Stop-Process $($BECID.Id)
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  APP:$BECExe PID:$($BECID.Id) killed "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  APP:$BECExe PID:$($BECID.Id) killed"
	}
}




# detect Stale BE-config files & Clean them up
Function CleanBEConfig {
	$Script:BESpareConfig = Get-ChildItem $PathActiveBattlEye\*.* -filter BEServer_x64.cfg
	if (!$BESpareConfig) {
		$BEStaleConfig = Get-ChildItem $PathActiveBattlEye\*.* -filter BEServer_x64_active*.cfg | sort LastWriteTime | select -last 1
		if (!$BEStaleConfig) {
			if ($EnableBeSync -eq "YES") {
				RUNCopyBEConfig
			} Else {
				$a=(Get-Date).ToUniversalTime()
				$b = "$a  -  FATAL: No BEServer_x64.cfg or Stale-config found. Stale:$BEStaleConfig & Spare:$BESpareConfig   "; Add-Content $PathRestarterLogFile $b
				$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
				Write-Host $a.ToShortTimeString() " -  FATAL: No BEServer_x64.cfg or Stale-config found" -BackgroundColor "Red" -ForegroundColor "white"
				Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
				Start-Sleep -s $IntervalLong
			}
		}
		Rename-Item $BEStaleConfig $FullPathActiveBattlEyeConfig
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Renaming $BEStaleConfig --> $FullPathActiveBattlEyeConfig "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  Renaming $BEStaleConfig " -ForegroundColor "Yellow"
	}
	$BEStaleConfig = Get-ChildItem $PathActiveBattlEye\*.* -filter BEServer_x64_active*.cfg
	if ($BEStaleConfig) {
		Foreach ($i in $BEStaleConfig) {
			Remove-Item $i
			$a=(Get-Date).ToUniversalTime()
			$b = "$a  -  Deleting stale $BEStaleConfig "; Add-Content $PathRestarterLogFile $b
			Write-Host $a.ToShortTimeString() " -  Deleting stale $BEStaleConfig " -ForegroundColor "Yellow"
		}
	}
	Clear-variable BEStaleConfig
}




# Kill Arma Server process
Function KILLSERVER {
	$CheckArmaServerRunning = Get-Process arma3server_x64 -ErrorAction SilentlyContinue | Where-Object {$_.Path -like "$ServerPath*"}
	if ($CheckArmaServerRunning) {
		Foreach ($i in $CheckArmaServerRunning) {
			Stop-Process $($i.Id)
			$a=(Get-Date).ToUniversalTime()
			Write-Host $a.ToShortTimeString() " -  APP:arma3server_x64.exe PID:$($i.Id) killed"
			$b = "$a  -  APP:arma3server_x64.exe PID:$($i.Id) killed "; Add-Content $PathRestarterLogFile $b
		}
	}
}




# Start-up sequence
Function StartSequence {
	if ($EnableBackup  -eq "YES") {
		RUNServerBackup
	}
	if ($EnableUpdateOnRestart  -eq "YES") {
		RunSteamUpdate
	}
	if ($EnableLogArchive -eq "YES") {
		RUNLogArchive
	}
	if ($EnableBECLogArchive -eq "YES") {
		RUNBECLogArchive
	}
	if ($EnableTADSTProfileSync -eq "YES") {
		RUNCopyTADSTProfile
	}
	if ($EnableKeySync -eq "YES") {
		RUNCopyKeys
	}
	if ($EnableMissionSync -eq "YES") {
		RUNCopyMissions
	}
	if ($EnableBeSync -eq "YES") {
		RUNCopyBEConfig
	}
	Write-Host ''
	$b = ''; Add-Content $PathRestarterLogFile $b
	RUNStartARMAServer
	RUNStartBEC
	Start-Sleep -s $IntervalLong
	Start-Sleep -s $IntervalLong
}




# Archive all BEC log-files
Function RUNBECLogArchive {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Archiving old BEC logfiles... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Archiving old BEC logfiles... (Please be patient) "
	
	# BEC BE-log
	$q = Get-ChildItem $FullPathBECLogFiles\BeLog\Be_*.log | measure
	if ( $($q.Count) -gt $VersionsToKeepBEC) {
		$q = Get-ChildItem $FullPathBECLogFiles\BeLog\Be_*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeepBEC)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $FullPathBECLogFiles\BeLog\BeLog.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $FullPathBECLogFiles\BeLog\BeLog.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
	
	

	# BEC  Chat_Command log
	$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Command_*.log | measure
	if ( $($q.Count) -gt $VersionsToKeepBEC) {
		$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Command_*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeepBEC)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $FullPathBECLogFiles\Chat\Chat_Command.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $FullPathBECLogFiles\Chat\Chat_Command.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
	
	
	# BEC  Chat_Direct log
	$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Direct_*.log | measure
	if ( $($q.Count) -gt $VersionsToKeepBEC) {
		$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Direct_*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeepBEC)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $FullPathBECLogFiles\Chat\Chat_Direct.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $FullPathBECLogFiles\Chat\Chat_Direct.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""


	# BEC  Chat_Global log
	$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Global_*.log | measure
	if ( $($q.Count) -gt $VersionsToKeepBEC) {
		$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Global_*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeepBEC)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $FullPathBECLogFiles\Chat\Chat_Global.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $FullPathBECLogFiles\Chat\Chat_Global.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
	
	
	# BEC  Chat_Group log
	$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Group_*.log | measure
	if ( $($q.Count) -gt $VersionsToKeepBEC) {
		$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Group_*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeepBEC)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $FullPathBECLogFiles\Chat\Chat_Group.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $FullPathBECLogFiles\Chat\Chat_Group.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""


	# BEC  Chat_Lobby log
	$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Lobby_*.log | measure
	if ( $($q.Count) -gt $VersionsToKeepBEC) {
		$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Lobby_*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeepBEC)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $FullPathBECLogFiles\Chat\Chat_Lobby.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $FullPathBECLogFiles\Chat\Chat_Lobby.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
	

	# BEC  Chat_Side log
	$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Side_*.log | measure
	if ( $($q.Count) -gt $VersionsToKeepBEC) {
		$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Side_*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeepBEC)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $FullPathBECLogFiles\Chat\Chat_Side.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $FullPathBECLogFiles\Chat\Chat_Side.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
	
	
	# BEC  Chat_Vehicle log
	$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Vehicle_*.log | measure
	if ( $($q.Count) -gt $VersionsToKeepBEC) {
		$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_Vehicle_*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeepBEC)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $FullPathBECLogFiles\Chat\Chat_Vehicle.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $FullPathBECLogFiles\Chat\Chat_Vehicle.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
	
	
	
	
	# BEC  Chat log
	$q = Get-ChildItem $FullPathBECLogFiles\Chat\*.* | Where-Object {$_.Name -match "Chat_[^_]*.log"} | measure
	if ( $($q.Count) -gt $VersionsToKeepBEC) {
		$q = Get-ChildItem $FullPathBECLogFiles\Chat\Chat_*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeepBEC)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $FullPathBECLogFiles\Chat\Chat.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $FullPathBECLogFiles\Chat\Chat.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
	
	
	
	
	# BEC BecError log
	$q = Get-ChildItem $FullPathBECLogFiles\Error\BecError_*.log | measure
	if ( $($q.Count) -gt $VersionsToKeepBEC ) {
		$q = Get-ChildItem $FullPathBECLogFiles\Error\BecError_*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeepBEC)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $FullPathBECLogFiles\Error\BecError.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $FullPathBECLogFiles\Error\BecError.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
}




# Archive and move the logfiles
Function RUNLogArchive {

	# Sanitycheck, see if log-archive folder exist, or create it
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Archiving old logfiles... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Archiving old logfiles... (Please be patient) "
	if (Test-Path $PathLogArchive) {
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Log-Archive folder found: $PathLogArchive "; Add-Content $PathRestarterLogFile $b
		# Write-Host $a.ToShortTimeString() " -  Log-Archive folder found: $PathLogArchive "
	}Else{
		New-Item $PathLogArchive -type directory | Out-Null
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Log-Archive folder created: $PathLogArchive "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  Log-Archive folder created: $PathLogArchive" -ForegroundColor "Yellow"
	}
	
	# mpStatistics*.log
	$q = Get-ChildItem $ServerPath\*.* -filter mpStatistics*.log | measure
	if ( $($q.Count) -gt $VersionsToKeep) {
		$q = Get-ChildItem $ServerPath\*.* -filter mpStatistics*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeep)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $PathLogArchive\mpStatistics.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $PathLogArchive\mpStatistics.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
	
	# arma3server_x64*.bidmp
	$q = Get-ChildItem $PathActiveBattlEye\*.* -filter arma3server_x64*.bidmp | measure
	if ( $($q.Count) -gt $VersionsToKeep) {
		$q = Get-ChildItem $PathActiveBattlEye\*.* -filter arma3server_x64*.bidmp | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeep)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $PathLogArchive\bidmp.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $PathLogArchive\bidmp.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
	
	# arma3server_x64*.rpt
	$q = Get-ChildItem $PathActiveBattlEye\*.* -filter arma3server_x64*.rpt | measure
	if ( $($q.Count) -gt $VersionsToKeep) {
		$q = Get-ChildItem $PathActiveBattlEye\*.* -filter arma3server_x64*.rpt | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeep)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $PathLogArchive\rpt.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $PathLogArchive\rpt.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
	
	# logfile_console*.log
	$q = Get-ChildItem $PathActiveBattlEye\*.* -filter logfile_console*.log | measure
	if ( $($q.Count) -gt $VersionsToKeep) {
		$q = Get-ChildItem $PathActiveBattlEye\*.* -filter logfile_console*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeep)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $PathLogArchive\logfile_console.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $PathLogArchive\logfile_console.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""
	
	
	# arma3server_x64*.mdmp
	$q = Get-ChildItem $PathActiveBattlEye\*.* -filter arma3server_x64*.mdmp | measure
	if ( $($q.Count) -gt $VersionsToKeep) {
		$q = Get-ChildItem $PathActiveBattlEye\*.* -filter arma3server_x64*.mdmp | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeep)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $PathLogArchive\mdmp.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $PathLogArchive\mdmp.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""

	# AntiHackLog*.log
	$q = Get-ChildItem $PathActiveBattlEye\*.* -filter AntiHackLog*.log | measure
	if ( $($q.Count) -gt $VersionsToKeep) {
		$q = Get-ChildItem $PathActiveBattlEye\*.* -filter AntiHackLog*.log | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeep)
		Foreach ($i in $q) {
			$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
		}
		Start-Process $PathCompressor "a -tzip -mx=9 $PathLogArchive\AntiHackLog.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		del $FullPathTempLog
		Foreach ($i in $q) {
			del $i
		}
	}
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  New files added to $PathLogArchive\AntiHackLog.zip "; Add-Content $PathRestarterLogFile $b
	Foreach ($i in $q) {
		$b = "                $i "; Add-Content $PathRestarterLogFile $b
	}
	$ZipMeNow = ""

	# connection_log*.txt
	if (Test-Path $ServerPath\logs) {
		$q = Get-ChildItem $ServerPath\logs\*.* -filter connection_log*.txt | measure
		if ( $($q.Count) -gt $VersionsToKeep) {
			$q = Get-ChildItem $ServerPath\logs\*.* -filter connection_log*.txt | sort LastWriteTime | select -First $($($q.Count)-$VersionsToKeep)
			Foreach ($i in $q) {
				$ZipMeNow = $ZipMeNow + ' "' + $i + '"'
			}
			Start-Process $PathCompressor "a -tzip -mx=9 $PathLogArchive\connection_log.zip $ZipMeNow" -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
			del $FullPathTempLog
			Foreach ($i in $q) {
				del $i
			}
		}
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  New files added to $PathLogArchive\connection_log.zip "; Add-Content $PathRestarterLogFile $b
		Foreach ($i in $q) {
			$b = "                $i "; Add-Content $PathRestarterLogFile $b
		}
		$ZipMeNow = ""
	}
}




# Make a Backup of the config for this server (and BEC), and it's log-history
Function RUNServerBackup {

	# Sanitychecks and folder creation
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Backing up Server configuration... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Backing up Server configuration...  "
	if (Test-Path $PathBackupDestination\$ServerName ) {
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Previous Backup found: $PathBackupDestination\$ServerName "; Add-Content $PathRestarterLogFile $b
	}Else{
		New-Item $PathBackupDestination\$ServerName -type directory | Out-Null
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Backup folder created: $PathBackupDestination\$ServerName "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  Backup folder created: $PathBackupDestination\$ServerName " -ForegroundColor "Yellow"
	}
	
	if (!(Test-Path $PathBackupDestination\$ServerName\BattlEye)) {
		New-Item $PathBackupDestination\$ServerName\BattlEye -type directory | Out-Null
	}
	
	If ($EnableLogArchive -eq "YES") {
		if (!(Test-Path $PathBackupDestination\$ServerName\Log-Archive)) {
			New-Item $PathBackupDestination\$ServerName\Log-Archive -type directory | Out-Null
		}
		Start-Process robocopy "$PathLogArchive $PathBackupDestination\$ServerName\Log-Archive /mir " -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
	}
	
	If ($EnableTADSTProfileSync -eq "YES") {
		if (!(Test-Path $PathBackupDestination\$ServerName\TADST)) {
			New-Item $PathBackupDestination\$ServerName\TADST -type directory | Out-Null
		}
	}
	
	if (!(Test-Path $PathBackupDestination\$ServerName\Keys)) {
		New-Item $PathBackupDestination\$ServerName\Keys -type directory | Out-Null
	}
	
	if (!(Test-Path $PathBackupDestination\$ServerName\MPMissions)) {
		New-Item $PathBackupDestination\$ServerName\MPMissions -type directory | Out-Null
	}
	
	# Backup server config
	Start-Process robocopy "$PathActiveBattlEye $PathBackupDestination\$ServerName\BattlEye /mir " -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
	Start-Process robocopy "$ServerPath\Keys $PathBackupDestination\$ServerName\Keys /mir " -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
	Start-Process robocopy "$ServerPath\MPMissions $PathBackupDestination\$ServerName\MPMissions /mir " -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
	Copy-Item $ServerPath\*.bat $PathBackupDestination\$ServerName
	Copy-Item $ServerPath\*.log $PathBackupDestination\$ServerName
	Copy-Item $ServerPath\*.config $PathBackupDestination\$ServerName
	
	
	#Backup BEC
	if (!(Test-Path $PathBackupDestination\$ServerName\BEC)) {
		New-Item $PathBackupDestination\$ServerName\BEC -type directory | Out-Null
	}
	if (!(Test-Path $PathBackupDestination\$ServerName\BEC\Config)) {
		New-Item $PathBackupDestination\$ServerName\BEC\Config -type directory | Out-Null
	}
	if (!(Test-Path $PathBackupDestination\$ServerName\BEC\Log)) {
		New-Item $PathBackupDestination\$ServerName\BEC\Log -type directory | Out-Null
	}
	if (!(Test-Path $PathBackupDestination\$ServerName\BEC\Log\$t)) {
		New-Item $PathBackupDestination\$ServerName\BEC\Log\$t -type directory | Out-Null
	}
	Copy-Item $FullPathBECExe $PathBackupDestination\$ServerName\BEC
	Start-Process robocopy "$BECPath\Config $PathBackupDestination\$ServerName\BEC\Config /mir " -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
	Start-Process robocopy "$FullPathBECLogFiles $PathBackupDestination\$ServerName\BEC\Log\$t /mir " -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
	Copy-Item $FullPathBECConfig $PathBackupDestination\$ServerName\BEC\Config
	Copy-Item $BECPath/*.txt $PathBackupDestination\$ServerName\BEC
	Copy-Item $BECPath/*.dll $PathBackupDestination\$ServerName\BEC
	Copy-Item $BECPath/*.bmp $PathBackupDestination\$ServerName\BEC
	
	
	#Backup TADST or manual Server-profile
	If ($EnableTADSTProfileSync -eq "YES") {
		Start-Process robocopy "$ServerPath\TADST $PathBackupDestination\$ServerName\TADST /mir " -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		Copy-Item $ServerPath\TADST*.* $PathBackupDestination\$ServerName
	} Else {
		if (!(Test-Path $PathBackupDestination\$ServerName\Profile)) {
			New-Item $PathBackupDestination\$ServerName\Profile -type directory | Out-Null
		}
		Start-Process robocopy "$PathActiveBattlEye\$TADSTProfileName $PathBackupDestination\$ServerName\$TADSTProfileName /mir " -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		Start-Process robocopy "$PathActiveBattlEye\$TADSTProfileName $PathBackupDestination\$ServerName\$TADSTProfileName /mir " -NoNewWindow -Wait -RedirectStandardOutput $FullPathTempLog
		Copy-Item $FullPathActiveConfig $PathBackupDestination\$ServerName
		Copy-Item $FullPathActiveBasicConfig $PathBackupDestination\$ServerName
	}
	
	
	# Backup the restarter
	if (!(Test-Path $PathBackupDestination\$ServerName\Restarter)) {
		New-Item $PathBackupDestination\$ServerName\Restarter -type directory | Out-Null
	}
	
	Copy-Item $PathRestarterLogFile $PathBackupDestination\$ServerName\Restarter
	Copy-Item $r $PathBackupDestination\$ServerName\Restarter
	Copy-Item $q $PathBackupDestination\$ServerName\Restarter


	# Cleanup
	if (!(Test-Path $PathBackupDestination\$ServerName\temp.log)) {
		Remove-Item $PathBackupDestination\$ServerName\temp.log | Out-Null
	}
	del $FullPathTempLog
	Start-Sleep -s $IntervalShort
}

$a=(Get-Date).ToUniversalTime()
Write-Host $a.ToShortTimeString() " -  Running sanity checks ..."

# Sanity check: checking for LogFile & Adding start-header
if (Test-Path $PathRestarterLogFile) {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a ";Set-Content $PathRestarterLogFile $b
	$b = "$a -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-";Add-Content $PathRestarterLogFile $b
	$b = "$a                AhoyWorld.co.uk Arma3 restarter by Kamaradski";Add-Content $PathRestarterLogFile $b
	$b = "$a -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-";Add-Content $PathRestarterLogFile $b
	$b = "$a ";Add-Content $PathRestarterLogFile $b
	$b = "$a ";Add-Content $PathRestarterLogFile $b
	$b = "$a  -  Existing logfile found: $PathRestarterLogFile "; Add-Content $PathRestarterLogFile $b
}Else{
	New-Item $PathRestarterLogFile -type file | Out-Null
	$a=(Get-Date).ToUniversalTime()
	$b = "$a ";Add-Content $PathRestarterLogFile $b
	$b = "$a -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-";Add-Content $PathRestarterLogFile $b
	$b = "$a                AhoyWorld.co.uk Arma3 restarter by Kamaradski";Add-Content $PathRestarterLogFile $b
	$b = "$a -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-";Add-Content $PathRestarterLogFile $b
	$b = "$a ";Add-Content $PathRestarterLogFile $b
	$b = "$a ";Add-Content $PathRestarterLogFile $b
	$b = "$a  -  Created new Logfile $PathRestarterLogFile "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Created new Logfile $PathRestarterLogFile" -ForegroundColor "Yellow"
}
Start-Sleep -s $IntervalShort




# Log manual config to log-file for debug purposes
if ($EnableTADSTProfileSync -ne "YES") {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Manual config enabled setting the following server profile:"; Add-Content $PathRestarterLogFile $b
	$b = "$a  -  			-profiles=$PathActiveBattlEye"; Add-Content $PathRestarterLogFile $b
	$b = "$a  -  			-name=$TADSTProfileName"; Add-Content $PathRestarterLogFile $b
	$b = "$a  -  			-bepath=$PathActiveBattlEye"; Add-Content $PathRestarterLogFile $b
	$b = "$a  -  			-config=$FullPathActiveConfig"; Add-Content $PathRestarterLogFile $b
	$b = "$a  -  			-cfg=$FullPathActiveBasicConfig"; Add-Content $PathRestarterLogFile $b
}




$a=(Get-Date).ToUniversalTime()
$b = "$a  -  Info read from config-file"; Add-Content $PathRestarterLogFile $b
$b = "$a  -  Config file found: $p"; Add-Content $PathRestarterLogFile $b
$b = "$a  -  Config parameters read:"; Add-Content $PathRestarterLogFile $b
$h.GetEnumerator() | Sort-Object Name | ForEach-Object {"{0} : {1}" -f $_.Name,$_.Value} | Add-Content $PathRestarterLogFile




# Sanity check: checking for running Arma3Server duplicates (same folder) & Kill if detected
$Script:CheckArmaServerRunning = Get-Process arma3server_x64 -ErrorAction SilentlyContinue | Where-Object {$_.Path -like "$ServerPath*"}
if ($CheckArmaServerRunning) {
	Foreach ($i in $CheckArmaServerRunning) {
		Stop-Process $($i.Id)
		$a=(Get-Date).ToUniversalTime()
		Write-Host $a.ToShortTimeString() " -  Duplicate arma-server detected: killed PID:$($i.Id)"
		$b = "$a  -  Duplicate arma-server detected: killed PID:$($i.Id) "; Add-Content $PathRestarterLogFile $b
	}
}
Start-Sleep -s $IntervalShort



# Sanity check: checking for Arma3Server executable
if (Test-Path $FullPathArmaServerExe) {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Arma Server found: $FullPathArmaServerExe "; Add-Content $PathRestarterLogFile $b
}Else{
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  arma3 Server NOT found: $FullPathArmaServerExe "; Add-Content $PathRestarterLogFile $b
	$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  Arma Server NOT found: $FullPathArmaServerExe" -BackgroundColor "Red" -ForegroundColor "white"
	Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
	Start-Sleep -s $IntervalLong
	exit
}
Start-Sleep -s $IntervalShort




# Sanity check: checking for BEC executable
if (Test-Path $FullPathBECExe) {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  BEC found: $FullPathBECExe "; Add-Content $PathRestarterLogFile $b
}Else{
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  BEC NOT found: $FullPathBECExe "; Add-Content $PathRestarterLogFile $b
	$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  BEC NOT found: $FullPathBECExe" -BackgroundColor "Red" -ForegroundColor "white"
	Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
	Start-Sleep -s $IntervalLong
	exit
}
Start-Sleep -s $IntervalShort




# Sanity check: checking for manual config files
if ($EnableTADSTProfileSync -ne "YES") {
	if (!(Test-Path $PathActiveBattlEye)) {
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Profile folder NOT found: $PathActiveBattlEye "; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  BattlEye folder NOT found: $PathActiveBattlEye" -BackgroundColor "Red" -ForegroundColor "white"
		Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
	}
	if (!(Test-Path $PathActiveBattlEye\$TADSTProfileName)) {
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Profile folder NOT found: $PathActiveBattlEye\$TADSTProfileName "; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  Profile folder NOT found: $PathActiveBattlEye\$TADSTProfileName" -BackgroundColor "Red" -ForegroundColor "white"
		Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
	}
	if (!(Test-Path $FullPathActiveConfig)) {
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Config-file NOT found: $FullPathActiveConfig "; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  Config-file NOT found: $FullPathActiveConfig" -BackgroundColor "Red" -ForegroundColor "white"
		Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
	}
	if (!(Test-Path $FullPathActiveBasicConfig)) {
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Basic Config-file NOT found: $FullPathActiveBasicConfig "; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  Basic Config-file NOT found: $FullPathActiveBasicConfig" -BackgroundColor "Red" -ForegroundColor "white"
		Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
	}
Start-Sleep -s $IntervalLong
exit
}




# Sanity check: checking for BattlEye master-config
if ($EnableBeSync -eq "YES") {
	if (Test-Path $FullPathMasterBEconfig) {
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  BattlEye master-config found: $FullPathMasterBEconfig "; Add-Content $PathRestarterLogFile $b
	}Else{
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  BattlEye master-config NOT found: $FullPathMasterBEconfig "; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  BattlEye master-config NOT found: $FullPathMasterBEconfig " -BackgroundColor "Red" -ForegroundColor "white"
		Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
		Start-Sleep -s $IntervalLong
		exit
	}
Start-Sleep -s $IntervalShort
}




# Sanity check: checking for BEC configuration file
if (Test-Path $FullPathBECConfig) {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  BEC config-file found: $FullPathBECConfig "; Add-Content $PathRestarterLogFile $b
}Else{
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  BEC config-file NOT found: $FullPathBECConfig "; Add-Content $PathRestarterLogFile $b
	$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  BEC config-file NOT found: $FullPathBECConfig" -BackgroundColor "Red" -ForegroundColor "white"
	Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
	Start-Sleep -s $IntervalLong
	exit
}
Start-Sleep -s $IntervalShort




# Sanity check: checking Backup Destination
if ($EnableBackup -eq "YES") {
	if (Test-Path $PathBackupDestination) {
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Backup folder found: $PathBackupDestination "; Add-Content $PathRestarterLogFile $b
	}Else{
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Backup folder NOT found: $PathBackupDestination "; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  Backup folder NOT found: $PathBackupDestination" -BackgroundColor "Red" -ForegroundColor "white"
		Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
		Start-Sleep -s $IntervalLong
		exit
	}
}
Start-Sleep -s $IntervalShort




# Sanity check: checking for BattlEye configuration file
if (Test-Path $FullPathActiveBattlEyeConfig) {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  BattlEye config-file found: $FullPathActiveBattlEyeConfig "; Add-Content $PathRestarterLogFile $b
}Else{
	if ($EnableBeSync -eq "YES") {
	} ELSE {
		CleanBEConfig
		if (Test-Path $FullPathActiveBattlEyeConfig) {
		} Else {
			$a=(Get-Date).ToUniversalTime()
			$b = "$a  -  BattlEye config-file NOT found: $FullPathActiveBattlEyeConfig "; Add-Content $PathRestarterLogFile $b
			$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
			Write-Host $a.ToShortTimeString() " -  BattlEye config-file NOT found: $FullPathActiveBattlEyeConfig" -BackgroundColor "Red" -ForegroundColor "white"
			Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
			Start-Sleep -s $IntervalLong
			exit
		}
	}
}
Start-Sleep -s $IntervalShort




# Sanity check: checking for Bans.txt configuration file
if (Test-Path $FullPathBanFile) {
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  Ban-list file found: $FullPathBanFile "; Add-Content $PathRestarterLogFile $b
}Else{
	$a=(Get-Date).ToUniversalTime()
	$b = "$a  -  NO ban-list file found: $FullPathBanFile "; Add-Content $PathRestarterLogFile $b
	$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
	Write-Host $a.ToShortTimeString() " -  NO ban-list file found: $FullPathBanFile" -BackgroundColor "Red" -ForegroundColor "white"
	Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
	Start-Sleep -s $IntervalLong
	exit
}
Start-Sleep -s $IntervalShort




# Sanity check: checking for Keys master-folder
if ($EnableKeySync -eq "YES") {
	if (Test-Path $MasterPathKey\*.bikey) {
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Keys master-folder found & containing keys: $MasterPathKey "; Add-Content $PathRestarterLogFile $b
	}Else{
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  Keys master-folder NOT found OR empty: $MasterPathKey "; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  Keys master-folder NOT found OR empty: $MasterPathKey" -BackgroundColor "Red" -ForegroundColor "white"
		Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
		Start-Sleep -s $IntervalLong
		exit
	}
	Start-Sleep -s $IntervalShort
}




# Sanity check: checking for MPMissions master-folder
if ($EnableMissionSync -eq "YES") {
	if (Test-Path $MasterPathMissions\*.pbo) {
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  MPMissions master-folder found & containing PBOs: $MasterPathMissions "; Add-Content $PathRestarterLogFile $b
	}Else{
		$a=(Get-Date).ToUniversalTime()
		$b = "$a  -  MPMissions master-folder NOT found OR empty: $MasterPathMissions "; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  Exiting script ... "; Add-Content $PathRestarterLogFile $b
		Write-Host $a.ToShortTimeString() " -  MPMissions master-folder NOT found OR empty: $MasterPathMissions" -BackgroundColor "Red" -ForegroundColor "white"
		Write-Host $a.ToShortTimeString() " -  Exiting script ..." -BackgroundColor "Red" -ForegroundColor "white"
		Start-Sleep -s $IntervalLong
		exit
	}
	Start-Sleep -s $IntervalShort
}




# Initial startup
StartSequence




# Main loop
Do {

	# check if Arma server is running
	IsServerRunning
	if (!$CheckArmaServerRunning) {
		$a=(Get-Date).ToUniversalTime()
		$b = ''; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  APP:arma3server_x64.exe PID:$($ArmaServerID.Id) crashed: restarting ... "; Add-Content $PathRestarterLogFile $b
		Write-Host ''
		Write-Host $a.ToShortTimeString() " -  APP:arma3server_x64.exe PID:$($ArmaServerID.Id) crashed: restarting ..." -BackgroundColor "Red" -ForegroundColor "white"
		Start-Sleep -s $IntervalMedium
		KILLBEC
		Start-Sleep -s $IntervalMedium
		KILLSERVER
		Start-Sleep -s $IntervalMedium
		CleanBEConfig
		Start-Sleep -s $IntervalMedium
		StartSequence
	}
	IsServerRunning
    	if ((Get-Date -UFormat "%H %M") -eq (Get-Date -Hour 4 -Minute 15 -UFormat "%H %M")) {
    		$a=(Get-Date).ToUniversalTime()
		$b = ''; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  APP:arma3server_x64.exe PID:$($ArmaServerID.Id) is performing daily restart ... "; Add-Content $PathRestarterLogFile $b
		Write-Host ''
		Write-Host $a.ToShortTimeString() " -  APP:arma3server_x64.exe PID:$($ArmaServerID.Id) restarting at 5am ..." -BackgroundColor "Red" -ForegroundColor "white"
		Start-Sleep -s $IntervalMedium
		KILLBEC
		Start-Sleep -s $IntervalMedium
		KILLSERVER
		Start-Sleep -s $IntervalMedium
		CleanBEConfig
		Start-Sleep -s $IntervalMedium
		StartSequence
    	}

	IsBECStillRunning
	if (!$CheckBECRunning) {
		$a=(Get-Date).ToUniversalTime()
		$b = ''; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  APP:$BECExe PID:$($BECID.Id) crashed: restarting ... "; Add-Content $PathRestarterLogFile $b
		Write-Host ''
		Write-Host $a.ToShortTimeString() " -  APP:$BECExe PID:$($BECID.Id) crashed: restarting ..." -BackgroundColor "Red" -ForegroundColor "white"
		KILLBEC
		Start-Sleep -s $IntervalMedium
		CleanBEConfig
		Start-Sleep -s $IntervalShort
		RUNStartBEC
		$Script:BECRestartCounter++
	}
	Start-Sleep -s $IntervalLong
	if ($BECRestartCounter -gt 3) { 			#if BEC restarted more than 2 in a row
		$a=(Get-Date).ToUniversalTime()
		$b = ''; Add-Content $PathRestarterLogFile $b
		$b = "$a  -  Something funky is happening to BEC: restarting arma3server ... "; Add-Content $PathRestarterLogFile $b
		Write-Host ''
		Write-Host $a.ToShortTimeString() " -  Something funky is happening to BEC: restarting arma3server ..." -BackgroundColor "Red" -ForegroundColor "white"
		KILLBEC
		Start-Sleep -s $IntervalMedium
		KILLSERVER
		Start-Sleep -s $IntervalMedium
		CleanBEConfig
		Start-Sleep -s $IntervalShort
		StartSequence
	}
} While ($gamer –eq ‘happy’)