XIncludeFile "GameObject.pbi"
XIncludeFile "DrawOrders.pbi"


EnableExplicit

Structure TGround Extends TGameObject
  CachedGroundSprite.i
EndStructure

Procedure DrawGroundTiles(*Ground.TGround)
  Protected x, y
  Protected NumGroundsWidth = ScreenWidth() / *Ground\Width
  Protected NumGroundsHeight = ScreenHeight() / *Ground\Height
  For x = 0 To NumGroundsWidth - 1
    For y = 0 To NumGroundsHeight - 1
      Protected.l PosX, PosY
      PosX = Int(x * *Ground\Width - *Ground\GameCamera\Position\x)
      PosY = Int(y * *Ground\Height - *Ground\GameCamera\Position\y)
      DisplayTransparentSprite(*Ground\SpriteNum, PosX, PosY)
    Next y
  Next x
  
EndProcedure

Procedure DrawGround(*Ground.TGround)
  If *Ground\CachedGroundSprite <> 0
    
    DisplayTransparentSprite(*Ground\CachedGroundSprite, *Ground\Position\x - *Ground\GameCamera\Position\x,
                             *Ground\Position\y - *Ground\GameCamera\Position\y)
    ProcedureReturn
  EndIf
  
  DrawGroundTiles(*Ground)
  
EndProcedure

Procedure.a GroundCacheGroundSprite(*Ground.TGround)
  DrawGroundTiles(*Ground)
  Protected CachedSprite.i = GrabSprite(#PB_Any, 0, 0, ScreenWidth(), ScreenHeight())
  If CachedSprite = 0
    ;error! could not create sprite
    ProcedureReturn #False
  EndIf
  
  *Ground\CachedGroundSprite = CachedSprite
  
  ClearScreen(#Black)
  
  ProcedureReturn #True
  
EndProcedure

Procedure InitGround(*Ground.TGround, CacheGroundSprite.a = #True)
  
  Protected Position.TVector2D\x = 0
  Position\y = 0
  
  InitGameObject(*Ground, @Position, #Ground, #Null, @DrawGround(), #True, #SPRITES_ZOOM,
                 #GroundDrawOrder)
  
  *Ground\CachedGroundSprite = 0
  If CacheGroundSprite
    GroundCacheGroundSprite(*Ground)
  EndIf
  
  
  
EndProcedure




DisableExplicit