; ✅ Add an error of fileDelete fails 10 tims.

; 💫 UPDATE | Part 2 of 3 💫
; 🚩 Startup
;@Ahk2Exe-SetMainIcon Calculator.ico
#Requires AutoHotkey >=2.0
#Singleinstance force
#Hotstring C1
#NoTrayIcon
CoordMode "Mouse", "Screen" ; Old code, may not work.

DetectHiddenWindows(true)
SetTitleMatchMode(2)
SetKeyDelay -1 ; Used to speed up SENDRAW, affects other types of SEND (old code, may not work)

; 🔸 GUI | Progress bar create
MyGui := Gui()
MyGui.Add("Progress", "w400 h40 cff6600 vMyProgress", 01)
MyGui.SetFont("s20 w500", "Arial") ; Sets GUI font from this point on.
MyGui.Add("Text", "w400 h40 Center", "Updating...")
MyGui.Opt("+AlwaysOnTop -Caption") 

MyGui.Show
    MyGui["MyProgress"].Value := 20

; ⭐ Kill calculator
    Run '"Calculator.exe" "/ExitApp"' ; Runs code inside calculator.exe that performs EXITAPP
   ; Sleep 500 ; This is here as FileDelete was failing because calculator.exe wasn't deleting fast enough. This can be deleted when  a futre looped check is added.
    ; SoundBeep 999

 ;⭐ Delete old version (to allow replacement Calculator.exe to download & not be rejected by existing locked Calculator.exe)
    lbl_delete_old_version:
        MyGui["MyProgress"].Value := 40
        Sleep 500
        MyGui["MyProgress"].Value := 60
        Sleep 500
        MyGui["MyProgress"].Value := 80
        Sleep 500 ; CHANGE THIS TO SOME SORT OF LOOP CHECK SO FILE DELETES WHEN ITS NOT LOCKED - THE LOOP CHECK IS FOR CHECKING THE LOCK STATUS. Time needed to allow Calculator EXE to shut down. FILEDELETE on the next line executes too soon & causes a file access error resulting in Calculator.exe not deleting & the script stopping.
        FileDelete "calculator.exe"
        Sleep 250
        If FileExist("calculator.exe") ; Keeps looping if FILEDELETE fails. Previous tests show some time needs to pass for calculator.exe to delete.
            {
                Goto lbl_delete_old_version
            }
            Else

; ⭐ Download new version
   ; func_update_progress_bar(60)
    Download "https://github.com/ozzynotwood/TA/releases/download/ta/Calculator.exe", "Calculator.exe"
   ; func_update_progress_bar(80)

; ⭐ Check to see if Calculator.exe has downloaded.
    lbl_download_status: ; Infiniate loop until new calculator.exe exists.
        If !FileExist("calculator.exe")
            {
                Goto lbl_download_status
            }
            Else

; ⭐ Run new version
    MyGui["MyProgress"].Value := 100
    Sleep 200
    MyGui.Destroy
    MsgBox "Application updated! Click OK to run.", "Notification", 64
    Run "Calculator.exe"

    ExitApp ; Calculator.exe will delete update.exe as part of Calculator.exe's startup.

; ⭐⭐⭐ UPDATE | COMPLETE! ⭐⭐⭐