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
    
    
  EndIf
  
EndProcedure

Procedure UpdatePlayer(*Player.TPlayer, TimeSlice.f)
  *Player\Velocity\x = 0
  *Player\Velocity\y = 0
  
  If KeyboardPushed(#PB_Key_Left)
    *Player\Velocity\x = -200
  EndIf
  
  If KeyboardPushed(#PB_Key_Right)
    *Player\Velocity\x = 200
  EndIf
  
  If KeyboardPushed(#PB_Key_Up)
    *Player\Velocity\y = -200
  EndIf
  
  If KeyboardPushed(#PB_Key_Down)
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