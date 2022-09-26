XIncludeFile "GameObject.pbi"

EnableExplicit

Structure TCamera Extends TGameObject
  
EndStructure

Procedure UpdateCamera(*Camera.TCamera, TimeSlice.f)
  
EndProcedure

Procedure InitCamera(*Camera.TCamera, *Position.TVector2D, Width.l, Height.l)
  
  InitGameObject(*Camera, *Position, -1, @UpdateCamera(), #Null, #True)
  
  *Camera\Width = Width
  *Camera\Height = Height
  
  
EndProcedure



DisableExplicit