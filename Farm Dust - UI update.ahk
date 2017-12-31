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
;[X] Adjustable resolution -1600x900 works for sure
;[]Will need a break if it doesn't find Auto some time after)
;[] Update UI 
;[] Near full mission automation (story->attack->story->etc)
;[] Work from any Screen


;Optional
;[] Ult after 'Enemy appears'
;[] Review macro level design. Handle outlier cases such as lvl up and academy upgrades



SetWorkingDir, D:\AutoHotKey\Scripts\Naruto\Images

;-------------Gui Layout ------------

 
State:= "Initial State"
ElapsedTime := 0
SleepTime:=500
global XRes:= 1600
global YRes:= 900
global XUnits:= XRes//100
global YUnits:= YRes//100
global debugMode:= False
global EndLoop := False

CoordMode Pixel, Screen
CoordMode Mouse, Screen
gui, font, cgray
Gui, +Resize +LastFound
gui, Add, Tab3,AltSubmit -Wrap , Main|Debug Mode
Gui, Tab, 1
	
; Gui, Add, Edit, r1 vPosX number, %PosX%
; Gui, Add, Edit, r1 vPosY number, %PosY%
;gui, add, text, cGreen w100 r1 vElapsedTime, ElaspedTime: %ElapsedTime%

Gui, Add, Button,  w75 r1 gAttackMission, Attack Mission
Gui, Add, Button, w75 h30 gSpecialMission section, Special Mission
gui, Add, Text, x+10 w40 h30, 
gui, add, UpDown, x+10 vMissionNumber Range1-5, 1 
gui, Add, Text, x+10 w40 h30,
gui, add, UpDown, x+10 vDifficultyNumber Range1-4, 1
gui, add, Button, xs w125 r1 gFullRun, Full Run
gui, add, button, w125  r1 gSetEnd, End After this Run
gui, add, text, x+25 w150 r2 vAlertEnd, State: %AlertEnd%


Gui,Tab,2
gui, add, Checkbox, vdebugMode, debug mode 
Gui, Add, Text, x+10 y+10 cAqua vElapsedTime, ElapsedTime: %ElapsedTime%
gui, add, text, w250 cGreen r1 vState, %State%
gui, add, text, w250 cRed r1, SleepTime(ms)
gui, add, Edit, w75 r1 vSleepTime, %SleepTime%
gui, Add, Button, y+20 w100 h20 gSearchForCertainImage, Search for Image
gui, Add, Button, w100 r1 gUpdateState, Test for state updates
gui, Add, Button, w100 h25 gTest2, Test for Touch
; StartX:=2090
; StartY:=650
; EndX:=2090
; EndY:=300
; gui,add,text,,StartX
; gui,Add,Edit, r1 vStartX, %StartX%
; gui,add,text,,EndX
; gui,Add,Edit, r1 vEndX, %EndX%
; gui,add,text,,StartY
; gui,Add,Edit, r1 vStartY, %StartY%
; gui,add, Text,,EndY
; gui,Add,Edit, r1 vEndY, %EndY%



;x+50 adds 50 pixels to the previous element, If yo u
;A new Gui, Add, Text will start an element on the next line
							
Gui, Font, s17 cBlack
Gui, Color, Grey ;Hex Code works HTML
Gui, Show, x1400 y20 w350 h400 NA, GUI
return


;---------Main Routines---------------------\
FullRun:
	Loop{
	gosub AttackMission
		if(EndLoop=True){			;Break loop after current Attack mission  ends
			StateUpdate("Attack Loop was ended by user")
			break
		}
	gosub SpecialMission
		if(EndLoop=True){			;Break loop after current Special mission ends
			StateUpdate("Special Loop was ended by user")
			break
		}
	}
return

SetEnd:
	If EndLoop{
		thisText:="This run will continue"
			GuiControl,,AlertEnd, %thisText%
			EndLoop:= False
		}
	Else{
			thisText:="The script will end at the completion of this run"
			GuiControl,, AlertEnd, %thisText%
			EndLoop:=True
		}
Return	

AttackMission:
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

	
	IfWinExist, Main game
		WinActivate, Main game
	else
		msgbox Game isnt open
	
	;Loop while attack mission token exists
	Loop{
			if(EndLoop=True){
				Break
			}
		;Click on attack mission
			Gosub, startAtkMis
			
		;Cofirm spending of attack token
			Gosub, confirmAtkMis
			Sleep 4*SleepTime
			if(SearchForImage("Yes1600x900.png")){
				;click X due to no resources
				Random PosX, 84*XUnits, 85*XUnits
				Random PosY, 14*YUnits, 15*YUnits
				ClickAtLocation(PosX, PosY)
				return 
			}else{
			gosub, okBtn 
			gosub, autoBtn
			gosub, touch
			gosub, touch
			Sleep 15*SleepTime
		}
	}
	StateUpdate("Completed Attack Missions")
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
	sleep 2*SleepTime
Loop {
	if(EndLoop=True){
		Break
	}
	Gosub selectSpecialMission
	gosub selectDifficulty
	sleep 4*SleepTime
		if(SearchForImage("Yes1600x900.png")){
			Random PosX, 84*XUnits, 85*XUnits
			Random PosY, 14*YUnits, 15*YUnits
			ClickAtLocation(PosX, PosY)
			StateUpdate("Out of resource. Loop broken")
			return 
		}else{
		gosub OkBtnSmall
		gosub AutoBtn
		gosub Touch
		gosub Touch
		Sleep 15*SleepTime
	}
}
StateUpdate("Completed Special Missions")

return	


;-------------Sub Routines----------------
	
startSpecialMission:
	Random, PosX, 58*XUnits, 65*XUnits
	Random, PosY, 27*YUnits, 38*YUnits
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". Started Special Mission") 
	ClickAtLocation(PosX, PosY)
return

selectSpecialMission:
	Loop{
		Sleep SleepTime
		TimeUpdate(t)
		t+=500
	}Until (SearchForImage("SpecialMission1600x900.png"))
	Gui,Submit, NoHide
	StateUpdate("Mission number: " . MissionNumber . ". Difficulty: " . DifficultyNumber)
	Sleep SleepTime
	if(MissionNumber <4){
		Random PosX, 18*XUnits,75*XUnits
		Random PosY, 11*YUnits + MissionNumber *25*YUnits, 17*YUnits + MissionNumber *25*YUnits
		StateUpdate("Clicked at: " . PosX . "," . PosY . ". Special Mission " . MissionNumber . " Selected") 
		ClickAtLocation(PosX, PosY)		
	} else{
		Random PosX, 87*XUnits, 88*XUnits
		Random PosY, 86*YUnits, 87*YUnits
		StateUpdate("Scrolled down")
		ClickAtLocation(PosX, PosY)
		sleep SleepTime
		
		Random PosX, 18*XUnits,75*XUnits
		Random PosY, 22*YUnits + (MissionNumber -3) *24*YUnits, 24*YUnits + (MissionNumber-3) *24*YUnits
		StateUpdate("Clicked at: " . PosX . "," . PosY . ". Special Mission " . MissionNumber . " Selected") 
		ClickAtLocation(PosX, PosY)	
		
	}
	return
selectDifficulty:
	;Look for NEXT button before continuing
	t:=0
	Loop{
		Sleep SleepTime
		TimeUpdate(t)
		t+=500
	}Until (SearchForImage("Next1600x900.png"))
	
	;Click on correct diff setting
	Gui, Submit, NoHide
	StateUpdate("Mission number: " . MissionNumber . ". Difficulty: " . DifficultyNumber)
	Random PosX, 18*XUnits,30*XUnits
	Random PosY, 20*YUnits + 15*YUnits*DifficultyNumber , 21*YUnits + DifficultyNumber*15*YUnits
	StateUpdate(PosY)
	sleep 4*SleepTime
	ClickAtLocation(PosX, PosY)	
	Sleep 3*SleepTime
	
	;If Details is present then click Next
	if(SearchForImage("Details1600x900.png")){	;If details is present after clicking mission number proceed to press next
		StateUpdate("Details found")
		;Pres Next
		Random PosX, 58*XUnits, 71*XUnits
		Random PosY, 91*YUnits, 93*YUnits
		ClickAtLocation(PosX, PosY)
	} else{								;If details is not present then no mission is slected so reselect mission
		StateUpdate("Mission Reslected and Nextpressed")
		sleep 2*SleepTime
		Random PosX, 18*XUnits,30*XUnits
		Random PosY, 20*YUnits + 15*YUnits*DifficultyNumber , 21*YUnits + DifficultyNumber*15*YUnits
		ClickAtLocation(PosX, PosY)
		
		sleep 3*SleepTime
		;Press Next
		Random PosX, 58*XUnits, 71*XUnits
		Random PosY, 91*YUnits, 93*YUnits
		ClickAtLocation(PosX, PosY)
	}	
return

okBtnSmall:
	t:=0
	Loop{
		Sleep, SleepTime
		TimeUpdate(t)
		t+=500
	}Until (SearchForImage("OkButtonSmall1600x900.png"))
	Random, PosX, 46*XUnits, 50*XUnits
	Random, PosY, 89*YUnits, 91*YUnits
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". OkButton pressed")
	ClickAtLocation(PosX, PosY)
	
return

startAtkMis:
	Random, PosX, 32*XUnits, 40*XUnits
	Random, PosY, 66*YUnits, 72*YUnits
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". Started Attack Mission") 
	ClickAtLocation(PosX, PosY)
return	
	
confirmAtkMis:
	Gui,Submit, NoHide
	Loop{
		Sleep SleepTime
		TimeUpdate(t)
		t+=500
	}Until (SearchForImage("AttackMissionYes1600x900.png"))
	Random, PosX, 60*XUnits, 67*XUnits
	Random, PosY, 75*YUnits, 76*YUnits
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". Confirm pressed")
	ClickAtLocation(PosX, PosY) 
return

okBtn:
	t:=0
	Loop{
		Sleep, SleepTime
		TimeUpdate(t)
		t+=500
	}Until (SearchForImage("OkButton1600x900.png"))
	sleep 2*SleepTime
	Random, PosX, 45*XUnits, 49*XUnits
	Random, PosY, 91*YUnits, 92*YUnits
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". OkButton pressed")
	ClickAtLocation(PosX, PosY)
Return

autoBtn:
	t:=0
	Loop{
		Sleep, SleepTime
		TimeUpdate(t)
		t+=500
		
	}Until (SearchForImage("AutoButton1600x900.png"))
	sleep 2*SleepTime
	Random, PosX, 44*XUnits, 48*XUnits
	Random, PosY, 91*YUnits, 92*YUnits
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". AutoButton pressed")
	ClickAtLocation(PosX, PosY) 
return
	
PressUlt:
	t:= 0
	Random, PosX, 730, 900
	Random, PosY, 970, 995
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". AutoButton pressed")
	ClickAtLocation(PosX, PosY) 
	Loop{
		Sleep, SleepTime
	
		t+=500
	}Until (SearchForImage("Touch.png"))
return

touch:
	t:=0
	Loop{
		Sleep, SleepTime
		TimeUpdate(t)
		t+=500
	}Until (SearchForImage("Touch1600x900.png"))
	sleep 2*SleepTime
	Random, PosX, 37*XUnits, 66*XUnits
	Random, PosY, 84*YUnits, 92*YUnits
	StateUpdate("Clicked at: " . PosX . "," . PosY . ". First Touch pressed")
	ClickAtLocation(PosX, PosY)
return 
	
	
UpdateState:
	TimeUpdate("10")
	StateUpdate(50*XUnits +1920)
	MouseMove 50*XUnits, 500, 50
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
	if(debugMode=1){
		MouseClick, left, LocPosX, LocPosY, 2, D
		msgbox, %LocPosX%, %LocPosY% has been clicked
	}
	ControlClick,  x%LocPosX% y%LocPosY%, Main game,
	
	return
	}
	
SearchForImage(Img){					;Make this take in an image type and specify coords based on image name
	Gui, Submit, NoHide
	IfWinExist, Main game
	{
		IfNotExist, %Img% 
		MsgBox Error: Your file either doesn't exist or isn't in this location.
		
		if(debugMode=1){
			; MouseMove, lowerX, lowerY, 50
			; sleep 500
			; MouseMove, upperX, upperY, 50
			; sleep 500
		}
		
		;Searching Full screen. Seems fast enough
		ImageSearch, LocX, LocY, 1920, 0, 1920+1600, 900, *100 %Img% ;last remaining token
		if(LocX>0 and LocY>0){
			StateUpdate(Img) 
			flag:= True
			} else{
			flag:= False
			}
		return flag
	}else
		return
}
		
	
;--------------Test things ------------------
SearchForCertainImage:

	if(SearchForImage("OkButton1600x900.png")){
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
!Esc:: Reload
^Esc:: Pause
+Esc:: ExitApp
