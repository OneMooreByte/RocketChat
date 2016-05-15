
FontSelector(ByRef Font, ByRef Style){
global FontSelector_SelectedFont, FontSelector_SelectedStyle, FontSelector_TestText, FontSelector_FontList
Title = Select Font
FontSelector_TestText = The quick brown fox jumps over the lazy dog
If FontSelector_FontList =
	FontSelector_FontList := CreateFontList(1)
Gui, 1: +Disabled
Gui, FontSelector:New
Gui, font,s9,
Gui, FontSelector:-SysMenu
Gui, FontSelector:Add, DropdownList, x10 y10 w190 Choose1 vFontSelector_SelectedFont gFontSelector_ModifyTestText, %FontSelector_FontList%
Gui, FontSelector:Add, DropdownList, x+5 yp w65 AltSubmit Choose%Style% vFontSelector_SelectedStyle gFontSelector_ModifyTestText, Regular|Bold|Italic
Gui, FontSelector:Add, Edit, y+5 x10 w260 h100 Multi -WantCtrlA -WantReturn -VScroll vFontSelector_TestText, %FontSelector_TestText%
Gui, FontSelector:Add, Button, w65 x205 y+5 gFontSelector_AcceptFont, Select
Gui, FontSelector:Add, Button, w65 x10 yp gFontSelector_CancelFont, Cancel
Gui, FontSelector:Show,, %Title%
if (Font)
	GuiControl, ChooseString, FontSelector_SelectedFont, %Font%
Gosub FontSelector_ModifyTestText
WinWaitClose, %Title%
Gui, 1: -Disabled
Return


FontSelector_ModifyTestText:
Gui, FontSelector:Submit, NoHide
If FontSelector_SelectedStyle = 2
	TestTextStyle = bold
Else If FontSelector_SelectedStyle = 3
	TestTextStyle = italic
Else
	TestTextStyle = norm
Gui, FontSelector:Font, s16 norm %TestTextStyle%, %FontSelector_SelectedFont%
GuiControl, Font, FontSelector_TestText,
Return

FontSelector_AcceptFont:
Font := FontSelector_SelectedFont
Style := FontSelector_SelectedStyle
FontSelector_CancelFont:
Gui, 1:Show
Gui, FontSelector:Destroy
Return
}

;This could probably be trimmed down
CreateFontList(ShowGUI)
{
SetFormat, Integer, d
Global FonDlg_num
a_fd := 1
adres = %A_WinDir%\Fonts
faces := ["norm","norm italic","bold italic", "norm bold"]
wersja := [16,24,34,34,34]

Listfiles =
Lista =
Num := 0
Loop, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts
{
	RegRead, name
	ext := Substr(name,-2)
;	msgbox, %name%
	if (ext = "otf") or (ext = "ttf") or (ext = "ttc")
	{
		Listfiles .= name . "@"
		Num++
	}
}
;zapis := FileOpen("testft.txt", "w")
;pozycje := 0
*/

Loop, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion\Type 1 Installer\Type 1 Fonts
{
	RegRead, name
	StringSplit, nn, name, `n
	Listfiles .= nn2 . "@"
	Num++
}

Num := 100/Num

;msgbox Num %Num%
If ShowGUI
{
Gui, FontLoad:New
Gui, font,s9,
Gui, FontLoad:-SysMenu
Gui, FontLoad:Show, w100 h30, Loading...
Gui, FontLoad:Add, Text, x0 y0 w100 center, Loading...
Gui, FontLoad:Add, Text, vFonDlg_num xp+0 y+0 w100 center, % "0%"
}
licz := 0
Listfiles := SubStr(Listfiles,1,-1)
;msgBox %Listfiles%
Loop, parse, Listfiles, @
{
name = %A_WinDir%\Fonts\%A_LoopField%
If ShowGUI
	GuiControl,,FonDlg_num, % Round(++licz*Num) . "%"
IfNotExist, %name%
	name = %A_LoopField%
IfNotExist, %name%
	continue
plik := FileOpen(name, "r")
ext := Substr(name,-2)
if (ext = "pfm")
{
	plik.Seek(80, 0)
	ita := plik.ReadUchar()
	plik.Seek(3,1)
	bol := plik.ReadUchar() - 1
	plik.Seek(210, 0)
	family =
	Loop
	{
		tt := plik.Read(1)
		if (tt)
			family .= tt
		else
			break
;		msgbox %family%
	}
	plik.Close()
;msgbox, %family% b%bol% i%ita%
	typ =
	if (bol)
		typ = %typ% bold
	if (ita)
		typ = %typ% italic
	typ = %typ%
	Lista = %Lista%%family%   : %typ%@
;msgbox, %family% b%bol% i%ita%  typ %typ%
	
	continue
}
;pozycje++
;pisz = %A_LoopField%  --  font nr %pozycje%`n`r
;zapis.Write(pisz)
;Msgbox, %name%
fonty := 1
offset := [12]
mode := plik.Read(4)
If (mode = "ttcf")
{
	plik.Seek(8, 0)
	fonty := plik.ReadUChar()*256*256*256 + plik.ReadUChar()*256*256  + plik.ReadUChar()*256  + plik.ReadUChar()
	Loop, %fonty%
	{
		offs := plik.ReadUChar()*256*256*256 + plik.ReadUChar()*256*256  + plik.ReadUChar()*256  + plik.ReadUChar() + 12
		if (A_index > 1)
			offset.Insert(offs)
		else
			offset[1] := offs
	}
}

;pisz = fontów: %fonty%`n`r
;zapis.Write(pisz)

Loop, %fonty%
{
	plik.Seek(offset[A_index], 0)
	i := 0
	Loop  ; looking for name and OS/2 tables
	{
		qq := plik.Read(4)
		plik.Seek(4, 1)
		if (qq = "name")
		{
			skokname := plik.ReadUChar()*256*256*256 + plik.ReadUChar()*256*256  + plik.ReadUChar()*256  + plik.ReadUChar()
			i++
			lenname := plik.ReadUChar()*256*256*256 + plik.ReadUChar()*256*256  + plik.ReadUChar()*256  + plik.ReadUChar()
		}
		else if (qq = "OS/2")
		{
			skokosdw := plik.ReadUChar()*256*256*256 + plik.ReadUChar()*256*256  + plik.ReadUChar()*256  + plik.ReadUChar()
			lenosdw := plik.ReadUChar()*256*256*256 + plik.ReadUChar()*256*256  + plik.ReadUChar()*256  + plik.ReadUChar()
			i++
		}
		else
			plik.Seek(8, 1)
		If (i=2)
			break
	}

;OS/2 table

	plik.Seek(skokosdw+1, 0)
	ver := plik.ReadUchar() +1   ;table version

	skok := skokosdw + lenosdw - wersja[ver]
	plik.Seek(skok, 0)
	typy := (plik.ReadUChar()*256  + plik.ReadUChar()) & 0x21
;	typ = regular
;	if (typy & 1) 
;		typ = italic
;	if (typy & 0x20)
;		typ = bold
;	if (typy & 0x20) and (typy & 1)
;		typ = bold italic
	typ =
	if (typy & 0x20)
		typ = %typ% bold
	if (typy & 1) 
		typ = %typ% italic
	typ = %typ%
;pisz = Tablice name z id 1                typ: %typ% `n`r
;zapis.Write(pisz)
	
; nametable
	plik.Seek(skokname+2, 0)
	liczbanamerec := plik.ReadUChar()*256  + plik.ReadUChar()
	obszar := skokname + plik.ReadUChar()*256  + plik.ReadUChar()
	plik.Seek(skokname+6, 0)
	Loop, %liczbanamerec%
	{
		plik.Seek(4, 1)
		lan := plik.ReadUChar()*256  + plik.ReadUChar()
		id := plik.ReadUChar()*256  + plik.ReadUChar()
		if (id = 1)
		{
			familen := plik.ReadUChar()*256  + plik.ReadUChar()
			famioff := plik.ReadUChar()*256  + plik.ReadUChar() + obszar
;			pisz = name:  `n`r    >>>
;			zapis.Write(pisz)
;			poz := plik.Tell()
;			plik.Seek(famioff,0)
;			plik.RawRead(tekst, familen)
;			zapis.RawWrite(tekst, familen)
;			plik.Seek(poz,0)
;			pisz = <<<`n`r---koniec namerec---`n`r
;			zapis.Write(pisz)
		}
		else
		{
			plik.Seek(4, 1)
		}
		if (id=1) and (lan = 1033)
			break
	}

	family =
	plik.Seek(famioff, 0)
	if (plik.ReadUChar() = 0)
	{
		Loop, % familen/2
		{
			family .= plik.Read(1)
			plik.Seek(1, 1)
		}
	}
	else
	{
		plik.Seek(famioff, 0)
		family := plik.Read(familen)
	}
Lista = %Lista%%family%   : %typ%@

;pisz = --------koniec fontu-----`n`r
;zapis.Write(pisz)
}
plik.Close()

;pisz = --------koniec pliku-----`n`r`n`r
;zapis.Write(pisz)
}  ; nie kasuj
;zapis.Close()

Lista := Substr(Lista,1,-1)
Sort, Lista, D@
;msgbox, %Lista%
family =
NowaLista := []
dwnlList =
Atrybuty := []
fonty := 0
Loop, parse, Lista, @
{
	dwu := InStr(A_LoopField, ":")
	typ := Substr(A_LoopField,1,dwu-4)
	res := Substr(A_LoopField,dwu+1)
	r := 1
	b:=Instr(res,"bold",false)
	i:=Instr(res,"italic",false)
	if  (b and i)
		r := 8
	else if (i)
		r := 4
	else if (b)
		r := 2
	if (typ = family)
		Atrybuty[fonty] |= r
	else
	{
		fonty++
		family := typ
		NowaLista.Insert(typ)
		dwnlList = %dwnlList%%typ%|
		Atrybuty.Insert(r)
	}
;	if (typ = "Trajan")
;		msgbox %typ% atr %r%
}
If ShowGUI
	Gui, FontLoad:Destroy
Return dwnlList

}