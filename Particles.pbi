XIncludeFile "GameObject.pbi"
XIncludeFile "Math.pbi"

EnableExplicit

#PARTICLES_START_NUM_PARTICLES = 100

Prototype UpdateParticleProc(*Particle, TimeSlice.f)

Structure TParticle
  Position.TVector2D
  Width.a;in pixels
  Height.a;in pixels
  VelX.f
  VelY.f
  Active.a;#true is active #false is inactive
  Intensity.a;0- transparent 255-opaque
  Color.q    ;should be set with rgb(r, g, b)
  AliveTimer.f;in seconds
  Update.UpdateParticleProc
EndStructure

Structure TParticlesRepository Extends TGameObject
  CurrentNumParticles.l
  Array Particles.TParticle(#PARTICLES_START_NUM_PARTICLES - 1)
EndStructure

Procedure ResetParticle(*Particle.TParticle)
  *Particle\Position\x = 0
  *Particle\Position\y = 0
  
  *Particle\Width = 1
  *Particle\Height = 1
  
  *Particle\VelX = 0.0
  *Particle\VelY = 0.0
  
  *Particle\Active = #False
  
  *Particle\Intensity = 255
  
  *Particle\Color = RGB(255, 255, 255)
  
  *Particle\AliveTimer = 0.0
  
  *Particle\Update = #Null
  
EndProcedure

Procedure InitParticle(*Particle.TParticle, *Position.TVector2D, Width.a, Height.a, VelX.f, VelY.f, Intensity.a,
                       Color.q, AliveTimer.f, *UpdateProc.UpdateParticleProc = #Null)
  
  *Particle\Position\x = *Position\x
  *Particle\Position\y = *Position\y
  
  *Particle\Width = Width
  *Particle\Height = Height
  
  *Particle\VelX = VelX
  *Particle\VelY = VelY
  
  *Particle\Active = #True
  
  *Particle\Intensity = Intensity
  
  *Particle\Color = Color
  
  *Particle\AliveTimer = AliveTimer
  
  *Particle\Update = *UpdateProc
  
EndProcedure

Procedure ResetParticles(*ParticlesRepository.TParticlesRepository)
  Protected i.l, EndIdxParticles.l = *ParticlesRepository\CurrentNumParticles - 1
  For i = 0  To EndIdxParticles
    ResetParticle(@*ParticlesRepository\Particles(i))
  Next
  
EndProcedure

Procedure.i GetInactiveParticle(*ParticlesRepository.TParticlesRepository)
  Protected i.l, EndIdxParticles.l = *ParticlesRepository\CurrentNumParticles - 1
  For i = 0 To EndIdxParticles
    Protected *Particle.TParticle = @*ParticlesRepository\Particles(i)
    If Not *Particle\Active
      ProcedureReturn *Particle
    EndIf
  Next
  
  ProcedureReturn #Null
  
EndProcedure

Procedure UpdateParticlesRepository(*ParticlesRepository.TParticlesRepository, TimeSlice.f)
  Protected i.l, EndIdxParticles.l = *ParticlesRepository\CurrentNumParticles - 1
  For i = 0 To EndIdxParticles
    Protected *Particle.TParticle = @*ParticlesRepository\Particles(i)
    
    If Not *Particle\Active
      Continue
    EndIf
    
    If *Particle\AliveTimer <= 0
      *Particle\Active = #False
      Continue
    EndIf
    
    *Particle\AliveTimer - TimeSlice
    
    If *Particle\Update = #Null
      *Particle\Position\x + *Particle\VelX * TimeSlice
      *Particle\Position\y + *Particle\VelY * TimeSlice
    Else
      *Particle\Update(*Particle, TimeSlice)
    EndIf
      
  Next
  
EndProcedure

Procedure DrawParticlesRepository(*ParticlesRepository.TParticlesRepository, Intensity.a = 255)
  Protected i.l, EndIdxParticles.l = *ParticlesRepository\CurrentNumParticles - 1
  For i = 0 To EndIdxParticles
    Protected *Particle.TParticle = @*ParticlesRepository\Particles(i)
    If Not *Particle\Active
      Continue
    EndIf
    
    ZoomSprite(*ParticlesRepository\SpriteNum, *Particle\Width, *Particle\Height)
    DisplayTransparentSprite(*ParticlesRepository\SpriteNum, *Particle\Position\x, *Particle\Position\y,
                             *Particle\Intensity, *Particle\Color)
  Next
  
EndProcedure

Procedure.a InitParticlesRepository(*ParticlesRepository.TParticlesRepository,
                                    *GameCamera.TCamera, DrawOrder.l,
                                    NumParticles.l = #PARTICLES_START_NUM_PARTICLES)
  
  Protected Position.TVector2D\x = 0
  Position\y = 0
  InitGameObject(*ParticlesRepository, @Position, -1, @UpdateParticlesRepository(), @DrawParticlesRepository(), #True,
                 #SPRITES_ZOOM, DrawOrder)
  
  *ParticlesRepository\GameCamera = *GameCamera
  
  ReDim *ParticlesRepository\Particles(NumParticles)
  
  Protected AllocatedSize = ArraySize(*ParticlesRepository\Particles())
  If AllocatedSize = -1
    ProcedureReturn #False
  Else
    *ParticlesRepository\CurrentNumParticles = AllocatedSize + 1
  EndIf
  
  ResetParticles(*ParticlesRepository)
  
  If IsSprite(*ParticlesRepository\SpriteNum)
    FreeSprite(*ParticlesRepository\SpriteNum)
  EndIf
  
  Protected SpriteNum = CreateSprite(#PB_Any, 1, 1, #PB_Sprite_AlphaBlending)
  If SpriteNum = 0
    ProcedureReturn #False
  Else
    *ParticlesRepository\SpriteNum = SpriteNum
  EndIf
  
  StartDrawing(SpriteOutput(*ParticlesRepository\SpriteNum))
  Box(0, 0, 1, 1, RGB(255, 255, 255))
  StopDrawing()
  
  ProcedureReturn #True
  
EndProcedure

DisableExplicit