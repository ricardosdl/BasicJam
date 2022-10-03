XIncludeFile "GameObject.pbi"
XIncludeFile "Util.pbi"

EnableExplicit

Structure TCamera Extends TGameObject
  ShakeTime.f
  ShakeX.f
  ShakeY.f
  BeforeShakeX.f
  BeforeShakeY.f
EndStructure

Procedure UpdateCamera(*Camera.TCamera, TimeSlice.f)
  *Camera\Position\x = *Camera\BeforeShakeX
  *Camera\Position\y = *Camera\BeforeShakeY
  UpdateGameObject(*Camera, TimeSlice)
  
  If *Camera\ShakeTime <= 0.0
    *Camera\ShakeTime = 0.0
  Else
    
  EndIf
  
  
  
  
  
  Protected RandomAngle.f = RandomFloat() * #PI * 2
  *Camera\ShakeX = Cos(RandomAngle) * *Camera\ShakeTime
  *Camera\ShakeY = Sin(RandomAngle) * *Camera\ShakeTime
  
  *Camera\BeforeShakeX = *Camera\Position\x
  *Camera\BeforeShakeY = *Camera\Position\y
  
  *Camera\Position\x + *Camera\ShakeX
  *Camera\Position\y + *Camera\ShakeY
  
  
  *Camera\ShakeTime - TimeSlice
  
  
  
  
EndProcedure

Procedure InitCamera(*Camera.TCamera, *Position.TVector2D, Width.l, Height.l)
  
  InitGameObject(*Camera, *Position, -1, @UpdateCamera(), #Null, #True)
  
  *Camera\Width = Width
  *Camera\Height = Height
  
  *Camera\ShakeTime = 0.0
  *Camera\BeforeShakeX = *Camera\Position\x
  *Camera\BeforeShakeY = *Camera\Position\y
  
EndProcedure

Procedure ShakeCamera(*Camera.TCamera, ShakeTime.f)
  *Camera\ShakeTime = ShakeTime
  
EndProcedure



DisableExplicit