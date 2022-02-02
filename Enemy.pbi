IncludeFile "GameObject.pbi"

EnableExplicit

Structure TEnemy Extends TGameObject
  *Player.TGameObject
EndStructure

Procedure InitEnemy(*Enemy.TEnemy, *Player.TGameObject)
  *Enemy\Player = *Player
  
EndProcedure


Procedure InitBananaEnemy(*BananaEnemy.TEnemy, *Player.TGameObject, *Position.TVector2D,
                          SpriteNum.i)
  
  InitEnemy(*BananaEnemy, *Player)
  
  InitGameObject(*BananaEnemy, *Position, 
  
  *Position.TVector2D, OriginalWidth.u,
                         OriginalHeight.u, SpriteNum.i, *UpdateProc.UpdateGameObjectProc,
                         *DrawProc.DrawGameObjectProc, ZoomFactor.f = 1.0
  
  
  
  
EndProcedure




DisableExplicit