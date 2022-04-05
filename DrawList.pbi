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
  
  ;Debug "size:" + ListSize(*DrawList\DrawList())
  
  Protected count = 0
  Protected NumDrawn = 0, NotDrawn = 0
  ForEach *DrawList\DrawList()
    count + 1
    If *DrawList\DrawList()\GameObject\Active
      *DrawList\DrawList()\GameObject\Draw(*DrawList\DrawList()\GameObject)
      NumDrawn + 1
    Else
      *DrawList\DrawList()\Active = #False
      NotDrawn + 1
    EndIf
  Next
  Debug "num drawn:" + NumDrawn
  Debug "not drawn:" + NotDrawn
  ;Debug "iterated size:" + Count
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