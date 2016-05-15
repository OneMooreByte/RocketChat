#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

CurrentVersion := "1.0"
ProgramName = Rocket Chat
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
FileCreateDir, %A_AppData%\%ProgramName%
SavedMessagesFolder = %A_AppData%\%ProgramName%\SavedMessages
FileCreateDir, %SavedMessagesFolder%
SavedOverlayFolder = %A_AppData%\%ProgramName%\SavedOverlays
FileCreateDir, %SavedOverlayFolder%
AppFolder = %A_AppData%\%ProgramName%
PortCheckPath = %AppFolder%\ConnectionCheck.txt
PATH_OVERLAY =%AppFolder%\dx9_overlay.dll
FileInstall, dx9_overlay.dll, %Path_Overlay%
FileInstall, DefaultMessages, %SavedMessagesFolder%\DefaultMessages
FileInstall, DefaultOverlay, %SavedOverlayFolder%\DefaultOverlay
FileInstall, Help.chm, %AppFolder%\Help.chm
FileInstall, RLIcon.ico, %AppFolder%\RLIcon.ico
#include overlay.ahk
#include FontSelector.ahk

;---Initialize Variables---
OverlayInitialized = 0
AxisActiveRatio:=0.19
OverlayMenuLastUpdateTime:=0
PSign:= "%"
CurrDir = None
CurrMenu = None
Running := 0
MenuOpenTime := 0
ChatMode := 1
ChatModeVisible = 0
LastInGameCheck = 0
InGame := False
SteamPortList = 27000,27001,27002,27003,27004,27005,27006,27007,27008,27009,27010,27011,27012,27013,27014,27015,27016,27017,27018,27019,27020,27021,27022,27023,27024,27025,27026,27027,27028,27029,27030,27031,27032,27033,27034,27035,27036,4380,3478,4379,1500,3005,3101
InGameCheckPeriod = 1000
RLProcess = RocketLeague.exe ;Process name used to identify Rocket League
SetParam("process", RLProcess)

SetFormat, Float, 0.3

;------Load Parameters------
IniPath = %A_AppData%\%ProgramName%\SavedParameters.ini
LoadIni("All",IniPath)

;----------Overlay Settings-----------

FontSizeMed := 10
OverlayTeamYOffsetMed := 5
OverlayYSpacingMed := 30
OverlayBgBotAdjMed := 20
OverlayBgMargin := 5
OverlayTimerH := 3
OverlayTimerYOffset := 1

OverlayMenuUpdatePeriod:= 10

OverlayXSpacing := 20

OverlayTextOpac:= 255

;----Default-----
DefaultUpUp = I got it!
DefaultUpLeft = Centering...
DefaultUpRight = Take the shot!
DefaultUpDown = Defending...

DefaultLeftUp = Nice shot!
DefaultLeftLeft = Great pass!
DefaultLeftRight = Thanks!
DefaultLeftDown = What a save!

DefaultRightUp = OMG!
DefaultRightLeft = Noooo!
DefaultRightRight = Wow!
DefaultRightDown = Close one!

DefaultDownUp := "$#@%!"
DefaultDownLeft = No Problem.
DefaultDownRight = Whoops...
DefaultDownDown = Sorry!


;------------GUI---------

;--GUI Variables---
StandardGuiFont = Arial
StandardGuiFontSize = 9

BoxLabelHeight :=15 ;Height of groupboxlabel
yTopRow := 5 ;Y placement of top row

TabXPos := 12 ;X Position of Tab box
TabYPos := 50 ;Y Position of Tab box
TabSelectionAreaThickness := 30 ;Y buffer to keep selection area unobstructed

MaxMsgLength := 32 ;Maximum Characters in a message.
LabelsOffset := 15 ;y Distance between chat labels and chat inputs
TeamLabelOffset :=12 ;Team Label Offset in X Direction to center over checkboxes
SymbolLength := 16 ;Direction Symbol X Length in Chat Tab
MsgLength := 220 ;Chat Message X Length in Chat Tab
TeamLength := 15 ;Team Checkbox X Length in Chat Tab
xSpacing := 4 ;x spacing between controls in chat section
ySpacing := 4 ;y spacing between controls in chat section
TextHeight := 20 ;Chat Message Box height used for spacing
ySymbolOffset := 3 ;amount to lower symbol in y direction to make centered with chat message box
yTeamOffset := 3 ;amount to lower team checkbox in y direction to make centered with chat message box
;Symbols used to denote directions
SymbolUp = UP
SymbolLeft = LT
SymbolRight = RT
SymbolDown = DN

SettingLabelXPos := 20 + TabXPos ;x Position of setting labels
SettingLabelWidth := 100 ;width of setting labels
SettingXSpacing := 5 ;Spacing between setting label and setting input
SettingInputXPos := SettingLabelXPos + SettingXSpacing + SettingLabelWidth ;X Position of Setting Inputs
SettingYSpacing := 3 ;y Spacing between each of the settings

FirstLoadTitle = Welcome to %ProgramName%

;---Start Program---
;LastVersion = 0 ;Forces FirstLoad ON
If LastVersion = 0
{
GoSub, OpenFirstLoadGui
WinWaitClose, %FirstLoadTitle%
}

LastVersion := CurrentVersion
GoSub, OpenMainGui

OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x203,"WM_LButtonDBLCLK")

Start()
If AutoLaunchRL
	GoSub OpenRocketLeague
Return


;---First Stop GUI---
OpenFirstLoadGui:
Gui, 1:New
Gui, Font, s11, %standarGuiFont%
Gui, Add, Edit, w535 x15 y5 ReadOnly -E0x200 -VScroll Center, This seems to be your first time opening Rocket Chat`nRocket Chat uses macros to give you custom quick chat messages
TempIndent = 10
TempspacingBig=20
Tempspacing=10
TempspacingSmall = 5
TempWidthBig = 360
TempWidth = 350
TempWidthSmall = 340
Gui, Add, Text, +Wrap w%TempWidthBig% x15 y50,Please follow the steps below to complete the initial setup:`n(All of these settings can be changed later)
Gui, Add, Text, +Wrap w%TempWidth% x25 y+%TempSpacingBig%, 1. Select your controller type from the dropdown on the right.
Gui, Add, Text, +Wrap w%TempWidthSmall% xp+%TempIndent% y+%TempSpacingSmall%, a. If your controller is not listed, select “Custom” and press the “Calibrate Custom Controller” button and follow the instructions that pop-up.
Gui, Add, Text, +Wrap w%TempWidth% x25 y+%TempSpacing%, 2. Rocket Chat allows you to toggle between custom quick chat and standard quick chat. In the “Toggle Chat Mode” box, select which controller button will be used to toggle chat modes. (If not set, only "Custom" mode will be used)
Gui, Add, Text, +Wrap w%TempWidth% x25 y+%TempSpacing%, 3. In Rocket League, open Options>Controls and do the following:
Gui, Add, Text, +Wrap w%TempWidthSmall% xp+%TempIndent% y+%TempSpacingSmall%, a. Unbind your controller from quick chat, be sure to keep the keyboard bindings active
Gui, Add, Text, +Wrap w%TempWidthSmall% xp y+%TempSpacingSmall%,b. If you have modified the keyboard bindings, copy the keyboard bindings to their corresponding input box on the right.
Gui, Add, Text, +Wrap w%TempWidthBig% x15 y+%TempSpacingBig%,When finished click the “Continue” button.
Gui, Add, Button, gCloseFirstGui vInitalCloseButton x90 y+%TempSpacingBig% w200 r2 center, Continue
TempXPos = 395
GoSub ResetGuiFont ;Set Font Size
Gui, Add, Text, x%TempXPos% y50 w75 r1 Right, Controller:
Gui, Add, DropDownList, vJoystickTypeFirst x+%SettingXSpacing% yp+0 w75 Choose%JoystickType% AltSubmit, Xbox 360|Custom
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w75 r1 Right HwndHwndTemp1, Controller #:
Gui, Add, DropDownList, vSelectedJoystickNumber x+%SettingXSpacing% yp+0 w75 Choose%SelectedJoystickNumber% AltSubmit, Auto Find|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16
Gui, Add, Button, gCustomCalibrate vCustomCalibrateButtonFirst x%TempXPos% y+%SettingYSpacing% w155 r2 center, Calibrate Custom Controller
TempYPos = 175
Gui, Add, Text, x%TempXPos% y%TempYPos% w100 r1 Right HwndHwndTemp1, Controller Button:
Gui, Add, Button, vToggleChatButton gSetToggleChatButton x+%SettingXSpacing% yp+0 w45 r1 HwndHwndTemp2, %ToggleChatButton%
HwndTemp3 := CreateGroupBox("Toggle Chat Mode", 5, HwndTemp1, HwndTemp2, HwndTemp1, HwndTemp2)
TempYPos = 260
TempXPos = 400
Gui, Add, Text, x%TempXPos% y%TempYPos% w120 r1 Right HwndHwndTemp1, All Chat:
Gui, Add, Edit, vAllChatFirst Limit1 x+%SettingXSpacing% yp+0 w15 r1, %AllChat%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w120 r1 Right, Team Chat:
Gui, Add, Edit, vTeamChatFirst Limit1 x+%SettingXSpacing% yp+0 w15 r1 HwndHwndTemp5, %TeamChat%
HwndTemp4:=CreateGroupBox("Open Chat", 5, HwndTemp1, HwndTemp5, HwndTemp1, HwndTemp5)
TempXpos := TempXPos
Gui, Add, Text, x%TempXPos% y+20 w120 r1 Right HwndHwndTemp2, Information (Up):
Gui, Add, Edit, vStandardChatUpFirst Limit1 x+%SettingXSpacing% yp+0 w15 r1, %StandardChatUp%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w120 r1 Right, Compliments (Left):
Gui, Add, Edit, vStandardChatLeftFirst Limit1 x+%SettingXSpacing% yp+0 w15 r1, %StandardChatLeft%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w120 r1 Right,Reactions (Right):
Gui, Add, Edit, vStandardChatRightFirst Limit1 x+%SettingXSpacing% yp+0 w15 r1, %StandardChatRight%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w120 r1 Right,Apologies (Down):
Gui, Add, Edit, vStandardChatDownFirst Limit1 x+%SettingXSpacing% yp+0 w15 r1 HwndHwndTemp3, %StandardChatDown%
HwndTemp5:=CreateGroupBox("Quick Chat", 5, HwndTemp2, HwndTemp3, HwndTemp2, HwndTemp3)
CreateGroupBox("RL Keyboard Bindings", 5, HwndTemp4, HwndTemp5, HwndTemp4, HwndTemp5)
GuiControl, Focus, CustomCalibrateButtonFirst
Gui, Show,, %FirstLoadTitle%
Return

CloseFirstGui:
Gui, Submit
Gui, Destroy
JoystickType := JoystickTypeFirst
AllChat := AllChatFirst
TeamChat := TeamChatFirst
StandardChatUp := StandardChatUpFirst
StandardChatLeft := StandardChatLeftFirst
StandardChatRight := StandardChatRightFirst
StandardChatDown := StandardChatDownFirst
Return


OpenMainGui:
Gui, 1:New
GoSub ResetGuiFont ;Set Font Size

;Top Row

TempYPos := yTopRow + 6
Gui, Add, Picture, x20 y%TempYPos% AltSubmit gOpenRLButton vOpenRLButton HwndHwndTemp1,%AppFolder%\RLIcon.ico
OpenRLButton_TT := "Click To Launch Rocket League"
TempYPos := yTopRow - 4
Gui, Add, GroupBox, x17 y%TempYPos% w38 h45,
Gui, Add, Button, w100 x82 y%yTopRow% h44 vStartStopButton gStartStop, Restart Chat`nUpdate Settings

Gui, Add, Text, w75 x+10 y%yTopRow% Center HwndNoFocus1, Status
Gui, Add, Edit, wp xp+0 y+5 vStatus ReadOnly cred Center, Stopped

Gui, Add, Text, w80 x+30 y%yTopRow% Center, Current Menu
Gui, Add, Edit, wp vIndicatorMenu xp+0 y+5 Center ReadOnly, None
Gui, Add, Progress, wp h3 cBlue BackgroundGray xp+0 yp-4 +E0x00400000 vIndicatorMenuProg

Gui, Add, Text, w80 x+10 y%yTopRow% Center, Last Selection
Gui, Add, Edit, wp vIndicatorSelection xp+0 y+5 ReadOnly Center, None

Gui, Add, Text, w80 x+10 y%yTopRow% Center, Chat Mode
Gui, Add, Edit, wp xp+0 y+5 vIndicatorChatMode ReadOnly Center, Custom

Gui, Add, Button, x+8 y2 gOpenHelp vHelpButton, ?
TempYPos := TabYPos+5
Gui, Add, Text, w100 x465 y%TempYPos% Right, Version: %CurrentVersion%

;Tabs
Gui, Add, Tab2, w565 h430 x%TabXPos% y%TabYPos% gNoFocus, Chat|Setup

Gui, Tab, Chat
TempYPos := TabYPos+30
Gui, Add, Button, gSaveMessages x510 y%TempYPos% w60 r1, Save
Gui, Add, Button, gLoadMessages xp+0 y+5 w60 r1, Load
TempXPos := TabXPos + 154
TempYPos := TabYPos + 35
CreateSection("Up", TempXPos, TempYPos)
TempXPos := TabXPos + 10
TempYPos := TabYPos + 170
CreateSection("Left", TempXPos, TempYPos)
TempXPos := TabXPos + 285
TempYPos := TabYPos + 170
CreateSection("Right", TempXPos, TempYPos)
TempXPos := TabXPos + 154
TempYPos := TabYPos + 305
CreateSection("Down", TempXPos, TempYPos)

Gui, Tab, Setup
;GamePad Settings
TempYPos := TabYPos + TabSelectionAreaThickness + 20
TempXPos := TabxPos + 15
Gui, Add, Text, x%TempXPos% y%TempYPos% w90 r1 Right HwndHwndTemp1, Controller #:
Gui, Add, DropDownList, vSelectedJoystickNumber x+%SettingXSpacing% yp+0 w100 Choose%SelectedJoystickNumber% AltSubmit, Auto Find|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w90 r1 Right, Controller Type:
Gui, Add, DropDownList, vJoystickType x+%SettingXSpacing% yp+0 w100 Choose%JoystickType% AltSubmit, Xbox 360|Custom
Gui, Add, Button, gCustomCalibrate vCustomCalibrateButton x%TempXPos% y+%SettingYSpacing% w195 r1 center, Calibrate Custom Controller
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% vCustomJoystickSettingString w195 r3 center, %CustomJoystickType%`nUP:%CustomJoystickUpDownAxis%%CustomJoystickUp%     DN:%CustomJoystickUpDownAxis%%CustomJoystickDown%`nLT:%CustomJoystickLeftRightAxis%%CustomJoystickLeft%     RT:%CustomJoystickLeftRightAxis%%CustomJoystickRight%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w195 r1 center, Last Controller Connected:
Gui, Add, Edit, x%TempXPos% y+%SettingYSpacing% vLastController w195 r1 readonly center, None
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w140 r1 Right, Sampling Period:
Gui, Add, Edit, vJoystickSamplingPeriod x+%SettingXSpacing% yp+0 w20 r1 Number Limit2 HwndHwndTemp2, %JoystickSamplingPeriod%
Gui, Add, Text, x+%SettingXSpacing% yp+0 w25 r1 Left HwndHwndTemp3, ms
CreateGroupBox("Controller Settings", 5, HwndTemp1, HwndTemp2, HwndTemp1, HwndTemp3)

;Chat Settings
TempYPos := TabYPos + TabSelectionAreaThickness + 40
TempXPos := TabXPos + 235
Gui, Add, Text, x%TempXPos% y%TempYPos% w105 r1 Right HwndHwndTemp1, Controller Button:
Gui, Add, Button, vToggleChatButton gSetToggleChatButton x+%SettingXSpacing% yp+0 w30 r1, %ToggleChatButton%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w120 r1 Right, Mute Notification:
Gui, Add, Checkbox, vMuteChatToggle w15 yp+0 x+%SettingXSpacing% r1 Checked%MuteChatToggle% HwndHwndTemp2
HwndTemp3 := CreateGroupBox("Toggle Chat Mode", 5, HwndTemp1, HwndTemp2, HwndTemp1, HwndTemp2)
Gui, Add, Text, x%TempXPos% y+20 w95 r1 Right HwndHwndTemp1, Menu Timeout:
Gui, Add, Edit, vMenuTimeout x+%SettingXSpacing% yp+0 w40 r1 Number Limit4, %MenuTimeout%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w100 r1 Right, Chat Open Delay:
Gui, Add, Edit, vChatOpenDelay yp+0 x+%SettingXSpacing% w35 r1 Number Limit3 HwndHwndTemp2, %ChatOpenDelay%
HwndTemp4 := CreateGroupBox("Timing", 5, HwndTemp1, HwndTemp2, HwndTemp1, HwndTemp2)
Gui, Add, Text, x%TempXPos% y+6 w120 r1 Right, Spam Mode:
Gui, Add, Checkbox, vSpamModeEnable w15 yp+0 x+%SettingXSpacing% r1 Checked%SpamModeEnable% HwndHwndTemp5
CreateGroupBox("Chat Settings", 5, HwndTemp3, HwndTemp5, HwndTemp3, HwndTemp4)
Temp1:=TempXPos-10
Gui, Add, Text, x%Temp1% y+8 w140 r2 Right, Launch Rocket League with Rocket Chat
Gui, Add, Checkbox, vAutoLaunchRL w15 yp+0 x+%SettingXSpacing% r2 Checked%AutoLaunchRL%

;RL KeyBindings
TempYPos := TabYPos + TabSelectionAreaThickness + 40
TempXPos := TempXPos + 170
Gui, Add, Text, x%TempXPos% y%TempYPos% w120 r1 Right HwndHwndTemp1, All Chat:
Gui, Add, Edit, vAllChat Limit1 x+%SettingXSpacing% yp+0 w15 r1, %AllChat%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w120 r1 Right, Team Chat:
Gui, Add, Edit, vTeamChat Limit1 x+%SettingXSpacing% yp+0 w15 r1 HwndHwndTemp5, %TeamChat%
HwndTemp4:=CreateGroupBox("Open Chat", 5, HwndTemp1, HwndTemp5, HwndTemp1, HwndTemp5)
TempXpos := TempXPos
Gui, Add, Text, x%TempXPos% y+20 w120 r1 Right HwndHwndTemp2, Information (Up):
Gui, Add, Edit, vStandardChatUp Limit1 x+%SettingXSpacing% yp+0 w15 r1, %StandardChatUp%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w120 r1 Right, Compliments (Left):
Gui, Add, Edit, vStandardChatLeft Limit1 x+%SettingXSpacing% yp+0 w15 r1, %StandardChatLeft%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w120 r1 Right,Reactions (Right):
Gui, Add, Edit, vStandardChatRight Limit1 x+%SettingXSpacing% yp+0 w15 r1, %StandardChatRight%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w120 r1 Right,Apologies (Down):
Gui, Add, Edit, vStandardChatDown Limit1 x+%SettingXSpacing% yp+0 w15 r1 HwndHwndTemp3, %StandardChatDown%
CreateGroupBox("Quick Chat", 5, HwndTemp2, HwndTemp3, HwndTemp2, HwndTemp3)
CreateGroupBox("RL Keyboard Bindings", 5, HwndTemp4, HwndGroupBox, HwndTemp4, HwndGroupBox)

;Overlay Settings
TempYPos := TabYPos + 305
TempXPos:= TabXPos + 20
;Position
Gui, Add, Text, x%TempXPos% y%TempYPos% w25 r1 Right HwndHwndTemp3, X:
Gui, Add, Edit, vOverlayX Limit4 number x+%SettingXSpacing% yp+0 w35 r1, %OverlayX%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w25 r1 Right, Y:
Gui, Add, Edit, vOverlayY Limit4 number x+%SettingXSpacing% yp+0 w35 r1, %OverlayY%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w25 r1 Right, Size:
Gui, Add, Edit, vFontSize x+%SettingXSpacing% yp+0 w35 Number Limit2 HwndHwndTemp4, %FontSize%
HwndTemp1:=CreateGroupBox("Position", 5, HwndTemp3, HwndTemp4, HwndTemp3, HwndTemp4)

Gui, Add, Button, gSaveOverlay xp+0 y+5 w35 r1, Save
Gui, Add, Button, gLoadOverlay x+5 yp+0 w35 r1, Load

TempXPos:= TempXPos + 80
Gui, Add, Text, x%TempXPos% y%TempYPos% w35 r1 Right HwndHwndTemp3, Color:
Gui, Add, Edit, vBgColor Limit6 x+%SettingXSpacing% yp+0 w60 r1, %BgColor%
BgColor_DblClk = ColorSelect
BgColor_TT = Double click to open color picker
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w60 r1 Right, Opacity %PSign%:
Gui, Add, Edit, vBgOpac w35 yp+0 x+%SettingXSpacing% r1 Number limit3, %BgOpac%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w60 r1 Right, Width:
Gui, Add, Edit, vBgWidth w35 yp+0 x+%SettingXSpacing% r1 Number limit3, %BgWidth%
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w80 r1 Right, Menu Timer:
Gui, Add, Checkbox, vMenuTimerON w15 yp+0 x+%SettingXSpacing% r1 Checked%MenuTimerON% HwndHwndTemp4
CreateGroupBox("Background", 5, HwndTemp3, HwndTemp4, HwndTemp3, HwndTemp4)

TempXPos := TempXPos + 115

Gui, Add, Text, x%TempXPos% y%TempYPos% w35 r1 Right HwndHwndTemp3,Color:
Gui, Add, Edit, vMsgColor Limit6 x+%SettingXSpacing% yp+0 w60 r1, %MsgColor%
MsgColor_DblClk = ColorSelect
MsgColor_TT = Double click to open color picker
Gui, Add, Button, x%TempXPos% y+%SettingYSpacing% w100 r1 vMsgFontPick gSelectMsgFont Center, Font Picker
Gui, Add, Edit, x%TempXPos% y+%SettingYSpacing% w100 r1 ReadOnly Center vMsgFontDisplay, %MsgFont%
UpdateFontDisplay("Msg")
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w75 r1 Right, Char Limit:
Gui, Add, Edit, vOverlayCharLim Limit4 number x+%SettingXSpacing% yp+0 w20 r1 HwndHwndTemp4, %OverlayCharLim%
HwndTemp6:=CreateGroupBox("Messages", 5, HwndTemp3, HwndTemp4, HwndTemp3, HwndTemp4)

TempXPos := TempXPos + 115

Gui, Add, Text, x%TempXPos% y%TempYPos% w35 r1 Right HwndHwndTemp3,Color:
Gui, Add, Edit, vTeamColor Limit6 x+%SettingXSpacing% yp+0 w60 r1, %TeamColor%
TeamColor_DblClk = ColorSelect
TeamColor_TT = Double click to open color picker
Gui, Add, Button, x%TempXPos% y+%SettingYSpacing% w100 r1 vTeamFontPick gSelectTeamFont Center, Font Picker
Gui, Add, Edit, x%TempXPos% y+%SettingYSpacing% w100 r1 ReadOnly Center vTeamFontDisplay, %TeamFont%
UpdateFontDisplay("Team")
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w75 r1 Right, Vert Offset:
Gui, Add, Edit, vTeamFlatOffset Limit1 number x+%SettingXSpacing% yp+0 w20 r1 HwndHwndTemp4, %TeamFlatOffset%
CreateGroupBox("Team Indicator", 5, HwndTemp3, HwndTemp4, HwndTemp3, HwndTemp4)


TempXPos := TempXPos + 115

Gui, Add, Text, x%TempXPos% y%TempYPos% w35 r1 Right HwndHwndTemp3,Color:
Gui, Add, Edit, vLblColor Limit6 x+%SettingXSpacing% yp+0 w60 r1, %LblColor%
LblColor_DblClk = ColorSelect
LblColor_TT = Double click to open color picker
Gui, Add, Button, x%TempXPos% y+%SettingYSpacing% w100 r1 vLblFontPick gSelectLblFont Center, Font Picker
Gui, Add, Edit, x%TempXPos% y+%SettingYSpacing% w100 r1 ReadOnly Center vLblFontDisplay, %LblFont%
UpdateFontDisplay("Lbl")
Gui, Add, Text, x%TempXPos% y+%SettingYSpacing% w56 vArrowsText r1 Right, Arrows?:
gui, font, s11, Wingdings 3
Gui, Add, DropDownList, vLblArrow x+%SettingXSpacing% yp+0 w39 Choose%LblArrow% AltSubmit HwndHwndTemp4, %A_Space%|#|h|5|<|J|p|r
hexhwnd:=hex(HwndTemp4)
hexhwnd=0x%hexhwnd%
If GetFontname(hexhwnd) != "Wingdings 3"
{
	LblArrow = 1
	GuiControl, Text, %HwndTemp4%,|
	GuiControl, Disable , %HwndTemp4%
}
GoSub ResetGuiFont
LblArrow_TT:="Requires the Wingdings 3 font`nLeave blank to use letters"
ArrowsText_TT:="Requires the Wingdings 3 font`nLeave blank to use letters"
HwndTemp2:=CreateGroupBox("", 5, HwndTemp3, HwndTemp4, HwndTemp3, HwndTemp4)
Gui, Add, Checkbox, vLabelsON yp+0 xp+5 r1 Checked%LabelsON%, Labels

CreateGroupBox("", 5, HwndTemp1, HwndTemp2, HwndTemp1, HwndTemp2)
Gui, Add, Checkbox, vOverlayON yp+0 xp+5 r1 Checked%OverlayON%, Overlay On
;Gui, Color,1D4D71,123249
Gui, Show, w588, %ProgramName%

Return

GetFontname( HwndInput ) {
 hFont := DllCall( "SendMessage", UInt, HwndInput, UInt,0x31, UInt,0, UInt,0, UInt )s
 VarSetCapacity( LF, szLF := 60*( A_IsUnicode ? 2:1 ) )
 DllCall( "GetObject", UInt,hFont, Int,szLF, UInt,&LF )
 hDC := DllCall( "GetDC", UInt,hwnd ), 
 DllCall( "ReleaseDC", Int,0, UInt,hDC ), 
Return DllCall( "MulDiv",Int,&LF+28, Int,1,Int,1, Str )
}
 

SelectMsgFont:
FontSelector(MsgFont, MsgModifier)
UpdateFontDisplay("Msg")
Return

SelectTeamFont:
FontSelector(TeamFont, TeamModifier)
UpdateFontDisplay("Team")
Return

SelectLblFont:
FontSelector(LblFont, LblModifier)
UpdateFontDisplay("Lbl")
Return

UpdateFontDisplay(name){
global
If %name%Modifier = 2
	TempStyle = bold
Else If %name%Modifier = 3
	TempStyle = italic
Else
	TempStyle = norm
TempFont := %name%Font
TempDisplayName = %name%FontDisplay
Gui, 1:Font, s%StandardGuiFontSize% norm %TempStyle%, %TempFont%
GuiControl, 1:text, %TempDisplayName%, %TempFont%
GuiControl, 1:Font, %TempDisplayName%,
GoSub ResetGuiFont
Return
}
OpenHelp:
Run %AppFolder%\Help.chm
Return

StartStop:
If (Running = 1)
{
Stop()
Sleep, 200
}
Start()
Return

InputCheck:
WinGet, CurrentProcess, ProcessName, A
PrevDir := CurrDir
GetDir()
Process, Exist, %RLProcess%
RLPID := ErrorLevel 
GoSub InGameCheck
If (OverlayON = 1)
{
	If (RLPID != 0)
	{
		If (OverlayInitialized = 0)
		{
		OverlayInit()
		}
	}
	Else If (OverlayInitialized = 1)
	{
	DestroyAllVisual()
	OverlayInitialized = 0
	}
}
If OverlayInitialized = 1
{
	If OverlayChatModeVisible = 1
	{

	Temp1 := A_TickCount - ChatModeChangeTime
		If Temp1 > 1000
		{
		TextSetShown(OverlayChatModeID, False)
		OverlayChatModeVisible = 0
		}

	}
}
If CurrMenu <> None
{
	MenuTimeCheck()
}
If PrevDir = None
{
	If CurrDir <> None
	{
		If ChatMode = 0
		{
		If InGame and (CurrentProcess = RLProcess)
			StandardChat()
		}
		Else
		{
			If CurrMenu = None
			{
			SetMenu()
			}
			Else
			{
				If InGame and (CurrentProcess = RLProcess)
					SendChat()
			guiControl, , IndicatorSelection, %CurrMenu%-%CurrDir%
			ResetMenu()
			}
		}
	}
}
Return


ToggleChatMode:
;If InGame
	SetChatMode(-1)
Return

SaveMessages:
Gui, Submit, NoHide
SaveSettings("Messages")
Return

SaveOverlay:
Gui, Submit, NoHide
SaveSettings("Overlay")
Return

LoadMessages:
LoadSettings("Messages")
Return

LoadOverlay:
LoadSettings("Overlay")
Return

SetToggleChatButton:
ConnectJoystick()
	If JoyName
	{
	Gui, 1: +Disabled
	Gui, InputButton:New
	Gui, InputButton:Font, cblack s%StandardGuiFontSize% norm, %StandardGuiFont%
	Gui, InputButton:-SysMenu
	Gui, InputButton:Add, Text, x15 y5 w130 center, Press controller button
	Gui, InputButton:Show,, Waiting
	ToggleChatButton:=GetJoyButton(2000,1)
	Gui, 1:Show
	Gui, InputButton:Destroy
	Gui, 1: -Disabled
	guiControl, 1:Text, ToggleChatButton, %ToggleChatButton%
	}
Return

ColorSelect:
GuiControlGet,StartColor,,%DblClkhwnd%
PickedColor = 0x%StartColor%
CmnDlg_Color( PickedColor)
If (PickedColor = StartColor)
	Return
StringTrimleft, PickedColor, PickedColor, 2
StringUpper, PickedColor, PickedColor
GuiControl,, %DblClkhwnd%, %PickedColor%
Return

CustomCalibrate:
ConnectJoystick()
If JoyName
	CalibrateJoystick()
Return

NoFocus:
GuiControl, Focus, OverlayON
Return

ResetGuiFont:
Gui, 1:Font, cblack s%StandardGuiFontSize% norm, %StandardGuiFont%
Return
;--------------------------FUNCTIONS-------------------------

Start()
{
global
Gui, Submit, NoHide
OverlayInitialized = 0
LimitCheck()
If OutOfLims= 
{
ConnectJoystick()
JoystickCalc()

	If JoyName
	{
	
	guiControl, text, Status, Running
	Gui, Font, cGreen, bold
	guiControl, Font, Status
	GoSub ResetGuiFont
	Running = 1
	InGame := False
	SaveIni("All",IniPath)
	
	If ToggleChatButton <>
	Hotkey, %JoystickNumber%joy%ToggleChatButton%, ToggleChatMode, On

	SetTimer, InputCheck, %JoystickSamplingPeriod%
	SetChatMode(1)
	}
}
}

Stop()
{
global
GuiControl, text, Status, Stopped
Gui, Font, cred
guiControl, Font, Status
Running = 0
SetTimer, InputCheck, Off
	If ToggleChatButton <>
	Hotkey, %JoystickNumber%joy%ToggleChatButton%, ToggleChatMode, Off
If OverlayInitialized = 1
{
DestroyAllVisual() ;Can use DestoryOverlay which I made and should delete everything, but this is simpler. I only used DestroyOverlay because I thought DestroyAllVisual was causing problems, but now I think its fine.
}
OverlayChatModeVisible = 0
}

ConnectJoystick()
{
global
JoystickNumber := SelectedJoystickNumber - 1
; Auto-detect the joystick number if called for:
if JoystickNumber <= 0
{
    Loop 16  ; Query each joystick number to find out which ones exist.
    {
	GetKeyState, JoystickPresenceCheck, %A_Index%Joy1
	if JoystickPresenceCheck <>
        {
            JoystickNumber=%A_Index%
            break
        }
    }
}
GetKeyState, JoyName, %JoystickNumber%JoyName
	If JoyName <>
	{
	SetFormat, float, 03  ; Omit decimal point from axis position percentages.
	GetKeyState, joy_buttons, %JoystickNumber%JoyButtons
	GetKeyState, joy_name, %JoystickNumber%JoyName
	GetKeyState, joy_info, %JoystickNumber%JoyInfo
	GuiControl,, LastController, %joy_name% (#%JoystickNumber%)
	}
	Else
	{
		If JoystickNumber = 0
		MsgBox,8192, Sorry!,Could not find any controllers
		Else
		MsgBox,8192, Sorry!,Could not find gamepad %JoystickNumber%`nChange ontroller # to 0 in settings to use Auto Find
	}

}

CreateGroupBox(Title, Margin, TopElement, BotElement, LeftElement, RightElement) ;Title must be in quotes
{
global

Local BoxX
Local BoxY
Local Boxh
Local BoxW

GuiControlGet, TopPos, Pos, %TopElement%
GuiControlGet, BotPos, Pos, %BotElement%
GuiControlGet, LeftPos, Pos, %LeftElement%
GuiControlGet, RightPos, Pos, %RightElement%

BoxX := LeftPosX - Margin
BoxY := TopPosY - Margin - BoxLabelHeight
BoxH := BotPosY - TopPosY + BotPosH + BoxLabelHeight + Margin + Margin
BoxW := RightPosX - LeftPosX + RightPosW + Margin + Margin

Gui, Add, GroupBox, x%BoxX% y%BoxY% h%BoxH% w%BoxW% HwndHwndGroupBox, %Title%

Return HwndGroupBox
}

GetDir()
{
global
If QuickChatType = Button
{
CurrDir = None
GetKeyState, Temp1, %JoystickNumber%joy%QuickChatUp%
	if Temp1 = D
	CurrDir = Up
GetKeyState, Temp1, %JoystickNumber%joy%QuickChatLeft%
	if Temp1 = D
	CurrDir = Left
GetKeyState, Temp1, %JoystickNumber%joy%QuickChatRight%
	if Temp1 = D
	CurrDir = Right
GetKeyState, Temp1, %JoystickNumber%joy%QuickChatDown%
	if Temp1 = D
	CurrDir = Down
}
Else If QuickChatType = Axis
{
CurrDir=None
GetKeyState, JoystickValue, %JoystickNumber%Joy%QuickChatUpDownAxis%
	If (JoystickValue > QuickChatUpDownHighActiveThresh)
	{
		CurrDir := QuickChatUpDownHighDir
	}
	Else If (JoystickValue < QuickChatUpDownLowActiveThresh)
	{
		CurrDir := QuickChatUpDownLowDir
	}
GetKeyState, JoystickValue, %JoystickNumber%Joy%QuickChatLeftRightAxis%
	If (JoystickValue > QuickChatLeftRightHighActiveThresh)
	{
		CurrDir := QuickChatLeftRightHighDir
	}
	Else If (JoystickValue < QuickChatLeftRightLowActiveThresh)
	{
		CurrDir := QuickChatLeftRightLowDir
	}
}
Else If QuickChatType = POV
{
GetKeyState, POV, %JoystickNumber%JoyPOV
if POV < 0   ; No angle to report
    CurrDir = None
else if POV > %QuickChatPOV7Eighth%    ; 315 to 360 degrees: Forward
    CurrDir := QuickChatPOVDirFirst
else if POV between 0 and %QuickChatPOV1Eighth%      ; 0 to 45 degrees: Forward
    CurrDir := QuickChatPOVDirFirst
else if POV between %QuickChatPOV1Eighth% and %QuickChatPOV3Eighth%  ; 45 to 135 degrees: Right
    CurrDir := QuickChatPOVDirSecond
else if POV between %QuickChatPOV3Eighth% and %QuickChatPOV5Eighth% ; 135 to 225 degrees: Down
    CurrDir := QuickChatPOVDirThird
else                                ; 225 to 315 degrees: Left
    CurrDir := QuickChatPOVDirFourth
}

}

GetNeutral()
{
global
local joyx, joyy, joyz, joyr, joyu, joyv, joyp
	GetKeyState, joyx, %JoystickNumber%JoyX
	NeutralX := joyx
	GetKeyState, joyy, %JoystickNumber%JoyY
	NeutralY := joyy
	IfInString, joy_info, Z
	{
		GetKeyState, joyz, %JoystickNumber%JoyZ
		NeutralZ := joyz
	}
	IfInString, joy_info, R
	{
		GetKeyState, joyr, %JoystickNumber%JoyR
		NeutralR := joyr
	}
	IfInString, joy_info, U
	{
		GetKeyState, joyu, %JoystickNumber%JoyU
		NeutralU := joyu
	}
	IfInString, joy_info, V
	{
		GetKeyState, joyv, %JoystickNumber%JoyV
		NeutralV := joyv
	}
	IfInString, joy_info, P
	{
		GetKeyState, joyp, %JoystickNumber%JoyPOV
		NeutralP := joyp
	}
}

CalibrateDir(ByRef CalibrateType, ByRef AxisNumber = 0)
{
global
local joyx, joyy, joyz, joyr, joyu, joyv, joyp, Value, TempType

TempType = Error ; If no type is set, this variable will remain "Error"

If (CalibrateType = "Detect") Or (CalibrateType = "Axis")
{
	GetKeyState, joyx, %JoystickNumber%JoyX
	OldDiff := abs(joyx - NeutralX)
	AxisNumber = X
	Value := joyx
	GetKeyState, joyy, %JoystickNumber%JoyY
	NewDiff := abs(joyy - NeutralY)
		If (NewDiff > OldDiff)
		{
		OldDiff := NewDiff
		AxisNumber = Y
		Value := joyy
		}
	IfInString, joy_info, Z
	{
		GetKeyState, joyz, %JoystickNumber%JoyZ
		NewDiff := abs(joyz - NeutralZ)
			If (NewDiff > OldDiff)
			{
			OldDiff := NewDiff
			AxisNumber = Z
			Value := joyz
			}
	}
	IfInString, joy_info, R
	{
		GetKeyState, joyr, %JoystickNumber%JoyR
		NewDiff := abs(joyr - NeutralR)
			If (NewDiff > OldDiff)
			{
			OldDiff := NewDiff
			AxisNumber = R
			Value := joyr
			}
	}
	IfInString, joy_info, U
	{
		GetKeyState, joyu, %JoystickNumber%JoyU
		NewDiff := abs(joyu - NeutralU)
			If (NewDiff > OldDiff)
			{
			OldDiff := NewDiff
			AxisNumber = U
			Value := joyu
			}
	}
	IfInString, joy_info, V
	{
		GetKeyState, joyv, %JoystickNumber%JoyV
		NewDiff := abs(joyv - NeutralV)
			If (NewDiff > OldDiff)
			{
			OldDiff := NewDiff
			AxisNumber = V
			Value := joyv
			}
	}
	If OldDiff > 5
		TempType = Axis
}
If (CalibrateType = "Detect") Or (CalibrateType = "POV")
{
;Check if POV is used
	IfInString, joy_info, P
	{
		GetKeyState, joyp, %JoystickNumber%JoyPOV
			If (joyp <> NeutralP)
			{
			AxisNumber = P
			Value := joyp
			TempType = POV
			}
	}
}
If (CalibrateType = "Detect") Or (CalibrateType = "Button")
{
;Check if Buttons pressed
Loop, %joy_buttons%
	{
		GetKeyState, joy%a_index%, %JoystickNumber%joy%a_index%
		if joy%a_index% = D
			{
			AxisNumber = B
			TempType = Button
			Value = %a_index%
			}
	}
}
CalibrateType := TempType
Return Value
}

CalibrateJoystick()
{
global
local TempSettingUp, TempSettingLeft, TempSettingRight, TempSettingDown, TempCalibrationType, TempAxisNumber, TempAxisUpDown, TempAxisLeftRight
MsgBox,8192, Calibration, Make sure no buttons are pressed and joysticks are in neutral position then press "OK"
GetNeutral()
MsgBox,8192, Calibration, Using the buttons or joystick that will be assigned to quick chat, hold UP (with all other buttons/joysticks in their neutral position) then press "OK"
TempCalibrationType = Detect
TempSettingUp := CalibrateDir(TempCalibrationType, TempAxisNumber)
	If (TempCalibrationType = "Error")
	{
	MsgBox,8192, Calibration Failed, No input detected`nPlease try again
	Return
	}
TempAxisUpDown := TempAxisNumber
MsgBox,8192, Calibration, Calibration type "%TempCalibrationType%" detected`nHold DOWN then press OK
TempSettingDown := CalibrateDir(TempCalibrationType, TempAxisNumber)
	If (TempCalibrationType = "Error")
	{
	MsgBox,8192, Calibration Failed, No input detected`nPlease try again
	Return
	}
	If (TempAxisNumber <> TempAxisUpDown)
	{
	MsgBox,8192, Calibration Failed, Inconsistent axis detected`nPlease try again
	Return
	}
MsgBox,8192, Calibration, Hold LEFT then press OK
TempSettingLeft := CalibrateDir(TempCalibrationType, TempAxisNumber)
	If (TempCalibrationType = "Error")
	{
	MsgBox,8192, Calibration Failed, No input detected`nPlease try again
	Return
	}
TempAxisLeftRight := TempAxisNumber
	
	If (TempCalibrationType = "Axis") and (TempAxisLeftRight = TempAxisUpDown)
	{
	MsgBox,8192, Calibration Failed, Left and Right cannot be mapped to the same axis as Up and Down`nPlease Try Agin
	Return
	}
MsgBox,8192, Calibration, Hold RIGHT then press OK
TempSettingRight := CalibrateDir(TempCalibrationType, TempAxisNumber)	
	If (TempCalibrationType = "Error")
	{
	MsgBox,8192, Calibration Failed, No input detected`nPlease try again
	Return
	}
	If (TempAxisNumber <> TempAxisLeftRight)
	{
	MsgBox,8192, Calibration Failed, Inconsistent axis detected`nPlease try again
	Return
	}
If TempCalibrationType <> Axis
{
	If (TempSettingUP = TempSettingDown) or (TempSettingUP = TempSettingLeft) or (TempSettingUP = TempSettingRight) or (TempSettingLeft = TempSettingDown) or (TempSettingLeft = TempSettingRight) or (TempSettingRight = TempSettingDown)
	{
	MsgBox,8192, Calibration Failed, At least two directions are mapped to the same input`nUP:%TempSettingUp% DN:%TempSettingUp% LT:%TempSettingLeft% RT:%TempSettingRight%`nPlease try again
	Return
	}
}
CustomJoystickType := TempCalibrationType
CustomJoystickUp := TempSettingUP
CustomJoystickDown := TempSettingDown
CustomJoystickLeft := TempSettingLeft
CustomJoystickRight := TempSettingRight
CustomJoystickUpDownAxis := TempAxisUpDown
CustomJoystickLeftRightAxis :=TempAxisLeftRight
CustomJoystickSettingString = %CustomJoystickType%`nUP:%CustomJoystickUpDownAxis%%CustomJoystickUp%     DN:%CustomJoystickUpDownAxis%%CustomJoystickDown%`nLT:%CustomJoystickLeftRightAxis%%CustomJoystickLeft%     RT:%CustomJoystickLeftRightAxis%%CustomJoystickRight%
MsgBox,8192,Calibration Successful, Calibration Successful!`nSettings: %CustomJoystickSettingString%
GuiControl,, CustomJoystickSettingString, %CustomJoystickSettingString%
}

JoystickCalc()
{
global
If JoystickType = 1
{
QuickChatType = POV
QuickChatUp = 0
QuickChatRight = 9000
QuickChatDown = 18000
QuickChatLeft = 27000
QuickChatUpDownAxis = P
QuickChatLeftRightAxis = P
}
Else
{
QuickChatType := CustomJoystickType
QuickChatUp := CustomJoystickUp
QuickChatRight := CustomJoystickRight
QuickChatDown := CustomJoystickDown
QuickChatLeft := CustomJoystickLeft
QuickChatUpDownAxis := CustomJoystickUpDownAxis
QuickChatLeftRightAxis := CustomJoystickLeftRightAxis
}
If QuickChatType = Axis
{
	If (QuickChatUp > QuickChatDown)
	{
	QuickChatUpDownHighValue := QuickChatUp
	QuickChatUpDownLowValue := QuickChatDown
	QuickChatUpDownHighDir = Up
	QuickChatUpDownLowDir = Down
	}
	Else
	{
	QuickChatUpDownHighValue := QuickChatDown
	QuickChatUpDownLowValue := QuickChatUp
	QuickChatUpDownHighDir = Down
	QuickChatUpDownLowDir = Up
	}
QuickChatUpDownMid := (QuickChatUpDownHighValue+QuickChatUpDownLowValue)/2
QuickChatUpDownDiff := (QuickChatUpDownHighValue-QuickChatUpDownLowValue)/2
QuickChatUpDownHighActiveThresh := QuickChatUpDownHighValue-(QuickChatUpDownDiff*AxisActiveRatio)
QuickChatUpDownLowActiveThresh := QuickChatUpDownLowValue+(QuickChatUpDownDiff*AxisActiveRatio)


	If (QuickChatLeft > QuickChatRight)
	{
	QuickChatLeftRightHighValue := QuickChatLeft
	QuickChatLeftRightLowValue := QuickChatRight
	QuickChatLeftRightHighDir = Left
	QuickChatLeftRightLowDir = Right
	}
	Else
	{
	QuickChatLeftRightHighValue := QuickChatRight
	QuickChatLeftRightLowValue := QuickChatLeft
	QuickChatLeftRightHighDir = Right
	QuickChatLeftRightLowDir = Left
	}
QuickChatLeftRightMid := (QuickChatLeftRightHighValue+QuickChatLeftRightLowValue)/2
QuickChatLeftRightDiff := (QuickChatLeftRightHighValue-QuickChatLeftRightLowValue)/2
QuickChatLeftRightHighActiveThresh := QuickChatLeftRightHighValue-(QuickChatLeftRightDiff*AxisActiveRatio)
QuickChatLeftRightLowActiveThresh := QuickChatLeftRightLowValue+(QuickChatLeftRightDiff*AxisActiveRatio)
}
If QuickChatType = POV
{
index := 0
If QuickChatUp between %QuickChatLeft% and %QuickChatRight%
{
index := index + 1
TempDir%index% = 0
TempVal%index% := QuickChatUp
}
If QuickChatRight between %QuickChatUp% and %QuickChatDown%
{
index := index + 1
TempDir%index% = 1
TempVal%index% := QuickChatRight
}
If QuickChatDown between %QuickChatRight% and %QuickChatLeft%
{
index := index + 1
TempDir%index% = 2
TempVal%index% := QuickChatDown
}
If QuickChatLeft between %QuickChatDown% and %QuickChatUp%
{
index := index + 1
TempDir%index% = 3
TempVal%index% := QuickChatLeft
}
QuickChatPOVClockwise = 1
If (index <> 2) ;Direction is not clockwise
{
index := 0
QuickChatPOVClockwise = -1
If QuickChatUp between %QuickChatRight% and %QuickChatLeft%
{
index := index + 1
TempDir%index% = 0
TempVal%index% := QuickChatUp
}
If QuickChatLeft between %QuickChatUp% and %QuickChatDown%
{
index := index + 1
TempDir%index% = 3
TempVal%index% := QuickChatLeft
}
If QuickChatDown between %QuickChatLeft% and %QuickChatRight%
{
index := index + 1
TempDir%index% = 2
TempVal%index% := QuickChatDown
}
If QuickChatRight between %QuickChatDown% and %QuickChatUp%
{
index := index + 1
TempDir%index% = 1
TempVal%index% := QuickChatRight
}
If (index <> 2)
	MsgBox,8192,Sorry!, POV Calculation error`nCould not detect rotational direction`nPlease recalibrate controller
}
If TempVal1>TempVal2
{
TempHighVal:=TempVal1
TempHighDir:=TempDir1
TempLowVal:=TempVal2
TempLowDir:=TempDir2
}
Else
{
TempLowVal:=TempVal1
TempLowDir:=TempDir1
TempHighVal:=TempVal2
TempHighDir:=TempDir2
}

TempDiff:=abs(TempHighVal-(TempLowVal*2))
TempTolerance:=TempLowVal/8

If (TempDiff > TempTolerance)
{
POVMidVal := TempLowVal
POVMidDir := TempLowDir 
}
Else
{
POVMidVal := TempHighVal
POVMidDir := TempHighDir 
}
POVMaxVal := 2*POVMidVal
Loop, 8
{
QuickChatPOV%a_index%Eighth:=POVMaxVal*(a_index/8)
}
; 0 = up and continue in rotational direction with 3 being largest, if clockwise 
QuickChatPOVDirFirst:=Mod(2+POVMidDir,4)
QuickChatPOVDirSecond:=abs(Mod(QuickChatPOVClockwise+QuickChatPOVDirFirst,4))
QuickChatPOVDirThird:=abs(Mod(QuickChatPOVClockwise+QuickChatPOVDirSecond,4))
QuickChatPOVDirFourth:=abs(Mod(QuickChatPOVClockwise+QuickChatPOVDirThird,4))
QuickChatPOVDirFirst:=NumToDir(QuickChatPOVDirFirst)
QuickChatPOVDirSecond:=NumToDir(QuickChatPOVDirSecond)
QuickChatPOVDirThird:=NumToDir(QuickChatPOVDirThird)
QuickChatPOVDirFourth:=NumToDir(QuickChatPOVDirFourth)
}
}


NumToDir(Input)
{
If Input = 0
	Return "Up"
Else If Input = 1
	Return "Right"
Else If Input = 2
	Return "Down"
Else
	Return "Left"
}

MenuTimeCheck()
{
global

MenuTimeElapsed := A_TickCount - MenuOpenTime

	If (MenuTimeElapsed >= MenuTimeout)
	{
	ResetMenu()
	}
	Else
	{
	UpdateMenuBar()
	}
}

UpdateMenuBar()
{
global
	If CurrMenu <> None
	{
	MenuTimeLeft := MenuTimeout - MenuTimeElapsed
	MenuPercentLeft := 100*MenuTimeleft/MenuTimeout
	GuiControl,, IndicatorMenuProg, %MenuPercentLeft%
	Temp1:= A_TickCount - OverlayMenuLastUpdateTime
If (OverlayInitialized) = 1 and (OverlayON = 1)
{
		If (MenuTimerON = 1) and (Temp1 > OverlayMenuUpdatePeriod)
		{
		Temp1:=Floor(OverlayBgW*(MenuPercentLeft/100))
		Temp2:=(OverlayX+(OverlayBgW - Temp1))
		BoxSetPos(OverlayTimerID, Temp2, OverlayTimerY)
		BoxSetWidth(OverlayTimerID, Temp1)
		OverlayMenuLastUpdateTime := A_TickCount
		}
}

	}
	Else
	{
	GuiControl,, IndicatorMenuProg, 0
	}
}

ResetMenu()
{
global
CurrMenu = None
GuiControl, Text, IndicatorMenu, %CurrMenu%
UpdateMenuBar()
If OverlayInitialized = 1
{
	If OverlayON
	{
	OverlayDispOff()
	}
}
}

SetMenu()
{
global
CurrMenu := CurrDir
GuiControl, , IndicatorMenu, %CurrMenu%
MenuOpenTime = %A_TickCount%
If OverlayInitialized = 1
{
	If OverlayON and InGame
	{
	OverlayDispMenu()
	}
}
}

SendChat()
{
global
TeamCheck := Team%CurrMenu%%CurrDir%
Loop 3{
	If TeamCheck = 1
	{
	SendInput %TeamChat%
	}
	Else
	{
	SendInput %AllChat%
	}
Sleep %ChatOpenDelay%
Output := %CurrMenu%%CurrDir%
SendInput {Raw}%Output%
SendInput {Enter}
If ChatMode <> 2
	break
Sleep %ChatOpenDelay%
}
}

FormatOverlayMsg(Input)
{
global OverlayCharLim

Length:=StrLen(Input)

If (Length > OverlayCharLim)
{
Extra := Length - OverlayCharLim + 1
StringTrimRight, Input, Input, Extra
Input =%Input%...
}
Return Input
}


OverlayInit()
{
global

OverlayMsgUpUp := FormatOverlayMsg(UpUp)
OverlayMsgUpLeft := FormatOverlayMsg(UpLeft)
OverlayMsgUpRight := FormatOverlayMsg(UpRight)
OverlayMsgUpDown := FormatOverlayMsg(UpDown)

OverlayMsgLeftUp := FormatOverlayMsg(LeftUp)
OverlayMsgLeftLeft := FormatOverlayMsg(LeftLeft)
OverlayMsgLeftRight := FormatOverlayMsg(LeftRight)
OverlayMsgLeftDown := FormatOverlayMsg(LeftDown)

OverlayMsgRightUp := FormatOverlayMsg(RightUp)
OverlayMsgRightLeft := FormatOverlayMsg(RightLeft)
OverlayMsgRightRight := FormatOverlayMsg(RightRight)
OverlayMsgRightDown := FormatOverlayMsg(RightDown)

OverlayMsgDownUp := FormatOverlayMsg(DownUp)
OverlayMsgDownLeft := FormatOverlayMsg(DownLeft)
OverlayMsgDownRight := FormatOverlayMsg(DownRight)
OverlayMsgDownDown := FormatOverlayMsg(DownDown)

If LblArrow = 1
{
LblUpText = UP
LblLeftText = LT
LblRightText = RT
LblDownText= DN
TempLblFont:= LblFont
}
Else If LblArrow = 2
{
LblUpText = #
LblLeftText =!
LblRightText ="
LblDownText=$
TempLblFont:= "Wingdings 3"
}
Else If LblArrow = 3
{
LblUpText = h
LblLeftText =f
LblRightText =g
LblDownText=i
TempLblFont:= "Wingdings 3"
}
Else If LblArrow = 4
{
LblUpText = 5
LblLeftText =3
LblRightText =4
LblDownText=6
TempLblFont:= "Wingdings 3"
}
Else If LblArrow = 5
{
LblUpText = <
LblLeftText =:
LblRightText =9
LblDownText=>
TempLblFont:= "Wingdings 3"
}
Else If LblArrow = 6
{
LblUpText = J
LblLeftText =H
LblRightText =I
LblDownText=K
TempLblFont:= "Wingdings 3"
}
Else If LblArrow = 7
{
LblUpText = p
LblLeftText =t
LblRightText =u
LblDownText=q
TempLblFont:= "Wingdings 3"
}
Else If LblArrow = 8
{
LblUpText = r
LblLeftText =v
LblRightText =w
LblDownText=s
TempLblFont:= "Wingdings 3"
}


MsgBold := False
MsgItalic := False
If MsgModifier = 2
	MsgBold := True
Else If MsgModifier = 3
	MsgItalic := True

TeamBold := False
TeamItalic := False
If TeamModifier = 2
	TeamBold := True
Else If TeamModifier = 3
	TeamItalic := True

LblBold := False
LblItalic := False
If LblModifier = 2
	LblBold := True
Else If LblModifier = 3
	LblItalic := True

Temp1:=Hex(OverlayTextOpac)
LblColorValue = 0x%Temp1%%LblColor%
MsgColorValue = 0x%Temp1%%MsgColor%
TeamColorValue = 0x%Temp1%%TeamColor%
Temp2:=BgOpac*255/100
Temp1:=Hex(Temp2)
BgColorValue = 0x%Temp1%%BgColor%

LblStartX:=OverlayX+OverlayBgMargin
MsgStartX:=LblStartX

LblFontSize := FontSize
MsgFontSize := FontSize
TeamFontSize := FontSize/2
Temp1:=(FontSize/FontSizeMed)
OverlayTeamYOffset := OverlayTeamYOffsetMed * Temp1 + TeamFlatOffset
OverlayYSpacing:= OverlayYSpacingMed * Temp1
OverlayBgBotAdj:= OverlayBgBotAdjMed * Temp1

OverlayRow1Y:=OverlayTeamYOffset+OverlayY+OverlayBgMargin
OverlayRow2Y:=OverlayRow1Y+OverlayYSpacing
OverlayRow3Y:=OverlayRow2Y+OverlayYSpacing
OverlayRow4Y:=OverlayRow3Y+OverlayYSpacing

If LabelsON = 1
{
MsgStartX:=MsgStartX+(OverlayXSpacing*Temp1)
}
OverlayBgW:=(BgWidth*Temp1) + MsgStartX - OverlayX + OverlayBgMargin
OverlayBgH:= (OverlayRow4Y - OverlayY) + OverlayBgMargin + OverlayBgBotAdj
OverlayBgID:= BoxCreate(OverlayX, OverlayY, OverlayBgW, OverlayBgH, BgColorValue, False)
OverlayTimerY := OverlayY - OverlayTimerYOffset - OverlayTimerH
OverlayTimerID:= BoxCreate(OverlayX, OverlayTimerY, OverlayBgW, OverlayTimerH, BgColorValue, False)

OverlayLblUpID := TextCreate(TempLblFont, LblFontSize, LblBold, LblItalic, LblStartX, OverlayRow1Y, LblColorValue, LblUpText, true, False)
OverlayLblLeftID := TextCreate(TempLblFont, LblFontSize, LblBold, LblItalic, LblStartX, OverlayRow2Y, LblColorValue, LblLeftText, true, False)
OverlayLblRightID := TextCreate(TempLblFont, LblFontSize, LblBold, LblItalic, LblStartX, OverlayRow3Y, LblColorValue, LblRightText, true, False)
OverlayLblDownID := TextCreate(TempLblFont, LblFontSize, LblBold, LblItalic, LblStartX, OverlayRow4Y, LblColorValue, LblDownText, true, False)
OverlayMsgUpID := TextCreate(MsgFont, MsgFontSize, MsgBold, MsgItalic, MsgStartX, OverlayRow1Y, MsgColorValue, OverlayUpMsg, true, False)
OverlayMsgLeftID := TextCreate(MsgFont, MsgFontSize, MsgBold, MsgItalic, MsgStartX, OverlayRow2Y, MsgColorValue, OverlayLeftMsg, true, False)
OverlayMsgRightID := TextCreate(MsgFont, MsgFontSize, MsgBold, MsgItalic, MsgStartX, OverlayRow3Y, MsgColorValue, OverlayRightMsg, true, False)
OverlayMsgDownID := TextCreate(MsgFont, MsgFontSize, MsgBold, MsgItalic, MsgStartX, OverlayRow4Y, MsgColorValue, OverlayDownMsg, true, False)

Temp1:=OverlayY+OverlayBgH
OverlayChatModeID := TextCreate(MsgFont, MsgFontSize, False, False, OverlayX, Temp1, "0xFFFFFFFF", "ChatMode", true, False)

Temp1:=OverlayRow1Y-OverlayTeamYOffset
OverlayTeamUpID := TextCreate(TeamFont, TeamFontSize, TeamBold, TeamItalic, MsgStartX, Temp1, TeamColorValue, "TEAM", true, False)
Temp1:=OverlayRow2Y-OverlayTeamYOffset
OverlayTeamLeftID := TextCreate(TeamFont, TeamFontSize, TeamBold, TeamItalic, MsgStartX, Temp1, TeamColorValue, "TEAM", true, False)
Temp1:=OverlayRow3Y-OverlayTeamYOffset
OverlayTeamRightID := TextCreate(TeamFont, TeamFontSize, TeamBold, TeamItalic, MsgStartX, Temp1, TeamColorValue, "TEAM", true, False)
Temp1:=OverlayRow4Y-OverlayTeamYOffset
OverlayTeamDownID := TextCreate(TeamFont, TeamFontSize, TeamBold, TeamItalic, MsgStartX, Temp1, TeamColorValue, "TEAM", true, False)
OverlayInitialized = 1
}


OverlayDispOff()
{
global

BoxSetShown(OverlayBgID, False)

	If MenuTimerON = 1
	{
	BoxSetShown(OverlayTimerID, False)
	}

	If LabelsON
	{
	TextSetShown(OverlayLblUpID, False)
	TextSetShown(OverlayLblLeftID, False)
	TextSetShown(OverlayLblRightID, False)
	TextSetShown(OverlayLblDownID, False)
	}

TextSetShown(OverlayMsgUpID, False)
TextSetShown(OverlayMsgLeftID, False)
TextSetShown(OverlayMsgRightID, False)
TextSetShown(OverlayMsgDownID, False)

TextSetShown(OverlayTeamUpID, False)
TextSetShown(OverlayTeamLeftID, False)
TextSetShown(OverlayTeamRightID, False)
TextSetShown(OverlayTeamDownID, False)

}

OverlayDispMenu()
{
global

OverlayUpMsg:= OverlayMsg%CurrMenu%Up
OverlayLeftMsg:= OverlayMsg%CurrMenu%Left
OverlayRightMsg:= OverlayMsg%CurrMenu%Right
OverlayDownMsg:= OverlayMsg%CurrMenu%Down

TextSetString(OverlayMsgUpID, OverlayUpMsg)
TextSetString(OverlayMsgLeftID, OverlayLeftMsg)
TextSetString(OverlayMsgRightID, OverlayRightMsg)
TextSetString(OverlayMsgDownID, OverlayDownMsg)

BoxSetShown(OverlayBgID, True)

	If MenuTimerON = 1
	{
	BoxSetPos(OverlayTimerID, OverlayX, OverlayTimerY)
	BoxSetWidth(OverlayTimerID, OverlayBgW)
	BoxSetShown(OverlayTimerID, True)
	}

	If LabelsON = 1
	{
	TextSetShown(OverlayLblUpID, True)
	TextSetShown(OverlayLblLeftID, True)
	TextSetShown(OverlayLblRightID, True)
	TextSetShown(OverlayLblDownID, True)
	}

TextSetShown(OverlayMsgUpID, True)
TextSetShown(OverlayMsgLeftID, True)
TextSetShown(OverlayMsgRightID, True)
TextSetShown(OverlayMsgDownID, True)

If (Team%CurrMenu%Up = 1)
{
TextSetShown(OverlayTeamUpID, True)
}
If (Team%CurrMenu%Left = 1)
{
TextSetShown(OverlayTeamLeftID, True)
}
If (Team%CurrMenu%Right = 1)
{
TextSetShown(OverlayTeamRightID, True)
}
If (Team%CurrMenu%Down = 1)
{
TextSetShown(OverlayTeamDownID, True)
}
}

DestroyOverlay()
{
global
BoxDestroy(OverlayBgID)
BoxDestroy(OverlayTimerID)

TextDestroy(OverlayLblUpID)
TextDestroy(OverlayLblLeftID)
TextDestroy(OverlayLblRightID)
TextDestroy(OverlayLblDownID)

TextDestroy(OverlayMsgUpID)
TextDestroy(OverlayMsgLeftID)
TextDestroy(OverlayMsgRightID)
TextDestroy(OverlayMsgDownID)

TextDestroy(OverlayChatModeID)

TextDestroy(OverlayTeamUpID)
TextDestroy(OverlayTeamLeftID)
TextDestroy(OverlayTeamRightID)
TextDestroy(OverlayTeamDownID)
}

SetChatMode(input)
{
global

	If input=-1
	{
		If (ChatMode=0)
		{
		ChatMode = 1
		}
		Else If ChatMode=1
		{
		ChatMode = 0
		If SpamModeEnable = 1
		ChatMode=2
		}
		Else
		{
		ChatMode=0
		}
	If MuteChatToggle = 0
		SoundPlay, %A_WinDir%\Media\ding.wav
	}
	Else
	{
	ChatMode:=input
	}

	If ChatMode=2
	{
	GuiControl, Text, IndicatorChatMode, Spam
	Temp1=Spam Chat Mode
	}
	Else If ChatMode=1
	{
	GuiControl, Text, IndicatorChatMode, Custom
	Temp1=Custom Chat Mode
	}
	Else
	{
	GuiControl, Text, IndicatorChatMode, Standard
	Temp1=Standard Chat Mode
	}

If (OverlayON=1) and (OverlayInitialized = 1)
{
OverlayChatModeVisible = 1
TextSetString(OverlayChatModeID, Temp1)
TextSetShown(OverlayChatModeID, True)
ChatModeChangeTime:= A_TickCount
}
}

StandardChat()
{
global
Output := StandardChat%CurrDir%
SendInput %Output%
}

LimitCheck()
{
global
OutOfLims = 

If MenuTimeout not between 100 and 5000
	OutOfLims = %OutOfLims%Menu Timeout must be between 100 and 5000`n
If ChatOpenDelay not between 50 and 950
	OutOfLims = %OutOfLims%Chat Open Delay must be between 50 and 950`n
If JoystickSamplingPeriod not between 1 and 250
	OutOfLims = %OutOfLims%Joystick Sampling Period must be between 1 and 250`n
If OverlayX not between 0 and 800
	OutOfLims = %OutOfLims%Overlay Position X must be between 0 and 800`n
If OverlayY not between 0 and 600
	OutOfLims = %OutOfLims%Overlay Position Y must be between 0 and 600`n
If Mod(FontSize,2) <> 0 or FontSize not between 4 and 30
	OutOfLims = %OutOfLims%Overlay Size must be an even number between 4 and 30`n
If BgOpac not between 0 and 100
	OutOfLims = %OutOfLims%Background Opacity must be between 0 and 100`n
If BgWidth not between 0 and 500
	OutOfLims = %OutOfLims%Width Scale must be between 20 and 500`n
If OverlayCharLim not between 5 and %MaxMsgLength%
	OutOfLims = %OutOfLims%Overlay Character Limit must be between 0 and %MaxMsgLength%`n
If StrLen(BgColor) < 6
	OutOfLims = %OutOfLims%Background Color must be must be a hex color code`n
If StrLen(MsgColor) < 6
	OutOfLims = %OutOfLims%Message Color must be must be a hex color code`n
If StrLen(TeamColor) < 6
	OutOfLims = %OutOfLims%Team Indicator Color must be must be a hex color code`n
If StrLen(LblColor) < 6
	OutOfLims = %OutOfLims%Label Color must be must be a hex color code`n

If OutofLims <>
	MsgBox,8192,Sorry!, % OutOfLims

}




LoadIni(Option,Path)
{
global
If Path <>
{
If (Option = "All")
{
;LastVer
IniRead, LastVersion, %Path%, ProgramInfo, LastVersion, 0
}
If (Option = "All") or (Option = "Messages")
{
;Chat
;Up
IniRead, UpUp, %Path%, Chat, UpUp, I got it!
IniRead, TeamUpUp, %Path%, Chat, TeamUpUp, 1
IniRead, UpLeft, %Path%, Chat, UpLeft, Centering...
IniRead, TeamUpLeft, %Path%, Chat, TeamUpLeft, 1
IniRead, UpRight, %Path%, Chat, UpRight, Take the shot!
IniRead, TeamUpRight, %Path%, Chat, TeamUpRight, 1
IniRead, UpDown, %Path%, Chat, UpDown, Defending...
IniRead, TeamUpDown, %Path%, Chat, TeamUpDown, 1
;Left
IniRead, LeftUp, %Path%, Chat, LeftUp, Nice shot!
IniRead, TeamLeftUp, %Path%, Chat, TeamLeftUp, 0
IniRead, LeftLeft, %Path%, Chat, LeftLeft, Great pass!
IniRead, TeamLeftLeft, %Path%, Chat, TeamLeftLeft, 0
IniRead, LeftRight, %Path%, Chat, LeftRight, Thanks!
IniRead, TeamLeftRight, %Path%, Chat, TeamLeftRight, 0
IniRead, LeftDown, %Path%, Chat, LeftDown, What a save!
IniRead, TeamLeftDown, %Path%, Chat, TeamLeftDown, 0
;Right
IniRead, RightUp, %Path%, Chat, RightUp, OMG!
IniRead, TeamRightUp, %Path%, Chat, TeamRightUp, 0
IniRead, RightLeft, %Path%, Chat, RightLeft, Noooo!
IniRead, TeamRightLeft, %Path%, Chat, TeamRightLeft, 0
IniRead, RightRight, %Path%, Chat, RightRight, Wow!
IniRead, TeamRightRight, %Path%, Chat, TeamRightRight, 0
IniRead, RightDown, %Path%, Chat, RightDown, Close one!
IniRead, TeamRightDown, %Path%, Chat, TeamRightDown, 0
;Down
CurseSymbols := "$#@%!"
IniRead, DownUp, %Path%, Chat, DownUp, %CurseSymbols%
IniRead, TeamDownUp, %Path%, Chat, TeamDownUp, 0
IniRead, DownLeft, %Path%, Chat, DownLeft, No Problem.
IniRead, TeamDownLeft, %Path%, Chat, TeamDownLeft, 0
IniRead, DownRight, %Path%, Chat, DownRight, Whoops...
IniRead, TeamDownRight, %Path%, Chat, TeamDownRight, 0
IniRead, DownDown, %Path%, Chat, DownDown, Sorry!
IniRead, TeamDownDown, %Path%, Chat, TeamDownDown, 0
}

;Settings
If (Option = "All")
{
;RL Keybindings
blank =
IniRead, AllChat, %Path%, Settings, AllChat, T
IniRead, TeamChat, %Path%, Settings, TeamChat, Y
IniRead, StandardChatUp, %Path%, Settings, StandardChatUp, 1
IniRead, StandardChatLeft, %Path%, Settings, StandardChatLeft, 2
IniRead, StandardChatRight, %Path%, Settings, StandardChatRight, 3
IniRead, StandardChatDown, %Path%, Settings, StandardChatDown, 4
;Chat Settings
IniRead, ToggleChatButton, %Path%, Settings, ToggleChatButton, %A_Space%
IniRead, MuteChatToggle, %Path%, Settings, MuteChatToggle, 0
IniRead, MenuTimeout, %Path%, Settings, MenuTimeout, 2000
IniRead, ChatOpenDelay, %Path%, Settings, ChatOpenDelay, 250
IniRead, SpamModeEnable, %Path%, Settings, SpamModeEnable, 0
;Auto Launch RL
IniRead, AutoLaunchRL, %Path%, Settings, AutoLaunchRL, 0
;Gamepad Settings
IniRead, JoystickType, %Path%, Settings, JoystickType, 1
IniRead, SelectedJoystickNumber, %Path%, Settings, SelectedJoystickNumber, 1
IniRead, JoystickSamplingPeriod, %Path%, Settings, JoystickSamplingPeriod, 5
IniRead, CustomJoystickType, %Path%, Settings, CustomJoystickType, POV
IniRead, CustomJoystickUp, %Path%, Settings, CustomJoystickUp, 0
IniRead, CustomJoystickRight, %Path%, Settings, CustomJoystickRight, 9000
IniRead, CustomJoystickDown, %Path%, Settings, CustomJoystickDown, 18000
IniRead, CustomJoystickLeft, %Path%, Settings, CustomJoystickLeft, 27000
IniRead, CustomJoystickUpDownAxis, %Path%, Settings, CustomJoystickUpDownAxis, P
IniRead, CustomJoystickLeftRightAxis, %Path%, Settings, CustomJoystickLeftRightAxis, P
}
;Overlay
IniRead, OverlayON, %Path%, Settings, OverlayON, 1
If (Option = "All") or (Option = "Overlay")
{
IniRead, OverlayX, %Path%, Settings, OverlayX, 20
IniRead, OverlayY, %Path%, Settings, OverlayY, 250
IniRead, FontSize, %Path%, Settings, FontSize, 10
IniRead, BgColor, %Path%, Settings, BgColor, 1B4667
IniRead, BgOpac, %Path%, Settings, BgOpac, 80
IniRead, BgWidth, %Path%, Settings, BgWidth, 100
IniRead, MenuTimerON, %Path%, Settings, MenuTimerON, 1
IniRead, MsgColor, %Path%, Settings, MsgColor, B0FFFF
IniRead, MsgFont, %Path%, Settings, MsgFont, Arial
IniRead, MsgModifier, %Path%, Settings, MsgModifier, 1
IniRead, TeamColor, %Path%, Settings, TeamColor, B0FFFF
IniRead, TeamFont, %Path%, Settings, TeamFont, Arial
IniRead, TeamModifier, %Path%, Settings, TeamModifier, 1
IniRead, TeamFlatOffset, %Path%, Settings, TeamFlatOffset, 2
IniRead, OverlayCharLim, %Path%, Settings, OverlayCharLim, 20
IniRead, LabelsON, %Path%, Settings, LabelsON, 1
IniRead, LblColor, %Path%, Settings, LblColor, B0FFFF
IniRead, LblFont, %Path%, Settings, LblFont, Arial
IniRead, LblModifier, %Path%, Settings, LblModifier, 1
IniRead, LblArrow, %Path%, Settings, LblArrow, 1
}
}
}

SaveIni(Option,Path)
{
global
If Path <>
{
If (Option = "All")
{
;Last Version
IniWrite, %LastVersion%, %Path%, ProgramInfo, LastVersion
}
If (Option = "All") or (Option = "Messages")
{
;Chat
;Up
IniWrite, %UpUp%, %Path%, Chat, UpUp
IniWrite, %TeamUpUp%, %Path%, Chat, TeamUpUp
IniWrite, %UpLeft%, %Path%, Chat, UpLeft
IniWrite, %TeamUpLeft%, %Path%, Chat, TeamUpLeft
IniWrite, %UpRight%, %Path%, Chat, UpRight
IniWrite, %TeamUpRight%, %Path%, Chat, TeamUpRight
IniWrite, %UpDown%, %Path%, Chat, UpDown
IniWrite, %TeamUpDown%, %Path%, Chat, TeamUpDown
;Left
IniWrite, %LeftUp%, %Path%, Chat, LeftUp
IniWrite, %TeamLeftUp%, %Path%, Chat, TeamLeftUp
IniWrite, %LeftLeft%, %Path%, Chat, LeftLeft
IniWrite, %TeamLeftLeft%, %Path%, Chat, TeamLeftLeft
IniWrite, %LeftRight%, %Path%, Chat, LeftRight
IniWrite, %TeamLeftRight%, %Path%, Chat, TeamLeftRight
IniWrite, %LeftDown%, %Path%, Chat, LeftDown
IniWrite, %TeamLeftDown%, %Path%, Chat, TeamLeftDown
;Right
IniWrite, %RightUp%, %Path%, Chat, RightUp
IniWrite, %TeamRightUp%, %Path%, Chat, TeamRightUp
IniWrite, %RightLeft%, %Path%, Chat, RightLeft
IniWrite, %TeamRightLeft%, %Path%, Chat, TeamRightLeft
IniWrite, %RightRight%, %Path%, Chat, RightRight
IniWrite, %TeamRightRight%, %Path%, Chat, TeamRightRight
IniWrite, %RightDown%, %Path%, Chat, RightDown
IniWrite, %TeamRightDown%, %Path%, Chat, TeamRightDown
;Down
IniWrite, %DownUp%, %Path%, Chat, DownUp
IniWrite, %TeamDownUp%, %Path%, Chat, TeamDownUp
IniWrite, %DownLeft%, %Path%, Chat, DownLeft
IniWrite, %TeamDownLeft%, %Path%, Chat, TeamDownLeft
IniWrite, %DownRight%, %Path%, Chat, DownRight
IniWrite, %TeamDownRight%, %Path%, Chat, TeamDownRight
IniWrite, %DownDown%, %Path%, Chat, DownDown
IniWrite, %TeamDownDown%, %Path%, Chat, TeamDownDown
}

If (Option = "All")
{
;Settings
;RL Keybeindings
IniWrite, %AllChat%, %Path%, Settings, AllChat
IniWrite, %TeamChat%, %Path%, Settings, TeamChat
IniWrite, %StandardChatUp%, %Path%, Settings, StandardChatUp
IniWrite, %StandardChatLeft%, %Path%, Settings, StandardChatLeft
IniWrite, %StandardChatRight%, %Path%, Settings, StandardChatRight
IniWrite, %StandardChatDown%, %Path%, Settings, StandardChatDown
;Chat Settings
IniWrite, %ToggleChatButton%, %Path%, Settings, ToggleChatButton
IniWrite, %MuteChatToggle%, %Path%, Settings, MuteChatToggle
IniWrite, %MenuTimeout%, %Path%, Settings, MenuTimeout
IniWrite, %ChatOpenDelay%, %Path%, Settings, ChatOpenDelay
IniWrite, %SpamModeEnable%, %Path%, Settings, SpamModeEnable
;Auto Launch RL
IniWrite, %AutoLaunchRL%, %Path%, Settings, AutoLaunchRL
;Gamepad Settings
IniWrite, %JoystickType%, %Path%, Settings, JoystickType
IniWrite, %SelectedJoystickNumber%, %Path%, Settings, SelectedJoystickNumber
IniWrite, %JoystickSamplingPeriod%, %Path%, Settings, JoystickSamplingPeriod
IniWrite, %CustomJoystickType%, %Path%, Settings, CustomJoystickType
IniWrite, %CustomJoystickUp%, %Path%, Settings, CustomJoystickUp
IniWrite, %CustomJoystickDown%, %Path%, Settings, CustomJoystickDown
IniWrite, %CustomJoystickLeft%, %Path%, Settings, CustomJoystickLeft
IniWrite, %CustomJoystickRight%, %Path%, Settings, CustomJoystickRight
IniWrite, %CustomJoystickUpDownAxis%, %Path%, Settings, CustomJoystickUpDownAxis
IniWrite, %CustomJoystickLeftRightAxis%, %Path%, Settings, CustomJoystickLeftRightAxis
}

;Overlay
IniWrite, %OverlayON%, %Path%, Settings, OverlayON
If (Option = "All") or (Option = "Overlay")
{
IniWrite, %OverlayX%, %Path%, Settings, OverlayX
IniWrite, %OverlayY%, %Path%, Settings, OverlayY
IniWrite, %FontSize%, %Path%, Settings, FontSize
IniWrite, %BgColor%, %Path%, Settings, BgColor
IniWrite, %BgOpac%, %Path%, Settings, BgOpac
IniWrite, %BgWidth%, %Path%, Settings, BgWidth
IniWrite, %MenuTimerON%, %Path%, Settings, MenuTimerON
IniWrite, %MsgColor%, %Path%, Settings, MsgColor
IniWrite, %MsgFont%, %Path%, Settings, MsgFont
IniWrite, %MsgModifier%, %Path%, Settings, MsgModifier
IniWrite, %TeamColor%, %Path%, Settings, TeamColor
IniWrite, %TeamFont%, %Path%, Settings, TeamFont
IniWrite, %TeamModifier%, %Path%, Settings, TeamModifier
IniWrite, %TeamFlatOffset%, %Path%, Settings, TeamFlatOffset
IniWrite, %OverlayCharLim%, %Path%, Settings, OverlayCharLim
IniWrite, %LabelsON%, %Path%, Settings, LabelsON
IniWrite, %LblColor%, %Path%, Settings, LblColor
IniWrite, %LblFont%, %Path%, Settings, LblFont
IniWrite, %LblModifier%, %Path%, Settings, LblModifier
IniWrite, %LblArrow%, %Path%, Settings, LblArrow
}
}
}


CreateSection(Menu, xsection, ysection)
{
global
;----------Section Start-----------
;calculations
xSymbol := xsection
xMsg := xSymbol + SymbolLength + xSpacing
xTeam := xMsg + MsgLength + xSpacing
xTeamLabel := xTeam - TeamLabelOffset
ypos := ysection + LabelsOffset
ySymbol := ypos + ySymbolOffset + 2
yTeam := ypos + yTeamOffset
yLabels := ysection

;labels
Gui, Add, Text, w%MsgLength% x%xMsg% y%yLabels% Center, Chat Message
Gui, Add, Text, w%TeamLength% x%xTeamLabel% y%yLabels%, Team?

Dir = Up
Selection = %Menu%%Dir%
Symbol := Symbol%Dir%
InitialCheckState := Team%Menu%%Dir%
InitialEditState := %Menu%%Dir%
Gui, Add, Text, w%SymbolLength% x%xSymbol% y%ySymbol% Right, %Symbol%
Gui, Add, Checkbox, vTeam%Selection% r1 w%TeamLength% x%xTeam% y%yTeam%  Checked%InitialCheckState%
Gui, Add, Edit, v%Selection% r1 w%MsgLength% x%xMsg% y%ypos% Limit%MaxMsgLength%, %InitialEditState%
ypos := ypos + TextHeight + ySpacing
ySymbol := ypos + ySymbolOffset
yTeam := ypos + yTeamOffset
%Menu%%Dir%_TT:=Default%Menu%%Dir%

Dir = Left
Selection = %Menu%%Dir%
Symbol := Symbol%Dir%
InitialCheckState := Team%Menu%%Dir%
InitialEditState := %Menu%%Dir%
Gui, Add, Text, w%SymbolLength% x%xSymbol% y%ySymbol% Right, %Symbol%
Gui, Add, Checkbox, vTeam%Selection% r1 w%TeamLength% x%xTeam% y%yTeam%  Checked%InitialCheckState%
Gui, Add, Edit, v%Selection% r1 w%MsgLength% x%xMsg% y%ypos% Limit%MaxMsgLength%, %InitialEditState%
ypos := ypos + TextHeight + ySpacing
ySymbol := ypos + ySymbolOffset
yTeam := ypos + yTeamOffset
%Menu%%Dir%_TT:=Default%Menu%%Dir%

Dir = Right
Selection = %Menu%%Dir%
Symbol := Symbol%Dir%
InitialCheckState := Team%Menu%%Dir%
InitialEditState := %Menu%%Dir%
Gui, Add, Text, w%SymbolLength% x%xSymbol% y%ySymbol% Right, %Symbol%
Gui, Add, Checkbox, vTeam%Selection% r1 w%TeamLength% x%xTeam% y%yTeam%  Checked%InitialCheckState%
Gui, Add, Edit, v%Selection% r1 w%MsgLength% x%xMsg% y%ypos% Limit%MaxMsgLength%, %InitialEditState%
ypos := ypos + TextHeight + ySpacing
ySymbol := ypos + ySymbolOffset
yTeam := ypos + yTeamOffset
%Menu%%Dir%_TT:=Default%Menu%%Dir%

Dir = Down
Selection = %Menu%%Dir%
Symbol := Symbol%Dir%
InitialCheckState := Team%Menu%%Dir%
InitialEditState := %Menu%%Dir%
Gui, Add, Text, w%SymbolLength% x%xSymbol% y%ySymbol% Right, %Symbol%
Gui, Add, Checkbox, vTeam%Selection% r1 w%TeamLength% x%xTeam% y%yTeam%  Checked%InitialCheckState%
Gui, Add, Edit, v%Selection% r1 w%MsgLength% x%xMsg% y%ypos% Limit%MaxMsgLength%, %InitialEditState%
ypos := ypos + TextHeight + ySpacing
ySymbol := ypos + ySymbolOffset
yTeam := ypos + yTeamOffset
%Menu%%Dir%_TT:=Default%Menu%%Dir%
;---------------END OF SECTION----------
}

Hex(Input)
{
OldFormat := A_FormatInteger ; save the current format as a string
Input := Floor(Input)
SetFormat, Integer, Hex
Input += 0 ;forces number into current fomatinteger

StringTrimLeft, Input, Input, 2

SetFormat, Integer, %OldFormat% ;if oldformat was either "hex" or "dec" it will restore it to it's previous setting
SetFormat, Float, 0.3

Return Input
}

GetJoyButton(Timeout, TimeoutMsg:=0) ;Must connect first
{
global
local StartTime := A_TickCount
local ButtonState
Loop { 
Loop %joy_buttons% {
		GetKeyState, ButtonState, %JoystickNumber%joy%a_index%
		if ButtonState = D
			Return %a_index%
}
If (Timeout < (A_TickCount - StartTime))
	Break
}
If TimeoutMsg = 1
	MsgBox,8192,Sorry!, No controller button input recieved
}


WM_MOUSEMOVE()
{
    static CurrControl, PrevControl, _TT
    CurrControl := A_GuiControl
	
    If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
    {
        ToolTip  ; Turn off any previous tooltip.
	SetTimer, DisplayToolTip, 500
        PrevControl := CurrControl
    }
    return

    DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    ToolTip % %CurrControl%_TT  ; The leading percent sign tell it to use an expression.
    SetTimer, RemoveToolTip, 4000
    return

    RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    return
}

SaveSettings(Input)
{
global

RootDir := Saved%Input%Folder
FileSelectFile, SavePath, S17, %RootDir%\, Save Settings
SaveIni(Input, SavePath)
}

LoadSettings(Input)
{
global

RootDir := Saved%Input%Folder
FileSelectFile, LoadPath, 3, %RootDir%\, Load Settings
LoadIni(Input, LoadPath)

If Input=Messages
{
Menu = Up

Dir = Up
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Left
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Right
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Down
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%

Menu = Left

Dir = Up
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Left
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Right
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Down
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%

Menu = Right

Dir = Up
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Left
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Right
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Down
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%

Menu = Down

Dir = Up
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Left
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Right
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
Dir = Down
Selection = %Menu%%Dir%
Msg:=%Selection%
Team:= Team%Selection%
GuiControl, , %Selection%, %Msg%
GuiControl, , Team%Selection%, %Team%
}

If Input=Overlay
{
GuiControl,, OverlayX, %OverlayX%
GuiControl,, OverlayY, %OverlayY%
GuiControl,, FontSize, %FontSize%
GuiControl,, BgColor, %BgColor%
GuiControl,, BgOpac, %BgOpac%
GuiControl,, BgWidth, %BgWidth%
GuiControl,, MenuTimerON, %MenuTimerON%
GuiControl,, MsgColor, %MsgColor%
GuiControl,, MsgFont, %MsgFont%
UpdateFontDisplay("Msg")
GuiControl,Choose, MsgModifier, %MsgModifier%
GuiControl,, TeamColor, %TeamColor%
GuiControl,, TeamFont, %TeamFont%
UpdateFontDisplay("Team")
GuiControl,Choose,TeamModifier, %TeamModifier%
GuiControl,,TeamFlatOffset, %TeamFlatOffset%
GuiControl,,OverlayCharLim, %OverlayCharLim%
GuiControl,, LabelsON, %LabelsON%
GuiControl,, LblColor, %LblColor%
GuiControl,, LblFont, %LblFont%
UpdateFontDisplay("Lbl")
GuiControl,Choose, LblModifier, %LblModifier%
GuiControl,Choose, LblArrow, %LblArrow%
}

}

WM_LButtonDBLCLK() {
 global
 MouseGetPos,,,,DBLCLKhwnd, 2
 GuiControlGet, DBLCLKvar,Name,%DBLCLKhwnd%
 DBLCLKlabel := %DBLCLKvar%_DblClk
If DBLCLKlabel <>
{
gosub %DBLCLKlabel%
}

}

CmnDlg_Color(ByRef pColor, hGui=0){ 
  ;covert from rgb
    clr := ((pColor & 0xFF) << 16) + (pColor & 0xFF00) + ((pColor >> 16) & 0xFF) 
 
    VarSetCapacity(sCHOOSECOLOR, 0x24, 0) 
    VarSetCapacity(aChooseColor, 64, 0) 
 
    NumPut(0x24,		 sCHOOSECOLOR, 0)      ; DWORD lStructSize 
    NumPut(hGui,		 sCHOOSECOLOR, 4)      ; HWND hwndOwner (makes dialog "modal"). 
    NumPut(clr,			 sCHOOSECOLOR, 12)     ; clr.rgbResult 
    NumPut(&aChooseColor,sCHOOSECOLOR, 16)     ; COLORREF *lpCustColors 
    NumPut(0x00000103,	 sCHOOSECOLOR, 20)     ; Flag: CC_ANYCOLOR || CC_RGBINIT 
 
    nRC := DllCall("comdlg32\ChooseColorA", str, sCHOOSECOLOR)  ; Display the dialog. 
    if (errorlevel <> 0) || (nRC = 0) 
       return  false 
 
 
    clr := NumGet(sCHOOSECOLOR, 12) 
  
    SetFormat, integer, hex  ; Show RGB color extracted below in hex format. 
 
 ;convert to rgb 
    pColor := (clr & 0xff00) + ((clr & 0xff0000) >> 16) + ((clr & 0xff) << 16) 
    StringTrimLeft, pColor, pColor, 2 
    loop, % 6-strlen(pColor) 
		pColor=0%pColor% 
    pColor=0x%pColor% 
SetFormat, Float, 0.3 
 
	return true
}

InGameCheck:
If ((A_TickCount - LastInGameCheck) < InGameCheckPeriod)
	Return
InGame := False
If RLPID = 0 ;Return if process does not exist
	Return
RunWait %comspec% /c Netstat -ano | findstr %RLPID% | findstr UDP >"%PortCheckPath%"",, Hide
Loop, read, %PortCheckPath%
{
    Loop, parse, A_LoopReadLine, :
    {
	
	If  A_index = 2
	{
		Loop, parse, A_LoopField, %A_Space%
		{
		Port = %A_LoopField%
		break
		}
		break
	}
    }
If Port not in %SteamPortList%
{
If InGame = False
	CurrMenu = None
InGame := True
break
}
}
LastInGameCheck := A_TickCount
Return

OpenRLButton:
GoSub OpenRocketLeague
If ErrorLevel != 0
	WinActivate, ahk_pid %ErrorLevel%
Return	

OpenRocketLeague:
Process, Exist, %RLProcess%
If ErrorLevel = 0
	Run steam://rungameid/252950
Return

GuiClose:
Gui, Submit, NoHide
SaveIni("All",IniPath)
exitapp
