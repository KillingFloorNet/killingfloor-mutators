class VSLoginMenu extends KFInvasionLoginMenu;

function bool NotifyLevelChange() // We want to get ride of this menu!
{
	bPersistent = false;
	return true;
}
function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	Panels[0].ClassName = string(Class'VSLoginControls');
	Super(UT2K4PlayerLoginMenu).InitComponent(MyController, MyComponent);
}

defaultproperties
{
}
