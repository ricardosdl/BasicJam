XIncludeFile "GameObject.pbi"
XIncludeFile "Util.pbi"

EnableExplicit

Structure TCamera Extends TGameObject
  ShakeTime.f
  ShakeX.f
  ShakeY.f
  MaxShake.f
EndStructure

Procedure UpdateCamera(*Camera.TCamera, TimeSlice.f)
  UpdateGameObject(*Camera, TimeSlice)
  
  If *Camera\ShakeTime <= 0.0
    ;defaul position is 0, 0
    *Camera\Position\x = 0.0
    *Camera\Position\y = 0.0
    ;nothing else to do
    ProcedureReturn
  EndIf
  
  
  
  
  
  Protected RandomAngle.f = RandomFloat() * #PI * 2
  *Camera\ShakeX = Cos(RandomAngle) * *Camera\MaxShake * RandomFloat()
  *Camera\ShakeY = Sin(RandomAngle) * *Camera\MaxShake * RandomFloat()
  
  *Camera\Position\x = 0 + *Camera\ShakeX
  *Camera\Position\y = 0 + *Camera\ShakeY
  
  Debug "posx:" + *Camera\Position\x
  Debug "posy:" + *Camera\Position\y
  
  
  *Camera\ShakeTime - TimeSlice
  
  
  
  
EndProcedure

Procedure InitCamera(*Camera.TCamera, *Position.TVector2D, Width.l, Height.l)
  InitGameObject(*Camera, *Position, -1, @UpdateCamera(), #Null, #True)
  
  *Camera\Width = Width
  *Camera\Height = Height
  
  *Camera\ShakeTime = 0.0
  *Camera\MaxShake = 0.0
  
EndProcedure

Procedure ShakeCamera(*Camera.TCamera, ShakeTime.f, MaxShake.f)
  *Camera\ShakeTime = ShakeTime
  *Camera\MaxShake = MaxShake
EndProcedure



DisableExplicit