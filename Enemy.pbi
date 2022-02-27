XIncludeFile "GameObject.pbi"
XIncludeFile "Math.pbi"
XIncludeFile "Util.pbi"
XIncludeFile "Projectile.pbi"

EnableExplicit

Enumeration EEnemyStates
  #EnemyNoState
  #EnemyGoingToObjectiveRect
  #EnemyWaiting
  #EnemyPatrolling
  #EnemyShooting
  #EnemyFollowingPlayer
EndEnumeration

Structure TEnemy Extends TGameObject
  *Player.TGameObject
  CurrentState.a
  LastState.a
  ObjectiveRect.TRect;a rect that can be used as an objective point for the enemy to reach
  WaitTimer.f
  FollowPlayerTimer.f
  *ShootingTarget.TGameObject
  ShootingArea.TRect
  ShootingTimer.f
  *Projectiles.TProjectileList
  NumShots.a
  TimerBetweenShots.f
  CurrentTimerBetweenShots.f
  CurrentAngleShot.f
EndStructure



Procedure InitEnemy(*Enemy.TEnemy, *Player.TGameObject, *ProjectileList.TProjectileList)
  *Enemy\Player = *Player
  *Enemy\Projectiles = *ProjectileList
EndProcedure

Procedure SetVelocityPatrollingBananaEnemy(*BananaEnemy.TEnemy)
  UpdateMiddlePositionGameObject(*BananaEnemy)
  If *BananaEnemy\MiddlePosition\x < (ScreenWidth() / 2)
    ;to the left of screen, will move up or down
    If *BananaEnemy\MiddlePosition\y < (ScreenHeight() / 2)
      ;move up
      *BananaEnemy\Velocity\y = -100
    Else
      ;move down
      *BananaEnemy\Velocity\y = 100
    EndIf
    
  Else
    ;to the right of screen, will move left or right
    If *BananaEnemy\MiddlePosition\y < (ScreenHeight() / 2)
      ;move left
      *BananaEnemy\Velocity\x = -100
    Else
      ;move right
      *BananaEnemy\Velocity\x = 100
    EndIf
    
  EndIf
  
EndProcedure

Procedure HasReachedObjectiveRectEnemy(*Enemy.TEnemy)
  Protected EnemyRect.TRect, ObjectiveRect.TRect
  EnemyRect\Position = *Enemy\Position
  EnemyRect\Width = *Enemy\Width
  EnemyRect\Height = *Enemy\Height
  
  ObjectiveRect = *Enemy\ObjectiveRect
  
  ProcedureReturn CollisionRectRect(EnemyRect\Position\x, EnemyRect\Position\y,
                                    EnemyRect\Width, EnemyRect\Height,
                                    ObjectiveRect\Position\x, ObjectiveRect\Position\y,
                                    ObjectiveRect\Width, ObjectiveRect\Height)
EndProcedure

Procedure GetRandomRectAroundPlayer(*Player.TGameObject, *RectAroundPlayer.TRect,
                                    RectWidth.f, RectHeight.f, ObjectiveRectWidth.f = 4,
                                    ObjectiveRectHeight.f = 4)
  Protected RectAroundPlayer.TRect
  GetRandomRectAroundGameObject(*Player, RectWidth, RectHeight,
                                @RectAroundPlayer)
  RectAroundPlayer\Position\x = ClampF(RectAroundPlayer\Position\x, 0, ScreenWidth() - 1)
  RectAroundPlayer\Position\y = ClampF(RectAroundPlayer\Position\y, 0, ScreenHeight() - 1)
  
  ;clamp the rect width and height if necessary to stay inside the screen
  If RectAroundPlayer\Position\x + RectAroundPlayer\Width > ScreenWidth() - 1
    RectAroundPlayer\Width - (RectAroundPlayer\Position\x + RectAroundPlayer\Width - (ScreenWidth() - 1))
  EndIf
  
  If RectAroundPlayer\Position\y + RectAroundPlayer\Height > ScreenHeight() - 1
    RectAroundPlayer\Height - (RectAroundPlayer\Position\y + RectAroundPlayer\Height - (ScreenHeight() - 1))
  EndIf
  
  
  
  ;lets get a random point inside the rect around the player
  Protected RandomPoint.TVector2D\x = Random(RectAroundPlayer\Position\x +
                                             RectAroundPlayer\Width,
                                             RectAroundPlayer\Position\x)
  RandomPoint\y = Random(RectAroundPlayer\Position\y + RectAroundPlayer\Height,
                         RectAroundPlayer\Position\y)
  
  
  Protected ObjectiveRect.TRect\Width = ObjectiveRectWidth
  ObjectiveRect\Height = ObjectiveRectHeight
  
  ;make sure the point is inside
  RandomPoint\x = ClampF(RandomPoint\x, 0, ScreenWidth() - ObjectiveRect\Width)
  RandomPoint\y = ClampF(RandomPoint\y, 0, ScreenHeight() - ObjectiveRect\Height)
  
  ObjectiveRect\Position = RandomPoint
  CopyStructure(@ObjectiveRect, *RectAroundPlayer, TRect)
EndProcedure

Procedure SwitchStateEnemy(*Enemy.TEnemy, NewState.a)
  *Enemy\LastState = *Enemy\CurrentState
  *Enemy\CurrentState = NewState
EndProcedure

Procedure SwitchToGoingToObjectiveRectEnemy(*BananaEnemy.TEnemy)
  Protected *Player.TGameObject = *BananaEnemy\Player
  Protected ObjectiveRect.TRect
  GetRandomRectAroundPlayer(*Player, @ObjectiveRect, *Player\Width * 10,
                            *Player\Height * 10, *BananaEnemy\Width, *BananaEnemy\Height)
  
  *BananaEnemy\ObjectiveRect = ObjectiveRect
  
  UpdateMiddlePositionGameObject(*BananaEnemy)
  
  Protected DeltaX.f = ObjectiveRect\Position\x - *BananaEnemy\Position\x
  Protected DeltaY.f = ObjectiveRect\Position\y - *BananaEnemy\Position\y
  
  Protected Angle.f = ATan2(DeltaX, DeltaY)
  
  *BananaEnemy\Velocity\x = Cos(Angle) * *BananaEnemy\MaxVelocity\x
  *BananaEnemy\Velocity\y = Sin(Angle) * *BananaEnemy\MaxVelocity\y
  
  
  SwitchStateEnemy(*BananaEnemy, #EnemyGoingToObjectiveRect)
EndProcedure

Procedure SwitchToWaitingEnemy(*Enemy.TEnemy, WaitTimer.f = 1.5)
  *Enemy\Velocity\x = 0
  *Enemy\Velocity\y = 0
  *Enemy\WaitTimer = WaitTimer
  SwitchStateEnemy(*Enemy, #EnemyWaiting)
EndProcedure

Procedure UpdateBananaEnemy(*BananaEnemy.TEnemy, TimeSlice.f)
  
  If *BananaEnemy\CurrentState = #EnemyNoState
    SwitchToWaitingEnemy(*BananaEnemy, 1.0)
    ProcedureReturn
  EndIf
  
  If *BananaEnemy\CurrentState = #EnemyGoingToObjectiveRect
    If HasReachedObjectiveRectEnemy(*BananaEnemy)
      SwitchToWaitingEnemy(*BananaEnemy)
      ProcedureReturn
    EndIf
  ElseIf *BananaEnemy\CurrentState = #EnemyWaiting
    *BananaEnemy\WaitTimer - TimeSlice
    If *BananaEnemy\WaitTimer <= 0.0
      SwitchToGoingToObjectiveRectEnemy(*BananaEnemy)
      ProcedureReturn
    EndIf
  EndIf
  
  
  
  UpdateGameObject(*BananaEnemy, TimeSlice)
  
  
EndProcedure

Procedure DrawEnemy(*Enemy.TEnemy)
  DrawGameObject(*Enemy)
EndProcedure

Procedure InitBananaEnemy(*BananaEnemy.TEnemy, *Player.TGameObject, *Position.TVector2D,
                          SpriteNum.i, ZoomFactor.f, *ProjectileList.TProjectileList)
  
  InitEnemy(*BananaEnemy, *Player, *ProjectileList)
  
  *BananaEnemy\Health = 1.0
  
  InitGameObject(*BananaEnemy, *Position, SpriteNum, @UpdateBananaEnemy(), @DrawEnemy(),
                 #True, ZoomFactor)
  
  *BananaEnemy\MaxVelocity\x = 100.0
  *BananaEnemy\MaxVelocity\y = 100.0
  
  *BananaEnemy\CurrentState = #EnemyNoState
  
  ;some initialization for the bananaenemy
  
  
  
  
EndProcedure

Procedure SwitchToFollowingPlayerEnemy(*Enemy.TEnemy, FollowPlayerTimer.f = 1.0)
  Protected *Player.TGameObject = *Enemy\Player
  
  UpdateMiddlePositionGameObject(*Enemy)
  UpdateMiddlePositionGameObject(*Player)
  
  Protected DeltaX.f = *Player\MiddlePosition\x - *Enemy\MiddlePosition\x
  Protected DeltaY.f = *Player\MiddlePosition\y - *Enemy\MiddlePosition\y
  Protected Angle.f = ATan2(DeltaX, DeltaY)
  
  *Enemy\Velocity\x = Cos(Angle) * *Enemy\MaxVelocity\x
  *Enemy\Velocity\y = Sin(Angle) * *Enemy\MaxVelocity\y
  *Enemy\FollowPlayerTimer = FollowPlayerTimer
  SwitchStateEnemy(*Enemy, #EnemyFollowingPlayer)
EndProcedure

Procedure.a IsCloseEneoughToPlayerEnemy(*Enemy.TEnemy, CloseEnoughDistance.f)
  
  UpdateMiddlePositionGameObject(*Enemy)
  UpdateMiddlePositionGameObject(*Enemy\Player)
  
  Protected DistanceToPlayer.f = DistanceBetweenPoints(*Enemy\MiddlePosition\x,
                                                       *Enemy\MiddlePosition\y,
                                                       *Enemy\Player\MiddlePosition\x,
                                                       *Enemy\Player\MiddlePosition\y)
  ProcedureReturn Bool(DistanceToPlayer <= CloseEnoughDistance)
  
EndProcedure

Procedure SwitchToShootingTargetEnemy(*Enemy.TEnemy, ShootingTimer.f, *Target.TGameObject,
                                      NumShots.a = 1, TimerBetweenShots.f = 0.0)
  *Enemy\Velocity\x = 0
  *Enemy\Velocity\y = 0
  *Enemy\ShootingTarget = *Target
  *Enemy\ShootingTimer = ShootingTimer
  *Enemy\NumShots = NumShots
  *Enemy\TimerBetweenShots = TimerBetweenShots
  *Enemy\CurrentTimerBetweenShots = TimerBetweenShots
  SwitchStateEnemy(*Enemy, #EnemyShooting)
EndProcedure

Procedure SwitchToShootingAreaEnemy(*Enemy.TEnemy, *TargetArea.TRect)
  CopyStructure(*TargetArea, *Enemy\ShootingArea, TRect)
  SwitchStateEnemy(*Enemy, #EnemyShooting)
EndProcedure

Procedure ShootAppleEnemy(*AppleEnemy.TEnemy)
  Protected *Projectile.TProjectile = GetInactiveProjectile(*AppleEnemy\Projectiles)
  
  UpdateMiddlePositionGameObject(*AppleEnemy)
  UpdateMiddlePositionGameObject(*AppleEnemy\ShootingTarget)
  
  Protected *Target.TGameObject = *AppleEnemy\ShootingTarget
  
  Protected DeltaX.f, DeltaY.f, Distance.f
  DeltaX = *Target\MiddlePosition\x - *AppleEnemy\MiddlePosition\x
  DeltaY = *Target\MiddlePosition\y - *AppleEnemy\MiddlePosition\y
  Distance = Sqr(DeltaX * DeltaX + DeltaY * DeltaY)
  
  Protected Angle.f = ATan2(DeltaX, DeltaY)
  
  Protected Position.TVector2D
  
  InitProjectile(*Projectile, @Position, #True, #SPRITES_ZOOM, Angle, #ProjectileBarf1)
  Position\x = *AppleEnemy\MiddlePosition\x - *Projectile\Width / 2
  Position\y = *AppleEnemy\MiddlePosition\y - *Projectile\Height / 2
  
  *Projectile\Position = Position
  
  Protected ProjectileAliveTimer.f = Distance / *Projectile\Velocity\x + 0.1
  *Projectile\HasAliveTimer = #True
  *Projectile\AliveTimer = ProjectileAliveTimer
  
EndProcedure


Procedure UpdateAppleEnemy(*AppleEnemy.TEnemy, TimeSlice.f)
  If *AppleEnemy\CurrentState = #EnemyNoState
    SwitchToFollowingPlayerEnemy(*AppleEnemy)
    ProcedureReturn
  EndIf
  
  If *AppleEnemy\CurrentState = #EnemyFollowingPlayer
    If IsCloseEneoughToPlayerEnemy(*AppleEnemy, 6 * *AppleEnemy\Width)
      ;Debug "close enough to shoot"
      SwitchToShootingTargetEnemy(*AppleEnemy, 0.5, *AppleEnemy\Player)
      ;ProcedureReturn
    EndIf
    
    *AppleEnemy\FollowPlayerTimer - TimeSlice
    If *AppleEnemy\FollowPlayerTimer <= 0
      ;readjust with the current player's position
      SwitchToFollowingPlayerEnemy(*AppleEnemy)
      ProcedureReturn
    EndIf
    
  ElseIf *AppleEnemy\CurrentState = #EnemyShooting
    *AppleEnemy\ShootingTimer - TimeSlice
    If *AppleEnemy\ShootingTimer <= 0
      ShootAppleEnemy(*AppleEnemy)
      SwitchToWaitingEnemy(*AppleEnemy, 2)
    EndIf
    
  ElseIf *AppleEnemy\CurrentState = #EnemyWaiting
    *AppleEnemy\WaitTimer - TimeSlice
    If *AppleEnemy\WaitTimer <= 0
      SwitchToFollowingPlayerEnemy(*AppleEnemy)
      ProcedureReturn
    EndIf
    
    
    
  EndIf
  
  
  UpdateGameObject(*AppleEnemy, TimeSlice)
  
EndProcedure

Procedure DrawAppleEnemy(*AppleEnemy.TEnemy)
  DrawEnemy(*AppleEnemy)
  UpdateMiddlePositionGameObject(*AppleEnemy)
  UpdateMiddlePositionGameObject(*AppleEnemy\Player)
  
  If IsCloseEneoughToPlayerEnemy(*AppleEnemy, 6 * *AppleEnemy\Width)
    
    
    StartDrawing(ScreenOutput())
    LineXY(*AppleEnemy\MiddlePosition\x, *AppleEnemy\MiddlePosition\y, *AppleEnemy\Player\MiddlePosition\x,
           *AppleEnemy\Player\MiddlePosition\y, RGB(150, 30, 30))
    StopDrawing()
    ;Debug "close enough to shoot"
    ;SwitchToShootingTargetEnemy(*AppleEnemy, *AppleEnemy\Player)
    ;ProcedureReturn
  EndIf
EndProcedure

Procedure InitAppleEnemy(*AppleEnemy.TEnemy, *Player.TGameObject, *Position.TVector2D,
                         SpriteNum.i, ZoomFactor.f, *ProjectileList.TProjectileList)
  
  InitEnemy(*AppleEnemy, *Player, *ProjectileList)
  
  *AppleEnemy\Health = 2.0
  
  InitGameObject(*AppleEnemy, *Position, SpriteNum, @UpdateAppleEnemy(), @DrawAppleEnemy(),
                 #True, ZoomFactor)
  
  *AppleEnemy\MaxVelocity\x = 80.0
  *AppleEnemy\MaxVelocity\y = 80.0
  
  *AppleEnemy\CurrentState = #EnemyNoState
  
  
EndProcedure

Procedure ShootGrapeEnemy(*GrapeEnemy.TEnemy, TimeSlice.f)
  *GrapeEnemy\CurrentTimerBetweenShots - TimeSlice
  If *GrapeEnemy\CurrentTimerBetweenShots <= 0 And *GrapeEnemy\NumShots > 0
    *GrapeEnemy\CurrentTimerBetweenShots = *GrapeEnemy\TimerBetweenShots
    
    Protected *Projectile.TProjectile = GetInactiveProjectile(*GrapeEnemy\Projectiles)
    
    UpdateMiddlePositionGameObject(*GrapeEnemy)
    UpdateMiddlePositionGameObject(*GrapeEnemy\ShootingTarget)
    
    Protected *Target.TGameObject = *GrapeEnemy\ShootingTarget
    
    Protected DeltaX.f, DeltaY.f, Distance.f
    DeltaX = *Target\MiddlePosition\x - *GrapeEnemy\MiddlePosition\x
    DeltaY = *Target\MiddlePosition\y - *GrapeEnemy\MiddlePosition\y
    Distance = Sqr(DeltaX * DeltaX + DeltaY * DeltaY)
    
    Protected Angle.f = ATan2(DeltaX, DeltaY)
    Angle + *GrapeEnemy\CurrentAngleShot
    *GrapeEnemy\CurrentAngleShot + Radian(25.0)
    
    Protected Position.TVector2D
    
    InitProjectile(*Projectile, @Position, #True, #SPRITES_ZOOM, Angle, #ProjectileGrape1)
    Position\x = *GrapeEnemy\MiddlePosition\x - *Projectile\Width / 2
    Position\y = *GrapeEnemy\MiddlePosition\y - *Projectile\Height / 2
    
    *Projectile\Position = Position
    
    *GrapeEnemy\NumShots - 1
    If *GrapeEnemy\NumShots < 1
      ;ended the shots
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
    
    
    ;Protected ProjectileAliveTimer.f = Distance / *Projectile\Velocity\x + 0.1
    ;*Projectile\HasAliveTimer = #True
    ;*Projectile\AliveTimer = ProjectileAliveTimer
  EndIf
  
  ProcedureReturn #False
  
EndProcedure


Procedure UpdateGrapeEnemy(*GrapeEnemy.TEnemy, TimeSlice.f)
  If *GrapeEnemy\CurrentState = #EnemyNoState
    SwitchToFollowingPlayerEnemy(*GrapeEnemy)
    ProcedureReturn
  EndIf
  
  If *GrapeEnemy\CurrentState = #EnemyFollowingPlayer
    If IsCloseEneoughToPlayerEnemy(*GrapeEnemy, 8 * *GrapeEnemy\Width)
      
      SwitchToShootingTargetEnemy(*GrapeEnemy, 1, *GrapeEnemy\Player, 3, 0.5)
      ;the first shot is off -25 degrees from the target
      *GrapeEnemy\CurrentAngleShot = Radian(-25.0)
    EndIf
    
    *GrapeEnemy\FollowPlayerTimer - TimeSlice
    If *GrapeEnemy\FollowPlayerTimer <= 0
      ;readjust with the current player's position
      SwitchToFollowingPlayerEnemy(*GrapeEnemy)
      ProcedureReturn
    EndIf
    
  ElseIf *GrapeEnemy\CurrentState = #EnemyShooting
    *GrapeEnemy\ShootingTimer - TimeSlice
    If *GrapeEnemy\ShootingTimer <= 0
      If ShootGrapeEnemy(*GrapeEnemy, TimeSlice)
        ;ended all shots
        SwitchToWaitingEnemy(*GrapeEnemy, 2)
      EndIf
      
      
    EndIf
    
  ElseIf *GrapeEnemy\CurrentState = #EnemyWaiting
    *GrapeEnemy\WaitTimer - TimeSlice
    If *GrapeEnemy\WaitTimer <= 0
      SwitchToFollowingPlayerEnemy(*GrapeEnemy)
      ProcedureReturn
    EndIf
    
    
    
  EndIf
  
  
  UpdateGameObject(*GrapeEnemy, TimeSlice)
EndProcedure

Procedure InitGrapeEnemy(*GrapeEnemy.TEnemy, *Player.TGameObject, *Position.TVector2D,
                         SpriteNum.i, ZoomFactor.f, *ProjectileList.TProjectileList)
  
  InitEnemy(*GrapeEnemy, *Player, *ProjectileList)
  
  *GrapeEnemy\Health = 2.0
  
  InitGameObject(*GrapeEnemy, *Position, SpriteNum, @UpdateGrapeEnemy(), @DrawAppleEnemy(),
                 #True, ZoomFactor)
  
  *GrapeEnemy\MaxVelocity\x = 80.0
  *GrapeEnemy\MaxVelocity\y = 80.0
  
  *GrapeEnemy\CurrentState = #EnemyNoState
  
  
EndProcedure

Procedure KillEnemy(*Enemy.TEnemy)
  *Enemy\Active = #False
EndProcedure


Procedure HurtEnemy(*Enemy.TEnemy, Power.f)
  *Enemy\Health - Power
  If *Enemy\Health <= 0.0
    KillEnemy(*Enemy)
  EndIf
  
EndProcedure





DisableExplicit