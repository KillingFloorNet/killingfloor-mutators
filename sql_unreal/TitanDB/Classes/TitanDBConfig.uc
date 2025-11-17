//============================================================
// TitanDBConfig.uc	- Database configuration
//============================================================
//	TitanDB
//		- A central database management package for the TitanAdminHax tool
//
//	Copyright (C) 2008 John "Shambler" Barrett (JBarrett847@Gmail.com or Shambler@OldUnreal.com)
//
//	This program is free software; you can redistribute and/or modify
//	it under the terms of the Open Unreal Mod License version 1.1.
//
//============================================================
//
// Mainly for determining which type of database to use
//
//============================================================
Class TitanDBConfig extends object
	config(TitanDatabase)
	abstract;


// Determines the type of database to use
enum EDatabaseType
{
	DT_Runtime,				// Data is stored in memory, and is lost when the server restarts
	DT_Config,				// Data is stored in the .ini file (performance steadily decreases over time)
	//DT_MySQL				// Data is stored and recovered from a MySQL database (relatively fast)
};

var config EDatabaseType	DatabaseType;	// Determines the type of database to use
var config bool bINIExists;


defaultproperties
{
	DatabaseType=DT_Config
}