XIncludeFile "GameState.pbi"

EnableExplicit

InitSprite()
InitKeyboard()

OpenWindow(1, 0,0,800,600,"Foo Game", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
OpenWindowedScreen(WindowID(1),0,0,800,600,0,0,0)

Global SimulationTime.q = 0, RealTime.q, GameTick = 5
Global LastTimeInMs.q

Procedure LoadSprites()
  LoadSprite(#Player1, "data\img\player1.png", #PB_Sprite_AlphaBlending)
  LoadSprite(#Banana, "data\img\banana.png", #PB_Sprite_AlphaBlending)
  LoadSprite(#Laser1, "data\img\laser1.png", #PB_Sprite_AlphaBlending)
  LoadSprite(#Apple, "data\img\apple.png", #PB_Sprite_AlphaBlending)
  LoadSprite(#Barf1, "data\img\barf1.png", #PB_Sprite_AlphaBlending)
  LoadSprite(#Grape, "data\img\grape.png", #PB_Sprite_AlphaBlending)
  LoadSprite(#Grape1, "data\img\grape1.png", #PB_Sprite_AlphaBlending)
  LoadSprite(#Watermelon, "data\img\watermelon.png", #PB_Sprite_AlphaBlending)
  LoadSprite(#Seed1, "data\img\seed1.png", #PB_Sprite_AlphaBlending)
EndProcedure

Procedure LoadResources()
  LoadSprites()
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

LoadResources()

InitGameSates()
SwitchGameState(@GameStateManager, #PlayState)

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