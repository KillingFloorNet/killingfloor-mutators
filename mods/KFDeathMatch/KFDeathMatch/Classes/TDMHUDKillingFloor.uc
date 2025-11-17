class TDMHUDKillingFloor extends DMHUDKillingFloor;

simulated function DrawKFHUDTextElements(Canvas C);

simulated function DrawEndGameHUD(Canvas C, bool bVictory)
{
	C.SetDrawColor(255, 255, 255, 255);
	C.Font = LoadFont(1);
	C.SetPos(0,C.ClipY*0.7f);
	C.bCenter = true;
	if( TeamInfo(KFGRI.Winner)==None )
		C.DrawText(LostMatchStr,false);
	else if( TeamInfo(KFGRI.Winner).TeamIndex==0 )
		C.DrawText("Red Team"$OtherWinnerStr,false);
	else C.DrawText("Blue Team"$OtherWinnerStr,false);
	C.bCenter = false;
	if ( bShowScoreBoard && ScoreBoard != None )
		ScoreBoard.DrawScoreboard(C);
}

defaultproperties
{
}
