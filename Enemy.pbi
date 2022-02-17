XIncludeFile "GameObject.pbi"
XIncludeFile "Math.pbi"
XIncludeFile "Util.pbi"

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
EndStructure



Procedure InitEnemy(*Enemy.TEnemy, *Player.TGameObject)
  *Enemy\Player = *Player
  
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
                          SpriteNum.i, ZoomFactor.f)
  
  InitEnemy(*BananaEnemy, *Player)
  
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

Procedure SwitchToShootingTargetEnemy(*Enemy.TEnemy, ShootingTimer.f, *Target.TGameObject)
  *Enemy\Velocity\x = 0
  *Enemy\Velocity\y = 0
  *Enemy\ShootingTarget = *Target
  *Enemy\ShootingTimer = ShootingTimer
  SwitchStateEnemy(*Enemy, #EnemyShooting)
EndProcedure

Procedure SwitchToShootingAreaEnemy(*Enemy.TEnemy, *TargetArea.TRect)
  CopyStructure(*TargetArea, *Enemy\ShootingArea, TRect)
  SwitchStateEnemy(*Enemy, #EnemyShooting)
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
                         SpriteNum.i, ZoomFactor.f)
  
  InitEnemy(*AppleEnemy, *Player)
  
  *AppleEnemy\Health = 2.0
  
  InitGameObject(*AppleEnemy, *Position, SpriteNum, @UpdateAppleEnemy(), @DrawAppleEnemy(),
                 #True, ZoomFactor)
  
  *AppleEnemy\MaxVelocity\x = 80.0
  *AppleEnemy\MaxVelocity\y = 80.0
  
  *AppleEnemy\CurrentState = #EnemyNoState
  
  
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