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
EndStructure



Global GameStateManager.TGameStateManager, PlayState.TPlayState


Procedure StartPlayState(*PlayState.TPlayState)
  Protected *Player.TGameObject = @*PlayState\Player
  Protected PlayerPos.TVector2D\x = ScreenWidth() / 2
  PlayerPos\y = ScreenHeight() / 2
  
  
  InitGameObject(*Player, @PlayerPos, 12, 12, #Player1, #Null, @DrawGameObject(), 2.5)
EndProcedure

Procedure EndPlayState(*PlayState.TPlayState)
EndProcedure

Procedure UpdatePlayState(*PlayState.TPlayState, TimeSlice.f)
  
EndProcedure

Procedure DrawPlayState(*PlayState.TPlayState)
  
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