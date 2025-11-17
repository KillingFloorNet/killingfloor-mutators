class SummoneableZombieClot extends ZombieClot_STANDARD;


var private float cloakStateChangeTime; //Time interval between cloak state changes
var private float nextCloakStateChangeTime; //Time when next cloak state change will take place


replication
{
  reliable if(bNetInitial && (Role < ROLE_Authority))
    cloakStateChangeTime;
  reliable if(Role == ROLE_Authority)
    nextCloakStateChangeTime;
}


simulated function PostBeginPlay()
{
  if (level.netMode != NM_DedicatedServer)
    cloak();
  super.PostBeginPlay();
  if (level.netMode != NM_DedicatedServer)
    setNextCloakStateChangeTime();
}


simulated function setNextCloakStateChangeTime()
{
  nextCloakStateChangeTime = Level.TimeSeconds + cloakStateChangeTime;
}

simulated function cloak()
{
  if (level.netMode == NM_DedicatedServer)
    return;

  Skins[0] = Material'KFX.FBDecloakShader';
  bSpotted = false;
  bCloaked = true;
  bUnlit = false;
  Projectors.Remove(0, Projectors.Length);
  bAcceptsProjectors = false;
}


simulated function semiUncloak()
{
  if (level.netMode == NM_DedicatedServer)
    return;

  Skins[0] = Finalblend'KFX.StalkerGlow';
  Skins[1] = Finalblend'KFX.StalkerGlow';
  bSpotted = true;
  bUnlit = true;
}


simulated function uncloak()
{
  if (level.netMode == NM_DedicatedServer)
    return;

  bCloaked = false;
  bUnlit = false;
  if (Skins.Length > 1)
    Skins.Remove(1,1);
  if (Skins[0] != Combiner'KF_Specimens_Trip_T.clot_cmb')
  {
    Skins[0] = Combiner'KF_Specimens_Trip_T.clot_cmb';
    bAcceptsProjectors = true;
  }
}


// srub function for states
function nextCloakedState();


simulated function tick(float deltaTime)
{
  super.tick(DeltaTime);

  if (Level.NetMode == NM_DedicatedServer)
    return;
  if (bCloaked && Level.TimeSeconds > nextCloakStateChangeTime)
    nextCloakedState();
}


auto state invisibleCloak
{
  simulated function nextCloakedState()
  {
    GotoState('semiInvisibleCloak');
  }
}


state semiInvisibleCloak
{
  simulated function nextCloakedState()
  {
    GotoState('visibleCloak');
  }

  simulated function BeginState()
  {
    semiUncloak();
    setNextCloakStateChangeTime();
  }
}


state visibleCloak
{
  simulated function BeginState()
  {
    uncloak();
    setNextCloakStateChangeTime();
  }
}


defaultproperties
{
  cloakStateChangeTime=0.50
}