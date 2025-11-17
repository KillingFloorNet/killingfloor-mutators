// Coded by Shambler, credits to Wormbo for his SHA1 class and for helping me bugfix authentication

// TODO: You can actually parse result packets as an array of strings, do that to simplify SQLHandle implementations (that would be a big step to making this code more usable)
Class SQLLink extends TCPLink
	dependson(SHA1Hash);

var string SQLServerIP;
var int SQLServerPort;

var string SQLUser;
var string SQLPassword;

var string SQLDatabase;

var bool bDebugLog;

// NOTE: The commented variables are parts of the packet which I do not need to get the code working
//	[4:PacketHeader][1:ProtocolVersion][Str:ServerVersion][4:ThreadID]
//	[8:ScrambleBuffer][1:0x00][2:ServerCaps][1:ServerLanguage]
//	[2:ServerStatus][13:0x00][12:ExtendedScrambleBuffer]
struct ChallengePacket
{
	//var byte	Header[4];
	//var byte	ProtocolVersion;
	//var string	ServerVersion;
	//var byte	ThreadID[4];

	var byte	ScrambleBuffer[20];
	var byte	ServerCapabilities[2];
	var byte	ServerLanguage;
	var byte	ServerStatus[2];
};


// Since it's possible for tick to be called while incoming data has not entirely arrived, the code will delay data processing until all data has arrived
var bool bReceivingData;
var array<byte> ResultData;

var array<byte> DebugResultData;
var deprecated int RemoveThisDebugCode;

var bool bAuthenticated;

// Query result filtering stuff
var int NextPacketPos;
var int HeaderBuffLen;
var int ByteCount;
var byte HeaderBuff[5];
var bool bInTargetPacket;
var bool bPendingPacketData;
var bool bIgnoreHeader;

// Updated query filtering
var byte StartFilter;
var byte EndFilter;
var bool bFilterStart;
var bool bFilterEnd;

var bool bPendingTargetChange;


// Delegates for controlling the SQL link
delegate AuthSuccess();			// Called once this object has successfully authenticated with and logged on to the SQL server, safe to make queries after this is called
delegate Disconnected();
delegate QueryResult();			// Called when receiving query data from the SQL server, the incoming data is stored within ResultData

delegate QueryError(string Msg);	// Called within 'QueryFiltering' when the server encountered an error parsing your query (atm, QueryResult is still called and sent the incoming data)


function PostBeginPlay()
{
	LinkMode = MODE_Binary;
	ReceiveMode = RMODE_Manual;
}

// Setup the delegates BEFORE connecting to an SQL server...especially if your connecting to localhost
function bool SQLConnect(string IP, bool bResolveIP, int Port, string User, string Password, optional string Database, optional int DesiredPort)
{
	local int BoundPort;

	if (DesiredPort != 0)
	{
		BoundPort = BindPort(DesiredPort, True);

		if (BoundPort != DesiredPort)
			Log("Couldn't bind to port"@DesiredPort$", bound to port number"@BoundPort@"instead", 'TTF_SQL');
	}
	else
	{
		BoundPort = BindPort();
		Log("No default port specified, bound to port number"@BoundPort, 'TTF_SQL');
	}


	SQLServerIP = IP;
	SQLServerPort = Port;

	SQLUser = User;
	SQLPassword = Password;
	SQLDatabase = Database;


	if (!bResolveIP)
	{
		if (!StringToIPAddr(SQLServerIP, RemoteAddr))
		{
			Log("SQLServerIP is not a valid IP address (Winsock error:"@GetLastError()$"), aborting", 'TTF_SQL');
			return false;
		}

		RemoteAddr.Port = Port;

		if (!Open(RemoteAddr))
		{
			Log("Failed to open connection to SQL Server (Winsock error:"@GetLastError()$")", 'TTF_SQL');
			return false;
		}
	}
	else
	{
		RemoteAddr.Port = Port;

		Log("Resolving:"@IP, 'TTF_SQL');
		Resolve(IP);
	}

	return true;
}

function Resolved(IPAddr Addr)
{
	RemoteAddr.Addr = Addr.Addr;

	if (!Open(RemoteAddr))
		Log("Failed to open connection to SQL Server (Winsock error:"@GetLastError()$")", 'TTF_SQL');
}

function ResolveFailed()
{
	Log("SQLServerIP did not resolve into an IP address", 'TTF_SQL');
	Disconnected();
}


function Opened()
{
	if (bDebugLog)
		Log("Successfully opened connection to SQL Server", 'TTF_SQL');
}

function Closed()
{
	if (bDebugLog)
	{
		if (GetLastError() == 0)
			Log("Connection to SQL Server has been closed", 'TTF_SQL');
		else
			Log("Connection to SQL Server has been closed, last winsock error:"@GetLastError(), 'TTF_SQL');
	}

	Disconnected();
}


// Implemented within individual states
function InternalQueryResult();


// Only perform querys after AuthSuccess has been called.
function SendQuery(string Query, optional byte CmdType);

// Special filtering function, this class was NOT coded to parse SQL results normally because (IMO) it's way too slow for UScript.
// Instead this function allows you to filter out all unwanted result packets, this is not documented but typically you just input: SetQueryFilter(0xfe, 0xfe, true, true, true);
function SetQueryFilter(byte StartID, optional byte EndID, optional bool bSkipStart, optional bool bSkipEnd, optional bool bStripHeader)
{
	if (!bAuthenticated)
	{
		Log("Can't set a query filter until the link has been authenticated", 'TTF_SQL');
		return;
	}


	if (StartID == -1)
	{
		GotoState('Authenticated');
		return;
	}

	StartFilter = StartID;

	if (EndID == -1)
		EndFilter = 0;
	else
		EndFilter = EndID;

	bFilterStart = bSkipStart;
	bFilterEnd = bSkipEnd;
	bIgnoreHeader = bStripHeader;


	GotoState('QueryFilter');
}


// Handles receiving and storing of all incoming data (except when overriden by certain states)
function Tick(float DeltaTime)
{
	local byte DataBuff[255];
	local byte DataBuffLen, i;

	if (IsDataPending() && LinkState == STATE_Connected)
	{
		// If new data is arriving after the link has been idle, the info within ResultData should have already been parsed so wipe the array
		if (!bReceivingData)
		{
			ResultData.Length = 0;
			bReceivingData = True;
		}


		if (bDebugLog)
			Log("Receiving data from SQL Server", 'TTF_SQL');


		// Extract the packet into the ResultData array
		do
		{
			DataBuffLen = ReadBinary(255, DataBuff);
			ResultData.Length = ResultData.Length + DataBuffLen;

			for (i=0; i<DataBuffLen; ++i)
				ResultData[(ResultData.Length-DataBuffLen)+i] = DataBuff[i];
		}
		until (DataBuffLen <= 0)
	}
	else if (bReceivingData)
	{
		bReceivingData = False;

		if (bDebugLog)
			Log("Data length is:"@ResultData.Length, 'TTF_SQL');

		InternalQueryResult();
	}
}

auto state PreChallenge
{
	function InternalQueryResult()
	{
		local int i, iTempInt, j;
		local string StringChallenge, HexChallenge;
		local ChallengePacket SQLChallenge;
		local SHA1Hash.SHA1Result HashStage1, HashStage2;
		local array<byte> ScrambleHashBuff, HS1;
		local byte DataBuff[255];


		// Now parse the challenge packet
		// Challenge packet construction:
		//
		//	[4:PacketHeader][1:ProtocolVersion][Str:ServerVersion][4:ThreadID]
		//	[8:ScrambleBuffer][1:0x00][2:ServerCaps][1:ServerLanguage]
		//	[2:ServerStatus][13:0x00][12:ExtendedScrambleBuffer]
		//

		// As far as I can tell, ProtocolVersion should always be 0x0A i.e. 10
		if (bDebugLog)
		{
			for (i=0; i<ResultData.Length; ++i)
			{
				StringChallenge $= Chr(ResultData[i]);
				HexChallenge $= ByteToHex(ResultData[i])@"";
			}

			Log("Packet data, str:"@StringChallenge, 'TTF_SQLServer');
			Log("Packet data, hex:"@HexChallenge, 'TTF_SQLServer');
		}

		//SQLChallenge.Header[0] = ResultData[0];
		//SQLChallenge.Header[1] = ResultData[1];
		//SQLChallenge.Header[2] = ResultData[2];
		//SQLChallenge.Header[3] = ResultData[3];

		if (ResultData[4] != 10)
		{
			Log("Unknown SQL protocol version, closing connection", 'TTF_SQL');
			Close();

			return;
		}

		//SQLChallenge.ProtocolVersion = ResultData[4];


		for (i=5; ResultData[i-1]!=0; ++i)
		{
			if (i >= ResultData.Length)
			{
				Log("Challenge packet is corrupt or incomplete, closing connection", 'TTF_SQL');
				Close();

				return;
			}

			//SQLChallenge.ServerVersion $= Chr(ResultData[i]);
		}


		if (i + 42 >= ResultData.Length)
		{
			Log("Challenge packet is corrupt or incomplete, closing connection", 'TTF_SQL');
			Close();

			return;
		}

		//SQLChallenge.ThreadID[0] = ResultData[i];
		//SQLChallenge.ThreadID[1] = ResultData[i+1];
		//SQLChallenge.ThreadID[2] = ResultData[i+2];
		//SQLChallenge.ThreadID[3] = ResultData[i+3];

		SQLChallenge.ScrambleBuffer[0] = ResultData[i+4];
		SQLChallenge.ScrambleBuffer[1] = ResultData[i+5];
		SQLChallenge.ScrambleBuffer[2] = ResultData[i+6];
		SQLChallenge.ScrambleBuffer[3] = ResultData[i+7];
		SQLChallenge.ScrambleBuffer[4] = ResultData[i+8];
		SQLChallenge.ScrambleBuffer[5] = ResultData[i+9];
		SQLChallenge.ScrambleBuffer[6] = ResultData[i+10];
		SQLChallenge.ScrambleBuffer[7] = ResultData[i+11];

		SQLChallenge.ServerCapabilities[0] = ResultData[i+13];
		SQLChallenge.ServerCapabilities[1] = ResultData[i+14];

		SQLChallenge.ServerLanguage = ResultData[i+15];

		SQLChallenge.ServerStatus[0] = ResultData[i+16];
		SQLChallenge.ServerStatus[1] = ResultData[i+17];

		// Grab the last 12 bytes of the scramble buffer
		SQLChallenge.ScrambleBuffer[8] = ResultData[i+31];
		SQLChallenge.ScrambleBuffer[9] = ResultData[i+32];
		SQLChallenge.ScrambleBuffer[10] = ResultData[i+33];
		SQLChallenge.ScrambleBuffer[11] = ResultData[i+34];
		SQLChallenge.ScrambleBuffer[12] = ResultData[i+35];
		SQLChallenge.ScrambleBuffer[13] = ResultData[i+36];
		SQLChallenge.ScrambleBuffer[14] = ResultData[i+37];
		SQLChallenge.ScrambleBuffer[15] = ResultData[i+38];
		SQLChallenge.ScrambleBuffer[16] = ResultData[i+39];
		SQLChallenge.ScrambleBuffer[17] = ResultData[i+40];
		SQLChallenge.ScrambleBuffer[18] = ResultData[i+41];
		SQLChallenge.ScrambleBuffer[19] = ResultData[i+42];




		// The challenge packet has been successfully parsed, now send the challenge response
		if (bDebugLog)
			Log("Challenge packet has been successfully parsed, constructing challenge response", 'TTF_SQL');


		// Response packet construction:
		//
		//	[4:PacketHeader][4:ClientFlags][4:MaxPacketSize][1:CharacterSet?]
		//	[23:0x00][Str:User][1:ScrambleBufferLength][20:ScrambleBuffer][Str:DatabaseName(Optional)]

		// First figure out the total length of the new packet (also accounting for null char in strings)
		if (SQLDatabase != "")
			ResultData.Length = 32 + Len(SQLUser) + 22 + Len(SQLDatabase) + 1;
		else
			ResultData.Length = 32 + Len(SQLUser) + 22;


		// Now construct the packet

		// Packet Header ([3:PacketSize][1:PacketNumber])
		ResultData[0] = ResultData.Length & 0xff;
		ResultData[1] = byte(ResultData.Length >> 8) & 0xff; // Must be converted to byte or it fails
		ResultData[2] = byte(ResultData.Length >> 16) & 0xff;

		// Packet size info within packet header doesn't count packet header size, so add the extra 4 bytes on here
		ResultData.Length = ResultData.Length + 4;


		if (bDebugLog)
			Log("PacketLength hex values are:"@ByteToHex(ResultData[0])@ByteToHex(ResultData[1])@ByteToHex(ResultData[2]), 'TTF_SQL');


		ResultData[3] = 1;



	/*
		if (bDebugLog)
		{
			Log("Server capabilities:", 'TTF_SQL');
			Log("", 'TTF_SQL');

			Log("	Long password:"@bool(SQLChallenge.ServerCapabilities[0] & 1), 'TTF_SQL');
			Log("	Found row(?):"@bool(SQLChallenge.ServerCapabilities[0] & 2), 'TTF_SQL');
			Log("	Long flag(?):"@bool(SQLChallenge.ServerCapabilities[0] & 4), 'TTF_SQL');
			Log("	Connect with Database:"@bool(SQLChallenge.ServerCapabilities[0] & 8), 'TTF_SQL');
			Log("	No schema(?):"@bool(SQLChallenge.ServerCapabilities[0] & 16), 'TTF_SQL');
			Log("	Compress:"@bool(SQLChallenge.ServerCapabilities[0] & 32), 'TTF_SQL');
			Log("	ODBC:"@bool(SQLChallenge.ServerCapabilities[0] & 64), 'TTF_SQL');
			Log("	Local files(?):"@bool(SQLChallenge.ServerCapabilities[0] & 128), 'TTF_SQL');

			Log("	Ignore space(?):"@bool(SQLChallenge.ServerCapabilities[1] & 1), 'TTF_SQL'); // If ServerCapabilities in UScript was still a WORD type...this would be & 256 etc.
			Log("	Protocol 4.1:"@bool(SQLChallenge.ServerCapabilities[1] & 2), 'TTF_SQL');
			Log("	Interactive(?):"@bool(SQLChallenge.ServerCapabilities[1] & 4), 'TTF_SQL');
			Log("	SSL(?):"@bool(SQLChallenge.ServerCapabilities[1] & 8), 'TTF_SQL');
			Log("	Ignore sigpipes(?):"@bool(SQLChallenge.ServerCapabilities[1] & 16), 'TTF_SQL');
			Log("	Transactions(?):"@bool(SQLChallenge.ServerCapabilities[1] & 32), 'TTF_SQL');
			Log("	Reserved(?):"@bool(SQLChallenge.ServerCapabilities[1] & 64), 'TTF_SQL');
			Log("	Secure connection:"@bool(SQLChallenge.ServerCapabilities[1] & 128), 'TTF_SQL');
		}
	*/


		if (!bool(SQLChallenge.ServerCapabilities[1] & 2) || !bool(SQLChallenge.ServerCapabilities[1] & 128))
		{
			Log("Not compatable with MySQL versions below 4.1", 'TTF_SQL');
			Close();

			return;
		}


		// ClientFlags
		ResultData[4] = 1 | 8;		// Long password | Connect with database
		ResultData[5] = 2 | 128;	// Protocol 4.1 | Secure Connection (2 really = 512, 128 = 32768.....remember this is the second byte within an INTEGER..and in backwards order)
		ResultData[6] = 0;
		ResultData[7] = 0;

		// MaxPacketSize, set at 8192
		ResultData[8] = 0;
		ResultData[9] = 0;
		ResultData[10] = 0;
		ResultData[11] = 2;


		// CharacterSet
		ResultData[12] = SQLChallenge.ServerLanguage;

		// Fillers
		ResultData[13] = 0;
		ResultData[14] = 0;
		ResultData[15] = 0;
		ResultData[16] = 0;
		ResultData[17] = 0;
		ResultData[18] = 0;
		ResultData[19] = 0;
		ResultData[20] = 0;
		ResultData[21] = 0;
		ResultData[22] = 0;
		ResultData[23] = 0;
		ResultData[24] = 0;
		ResultData[25] = 0;
		ResultData[26] = 0;
		ResultData[27] = 0;
		ResultData[28] = 0;
		ResultData[29] = 0;
		ResultData[30] = 0;
		ResultData[31] = 0;
		ResultData[32] = 0;
		ResultData[33] = 0;
		ResultData[34] = 0;
		ResultData[35] = 0;

		// User
		iTempInt = 36 + Len(SQLUser);

		for (i=36; i<iTempInt; ++i)
			ResultData[i] = Asc(Mid(SQLUser, i-36, 1));

		ResultData[i] = 0;
		++i;


		// Scramble buffer, i.e. encrypted password
		HashStage1 = Class'SHA1Hash'.static.GetStringHash(SQLPassword);
		Class'SHA1Hash'.static.GetHashBytes(HS1, HashStage1);

		HashStage2 = Class'SHA1Hash'.static.GetArrayHash(HS1);


		// Pass ScrambleBuffer and the hashed password into an array of bytes for scrambling
		ScrambleHashBuff.Length = 20;

		ScrambleHashBuff[0] = SQLChallenge.ScrambleBuffer[0];
		ScrambleHashBuff[1] = SQLChallenge.ScrambleBuffer[1];
		ScrambleHashBuff[2] = SQLChallenge.ScrambleBuffer[2];
		ScrambleHashBuff[3] = SQLChallenge.ScrambleBuffer[3];
		ScrambleHashBuff[4] = SQLChallenge.ScrambleBuffer[4];
		ScrambleHashBuff[5] = SQLChallenge.ScrambleBuffer[5];
		ScrambleHashBuff[6] = SQLChallenge.ScrambleBuffer[6];
		ScrambleHashBuff[7] = SQLChallenge.ScrambleBuffer[7];
		ScrambleHashBuff[8] = SQLChallenge.ScrambleBuffer[8];
		ScrambleHashBuff[9] = SQLChallenge.ScrambleBuffer[9];
		ScrambleHashBuff[10] = SQLChallenge.ScrambleBuffer[10];
		ScrambleHashBuff[11] = SQLChallenge.ScrambleBuffer[11];
		ScrambleHashBuff[12] = SQLChallenge.ScrambleBuffer[12];
		ScrambleHashBuff[13] = SQLChallenge.ScrambleBuffer[13];
		ScrambleHashBuff[14] = SQLChallenge.ScrambleBuffer[14];
		ScrambleHashBuff[15] = SQLChallenge.ScrambleBuffer[15];
		ScrambleHashBuff[16] = SQLChallenge.ScrambleBuffer[16];
		ScrambleHashBuff[17] = SQLChallenge.ScrambleBuffer[17];
		ScrambleHashBuff[18] = SQLChallenge.ScrambleBuffer[18];
		ScrambleHashBuff[19] = SQLChallenge.ScrambleBuffer[19];

		// Appends the hashed password to ScrambleHashBuff
		Class'SHA1Hash'.static.GetHashBytes(ScrambleHashBuff, HashStage2);


		HashStage2 = Class'SHA1Hash'.static.GetArrayHash(ScrambleHashBuff);


		// Calculate the final hash and store it in the packet
		ResultData[i] = 20;

		ResultData[i+1] =	((HashStage2.A >> 24)	& 0xff) ^ HS1[0];
		ResultData[i+2] =	((HashStage2.A >> 16)	& 0xff) ^ HS1[1];
		ResultData[i+3] =	((HashStage2.A >> 8)	& 0xff) ^ HS1[2];
		ResultData[i+4] =	(HashStage2.A		& 0xff) ^ HS1[3];
		ResultData[i+5] =	((HashStage2.B >> 24)	& 0xff) ^ HS1[4];
		ResultData[i+6] =	((HashStage2.B >> 16)	& 0xff) ^ HS1[5];
		ResultData[i+7] =	((HashStage2.B >> 8)	& 0xff) ^ HS1[6];
		ResultData[i+8] =	(HashStage2.B		& 0xff) ^ HS1[7];
		ResultData[i+9] =	((HashStage2.C >> 24)	& 0xff) ^ HS1[8];
		ResultData[i+10] =	((HashStage2.C >> 16)	& 0xff) ^ HS1[9];
		ResultData[i+11] =	((HashStage2.C >> 8)	& 0xff) ^ HS1[10];
		ResultData[i+12] =	(HashStage2.C		& 0xff) ^ HS1[11];
		ResultData[i+13] =	((HashStage2.D >> 24)	& 0xff) ^ HS1[12];
		ResultData[i+14] =	((HashStage2.D >> 16)	& 0xff) ^ HS1[13];
		ResultData[i+15] =	((HashStage2.D >> 8)	& 0xff) ^ HS1[14];
		ResultData[i+16] =	(HashStage2.D		& 0xff) ^ HS1[15];
		ResultData[i+17] =	((HashStage2.E >> 24)	& 0xff) ^ HS1[16];
		ResultData[i+18] =	((HashStage2.E >> 16)	& 0xff) ^ HS1[17];
		ResultData[i+19] =	((HashStage2.E >> 8)	& 0xff) ^ HS1[18];
		ResultData[i+20] =	(HashStage2.E		& 0xff) ^ HS1[19];


		// Now add the database name, if specified
		if (SQLDatabase != "")
		{
			i += 21;
			iTempInt = i + Len(SQLDatabase);

			for (j=i; j<iTempInt; ++j)
				ResultData[j] = Asc(Mid(SQLDatabase, j-i, 1));


			ResultData[j] = 0;
		}




		// Switch states before sending the packet
		GotoState('PostChallenge');


		// Send the packet and await the servers response
		for (j=0; (j*255)<ResultData.Length; ++j)
		{
			iTempInt = ResultData.Length - (j*255);

			for (i=0; i<255 && i<iTempInt; ++i)
				DataBuff[i] = ResultData[(j*255)+i];

			SendBinary(Min(255, iTempInt), DataBuff);
		}
	}
}

state PostChallenge
{
	function InternalQueryResult()
	{
	/*
		local int i, ErrorNum;
		local string SQLState, ErrorMsg;

		// OK Packet
		if (ResultData[4] == 0)
		{
			if (bDebugLog)
				Log("Successfully authenticated with the MySQL server", 'TTF_SQL');

			// No need to parse any extra data, go straight to the 'Authenticated' state...the connection is then ready to send queries
			GotoState('Authenticated');
		}
		// Error packet (connection will often cutoff before the error packet is received, limitation of TCPLink's)
		else if (ResultData[4] == 255)
		{
			ErrorNum = (ResultData[6] << 8) + ResultData[5];
			SQLState = "#"$Chr(ResultData[8])$Chr(ResultData[9])$Chr(ResultData[10])$Chr(ResultData[11])$Chr(ResultData[12]);

			for (i=13; i<ResultData.Length; ++i)
				ErrorMsg $= Chr(ResultData[i]);

			Log("Error while authenticating with MySQL server ("$ErrorNum$", "$SQLState$"), error message:", 'TTF_SQL');
			Log("	"$ErrorMsg, 'TTF_SQL');

			Close();
		}
		else
		{
			Log("Was expecting an 'OK' packet or an 'Error' packet, got a packet with ID #"$ResultData[4]@"instead. Closing connection", 'TTF_SQL');
			Close();
		}
	*/
	/**/
		local int PacketID;
		local array<string> ErrorData;

		PacketID = ParseResultPacketID();

		// OK Packet
		if (PacketID == 0)
		{
			if (bDebugLog)
				Log("Successfully authenticated with the MySQL server", 'TTF_SQL');

			// No need to parse any extra data, go straight to the 'Authenticated' state...the connection is then ready to send queries
			GotoState('Authenticated');
		}
		// Error packet (connection will often cutoff before the error packet is received, limitation of TCPLink's)
		else if (PacketID == 255)
		{
			ErrorData = ParseResultPacket();

			if (ErrorData.Length < 2)
			{
				Log("Bad error packet", 'TTF_SQL');
			}
			else
			{
				Log("Error while authenticating with MySQL server ("$ErrorData[0]$", "$ErrorData[1]$"), error message:", 'TTF_SQL');
				Log("     "$ErrorData[2], 'TTF_SQL');
			}

			Close();
		}
		else
		{
			Log("Was expecting an 'OK' packet or an 'Error' packet, got a packet with ID #"$PacketID@"instead. Closing connection", 'TTF_SQL');
			Close();
		}
	/**/
	}
}


// Ready to communicate with database, queries can be performed within this state (NOTE: All query result packets must be parsed manually when using this state)
state Authenticated
{
	function SendQuery(string Query, optional byte CmdType)
	{
		local array<byte> OutData;
		local byte DataBuff[255];
		local int i, j, iTempInt;

		iTempInt = Len(Query);


		OutData.Length = 5 + iTempInt;


		OutData[0] = (OutData.Length - 4) & 0xff;
		OutData[1] = byte((OutData.Length - 4) >> 8) & 0xff;
		OutData[2] = byte((OutData.Length - 4) >> 16) & 0xff;

		OutData[3] = 0;


		// Setup the command type
		if (CmdType == 0)
			OutData[4] = 3;
		else if (CmdType == -1)
			OutData[4] = 0;
		else
			OutData[4] = CmdType;


		for (i=0; i<iTempInt; ++i)
			OutData[i+5] = Asc(Mid(Query, i, 1));



		// Now send the cmd
		for (j=0; (j*255)<OutData.Length; ++j)
		{
			iTempInt = OutData.Length - (j*255);

			for (i=0; i<255 && i<iTempInt; ++i)
				DataBuff[i] = OutData[(j*255)+i];

			SendBinary(Min(255, iTempInt), DataBuff);
		}
	}

	function BeginState()
	{
		if (!bAuthenticated)
		{
			bAuthenticated = True;
			AuthSuccess();
		}
	}

	function InternalQueryResult()
	{
		local int i;
		local string DataString;

		if (bDebugLog)
		{
			Log("Data length is:"@ResultData.Length, 'TTF_SQL');

			Log("Data:", 'TTF_SQL');

			for (i=4; i<ResultData.Length; ++i)
				DataString $= Chr(ResultData[i]);

			Log(DataString, 'TTF_SQL');
		}

		QueryResult();
	}
}

// Special state used for filtering incoming query results, more efficient than reading all incoming packets but there is no automatic parsing (may be added sometime in future)
// TODO: 0xfe does NOT accurately identify a EOF packet, you have to check that the packet length is < 9 aswel because row-data and other packets use length-coded bytes at the start
state QueryFilter extends Authenticated
{
	function BeginState()
	{
		if (!bAuthenticated)
		{
			Log("Error, an SQLLink must be authenticated with an SQL Server before it can send or filter incoming queries", 'TTF_SQL');
			Close();
		}
	}

	// Handles receiving and storing of all incoming data
	function Tick(float DeltaTime)
	{
		local byte DataBuff[255];
		local byte DataBuffLen;
		local int iTempInt, iTempInt2, i;
		local string DataString;

		if (IsDataPending() && LinkState == STATE_Connected)
		{
			// If new data is arriving after the link has been idle, the info within ResultData should have already been parsed so wipe the array and reset filter variables
			if (!bReceivingData)
			{
				ByteCount = 0;
				bInTargetPacket = False;
				bPendingTargetChange = False;
				bPendingPacketData = False;
				NextPacketPos = 0;

				ResultData.Length = 0;
				bReceivingData = True;

				// temp
				if (bDebugLog)
					DebugResultData.Length = 0;
			}


			if (bDebugLog)
				Log("Receiving data from SQL Server", 'TTF_SQL');


			// Extract the packet data into the ResultData array (filtering out unwanted packets as needed)
			do
			{
				DataBuffLen = ReadBinary(255, DataBuff);
				ByteCount += DataBuffLen;


				// ***
				if (bDebugLog)
				{
					RemoveThisDebugCode = 0;
					DebugResultData.Length = DebugResultData.Length + DataBuffLen;

					for (i=0; i<DataBuffLen; ++i)
						DebugResultData[(DebugResultData.Length-DataBuffLen)+i] = DataBuff[i];
				}
				// ***
					


				// Iterate through all incoming packets within the data buffer
				while (NextPacketPos < ByteCount)
				{
					// If currently parsing the target packet, copy its data before doing checks for new packets
					if (bInTargetPacket && bPendingPacketData)
					{
						iTempInt = Min(255, NextPacketPos - (ByteCount - DataBuffLen));
						ResultData.Length = ResultData.Length + iTempInt;


						for (i=0; i<iTempInt; ++i)
							ResultData[(ResultData.Length-iTempInt)+i] = DataBuff[i];
					}



					// If we are receiving a new packet, check that it's the desired packet
					if (ByteCount > NextPacketPos)
					{
						bPendingPacketData = False;

						// Make sure we have enough incoming data to get the incoming packet size and count (both within packet header, packet header is 4 bytes long)
						// UPDATE: This now includes the result packet type, making a total of 5 bytes
						if (ByteCount - NextPacketPos >= 5)
						{
							if (bPendingTargetChange)
							{
								bInTargetPacket = !bInTargetPacket;
								bPendingTargetChange = False;
							}

							// Check if data has been buffered from last iteration/tick (happens if the packet header is only partially received)
							if (HeaderBuffLen > 0)
							{
								// Complete the buffer
								for (i=0; i+HeaderBuffLen<5; ++i)
									HeaderBuff[HeaderBuffLen+i] = DataBuff[i];


								HeaderBuffLen = 0;

								NextPacketPos += 4 + (HeaderBuff[2] << 16) + (HeaderBuff[1] << 8) + HeaderBuff[0];


								// Check if we should filter out this packet
								if (bInTargetPacket)
								{
									if (HeaderBuff[4] == EndFilter)
									{
										if (bFilterEnd)
										{
											bInTargetPacket = False;
											continue;
										}
										else
										{
											bPendingTargetChange = True;
										}
									}
								}
								else
								{
									if (HeaderBuff[4] == StartFilter)
									{
										if (bFilterStart)
										{
											bPendingTargetChange = True;
											continue;
										}
									}
									else
									{
										continue;
									}
								}


								// Correct packet. If neccessary, copy the header buffer into the result buffer before continuing
								if (!bIgnoreHeader)
								{
									ResultData.Length = ResultData.Length + 5;

									for (i=0; i<5; ++i)
										ResultData[(ResultData.Length-5)+i] = HeaderBuff[i];
								}


								// iTempInt is used below to locate where the new packet starts
								iTempInt = 0;
								i = 0;
							}
							else
							{
								// If it hasn't been buffered, the packet count still needs to be checked and filtered
								iTempInt = NextPacketPos - (ByteCount - DataBuffLen);
								NextPacketPos += 4 + (DataBuff[iTempInt+2] << 16) + (DataBuff[iTempInt+1] << 8) + DataBuff[iTempInt];

								//Log("Packet id:"@DataBuff[iTempInt+4]);


								// Error checking, this can be overriden by the filters
								if (StartFilter != 255 && EndFilter != 255 && DataBuff[iTempInt+4] == 255)
									QueryError(ParseErrorPacket_SA(DataBuff, DataBuffLen));



								if (bInTargetPacket)
								{
									if (DataBuff[iTempInt+4] == EndFilter)
									{
										if (bFilterEnd)
										{
											bInTargetPacket = False;
											continue;
										}
										else
										{
											bPendingTargetChange = True;
										}
									}
								}
								else
								{
									if (DataBuff[iTempInt+4] == StartFilter)
									{
										if (bFilterStart)
										{
											bPendingTargetChange = True;
											continue;
										}
									}
									else
									{
										continue;
									}
								}


								i = int(bIgnoreHeader) * 4;
							}


							// If the code reaches here, it's the correct packet...add the rest of this iteration/packets data to ResultData
							bInTargetPacket = true;
							iTempInt2 = NextPacketPos - (ByteCount - DataBuffLen);


							// If the target packet ends within this iteration then tell the code not to copy the data again in the next iteration
							bPendingPacketData = iTempInt2 >= 255;


							iTempInt2 = Min(255, iTempInt2);
							iTempInt = iTempInt2 - iTempInt;


							ResultData.Length = ResultData.Length + iTempInt;

							for (i=i; i<iTempInt; ++i)
								ResultData[(ResultData.Length-iTempInt)+i] = DataBuff[(iTempInt2-iTempInt)+i];
						}
						// Not enough incoming data for parsing the packet header, buffer the data and wait until the next iteration (and optionally, the next tick)
						else
						{
							HeaderBuffLen = ByteCount - NextPacketPos;
							iTempInt2 = NextPacketPos - (ByteCount - DataBuffLen);


							for (i=0; i<HeaderBuffLen; ++i)
								HeaderBuff[i] = DataBuff[iTempInt2 + i];

							// The current iteration MUST be broken 'manually' in this case...because NextPacketPos is still < ByteCount
							break;
						}
					}
				}
			}
			until (DataBuffLen <= 0)
		}
		else if (bReceivingData)
		{
			// If the link was waiting for more data, but no more data arrives...something is wrong
			if (HeaderBuffLen > 0)
			{
				Log("Data transfer ended before packet was completed, closing connection", 'TTF_SQL');
				Close();

				return;
			}


			// If data was being received last tick, but none is being received this tick...assume that means all incoming data has arrived
			bReceivingData = False;

			//if (bDebugLog)
			//	Log("Data length is:"@ResultData.Length, 'TTF_SQL');


			// ***
			if (bDebugLog)
			{
				RemoveThisDebugCode = 0;

				Log("Debug Data length is:"@DebugResultData.Length, 'TTF_SQL_DEBUG');

				Log("Data:", 'TTF_SQL_DEBUG');

				for (i=4; i<DebugResultData.Length; ++i)
				{
					//Log("Chr:"@DebugResultData[i], 'TTF_SQL_DEBUG');
					DataString $= Chr(DebugResultData[i]);
				}

				Log(DataString, 'TTF_SQL_DEBUG');


				DataString = "";
				Log("Hex Data:", 'TTF_SQL_DEBUG');

				for (i=4; i<DebugResultData.Length; ++i)
				{
					//Log("Hex:"@DebugResultData[i], 'TTF_SQL_DEBUG');
					DataString $= ByteToHex(DebugResultData[i])@"";
				}

				Log(DataString, 'TTF_SQL_DEBUG');
			}
			// ***


			InternalQueryResult();
		}
	}
}

// An slightly easier to understand (yet less efficient) way of parsing packets
// Result packet ID types:
//	0x00 = OK Packet
//	0xff = Error Packet
//	0xfe = End Of File packet
//	0x01-0xfa (i.e. 1-250) = Result-Set, Field or Row-Data packet.
//		^^ Determine which by packet order(i.e. PacketNum), Result-Set comes first, then Field packets, one EOF packet, row data packets, and a final EOF packet)
//		^^ The SetQueryFilter function was specifically made to optimise parsing of these results, SetQueryFilter(0xfe, 0xfe, true, true, true) returns ONLY row data packets

// PacketID = ID of newly parsed packet, PacketNum = number of the parsed packet, StartPos = start position of packet within ResultData, EndPos = Where the packet ends within ResultData,
//	ResultPacketType = Due to difficulty identifying result packet types for packet id's ranging 1-250, you must MANUALLY specify the expected result packets.
//		0 = 'Result Set Header', 1 = 'Field', 2 = 'Row Data'
function array<string> ParseResultPacket(optional out byte PacketID, optional out int PacketNum, optional int StartPos, optional out int EndPos, optional byte ResultPacketType)
{
	local array<string> ReturnVal;
	local int PacketLength, CurPos/*, StrLen*/, i;

	if (ResultData.Length < 4)
	{
		Log("Bad packet size. Not enough data to parse header, size is"@ResultData.Length@"bytes.", 'TTF_SQL');

		// Been getting some really wierd GPF's, don't know if this line solves it or is needed at all but will add it anyway.
		ReturnVal.Length = 0;

		return ReturnVal;
	}

	PacketLength = (ResultData[StartPos+2] << 16) + (ResultData[StartPos+1] << 8) + ResultData[StartPos];
	PacketNum = ResultData[StartPos+3];
	EndPos = StartPos + PacketLength + 4;

	if (PacketLength < 2 || (ResultData.Length - 4) < PacketLength)
	{
		Log("Bad packet size. Specified packet size is"@PacketLength@"bytes while remaining data contains"@(ResultData.Length-4)@"bytes.", 'TTF_SQL');
		ReturnVal.Length = 0;
		return ReturnVal;
	}


	PacketID = ResultData[StartPos+4];

	switch (PacketID)
	{
		// 'OK' packet
		case 0x00:
			ReturnVal.Length = 5;
			CurPos = StartPos + 5;

			// Affected rows (i.e. number of rows modified by insert/update/delete)
			ReturnVal[0] = string(ReadCodedInt(CurPos));

			// Insert ID (i.e. value given to an AUTO_INCREMENT column by the insert command), if the value was 64bit ReadCodedInt returns 0
			ReturnVal[1] = string(ReadCodedInt(CurPos));

			// Server status (just two bytes)
			ReturnVal[2] = string((ResultData[CurPos+1] << 8) + ResultData[CurPos]);

			// Warning count
			ReturnVal[3] = string((ResultData[CurPos+3] << 8) + ResultData[CurPos+2]);

			CurPos += 5;

			// Message
			ReturnVal[4] = ReadCodedString(CurPos);

			break;


		// 'Error' packet
		case 0xff:
			ReturnVal.Length = 2;

			// Error number
			ReturnVal[0] = string((ResultData[StartPos+6] << 8) + ResultData[StartPos+5]);

			// SQLState (a different error number)
			ReturnVal[1] = Chr(ResultData[StartPos+7])$Chr(ResultData[StartPos+8])$Chr(ResultData[StartPos+9])$Chr(ResultData[StartPos+10])$Chr(ResultData[StartPos+11])$
					Chr(ResultData[StartPos+12]);

			// Message
			for (i=StartPos+13; i<Min(EndPos, ResultData.Length); ++i)
				ReturnVal[2] $= Chr(ResultData[i]);

			break;


		// 'End Of File' packet
		case 0xfe:
			// Not an EOF packet
			if (PacketLength >= 9)
				Goto 'def';

			ReturnVal.Length = 2;

			// Warning count
			ReturnVal[0] = string((ResultData[StartPos+6] << 8) + ResultData[StartPos+5]);

			// Status flags
			ReturnVal[1] = string((ResultData[StartPos+8] << 8) + ResultData[StartPos+7]);

			break;

		// Could be a 'Result Set Header' packet, a 'Field' packet or a 'Row Data' packet
		def:
		default:

			// TODO:
			switch (ResultPacketType)
			{
				// 'Result Set Header' packet
				case 0x00:
					ReturnVal.Length = 2;
					CurPos = StartPos + 4;

					// Field count
					ReturnVal[0] = string(ReadCodedInt(CurPos));

					// Random extra data
					ReturnVal[1] = string(ReadCodedInt(CurPos));

					break;


				// 'Field' packet
				case 0x01:
					ReturnVal.Length = 11;
					CurPos = StartPos + 4;

					// Catalog
					ReturnVal[0] = ReadCodedString(CurPos);

					// Database ID
					ReturnVal[1] = ReadCodedString(CurPos);

					// Table ID
					ReturnVal[2] = ReadCodedString(CurPos);

					// Original table ID
					ReturnVal[3] = ReadCodedString(CurPos);

					// Name (column ID?)
					ReturnVal[4] = ReadCodedString(CurPos);

					// Original name
					ReturnVal[5] = ReadCodedString(CurPos);

					// Character set num
					ReturnVal[6] = string((ResultData[CurPos+1] << 8) + ResultData[CurPos]);

					// Column length
					ReturnVal[7] = string((ResultData[CurPos+5] << 24) + (ResultData[CurPos+4] << 16) + (ResultData[CurPos+3] << 8) + ResultData[CurPos+2]);

					// Column data type
					ReturnVal[8] = string(ResultData[CurPos+6]);

					// Flags(?)
					ReturnVal[9] = string((ResultData[CurPos+8] << 8) + ResultData[CurPos+7]);

					// Decimals(?)
					ReturnVal[10] = string(ResultData[CurPos+9]);


					break;

				// 'Row Data' packet
				case 0x02:
					CurPos = StartPos + 4;

					// Column values
					while (CurPos < StartPos + 4 + PacketLength)
						ReturnVal[ReturnVal.Length] = ReadCodedString(CurPos);

					break;
			}
	}

	return ReturnVal;
}

// Returns the ID of a packet, StartPos must be set to the start of a packets header (if set at all)
function byte ParseResultPacketID(optional int StartPos)
{
	if (ResultData.Length-StartPos-1 < 5)
	{
		Log("Invalid start position, StartPos is"@StartPos@"while data length is"@ResultData.Length$", at least 5 bytes of data needed", 'TTF_SQL');
		return 0;
	}

	return ResultData[StartPos+4];
}

function int ParsePacketLength(optional int StartPos)
{
	if (ResultData.Length-StartPos-1 < 3)
	{
		Log("Invalid start position, StartPos is"@StartPos@"while data length is"@ResultData.Length$", at least 3 bytes of data needed", 'TTF_SQL');
		return 0;
	}

	return (ResultData[StartPos+2] << 16) + (ResultData[StartPos+1] << 8) + ResultData[StartPos];
}

// Used mainly by ParseResultPacket, StartPos is an out variable because the position has to be displaced
final function int ReadCodedInt(out int StartPos)
{
	if (ResultData.Length-StartPos < 1)
	{
		Log("Invalid start position, StartPos is"@StartPos@"while data length is"@ResultData.Length$", at least 1 byte of data needed", 'TTF_SQL');
		return 0;
	}

	if (ResultData[StartPos] < 251)
	{
		++StartPos;
		return ResultData[StartPos-1];
	}

	if (ResultData[StartPos] == 251)
	{
		++StartPos;
		return 0;
	}

	if (ResultData[StartPos] == 252)
	{
		StartPos += 3;
		return (ResultData[StartPos-1] << 8) + ResultData[StartPos-2];
	}

	if (ResultData[StartPos] == 253)
	{
		StartPos += 5;
		return (ResultData[StartPos-1] << 32) + (ResultData[StartPos-2] << 16) + (ResultData[StartPos-3] << 8) + ResultData[StartPos-4];
	}

	// Can't parse 64bit integers
	StartPos += 9;
	return 0;
}

final function string ReadCodedString(out int StartPos)
{
	local int i, StrLen;
	local string ReturnString;

	StrLen = ReadCodedInt(StartPos);

	if (StartPos + StrLen > ResultData.Length)
	{
		Log("Reached end of data buffer while parsing 'OK' packet, final position:"@(StartPos+StrLen)$", buffer length:"@ResultData.Length, 'TTF_SQL');
		return "";
	}

	for (i=0; i<StrLen; ++i)
		ReturnString $= Chr(ResultData[StartPos+i]);

	StartPos += StrLen;

	return ReturnString;
}

// Parses an error packet from a static array (must include packet header)
static final function string ParseErrorPacket_SA(byte B[255], int Count)
{
	local int ErrorNum, i;
	local string SQLState, ErrorMsg;;

	ErrorNum = (B[6] << 8) + B[5];

	SQLState = "#"$Chr(B[8])$Chr(B[9])$Chr(B[10])$Chr(B[11])$Chr(B[12]);

	for (i=13; i<Count; ++i)
		ErrorMsg $= Chr(B[i]);

	return "("$ErrorNum$", "$SQLState$"):"@ErrorMsg;
}

static final function string ParseErrorPacket(array<byte> B)
{
	local int ErrorNum, i;
	local string SQLState, ErrorMsg;;

	ErrorNum = (B[6] << 8) + B[5];

	SQLState = "#"$Chr(B[8])$Chr(B[9])$Chr(B[10])$Chr(B[11])$Chr(B[12]);

	for (i=13; i<B.Length; ++i)
		ErrorMsg $= Chr(B[i]);

	return "("$ErrorNum$", "$SQLState$"):"@ErrorMsg;
}


// Helper function for debug logging
static final function string ByteToHex(byte B)
{
	local byte H;
	local string ReturnString;

	H = B >> 4;
	B = B & 0xf;

	if (H > 9)
		ReturnString = Chr(55+H);
	else
		ReturnString $= H;

	if (B > 9)
		return ReturnString$Chr(55+B);
	else
		return ReturnString$B;
}

defaultproperties
{
	bDebugLog=False
}