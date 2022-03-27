XIncludeFile "Math.pbi"
XIncludeFile "GameObject.pbi"
XIncludeFile "Enemy.pbi"
XIncludeFile "Player.pbi"
XIncludeFile "Projectile.pbi"
XIncludeFile "Resources.pbi"
XIncludeFile "Util.pbi"
EnableExplicit

Prototype StartGameStateProc(*GameState)
Prototype EndGameStateProc(*GameState)
Prototype UpdateGameStateProc(*GameState, TimeSlice.f)
Prototype DrawGameStateProc(*GameState)

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
  Player.TPlayer
  Array Enemies.TEnemy(#MAX_ENEMIES - 1)
  CurrentLevel.a
  MaxLevel.a
  PlayerProjectiles.TProjectileList
  EnemiesProjectiles.TProjectileList
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
  Protected NumEnemies = 1
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
    
    ;InitBananaEnemy(*Enemy, *PlayState\Player, @Position, #Banana, 2.5)
    ;InitAppleEnemy(*Enemy, *PlayState\Player, @Position, #Apple, 2.5, @*PlayState\EnemiesProjectiles)
    ;InitGrapeEnemy(*Enemy, *PlayState\Player, @Position, #Grape, 2.5, @*PlayState\EnemiesProjectiles)
    ;InitWatermelonEnemy(*Enemy, *PlayState\Player, @Position, #Watermelon, 2.5, @*PlayState\EnemiesProjectiles)
    ;InitTangerineEnemy(*Enemy, *PlayState\Player, @Position, #Tangerine, #SPRITES_ZOOM, @*PlayState\EnemiesProjectiles)
    ;InitPineappleEnemy(*Enemy, *PlayState\Player, @Position, #PineApple, #SPRITES_ZOOM)
    ;InitPineappleEnemy(*Enemy, *PlayState\Player, @Position, #Lemon, #SPRITES_ZOOM)
    InitLemonEnemy(*Enemy, *PlayState\Player, @Position, #Lemon, #SPRITES_ZOOM, @*PlayState\EnemiesProjectiles)
    
    *Enemy\Active = #True
    
    EnemiesToAdd - 1
  Wend
  
  
EndProcedure


Procedure StartPlayState(*PlayState.TPlayState)
  *PlayState\CurrentLevel = 1
  *PlayState\MaxLevel = 1;TODO: more levels
  
  Protected *Player.TPlayer = @*PlayState\Player
  Protected PlayerPos.TVector2D\x = ScreenWidth() / 2
  PlayerPos\y = ScreenHeight() / 2
  
  
  InitPlayer(*Player, @*PlayState\PlayerProjectiles, @PlayerPos, #Player1, 2.5)
  ;InitPlayer(*Player, #Null, @PlayerPos, #Player1, 2.5)
  
  InitEnemiesPlayState(*PlayState)
  
  
EndProcedure

Procedure EndPlayState(*PlayState.TPlayState)
EndProcedure

Procedure CollisionPlayerProjectileEnemies(*PlayState.TPlayState, *Projectile.TProjectile,
                                           TimeSlice.f)
  Protected i, IdxMax = ArraySize(*PlayState\Enemies())
  For i = 0 To IdxMax
    If *PlayState\Enemies(i)\Active
      Protected *Enemy.TEnemy = *PlayState\Enemies(i)
      Protected EnemyRect.TRect\Position = *Enemy\Position
      EnemyRect\Width = *Enemy\Width
      EnemyRect\Height = *Enemy\Height
      
      Protected ProjectileRect.TRect\Position = *Projectile\Position
      ProjectileRect\Width = *Projectile\Width
      ProjectileRect\Height = *Projectile\Height
      
      If CollisionRectRect(EnemyRect\Position\x, EnemyRect\Position\y, EnemyRect\Width,
                           EnemyRect\Height, ProjectileRect\Position\x,
                           ProjectileRect\Position\y, ProjectileRect\Width, ProjectileRect\Height)
        HurtProjectile(*Projectile, 1.0)
        HurtEnemy(*Enemy, *Projectile\Power)
        
      EndIf
      
    EndIf
    
  Next
  
EndProcedure


Procedure UpdateCollisionsPlayState(*PlayState.TPlayState, TimeSlice.f)
  ;collisions of player projectiles and enemies
  ForEach *PlayState\PlayerProjectiles\Projectiles()
    If *PlayState\PlayerProjectiles\Projectiles()\Active
      Protected *Projectile.TProjectile = *PlayState\PlayerProjectiles\Projectiles()
      CollisionPlayerProjectileEnemies(*PlayState, *Projectile, TimeSlice)
    EndIf
  Next
EndProcedure

Procedure.a FinishedEnemiesPlayState(*PlayState.TPlayState)
  Protected i, EnemiesEndIdx = ArraySize(*PlayState\Enemies())
  For i = 0 To EnemiesEndIdx
    If *PlayState\Enemies(i)\Active
      ProcedureReturn #False
    EndIf
  Next
  
  ProcedureReturn #True
  
EndProcedure

Procedure EndLevelPlayState(*PlayState.TPlayState)
  If *PlayState\CurrentLevel = *PlayState\MaxLevel
    ;finished the game
    ;for now just restart the game
    SwitchGameState(@GameStateManager, #PlayState)
    ProcedureReturn
  EndIf
  
EndProcedure

Procedure UpdatePlayState(*PlayState.TPlayState, TimeSlice.f)
  *PlayState\Player\Update(*PlayState\Player, TimeSlice)
  ;update player projectiles
  ForEach *PlayState\PlayerProjectiles\Projectiles()
    If *PlayState\PlayerProjectiles\Projectiles()\Active
      *PlayState\PlayerProjectiles\Projectiles()\Update(@*PlayState\PlayerProjectiles\Projectiles(), TimeSlice)
    EndIf
    
  Next
  
  Protected i, EndEnemiesIdx = ArraySize(*PlayState\Enemies())
  For i = 0 To EndEnemiesIdx
    If *PlayState\Enemies(i)\Active
      *PlayState\Enemies(i)\Update(@*PlayState\Enemies(i), TimeSlice)
    EndIf
  Next
  
  ForEach *PlayState\EnemiesProjectiles\Projectiles()
    If *PlayState\EnemiesProjectiles\Projectiles()\Active
      *PlayState\EnemiesProjectiles\Projectiles()\Update(@*PlayState\EnemiesProjectiles\Projectiles(), TimeSlice)
    EndIf
  Next
  
  
  
  UpdateCollisionsPlayState(*PlayState, TimeSlice)
  
  If FinishedEnemiesPlayState(*PlayState)
    EndLevelPlayState(*PlayState)
    ProcedureReturn
  EndIf
  
  
EndProcedure

Procedure DrawPlayState(*PlayState.TPlayState)
  *PlayState\Player\Draw(*PlayState\Player)
  Protected i
  Protected EnemiesEndIdx = ArraySize(*PlayState\Enemies())
  
  For i = 0 To EnemiesEndIdx
    If *PlayState\Enemies(i)\Active
      *PlayState\Enemies(i)\Draw(@*PlayState\Enemies(i))
    EndIf
    
  Next
  
  
  ;draw player projectiles
  ForEach *PlayState\PlayerProjectiles\Projectiles()
    If *PlayState\PlayerProjectiles\Projectiles()\Active
      *PlayState\PlayerProjectiles\Projectiles()\Draw(@*PlayState\PlayerProjectiles\Projectiles())
    EndIf
  Next
  
  ;draw enemies projectiles
  ForEach *PlayState\EnemiesProjectiles\Projectiles()
    If *PlayState\EnemiesProjectiles\Projectiles()\Active
      *PlayState\EnemiesProjectiles\Projectiles()\Draw(@*PlayState\EnemiesProjectiles\Projectiles())
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




DisableExplicit