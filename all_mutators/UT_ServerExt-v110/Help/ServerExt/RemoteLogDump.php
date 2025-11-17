<?php
/******************************************************************************

	RemoteLogDump.php

	Simple PHP script that will accept UT2004 stats log data as posted by
	RemoteStats of ServerExt ( http://ut2004.elmuerte.com/ServerExt )	

	Written by Michiel "El Muerte" Hendriks

******************************************************************************/

/**   config part   **/

/** log filename prefix */
$logprefix		= "Stats_";
/** 
	directory where to write the log files, must be writable by the webserver 
	user (include the trailing slash) 
*/
$logpath		= "./logs/";
/** name of the secret field */
$SecretName		= "secret";
/** 
	the value of the secret field, if it doesn't match the log file will be 
	ignored 
*/
$SecretValue	= "MySecret";

/** 
	if you set this to true the script will call UTStatsDB's log processor 
	after it received an endgame stats line. For this the script assumes it's
	located in the UTStatsDB directory.
*/
$UTStatsDBProcLog = true;


/**   script part   **/

header("Content-type: text/plain");
if (empty($_REQUEST["serverPort"]) || empty($_REQUEST["serverHost"]) || empty($_REQUEST["gameDateTime"])) 
{
	// unacceptable request
	header("HTTP/1.1 406 Not Acceptable");
	die;
}
if ($_REQUEST[$SecretName] != $SecretValue) 
{
	// secret doesn't match
	header("HTTP/1.1 403 Forbidden");
	die;
}
if (empty($_REQUEST["stats"])) 
{	
	// nothing to log, just ignore
	die;
}

$gamedate = date("Y_m_d_H_i_s", strtotime($_REQUEST["gameDateTime"]));
$fname = $logpath.$logprefix.$_REQUEST["serverPort"]."_".$gamedate.".log";

$fp = @fopen($fname, "a");
if ($fp === false)
{
	header("HTTP/1.1 500");
	echo "Unable to open file: ".$fname;
	die;
}

if (flock($fp, LOCK_EX))
{
	fputs($fp, $_REQUEST["stats"]);
	flock($fp, LOCK_UN);
	echo "Stats log success";
}
else {
	// failed to lock
	header("HTTP/1.1 500");
	echo "Failed to lock file: ".$fname;
}
fclose($fp);

if ($UTStatsDBProcLog)
{
	// has endgame flag?
	if (preg_match("#^([0-9]+)\tEG\t#m", $_REQUEST["stats"]))
	{
		echo "\nFound endgame";
		if (file_exists("logs.php"))
		{
			register_shutdown_function("endgameProcLogs");
			die();
		}
		else echo "\nError UTStatsDB's logs.php not found";
	}
}

function endgameProcLogs()
{
	echo "\nCalling logs.php\n";
	unset($UpdatePass);
	@require("config.inc.php");
	if ($UpdatePass != "") readfile("http://".$_SERVER["HTTP_HOST"].dirname($_SERVER["PHP_SELF"])."/logs.php?pass=".rawurlencode($UpdatePass));
}

?>