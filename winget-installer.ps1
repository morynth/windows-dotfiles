## Obsidian plugins 
# Dateview,Advanced Tables,Calendar,Iconize Editor Syntax Highlight Emoji Toolbar,Paste URL into selection,Editing Toolbar,Obsidian Memos Easy Typing

# system information viewers
# TopalaSoftwareSolutions.SIW  winaudit REALiX.HWiNFO AIDA64

# install scoop
irm get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -ScoopDir 'O:\admin\app-managers\scoop' -ScoopGlobalDir 'O:\admin\app-managers\global-scoop'
https://github.com/ScoopInstaller/scoop/wiki/Using-Scoop-behind-a-proxy
scoop config proxy 127.0.0.1:7890

scoop bucket add extras

scoop install ventoy nekoray office-tool-plus pandoc bulk-crap-uninstaller ghostscript scrcpy locale-emulator -g

scoop install posh-git
Add-PoshGitToProfile



