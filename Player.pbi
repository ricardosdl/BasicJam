XIncludeFile "GameObject.pbi"
XIncludeFile "Projectile.pbi"
XIncludeFile "Resources.pbi"

EnableExplicit

#PLAYER_SHOOT_TIMER = 1.0 / 3.0

Structure TPlayer Extends TGameObject
  *Projectiles.TProjectileList
  IsShooting.a
  ShootTimer.f
EndStructure

Procedure PlayerShoot(*Player.TPlayer, TimeSlice.f)
  *Player\ShootTimer + TimeSlice
  If *Player\ShootTimer >= #PLAYER_SHOOT_TIMER
    ;shoot
    Protected PlayerShootingAngle.f = ATan2(*Player\Velocity\x, *Player\Velocity\y)
    Protected *Projectile.TProjectile = GetInactiveProjectile(*Player\Projectiles)
    
    Protected Position.TVector2D
    InitProjectile(*Projectile, @Position, #True, #SPRITES_ZOOM, PlayerShootingAngle, #ProjectileLaser1)
    
    Position\x = *Player\MiddlePosition\x - *Projectile\Width / 2
    Position\y = *Player\MiddlePosition\y - *Projectile\Height / 2
    
    *Projectile\Position = Position
    
    *Player\ShootTimer = 0.0
    
  EndIf
  
EndProcedure

Procedure UpdatePlayer(*Player.TPlayer, TimeSlice.f)
  *Player\Velocity\x = 0
  *Player\Velocity\y = 0
  
  If KeyboardPushed(#PB_Key_Left)
    *Player\IsShooting = #True
    *Player\Velocity\x = -200
  EndIf
  
  If KeyboardPushed(#PB_Key_Right)
    *Player\IsShooting = #True
    *Player\Velocity\x = 200
  EndIf
  
  If KeyboardPushed(#PB_Key_Up)
    *Player\IsShooting = #True
    *Player\Velocity\y = -200
  EndIf
  
  If KeyboardPushed(#PB_Key_Down)
    *Player\IsShooting = #True
    *Player\Velocity\y = 200
  EndIf
  
  If *Player\IsShooting
    PlayerShoot(*Player, TimeSlice)
  EndIf
  
  
  ;*Player\Position\x + *Player\Velocity\x * TimeSlice
  ;*Player\Position\y + *Player\Velocity\y * TimeSlice
  UpdateGameObject(*Player, TimeSlice)
  
EndProcedure

Procedure DrawPlayer(*Player.TPlayer)
  DrawGameObject(*Player)
EndProcedure


Procedure InitPlayer(*Player.TPlayer, *ProjectilesList.TProjectileList, *Pos.TVector2D, IsShooting.a, ZoomFactor.f)
  InitGameObject(*Player, *Pos, #Player1, @UpdatePlayer(), @DrawPlayer(), #True, ZoomFactor)
  
  *Player\Projectiles = *ProjectilesList
  
  *Player\IsShooting = IsShooting
  
  *Player\MaxVelocity\x = 500
  *Player\MaxVelocity\y = 500
  
EndProcedure




DisableExplicit