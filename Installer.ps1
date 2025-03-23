#  ██████╗ ██╗ ██████╗███████╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗
#  ██╔══██╗██║██╔════╝██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
#  ██████╔╝██║██║     █████╗      ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
#  ██╔══██╗██║██║     ██╔══╝      ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
#  ██║  ██║██║╚██████╗███████╗    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
#  ╚═╝  ╚═╝╚═╝ ╚═════╝╚══════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
#
#	Author	-	molin
#	Repo	-	
#	Date	-	2025-03-16 08:45:07
#
#	Installer - Script to install my dotfiles
#

# Global vars
$ERROR_LOG = Join-Path -Path $HOME -ChildPath "InstallError.log"
$backup_folder = Join-Path -Path $HOME -ChildPath "DotBackup"
# 获取当前脚本所在的目录路径（规范化处理）
$scriptPath = $PSScriptRoot
$global:try_firefox = $null

$pwsh_profile = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$windows_powershell_profile = "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# function instal_winget {

#     Clear-Host
#     logo "Add molin custom repo"
#     $repo_name="molin-dotfiles"
#     Start-Sleep 2

#     # Check if the repository already exists
#     Write-Host "Installing ${repo_name} repository..."
#     if (condition) {
#         <# Action to perform if the condition is true #>
#     }
    
# }

function switch_ustc_mirrors {

    winget source remove winget
    winget source add winget https://mirrors.ustc.edu.cn/winget-source --trust-level trusted
    
}

# Logo 显示函数
function logo {
    
    # [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] : $args"

    $logEntry | Out-File $ERROR_LOG -Encoding utf8 -Append
    Write-Host $args -ForegroundColor Yellow
}

# 错误日志处理函数
function logo_error {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] ERROR: $args"

    # 写入日志文件
    $logEntry | Out-File $ERROR_LOG -Encoding utf8 -Append

    # 控制台彩色输出
    Write-Host "ERROR: $args" -ForegroundColor Red
}

function welcome {

    Clear-Host
    logo "welcome $env:USERNAME"
    Write-Host "This script will install my dotfiles and this is what it will do:
        [i] 2 repositories will be installed. gh0stzk-dotfiles and Chaotic-Aur
        [i] Check necessary dependencies and install them
        [i] Download my dotfiles in ${HOME}/dotfiles
        [i] Backup of possible existing configurations (bspwm, polybar, etc...)
        [i] Install my configuration
        [i] Enabling MPD service (Music player daemon)
        [i] Change your shell to zsh shell

        [!] My dotfiles DO NOT modify any of your system configurations
        [!] This script does NOT have the potential power to break your system

    " 

    while ($true) {
        Write-Host "Do you wish to continue? [y/N]: "-NoNewline -ForegroundColor Red
        $yn = Read-Host

        switch -Regex ($yn.Trim().ToLower()) {
            '^(y|yes)$' { 
                return
            }
            '^(n|no)?$' {
                Write-Host "Operation cancelled" -ForegroundColor Yellow
                exit 1  # 退出脚本
            }
            default {
                Write-Host "Error: Just write 'y' or 'n'" -ForegroundColor Yellow
            }
        }
    }

}

function initial_checks {

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "The script must be executed for admin"
        exit 1
    }

    if ($scriptPath -ne $HOME) {
        Write-Host "The script must be executed from HOME directory. " -ForegroundColor Red -NoNewline
        exit 1
    }

    if (-not (Test-Connection -TargetName 8.8.8.8 -Quiet) ) {
        Write-Host "No internet connection detected." -ForegroundColor Red
        exit 1
    }

    $TargetDrive = "O:"
    if (-not (Test-Path $TargetDrive)) {
        Write-Host "Software Disk $TargetDrive not found" -ForegroundColor Red
        exit 1
    }


}

function add_env {
    $envVariables = @(
        @{ name = "GLAZEWM_CONFIG_PATH"; value = "$HOME\.config\glazewm\glazewm.yaml"; scope = "Machine" }
        @{ name = "ChocolateyInstall"; value = "O:\admin\app_managers\chocolatey"; scope = "Machine" }
        @{ name = "ChocolateyToolsLocation"; value = "O:\admin\app_managers\chocolatey\tools"; scope = "Machine" }
    )
    
    foreach ($var in $envVariables) {
        try {
            $targetScope = [System.EnvironmentVariableTarget]::$($var.Scope)
            [System.Environment]::SetEnvironmentVariable($var.name, $var.value, $targetScope)
            Write-Host "Set [$($var.scope)] env variable succeed: $($var.name)=$($var.value)"
        }
        catch {
            $msg = "Failed to set $($var) variables"
            Write-Error $msg
            logo_error $msg
        }
    }
    Write-Host "Please restart Shell" -ForegroundColor Red
}

function install_dependencies {
    Clear-Host
    logo "Installing needed packages.."
    Start-Sleep 2

    $soft_disk = "O:"
    $util = Join-Path -Path $soft_disk -ChildPath "utils"
    $desktop = Join-Path -Path $soft_disk -ChildPath "desktop"
    $coding = Join-Path -Path $soft_disk -ChildPath "coding"
    $doc = Join-Path -Path $soft_disk -ChildPath "docs"
    $admin = Join-Path -Path $soft_disk -ChildPath "admin"
    $net = Join-Path -Path $soft_disk -ChildPath "net"
    $media = Join-Path -Path $soft_disk -ChildPath "media"
    $secu = Join-Path -Path $soft_disk -ChildPath "secu"
    $game = Join-Path -Path $soft_disk -ChildPath "games"
    # "TARGETDIR" "INSTALL_ROOT" "DESTINATION" "INSTALLDIR" "APPLICATIONFOLDE" "INSTALLLOCATION"
    $dependices = @(

        # ok
        # @{ name = "yasb"; id = "AmN.yasb"; location = "$desktop\yasb"; scope = "none"}
        # @{ name = "Espanso"; id = "Espanso.Espanso"; location = "$util\suites\espanso"; scope = "user"}
        # @{ name = "qBittorrent-Enhanced-Edition"; id = "c0re100.qBittorrent-Enhanced-Edition"; custom = "/D=$net\file-sharing\qbittorrent";}
        # @{ name = "JetBrainsMonoNerdFont"; id = "DEVCOM.JetBrainsMonoNerdFont"; scope = "user"}
        
        # @{ name = "7zip"; id = "7zip.7zip"; location = "$util\file\7zip";}
        # @{ name = "winrar"; id = "RARLab.WinRAR"; location = "$util\file\winrar";}
        # @{ name = "VSCodium"; id = "VSCodium.VSCodium"; location = "$doc\editors\vscodium";}
        # @{ name = "firefox"; id = "Mozilla.Firefox"; location = "$net\browsers\firefox";}
        # @{ name = "zeal"; id = "OlegShparber.Zeal"; custom = "INSTALL_ROOT=$coding\doc\zeal";}
        # @{ name = "Flameshot"; id = "Flameshot.Flameshot"; custom = "INSTALL_ROOT=$util\ime\flameshot"; }

        # @{ name = "Neovim"; id = "Neovim.Neovim"; custom = "INSTALL_ROOT=$doc\editors\neovim"}
        # @{ name = "Gpg4win"; id = "GnuPG.Gpg4win"; location = "O:\secu\gpg4win"}
        # @{ name = "Keepassxc"; id = "KeePassXCTeam.KeePassXC"; custom = "INSTALL_ROOT=$secu\passwd\keepassxc";}
        # @{ name = "crystalDiskInfo"; id = "CrystalDewWorld.CrystalDiskInfo.AoiEdition"; location = "$admin\disk\crystal-disk-info"; }
        # @{ name = "drawio"; id = "JGraph.Draw"; location = "$doc\editors\drwaio"; }
        # @{ name = "fluent-reader"; id = "yang991178.fluent-reader"; location = "$doc\office\fluent-reader";}
        # @{ name = "obsidian"; id = "Obsidian.Obsidian"; location = "$doc\editors\obsidian";}
        # @{ name = "thunderbird"; id = "Mozilla.Thunderbird.zh-CN"; location = "$net\comm\thunderbird"; }
        # @{ name = "calibre"; id = "calibre.calibre"; location = "$doc\ebooks\calibre"; }
        # @{ name = "picard"; id = "MusicBrainz.Picard"; location = "$media\audio\picard"; }
        # @{ name = "obs-studio"; id = "OBSProject.OBSStudio"; location = "$media\video\obs-studio"; }
        # @{ name = "yac-reader"; id = "YACReader.YACReader"; location = "$media\graphics\yac-reader"; }
        # @{ name = "digiKam"; id = "KDE.digiKam"; location = "$media\graphics\digikam"; }
        # @{ name = "ImageMagick"; id = "ImageMagick.ImageMagick"; location = "$media\graphics\image-magick"; }
        # @{ name = "Steam"; id = "Valve.Steam"; custom = "/D=$game\platforms\steam"; }
        # @{ name = "Playnite"; id = "Playnite.Playnite"; location = "$game\manager\playnite"; scope = "user"}
        # @{  name = "android-studio";
        #     id = "Google.AndroidStudio";
        #     custom = """/S /LOG=$coding\ides\android-studio\install.log /CONFIG=$HOME\dotfiles\misc\jetbrains\silent.config /D=$coding\ides\android-studio"""
        #     install_mode = "n"
        # }
        @{  name         = "idea-ic";
            id           = "JetBrains.IntelliJIDEA.Community";
            custom       = """/S /LOG=$coding\ides\idea-ic\install.log /CONFIG=$HOME\dotfiles\misc\jetbrains\silent.config /D=$coding\ides\idea-ic"""; 
            install_mode = "n"
        }
        @{  name         = "pycharm-pc";
            id           = "JetBrains.PyCharm.Community";
            custom       = """/S /LOG=$coding\ides\pycharm\install.log /CONFIG=$HOME\dotfiles\misc\jetbrains\silent.config /D=$coding\ides\pycharm"""
            install_mode = "n"
        }


        # not perfect,need interactive
        # @{ name = "NVM"; id = "CoreyButler.NVMforWindows"; location = "$coding\vcs\nvm"; scope = "user"; install_mode = "i";}
        # @{ name = "KDEConnect"; id = "KDE.KDEConnect"; custom = "/D=$net\file-sharing\sync\kde-connect"; install_mode = "i";}
        # @{ name = "WindowsSDK"; id = "Microsoft.WindowsSDK.10.0.18362"; install_mode = "i";}
        # @{ name = "Weasel"; id = "Rime.Weasel"; custom = "INSTALL_ROOT=$util\ime\weasel"; install_mode = "i";}
        # @{ name = "PowerShell"; id = "Microsoft.PowerShell"; custom = "TARGETDIR=$util\shells\pwsh"; install_mode = "i";}
        # @{ name = "Powertoys"; id = "Microsoft.PowerToys"; custom = "TARGETDIR=$util\suites\powertoys";}
        # @{ name = "glazewm"; id = "glzr-io.glazewm"; location = "$desktop\glazewm"; install_mode = "i";}
        # @{ name = "qq"; id = "Tencent.QQ.NT"; location = "$net\comm\qq"; install_mode = "i";}
        # @{ name = "wechat"; id = "Tencent.WeChat"; location = "$net\comm\wechat"; install_mode = "i";}
        # @{ name = "potplayer"; id = "Daum.PotPlayer"; custom = "/D=$media\video\potplayer"; install_mode = "i";}
        # @{ name = "python"; id = "Python.Python.3.12"; location = "$coding\sdks\python"; install_mode = "i";}
        # @{ name = "deployment-toolkit"; id = "Microsoft.DeploymentToolkit"; custom = "TARGETDIR=$coding\builds\windows-deploy-toolkit"; install_mode = "i";}

        
        # not support 'install location'
        # @{ name = "ungoogled-chromium"; id = "eloston.ungoogled-chromium";}
        # @{ name = "Dotnet8"; id = "Microsoft.DotNet.SDK.8"; scope = "none"}
        # @{ name = "Autohotkey"; id = "AutoHotkey.AutoHotkey";}
        # @{ name = "OhMyPosh"; id = "JanDeDobbeleer.OhMyPosh";}
        # @{ name = "WindowsTerminal"; id = "Microsoft.WindowsTerminal";}
        # @{ name = "ffmpeg"; id = "Gyan.FFmpeg"; location = "$media\graphics\ffmpeg";}
        
        # optional if you uninstall edge,maybe need install Microsoft.EdgeWebView2Runtime

    )

    function is_installed {
        param (
            [string]$id
        )
        winget list -e --id $id *> $ERROR_LOG
        return $LASTEXITCODE -eq 0
    }

    Write-Host "Checking for required packages..." -ForegroundColor Blue
    Start-Sleep 2

    # Detet missing packages
    $missing_pkgs = @()
    foreach ($pkg in $dependices) {
        try {
            if (is_installed $pkg.id) {
                Write-Host "[1] [$($pkg.name)] already install" -ForegroundColor Yellow
                continue
            }
            else {
                $missing_pkgs += $pkg
                Write-Host "[0] [$($pkg.name)] not install" -ForegroundColor Red
            }
        
        }
        catch {
            $errormsg = "Detece $($pkg.DisplayName) error: $_"
            Write-Host  $errormsg -ForegroundColor Red
            logo_error $errormsg
            $missing_pkgs += $pkg
        }
        
    }

    # Batch installation
    if ($missing_pkgs.Count -gt 0) {
        Write-Host "Installing $($missing_pkgs.Count) missing packages..."
        $failed_install = @()
        foreach ($pkg in $missing_pkgs) {
            try {
                $wingetArgs = @(
                    "install",
                    "-e",
                    "--id", $pkg.id
                )

                if ($pkg.install_mode) { 
                    switch ($pkg.install_mode) {
                        "i" {
                            $wingetArgs += "-i" 
                        }
                        "h" {
                            $wingetArgs += "-h"
                        }
                        "n" {
                            # some pkg need custom,such as jetbrains
                        }
                    }
                }
                else {
                    # 默认静默安装
                    $wingetArgs += "-h"
                }
                if ($pkg.location) { $wingetArgs += @("-l", "`"$($pkg.location)`"") }

                if ($pkg.scope) { 
                    switch ($pkg.scope) {
                        "machine" {
                            $wingetArgs += @("--scope", "machine") 
                        }
                        "user" {
                            $wingetArgs += @("--scope", "user") 
                        }
                        default {
                            # not support scope(user and machine)
                        }
                    }
                }
                else {
                    # 默认全局安装
                    $wingetArgs += @("--scope", "machine") 
                }
    
                if ($pkg.custom) { 
                    $wingetArgs += @("--custom", $pkg.custom) 
                }
                Write-Host "winget $wingetArgs"
            
                Write-Host "Installing [$($pkg.name)]" -ForegroundColor Cyan
                # winget $install_cmd
                # Invoke-Expression $install_cmd
                Start-Process "winget" -ArgumentList $wingetArgs -Wait -NoNewWindow | Out-Null

            }
            catch {
                $failed_install += $pkg
                logo_error -Message "$($pkg.name) install failed,error message: $($_.Exception.Message)"
            }

        }
 
    }
    Start-Sleep 3

}

function clone_dotfiles {
    Clear-Host
    logo "Downloading dotfiles"
    $repo_url = "https://github.com/morynth/windows-dotfiles"
    $repo_dir = Join-Path -Path $HOME -ChildPath "dotfiles"
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Start-Sleep 2

    # Handle existing repository
    if (Test-Path -Path $repo_dir -PathType Container) {
        $backup_dir = "${repo_dir}" + "_" + "${timestamp}"
        Write-Host "Existing repository found - renaming to: ${backup_dir}"
    
        try {
            Move-Item -Path $repo_dir -Destination $backup_dir -ErrorAction Stop
            
        }
        catch {
            Write-Host "ERROR: - $($_.Exception.Message)"
            Write-Host "Renaming failed! CheckInstallError.log"
            exit 1
        }
        Write-Host "Repository successfully renamed for backup"

    }

    # Clone new repository
    Write-Host "Cloning dotfiles from: ${repo_url}"
    
    git clone --depth 1 "$repo_url" "$repo_dir" *>> $ERROR_LOG
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Dotfiles cloned successfully!"
    }
    else {
        logo_error "Repository clone failed"
        Write-Host "Clone failed! Check RiceError.log"
        exit 1
    }
    Start-Sleep 2

}

function backup_existing_config {
    Clear-Host
    logo "Backup files"
    $date = Get-Date -Format "yyyyMMdd-HHmmss"
    do {
        $answer = Read-Host "Do you want to use my Firefox theme setup? [y/N]"
        $cleanAnswer = $answer.Trim().ToLower()
        switch ($cleanAnswer) {
            'y' { 
                $global:try_firefox = 'y'
                break
            }
            'n' { 
                $global:try_firefox = 'n'
                break
            }
            default {
                Write-Host " Error: write 'y' or 'n'"
                continue
            }
        }
    } while ($cleanAnswer -notin 'y', 'n')

    New-Item -Path $backup_folder -ItemType Directory -Force *> $ERROR_LOG
    Write-Host "Backup directory: $backup_folder"

    Start-Sleep 1

    function backup_item {
        param(
            [string]$source,
            [string]$target,
            [string]$type
        )
        $base_name = $target
        $dst = Join-Path -Path $backup_folder -ChildPath "${target}_${date}"
        if (Test-Path $source -PathType $type) {
            Move-Item -Path $source -Destination $dst -ErrorAction Stop *> $ERROR_LOG
            if ($?) {
                Write-Host "${base_name} backup successful" -ForegroundColor Green
            }
            else {
                logo_error "Error bakcup: ${base_name}"
                Write-Host "${base_name} backup failed" -ForegroundColor Red
            }
            Start-Sleep 1
            
        }
        else {
            Write-Host "${base_name} not found"
            Start-Sleep 1
        }

    }

    # Backup of main configurations
    $config_folders = @("autohotkey", "glazewm", "yasb")
    foreach ($item in $config_folders) {
        $item_path = Join-Path $HOME (Join-Path ".config" $item)
        backup_item $item_path $item Container
    }

    # Firefox management
    if ($global:try_firefox -eq "y") {
        $profiles_dir = "$env:APPDATA\Mozilla\Firefox\Profiles"
        $firefox_profile = Join-Path $profiles_dir (Get-ChildItem -Path $profiles_dir -Directory -Filter "*.default-release")
        # Backup of Firefox components
        if (Test-Path -Path $firefox_profile) {
            backup_item "${firefox_profile}\chrome" "chrome" Container
            backup_item "${firefox_profile}\user.js" "user.js" Leaf
        }
        else {
            Write-Host "Firefox profile not found, please start firefox." -ForegroundColor Yellow
        }
    }

    # Backup of individual files
    $single_files = @(
        @{ name = "Microsoft.PowerShell_profile(internally).ps1"; path = $windows_powershell_profile; type = "Leaf"}
        @{ name = "Microsoft.PowerShell_profile.ps1"; path = $pwsh_profile; type = "Leaf"}
        @{ name = "espanso"; path = "$env:AppData\espanso"; type = "Container"}
        @{ name = "winterminal-settings.json"; path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"; type = "Leaf"}
    )
    foreach ($item in $single_files) {
        backup_item $item.path $item.name $item.type
    }

    Write-Host "Backup completed" -ForegroundColor Green
    Start-Sleep 3

}

function install_dotfiles {
    Clear-Host
    logo "Installing dotfiles..."

    Write-Host "Copying files to respective directories..." -ForegroundColor Blue
    Start-Sleep 2

    # Create required directories
    $required_dirs = @(
        "$HOME\.config",
        "$HOME\.local\share",
        "$HOME\Documents\PowerShell",
        "$HOME\Documents\WindowsPowerShell",
        "$env:APPDATA\espanso",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    )
    foreach ($item in $required_dirs) {
        if (-not (Test-Path -Path $item -PathType Container) ) {
            New-Item -Path $item -ItemType Directory *> $ERROR_LOG
            Write-Host "Created directory: $item" -ForegroundColor Green
        }
    }

    # Generic funtion to copy files
    function copy_files {
        param (
            [string]$name,
            [string]$source,
            [string]$target
        )

        Copy-Item -Path $source -Destination $target -Recurse -Force *>> $ERROR_LOG 
        if ($?) {
            Write-Host "${name} copied successfully!" -ForegroundColor Yellow
        }
        else {
            logo_error "Failed to copy: ${name}"
            Write-Host "${name} copy failed!" -ForegroundColor Yellow
            exit 1
        }

    }

    # Copy main settings
    $config_source = Get-ChildItem -Path "$HOME\dotfiles\config" -Directory | Select-Object -ExpandProperty FullName
    foreach ($item in $config_source) {
        $name = Split-Path $item -Leaf
        copy_files $name $item "$HOME\.config"
        Start-Sleep 0.3
    }

    # Copy miscellaneous components and remaining files
    $home_files = @(
        @{name = "startup-page"; source = "$HOME\dotfiles\misc\startup-page"; target = "$HOME\.local\share"}
        @{name = "windows-powershell"; source = "$HOME\dotfiles\home\Microsoft.PowerShell_profile.ps1"; target = $pwsh_profile}
        @{name = "windows-powershell(internally)"; source = "$HOME\dotfiles\home\Microsoft.PowerShell_profile.ps1"; target = $windows_powershell_profile}
        @{name = "espanso";
        source = Get-ChildItem -Path "$HOME\dotfiles\home\espanso" -Directory | Select-Object -ExpandProperty FullName;
        target = "$env:APPDATA\espanso";
        type = "Container"
    }
        @{name = "windows-terminal"; source = "$HOME\dotfiles\home\windows-terminal\settings.json"; target = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"}
    )
    foreach ($item in $home_files) {
        if ($item.type -eq "Container") {
            foreach ($single in $item.source) {
                $child_name = Join-Path $item.name (Split-Path $single -Leaf)
                copy_files $child_name $single $item.target
            }
        }else{
            copy_files $item.name $item.source $item.target
        }
        Start-Sleep 1
    }

    # Handle Firefox theme
    if ($global:try_firefox -eq "y") {
        $profiles_dir = "$env:APPDATA\Mozilla\Firefox\Profiles"
        $firefox_profile = Join-Path $profiles_dir (Get-ChildItem -Path $profiles_dir -Directory -Filter "*.default-release")
        $firefox_source = Get-ChildItem -Path "$HOME\dotfiles\misc\firefox" | Select-Object -ExpandProperty FullName
        # Copy content from firefox/
        if (Test-Path -Path $firefox_profile -PathType Container) {
            foreach ($item in $firefox_source) {
                $name = Split-Path $item -Leaf
                $target = $firefox_profile
                copy_files $name $item $target
            }

        }
        # Update settings
    }
    Write-Host "Dotfiles installed successfully!" -ForegroundColor Green
    Start-Sleep 3

}


function configure_startup {
    Clear-Host
    logo "Configuring Startup"
    Start-Sleep 2
    function create_shortcut {
        param (
            # 文件路径
            [string]$source
        )
        # 启动目录
        $startupDir = [Environment]::GetFolderPath([Environment+SpecialFolder]::Startup)

        if (-not (Test-Path $source -PathType Leaf)) {
            Write-Host "$item not found"
            exit 1
        }
        # 启动文件
        $filename = [System.IO.Path]::GetFileNameWithoutExtension($item)
        $shortcut_file = (Join-Path $startupDir $filename) + ".lnk"

        # 创建lnk快捷方式
        New-Item -ItemType SymbolicLink -Path $shortcut_file -Target $item *> $ERROR_LOG

        # $WScriptShell = New-Object -ComObject WScript.Shell
        # $shortcut = $WScriptShell.Createshortcut($shortcut_file)
        # $shortcut.TargetPath = $item
        # $shortcut.Save()
        Write-Host "$filename shortcurt enabled successfully!"
        
    }

    # Autohotkey shortcut
    $hotkeys = Get-ChildItem -Path "$HOME\.config\autohotkey" -File -Filter "*.ahk" | Select-Object -ExpandProperty FullName
    foreach ($item in $hotkeys) {
        create_shortcut $hotkeys
    }

    Start-Sleep 3

}


initial_checks
welcome

install_dependencies
clone_dotfiles

backup_existing_config
install_dotfiles
configure_startup