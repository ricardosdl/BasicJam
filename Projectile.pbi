﻿XIncludeFile "GameObject.pbi"
XIncludeFile "Resources.pbi"
XIncludeFile "Util.pbi"

EnableExplicit

Enumeration EProjectileTypes
  #ProjectileLaser1
  #ProjectileBarf1
  #ProjectileGrape1
  #ProjectileSeed1
  #ProjectileGomo1
EndEnumeration


Structure TProjectile Extends TGameObject
  Angle.f;in radians
  Type.a
  Power.f
  HasAliveTimer.a
  AliveTimer.f
  *Owner.TGameObject
  List WayPoints.TRect()
  CurrentWayPoint.a
EndStructure

Structure TProjectileList
  List Projectiles.TProjectile()
EndStructure

Procedure GetOwnedProjectile(*Owner.TGameObject, *Projectiles.TProjectileList)
  ForEach *Projectiles\Projectiles()
    If *Projectiles\Projectiles()\Active And *Projectiles\Projectiles()\Owner = *Owner
      ProcedureReturn @*Projectiles\Projectiles()
    EndIf
    
  Next
  
  ProcedureReturn #Null
  
EndProcedure

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
  
  If *Projectile\HasAliveTimer
    *Projectile\AliveTimer - TimeSlice
    If *Projectile\AliveTimer <= 0
      *Projectile\Active = #False
    EndIf
    
  EndIf
  
  
  
EndProcedure

Procedure HurtProjectile(*Projectile.TProjectile, Power.f)
  *Projectile\Health - Power
  If *Projectile\Health <= 0
    *Projectile\Active = #False
  EndIf
  
EndProcedure

Procedure UpdateSeed1Projectile(*Projectile.TProjectile, TimeSlice.f)
  *Projectile\Angle + Radian(200.0) * TimeSlice
  UpdateProjectile(*Projectile, TimeSlice)
EndProcedure

Procedure UpdateGomo1Projectile(*Projectile.TProjectile, TimeSlice.f)
  ;more stuff here
  SelectElement(*Projectile\WayPoints(), *Projectile\CurrentWayPoint)
  Protected CurrentWayPoint.TRect = *Projectile\WayPoints()
  
  UpdateProjectile(*Projectile, TimeSlice)
EndProcedure

Procedure.f GetProjectileVelocity(Type.a)
  Select Type
    Case #ProjectileLaser1
      
      ProcedureReturn 500.0
      
    Case #ProjectileBarf1
      
      ProcedureReturn 100.0
      
    Case #ProjectileGrape1
      
      ProcedureReturn 100.0
      
    Case #ProjectileSeed1
      
      ProcedureReturn 80.0
      
    Case #ProjectileGomo1
      
      ProcedureReturn 80.0
      
  EndSelect
EndProcedure

Procedure InitProjectile(*Projectile.TProjectile, *Pos.TVector2D, Active.a,
                         ZoomFactor.f, Angle.f, Type.a, HasAliveTimer.a = #False,
                         AliveTimer.f = 0.0, *Owner.TGameObject = #Null)
  
  Protected SpriteNum, Velocity.f, Power.f, Health.f
  Protected *UpdateProjectileProc = @UpdateProjectile()
  
  Select Type
    Case #ProjectileLaser1
      SpriteNum = #Laser1
      Velocity = 500.0
      Power = 1.0
      Health = 1.0
    Case #ProjectileBarf1
      SpriteNum = #Barf1
      Velocity = 100.0
      Power = 1.0
      Health = 1.0
    Case #ProjectileGrape1
      SpriteNum = #Grape1
      Velocity = 100.0
      Power = 1.0
      Health = 1.0
    Case #ProjectileSeed1
      SpriteNum = #Seed1
      Velocity = 80.0
      Power = 2.0
      Health = 1.0
      *UpdateProjectileProc = @UpdateSeed1Projectile()
    Case #ProjectileGomo1
      SpriteNum = #Gomo1
      Velocity = 80.0
      Power = 2.0
      Health = 1.0
      *UpdateProjectileProc = @UpdateGomo1Projectile()
  EndSelect
  
  InitGameObject(*Projectile, *Pos, SpriteNum, *UpdateProjectileProc, @DrawProjectile(), Active, ZoomFactor)
  *Projectile\Velocity\x = Cos(Angle) * Velocity
  *Projectile\Velocity\y = Sin(Angle) * Velocity
  
  *Projectile\Angle = Angle
  
  *Projectile\Power = Power
  
  *Projectile\Health = Health
  
  *Projectile\HasAliveTimer = HasAliveTimer
  *Projectile\AliveTimer = AliveTimer
  
  *Projectile\Owner = *Owner
  
  *Projectile\MaxVelocity\x = 1000
  *Projectile\MaxVelocity\y = 1000
  
  ClearList(*Projectile\WayPoints())
  *Projectile\CurrentWayPoint = 1
  
EndProcedure

Procedure SetWayPointsProjectile(*Projectile.TProjectile, List WayPoints.TRect())
  CopyList(WayPoints(), *Projectile\WayPoints())
  FirstElement(*Projectile\WayPoints())
  UpdateMiddlePositionGameObject(*Projectile)
  Protected DeltaX.f, DeltaY.f
  DeltaX = *Projectile\WayPoints()\Position\x - *Projectile\MiddlePosition\x
  DeltaY = *Projectile\WayPoints()\Position\y - *Projectile\MiddlePosition\y
  
  Protected Angle.f = ATan2(DeltaX, DeltaY)
  
  *Projectile\Velocity\x = Cos(Angle) * GetProjectileVelocity(*Projectile\Type)
  *Projectile\Velocity\y = Sin(Angle) * GetProjectileVelocity(*Projectile\Type)
  
EndProcedure



DisableExplicit