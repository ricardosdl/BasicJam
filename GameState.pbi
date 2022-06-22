XIncludeFile "Math.pbi"
XIncludeFile "GameObject.pbi"
XIncludeFile "Enemy.pbi"
XIncludeFile "Player.pbi"
XIncludeFile "Projectile.pbi"
XIncludeFile "Resources.pbi"
XIncludeFile "Util.pbi"
XIncludeFile "DrawList.pbi"
XIncludeFile "Ground.pbi"
XIncludeFile "DrawText.pbi"

EnableExplicit

Prototype StartGameStateProc(*GameState)
Prototype EndGameStateProc(*GameState)
Prototype UpdateGameStateProc(*GameState, TimeSlice.f)
Prototype DrawGameStateProc(*GameState)

Enumeration EGameStates
  #NoGameState
  #MainMenuState
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
  DrawList.TDrawList
  Ground.TGround
  StartTimer.f
  EnemySpawnerTimer.f;time until an enemyspawner will spawn an enemy
  NextEnemySpawnerWaveTimer.f;time until we get more enemyspawners
EndStructure

Structure TMainMenuState Extends TGameState
  GameTitle.s
  GameTitleX.f
  GameTitleY.f
  GameTitleFontWidth.f
  GameTitleFontHeight.f
  
  GameStart.s
  GameStartX.f
  GameStartY.f
  GameStartFontWidth.f
  GameStartFontHeight.f
EndStructure

Global GameStateManager.TGameStateManager, PlayState.TPlayState, MainMenuState.TMainMenuState

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

Procedure SpawnEnemyPlayState(*EnemySpawner.TEnemy)
  
EndProcedure

Procedure InitEnemiesPlayState(*PlayState.TPlayState)
  ;enemies that we'll add
  Protected NumEnemies = 10
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
    
    ;InitBananaEnemy(*Enemy, *PlayState\Player, @Position, #Banana, 2.5, #Null)
    ;InitAppleEnemy(*Enemy, *PlayState\Player, @Position, #Apple, 2.5, @*PlayState\EnemiesProjectiles)
    ;InitGrapeEnemy(*Enemy, *PlayState\Player, @Position, #Grape, 2.5, @*PlayState\EnemiesProjectiles)
    ;InitWatermelonEnemy(*Enemy, *PlayState\Player, @Position, #Watermelon, 2.5, @*PlayState\EnemiesProjectiles)
    ;InitTangerineEnemy(*Enemy, *PlayState\Player, @Position, #Tangerine, #SPRITES_ZOOM, @*PlayState\EnemiesProjectiles)
    ;InitPineappleEnemy(*Enemy, *PlayState\Player, @Position, #PineApple, #SPRITES_ZOOM)
    ;InitPineappleEnemy(*Enemy, *PlayState\Player, @Position, #Lemon, #SPRITES_ZOOM)
    ;InitLemonEnemy(*Enemy, *PlayState\Player, @Position, #Lemon, #SPRITES_ZOOM, @*PlayState\EnemiesProjectiles)
    ;InitCoconutEnemy(*Enemy, *PlayState\Player, @Position, #Coconut, #SPRITES_ZOOM, @*PlayState\EnemiesProjectiles)
    ;InitJabuticabaEnemy(*Enemy, *PlayState\Player, @Position, #Jabuticaba, #SPRITES_ZOOM, @*PlayState\EnemiesProjectiles,
    ;                    @*PlayState\DrawList)
    ;InitTomatoEnemy(*Enemy, *PlayState\Player, @Position, #Tomato, #SPRITES_ZOOM,
    ;                @*PlayState\EnemiesProjectiles, @*PlayState\DrawList)
    InitEnemySpawnerEnemy(*Enemy, *PlayState\Player, @Position, #EnemySpawner, #SPRITES_ZOOM, @*PlayState\EnemiesProjectiles,
                          @*PlayState\DrawList, @SpawnEnemyPlayState())
    
    *Enemy\Active = #True
    
    AddDrawItemDrawList(@*PlayState\DrawList, *Enemy)
    
    EnemiesToAdd - 1
  Wend
  
  
EndProcedure

Procedure InitGroundPlayState(*PlayState.TPlayState)
  InitGround(*PlayState\Ground)
  
  AddDrawItemDrawList(*PlayState\DrawList, *PlayState\Ground)
  
  
EndProcedure

Procedure StartPlayState(*PlayState.TPlayState)
  *PlayState\CurrentLevel = 1
  *PlayState\MaxLevel = 1;TODO: more levels
  *PlayState\NextEnemySpawnerWaveTimer = 0.0;when we start we already create a wave of enemyspawners
  
  *PlayState\StartTimer = 3.0
  
  InitDrawList(@*PlayState\DrawList)
  
  Protected *Player.TPlayer = @*PlayState\Player
  Protected PlayerPos.TVector2D\x = ScreenWidth() / 2
  PlayerPos\y = ScreenHeight() / 2
  
  
  InitPlayer(*Player, @*PlayState\PlayerProjectiles, @PlayerPos, #False, 2.5, @*PlayState\DrawList)
  
  AddDrawItemDrawList(@*PlayState\DrawList, *Player)
  
  InitGroundPlayState(*PlayState)
  
  
EndProcedure

Procedure EndPlayState(*PlayState.TPlayState)
EndProcedure

Procedure CollisionPlayerProjectileEnemies(*PlayState.TPlayState, *Projectile.TProjectile,
                                           TimeSlice.f)
  Protected i, IdxMax = ArraySize(*PlayState\Enemies())
  For i = 0 To IdxMax
    If *PlayState\Enemies(i)\Active
      Protected *Enemy.TEnemy = *PlayState\Enemies(i)
      Protected EnemyRect.TRect
      If Not *Enemy\GetCollisionRect(*Enemy, @EnemyRect)
        ;the enemy is not collidable, ignore it
        Continue
      EndIf
      
      
      Protected ProjectileRect.TRect
      If Not *Projectile\GetCollisionRect(*Projectile, @ProjectileRect)
        ;the projectile is not collidable, ignore
        Continue
      EndIf
      
      
      If CollisionRectRect(EnemyRect\Position\x, EnemyRect\Position\y, EnemyRect\Width,
                           EnemyRect\Height, ProjectileRect\Position\x,
                           ProjectileRect\Position\y, ProjectileRect\Width, ProjectileRect\Height)
        HurtProjectile(*Projectile, 1.0)
        HurtEnemy(*Enemy, *Projectile\Power)
        
      EndIf
      
    EndIf
    
  Next
  
EndProcedure

Procedure CollisionPlayerEnemies(*PlayState.TPlayState, TimeSlice.f)
  Protected PlayerRect.TRect
  If Not *PlayState\Player\GetCollisionRect(@*PlayState\Player, @PlayerRect)
    ;player is not collidable, nothing to do
    ProcedureReturn
  EndIf
  
  ;collisions between player and enemies
  Protected i, EnemiesEndIdx = ArraySize(*PlayState\Enemies())
  
  For i = 0 To EnemiesEndIdx
    Protected *Enemy.TEnemy = *PlayState\Enemies(i)
    Protected EnemyRect.TRect
    If Not *Enemy\Active Or *Enemy\GetCollisionRect(*Enemy, @EnemyRect) = #False
      Continue
    EndIf
    
    If CollisionRectRect(EnemyRect\Position\x, EnemyRect\Position\y, EnemyRect\Width,
                         EnemyRect\Height, PlayerRect\Position\x, PlayerRect\Position\y,
                         PlayerRect\Width, PlayerRect\Height)
      
      HurtPlayer(@*PlayState\Player, 1.0)
      
      
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
  
  CollisionPlayerEnemies(*PlayState, TimeSlice)
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

Procedure UpdateEnemySpawners(*PlayState.TPlayState, TimeSlice.f)
  If *PlayState\NextEnemySpawnerWaveTimer <= 0
    InitEnemiesPlayState(*PlayState)
    *PlayState\NextEnemySpawnerWaveTimer = 30.0
  EndIf
  *PlayState\NextEnemySpawnerWaveTimer - TimeSlice
EndProcedure

Procedure UpdatePlayState(*PlayState.TPlayState, TimeSlice.f)
  If *PlayState\StartTimer > 0.0
    ;just wait the timer to start the game
    *PlayState\StartTimer - TimeSlice
    ProcedureReturn
  EndIf
  
  UpdateEnemySpawners(*PlayState, TimeSlice)
  
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
  DrawDrawList(*PlayState\DrawList)
  
  If *PlayState\StartTimer > 0.0
    ;shows a timer when the game starts
    Protected StartTimerRounded.f = Round(*PlayState\StartTimer, #PB_Round_Up)
    Protected StartTimer.s = StrF(StartTimerRounded, 0)
    Protected StartTimerSize = Len(StartTimer)
    Protected FontWidth.f = #STANDARD_FONT_WIDTH * (#SPRITES_ZOOM + 2.5)
    Protected FontHeight.f = #STANDARD_FONT_HEIGHT * (#SPRITES_ZOOM + 2.5)
    
    Protected StartTimerWidth.f = StartTimerSize * FontWidth
    
    Protected StartTimerX.f = (ScreenWidth() / 2) - (StartTimerWidth / 2)
    
    DrawTextWithStandardFont(StartTimerX, ScreenHeight() / 2, StartTimer, FontWidth, FontHeight)
  EndIf

  
  
  
EndProcedure

Procedure StartMainMenuState(*MainMenuState.TMainMenuState)
  Protected MainMenuHeightOffset.f = ScreenHeight() / 5
  
  ;game title text
  *MainMenuState\GameTitle = "FRUIT WARS v0.9999..."
  *MainMenuState\GameTitleFontWidth = #STANDARD_FONT_WIDTH * (#SPRITES_ZOOM + 2.5)
  *MainMenuState\GameTitleFontHeight = #STANDARD_FONT_HEIGHT * (#SPRITES_ZOOM + 2.5)
  Protected GameTitleWidth.f = Len(*MainMenuState\GameTitle) * *MainMenuState\GameTitleFontWidth
  
  *MainMenuState\GameTitleX = (ScreenWidth() / 2) - GameTitleWidth / 2
  *MainMenuState\GameTitleY = MainMenuHeightOffset
  
  ;start game text
  *MainMenuState\GameStart = "PRESS ENTER TO START"
  *MainMenuState\GameStartFontWidth = #STANDARD_FONT_WIDTH * (#SPRITES_ZOOM)
  *MainMenuState\GameStartFontHeight = #STANDARD_FONT_HEIGHT * (#SPRITES_ZOOM)
  Protected GameStartWidth.f = Len(*MainMenuState\GameStart) * *MainMenuState\GameStartFontWidth
  
  *MainMenuState\GameStartX = (ScreenWidth() / 2) - GameStartWidth / 2
  *MainMenuState\GameStartY = MainMenuHeightOffset + *MainMenuState\GameTitleFontHeight + 40
  
EndProcedure

Procedure EndMainMenuState(*MainMenuState.TMainMenuState)
  
EndProcedure

Procedure UpdateMainMenuState(*MainMenuState.TMainMenuState, TimeSlice.f)
  If KeyboardPushed(#PB_Key_Return)
    SwitchGameState(@GameStateManager, #PlayState)
    ProcedureReturn
  EndIf
  
  
EndProcedure

Procedure DrawMainMenuState(*MainMenuState.TMainMenuState, TimeSlice.f)
  DrawTextWithStandardFont(*MainMenuState\GameTitleX, *MainMenuState\GameTitleY,
                           *MainMenuState\GameTitle, *MainMenuState\GameTitleFontWidth,
                           *MainMenuState\GameTitleFontHeight)
  
  DrawTextWithStandardFont(*MainMenuState\GameStartX, *MainMenuState\GameStartY, *MainMenuState\GameStart,
                           *MainMenuState\GameStartFontWidth, *MainMenuState\GameStartFontHeight)
EndProcedure

Procedure InitGameSates()
  ;@GameStateManager\GameStates(#PlayState)
  PlayState\GameState = #PlayState
  
  PlayState\StartGameState = @StartPlayState()
  PlayState\EndGameState = @EndPlayState()
  PlayState\UpdateGameState = @UpdatePlayState()
  PlayState\DrawGameState = @DrawPlayState()
  
  MainMenuState\GameState = #MainMenuState
  MainMenuState\StartGameState = @StartMainMenuState()
  MainMenuState\EndGameState = @EndMainMenuState()
  MainMenuState\UpdateGameState = @UpdateMainMenuState()
  MainMenuState\DrawGameState = @DrawMainMenuState()
  
  GameStateManager\GameStates(#PlayState) = @PlayState
  GameStateManager\GameStates(#MainMenuState) = @MainMenuState
  
  GameStateManager\CurrentGameState = #NoGameState
  GameStateManager\LastGameState = #NoGameState
  
EndProcedure




DisableExplicit