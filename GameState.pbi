﻿XIncludeFile "Math.pbi"
XIncludeFile "GameObject.pbi"
XIncludeFile "Enemy.pbi"
XIncludeFile "Util.pbi"
EnableExplicit

Prototype StartGameStateProc(*GameState)
Prototype EndGameStateProc(*GameState)
Prototype UpdateGameStateProc(*GameState, TimeSlice.f)
Prototype DrawGameStateProc(*GameState)

Enumeration ESprites
  #Player1
  #Banana
EndEnumeration

Enumeration EGameStates
  #NoGameState
  #MenuState
  #PlayState
  #GameOverState
EndEnumeration
#NUM_GAME_STATES = 4

#MAX_ENEMIES = 100


Structure TGameState
  GameState.a
  *StartGameState.StartGameStateProc
  *EndGameState.EndGameStateProc
  *UpdateGameState.UpdateGameStateProc
  *DrawGameState.DrawGameStateProc
EndStructure

Structure TGameStateManager
  Array *GameStates.TGameState(#NUM_GAME_STATES - 1)
  CurrentGameState.b
  LastGameState.b
EndStructure

Structure TPlayState Extends TGameState
  Player.TGameObject
  Array Enemies.TEnemy(#MAX_ENEMIES - 1)
  CurrentLevel.a
EndStructure



Global GameStateManager.TGameStateManager, PlayState.TPlayState

Procedure DrawCurrentStateGameSateManager(*GameStateManager.TGameStateManager)
  Protected *GameState.TGameState = *GameStateManager\GameStates(*GameStateManager\CurrentGameState)
  *GameState\DrawGameState(*GameState)
EndProcedure

Procedure UpdateCurrentStateGameStateManager(*GameStateManager.TGameStateManager, TimeSlice.f)
  Protected *GameState.TGameState = *GameStateManager\GameStates(*GameStateManager\CurrentGameState)
  *GameState\UpdateGameState(*GameState, TimeSlice)
EndProcedure

Procedure.i GetInactiveEnemyPlayState(*PlayState.TPlayState)
  Protected i = 0, EnemiesSize = ArraySize(*PlayState\Enemies())
  For i = 0 To EnemiesSize
    Protected *Enemy.TEnemy = @*PlayState\Enemies(i)
    If *Enemy\Active = #False
      ProcedureReturn *Enemy
    EndIf
  Next
  
  ProcedureReturn #Null
  
    
EndProcedure

Procedure InitEnemiesPlayState(*PlayState.TPlayState)
  ;enemies that we'll add
  Protected NumEnemies = 60
  ;we add half on the left and half on the right
  Protected EnemiesToAdd = NumEnemies
  
  ;rect on left side
  Protected EnemiesRect.TRect\Width = ScreenWidth() / 6
  EnemiesRect\Height = ScreenHeight() / 4
  ;left side position
  EnemiesRect\Position\x = (ScreenWidth() / 4) - EnemiesRect\Width / 2
  
  ;the enemies spawn on the same y interval of the enemiesrect on both left and right
  EnemiesRect\Position\y = (ScreenHeight() / 2) - EnemiesRect\Height / 2
  
  Protected.f MaxLeftEnemyX, MinLeftEnemyX, MaxLeftEnemyY, MinLeftEnemyY
  MaxLeftEnemyX = EnemiesRect\Position\x + EnemiesRect\Width
  MinLeftEnemyX = EnemiesRect\Position\x
  
  MaxLeftEnemyY = EnemiesRect\Position\y + EnemiesRect\Height
  MinLeftEnemyY = EnemiesRect\Position\y
  
  While EnemiesToAdd
    Protected *Enemy.TEnemy = GetInactiveEnemyPlayState(*PlayState)
    If *Enemy = #Null
      ;no enemy available :(
      EnemiesToAdd - 1
      Continue
    EndIf
    
    If (EnemiesToAdd < NumEnemies / 2)
      ;change the rect position to the right of the screen
      EnemiesRect\Position\x = (ScreenWidth() / 4 * 3) - EnemiesRect\Width / 2
    EndIf
    
    MaxLeftEnemyX = EnemiesRect\Position\x + EnemiesRect\Width
    MinLeftEnemyX = EnemiesRect\Position\x
    
    
    Protected Position.TVector2d\x = Random(MaxLeftEnemyX, MinLeftEnemyX)
    Position\y = Random(MaxLeftEnemyY, MinLeftEnemyY)
    
    InitBananaEnemy(*Enemy, *PlayState\Player, @Position, #Banana, 2.5)
    
    *Enemy\Active = #True
    
    EnemiesToAdd - 1
  Wend
  
  
EndProcedure


Procedure StartPlayState(*PlayState.TPlayState)
  *PlayState\CurrentLevel = 1
  
  Protected *Player.TGameObject = @*PlayState\Player
  Protected PlayerPos.TVector2D\x = ScreenWidth() / 2
  PlayerPos\y = ScreenHeight() / 2
  
  
  InitGameObject(*Player, @PlayerPos, #Player1, #Null, @DrawGameObject(), #True, 2.5)
  
  InitEnemiesPlayState(*PlayState)
  
  
EndProcedure

Procedure UpdatePlayStatePlayer(*PlayState.TPlayState, TimeSlice.f)
  Protected *Player.TGameObject = @*PlayState\Player
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
  
  *Player\Position\x + *Player\Velocity\x * TimeSlice
  *Player\Position\y + *Player\Velocity\y * TimeSlice
  
  
  
  
EndProcedure

Procedure EndPlayState(*PlayState.TPlayState)
EndProcedure

Procedure UpdatePlayState(*PlayState.TPlayState, TimeSlice.f)
  UpdatePlayStatePlayer(*PlayState, TimeSlice)
EndProcedure

Procedure DrawPlayState(*PlayState.TPlayState)
  *PlayState\Player\DrawGameObject(*PlayState\Player)
  Protected i
  Protected EnemiesEndIdx = ArraySize(*PlayState\Enemies())
  For i = 0 To EnemiesEndIdx
    If *PlayState\Enemies(i)\Active
      *PlayState\Enemies(i)\DrawGameObject(@*PlayState\Enemies(i))
    EndIf
    
  Next
EndProcedure

Procedure InitGameSates()
  ;@GameStateManager\GameStates(#PlayState)
  PlayState\GameState = #PlayState
  
  PlayState\StartGameState = @StartPlayState()
  PlayState\EndGameState = @EndPlayState()
  PlayState\UpdateGameState = @UpdatePlayState()
  PlayState\DrawGameState = @DrawPlayState()
  
  GameStateManager\GameStates(#PlayState) = @PlayState
  GameStateManager\CurrentGameState = #NoGameState
  GameStateManager\LastGameState = #NoGameState
EndProcedure

Procedure SwitchGameState(*GameStateManager.TGameStateManager, NewGameState.a)
  Protected *CurrentGameState.TGameState = #Null
  If *GameStateManager\CurrentGameState <> #NoGameState
    *CurrentGameState = *GameStateManager\GameStates(*GameStateManager\CurrentGameState)
  EndIf
  
  If *CurrentGameState <> #Null
    *CurrentGameState\EndGameState(*CurrentGameState)
  EndIf
  
  *GameStateManager\LastGameState = *GameStateManager\CurrentGameState
  *GameStateManager\CurrentGameState = NewGameState
  
  Protected *NewGameState.TGameState = *GameStateManager\GameStates(NewGameState)
  *NewGameState\StartGameState(*NewGameState)
EndProcedure




DisableExplicit