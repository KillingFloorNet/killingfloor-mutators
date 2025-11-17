class ACWebQueryDefaults extends xWebQueryDefaults;

function QueryDefaultsIPPolicy(WebRequest Request, WebResponse Response)
{
	local int i, j;
	local bool bIpBan;
	local string policies, tmpN, tmpV;
	local string PolicyType;
	local AdminControlMut ACMutator;

	if (CanPerform("Xi"))
	{
		ACMutator = class'AdminControlMut'.Static.GetSelf(Spectator);
		Response.Subst("Section", DefaultsIPPolicyLink);
		if (Request.GetVariable("Update") != "")
		{
			i = int(Request.GetVariable("IpNo", "-1"));
			//if _RO_
			tmpN = Request.GetVariable("IPMask");
			if (ValidMask(tmpN))
			{
			    if(i > -1)
			    {
			//else
			//if(i > -1 && ValidMask(Request.GetVariable("IPMask")))
			//{
			//end _RO_
    				if (i >= Level.Game.AccessControl.IPPolicies.Length)
    				{
    					i = Level.Game.AccessControl.IPPolicies.Length;
    					Level.Game.AccessControl.IPPolicies.Length = i+1;
    				}
				    Level.Game.AccessControl.IPPolicies[i] = Request.GetVariable("AcceptDeny")$";"$Request.GetVariable("IPMask");
    				Level.Game.AccessControl.SaveConfig();
					ACMutator.TrackBan(Level.Game.AccessControl.IPPolicies[i],CurAdmin);
					ACMutator.IncreaseBanCount(CurAdmin);
    			}
			}
			//if _RO_
			else if (Level.Game.AccessControl.CheckID(tmpN) == 0)
		    {
    			i = Level.Game.AccessControl.BannedIDs.Length;
			    Level.Game.AccessControl.BannedIDs.Length = i+1;
				Level.Game.AccessControl.BannedIDs[i] = tmpN @ "WebAdminBan";
				Level.Game.AccessControl.SaveConfig();
				ACMutator.RegisterBan(CurAdmin,tmpN,"WebAdminBan",-1);
				ACMutator.IncreaseBanCount(CurAdmin);
				//ACMutator.TrackBan(Level.Game.AccessControl.BannedIDs[i],CurAdmin);
			}
			//end _RO_
		}

		if(Request.GetVariable("Delete") != "")
		{
			i = int(Request.GetVariable("IdNo", "-1"));
			if (i == -1)
			{
				bIpBan = True;
				i = int(Request.GetVariable("IpNo", "-1"));
			}

			if (i > -1)
			{
				if ( bIpBan && i < Level.Game.AccessControl.IPPolicies.Length )
				{
					ACMutator.TrackUnban(Level.Game.AccessControl.IPPolicies[i],CurAdmin);
					Level.Game.AccessControl.IPPolicies.Remove(i,1);
					Level.Game.AccessControl.SaveConfig();
				}

				if ( !bIpBan && i < Level.Game.AccessControl.BannedIDs.Length )
				{
					ACMutator.TrackUnban(Level.Game.AccessControl.BannedIDs[i],CurAdmin);
					Level.Game.AccessControl.BannedIDs.Remove(i,1);
					Level.Game.AccessControl.SaveConfig();
				}
			}
		}

		Policies = "";
		if (Level.Game.AccessControl.bBanById)
		{
			for (i = 0; i < Level.Game.AccessControl.BannedIds.Length; i++)
			{
				j = InStr(Level.Game.AccessControl.BannedIDs[i], " ");
				tmpN = Mid(Level.Game.AccessControl.BannedIDs[i], j + 1);
				tmpV = Left(Level.Game.AccessControl.BannedIDs[i], j);

				Response.Subst("PolicyType", IDBan);
				Response.Subst("PolicyCell", tmpN $ ":" @ tmpV $ "&nbsp;&nbsp;");
				Response.Subst("PostAction", DefaultsIPPolicyPage $ "?IDNo="$string(i));
				Response.Subst("UpdateButton", "");
				Policies = Policies $ WebInclude(DefaultsIPPolicyPage $ "_row");
			}
		}

		for(i=0; i<Level.Game.AccessControl.IPPolicies.Length; i++)
		{
			Divide( Level.Game.AccessControl.IPPolicies[i], ";", tmpN, tmpV );

			PolicyType = RadioButton("AcceptDeny", "ACCEPT", tmpN ~= "ACCEPT") @ Accept $ "<br>";
			PolicyType = PolicyType $ RadioButton("AcceptDeny", "DENY", tmpN ~= "DENY") @ Deny;

			Response.Subst("PolicyType", PolicyType);
			Response.Subst("PolicyCell", Textbox("IPMask", 15, 25, tmpV) $ "&nbsp;&nbsp;");
			Response.Subst("PostAction", DefaultsIPPolicyPage $ "?IpNo="$string(i));
			Response.Subst("UpdateButton", SubmitButton("Update", Update));
			Policies = Policies $ WebInclude(DefaultsIPPolicyPage $ "_row");
		}

		Response.Subst("Policies", policies);
		Response.Subst("PostAction", DefaultsIPPolicyPage$"?IpNo="$string(i));
		Response.Subst("PageHelp", NotePolicyPage);
		ShowPage(Response, DefaultsIPPolicyPage);
	}
	else
		AccessDenied(Response);
}

defaultproperties
{
}
