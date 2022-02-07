EnableExplicit

Procedure.f RandomSinValue()
  Protected RandomAngle.f = Random(359, 0)
  ProcedureReturn Sin(Radian(RandomAngle))
EndProcedure


DisableExplicit