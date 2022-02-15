XIncludeFile "GameObject.pbi"
XIncludeFile "Math.pbi"
XIncludeFile "Util.pbi"

EnableExplicit

Enumeration EEnemyStates
  #EnemyNoState
  #EnemyGoingToObjectiveRect
  #EnemyWaiting
  #EnemyPatrolling
  
EndEnumeration

Structure TEnemy Extends TGameObject
  *Player.TGameObject
  CurrentState.a
  LastState.a
  ObjectiveRect.TRect;a rect that can be used as an objective point for the enemy to reach
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

Procedure UpdateBananaEnemy(*BananaEnemy.TEnemy, TimeSlice.f)
  Protected *Player.TGameObject = *BananaEnemy\Player
  If *BananaEnemy\CurrentState = #EnemyNoState
    ;lets start some state
    *BananaEnemy\LastState = *BananaEnemy\CurrentState
 
    Protected RectAroundPlayer.TRect
    GetRandomRectAroundGameObject(*Player, *Player\Width * 1.5, *Player\Height * 1.5,
                                  @RectAroundPlayer)
    
    ;lets get a random point inside the rect around the player
    Protected RandomPoint.TVector2D\x = Random(RectAroundPlayer\Position\x +
                                               RectAroundPlayer\Width,
                                               RectAroundPlayer\Position\x)
    RandomPoint\y = Random(RectAroundPlayer\Position\y + RectAroundPlayer\Height,
                           RectAroundPlayer\Position\y)
    
    Protected ObjectiveRect.TRect\Width = 4
    ObjectiveRect\Height = 4
    
    ;make sure the point is inside
    RandomPoint\x = ClampF(RandomPoint\x, 0, ScreenWidth() - ObjectiveRect\Width)
    RandomPoint\y = ClampF(RandomPoint\y, 0, ScreenHeight() - ObjectiveRect\Height)
    
    ObjectiveRect\Position = RandomPoint
    
    *BananaEnemy\CurrentState = #EnemyGoingToObjectiveRect
    ProcedureReturn
  EndIf
  
  If *BananaEnemy\CurrentState = #EnemyGoingToObjectiveRect
    
  EndIf
  
  
  UpdateGameObject(*BananaEnemy, TimeSlice)
  
  
EndProcedure

Procedure InitBananaEnemy(*BananaEnemy.TEnemy, *Player.TGameObject, *Position.TVector2D,
                          SpriteNum.i, ZoomFactor.f)
  
  InitEnemy(*BananaEnemy, *Player)
  
  *BananaEnemy\Health = 2.0
  
  InitGameObject(*BananaEnemy, *Position, SpriteNum, @UpdateBananaEnemy(), @DrawGameObject(),
                 #True, ZoomFactor)
  
  *BananaEnemy\MaxVelocity\x = 200.0
  *BananaEnemy\MaxVelocity\y = 200.0
  
  *BananaEnemy\CurrentState = #EnemyNoState
  
  ;some initialization for the bananaenemy
  
  
  
  
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