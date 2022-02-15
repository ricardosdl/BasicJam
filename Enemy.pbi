XIncludeFile "GameObject.pbi"

EnableExplicit

Enumeration EEnemyStates
  #EnemyNoState
  #EnemyPatrolling
EndEnumeration

Structure TEnemy Extends TGameObject
  *Player.TGameObject
  CurrentState.a
  LastState.a
  
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
  If *BananaEnemy\CurrentState = #EnemyNoState
    ;lets start some state
    *BananaEnemy\LastState = *BananaEnemy\CurrentState
    *BananaEnemy\CurrentState = #EnemyPatrolling
    SetVelocityPatrollingBananaEnemy(*BananaEnemy)
    ProcedureReturn
  EndIf
  
  UpdateGameObject(*BananaEnemy, TimeSlice)
  
  If *BananaEnemy\Position\x < 0 Or
     (*BananaEnemy\Position\x + *BananaEnemy\Width > ScreenWidth())
    
    *BananaEnemy\Velocity\x * -1
    
    
  EndIf
  
  If *BananaEnemy\Position\y < 0 Or
     (*BananaEnemy\Position\y + *BananaEnemy\Health > ScreenHeight())
    
    *BananaEnemy\Velocity\y * -1
    
    
  EndIf
  
  
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