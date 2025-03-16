; ########################
; ----- Applications ----- 
; ########################

; # ----- Main Apps ----- #

; Apps (browser, editor, filemanager)
#enter::Run "wt"

!F2::Run "Taskmgr"
!+b::Run "O:\internet\browsers\firefox\firefox.exe"
+e::Run "O:\documents\editors\vscodium\VSCodium"
+f::Run "explorer"

; Terminal apps (yazi, musikcube, musicfox)
!+y::Run "pwsh -c yazi H:\molin\"
+m::Run "pwsh -c musikcube"
+l::Run "pwsh -c musicfox"

; Media apps (Pavucontrol, Telegram, Whatsapp)
+t::Run "telegram"

;Reload Keybindings
#Esc::Reload

;show/hide taskbar
#u::WinShow "ahk_class Shell_TrayWnd"
#h::WinHide "ahk_class Shell_TrayWnd"




