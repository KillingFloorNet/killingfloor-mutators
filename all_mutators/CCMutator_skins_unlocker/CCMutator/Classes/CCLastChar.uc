class CCLastChar extends Object config;

var config String LastChar;

function SetLastChar(string sChar)
{
LastChar = sChar;
saveconfig();
}

function string GetLastChar()
{
return LastChar;
}

defaultproperties
{
}
