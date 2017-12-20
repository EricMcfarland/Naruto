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

; Start Special missions
;[X]specify which mission
;[X]specify Difficulty
;[X]Press small Ok btn
;[X]Press auto
;[X]Press first Touch
;[X]Press second Touch
;!!!!!![]Loop
	
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
Gui, Add, Text, x+10 y+10 cAqua vElapsedTime, ElapsedTime: %ElapsedTime%	
; Gui, Add, Edit, r1 vPosX number, %PosX%
; Gui, Add, Edit, r1 vPosY number, %PosY%
;gui, add, text, cGreen w100 r1 vElapsedTime, ElaspedTime: %ElapsedTime%
gui, add, text, w250 cGreen r1 vState, %State%
Gui, Add, Button, w75 r1 gAttackMission, Attack Mission
Gui, Add, Button, w75 gSpecialMission, Special Mission
gui, Add, Text, x+10 w40 h30, 
gui, add, UpDown, x+10 vMissionNumber Range1-5, 1 
gui, Add, Text, x+10 w40 h30,
gui, add, UpDown, x+10 vDifficultyNumber Range1-4, 1

gui, Add, Button, y+20 w100 h20 gSearchForCertainImage, Search for Image

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



;x+50 adds 50 pixels to the previous element, If yo u
;A new Gui, Add, Text will start an element on the next line
							
Gui, Font, s17 cBlack
Gui, Color, Grey ;Hex Code works HTML
Gui, Show, x1400 y20 w350 h400 NA, GUI
return


;---------Main Routines---------------------\
	
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
			gosub, touch
			;Sleep 5000
		;Touch for Spoils screen
			gosub, touch
			Sleep 8000
	} 
	msgbox, Out of tokens
	
	return 

SpecialMission:
;Use GUI Updowns to set mission and difficulty
;Click on Special Mission Icon
;Select Mission based on updown 
;Select Difficulty (Click on difficulty, if details not present then click on difficulty then Next, else just clikc Next
;Click Next
;Click small Ok
;Check if not enough LP by looking for NO Button
;Press Auto
;Press Touch1
;Press Touch2
;Repeat

gosub startSpecialMission
sleep 1000
Gosub selectSpecialMission
sleep 2000
gosub selectDifficulty
gosub OkBtnSmall
gosub AutoBtn
gosub Touch
gosub Touch

return	


;-------------Sub Routines----------------
; WindowMax:		;improve this
	; Random, PosX, 1395, 1405
	; Random, PosY, 13, 17
	; ClickAtLocation(PosX, PosY)
	; return	
	
startSpecialMission:
	Random, PosX, 980, 1130
	Random, PosY, 300, 430
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". Started Special Mission") 
	ClickAtLocation(PosX, PosY)
return

selectSpecialMission:
	Gui,Submit, NoHide
	StateUpdate("Mission number: " . MissionNumber . ". Difficulty: " . DifficultyNumber)
	Sleep 500
	if(MissionNumber <4){
		Random PosX, 500,1200
		Random PosY, 120 + MissionNumber *230, 240 + MissionNumber *230
		StateUpdate("Clicked at: " . PosX . "," . PosY . ". Special Mission " . MissionNumber . " Selected") 
		ClickAtLocation(PosX, PosY)		
	} else{
		Random PosX, 1480, 1490
		Random PosY, 860, 880
		StateUpdate("Scrolled down")
		ClickAtLocation(PosX, PosY)
		sleep 500
		
		Random PosX, 500,1200
		Random PosY, 270 + (MissionNumber -3) *230, 300 + (MissionNumber-3) *230
		StateUpdate("Clicked at: " . PosX . "," . PosY . ". Special Mission " . MissionNumber . " Selected") 
		ClickAtLocation(PosX, PosY)	
		
	}
	return
selectDifficulty:
	;Look for NEXT button before continuing
	t:=0
	Loop{
		Sleep 500
		TimeUpdate(t)
		t+=500
	}Until (t>8000 or SearchForImage("NEXT.png"))
	
	;Click on correct diff setting
	Gui, Submit, NoHide
	StateUpdate("Mission number: " . MissionNumber . ". Difficulty: " . DifficultyNumber)
	Random PosX, 260,750
	Random PosY, 180 + DifficultyNumber *145, 190 + DifficultyNumber *145
	ClickAtLocation(PosX, PosY)	
	Sleep 500
	
	;If Details is present then click Next
	if(SearchForImage("Details.png")){	;If details is present after clicking mission number proceed to press next
		StateUpdate("Details found")
		Random PosX, 960, 1180
		Random PosY, 910, 960
		ClickAtLocation(PosX, PosY)
	} else{								;If details is not present then no mission is slected so reselect mission
		StateUpdate("Mission Reslected and Nextpressed")
		sleep 700
		Random PosX, 260,750
		Random PosY, 180 + DifficultyNumber *145, 200 + DifficultyNumber *145
		ClickAtLocation(PosX, PosY)
		
		sleep 700
		;Press Next
		Random PosX, 960, 1180
		Random PosY, 910, 960
		ClickAtLocation(PosX, PosY)
	}	
return
okBtnSmall:
	t:=0
	Loop{
		Sleep, 500
		TimeUpdate(t)
		t+=500
		
		;TRY- get the active window at end of script WinGetActiveTitle, LastWindow
		;	Then set that window back to active on next loop WinActivate LastWindow
	}Until ( t>22000 or SearchForImage("OkButtonSmall.png"))
	Random, PosX, 765, 875
	Random, PosY, 910, 940
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". OkButton pressed")
	ClickAtLocation(PosX, PosY)
	sleep 1000
	return
return
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
	
	ClickAtLocation(PosX, PosY) 
	return
okBtn:
	t:=0
	Loop{
		Sleep, 500
		TimeUpdate(t)
		t+=500
		
		;TRY- get the active window at end of script WinGetActiveTitle, LastWindow
		;	Then set that window back to active on next loop WinActivate LastWindow
	}Until ( t>22000 or SearchForImage("OkButton.png"))
	sleep 1000
	Random, PosX, 765, 875
	Random, PosY, 910, 940
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". OkButton pressed")
	ClickAtLocation(PosX, PosY)
	
	Return
autoBtn:
	t:=0
	Loop{
		Sleep, 1000
		TimeUpdate(t)
		t+=1000
		
		;TRY- get the active window at end of script WinGetActiveTitle, LastWindow
		;	Then set that window back to active on next loop WinActivate LastWindow
	}Until ( t>20000 or SearchForImage("AutoButton.png"))
	sleep 1000
	Random, PosX, 740, 890
	Random, PosY, 975, 990
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". AutoButton pressed")
	ClickAtLocation(PosX, PosY) 
	
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

touch:
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
		Sleep, 500
		TimeUpdate(t)
		t+=500
		;TRY- get the active window at end of script WinGetActiveTitle, LastWindow
		;	Then set that window back to active on next loop WinActivate LastWindow
	}Until ( t>222000 or SearchForImage("Touch.png"))
	sleep 1000
	Random, PosX, 550, 1110
	Random, PosY, 800, 950
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". First Touch pressed")
	ClickAtLocation(PosX, PosY)
	t:=0
	return 
	
	
UpdateState:
	TimeUpdate("10")
	StateUpdate("This is an update")
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
		else if(Img = "OkButton.png" or Img ="OkButtonSmall.png"){
			lowerX:= 640+1920
			upperX:= 1025+1920
			lowerY:= 837
			upperY:= 1050
		}else if(Img = "AutoButton.png"){
			lowerX:= 640+1920
			upperX:= 1025+1920
			lowerY:= 937
			upperY:= 1050
		}else if(Img = "NEXT.png"){
			lowerX:= 890+1920
			lowerY:= 860
			upperX:=1270+1920
			upperY:= 1050
		
		}else if(Img = "Details.png"){
			lowerX:= 1110+1920
			lowerY:= 700
			upperX:=1440+1920
			upperY:= 800
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

	if(SearchForImage("OkButtonSmall.png")){
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
