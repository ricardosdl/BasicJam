XIncludeFile "GameObject.pbi"
XIncludeFile "Projectile.pbi"
XIncludeFile "Resources.pbi"
XIncludeFile "DrawList.pbi"
XIncludeFile "DrawOrders.pbi"
XIncludeFile "PowerUp.pbi"

EnableExplicit

#PLAYER_SHOOT_TIMER = 1.0 / 5
#PLAYER_SHOOT_ANGLE_VARIATION = 0.04363323003054;in radians

#PLAYER_HOP_DURATION = 0.25;in seconds
#PLAYER_SHADOW_MAX_ANGLE = 3.14159274101257;in radians
#PLAYER_SHADOW_ANGLE_VELOCITY = #PLAYER_SHADOW_MAX_ANGLE / #PLAYER_HOP_DURATION

Structure TPlayerShadow
  Sprite.i
  ZoomedOriginalWidth.f
  ZoomedOriginalHeight.f
  CurrentAngle.f
  
EndStructure

Structure TPlayer Extends TGameObject
  *Projectiles.TProjectileList
  IsShooting.a
  ShootTimer.f
  LastMovementAngle.f;in radians
  *DrawList.TDrawList
  HurtTimer.f
  HasShot.a
  IsHopping.a
  PlayerShadow.TPlayerShadow
  VerticalY.f
  MaxVerticalY.f
EndStructure

Procedure.a PlayerShoot(*Player.TPlayer, TimeSlice.f)
  *Player\ShootTimer + TimeSlice
  If *Player\ShootTimer >= #PLAYER_SHOOT_TIMER
    ;shoot
    Protected PlayerShootingAngle.f = *Player\LastMovementAngle
    PlayerShootingAngle + Sin(Random(359)) * #PLAYER_SHOOT_ANGLE_VARIATION
    Protected *Projectile.TProjectile = GetInactiveProjectile(*Player\Projectiles)
    
    Protected Position.TVector2D
    InitProjectile(*Projectile, @Position, #True, #SPRITES_ZOOM, PlayerShootingAngle, #ProjectileLaser1)
    
    AddDrawItemDrawList(*Player\DrawList, *Projectile)
    
    Protected CircleAroundPlayer.TCircle
    CircleAroundPlayer\Position = *Player\MiddlePosition
    CircleAroundPlayer\Radius = *Player\Width / 2
    
    Position\x = (CircleAroundPlayer\Position\x + Cos(PlayerShootingAngle) * CircleAroundPlayer\Radius) - *Projectile\Width / 2
    Position\y = (CircleAroundPlayer\Position\y + Sin(PlayerShootingAngle) * CircleAroundPlayer\Radius) - *Projectile\Height / 2
      
    *Projectile\Position = Position
    
    *Player\ShootTimer = 0.0
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
  
EndProcedure

Procedure UpdatePlayer(*Player.TPlayer, TimeSlice.f)
  Protected DisplayedAtLasFrame.a = *Player\Displayed
  If *Player\Displayed
    *Player\Displayed = #False
  EndIf
  
  
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
    If DisplayedAtLasFrame
      *Player\HasShot = #False
    EndIf
    
    If PlayerShoot(*Player, TimeSlice)
      *Player\HasShot = #True
    EndIf
  EndIf
  
  If *Player\HurtTimer > 0.0
    *Player\HurtTimer - TimeSlice
  EndIf
  
  Protected IsPlayerMoving.a = Bool((*Player\Velocity\x <> 0) Or (*Player\Velocity\y <> 0))
  
  If IsPlayerMoving
    *Player\LastMovementAngle = ATan2(*Player\Velocity\x, *Player\Velocity\y)
  EndIf
  
  If IsPlayerMoving And Not *Player\IsHopping
    ;let's hop
    *Player\PlayerShadow\CurrentAngle = 0
    *Player\IsHopping = #True
  EndIf
  
  If *Player\IsHopping
    *Player\PlayerShadow\CurrentAngle + #PLAYER_SHADOW_ANGLE_VELOCITY * TimeSlice
    *Player\VerticalY = *Player\MaxVerticalY * Sin(*Player\PlayerShadow\CurrentAngle)
    
    If *Player\PlayerShadow\CurrentAngle >= #PLAYER_SHADOW_MAX_ANGLE
      *Player\VerticalY = 0.0
      *Player\IsHopping = #False
    EndIf
    
    
  EndIf
  
  
  UpdateGameObject(*Player, TimeSlice)
  
  ;limits the playe to the play area (game screen)
  If *Player\Position\x < 0
    *Player\Position\x = 0
  EndIf
  
  If *Player\Position\y < 0
    *Player\Position\y = 0
  EndIf
  
  If *Player\Position\x + *Player\Width > ScreenWidth() - 1
    *Player\Position\x = (ScreenWidth() - 1) - *Player\Width
  EndIf
  
  If *Player\Position\y + *Player\Height > ScreenHeight() - 1
    *Player\Position\y = (ScreenHeight() - 1) - *Player\Height
  EndIf
  
  
  
  
    
  
EndProcedure

Procedure PlayerDrawShadow(*Player.TPlayer)
  ;first draw shadow
  Protected ShadowWidth.i, ShadowHeight.i
  
  If *Player\IsHopping
    ;when player is hopping just increase the shadow width and height a little
    ZoomSprite(*Player\PlayerShadow\Sprite, *Player\PlayerShadow\ZoomedOriginalWidth * 1.2,
               *Player\PlayerShadow\ZoomedOriginalHeight * 1.2)
    ;get the new size for further calculations
    ShadowWidth = SpriteWidth(*Player\PlayerShadow\Sprite)
    ShadowHeight = SpriteHeight(*Player\PlayerShadow\Sprite)
  Else
    ;player not hopping, use the normal size
    ZoomSprite(*Player\PlayerShadow\Sprite, *Player\PlayerShadow\ZoomedOriginalWidth,
               *Player\PlayerShadow\ZoomedOriginalHeight)
    ;get the new size for further calculations
    ShadowWidth = SpriteWidth(*Player\PlayerShadow\Sprite)
    ShadowHeight = SpriteHeight(*Player\PlayerShadow\Sprite)
  EndIf
  
  
  Protected ShadowX.f = *Player\MiddlePosition\x - (ShadowWidth / 2); + (ShadowWidth * 0.9)
  Protected ShadowY.f = *Player\MiddlePosition\y + (ShadowHeight / 3)
  DisplayTransparentSprite(*Player\PlayerShadow\Sprite, ShadowX, ShadowY)
  
EndProcedure

Procedure DrawPlayerWithGameCamera(*Player.TPlayer, Intensity = 255)
  Protected.l PosX, PosY
  
  PlayerDrawShadow(*Player)
  
  PosX = Int(*Player\Position\x - *Player\GameCamera\Position\x)
  If *Player\IsHopping
    PosY = Int((*Player\Position\y + (*Player\VerticalY * -1)) - *Player\GameCamera\Position\y)
  Else
    PosY = Int(*Player\Position\y - *Player\GameCamera\Position\y)
  EndIf
  
  DisplayTransparentSprite(*Player\SpriteNum, PosX, PosY, Intensity)
  
EndProcedure

Procedure DrawPlayer(*Player.TPlayer)
  If *Player\HurtTimer <= 0
    DrawPlayerWithGameCamera(*Player)
  Else
    Protected HurtTimerMs = *Player\HurtTimer * 1000
    
    Protected IsOpaque = (HurtTimerMs / 100) % 2
    
    ;after each 100 ms we will display the player transparent
    DrawPlayerWithGameCamera(*Player, 255 * IsOpaque)
  EndIf
  
  If *Player\HasShot
    
    Protected CircleAroundPlayer.TCircle
    CircleAroundPlayer\Position = *Player\MiddlePosition
    CircleAroundPlayer\Radius = *Player\Width / 2
    
    Protected Position.TVector2D
    
    Position\x = CircleAroundPlayer\Position\x + Cos(*Player\LastMovementAngle) * CircleAroundPlayer\Radius
    Position\y = CircleAroundPlayer\Position\y + Sin(*Player\LastMovementAngle) * CircleAroundPlayer\Radius
    
    Protected.f ShotFlashX, ShotFlashY
    ShotFlashX = Position\x - SpriteWidth(#ShotFlash) / 2
    ShotFlashY = Position\y - SpriteHeight(#ShotFlash) / 2
    
    RotateSprite(#ShotFlash, Degree(*Player\LastMovementAngle), #PB_Absolute)
    DisplayTransparentSprite(#ShotFlash, ShotFlashX, ShotFlashY)
    
    
    
    
    
  EndIf
  
  *Player\Displayed = #True
EndProcedure

Procedure.a GetCollisionRectPlayer(*Player.TPlayer, *CollisionRect.TRect)
  *CollisionRect\Width = *Player\Width * 0.3
  *CollisionRect\Height = *Player\Height * 0.3
  
  *CollisionRect\Position\x = (*Player\Position\x + *Player\Width / 2) - *CollisionRect\Width / 2
  *CollisionRect\Position\y = (*Player\Position\y + *Player\Height / 2) - *CollisionRect\Height / 2
  
  ;if the player is hurt we don't return it as collidable
  ProcedureReturn Bool(*Player\HurtTimer <= 0)
  
EndProcedure

Procedure PlayerSetupPlayerShadowSprite(*Player.TPlayer, ZoomFactor.f)
  ZoomSprite(#PlayerShadow, SpriteWidth(#PlayerShadow) * ZoomFactor, SpriteHeight(#PlayerShadow) * ZoomFactor)
  *Player\PlayerShadow\Sprite = #PlayerShadow
  *Player\PlayerShadow\ZoomedOriginalWidth = SpriteWidth(#PlayerShadow)
  *Player\PlayerShadow\ZoomedOriginalHeight = SpriteHeight(#PlayerShadow)
  *Player\PlayerShadow\CurrentAngle = 0.0
EndProcedure

Procedure InitPlayer(*Player.TPlayer, *ProjectilesList.TProjectileList, *Pos.TVector2D, IsShooting.a, ZoomFactor.f, *DrawList.TDrawList)
  InitGameObject(*Player, *Pos, #Player1, @UpdatePlayer(), @DrawPlayer(), #True, ZoomFactor,
                 #PlayerDrawOrder)
  
  *Player\Projectiles = *ProjectilesList
  
  *Player\IsShooting = IsShooting
  
  *Player\DrawList = *DrawList
  
  *Player\MaxVelocity\x = 500
  *Player\MaxVelocity\y = 500
  
  *Player\GetCollisionRect = @GetCollisionRectPlayer()
  
  *Player\Health = 5.0
  
  *Player\HurtTimer = 0.0
  
  *Player\HasShot = #False
  
  *Player\Displayed = #False
  
  *Player\IsHopping = #False
  
  *Player\VerticalY = 0.0
  
  *Player\MaxVerticalY = *Player\Height * 0.5
  
  PlayerSetupPlayerShadowSprite(*Player, ZoomFactor)
  
EndProcedure

Procedure HurtPlayer(*Player.TPlayer, Power.f)
  *Player\Health - Power
  *Player\HurtTimer = 2.5
  If *Player\Health <= 0
    ;TODO: kill the player
    Debug "player died"
  EndIf
  
EndProcedure





DisableExplicit