XIncludeFile "GameState.pbi"

EnableExplicit

InitSprite()
InitKeyboard()

OpenWindow(1, 0,0,800,600,"Foo Game", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
OpenWindowedScreen(WindowID(1),0,0,800,600,0,0,0)

Global SimulationTime.q = 0, RealTime.q, GameTick = 5
Global LastTimeInMs.q

Procedure.a LoadSprites()
  Protected LoadedAll = #True
  LoadedAll = LoadedAll & Bool(LoadSprite(#Player1, "data\img\player1.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Banana, "data\img\banana.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Laser1, "data\img\laser1.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Apple, "data\img\apple.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Barf1, "data\img\barf1.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Grape, "data\img\grape.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Grape1, "data\img\grape1.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Watermelon, "data\img\watermelon.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Seed1, "data\img\seed1.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Tangerine, "data\img\tangerine.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Gomo1, "data\img\gomo1.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#PineApple, "data\img\pineapple.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Lemon, "data\img\lemon.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Acid1, "data\img\acid1.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Coconut, "data\img\coconut.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#CocoSlice1, "data\img\cocoslice1.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Jabuticaba, "data\img\jabuticaba.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Ground, "data\img\ground.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#JabuticabaShadow, "data\img\jabuticabashadow.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#Tomato, "data\img\tomato.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#StandardFont, "data\img\font.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#EnemySpawner, "data\img\enemyspawner.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#ShotFlash, "data\img\shotflash.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#PlayerShadow, "data\img\jabuticabashadow.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#PowerUpShootAllDirections, "data\img\power-up-shoot-all-directions.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#PowerUpFreezingShot, "data\img\power-up-freezing-shot.png", #PB_Sprite_AlphaBlending))
  LoadedAll = LoadedAll & Bool(LoadSprite(#FreezingLaser1, "data\img\freezing-laser1.png", #PB_Sprite_AlphaBlending))
  
  ProcedureReturn LoadedAll
EndProcedure

Procedure.a LoadResources()
  If LoadSprites() = #False
    MessageRequester("ERROR", "Error loading sprites! Couldn't find data.")
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure UpdateWorld(TimeSlice.f)
  UpdateCurrentStateGameStateManager(@GameStateManager, TimeSlice)
EndProcedure

Procedure DrawWorld()
  DrawCurrentStateGameSateManager(@GameStateManager)
  ;Player\DrawGameObject(@Player)
  ;Banana\DrawGameObject(@Banana)
EndProcedure

Procedure StartGame()
  
EndProcedure


UsePNGImageDecoder()

If (LoadResources() = #False)
  ;error loading resources, can't ryb the game this way
  End 1
EndIf


InitGameSates()
SwitchGameState(@GameStateManager, #MainMenuState)

SimulationTime = ElapsedMilliseconds()

Repeat
  LastTimeInMs = ElapsedMilliseconds()
  
  ;RealTime = ElapsedMilliseconds()
  Define Event = WindowEvent()
  
  ExamineKeyboard()
  
  ;Update
  While SimulationTime < LastTimeInMs
    SimulationTime + GameTick
    UpdateWorld(GameTick / 1000.0)
  Wend
  
  ;Draw
  ClearScreen(#Black)  
  DrawWorld()
  FlipBuffers()
Until event = #PB_Event_CloseWindow Or KeyboardPushed(#PB_Key_Escape)
End