XIncludeFile "GameObject.pbi"

EnableExplicit

Structure TGameActor Extends TGameObject
  Frozen.a
  FrozenTimer.f
  ShootingFreezingShots.a
EndStructure

Procedure GameActorInit(*GameActor.TGameActor)
  *GameActor\Frozen = #False
  *GameActor\FrozenTimer = 0.0
  *GameActor\ShootingFreezingShots = #False
EndProcedure

Procedure GameActorUpdate(*GameActor.TGameActor, TimeSlice.f)
  ;TODO: implement the freezing here, probably making the velocity 0
  
EndProcedure



DisableExplicit
