#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance force
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%",,UseErrorLevel
   ExitApp
}
ProgramName = Rocket Chat
StartMenu := GetCommonPath("PROGRAMS")
ProgramFolder := GetCommonPath("PROGRAM_FILES")
Gui, 1:New,, Rocket Chat Installer
Gui, Font, s11, Arial
Gui, Add, Text,x15 y10 w350 Center, Welcome to the Rocket Chat Installer`nPlease select an option
Gui, Add, Button,x15 y+15 w100 gUninstall, Uninstall
Gui, Add, Button,x265 yp w100 gInstall, Install
Gui, 1:Show, w380, Rocket Chat Installer
Return

Uninstall:
MsgBox, 4,Uninstall, Are you sure you want to uninstall Rocket Chat?
IfMsgBox Yes
{
Gui, Uninstalling:New,-SysMenu,Uninstalling
Gui, Uninstalling:Font, s11, Arial
Gui, Uninstalling:Add, Text,x15 y10, Uninstalling
Gui, Uninstalling:Show
	IfExist, %ProgramFolder%\%ProgramName%
	{
	FileRemoveDir, %ProgramFolder%\%ProgramName%, 1
		If ErrorLevel != 0
		{
		GoSub UninstallFail
		Return
		}
	}
	IfExist, %A_AppData%\%ProgramName%
	{
	FileRemoveDir, %A_AppData%\%ProgramName%, 1
		If ErrorLevel != 0
		{
		GoSub UninstallFail
		Return
		}
	}
	IfExist, %StartMenu%\%ProgramName%.lnk
	{
	FileDelete, %StartMenu%\%ProgramName%.lnk
		If ErrorLevel != 0
		{
		GoSub UninstallFail
		Return
		}
	}
MsgBox,,Uninstall Successful, Rocket Chat has been uninstalled
ExitApp
}
Return

UninstallFail:
Gui, Uninstalling:Destroy
MsgBox,,Uninstall Failed, Uninstall Failed`nMake sure Rocket Chat is closed
Return

Install:
Gui, Installing:New,-SysMenu,Installing
Gui, Installing:Font, s11, Arial
Gui, Installing:Add, Text,x15 y10, Installing
Gui, Installing:Show
FileCreateDir, %ProgramFolder%\%ProgramName%
FileInstall, Rocket Chat.exe, %ProgramFolder%\%ProgramName%\Rocket Chat.exe,1
		If ErrorLevel != 0
		{
		Gui, Installing:Destroy
		MsgBox,,Install Failed, Install Failed`nMake sure there is not a previous version of Rocket Chat open
		Return
		}
FileCreateShortcut, %ProgramFolder%\%ProgramName%\Rocket Chat.exe, %StartMenu%\Rocket Chat.lnk
Gui, Installing:Destroy
MsgBox, 4,Install Successful, Would you like to launch Rocket Chat now?
IfMsgBox Yes
	Run %ProgramFolder%\%ProgramName%\Rocket Chat.exe
ExitApp
Return

GuiClose:
ExitApp
return

GetCommonPath( csidl ) 
{ 
        static init 

        if !init 
        { 
                CSIDL_APPDATA                 =0x001A     ; Application Data, new for NT4 
                CSIDL_COMMON_APPDATA          =0x0023     ; All Users\Application Data 
                CSIDL_COMMON_DOCUMENTS        =0x002e     ; All Users\Documents 
                CSIDL_DESKTOP                 =0x0010     ; C:\Documents and Settings\username\Desktop 
                CSIDL_FONTS                   =0x0014     ; C:\Windows\Fonts 
                CSIDL_LOCAL_APPDATA           =0x001C     ; non roaming, user\Local Settings\Application Data 
                CSIDL_MYMUSIC                 =0x000d     ; "My Music" folder 
                CSIDL_MYPICTURES              =0x0027     ; My Pictures, new for Win2K 
                CSIDL_PERSONAL                =0x0005     ; My Documents 
                CSIDL_PROGRAM_FILES_COMMON    =0x002b     ; C:\Program Files\Common 
                CSIDL_PROGRAM_FILES           =0x0026     ; C:\Program Files 
                CSIDL_PROGRAMS                =0x0002     ; C:\Documents and Settings\username\Start Menu\Programs 
                CSIDL_RESOURCES               =0x0038     ; %windir%\Resources\, For theme and other windows resources. 
                CSIDL_STARTMENU               =0x000b     ; C:\Documents and Settings\username\Start Menu 
                CSIDL_STARTUP                 =0x0007     ; C:\Documents and Settings\username\Start Menu\Programs\Startup. 
                CSIDL_SYSTEM                  =0x0025     ; GetSystemDirectory() 
                CSIDL_WINDOWS                 =0x0024     ; GetWindowsDirectory() 
        } 

        
        val = % CSIDL_%csidl% 
        VarSetCapacity(fpath, 256) 
        DllCall( "shell32\SHGetFolderPathA", "uint", 0, "int", val, "uint", 0, "int", 0, "str", fpath) 
        return %fpath% 
}