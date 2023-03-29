XIncludeFile "GameObject.pbi"
XIncludeFile "Projectile.pbi"
XIncludeFile "Math.pbi"
XIncludeFile "Util.pbi"
XIncludeFile "DrawList.pbi"
XIncludeFile "DrawOrders.pbi"
XIncludeFile "GameActor.pbi"

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

Structure TPowerUp Extends TGameActor
  Type.a
  Timer.f
  Uses.b
  ShootTimer.f
  *ProjectileList.TProjectileList
  *Holder.TGameActor
  *DrawList.TDrawList
  Equipped.a
EndStructure

Structure TPowerUpList
  List PowerUps.TPowerUp()
EndStructure

Procedure PowerUpGetInactive(*PowerUpList.TPowerUpList, AddIfNotFound.a = #True)
  ForEach *PowerUpList\PowerUps()
    If Not *PowerUpList\PowerUps()\Active
      ProcedureReturn @*PowerUpList\PowerUps()
    EndIf  
  Next
  
  If AddIfNotFound
    If AddElement(*PowerUpList\PowerUps()) <> 0
      ;sucessfully added a new element, now return it
      ProcedureReturn @*PowerUpList\PowerUps()
    Else
      ;error allocating the element in the list
      ProcedureReturn #Null
    EndIf
  EndIf
  
  
  ProcedureReturn #Null
  
  
EndProcedure

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
  If Not *PowerUp\Equipped
    UpdateGameObject(*PowerUp, TimeSlice)
    ProcedureReturn
  EndIf
  
  *PowerUp\Timer - TimeSlice
  
  If *PowerUp\Timer <= 0.0
    *PowerUp\Active = #False
    ProcedureReturn
  EndIf
  
  *PowerUp\ShootTimer + TimeSlice
  If *PowerUp\ShootTimer >= #POWERUP_SHOOT_ALL_DIRECTIONS_TIMER
    *PowerUp\ShootTimer = 0.0
    PowerUpShootAllDirections(*PowerUp)
  EndIf
  
  
  
  
  
  
EndProcedure

Procedure PowerUpInit(*PowerUp.TPowerUp, Type.a, Timer.f, Uses.b, ShootTimer.f, *ProjectileList.TProjectileList,
                      *Holder.TGameObject, Equipped.a, *DrawList.TDrawList)
  GameActorInit(*PowerUp)
  *PowerUp\Type = Type
  
  *PowerUp\Timer = Timer
  *PowerUp\Uses = Uses
  *PowerUp\ShootTimer = ShootTimer
  *PowerUp\ProjectileList = *ProjectileList
  *PowerUp\Holder = *Holder
  *PowerUp\Active = #True
  *PowerUp\Equipped = Equipped
  *PowerUp\DrawList = *DrawList
EndProcedure

Procedure PowerUpDraw(*PowerUp.TPowerUp, Intensity = 255)
  If *PowerUp\Equipped
    ProcedureReturn
  EndIf
  DrawGameObject(*PowerUp, 255)
EndProcedure

Procedure PowerUpShootAllDirectionsInit(*PowerUp.TPowerUp, *Position.TVector2D, *ProjectileList.TProjectileList,
                                        *Holder.TGameObject, Equipped.a, *DrawList.TDrawList)
  
  InitGameObject(*PowerUp, *Position, #PowerUpShootAllDirections, @PowerUpUpdateShootAllDirections(), @PowerUpDraw(),
                 #True, #SPRITES_ZOOM, #PowerUpDrawOrder)
  
  PowerUpInit(*PowerUp, #POWERUP_TYPE_SHOOT_ALL_DIRECTIONS, 3.0, -1, #POWERUP_SHOOT_ALL_DIRECTIONS_TIMER,
              *ProjectileList, *Holder, Equipped, *DrawList)
EndProcedure

Procedure PowerUpUpdateFreezingShot(*PowerUp.TPowerUp, TimeSlice.f)
  If Not *PowerUp\Equipped
    UpdateGameObject(*PowerUp, TimeSlice)
    ProcedureReturn
  EndIf
  
  
  
  
  *PowerUp\Timer - TimeSlice
  
  If *PowerUp\Timer <= 0.0
    *PowerUp\Active = #False
    *PowerUp\Holder\ShootingFreezingShots = #False
    ProcedureReturn
  EndIf
EndProcedure

Procedure PowerUpFreezingShotInit(*PowerUp.TPowerUp, *Position.TVector2D, *ProjectileList.TProjectileList,
                                  *Holder.TGameObject, Equipped.a, *DrawList.TDrawList)
  InitGameObject(*PowerUp, *Position, #PowerUpFreezingShot, @PowerUpUpdateFreezingShot(), @PowerUpDraw(),
                 #True, #SPRITES_ZOOM, #PowerUpDrawOrder)
  
  PowerUpInit(*PowerUp, #POWERUP_TYPE_FREEZING_SHOT, 5.0, -1, 0.0, *ProjectileList, *Holder, Equipped, *DrawList)
EndProcedure

Procedure PowerUpEquip(*PowerUp.TPowerUp, *Holder.TGameObject, *ProjectileList.TProjectileList)
  *PowerUp\Equipped = #True
  *PowerUp\Holder = *Holder
  *PowerUp\ProjectileList = *ProjectileList
  ;setup the holder as shootingfreezinshots when the powerup is #PowerUpFreezingShot
  *PowerUp\Holder\ShootingFreezingShots = Bool(*PowerUp\Type = #POWERUP_TYPE_FREEZING_SHOT)
EndProcedure

DisableExplicit