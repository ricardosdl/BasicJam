XIncludeFile "Math.pbi"

EnableExplicit

Prototype UpdateGameObjectProc(*GameObject, TimeSlice.f)
Prototype DrawGameObjectProc(*GameObject)

Structure TGameObject
  Position.TVector2D
  LastPosition.TVector2D
  OriginalWidth.u
  OriginalHeight.u
  ZoomFactor.f
  Width.u
  Height.u
  
  SpriteNum.i
  
  Acceleration.TVector2D
  Velocity.TVector2D
  MaxVelocity.TVector2D
  Drag.TVector2D
  
  UpdateGameObject.UpdateGameObjectProc
  DrawGameObject.DrawGameObjectProc
  
  Active.a
  
  
  
EndStructure


Procedure InitGameObject(*GameObject.TGameObject, *Position.TVector2D, OriginalWidth.u,
                         OriginalHeight.u, SpriteNum.i, *UpdateProc.UpdateGameObjectProc,
                         *DrawProc.DrawGameObjectProc, Active.a, ZoomFactor.f = 1.0)
  
  *GameObject\Position\x = *Position\x
  *GameObject\Position\y = *Position\y
  *GameObject\OriginalWidth = OriginalWidth
  *GameObject\OriginalHeight = OriginalHeight
  *GameObject\ZoomFactor = ZoomFactor
  *GameObject\Width = OriginalWidth * ZoomFactor
  *GameObject\Height = OriginalHeight * ZoomFactor
  *GameObject\SpriteNum = SpriteNum
  ZoomSprite(*GameObject\SpriteNum, OriginalWidth * ZoomFactor, OriginalHeight * ZoomFactor)
  
  *GameObject\UpdateGameObject = *UpdateProc
  *GameObject\DrawGameObject = *DrawProc
  
  *GameObject\Active = Active
  
  
  
  
EndProcedure

Procedure DrawGameObject(*GameObject.TGameObject)
  DisplayTransparentSprite(*GameObject\SpriteNum, Int(*GameObject\Position\x), Int(*GameObject\Position\y))
EndProcedure





DisableExplicit