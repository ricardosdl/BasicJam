IncludeFile "GameObject.pbi"

EnableExplicit

Enumeration ESprites
  #Player1
  #Banana
EndEnumeration

InitSprite()
InitKeyboard()

OpenWindow(1, 0,0,800,600,"Foo Game", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
OpenWindowedScreen(WindowID(1),0,0,800,600,0,0,0)

Global SimulationTime.q = 0, RealTime.q, GameTick = 6
Global ElapsedTimneInS.f, LastTimeInMs.q
Global Player.TGameObject, Banana.TGameObject

Procedure LoadSprites()
  LoadSprite(#Player1, "data\img\player1.png", #PB_Sprite_AlphaBlending)
  LoadSprite(#Banana, "data\img\banana.png", #PB_Sprite_AlphaBlending)
EndProcedure

Procedure LoadResources()
  LoadSprites()
EndProcedure

Procedure UpdateWorld(TimeSlice.f)
  Player\Velocity\x = 0
  If KeyboardPushed(#PB_Key_Left)
    Player\Velocity\x = -250
  EndIf
  
  If KeyboardPushed(#PB_Key_Right)
    Player\Velocity\x = 250
  EndIf
  
  Player\Velocity\y = 0
  If KeyboardPushed(#PB_Key_Up)
    Player\Velocity\y = -250
  EndIf
  
  If KeyboardPushed(#PB_Key_Down)
    Player\Velocity\y = 250
  EndIf
  
  
  
  Player\Position\x + Player\Velocity\x * TimeSlice
  Player\Position\y + Player\Velocity\y * TimeSlice
EndProcedure

Procedure DrawWorld()
  Player\DrawGameObject(@Player)
  Banana\DrawGameObject(@Banana)
EndProcedure


UsePNGImageDecoder()

LoadResources()


Define PlayerPosition.TVector2D\x = 90
PlayerPosition.TVector2D\y = 90
InitGameObject(@Player, @PlayerPosition, 12, 12, #Player1, #Null, @DrawGameObject(), 2.5)

Define BananaPos.TVector2D\x = 150
BananaPos\y = 150
InitGameObject(@Banana, @BananaPos, 8, 8, #Banana, #Null, @DrawGameObject(), 2.5)

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