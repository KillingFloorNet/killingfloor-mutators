//=============================================================================
// UTRUtils.
//
// Author: Francesco Biscazzo
// Date: 2019
// ©copyright Francesco Biscazzo. All rights reserved.
//
// Description: Generally static functions.
//=============================================================================
class UTRUtils extends Info;

var float smallFontAt, mediumFontAt, bigFontAt, largeFontAt;

/*
 *	Return this class's package name.
 */
static function String getPackageName(Object object) {
	return Left(object.default.class, InStr(object.default.class, "."));
}

static function String getClassName(Object object) {
	return Right(object.default.class, Len(object.default.class) - (InStr(object.default.class, ".") + 1));
}

/*
 *	Map x from the range inMin-inMax to the range outMin-outMax and return the result.
 */
static function float map(float x, float inMin, float inMax, float outMin, float outMax) {
  return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

/*
 *	Map x from the range inMin-inMax to the range startColor-endColor and return the resulting color.
 */
static function Color mapToColor(float x, float inMin, float inMax, Color startColor, Color endColor) {
	local Color color;
	
	color.r = map(x, inMin, inMax, startColor.r, endColor.r);
	color.g = map(x, inMin, inMax, startColor.g, endColor.g);
	color.b = map(x, inMin, inMax, startColor.b, endColor.b);
	
	return color;
}

/*
 * Return the string from the parameter from the given position.
 * Return an empty string if no string is found.
 */
static function String getStringParameter( String Parameters, int ParameterNum, bool bToLastParam )
{
	local int wordCount;
	local String MultipleStrings;
	local bool bFirstTime;
	
	if (Parameters != "")
	{
		if (InStr(Parameters, " ") != -1)
		{
			bFirstTime = true;

			if (!bToLastParam)
				MultipleStrings = FindParameter(Parameters, " ", ParameterNum, false);
			else
			{
				wordCount = ParameterNum;
				MultipleStrings = "";
				while (wordCount != -1)
				{
					if (FindParameter(Parameters, " ", wordCount, false) != "")
					{
						if (bFirstTime)
						{
							MultipleStrings = FindParameter(Parameters, " ", wordCount, false);
						}
						else
							MultipleStrings = MultipleStrings@FindParameter(Parameters, " ", wordCount, false);
						wordCount++;
					}
					else
						wordCount = -1;
					bFirstTime = false;
				}	
			}
		}
		else
			MultipleStrings = Parameters;
	}
	
	return MultipleStrings;
}

/*
 * Parse a string into a float, taking the string from the parameter from the given position.
 * Return -1 if the parse gone wrong.
 */
static function float getFloatParameter( String Parameters, float ParameterNum )
{
	if (FindParameter(Parameters, " ", ParameterNum, false) == "")
		return -1;
	else
		return float(FindParameter(Parameters, " ", ParameterNum, false));
}

/*
 * Split a string and return the string from the given position. If no string was found in the
 * given position, return an empty string.
 *
 * @Parameters = the string to split.
 * @div = the string to interpret as divider.
 * @bDiv = true to keep dividers, false to remove dividers.
 */
static function String FindParameter(String Parameters, String div, int ParameterNum, bool bDiv)
{
   local bool bEOL;
   local String tempChar;
   local int precount, curcount, wordcount, ParametersLength;
   
   local String word;
   
   if (Parameters != "")
   {
		if (InStr(Parameters, div) != -1)
		{
			ParametersLength = Len(Parameters);
			bEOL = false;
			precount = 0;
			curcount = 0;
			wordcount = 0;
			
			while(!bEOL)
			{
				tempChar = Mid(Parameters, curcount, 1); //go up by 1 count
				if(tempChar != div)
					curcount++;
				else if(tempChar == div)
				{
					if (wordcount == ParameterNum)
					{
						word = Mid(Parameters, precount, curcount - precount);
						break;
					}
					wordcount++;
					if(bDiv)
						precount = curcount; //leaves the divider
					else
						precount = curcount + 1; //removes the divider.
					curcount++;
				}
				if(curcount == ParametersLength)//end of Parameters string.
				{
					if (wordcount == ParameterNum)
						word = Mid(Parameters, precount);
					bEOL = true;
				}
			}
		}
		else
			word = Parameters;
	}
	
	return word;
}

static function Font getFont(float minClip, optional bool bSmaller, optional bool bBigger) {
	local Font font;
	
	if (minClip < default.mediumFontAt) {
		if (!bBigger)
			font = class'Canvas'.default.smallFont;
		else
			font = class'Canvas'.default.MedFont;
	} else if (minClip < default.bigFontAt) {
		if (bSmaller)
			font = class'Canvas'.default.SmallFont;
		else if (bBigger)
			font = class'Canvas'.default.BigFont;
		else
			font = class'Canvas'.default.MedFont;
	} else if (minClip < default.largeFontAt) {
		if (bSmaller)
			font = class'Canvas'.default.MedFont;
		else if (bBigger)
			font = class'Canvas'.default.LargeFont;
		else
			font = class'Canvas'.default.BigFont;
	} else {
		if (!bSmaller)
			font = class'Canvas'.default.LargeFont;
		else
			font = class'Canvas'.default.BigFont;
	}
		
	return font;
}

static function triggerActorsWithTag(String triggerTag, LevelInfo level, optional Actor other, optional Pawn eventInstigator) {
	local Actor actor;
	
	foreach level.allActors(class'Actor', actor) {
		if (String(actor.tag) == triggerTag)
			actor.trigger(other, eventInstigator);
	}
}

static function untriggerActorsWithTag(String triggerTag, LevelInfo level, optional Actor other, optional Pawn eventInstigator) {
	local Actor actor;
	
	foreach level.allActors(class'Actor', actor) {
		if (String(actor.tag) == triggerTag)
			actor.untrigger(other, eventInstigator);
	}
}

defaultproperties {
	smallFontAt=270
	mediumFontAt=540
	bigFontAt=1080
	largeFontAt=2160
}