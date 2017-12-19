MouseClickDrag, left, 0, 200, 600, 400

; The following example opens MS Paint and draws a little house:
SetDefaultMouseSpeed ,50
Run, mspaint.exe
WinWaitActive, ahk_class MSPaintApp,, 2
if ErrorLevel
    return
MouseClickDrag, L, 150, 250, 150, 150
MouseClickDrag, L, 150, 150, 200, 100
MouseClickDrag, L, 200, 100, 250, 150
MouseClickDrag, L, 250, 150, 150, 150
MouseClickDrag, L, 150, 150, 250, 250
MouseClickDrag, L, 250, 250, 250, 150
MouseClickDrag, L, 250, 150, 150, 250
MouseClickDrag, L, 150, 250, 250, 250