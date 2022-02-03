XIncludeFile "GameState.pbi"

EnableExplicit

InitSprite()
InitKeyboard()

OpenWindow(1, 0,0,800,600,"Foo Game", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
OpenWindowedScreen(WindowID(1),0,0,800,600,0,0,0)

Global SimulationTime.q = 0, RealTime.q, GameTick = 6
Global ElapsedTimneInS.f, LastTimeInMs.q

Procedure LoadSprites()
  LoadSprite(#Player1, "data\img\player1.png", #PB_Sprite_AlphaBlending)
  LoadSprite(#Banana, "data\img\banana.png", #PB_Sprite_AlphaBlending)
EndProcedure

Procedure LoadResources()
  LoadSprites()
EndProcedure

Procedure UpdateWorld(TimeSlice.f)
  
EndProcedure

Procedure DrawWorld()
  ;Player\DrawGameObject(@Player)
  ;Banana\DrawGameObject(@Banana)
EndProcedure

Procedure StartGame()
  
EndProcedure


UsePNGImageDecoder()

LoadResources()

InitGameSates()
SwitchGameState(@GameStateManager, #PlayState)

LastTimeInMs = ElapsedMilliseconds()

Repeat
  ElapsedTimneInS = (ElapsedMilliseconds() - LastTimeInMs) / 1000.0
  LastTimeInMs = ElapsedMilliseconds()
  
  ;RealTime = ElapsedMilliseconds()
  Define Event = WindowEvent()
  
  ExamineKeyboard()
  
  ;Update
  While SimulationTime < LastTimeInMs
    SimulationTime + GameTick
    UpdateWorld(GameTick / 1000.0)
  Wend
  
  
  ;UpdateWorld(ElapsedTimneInS)
  
  ;Draw
  ClearScreen(#Black)  
  DrawWorld()
  FlipBuffers()
Until event = #PB_Event_CloseWindow Or KeyboardPushed(#PB_Key_Escape)
End