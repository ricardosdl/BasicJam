XIncludeFile "Math.pbi"
XIncludeFile "GameObject.pbi"
XIncludeFile "Enemy.pbi"
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
  Protected HalfEnemies = NumEnemies / 2
  
  ;left side
  Protected LeftSideEnemies = HalfEnemies
  While LeftSideEnemies
    ;we add random number of enemies each time
    Protected EnemiesToAdd = Random(5, 1)
    
    While EnemiesToAdd
      Protected *Enemy.TEnemy = GetInactiveEnemyPlayState(*PlayState)
      If *Enemy = #Null
        ;no enemy available :(
        Continue
      EndIf
      
      
      ;InitBananaEnemy(*Enemy, *PlayState\Player, 
      
      EnemiesToAdd - 1
    Wend
    
    
    
    LeftSideEnemies - EnemiesToAdd
  Wend
  
  
EndProcedure


Procedure StartPlayState(*PlayState.TPlayState)
  *PlayState\CurrentLevel = 1
  
  Protected *Player.TGameObject = @*PlayState\Player
  Protected PlayerPos.TVector2D\x = ScreenWidth() / 2
  PlayerPos\y = ScreenHeight() / 2
  
  
  InitGameObject(*Player, @PlayerPos, 12, 12, #Player1, #Null, @DrawGameObject(), #True, 2.5)
  
  InitEnemiesPlayState(*PlayState)
  
  
EndProcedure

Procedure EndPlayState(*PlayState.TPlayState)
EndProcedure

Procedure UpdatePlayState(*PlayState.TPlayState, TimeSlice.f)
  
EndProcedure

Procedure DrawPlayState(*PlayState.TPlayState)
  *PlayState\Player\DrawGameObject(*PlayState\Player)
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