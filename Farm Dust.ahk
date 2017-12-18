#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

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
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;---[] End mission early if Touch exists, or timeout
	;		WaitForImage (with a timeout)
	;[] Search for OK Button (in order to deal with connection errors. Will need a break if it doesn't find Auto some time after)
	;;****Plan next steps****

;Optional
;[X] Randomize click locations in area for bot correction



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

SetWorkingDir, D:\AutoHotKey\Images

;-------------Gui Layout ------------

 Gui, +AlwaysOnTop ;stays on top
 PosX := 200
PosY := 400 

CoordMode Mouse, Relative
Gui, Add, Text, cAqua x10 y10, Hello	
Gui, Add, Edit, r1 vPosX number, %PosX%
Gui, Add, Edit, r1 vPosY number, %PosY%
Gui, Add, Button, x+50 w75 h20 ggoClick, Force A Click	 ;gSomething does a go to to execute a label
Gui, Add, Button, w75 h20 gAttackMission, Attack Mission
gui, Add, Button, w100 h20 gSearchForCertainImage, Search for Image
gui, Add, Button, w100 h25 gTest, Test
gui, Add, Button, w100 h25 gTest2, Test for Touch
;x+50 adds 50 pixels to the previous element, If yo u
;A new Gui, Add, Text will start an element on the next line
							
Gui, Font, s17 cBlack
Gui, Color, Grey ;Hex Code works HTML
Gui, Show, x1600 y20 w300 h200, GUI
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
			Gosub, WindowMax
			Sleep 500
		;Click on attack mission
			Gosub, startAtkMis
			Sleep 1500
		;Cofirm spending of attack token
			Gosub, confirmAtkMis
			Sleep 14000
		;Click ok to deploy troops
			gosub, okBtn 
			sleep 11000
		;Click auto
			gosub, autoBtn
			sleep 240000
		;Touch for Victory screen
			gosub, touch
			Sleep 5000
		;Touch for Spoils screen
			gosub, touch
			Sleep 10000
	} 
	msgbox, Out of tokens
	
	return 

WindowMax:		;improve this
	Random, PosX, 1395, 1405
	Random, PosY, 13, 17
	ClickAtLocation(PosX, PosY)
	return	
	
startAtkMis:
	Random, PosX, 530, 720
	Random, PosY, 680, 850
	ClickAtLocation(PosX, PosY)
	return	
confirmAtkMis:
	Random, PosX, 980, 1130
	Random, PosY, 750, 800
	ClickAtLocation(PosX, PosY) 
	return
autoBtn:
	t:= 0
	Random, PosX, 730, 900
	Random, PosY, 970, 995
	ClickAtLocation(PosX, PosY) 
	
	return
okBtn:
	Random, PosX, 750, 900
	Random, PosY, 925, 950
	ClickAtLocation(PosX, PosY)
	Return
touch:
	Random, PosX, 550, 1110
	Random, PosY, 800, 950
	ClickAtLocation(PosX, PosY)
	return 
	
SearchForCertainImage:
	if(SearchForImage("AttackMissionToken.png")){
	msgbox, image found 
	}
	else{
	msgbox, image not found
	}
	return
goClick:
	GuiControlGet, PosX
	GuiControlGet, PosY
	
	ClickAtLocation(PosX,PosY)
	return
	
GuiClose:
	ExitApp
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
		
;--------Function-----------------------
ClickAtLocation(LocPosX,LocPosY){
	;MouseClick, left, LocPosX, LocPosY, 2, D
	ControlClick,  x%LocPosX% y%LocPosY%, Main game,
	;msgbox, %LocPosX%, %LocPosY% has been clicked
	return
	}
	SearchForImage(Img){					;Make this take in an image type and specify coords based on image name
	IfWinExist, Main game
		WinActivate, Main game
	else
		WinActivate, Calculator
	IfNotExist, %Img% 
    MsgBox Error: Your file either doesn't exist or isn't in this location.
		
	;Image case statment	
	if (Img = "Touch.png"){
		lowerX := 450
		upperX := 1180
		lowerY:= 780
		upperY:= 1180
	} else if(Img = "AttackMissionToken.png"){
		lowerX := 190
		upperX := 246
		lowerY:= 47
		upperY:= 96
	} else {
		lowerX := 10
		upperX := 30
		lowerY:= 10
		upperY:= 30
	}
	
	;MouseMove, 175, 40, 50
	;sleep 500
	;MouseMove, 250, 94, 50
	;sleep 500
	
	ImageSearch, LocX, LocY, lowerX, lowerY, upperX, upperY, *100 %Img% ;last remaining token
	;ImageSearch, LocX, LocY, 330, 40, 380, 94, *100 AttackMissionToken.png ;one missing
	;MsgBox, second image found at %LocX%, %LocY%
	if(LocX>0 and LocY>0){
		flag:= True
		} else{
		flag:= False
		}
	return flag
	}

; -------------------- Main Script -----------------
Pause Off

^Esc:: Pause
Esc:: ExitApp
