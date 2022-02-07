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

Procedure GetSpriteOriginalWidthAndHeight(SpriteNum.i, *OriginalWidth.Integer, *OriginalHeight.Integer)
  ;saves the current width and height
  Protected CurrentWidth, CurrentHeight
  CurrentWidth = SpriteWidth(SpriteNum)
  CurrentHeight = SpriteHeight(SpriteNum)
  
  ;restore the orignal dimensions
  ZoomSprite(SpriteNum, #PB_Default, #PB_Default)
  
  *OriginalWidth\i = SpriteWidth(SpriteNum)
  *OriginalHeight\i = SpriteHeight(SpriteNum)
  
  ;restore the current dimensions
  ZoomSprite(SpriteNum, CurrentWidth, CurrentHeight)
  
  
EndProcedure


Procedure InitGameObject(*GameObject.TGameObject, *Position.TVector2D, SpriteNum.i,
                         *UpdateProc.UpdateGameObjectProc, *DrawProc.DrawGameObjectProc,
                         Active.a, ZoomFactor.f = 1.0)
  
  *GameObject\Position\x = *Position\x
  *GameObject\Position\y = *Position\y
  
  
  Protected OriginalWidth.Integer, OriginalHeight.Integer
  GetSpriteOriginalWidthAndHeight(SpriteNum, @OriginalWidth, @OriginalHeight)
  
  *GameObject\OriginalWidth = OriginalWidth\i
  *GameObject\OriginalHeight = OriginalHeight\i
  *GameObject\ZoomFactor = ZoomFactor
  *GameObject\Width = OriginalWidth\i * ZoomFactor
  *GameObject\Height = OriginalHeight\i * ZoomFactor
  *GameObject\SpriteNum = SpriteNum
  ZoomSprite(*GameObject\SpriteNum, OriginalWidth\i * ZoomFactor, OriginalHeight\i * ZoomFactor)
  
  *GameObject\UpdateGameObject = *UpdateProc
  *GameObject\DrawGameObject = *DrawProc
  
  *GameObject\Active = Active
  
  
  
  
EndProcedure

Procedure DrawGameObject(*GameObject.TGameObject)
  DisplayTransparentSprite(*GameObject\SpriteNum, Int(*GameObject\Position\x), Int(*GameObject\Position\y))
EndProcedure





DisableExplicit