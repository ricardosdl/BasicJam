XIncludeFile "GameObject.pbi"

EnableExplicit

Structure TGameActor Extends TGameObject
  Frozen.a
  FrozenTimer.f
EndStructure

Procedure GameActorInit(*GameActor.TGameActor)
  *GameActor\Frozen = #False
  *GameActor\FrozenTimer = 0.0
EndProcedure



DisableExplicit
