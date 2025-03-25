; ########################
; ----- Applications ----- 
; ########################

; # ----- Main Apps ----- #

; Apps (browser, editor, filemanager)
#enter::Run "wt"

!F2::Run "Taskmgr"
!+b::Run "O:\net\browsers\firefox\firefox.exe"
+e::Run "O:\docs\editors\vscodium\VSCodium"
+f::Run "explorer"

; Terminal apps (musikcube, musicfox)
!+m::Run "pwsh -c musikcube"
!+l::Run "pwsh -c musicfox"

;Reload Keybindings
#Esc::Reload

;show/hide taskbar
#u::WinShow "ahk_class Shell_TrayWnd"
#h::WinHide "ahk_class Shell_TrayWnd"




