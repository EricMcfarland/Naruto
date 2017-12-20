#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;this is a random comment
#SingleInstance, Force


State:= "Initial State"
ElapsedTime := 0
CoordMode Pixel, Screen
CoordMode Mouse, Screen

Gui, 1: +Resize +LastFound
Gui, 1:Add, Tab, AltSubmit -Wrap , One|Two

Gui, 1:Tab, 1
Gui, Add, Button,, Button1


Gui, 1:Tab, 2
Gui, Add, Button,, Button2

Gui, 2: +Resize +LastFound
Gui, 2:Add, Tab, AltSubmit -Wrap , One|Two

Gui, 2:Tab, 1
Gui, Add, Button,, Button1


Gui, 2:Tab, 2
Gui, Add, Button,, Button2

Gui, 1:Show, , Tabs
Gui, 2:Show, , Tabs