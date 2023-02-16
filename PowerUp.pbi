XIncludeFile "GameObject.pbi"
XIncludeFile "Projectile.pbi"
XIncludeFile "Math.pbi"
XIncludeFile "Util.pbi"
XIncludeFile "DrawList.pbi"
XIncludeFile "DrawOrders.pbi"

EnableExplicit

Enumeration
  #POWERUP_TYPE_SUPER_JUMP
  #POWERUP_TYPE_SMALL
  #POWERUP_TYPE_SHOOT_ALL_DIRECTIONS
  #POWERUP_TYPE_FREEZING_SHOT
EndEnumeration

#POWERUP_SHOOT_ALL_DIRECTIONS_TIMER = 1.0 / 5.0
#POWERUP_SHOOT_ALL_DIRECTIONS_MAX_SHOTS = 16

Prototype PowerUpUpdateProc(*PowerUp, TimeSlice.f)

Structure TPowerUp Extends TGameObject
  Type.a
  Timer.f
  Uses.b
  ShootTimer.f
  *ProjectileList.TProjectileList
  *Holder.TGameObject
  *DrawList.TDrawList
EndStructure

Procedure PowerUpShootAllDirections(*PowerUp.TPowerUp)
  Protected NumShots.a = #POWERUP_SHOOT_ALL_DIRECTIONS_MAX_SHOTS, i.a = 0
  Protected AngleStart.f = 0
  Protected AngleOffset.f = (2 * #PI) / NumShots
  
  For i = 0 To NumShots - 1
    Protected *Projectile.TProjectile = GetInactiveProjectile(*PowerUp\ProjectileList)
    
    Protected Position.TVector2D
    Protected Angle.f = AngleStart + (AngleOffset * i)
    InitProjectile(*Projectile, @Position, #True, #SPRITES_ZOOM, Angle, #ProjectileLaser1)
    
    AddDrawItemDrawList(*PowerUp\DrawList, *Projectile)
    
    Protected CircleAroundPlayer.TCircle
    CircleAroundPlayer\Position = *PowerUp\Holder\MiddlePosition
    CircleAroundPlayer\Radius = *PowerUp\Holder\Width / 2
    
    Position\x = (CircleAroundPlayer\Position\x + Cos(Angle) * CircleAroundPlayer\Radius) - *Projectile\Width / 2
    Position\y = (CircleAroundPlayer\Position\y + Sin(Angle) * CircleAroundPlayer\Radius) - *Projectile\Height / 2
      
    *Projectile\Position = Position
    
  Next i
  
EndProcedure


Procedure PowerUpUpdateShootAllDirections(*PowerUp.TPowerUp, TimeSlice.f)
  *PowerUp\Timer - TimeSlice
  
  If *PowerUp\Timer <= 0.0
    *PowerUp\Active = #False
    ProcedureReturn
  EndIf
  
  *PowerUp\ShootTimer + TimeSlice
  If *PowerUp\ShootTimer >= #POWERUP_SHOOT_ALL_DIRECTIONS_TIMER
    
  EndIf
  
  
  
  
  
  
EndProcedure

Procedure PowerUpInit(*PowerUp.TPowerUp, Type.a, Timer.f, Uses.b, ShootTimer.f, *ProjectileList.TProjectileList, *Holder.TGameObject)
  *PowerUp\Type = Type
  
  *PowerUp\Timer = Timer
  *PowerUp\Uses = Uses
  *PowerUp\ShootTimer = ShootTimer
  *PowerUp\ProjectileList = *ProjectileList
  *PowerUp\Holder = *Holder
  *PowerUp\Active = #True
EndProcedure

Procedure PowerUpShootAllDirectionsInit(*PowerUp.TPowerUp, *Position.TVector2D, *ProjectileList.TProjectileList, *Holder.TGameObject)
  
  InitGameObject(*PowerUp, *Position, #PowerUpShootAllDirections, @PowerUpUpdateShootAllDirections(), @DrawGameObject(),
                 #True, #SPRITES_ZOOM, #PowerUpDrawOrder)
  
  PowerUpInit(*PowerUp, #POWERUP_TYPE_SHOOT_ALL_DIRECTIONS, 3.0, -1, #POWERUP_SHOOT_ALL_DIRECTIONS_TIMER,
              *ProjectileList, *Holder)
EndProcedure

DisableExplicit