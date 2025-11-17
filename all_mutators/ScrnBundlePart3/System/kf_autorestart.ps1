# KF Server Auto Restart Script
# (c) [ScrN]PooSH, 2016
#
# To allow execution of third-party PS script on your system you need to launch PowerShell as admin and enter:
# Set-ExecutionPolicy Unrestricted

$kfsystemdir = "c:\kfserver\KillingFloor\System\"
$kfexename = "ucc.exe"

$kfport=7707
$kfmutators="ScrnSP.ServerPerksMutSE,ScrnBalanceSrv.ScrnBalance"
$kfplayers=20
$kflog="kfserver.log"

$params = "server KF-BioticsLab.rom?Game=ScrnBalanceSrv.ScrnGameType?GameLength=2?VACSecured=true?MaxPlayers=${kfplayers}?Port=${kfport}?Mutator=${kfmutators} log=${kflog}"


$process = $null
$processid = $null
while ( $true ) { 
    if ( (!$process) -or ($process.HasExited) ) {
        echo "Starting KF..."
        $process = Start-Process -FilePath $kfexename -ArgumentList $params -WorkingDirectory $kfsystemdir -PassThru
        Get-Process -InputObject $process
        if ( $process ) {
            $processid = $process.id
            echo "Process ID = $processid"
        }
    }
    Start-Sleep -Seconds 5

    echo "Waiting for KF to exit..."
    $process.WaitForExit()
    $exitcode = $process.ExitCode
    echo "KF finished with exit code = $exitcode"
    Start-Sleep -Seconds 5
}
