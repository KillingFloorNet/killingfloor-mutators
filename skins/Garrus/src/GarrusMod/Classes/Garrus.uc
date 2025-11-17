class Garrus extends PlayerRecordClass;

#exec OBJ LOAD FILE=..\animations\GarrusA.ukx
#exec OBJ LOAD FILE=..\textures\GarrusT.utx

defaultproperties
{
     Species=Class'GarrusMod.GarrusSpecies'
     MeshName="GarrusA.Garrus"
     BodySkinName="GarrusT.eyeball"
     FaceSkinName="GarrusT.Visor_Frame"
     Portrait=Texture'GarrusT.garrus_portrait'
     TextName="Garrus Vakarian is a turian, formerly part of C-Sec's Investigation Division."
     VoiceClassName="KFMod.KFVoicePack"
     Sex="Male"
     Menu="SP"
     Skeleton="KFSoldiers.Soldier"
     Ragdoll="British_Soldier1"
}
