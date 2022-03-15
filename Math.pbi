EnableExplicit

Structure TVector2D
  x.f
  y.f
EndStructure

Structure TRect
  Position.TVector2D
  Width.f
  Height.f
EndStructure

Structure TCircle
  Position.TVector2D
  Radius.f
EndStructure

Procedure RotateAroundPoint(*PointOfRotation.TVector2D, *PointToRotate.TVector2D, Angle.f)
  
  ;translate *pointtorotate to the origin
  *PointToRotate\x = *PointToRotate\x - *PointOfRotation\x
  *PointToRotate\y = *PointToRotate\y - *PointOfRotation\y
  
  *PointToRotate\x = *PointToRotate\x * Cos(Angle) - (*PointToRotate\y * Sin(Angle))
  *PointToRotate\y = *PointToRotate\y * Cos(Angle) + (*PointToRotate\x * Sin(Angle))
  
  ;translate *pointotorotate back 
  *PointToRotate\x = *PointToRotate\x + *PointOfRotation\x
  *PointToRotate\y = *PointToRotate\y + *PointOfRotation\y
  
EndProcedure





DisableExplicit