; Tibia Macro com Interface e Calibração Inteligente - por Careca Player ou João Vitor

#SingleInstance force
#Persistent
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
FileEncoding, UTF-8

; Variáveis globais
global configFile := A_ScriptDir "\config.ini"
global running := false
global BattleListChanged := false

; GUI principal
;Gui, +AlwaysOnTop +ToolWindow
Gui -Theme
Gui, Color, Red
Gui Font, s10, Arial
Gui Add, CheckBox, vchkAutoHeal gToggleOptions x16 y24 w119 h17 , Auto Cura (HP)
Gui Add, CheckBox, vchkAutoMana gToggleOptions x16 y48 w121 h17 , Auto Cura (MP)
Gui Add, CheckBox, vchkAutoHaste gToggleOptions x16 y72 w94 h17 , Auto Haste
Gui Add, CheckBox, vchkAutoUseSpells gToggleOptions x16 y96 w95 h17 , Auto Spells
Gui Add, CheckBox, vchkAutoUseUtito gToggleOptions x16 y120 w119 h17 , Auto Use Utito
Gui Add, Text, x160 y24 w130 h17 +Right 0x50000002, Tecla Cura 50 HP:
Gui Add, Text, x160 y56 w130 h17 +Right 0x50000002, Tecla Cura 80 HP:
Gui Add, Text, x160 y88 w130 h17 +Right 0x50000002, Tecla Cura 90 HP:
Gui Add, Text, x160 y120 w130 h17 +Right 0x50000002, Tecla Cura 50 MP:
Gui Add, Text, x160 y152 w130 h17 +Right 0x50000002, Tecla Cura 30 MP:
Gui Add, Text, x160 y184 w130 h17 +Right 0x50000002, Tecla Cura 10 MP:
Gui Add, Text, x160 y216 w130 h17 +Right 0x50000002, Tecla de Haste:
Gui Add, Text, x424 y24 w130 h17 +Right 0x50000002, Atalho Magia 1:
Gui Add, Text, x424 y56 w130 h17 +Right 0x50000002, Atalho Magia 2:
Gui Add, Text, x424 y88 w130 h17 +Right 0x50000002, Atalho Magia 3:
Gui Add, Text, x424 y120 w130 h17 +Right 0x50000002, Tecla Utito:
Gui Add, Button, gStartMacro x624 y256 w100 h29 0x50012000, Iniciar
Gui Add, Button, gStopMacro x520 y256 w100 h29 0x50012000, Parar
Gui Add, Button, gOpenCalibration x152 y256 w130 h29 0x50012000, Calibrar Áreas
Gui Add, GroupBox, x8 y0 w138 h150, Ativar/Desativar
Gui Add, GroupBox, x152 y0 w568 h246, Teclas
Gui Add, Hotkey, vkeyHP50 x296 y24 w120 h21
Gui Add, Hotkey, vkeyHP80 x296 y56 w120 h21
Gui Add, Hotkey, vkeyHP90 x296 y88 w120 h21
Gui Add, Hotkey, vkeyMP50 x296 y120 w120 h21
Gui Add, Hotkey, vkeyMP30 x296 y152 w120 h21
Gui Add, Hotkey, vkeyMP10 x296 y184 w120 h21
Gui Add, Hotkey, vkeyHaste x296 y216 w120 h21
Gui Add, Hotkey, vkeyMagicHotkey1 x560 y24 w120 h21
Gui Add, Hotkey, vkeyMagicHotkey2 x560 y56 w120 h21
Gui Add, Hotkey, vkeyMagicHotkey3 x560 y88 w120 h21
Gui Add, Hotkey, vkeyUtito x560 y120 w120 h21

Gui Show, w727 h293, Macro Tibia Inteligente 2.0
LoadSettings()
return

; verifica se as imagens estão na mesma pasta
images := ["haste.png", "spell1.png", "spell2.png", "spell3.png", "utito.png"]
for _, file in images {
    if !FileExist(file) {
        MsgBox, 16, Erro, Arquivo de imagem "%file%" não encontrado na pasta do script. O script será encerrado.
        ExitApp
    }
}

; Verifica se o processo client.exe está rodando
if !ProcessExist("client.exe") {
    MsgBox, 16, Erro, O processo client.exe não está em execução. O script será encerrado.
    ExitApp
}

; Verifica se a janela ativa pertence ao client.exe
WinGet, pid, PID, A
Process, Exist, client.exe
if (pid != ErrorLevel) {
    ; Tudo certo
} else {
    MsgBox, 16, Erro, A janela ativa não pertence ao client.exe. O script será encerrado.
    ExitApp
}

; Função para verificar processo
ProcessExist(name) {
    Process, Exist, %name%
    return ErrorLevel
}

ToggleOptions:
return

OpenCalibration:
    MsgBox, Vamos calibrar os pontos da barra de HP (cura leve, média e forte).
    CalibratePoint("HP90")
    CalibratePoint("HP80")
    CalibratePoint("HP50")
    MsgBox, Vamos calibrar os pontos da barra de Mana (cura leve, média e forte).
    CalibratePoint("MP50")
    CalibratePoint("MP30")
    CalibratePoint("MP10")
    MsgBox, Agora vamos calibrar a área dos ícones de status.
    CalibrateArea("StatusIcons")
	MsgBox, Agora vamos calibrar a área dos ícones das magias.
    CalibrateArea("SpellIcons")
    MsgBox, Agora vamos valibrar a posição da Battle List
    CalibrateArea("BattleList")
return

StartMacro:
    Gui, Color, Green
    Gui, Show,, Macro Ativado!
    SaveSettings()
    running := true
    SetTimer, MacroLoop, 100
    SetTimer, CheckBattleList, 100
	if (chkAutoHeal) {
		SetTimer, CheckHP, 100
	}
	if (chkAutoMana) {
		SetTimer, CheckMP, 100
	}
	if (chkAutoHaste) {
		SetTimer, CheckHaste, 250
	}
    if (!BattleListChanged) {
        if (chkAutoUseSpells) {
            SetTimer, CheckSpell1, 250
            SetTimer, CheckSpell2, 250
            SetTimer, CheckSpell3, 250
        }
    }
	if (chkAutoUseUtito) {
		SetTimer, CheckUtito, 10000
	}
	
	; Ativa a janela do client.exe
    ; Aguarda um momento para garantir que o client.exe foi iniciado corretamente
    Process, Exist, client.exe
    if (ErrorLevel)  ; Se o processo client.exe foi encontrado
    {
        WinActivate, ahk_pid %ErrorLevel%  ; Foca a janela do client.exe
    }
return

StopMacro:
    Gui, Color, Red
    Gui, Show,, Macro Desativado
    SaveSettings()
    running := false
    SetTimer, CheckBattleList, Off
    SetTimer, MacroLoop, Off
	SetTimer, CheckHP, Off
	SetTimer, CheckMP, Off
	SetTimer, CheckHaste, Off
	SetTimer, CheckSpell1, Off
	SetTimer, CheckSpell2, Off
	SetTimer, CheckSpell3, Off
	SetTimer, CheckUtito, Off
	
	; Ativa a janela do client.exe
    ; Aguarda um momento para garantir que o client.exe foi iniciado corretamente
    Process, Exist, client.exe
    if (ErrorLevel)  ; Se o processo client.exe foi encontrado
    {
        WinActivate, ahk_pid %ErrorLevel%  ; Foca a janela do client.exe
    }
return

MacroLoop:
    if (!running)
        return

    GuiControlGet, chkAutoHeal,, chkAutoHeal
    GuiControlGet, chkAutoMana,, chkAutoMana
    GuiControlGet, chkAutoHaste,, chkAutoHaste
	GuiControlGet, chkAutoUseSpells,, chkAutoUseSpells
	GuiControlGet, chkAutoUseUtito,, chkAutoUseUtito
return

;=====================================================================
; Funções do macro
;=====================================================================

; Função para verificar se a BattleList está variando (com monstros)
CheckBattleList() {
    global

    ; Lê as coordenadas da área da BattleList
    IniRead, BattleListX1, %configFile%, BattleList, X1
    IniRead, BattleListY1, %configFile%, BattleList, Y1
    IniRead, BattleListX2, %configFile%, BattleList, X2
    IniRead, BattleListY2, %configFile%, BattleList, Y2

    ; Procura a imagem bl.png na área da BattleList
    ImageSearch, foundX, foundY, %BattleListX1%, %BattleListY1%, %BattleListX2%, %BattleListY2%, *50 bl.png

    ; Se a imagem **não for encontrada**, a BattleList mudou (possivelmente com monstros)
    if (ErrorLevel != 0) {
        if (!BattleListChanged) {
            BattleListChanged := true
        }
    } else {
        if (BattleListChanged) {
            BattleListChanged := false
        }
    }
}

CheckHP() {
    GuiControlGet, keyHP50,, keyHP50
    GuiControlGet, keyHP80,, keyHP80
    GuiControlGet, keyHP90,, keyHP90

    CheckHPPoint("HP50", keyHP50)
    CheckHPPoint("HP80", keyHP80)
    CheckHPPoint("HP90", keyHP90)
}

CheckHPPoint(section, key) {
    IniRead, x, %configFile%, %section%, X
    IniRead, y, %configFile%, %section%, Y
    IniRead, expectedColor, %configFile%, %section%, Color

    PixelGetColor, currentColor, x, y, RGB
    if (currentColor != expectedColor) {
        SendInput, {%key%}
		RandSleep(25,75)
    }
}

CheckMP() {
    GuiControlGet, keyMP50,, keyMP50
    GuiControlGet, keyMP30,, keyMP30
    GuiControlGet, keyMP10,, keyMP10

    CheckMPPoint("MP10", keyMP10)
    CheckMPPoint("MP30", keyMP30)
    CheckMPPoint("MP50", keyMP50)
}

CheckHaste() {
    IniRead, x1, %configFile%, StatusIcons, X1
    IniRead, y1, %configFile%, StatusIcons, Y1
    IniRead, x2, %configFile%, StatusIcons, X2
    IniRead, y2, %configFile%, StatusIcons, Y2
    GuiControlGet, keyHaste,, keyHaste

    ImageSearch, foundX, foundY, x1, y1, x2, y2, *50 haste.png
    if (ErrorLevel = 0) {
        return  ; Haste ativo
    } else {
        SendInput, {%keyHaste%}
		RandSleep(25,75)
    }
}

CheckSpell1() {
    global
    if (!chkAutoUseSpells || !BattleListChanged)
        return

    IniRead, x1, %configFile%, SpellIcons, X1
    IniRead, y1, %configFile%, SpellIcons, Y1
    IniRead, x2, %configFile%, SpellIcons, X2
    IniRead, y2, %configFile%, SpellIcons, Y2
    GuiControlGet, keyMagicHotkey1,, keyMagicHotkey1

    ImageSearch, foundX, foundY, x1, y1, x2, y2, *50 spell1.png
    if (ErrorLevel = 0) {
        return  ; 
    } else {
        SendInput, {%keyMagicHotkey1%}
		RandSleep(25,75)
    }
}

CheckSpell2() {
    global
    if (!chkAutoUseSpells || !BattleListChanged)
        return

    IniRead, x1, %configFile%, SpellIcons, X1
    IniRead, y1, %configFile%, SpellIcons, Y1
    IniRead, x2, %configFile%, SpellIcons, X2
    IniRead, y2, %configFile%, SpellIcons, Y2
    GuiControlGet, keyMagicHotkey2,, keyMagicHotkey2

    ImageSearch, foundX, foundY, x1, y1, x2, y2, *50 spell2.png
    if (ErrorLevel = 0) {
        return  ; 
    } else {
        SendInput, {%keyMagicHotkey2%}
		RandSleep(25,75)
    }
}

CheckSpell3() {
    global
    if (!chkAutoUseSpells || !BattleListChanged)
        return
    
    IniRead, x1, %configFile%, SpellIcons, X1
    IniRead, y1, %configFile%, SpellIcons, Y1
    IniRead, x2, %configFile%, SpellIcons, X2
    IniRead, y2, %configFile%, SpellIcons, Y2
    GuiControlGet, keyMagicHotkey3,, keyMagicHotkey3

    ImageSearch, foundX, foundY, x1, y1, x2, y2, *50 spell3.png
    if (ErrorLevel = 0) {
        return  ; 
    } else {
        SendInput, {%keyMagicHotkey3%}
		RandSleep(25,75)
    }
}

CheckUtito() {
    IniRead, x1, %configFile%, SpellIcons, X1
    IniRead, y1, %configFile%, SpellIcons, Y1
    IniRead, x2, %configFile%, SpellIcons, X2
    IniRead, y2, %configFile%, SpellIcons, Y2
    GuiControlGet, keyUtito,, keyUtito

    ImageSearch, foundX, foundY, x1, y1, x2, y2, *50 utito.png
    if (ErrorLevel = 0) {
        return  ; 
    } else {
        SendInput, {%keyUtito%}
    }
}

;=====================================================================
; Funções de auxílio do macro (Não mexer)
;=====================================================================

CalibratePoint(section) {
    MsgBox, Clique no ponto de %section%.
    KeyWait, LButton, D
    MouseGetPos, x, y
    PixelGetColor, color, x, y, RGB

    IniWrite, %x%, %configFile%, %section%, X
    IniWrite, %y%, %configFile%, %section%, Y
    IniWrite, %color%, %configFile%, %section%, Color
}

CheckMPPoint(section, key) {
    IniRead, x, %configFile%, %section%, X
    IniRead, y, %configFile%, %section%, Y
    IniRead, expectedColor, %configFile%, %section%, Color

    PixelGetColor, currentColor, x, y, RGB
    if (currentColor != expectedColor) {
        SendInput, {%key%}
		RandSleep(25,75)
    }
}

CalibrateArea(section) {
    MsgBox, Clique no canto superior esquerdo da área para %section%.
    KeyWait, LButton, D
    MouseGetPos, x1, y1

    MsgBox, Agora clique no canto inferior direito da área.
    KeyWait, LButton, D
    MouseGetPos, x2, y2

    IniWrite, %x1%, %configFile%, %section%, X1
    IniWrite, %y1%, %configFile%, %section%, Y1
    IniWrite, %x2%, %configFile%, %section%, X2
    IniWrite, %y2%, %configFile%, %section%, Y2
}

TryFindImage(imagePath, x1, y1, x2, y2) {
    if !FileExist(imagePath) {
        ToolTip, ❌ Imagem não encontrada: %imagePath%
        Sleep, 1500
        ToolTip
        return false
    }
    ImageSearch, foundX, foundY, x1, y1, x2, y2, *50 %imagePath%
    return (ErrorLevel = 0)
}

RandSleep(x, y) {
	Random, rand, %x%, %y%
	Sleep %rand%
}

;=====================================================================
; Carrega as configurações do arquivo config.ini
;=====================================================================

LoadSettings() {
    global
    IniRead, chkAutoHeal, %configFile%, Settings, AutoHeal, 0
    IniRead, chkAutoMana, %configFile%, Settings, AutoMana, 0
    IniRead, chkAutoHaste, %configFile%, Settings, AutoHaste, 0
	IniRead, chkAutoUseSpells, %configFile%, Settings, AutoSpells, 0
	IniRead, chkAutoUseUtito, %configFile%, Settings, AutoUseUtito, 0

    IniRead, keyHP50, %configFile%, Keys, HP50, 1
    IniRead, keyHP80, %configFile%, Keys, HP80, F1
    IniRead, keyHP90, %configFile%, Keys, HP90, F2
    IniRead, keyMP50, %configFile%, Keys, MP50, F3
    IniRead, keyMP30, %configFile%, Keys, MP30, F4
    IniRead, keyMP10, %configFile%, Keys, MP10, r
    IniRead, keyHaste, %configFile%, Keys, Haste, 3
	
	IniRead, keyMagicHotkey1, %configFile%, Keys, MagicHotkey1, 7
	IniRead, keyMagicHotkey2, %configFile%, Keys, MagicHotkey2, 8
	IniRead, keyMagicHotkey3, %configFile%, Keys, MagicHotkey3, 9
	
	IniRead, keyUtito, %configFile%, Keys, Utito, F1

    GuiControl,, chkAutoHeal, %chkAutoHeal%
    GuiControl,, chkAutoMana, %chkAutoMana%
    GuiControl,, chkAutoHaste, %chkAutoHaste%
	GuiControl,, chkAutoUseSpells, %chkAutoUseSpells%
	GuiControl,, chkAutoUseUtito, %chkAutoUseUtito%

    GuiControl,, keyHP50, %keyHP50%
    GuiControl,, keyHP80, %keyHP80%
    GuiControl,, keyHP90, %keyHP90%
    GuiControl,, keyMP50, %keyMP50%
    GuiControl,, keyMP30, %keyMP30%
    GuiControl,, keyMP10, %keyMP10%
    GuiControl,, keyHaste, %keyHaste%
	
	GuiControl,, keyMagicHotkey1, %keyMagicHotkey1%
	GuiControl,, keyMagicHotkey2, %keyMagicHotkey2%
	GuiControl,, keyMagicHotkey3, %keyMagicHotkey3%
	
	GuiControl,, keyUtito, %keyUtito%
}

;=====================================================================
; Salva as configurações no arquivo config.ini
;=====================================================================

SaveSettings() {
	global
    GuiControlGet, chkAutoHeal,, chkAutoHeal
    GuiControlGet, chkAutoMana,, chkAutoMana
    GuiControlGet, chkAutoHaste,, chkAutoHaste
    GuiControlGet, chkAutoUseSpells,, chkAutoUseSpells
	GuiControlGet, chkAutoUseUtito,, chkAutoUseUtito

    IniWrite, %chkAutoHeal%, %configFile%, Settings, AutoHeal
    IniWrite, %chkAutoMana%, %configFile%, Settings, AutoMana
    IniWrite, %chkAutoHaste%, %configFile%, Settings, AutoHaste
    IniWrite, %chkAutoUseSpells%, %configFile%, Settings, AutoSpells
	IniWrite, %chkAutoUseUtito%, %configFile%, Settings, AutoUseUtito

    GuiControlGet, keyHP50,, keyHP50
    GuiControlGet, keyHP80,, keyHP80
    GuiControlGet, keyHP90,, keyHP90
    GuiControlGet, keyMP50,, keyMP50
    GuiControlGet, keyMP30,, keyMP30
    GuiControlGet, keyMP10,, keyMP10
    GuiControlGet, keyHaste,, keyHaste

	GuiControlGet, keyMagicHotkey1,, keyMagicHotkey1
	GuiControlGet, keyMagicHotkey2,, keyMagicHotkey2
	GuiControlGet, keyMagicHotkey3,, keyMagicHotkey3
	
	GuiControlGet, keyUtito,, keyUtito

    IniWrite, %keyHP50%, %configFile%, Keys, HP50
    IniWrite, %keyHP80%, %configFile%, Keys, HP80
    IniWrite, %keyHP90%, %configFile%, Keys, HP90
    IniWrite, %keyMP50%, %configFile%, Keys, MP50
    IniWrite, %keyMP30%, %configFile%, Keys, MP30
    IniWrite, %keyMP10%, %configFile%, Keys, MP10
    IniWrite, %keyHaste%, %configFile%, Keys, Haste
	
    IniWrite, %keyMagicHotkey1%, %configFile%, Keys, MagicHotkey1
	IniWrite, %keyMagicHotkey2%, %configFile%, Keys, MagicHotkey2
	IniWrite, %keyMagicHotkey3%, %configFile%, Keys, MagicHotkey3
	
	IniWrite, %keyUtito%, %configFile%, Keys, Utito
}

GuiClose:
    SaveSettings()
    ExitApp

Pause:: ; Tecla "Pause" do teclado
    running := !running
    Gui, Color, % (running ? "Green" : "Red")
	; Chama a label de acordo com o estado da variável 'running'
    if (running) {
        Goto, StartMacro
    } else {
        Goto, StopMacro
    }
    return