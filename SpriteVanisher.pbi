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
  SpriteWidth.u
  SpriteHeight.u
  SpriteClipX.f
  SpriteClipY.f
  SpriteClipWidth.f
  SpriteClipHeight.f
  Update.UpdateVanishingRectProc
EndStructure

Structure TSpriteVanisher Extends TGameObject
  List VanishingRects.TVanishingRect()
EndStructure

Procedure ClearVanishingRects(*SpriteVanisher.TSpriteVanisher)
  ForEach *SpriteVanisher\VanishingRects()
    *SpriteVanisher\VanishingRects()\Active = #False
    *SpriteVanisher\VanishingRects()\AliveTimer = 0.0
  Next
  
EndProcedure

Procedure GetInactiveVanishingRect(*SpriteVanisher.TSpriteVanisher, AddIfNecessary.a = #True)
  ForEach *SpriteVanisher\VanishingRects()
    If Not *SpriteVanisher\VanishingRects()\Active
      ProcedureReturn @*SpriteVanisher\VanishingRects()
    EndIf
  Next
  
  If AddIfNecessary
    If AddElement(*SpriteVanisher\VanishingRects()) = 0
      ProcedureReturn #Null
    EndIf
    
    *SpriteVanisher\VanishingRects()\Active = #False
    *SpriteVanisher\VanishingRects()\AliveTimer = 0.0
    ProcedureReturn @*SpriteVanisher\VanishingRects()
  EndIf
  
  ProcedureReturn #Null
  
  
EndProcedure

Procedure GetExplodingSpriteVanisher(*SpriteVanisher.TSpriteVanisher, *GameObject.TGameObject, NumColumns.a = 4, NumRows.a = 4)
  ;we devide the sprite from *gameobject in numcolumns columns and numrows rows
  ;take the center point of the sprite as a relative 0,0 point
  ;and each vanishing rect will take an angle relative to this central point
  ;
  ;   each vansishing rect will be thrown at an angle
  ;   around a circle starting from 00 until 33
  ;   00,10,20,30
  ;   01,11,21,31
  ;   02,12,22,32
  ;   03,13,23,33
  ;
  Protected i.u, j.u
  Protected *VanishingRect.TVanishingRect
  Protected GameObjectWidth.f = *GameObject\Width
  Protected HalfWidth.f = GameObjectWidth / 2
  Protected GameObjectHeight.f = *GameObject\Height
  Protected HalfHeight.f = GameObjectHeight / 2
  Protected VanishingRectWidth.f = GameObjectWidth / NumColumns
  Protected VanishingRectHeight.f = GameObjectHeight / NumRows
  
  Protected VanishingRectRelativePositon.TVector2D\x = 0 - HalfWidth
  VanishingRectRelativePositon\y = 0 - HalfHeight
  For i = 0 To NumColumns - 1
    For j = 0 To NumRows - 1
      *VanishingRect = GetInactiveVanishingRect(*SpriteVanisher)
      If *VanishingRect = #Null
        Continue
      EndIf
      
      VanishingRectRelativePositon\x + i * VanishingRectWidth
      VanishingRectRelativePositon\y + j * VanishingRectHeight
      Protected VanishingRectAngle.f = ATan2(VanishingRectRelativePositon\x, VanishingRectRelativePositon\y)
      
      *VanishingRect\Width = VanishingRectWidth
      *VanishingRect\Height = VanishingRectHeight
      *VanishingRect\Position\x = *GameObject\Position\x + i * VanishingRectWidth
      *VanishingRect\Position\y = *GameObject\Position\y + j * VanishingRectHeight
      *VanishingRect\SpriteNum = *GameObject\SpriteNum
      *VanishingRect\SpriteWidth = GameObjectWidth
      *VanishingRect\SpriteHeight = GameObjectHeight
      *VanishingRect\SpriteClipX = i * VanishingRectWidth
      *VanishingRect\SpriteClipY = j * VanishingRectHeight
      
      *VanishingRect\Active = #True
      *VanishingRect\Intensity = 255
      *VanishingRect\AliveTimer = 1.5
      
      *VanishingRect\VelX = Cos(VanishingRectAngle) * 200
      *VanishingRect\VelY = Sin(VanishingRectAngle) * 200
      
    Next
  Next i
  
EndProcedure

Procedure DrawSpriteVanisher(*SpriteVanisher.TSpriteVanisher, Intensity.a = 255)
  ForEach *SpriteVanisher\VanishingRects()
    If Not *SpriteVanisher\VanishingRects()\Active
      Continue
    EndIf
    
    ;TODO:implement drawing
    
      
  Next
  
EndProcedure

Procedure UpdateSpriteVanisher(*SpriteVanisher.TSpriteVanisher, TimeSlice.f)
  ForEach *SpriteVanisher\VanishingRects()
    If Not *SpriteVanisher\VanishingRects()\Active
      Continue
    EndIf
    
    If *SpriteVanisher\VanishingRects()\AliveTimer <= 0.0
      *SpriteVanisher\VanishingRects()\Active = #False
      Continue
    EndIf
    
    
    *SpriteVanisher\VanishingRects()\Position\x + *SpriteVanisher\VanishingRects()\VelX * TimeSlice
    *SpriteVanisher\VanishingRects()\Position\y + *SpriteVanisher\VanishingRects()\VelY * TimeSlice
    
    *SpriteVanisher\VanishingRects()\AliveTimer - TimeSlice
  Next
  
EndProcedure

Procedure InitSpriteVanisher(*SpriteVanisher.TSpriteVanisher, *GameCamera.TCamera, DrawOrder.l)
  Protected Position.TVector2D\x = 0
  Position\y = 0
  InitGameObject(*SpriteVanisher, @Position, -1, #Null, #Null, #True, #SPRITES_ZOOM, DrawOrder)
  
  *SpriteVanisher\GameCamera = *GameCamera
  
  ClearVanishingRects(*SpriteVanisher)
  
EndProcedure

DisableExplicit