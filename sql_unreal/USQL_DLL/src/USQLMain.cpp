#include "USQLProjectPrivate.h"


IMPLEMENT_PACKAGE(USQL); 

IMPLEMENT_CLASS(AUSQLDB); 


AUSQLDB::AUSQLDB()
{
	ServerPointer = NULL;//null the fucker out
	ResultPointer = NULL;
}
/*~AUSQLDB::AUSQLDB()
{
	ServerPointer = NULL; // FUCK OFF NULL POS
}*/


inline sql::SQLString TCHARToSQLString( const TCHAR* F )//Unicode to ANSI
{
	return sql::SQLString(appToAnsi(F));
}

inline const TCHAR* SQLStringToTCHAR(sql::SQLString* SQLString)//ANSI to Unicode
{
	return appFromAnsi(SQLString->c_str());
}
//===================
// Start .:..: ownage
//===================
#define P_GET_REFP(Type,Name) Stack.Step( Stack.Object, NULL ); Type* Name=(Type*)GPropAddr;

#define StartIterator \
	INT wEndOffset = Stack.ReadWord(); \
	BYTE B=0, Buffer[MAX_CONST_SIZE]; \
	BYTE *StartCode = Stack.Code;

#define EndIterator \
	Stack.Code = &Stack.Node->Script(wEndOffset + 1);

#define LoopIterator( BreakType ) \
	while( (B=*Stack.Code)!=EX_IteratorPop && B!=EX_IteratorNext ) \
		Stack.Step( Stack.Object, Buffer ); \
	if( *Stack.Code++==EX_IteratorNext ) \
		Stack.Code = StartCode; \
	if( B==EX_IteratorPop ) \
		BreakType;

#define BeginSQL try {
#define EndSQL(Func) \
	} \
	catch (sql::SQLException &e) \
	{ \
		Stack.Logf(TEXT("SQL exception in %s, (%s) on line %d)"),appFromAnsi(__FILE__),appFromAnsi(__FUNCTION__),__LINE__); \
		Stack.Logf(TEXT("Err %s (MySQL error code : %d, SQLState %s"),appFromAnsi(e.what()),e.getErrorCode(),appFromAnsi(e.getSQLStateCStr())); \
		Func; \
	}

//===================
// End .:..: ownage
//===================
void AUSQLDB::execGetQueries( FFrame& Stack, RESULT_DECL )
{
	P_GET_REFP(TArray<FString>,QueryString); //.:..: ownage!!!!!!!!
	P_GET_UBOOL(bReverse);
	P_FINISH;
	
	
	INT NumColumns=0;
	sql::ResultSet* Res = NULL;
	if(ResultPointer)
	{
		Res = (sql::ResultSet*) ResultPointer;
		NumColumns = Res->getMetaData()->getColumnCount();
	}
	StartIterator;//start dots ownerator
	BeginSQL;
	if(!bReverse)
	{
		while (Res->next())
		{
			QueryString->Empty();
			for(int i = 0; i<NumColumns; i++)
			{
				new(*QueryString)FString(SQLStringToTCHAR(&Res->getString(i+1)));
			}
			LoopIterator(return);//dots ownage loop
		}
	}
	else
	{
		Res->afterLast();
		while (Res->previous())
		{
			QueryString->Empty();
			for(int i = 0; i<NumColumns; i++)
			{
				new(*QueryString)FString(SQLStringToTCHAR(&Res->getString(i+1)));
			}
			LoopIterator(return);//dots ownage loop
		}
	}
	EndSQL(ServerPointer=NULL;ResultPointer=NULL;);

	EndIterator;//end dots ownerator
}

IMPLEMENT_FUNCTION( AUSQLDB, -1, execGetQueries );

void AUSQLDB::execSQLServerConnect( FFrame& Stack, RESULT_DECL )
{
	guard(AUSQLDB::execSQLServerConnect);
	P_GET_STR(IP);
	P_GET_STR(USER);
	P_GET_STR(PASSWORD);
	P_FINISH;
	sql::Driver *driver;


	FString F = FString::Printf(TEXT("tcp://%s"),*IP);

	BeginSQL;

	driver = get_driver_instance();
	ServerPointer = driver->connect(TCHARToSQLString(*F),TCHARToSQLString(*USER),TCHARToSQLString(*PASSWORD));
	*(UBOOL *) Result = true;

	EndSQL(ServerPointer = NULL; *(UBOOL *) Result = false;);
	unguard;
}

IMPLEMENT_FUNCTION( AUSQLDB, -1, execSQLServerConnect );

void AUSQLDB::execSQLExecute( FFrame& Stack, RESULT_DECL )
{
	guard(AUSQLDB::execSQLExecute);
	P_GET_STR(Command);
	P_FINISH;

	BeginSQL;

	if(ServerPointer)
	{
		sql::Statement *stmt = ((sql::Connection*) ServerPointer)->createStatement();
		*(UBOOL *) Result = stmt->execute(TCHARToSQLString(*Command));
	}
	else *(UBOOL *) Result = false; //bs

	EndSQL(ServerPointer = NULL; *(UBOOL *) Result = false;);
	unguard;
}

IMPLEMENT_FUNCTION( AUSQLDB, -1, execSQLExecute );

void AUSQLDB::execSQLExecuteQuery( FFrame& Stack, RESULT_DECL )
{
	guard(AUSQLDB::execSQLExecuteQuery);
	P_GET_STR(Command);
	P_FINISH;

	BeginSQL;

	if(ServerPointer)
	{
		sql::Statement *stmt = ((sql::Connection*) ServerPointer)->createStatement();
		
		ResultPointer = stmt->executeQuery(TCHARToSQLString(*Command));
		if(ResultPointer)
			*(UBOOL *) Result = true;
		else *(UBOOL *) Result = false;
	}
	else *(UBOOL *) Result = false; //it's bs

	EndSQL(ServerPointer = NULL;ResultPointer = NULL; *(UBOOL *) Result = false;);

	unguard;
}

IMPLEMENT_FUNCTION( AUSQLDB, -1, execSQLExecuteQuery );