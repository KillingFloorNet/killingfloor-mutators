Class CrossH_interaction extends Interaction;
 
var float xPos, yPos;

function PostRender( canvas Canvas )
{
	Canvas.SetPos(Canvas.SizeX*xPos, Canvas.SizeY*yPos);
	//Canvas.Style=5;
	//Canvas.ColorModulate.W = 0.5;
	Canvas.SetDrawColor(0,255,0);
	Canvas.DrawColor.A = 100;
	Canvas.DrawLine(3, 5.000000);
	Canvas.DrawLine(1, 5.000000);
	Canvas.DrawLine(2, 3.000000);
	Canvas.DrawLine(0, 3.000000);
	Canvas.ColorModulate.W = 1.0;
}

defaultproperties
{
	XPos=0.499000
	YPos=0.499000
	bVisible=True
}