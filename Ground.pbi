XIncludeFile "GameObject.pbi"
XIncludeFile "DrawOrders.pbi"


EnableExplicit

Structure TGround Extends TGameObject
  
EndStructure

Procedure DrawGround(*Ground.TGround)
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

Procedure InitGround(*Ground.TGround)
  
  Protected Position.TVector2D\x = 0
  Position\y = 0
  
  InitGameObject(*Ground, @Position, #Ground, #Null, @DrawGround(), #True, #SPRITES_ZOOM,
                 #GroundDrawOrder)
  
  
EndProcedure




DisableExplicit