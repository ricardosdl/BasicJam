XIncludeFile "GameObject.pbi"
XIncludeFile "Projectile.pbi"

EnableExplicit

Structure TPlayer Extends TGameObject
  *Projectiles.TProjectileList
EndStructure


Procedure UpdatePlayer(*Player.TPlayer, TimeSlice.f)
  *Player\Velocity\x = 0
  *Player\Velocity\y = 0
  
  If KeyboardPushed(#PB_Key_Left)
    *Player\Velocity\x = -200
  EndIf
  
  If KeyboardPushed(#PB_Key_Right)
    *Player\Velocity\x = 200
  EndIf
  
  If KeyboardPushed(#PB_Key_Up)
    *Player\Velocity\y = -200
  EndIf
  
  If KeyboardPushed(#PB_Key_Down)
    *Player\Velocity\y = 200
  EndIf
  
  *Player\Position\x + *Player\Velocity\x * TimeSlice
  *Player\Position\y + *Player\Velocity\y * TimeSlice
  
EndProcedure

Procedure DrawPlayer(*Player.TPlayer)
  DrawGameObject(*Player)
EndProcedure


Procedure InitPlayer(*Player.TPlayer, *ProjectilesList.TProjectileList, *Pos.TVector2D, SpriteNum.i, ZoomFactor.f)
  InitGameObject(*Player, *Pos, SpriteNum, @UpdatePlayer(), @DrawPlayer(), #True, ZoomFactor)
  
  *Player\Projectiles = *ProjectilesList
  
EndProcedure




DisableExplicit