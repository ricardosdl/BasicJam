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
  StateTimer.f
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

Procedure SwitchToGoingToObjectiveRectEnemy(*Enemy.TEnemy, *ObjectiveRect.TRect, StateTimer.f = 1.0)
  CopyStructure(*ObjectiveRect, @*Enemy\ObjectiveRect, TRect)
  
  UpdateMiddlePositionGameObject(*Enemy)
  
  Protected DeltaX.f = *ObjectiveRect\Position\x - *Enemy\MiddlePosition\x
  Protected DeltaY.f = *ObjectiveRect\Position\y - *Enemy\MiddlePosition\y
  
  Protected Angle.f = ATan2(DeltaX, DeltaY)
  
  *Enemy\Velocity\x = Cos(Angle) * *Enemy\MaxVelocity\x
  *Enemy\Velocity\y = Sin(Angle) * *Enemy\MaxVelocity\y
  
  *Enemy\StateTimer = StateTimer
  SwitchStateEnemy(*Enemy, #EnemyGoingToObjectiveRect)
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
      Protected ObjectiveRect.TRect
      Protected *Player.TGameObject = *BananaEnemy\Player
      GetRandomRectAroundPlayer(*Player, @ObjectiveRect, *Player\Width * 10,
                            *Player\Height * 10, *BananaEnemy\Width, *BananaEnemy\Height)
      SwitchToGoingToObjectiveRectEnemy(*BananaEnemy, @ObjectiveRect)
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

Procedure SwitchToFollowingPlayerEnemy(*Enemy.TEnemy, StateTimer.f = 1.0)
  Protected *Player.TGameObject = *Enemy\Player
  
  UpdateMiddlePositionGameObject(*Enemy)
  UpdateMiddlePositionGameObject(*Player)
  
  Protected DeltaX.f = *Player\MiddlePosition\x - *Enemy\MiddlePosition\x
  Protected DeltaY.f = *Player\MiddlePosition\y - *Enemy\MiddlePosition\y
  Protected Angle.f = ATan2(DeltaX, DeltaY)
  
  *Enemy\Velocity\x = Cos(Angle) * *Enemy\MaxVelocity\x
  *Enemy\Velocity\y = Sin(Angle) * *Enemy\MaxVelocity\y
  *Enemy\StateTimer = StateTimer
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

Procedure SwitchToShootingAreaEnemy(*Enemy.TEnemy, *TargetArea.TRect, ShootingTimer.f, NumShots.a = 1,
                                    TimerBetweenShots.f = 0.0)
  CopyStructure(*TargetArea, *Enemy\ShootingArea, TRect)
  *Enemy\ShootingTimer = ShootingTimer
  *Enemy\NumShots = NumShots
  *Enemy\TimerBetweenShots = TimerBetweenShots
  *Enemy\CurrentTimerBetweenShots = TimerBetweenShots
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
    
    *AppleEnemy\StateTimer - TimeSlice
    If *AppleEnemy\StateTimer <= 0
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
    *GrapeEnemy\CurrentAngleShot + Radian(30.0 / 3)
    
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
      ;the first shot is off -30/3 degrees from the target
      *GrapeEnemy\CurrentAngleShot = Radian(-30.0 / 3)
    EndIf
    
    *GrapeEnemy\StateTimer - TimeSlice
    If *GrapeEnemy\StateTimer <= 0
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

Procedure ShootWatermelonEnemy(*WatermelonEnemy.TEnemy, TimeSlice.f)
  
  *WatermelonEnemy\CurrentTimerBetweenShots - TimeSlice
  If *WatermelonEnemy\CurrentTimerBetweenShots <= 0 And *WatermelonEnemy\NumShots > 0
    ;restore the timer
    *WatermelonEnemy\CurrentTimerBetweenShots = *WatermelonEnemy\TimerBetweenShots
    
    UpdateMiddlePositionGameObject(*WatermelonEnemy)
    
    ;the shots are distributed over the targetarea in 3x3 rows and cols
    Protected ShotsPerRow.a = 3
    
    Protected *TargetArea.TRect = @*WatermelonEnemy\ShootingArea
    
    Protected *Projectile.TProjectile = GetInactiveProjectile(*WatermelonEnemy\Projectiles)
    
    Protected.a TargetRow, TargetCol
    ;get the targetrow (0..2) and target col(0..2)
    TargetRow = (*WatermelonEnemy\NumShots - 1) / ShotsPerRow
    TargetCol = (*WatermelonEnemy\NumShots - 1) % ShotsPerRow
    
    ;the position where the projectile will land
    Protected TargetPosition.TVector2D
    
    ;the width of each row
    Protected QuadrantWidth.f = *TargetArea\Width / ShotsPerRow
    ;the height of each col
    Protected QuadrantHeight.f = *TargetArea\Height / ShotsPerRow
    
    ;the target position is centralized inside each quadrant
    TargetPosition\x = *TargetArea\Position\x + (QuadrantWidth) * TargetCol + (QuadrantWidth / 2)
    TargetPosition\y = *TargetArea\Position\y + (QuadrantHeight) * TargetRow + (QuadrantHeight / 2)
    
    ;get the distance and the angle in which the projectile will travel
    Protected DeltaX.f, DeltaY.f, Distance.f
    DeltaX = TargetPosition\x - *WatermelonEnemy\MiddlePosition\x
    DeltaY = TargetPosition\y - *WatermelonEnemy\MiddlePosition\y
    Distance = Sqr(DeltaX * DeltaX + DeltaY * DeltaY)
    
    Protected Angle.f = ATan2(DeltaX, DeltaY)
    
    Protected Position.TVector2D
    
    InitProjectile(*Projectile, @Position, #True, #SPRITES_ZOOM, Angle, #ProjectileSeed1)
    Position\x = *WatermelonEnemy\MiddlePosition\x - *Projectile\Width / 2
    Position\y = *WatermelonEnemy\MiddlePosition\y - *Projectile\Height / 2
    
    *Projectile\Position = Position
    *Projectile\Angle = RandomInterval(2 * #PI, 0)
    
    ;the projectile velocity on both axis
    Protected ProjectileVel.f = Sqr(*Projectile\Velocity\x * *Projectile\Velocity\x +
                                    *Projectile\Velocity\y * *Projectile\Velocity\y)
    
    Protected ProjectileAliveTimer.f = Distance / ProjectileVel
    *Projectile\HasAliveTimer = #True
    *Projectile\AliveTimer = ProjectileAliveTimer
    
    *WatermelonEnemy\NumShots - 1
    
    If *WatermelonEnemy\NumShots < 1
      ProcedureReturn #True
    EndIf
  EndIf
  
  
  ProcedureReturn #False
  
EndProcedure

Procedure UpdateWatermelonEnemy(*WatermelonEnemy.TEnemy, TimeSlice.f)
  If *WatermelonEnemy\CurrentState = #EnemyNoState
    SwitchToFollowingPlayerEnemy(*WatermelonEnemy)
    ProcedureReturn
  EndIf
  
  If *WatermelonEnemy\CurrentState = #EnemyFollowingPlayer
    If IsCloseEneoughToPlayerEnemy(*WatermelonEnemy, 10 * *WatermelonEnemy\Width)
      
      ;SwitchToShootingTargetEnemy(*WatermelonEnemy, 1, *WatermelonEnemy\Player, 3, 0.5)
      Protected AreaAroundPlayer.TRect
      AreaAroundPlayer\Width = *WatermelonEnemy\Player\Width * 5
      AreaAroundPlayer\Height = *WatermelonEnemy\Player\Height * 5
      AreaAroundPlayer\Position\x = *WatermelonEnemy\Player\Position\x - (AreaAroundPlayer\Width / 2)
      AreaAroundPlayer\Position\y = *WatermelonEnemy\Player\Position\y - (AreaAroundPlayer\Height / 2)
      
      
      SwitchToShootingAreaEnemy(*WatermelonEnemy, @AreaAroundPlayer, 1.5, 9, 0.3)
    EndIf
    
    *WatermelonEnemy\StateTimer - TimeSlice
    If *WatermelonEnemy\StateTimer <= 0
      ;readjust with the current player's position
      SwitchToFollowingPlayerEnemy(*WatermelonEnemy)
      ProcedureReturn
    EndIf
    
  ElseIf *WatermelonEnemy\CurrentState = #EnemyShooting
    *WatermelonEnemy\ShootingTimer - TimeSlice
    If *WatermelonEnemy\ShootingTimer <= 0
      If ShootWatermelonEnemy(*WatermelonEnemy, TimeSlice)
        ;ended all shots
        SwitchToWaitingEnemy(*WatermelonEnemy, 2)
      EndIf
      
      
    EndIf
    
  ElseIf *WatermelonEnemy\CurrentState = #EnemyWaiting
    *WatermelonEnemy\WaitTimer - TimeSlice
    If *WatermelonEnemy\WaitTimer <= 0
      SwitchToFollowingPlayerEnemy(*WatermelonEnemy)
      ProcedureReturn
    EndIf
    
    
    
  EndIf
  
  
  UpdateGameObject(*WatermelonEnemy, TimeSlice)
EndProcedure

Procedure DrawWatermelonEnemy(*WatermelonEnemy.TEnemy)
  DrawEnemy(*WatermelonEnemy)
EndProcedure

Procedure InitWatermelonEnemy(*WatermelonEnemy.TEnemy, *Player.TGameObject, *Position.TVector2D,
                         SpriteNum.i, ZoomFactor.f, *ProjectileList.TProjectileList)
  
  InitEnemy(*WatermelonEnemy, *Player, *ProjectileList)
  
  *WatermelonEnemy\Health = 3.0
  
  InitGameObject(*WatermelonEnemy, *Position, SpriteNum, @UpdateWatermelonEnemy(), @DrawWatermelonEnemy(),
                 #True, ZoomFactor)
  
  *WatermelonEnemy\MaxVelocity\x = 80.0
  *WatermelonEnemy\MaxVelocity\y = 80.0
  
  *WatermelonEnemy\CurrentState = #EnemyNoState
  
  
EndProcedure

Procedure ShootTangerineEnemy(*TangerineEnemy.TEnemy, TimeSlice.f)
  Protected *Projectile.TProjectile = GetOwnedProjectile(*TangerineEnemy, *TangerineEnemy\Projectiles)
  If *Projectile <> #Null
  Else
    ;need to shoot a new one here
    *Projectile = GetInactiveProjectile(*TangerineEnemy\Projectiles)
    If *Projectile = #Null
      ProcedureReturn #True
    EndIf
    
    Protected Position.TVector2d
    
    Protected *Target.TGameObject = *TangerineEnemy\ShootingTarget
    
    UpdateMiddlePositionGameObject(*TangerineEnemy)
    UpdateMiddlePositionGameObject(*Target)
    
    
    Protected DeltaX.f, DeltaY.f, Distance.f
    DeltaX = *Target\MiddlePosition\x - *TangerineEnemy\MiddlePosition\x
    DeltaY = *Target\MiddlePosition\y - *TangerineEnemy\MiddlePosition\y
    ;Distance = Sqr(DeltaX * DeltaX + DeltaY * DeltaY)
    Protected Angle.f = ATan2(DeltaX, DeltaY)
    
    InitProjectile(*Projectile, @Position, #True, #SPRITES_ZOOM, Angle, #ProjectileGomo1,
                   #False, 0, *TangerineEnemy)
    
    
    Position\x = *TangerineEnemy\MiddlePosition\x - (*Projectile\Width / 2)
    Position\y = *TangerineEnemy\MiddlePosition\y - (*Projectile\Height / 2)
    
    *Projectile\Position = Position
    
    NewList WayPoints.TRect()
    
    ;the first waypoint is the target positon
    Protected FirstWayPoint.TRect
    FirstWayPoint\Position\x = *Target\MiddlePosition\x
    FirstWayPoint\Position\y = *Target\MiddlePosition\y
    AddElement(WayPoints())
    WayPoints() = FirstWayPoint
    
    
    ;the second point is beyond (to the left or tight) of the first and rotated 30 degrees
    Protected SecondWayPoint.TRect\Position = FirstWayPoint\Position
    Protected SignDeltaX.f = Sign(*Target\Position\x - *TangerineEnemy\Position\x)
    SecondWayPoint\Position\x + (3 * *Target\Width) * SignDeltaX
    RotateAroundPoint(FirstWayPoint\Position, @SecondWayPoint\Position, Radian(30))
    
    AddElement(WayPoints())
    WayPoints()\Position = SecondWayPoint\Position
    
    ;the third way point is the first one rotated 60 degrees around the tangerine position
    Protected ThirdWayPoint.TRect\Position = FirstWayPoint\Position
    ThirdWayPoint\Position\y + (3 * *Target\Width) * (Sign(*Target\Position\y - *TangerineEnemy\Position\y))
    RotateAroundPoint(FirstWayPoint\Position, @ThirdWayPoint\Position, Radian(30))
    
    AddElement(WayPoints())
    WayPoints()\Position = ThirdWayPoint\Position
    
    
    ;the fourth waypoint is at the tangerineenemy position, because the projectile will
    ;return to the enemy
    AddElement(WayPoints())
    WayPoints()\Position = *TangerineEnemy\MiddlePosition
    
    
    ;all waypoints have the same width and height
    ForEach WayPoints()
      WayPoints()\Width = *Projectile\Width * 0.8
      WayPoints()\Height = *Projectile\Height * 0.8
    Next
    
    SetWayPointsProjectile(*Projectile, WayPoints())
    
    
    
    
    
    
    
  EndIf
  
EndProcedure

Procedure UpdateTangerineEnemy(*TangerineEnemy.TEnemy, TimeSlice.f)
  Protected *Player.TGameObject = *TangerineEnemy\Player
  If *TangerineEnemy\CurrentState = #EnemyNoState
    UpdateMiddlePositionGameObject(*TangerineEnemy)
    UpdateMiddlePositionGameObject(*Player)
    
    Protected DeltaX.f = *TangerineEnemy\MiddlePosition\x - *Player\MiddlePosition\x
    Protected DeltaY.f = *TangerineEnemy\MiddlePosition\y - *Player\MiddlePosition\y
    Protected Angle.f = ATan2(DeltaX, DeltaY)
    
    Protected ObjectiveRect.TRect\Width = *TangerineEnemy\Width * 0.8
    ObjectiveRect\Height = *TangerineEnemy\Height * 0.8
    
    Protected Radius.f = *Player\Width * 5
    
    ObjectiveRect\Position\x = *Player\MiddlePosition\x + Radius * Cos(angle)
    ObjectiveRect\Position\y = *Player\MiddlePosition\y + Radius * Sin(angle)
    
    
    SwitchToGoingToObjectiveRectEnemy(*TangerineEnemy, @ObjectiveRect)
    ProcedureReturn
  EndIf
  
  If *TangerineEnemy\CurrentState = #EnemyGoingToObjectiveRect
    If HasReachedObjectiveRectEnemy(*TangerineEnemy)
      SwitchToShootingTargetEnemy(*TangerineEnemy, 0.1, *TangerineEnemy\Player)
      ProcedureReturn
    EndIf
    
    *TangerineEnemy\StateTimer - TimeSlice
    If *TangerineEnemy\StateTimer <= 0
      ;so we can go end retarget the objective rect
      SwitchStateEnemy(*TangerineEnemy, #EnemyNoState)
      ProcedureReturn
    EndIf
  ElseIf *TangerineEnemy\CurrentState = #EnemyShooting
    *TangerineEnemy\ShootingTimer - TimeSlice
    If *TangerineEnemy\ShootingTimer <= 0
      If ShootTangerineEnemy(*TangerineEnemy, TimeSlice)
        ;ended all shots
        SwitchToWaitingEnemy(*TangerineEnemy, #EnemyNoState)
      EndIf
      
      
    EndIf
    
  ElseIf *TangerineEnemy\CurrentState = #EnemyWaiting
    *TangerineEnemy\WaitTimer - TimeSlice
    If *TangerineEnemy\WaitTimer <= 0
      SwitchToFollowingPlayerEnemy(*TangerineEnemy)
      ProcedureReturn
    EndIf
    
    
    
  EndIf
  
  
  UpdateGameObject(*TangerineEnemy, TimeSlice)
EndProcedure

Procedure DrawTangerineEnemy(*TangerineEnemy.TEnemy)
  If *TangerineEnemy\CurrentState = #EnemyGoingToObjectiveRect
    StartDrawing(ScreenOutput())
    Box(*TangerineEnemy\ObjectiveRect\Position\x, *TangerineEnemy\ObjectiveRect\Position\y,
        *TangerineEnemy\ObjectiveRect\Width, *TangerineEnemy\ObjectiveRect\Height, RGB($55, $65, $47))
    StopDrawing()
  EndIf
  
  DrawEnemy(*TangerineEnemy)
EndProcedure

Procedure InitTangerineEnemy(*TangerineEnemy.TEnemy, *Player.TGameObject, *Position.TVector2D,
                            SpriteNum.i, ZoomFactor.f, *ProjectileList.TProjectileList)
  
  InitEnemy(*TangerineEnemy, *Player, *ProjectileList)
  
  *TangerineEnemy\Health = 4.0
  
  InitGameObject(*TangerineEnemy, *Position, SpriteNum, @UpdateTangerineEnemy(), @DrawTangerineEnemy(),
                 #True, ZoomFactor)
  
  *TangerineEnemy\MaxVelocity\x = 80.0
  *TangerineEnemy\MaxVelocity\y = 80.0
  
  *TangerineEnemy\CurrentState = #EnemyNoState
  
  
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