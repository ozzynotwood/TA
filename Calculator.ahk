;Need code to force AHKv2
; Create warning for app showing default settings will be resotored when reloading.
;@Ahk2Exe-SetMainIcon Calculator.ico
#Requires AutoHotkey >=2.0
#Singleinstance force
#Hotstring C1
#NoTrayIcon
CoordMode "Mouse", "Screen" ; Old code, may not work.
DetectHiddenWindows(true)
SetTitleMatchMode(2)
SetKeyDelay -1 ; Used to speed up SENDRAW, affects other types of SEND. Old code, may not work.

; 🔸 Command Line Parameter | Perform ExitApp
testParameter := false
For arg in A_Args 
    {
        if arg == "/ExitApp" ; if /ExitApp is used as a command line parameter...
            {
                testParameter := true
            }
    }
    if testParameter 
        {
            ExitApp ; ... do this.
        } ; If no command line parameter is used, run script as normal.

; 🔸 Variables
datestamp := FormatTime(, "dd/MM/yy")
timestamp := FormatTime(, "hh:mm:sstt") ; Hours|Minutes|Seconds|AM/PM

; 💫 UPDATE | Part 3 of 3 💫
If FileExist("Update.exe") ; Checks for existance of update.exe. Without this, AHK v2 will throw an error when trying to perform FileDelete. AHK v1 did not throw an error on FileDelete & continued to run the script.
    {
        FileDelete "Update.exe" ;  Part up the update process that can't be run from Update.exe as Update.exe can't delete itself. 
        ;PREVIOUSLY: FileDelete A_ScriptDir "\Update.exe"
    }
; 💫 UPDATE | END 💫

; 🔸 GUI | Progress bar create
MyGui := Gui()
MyGui.Add("Progress", "w400 h40 cff6600 vMyProgress", 01)
MyGui.SetFont("s20 w500", "Arial") ; Sets GUI font from this point on.
MyGui.Add("Text", "w400 h40 Center", "Downloading...")
MyGui.Opt("+AlwaysOnTop -Caption") 

; 🔸 Setup for "about" variable
    If A_Is64bitOS = True
        {
            OS_Achitecture := "64bit"
        }
        Else
            {
                OS_Achitecture := "32bit"
            }

; 🔸 App run confirmation
    Run "calc.exe" ; Windows calculator, path not required for windows app.

; 🔸 Menu
    MainMenu := Menu() ; Thingy that makes the menu work.

; 🔸SubMenu | Email Templates 
    SubMenu_AutoComplete_Words := Menu()
    SubMenu_AutoComplete_Words.Add "TRIGGER `tREPLACEMENT", menu_main_hide_menu
    SubMenu_AutoComplete_Words.Add "Client `tAgency",       menu_main_hide_menu
    SubMenu_AutoComplete_Words.Add "CC `tCase Conference",  menu_main_hide_menu
    SubMenu_AutoComplete_Words.Add "CM `tCase Manager",     menu_main_hide_menu
    SubMenu_AutoComplete_Words.Add "Perm `tPermanent",      menu_main_hide_menu
    SubMenu_AutoComplete_Words.Add "Tism `tAutism",         menu_main_hide_menu

; 🔸 SubMenu | Email Templates 
    SubMenu_email_templates := Menu()
    SubMenu_email_templates.Add "Email Template", menu_main_hide_menu

; 🔸 SubMenu | Settings
    SubMenu_settings := Menu()
    SubMenu_settings.Add "Install Update",                 Menu_submenu_install_update_automatic
    SubMenu_settings.Add "Install Update (manual)",        Menu_submenu_install_update_manual
    SubMenu_settings.Add "Toggle Autocomplete && Hotkeys", Menu_hotkeys_and_hotstrings_toggle
    SubMenu_settings.Check "Toggle Autocomplete && Hotkeys"
    SubMenu_settings.Add ; Add a separator line.
    SubMenu_settings.Add "Reload App",                     menu_SubMenu_reload_app
    SubMenu_settings.Add "About",                          menu_SubMenu_about

; 🔸 Main Menu | Sub Menus
    MainMenu.Add "Auto Complete Words", SubMenu_AutoComplete_Words
    MainMenu.Add "Email Templates",     SubMenu_email_templates

; 🔸 Main Menu
    MainMenu.Add  ; Add a separator line.
    MainMenu.Add "Settings",           SubMenu_settings
    MainMenu.Add  ; Add a separator line.
    MainMenu.Add "Hide Menu",          menu_main_hide_menu
    MainMenu.Add "Shut Down App`tF12", menu_main_shut_down_app

; 🔸 HotKeys
    #SuspendExempt True
    ` & 1::MainMenu.Show
    #SuspendExempt False

    F12::
    menu_main_shut_down_app(Item, *)
        {
            MsgBox "Application Error. The instruction at 0xdf2eac39 referenced memory at 0x00000008. The memory could not be written.", "Error", 16
            ExitApp
        }

; 🔸 Menu | Hotstrings
    :*:CC::Case Conference
    :*:CM::Case Manager
    :*:client::Agency
    :*C:fiance::fiancé
    :*C:Fiance::Fiancé
    :*C:perm::permanent
    :*:tism::Autism
 
; 🔸 Menu | functions
    ; 💫 UPDATE | Part 1 of 3 💫
    Menu_submenu_install_update_automatic(Item, *)
        {
    MyGui := Gui()
    MyGui.Add("Progress", "w400 h40 cff6600 vMyProgress", 01)
    MyGui.SetFont("s20 w500", "Arial") ; Sets GUI font from this point on.
    MyGui.Add("Text", "w400 h40 Center", "Downloading...")

    MyGui.Opt("+AlwaysOnTop -Caption") 

            MyGui.Show
        MyGui["MyProgress"].Value := 20
        Sleep 200
        MyGui["MyProgress"].Value := 40
        Sleep 200
        MyGui["MyProgress"].Value := 60

        Download "https://github.com/ozzynotwood/TA/releases/download/ta/Update.exe", "Update.exe"

        MyGui["MyProgress"].Value := 80
        Sleep 200
        MyGui["MyProgress"].Value := 100
        Sleep 200
        
        lbl_wait_for_update_exe: ; Infiniate loop until new update.exe exists.
            If !FileExist("Update.exe")
                {
                    Goto lbl_wait_for_update_exe
                }
            MyGui["MyProgress"].Value := 100
            MyGui.Destroy
                Run "update.exe" ; ⭐Go to update.ahk for continuatation of update.⭐
        Return
        }

    Menu_submenu_install_update_manual(Item, *)
        {
            Run "https://github.com/ozzynotwood/TA/releases/tag/ta"
        }

    Menu_hotkeys_and_hotstrings_toggle(Item, *)
        {
            If A_IsSuspended = False
            {
                Suspend True
                SubMenu_settings.Uncheck "Toggle Autocomplete && Hotkeys"
                MsgBox "Autocomplete & Hotkeys DISABLED"
            }
            Else
                {
                    Suspend False
                    SubMenu_settings.Check "Toggle Autocomplete && Hotkeys"
                    MsgBox "Autocomplete & Hotkeys ENALBED"
                }
        }

    menu_SubMenu_reload_app(Item, *)
        {
            Result := MsgBox("Default settings will be be restored after re-loading.`n`nDO YOU WANT TO RELOAD?","WARNING", "52")
                If Result = "Yes"
                    Reload
                Else
                    Return
        }

    menu_SubMenu_about(Item, *)
        {
            MsgBox "Version: 8" "`n`nUsername: " A_Username "`n`nSystem Architecture: " OS_Achitecture "`n`nApp Location: " A_ScriptFullPath, "About", 64
        }

    menu_main_hide_menu(Item, *)
        {
            Return
        }