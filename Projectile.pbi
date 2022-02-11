﻿XIncludeFile "GameObject.pbi"
XIncludeFile "Resources.pbi"
XIncludeFile "Util.pbi"

EnableExplicit

Enumeration EProjectileTypes
  #ProjectileLaser1
EndEnumeration


Structure TProjectile Extends TGameObject
  Angle.f;in radians
  Type.a
EndStructure

Structure TProjectileList
  List Projectiles.TProjectile()
EndStructure

Procedure GetInactiveProjectile(*Projectiles.TProjectileList, AddIfNotFound.a = #True)
  ForEach *Projectiles\Projectiles()
    If *Projectiles\Projectiles()\Active = #False
      ProcedureReturn @*Projectiles\Projectiles()
    EndIf
  Next
  
  If AddIfNotFound
    If AddElement(*Projectiles\Projectiles()) <> 0
      ;sucessfully added a new element, now return it
      ProcedureReturn *Projectiles\Projectiles()
    Else
      ;error allocating the element in the list
      ProcedureReturn #Null
    EndIf
  EndIf
  
  
  ProcedureReturn #Null
  
  
  
EndProcedure

Procedure DrawProjectile(*Projectile.TProjectile)
  RotateSprite(*Projectile\SpriteNum, Degree(*Projectile\Angle), #PB_Absolute)
  DrawGameObject(*Projectile)
  ;Protected ScreenRect.TRect\Position\x = 0
  ;ScreenRect\Position\y = 0
  ;ScreenRect\Width = ScreenWidth()
  ;ScreenRect\Height = ScreenHeight()
  ;If CollisionRectRect(ScreenRect\Position\x, ScreenRect\Position\y, ScreenRect\Width,
  ;                     ScreenRect\Height, *Projectile\Position\x, *Projectile\Position\y, 0, 0)
  ;  StartDrawing(ScreenOutput())
  ;  Box(Int(*Projectile\Position\x), Int(*Projectile\Position\y), SpriteWidth(#Laser1), SpriteHeight(#Laser1), RGB(213, 44, 44))
  ;  Plot(Int(*Projectile\Position\x), Int(*Projectile\Position\y), RGB(44, 213, 44))
  ;  StopDrawing()
  ;EndIf
  
  
EndProcedure

Procedure UpdateProjectile(*Projectile.TProjectile, TimeSlice.f)
  UpdateGameObject(*Projectile, TimeSlice)
  Protected ScreenRect.TRect\Position\x = 0
  ScreenRect\Position\y = 0
  ScreenRect\Width = ScreenWidth()
  ScreenRect\Height = ScreenHeight()
  
  If Not CollisionRectRect(ScreenRect\Position\x, ScreenRect\Position\y, ScreenRect\Width,
                           ScreenRect\Height, *Projectile\Position\x, *Projectile\Position\y,
                           *Projectile\Width, *Projectile\Height)
    
    ;the projectile is outside of the visible screen
    *Projectile\Active = #False
    
  EndIf
  
  
EndProcedure

Procedure InitProjectile(*Projectile.TProjectile, *Pos.TVector2D, Active.a, ZoomFactor.f, Angle.f, Type.a)
  Protected SpriteNum, Velocity.f
  Select Type
    Case #ProjectileLaser1
      SpriteNum = #Laser1
      Velocity = 500.0
  EndSelect
  
  InitGameObject(*Projectile, *Pos, SpriteNum, @UpdateProjectile(), @DrawProjectile(), Active, ZoomFactor)
  *Projectile\Velocity\x = Cos(Angle) * Velocity
  *Projectile\Velocity\y = Sin(Angle) * Velocity
  
  *Projectile\Angle = Angle
  
  *Projectile\MaxVelocity\x = 1000
  *Projectile\MaxVelocity\y = 1000
  
EndProcedure



DisableExplicit