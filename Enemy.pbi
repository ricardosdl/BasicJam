XIncludeFile "GameObject.pbi"

EnableExplicit

Structure TEnemy Extends TGameObject
  *Player.TGameObject
EndStructure

Procedure InitEnemy(*Enemy.TEnemy, *Player.TGameObject)
  *Enemy\Player = *Player
  
EndProcedure


Procedure InitBananaEnemy(*BananaEnemy.TEnemy, *Player.TGameObject, *Position.TVector2D,
                          SpriteNum.i, ZoomFactor.f)
  
  InitEnemy(*BananaEnemy, *Player)
  
  InitGameObject(*BananaEnemy, *Position, 8, 8, SpriteNum, #Null, @DrawGameObject(), #True, ZoomFactor)
  
  ;some initialization for the bananaenemy
  
  
  
  
EndProcedure




DisableExplicit