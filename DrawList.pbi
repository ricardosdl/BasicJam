XIncludeFile "GameObject.pbi"


EnableExplicit

Structure TDrawListItem
  *GameObject.TGameObject
  Active.a
  DrawOrder.l
EndStructure


Structure TDrawList
  Changed.a
  List DrawList.TDrawListItem()
EndStructure

Procedure InitDrawList(*DrawList.TDrawList)
  ForEach *DrawList\DrawList()
    *DrawList\DrawList()\Active = #False
  Next
  
  *DrawList\Changed = #False
EndProcedure

Procedure DrawDrawList(*DrawList.TDrawList, ReorderIfChanged.a = #True)
  If ReorderIfChanged And *DrawList\Changed
    SortStructuredList(*DrawList\DrawList(), #PB_Sort_Ascending,
                       OffsetOf(TDrawListItem\DrawOrder), TypeOf(TDrawListItem\DrawOrder))
    *DrawList\Changed = #False
  EndIf
  
  ForEach *DrawList\DrawList()
    If *DrawList\DrawList()\Active
      If *DrawList\DrawList()\GameObject\Active
        *DrawList\DrawList()\GameObject\Draw(*DrawList\DrawList()\GameObject)
      Else
        ;gameobject is not active anymore, the dralistitem must be inactive
        *DrawList\DrawList()\Active = #False
      EndIf
    EndIf
  Next
EndProcedure

Procedure AddDrawItemDrawList(*DrawList.TDrawList, *GameObject.TGameObject)
  ;first we try to add the *gameobject to an already created drawitem that is inactive
  ForEach *DrawList\DrawList()
    If *DrawList\DrawList()\Active = #False
      *DrawList\DrawList()\GameObject = *GameObject
      *DrawList\DrawList()\Active = #True
      *DrawList\DrawList()\DrawOrder = *GameObject\DrawOrder
      *DrawList\Changed = #True
      ProcedureReturn
    EndIf
  Next
  
  ;here we create a new drawlisteitem
  Protected *DrawListItem.TDrawListItem = AddElement(*DrawList\DrawList())
  *DrawListItem\Active = #True
  *DrawListItem\GameObject = *GameObject
  *DrawListItem\DrawOrder = *GameObject\DrawOrder
  
  *DrawList\Changed = #True
EndProcedure
  
  

DisableExplicit