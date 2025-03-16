Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm

# 1. set env
$username = $env:USERNAME
$app_driver = "O:"
$home_driver = "H:"
$game_driver = "G:"
$my_profile = "$home_driver\$env:USERNAME"
Write-Host 'Add env vars'

$addEnvs = @(
    @{ name="MyApp";value = "$app_driver"},
    @{ name="MyProfile";value = "$my_profile"},
    @{ name="Admin";value = "$app_driver\admin"},
    @{ name="Internet";value = "$app_driver\internet"},
    @{ name="Docs";value = "$app_driver\documents"},
    @{ name="Security";value = "$app_driver\security"},
    @{ name="Multimedia";value = "$app_driver\multimedia"},
    @{ name="Utilities";value = "$app_driver\utilities"},
    @{ name="Coding";value = "$app_driver\coding"},
    @{ name="Games";value = "$app_driver\games"}
    @{ name="Desktop";value = "$app_driver\desktop"}
    # TODO 添加adb到path变量中

)

foreach ($env in $addEnvs) {
    $varname = $env.name
    $value = $env.value
    [System.Environment]::SetEnvironmentVariable($varname, $value, [System.EnvironmentVariableTarget]::User)

    $userVariable = [System.Environment]::GetEnvironmentVariable($varname, [System.EnvironmentVariableTarget]::User)
    Write-Host "add user env key:" $varname ",value:$userVariable"
}

Write-Host "create user dirs"
$softwareFolderNames = @(
    @{ driver = "$app_driver"; dir = "\internet\proxy"},
    @{ driver = "$my_profile"; dir = "\Coding"},
    @{ driver = "$my_profile"; dir = "\.local\share"},
    @{ driver = "$game_driver"; dir = "\card"},
    @{ driver = "$game_driver"; dir = "\role-play"}
)

ForEach ($item in $softwareFolderNames) {
    New-Item -ItemType Directory -Path "$($item.driver)$($item.dir)" -Force
}


$hotkey_path = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\hotkey.lnk"

if (!(Test-Path -Path $hotkey_path)) {
    $TargetFile = "$env:USERPROFILE\.config\autohotkey\hotkey.ahk"
    $ShortcutFile = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\hotkey.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
}




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


$packages = @(
    
    @{ name = "jetbrainsmono-nerd-fonts"; id = "DEVCOM.JetBrainsMonoNerdFont"; append = "-eh" },

    # desktop
    # glazewm yasb
    @{ name = "yasb"; id = "AmN.yasb"; append = "-eh" },
    @{ name = "glazewm"; id = "glzr-io.glazewm"; location = "$desktop\glazewm"; append = "-ei --scope machine" },

    # coding
    # @{ name = "python"; id = "Python.Python.3.12"; location = "$coding\sdks\python"; append = "-ei " },
    @{ name = "dotnet8"; id = "Microsoft.DotNet.SDK.8"; location = "$coding\sdks\dotnet8"; append = "-eh" },
    @{ name = "deployment-toolkit"; id = "Microsoft.DeploymentToolkit"; location = "$coding\builds\microsoft\deploy-toolkit"; append = "-ei --scope machine " },
    @{ name = "windows-adk"; id = "Microsoft.WindowsADK"; location = "$coding\builds\microsoft\windows-adk"; append = "-ei " },
    @{ name = "vscodium"; id = "VSCodium.VSCodium"; location = "$docs\editors\vscodium"; append = "-ei --scope machine " },
    @{ name = "neovim"; id = "Neovim.Neovim"; location = "$docs\editors\neovim"; append = "--scope machine --custom ""/qb INSTALL_ROOT=$docs\editors\neovim"" " },
    @{ name = "nvm"; id = "CoreyButler.NVMforWindows"; location = "$coding\vcs\nvm"; append = "-ei" },
    @{ name = "zeal"; id = "OlegShparber.Zeal"; location = "$coding\doc-browsers\zeal"; append = "-ei"},
    @{ name = "android-studio"; id = "Google.AndroidStudio"; location = "$coding\ides\android-studio"; append = "-ei --scope machine"},
    @{ name = "idea-ic"; id = "JetBrains.IntelliJIDEA.Community"; location = "$coding\ides\idea-ic"; append = "-e --custom '/S /CONFIG=$env:USERPROFILE\Scripts\installer\silent.config'"},
    @{ name = "pycharm-pc"; id = "JetBrains.PyCharm.Community"; location = "$coding\ides\pycharm-pc"; append = "-e --custom '/S /CONFIG=$env:USERPROFILE\Scripts\installer\silent.config'"},
    @{ name = "beekeeper-studio"; id = "beekeeper-studio.beekeeper-studio"; location = "$coding\ides\beekeeper-studio"; append = "-ei --scope machine "},

    # oh-my-posh theme:spaceship,json,star,tokyonight_storm,zash
    # utilities
    @{ name = "winrar"; id = "RARLab.WinRAR"; location = "$utilities\file\winrar"; append = "-ei  --scope machine " },
    @{ name = "windows-terminal"; id = "Microsoft.WindowsTerminal"; location = "$coding\utilities\windows-terminal"; append = "-ei " },
    @{ name = "oh-my-posh"; id = "JanDeDobbeleer.OhMyPosh"; location = "$coding\utilities\shells\oh-my-posh-theme"; append = "-ei " },
    @{ name = "pwsh"; id = "Microsoft.PowerShell"; location = "$coding\utilities\shells\pwsh"; append = "-ei --scope machine " },
    # @{ name = "espanso"; id = "Espanso.Espanso"; location = "$utilities\suites\espanso"; append = "-ei " },
    @{ name = "weasel"; id = "Rime.Weasel"; location = "$utilities\ime\weasel"; append = "-ei " },
    @{ name = "powertoys"; id = "Microsoft.PowerToys"; location = "$utilities\suites\powertoys"; append = "-ei --scope machine " },
    @{ name = "autohotkey"; id = "AutoHotkey.AutoHotkey"; location = "$utilities\ime\autohotkey"; append = "-h --scope machine " },
    @{ name = "flameshot"; id = "Flameshot.Flameshot"; location = "$utilities\ime\flameshot"; append = "-h --scope machine " },
    @{ name = "keepassxc"; id = "KeePassXCTeam.KeePassXC"; location = "$security\passwd-managers\keepassxc"; append = "-ei --scope machine " },

    # admin
    # 如果提示win32api，需要按照python与pywin32包
    # https://www.sysnettechsolutions.com/en/fix-python-win32api-virtualbox/
    # py -m pip install pywin32
    # @{ name = "virtualbox"; id = "Oracle.VirtualBox"; location = "$admin\virtual\virtualbox"; append = "-ei --scope machine " },
    @{ name = "crystalDiskInfo"; id = "CrystalDewWorld.CrystalDiskInfo.AoiEdition"; location = "$admin\disk\crystalDiskInfo"; append = "-ei --scope machine " },

    # documents
    
    @{ name = "obsidian"; id = "Obsidian.Obsidian"; location = "$docs\editors\obsidian"; append = "--scope machine " },
    @{ name = "goldendict"; id = "GoldenDict.GoldenDict"; location = "$docs\languages\goldendict"; append = "-h " },
    @{ name = "calibre"; id = "calibre.calibre"; location = "$docs\e-books\calibre"; append = "-ei --scope machine " },
    @{ name = "drawio"; id = "JGraph.Draw"; location = "$docs\editors\drwaio"; append = "-ei --scope machine " },
    @{ name = "fluent-reader"; id = "yang991178.fluent-reader"; location = "$docs\office\fluent-reader"; append = "-ei --scope machine " },

    # internet
    @{ name = "kde-connect"; id = "KDE.KDEConnect"; location = "$internet\file-sharing\sync\kde-connect"; append = "-ei" },
    @{ name = "mremoteng"; id = "mRemoteNG.mRemoteNG"; location = "$internet\remote-clients\mremoteng"; append = "-ei --scope machine" },
    @{ name = "chromium"; id = "Hibbiki.Chromium"; location = "$internet\browsers\chromium"; append = "-ei --scope machine" },
    @{ name = "firefox"; id = "Mozilla.Firefox"; location = "$internet\browsers\firefox"; append = "-ei --scope machine" },
    @{ name = "thunderbird"; id = "Mozilla.Thunderbird.zh-CN"; location = "$internet\comm\thunderbird"; append = "-ei --scope machine" },

    
    # plugins:powerful pixiv downloader ,DeepL,xBrowserSync,DuckDuckGo Privacy Essentials,KeePassXC-Browser
    # 配合https://github.com/XIU2/TrackersListCollection
    @{ name = "qbittorrent"; id = "c0re100.qBittorrent-Enhanced-Edition"; location = "$internet\file-sharing\bittorrents\qbittorrent"; append = "-ei --scope machine" },
    @{ name = "wechat"; id = "Tencent.WeChat"; location = "$internet\comm\im\wechat"; append = "-ei --scope machine" },
    @{ name = "qq"; id = "Tencent.QQ.NT"; location = "$internet\comm\im\qq"; append = "-ei --scope machine" },
    @{ name = "telegram"; id = "Telegram.TelegramDesktop"; location = "$internet\comm\telegram"; append = "-ei --scope machine" },

    # multimedia
    @{ name = "potplayer"; id = "Daum.PotPlayer"; location = "$multimedia\video\potplayer"; append = "-ei " },
    # @{ name = "bilibili"; id = "Bilibili.Bilibili"; location = "$multimedia\video\bilibili"; append = "-h --scope machine" },
    @{ name = "ffmpeg"; id = "Gyan.FFmpeg"; location = "$multimedia\suites\ffmpeg"; append = "-ei --scope machine" },
    @{ name = "picard"; id = "MusicBrainz.Picard"; location = "$multimedia\audio\picard"; append = "-ei" }
    @{ name = "obs-studio"; id = "OBSProject.OBSStudio"; location = "$multimedia\video\obs-studio"; append = "-ei --scope machine" }
    @{ name = "digikam"; id = "KDE.digikam"; location = "$multimedia\managers\digikam"; append = "-ei --scope machine " }
    @{ name = "yac-reader"; id = "YACReader.YACReader"; location = "$multimedia\managers\yac-reader"; append = "-ei --scope machine" }
    
    # @{ name = "image-magick"; id = "ImageMagick.ImageMagick"; location = "$multimedia\suites\image-magick"; append = "-ei --scope machine" }

    # game
    @{ name = "steam"; id = "Valve.Steam"; location = "$games\platform\steam"; append = "-ei --scope machine " },
    @{ name = "playnite"; id = "Playnite.Playnite"; location = "$games\manager\playnite"; append = "-ei " }


)



foreach ($app in $packages) {
    $search_Result = Invoke-Expression "winget list --id $($app.id)"
    if ($search_Result -like "*$($app.id)*") {
        Write-Host $app.name "already install"
        continue
    }
    $installCmd = "winget install --id $($app.id) -l '$($app.location)' $($app.append)"
    Write-Host $installCmd
    Invoke-Expression $installCmd
}

Invoke-Expression "git config --global user.name $env:USERNAME"
Invoke-Expression "git config --global user.email $env:USERNAME@$env:COMPUTERNAME"
