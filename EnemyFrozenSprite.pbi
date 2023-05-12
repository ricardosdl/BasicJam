EnableExplicit

Structure TEnemyFrozenSprite
  EnemySprite.i
  EnemyFrozenSprite.i
  EnemyType.a
EndStructure

Global NewList EnemyFrozenSpriteFrozenSprites.TEnemyFrozenSprite()

Procedure EnemyFrozenSpriteCreate(EnemySprite.i, *EnemyFrozenSprite.Integer)
  If Not IsSprite(EnemySprite)
    ProcedureReturn #False
  EndIf
  
  Protected EnemyFrozenSprite.i = CopySprite(EnemySprite, #PB_Any, #PB_Sprite_AlphaBlending)
  If EnemyFrozenSprite = 0
    ProcedureReturn #False
  EndIf
  
  StartDrawing(SpriteOutput(EnemyFrozenSprite))
  DrawingMode(#PB_2DDrawing_AlphaClip)
  DrawAlphaImage(ImageID(#FrozenSurfaceImage), 0, 0)
  StopDrawing()
  
  *EnemyFrozenSprite\i = EnemyFrozenSprite
  ProcedureReturn #True
  
EndProcedure


Procedure EnemyFrozenSpriteGetFrozenSprite(EnemySprite.i, EnemyType.a, *FrozenSprite.Integer)
  ForEach EnemyFrozenSpriteFrozenSprites()
    If EnemyFrozenSpriteFrozenSprites()\EnemyType = EnemyType
      ;the frozen sprite already exists
      *FrozenSprite\i = EnemyFrozenSpriteFrozenSprites()\EnemyFrozenSprite
      ProcedureReturn #True
    EndIf
  Next
  
  Protected WasCreated = EnemyFrozenSpriteCreate(EnemySprite, *FrozenSprite)
  If Not WasCreated
    ProcedureReturn #False
  EndIf
  
  AddElement(EnemyFrozenSpriteFrozenSprites())
  EnemyFrozenSpriteFrozenSprites()\EnemyFrozenSprite = *FrozenSprite\i
  EnemyFrozenSpriteFrozenSprites()\EnemySprite = EnemySprite
  EnemyFrozenSpriteFrozenSprites()\EnemyType = EnemyType
  
  ProcedureReturn #True
  
  
EndProcedure


