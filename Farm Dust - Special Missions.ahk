#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;this is a random comment
#SingleInstance, Force
;Milestones
;[X] Make simple GUI
;[X] Be able to specify a location to be clicked, then force a click at that location
;[X] Be able to specify a relative location on a window (Prob have to force window active)
;[X] Determine click location logic for one type of Run 
;	[X] ATK MIS (Working on ending once "Touch" shows up)
;[X] Get image search to work
;	[X] attack token
;	[X]	Touch
;[]Recursion to play until out of tokens 
;[X] research what conditional logic I can employ to make sure what screen I'm On
	;[X] ImageSearch
;[]Add debugging features for Gui	
;	[X] Text output for what routine im On
;	[X] Text output for conditional case
;[X] End mission early if Touch exists, or timeout
;	[SOLVED]!!!!!!!!!!!!!!!!!!!!!!Nox keeps stealing focus!!!!!!
; 		-Can use absolute coords and not even activate window Ever. (This may be easier)
;[X] Search for OK Button (in order to deal with connection errors. 
;[]Will need a break if it doesn't find Auto some time after)
;[] Ult after 'Enemy appears'
;[] Review macro level design. Handle outlier cases such as lvl up and academy upgrades

;!! Start Special missions
;[]specify which mission
	;[] drag scroll to lower mission
	;!!!!!!!!!!!!DRAG WILL STEAL MOUSE FOCUS
;[]Use vision logic


;Optional
;[X] Randomize click locations in area for bot correction
	;[] Narrow range 



;*****How to keep looking for Touch ****
;

;****Attack Mission Logic*****
; Need to maximize window regardless of initial window size. WinMaximize isn't working
; Will start at Mission Screen
;1) Click in Attack Mission area. Wait some time (experiment)
;2) Confirm spending an attack token. Wait some time (experiment n +6seconds)
;3) Hit OK. Wait some time
;4) Click auto. Wait a long time (Full 240 seconds at first)
;5) Click in touch area to clear victory Screen. Wait some time
;6) Click to loot rewards. Wait some time
;6) Repeat (if starts at mission screen again)

SetWorkingDir, D:\AutoHotKey\Scripts\Naruto\Images

;-------------Gui Layout ------------

 
State:= "Initial State"
ElapsedTime := 0
CoordMode Pixel, Screen
CoordMode Mouse, Screen
gui, font, cgray
Gui, +Resize +LastFound
gui, Add, Tab2,AltSubmit -Wrap , Main|ClickDrag
Gui, Tab, 1
Gui, Add, Text, cAqua vElapsedTime, ElapsedTime: %ElapsedTime%	
; Gui, Add, Edit, r1 vPosX number, %PosX%
; Gui, Add, Edit, r1 vPosY number, %PosY%
;gui, add, text, cGreen w100 r1 vElapsedTime, ElaspedTime: %ElapsedTime%
gui, add, text, w250 cGreen r1 vState, %State%
Gui, Add, Button, w75 r1 gAttackMission, Attack Mission
Gui, Add, Button, w75 gSpecialMission, Special Mission
gui, Add, Edit, x+10 w40, 
gui, add, UpDown, x+10, 0
gui, Add, Button, w100 h20 gSearchForCertainImage, Search for Image

gui, Add, Button, w100 r1 gUpdateState, Test for state updates
gui, Add, Button, w100 h25 gTest2, Test for Touch
Gui,Tab,2
StartX:=2090
StartY:=650
EndX:=2090
EndY:=300
gui,add,text,,StartX
gui,Add,Edit, r1 vStartX, %StartX%
gui,add,text,,EndX
gui,Add,Edit, r1 vEndX, %EndX%
gui,add,text,,StartY
gui,Add,Edit, r1 vStartY, %StartY%
gui,add, Text,,EndY
gui,Add,Edit, r1 vEndY, %EndY%

gui, add, button,  w100 h25 gScroll, Click and drag

;x+50 adds 50 pixels to the previous element, If yo u
;A new Gui, Add, Text will start an element on the next line
							
Gui, Font, s17 cBlack
Gui, Color, Grey ;Hex Code works HTML
Gui, Show, x1400 y20 w350 h400 NA, GUI
return


;---------Labels---------------------\
	
AttackMission:
	IfWinExist, Main game
		WinActivate, Main game
	else
		WinActivate, Calculator
	
	;Loop while attack mission token exists
	While(SearchForImage("AttackMissionToken.png")){
		;try to Maximize (Find more reliable way to do this)
			; Gosub, WindowMax
			; Sleep 500
		;Click on attack mission
			Gosub, startAtkMis
			Sleep 2000
		;Cofirm spending of attack token
			Gosub, confirmAtkMis
			;Sleep 13000
		;Click ok to deploy troops
			gosub, okBtn 
			;sleep 10000
		;Click auto
			gosub, autoBtn
			;sleep 240000
		;Ult
			;gosub PressUlt
		;Touch for Victory screen
			gosub, touch1
			;Sleep 5000
		;Touch for Spoils screen
			gosub, touch2
			Sleep 8000
	} 
	msgbox, Out of tokens
	
	return 

SpecialMission:
return	

; WindowMax:		;improve this
	; Random, PosX, 1395, 1405
	; Random, PosY, 13, 17
	; ClickAtLocation(PosX, PosY)
	; return	

startAtkMis:
	
	Random, PosX, 540, 710
	Random, PosY, 700, 840
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". Started Attack Mission") 
	ClickAtLocation(PosX, PosY)
	return	
confirmAtkMis:

	Random, PosX, 1000, 1120
	Random, PosY, 755, 795
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". Confirm pressed")
	t:=0
	ClickAtLocation(PosX, PosY) 
	Loop{
		Sleep, 1000
		TimeUpdate(t)
		t+=1000
		
		;TRY- get the active window at end of script WinGetActiveTitle, LastWindow
		;	Then set that window back to active on next loop WinActivate LastWindow
	}Until ( t>22000 or SearchForImage("OkButton.png"))
	sleep 1000
	return
okBtn:
	Random, PosX, 765, 875
	Random, PosY, 910, 940
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". OkButton pressed")
	ClickAtLocation(PosX, PosY)
	t:=0
	Loop{
		Sleep, 1000
		TimeUpdate(t)
		t+=1000
		
		;TRY- get the active window at end of script WinGetActiveTitle, LastWindow
		;	Then set that window back to active on next loop WinActivate LastWindow
	}Until ( t>20000 or SearchForImage("AutoButton.png"))
	sleep 1000
	Return
autoBtn:
	
	t:= 0
	Random, PosX, 740, 890
	Random, PosY, 975, 990
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". AutoButton pressed")
	ClickAtLocation(PosX, PosY) 
	;sleep 30000
	t:=0
	Loop{
		;!!!Prob need to search more often. Use manual test to see if imagefound
		; if(SearchForImage("Enemy.png")){
			; Sleep 4000
			; loop 4{
			; ClickAtLocation(1550,680)
			; sleep 500
			; }
		; }
		Sleep, 1000
		TimeUpdate(t)
		t+=1000
		;TRY- get the active window at end of script WinGetActiveTitle, LastWindow
		;	Then set that window back to active on next loop WinActivate LastWindow
	}Until ( t>220000 or SearchForImage("Touch.png"))
	sleep 1000
	return
	
PressUlt:
	
	t:= 0
	Random, PosX, 730, 900
	Random, PosY, 970, 995
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". AutoButton pressed")
	ClickAtLocation(PosX, PosY) 
	;sleep 30000
	Loop{
		Sleep, 1000
	
		t+=1000
		;TRY- get the active window at end of script WinGetActiveTitle, LastWindow
		;	Then set that window back to active on next loop WinActivate LastWindow
	}Until ( t>190000 or SearchForImage("Touch.png"))
	return

touch1:
	
	Random, PosX, 550, 1110
	Random, PosY, 800, 950
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". First Touch pressed")
	ClickAtLocation(PosX, PosY)
	t:=0
	Loop{
		Sleep, 1000
		TimeUpdate(t)
		t+=1000
		;TRY- get the active window at end of script WinGetActiveTitle, LastWindow
		;	Then set that window back to active on next loop WinActivate LastWindow
	}Until ( t>19000 or SearchForImage("Touch.png"))
	sleep 1000
	return 
	
touch2:
	Random, PosX, 550, 1110
	Random, PosY, 800, 950
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". Second Touch pressed")
	ClickAtLocation(PosX, PosY)
	return 
	
	
UpdateState:
	TimeUpdate("10")
	StateUpdate("This is an update")
	return

Scroll:
	GuiControlGet, StartX
	GuiControlGet, StartY
	GuiControlGet, EndX
	GuiControlGet, EndY
	ClickAndDrag(StartX,StartY,EndX, EndY)
return	
StateUpdate(NewState){
	GuiControl,,State, %NewState%
	Return
	}

TimeUpdate(NewTime){
	GuiControl,,ElapsedTime, %NewTime%
	Return
	}	

		
;--------Function-----------------------
ClickAndDrag(StartPosX, StartPosY,EndPosX, EndPosY,Speed){
	MouseClickDrag, Left, StartPosX, StartPosY, EndPosX, EndPosY, 65
		
}
ClickAtLocation(LocPosX,LocPosY){
	;MouseClick, left, LocPosX, LocPosY, 2, D
	ControlClick,  x%LocPosX% y%LocPosY%, Main game,
	;msgbox, %LocPosX%, %LocPosY% has been clicked
	return
	}
	
SearchForImage(Img){					;Make this take in an image type and specify coords based on image name
	IfWinExist, Main game
	{
		;WinActivate, Main game    no ac
		IfNotExist, %Img% 
		MsgBox Error: Your file either doesn't exist or isn't in this location.
			
		;~~Image case statment Relative to Main game	
		; if (Img = "Touch.png"){
			; lowerX := 450
			; upperX := 1180
			; lowerY:= 780
			; upperY:= 1180
		; } else if(Img = "AttackMissionToken.png"){
			; lowerX := 190
			; upperX := 246
			; lowerY:= 47
			; upperY:= 96
		; } else {
			; lowerX := 10
			; upperX := 30
			; lowerY:= 10
			; upperY:= 30
		; }
		;Image case statment Relative to screen	
		if (Img = "Touch.png"){
			lowerX := 450+1920
			upperX := 1180+1920
			lowerY:= 780
			upperY:= 1180
		} else if(Img = "AttackMissionToken.png"){
			lowerX := 195 +1920 
			upperX := 245 +1920
			lowerY:= 75
			upperY:= 125
		} 
		else if(Img = "OkButton.png"){
			lowerX:= 640+1920
			upperX:= 1025+1920
			lowerY:= 837
			upperY:= 1050
		}else if(Img = "AutoButton.png"){
			lowerX:= 640+1920
			upperX:= 1025+1920
			lowerY:= 937
			upperY:= 1050
		} else {
			lowerX := 10
			upperX := 30
			lowerY:= 10
			upperY:= 30
		}
		
		; MouseMove, lowerX, lowerY, 50
		; sleep 500
		; MouseMove, upperX, upperY, 50
		; sleep 500
		
		ImageSearch, LocX, LocY, lowerX, lowerY, upperX, upperY, *100 %Img% ;last remaining token
		;ImageSearch, LocX, LocY, 330, 40, 380, 94, *100 AttackMissionToken.png ;one missing
		;MsgBox, second image found at %LocX%, %LocY%
		if(LocX>0 and LocY>0){
			StateUpdate(Img) ;!!! Try a delay
			flag:= True
			} else{
			flag:= False
			}
		return flag
	}else
		WinActivate, Calculator
}
		
	
;--------------Test things ------------------
SearchForCertainImage:

	if(SearchForImage("Enemy.png")){
	msgbox, image found 
	}
	else{
	msgbox, image not found
	}
	return

Test2:
	t:=0
	Loop{
		Sleep, 1000
		t+=1000
	}Until ( t>10000)
	MsgBox %t% ms
	return
Test:
	IfWinExist, Main game
		WinActivate, Main game
	else
		WinActivate, Calculator
	; PosX:= 58
	; PosY:= 70
	; ClickAtLocation(PosX, PosY)
	; Sleep 1000
	; PosX:= 1500
	; PosY:= 800
	; ClickAtLocation(PosX, PosY)
	; sleep 1000
	; Random, PosX, 2, 90
	; Random, PosY, 30, 100
	; ClickAtLocation(PosX, PosY)
	
	
	if (SearchForImage("AttackMissionToken.png")){
		MsgBox, image found
		} else{
		msgbox, image not found
		}
	return
	
GuiClose:
ExitApp
return
; -------------------- Main Script -----------------
Pause Off

^Esc:: Pause
+Esc:: ExitApp
