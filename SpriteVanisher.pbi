XIncludeFile "GameObject.pbi"
XIncludeFile "Math.pbi"
XIncludeFile "Camera.pbi"

EnableExplicit

Prototype.a UpdateVanishingRectProc(*VanishingRect, TimeSlice.f)

Structure TVanishingRect Extends TRect
  Rotation.f;in radians
  VelX.f
  VelY.f
  AliveTimer.f
  Intensity.a
  Active.a
  SpriteNum.i
  SpriteClipX.f
  SpriteClipY.f
  SpriteClipWidth.f
  SpriteClipHeight.f
  Update.UpdateVanishingRectProc
EndStructure

Structure TSpriteVanisher Extends TGameObject
  List VanishingRects.TVanishingRect()
EndStructure

Procedure InitSpriteVanisher(*SpriteVanisher.TSpriteVanisher, *GameCamera.TCamera, DrawOrder.l)
  
EndProcedure

DisableExplicit