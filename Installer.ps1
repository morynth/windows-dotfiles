#  ██████╗ ██╗ ██████╗███████╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗
#  ██╔══██╗██║██╔════╝██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
#  ██████╔╝██║██║     █████╗      ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
#  ██╔══██╗██║██║     ██╔══╝      ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
#  ██║  ██║██║╚██████╗███████╗    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
#  ╚═╝  ╚═╝╚═╝ ╚═════╝╚══════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
#
#	Author	-	molin
#	Repo	-	https://github.com/morynth/windows-dotfiles
#	Date	-	2025-03-16 08:45:07
#
#	Installer - Script to install my dotfiles
#

# Global vars
$ERROR_LOG = Join-Path -Path $HOME -ChildPath "InstallError.log"
$backup_folder = Join-Path -Path $HOME -ChildPath "DotBackup"

$scriptPath = $PSScriptRoot
$global:try_firefox = $null

$pwsh_profile = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$windows_powershell_profile = "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$profiles_dir = "$env:APPDATA\Mozilla\Firefox\Profiles"


$soft_disk = "O:"
$util = Join-Path -Path $soft_disk -ChildPath "util"
$desktop = Join-Path -Path $soft_disk -ChildPath "desktop"
$coding = Join-Path -Path $soft_disk -ChildPath "coding"
$doc = Join-Path -Path $soft_disk -ChildPath "doc"
$admin = Join-Path -Path $soft_disk -ChildPath "admin"
$net = Join-Path -Path $soft_disk -ChildPath "net"
$media = Join-Path -Path $soft_disk -ChildPath "media"
$secu = Join-Path -Path $soft_disk -ChildPath "secu"
$game = Join-Path -Path $soft_disk -ChildPath "game"
$finance = Join-Path -Path $soft_disk -ChildPath "finance"

function switch_ustc_mirrors {

    winget source remove winget
    winget source add winget https://mirrors.ustc.edu.cn/winget-source --trust-level trusted
    
}

function logo {
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] : $args"

    $logEntry | Out-File $ERROR_LOG -Encoding utf8 -Append
    Write-Host $args -ForegroundColor Yellow
}

function logo_error {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] ERROR: $args"

    $logEntry | Out-File $ERROR_LOG -Encoding utf8 -Append

    Write-Host "ERROR: $args" -ForegroundColor Red
}

function welcome {

    Clear-Host
    logo "welcome $env:USERNAME"
    Write-Host "This script will install my dotfiles and this is what it will do:
        [i] Check necessary dependencies and install themes
        [i] Download my dotfiles in ${HOME}\dotfiles
        [i] Backup of possible existing configurations (glazewm, yasb, PowerShell_profile...)
        [i] Install my configuration
        [i] Create shortcut (startup)

        [!] My dotfiles DO NOT modify any of your system configurations
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
                exit 1
            }
            default {
                Write-Host "Error: Just write 'y' or 'n'" -ForegroundColor Yellow
            }
        }
    }

}

function initial_checks {

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "The script must be executed for admin."
        exit 1
    }

    if ($scriptPath -ne $HOME) {
        Write-Host "The script must be executed from HOME directory. " -ForegroundColor Red -NoNewline
        exit 1
    }

    if (-not (Test-Connection 8.8.8.8 -Quiet) ) {
        Write-Host "No internet connection detected." -ForegroundColor Red
        exit 1
    }

    if (-not (Test-Path $soft_disk)) {
        Write-Host "Software Disk $soft_disk not found." -ForegroundColor Red
        exit 1
    }

    if (-not (Test-Path "$HOME\silent.config")) {
        Write-Host "This script needs to download slient.config to the home directory." -ForegroundColor Red
        exit 1
    }

}

function add_env {
    $envVariables = @(
        @{ name = "GLAZEWM_CONFIG_PATH"; value = "$HOME\.config\glazewm\config.yaml"; scope = "Machine" }
        @{ name = "ChocolateyInstall"; value = "O:\admin\app-managers\chocolatey"; scope = "Machine" }
        @{ name = "ChocolateyToolsLocation"; value = "O:\admin\app-managers\chocolatey\tools"; scope = "Machine" }
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


    # "TARGETDIR" "INSTALL_ROOT" "DESTINATION" "INSTALLDIR" "APPLICATIONFOLDE" "INSTALLLOCATION"
    $dependices = @(

        # ok
        @{ name = "yasb"; id = "AmN.yasb"; location = "$desktop\yasb"; scope = "none" }
        @{ name = "Flow-Launcher"; id = "Flow-Launcher.Flow-Launcher"; scope = "none" }
        @{ name = "glazewm"; id = "glzr-io.glazewm"; location = "$desktop\glazewm"; install_mode = "i"; }
        @{ name = "Espanso"; id = "Espanso.Espanso"; location = "$util\espanso"; scope = "user" }
        @{ name = "qBittorrent-Enhanced-Edition"; id = "c0re100.qBittorrent-Enhanced-Edition"; custom = "/D=$net\file-sharing\qbittorrent"; }
        @{ name = "JetBrainsMonoNerdFont"; id = "DEVCOM.JetBrainsMonoNerdFont"; scope = "none" }
        @{ name = "7zip"; id = "7zip.7zip"; location = "$util\7zip"; }
        @{ name = "WinRAR"; id = "RARLab.WinRAR"; location = "$util\winrar"; }
        @{ name = "VSCodium"; id = "VSCodium.VSCodium"; location = "$doc\editor\vscodium"; }
        @{ name = "Firefox"; id = "Mozilla.Firefox"; location = "$net\browser\firefox"; }
        @{ name = "Zeal"; id = "OlegShparber.Zeal"; custom = "INSTALL_ROOT=$coding\doc\zeal"; }
        @{ name = "Flameshot"; id = "Flameshot.Flameshot"; custom = "INSTALL_ROOT=$util\flameshot"; }
        @{ name = "CPU-Z"; id = "CPUID.CPU-Z"; location = "$admin\profile\cpu-z" }
        @{ name = "Gimp"; id = "GIMP.GIMP.3"; location = "$media\graphic\gimp" }
        @{ name = "Sigil"; id = "Sigil-Ebook.Sigil"; location = "$doc\ebook\sigil" }
        @{ name = "TeXstudio"; id = "TeXstudio.TeXstudio"; location = "$doc\editor\texstudio" }
        # @{ name = "git"; id = "Microsoft.Git"; location = "$coding\vcs\git"; custom = "/COMPONENTS=gitlfs,assoc,assoc_sh,windowsterminal,scalar"}
        @{ name = "Neovim"; id = "Neovim.Neovim"; custom = "INSTALL_ROOT=$doc\editor\neovim" }
        @{ name = "Keepassxc"; id = "KeePassXCTeam.KeePassXC"; custom = "INSTALL_ROOT=$secu\passwd\keepassxc"; }
        @{ name = "CrystalDiskInfo"; id = "CrystalDewWorld.CrystalDiskInfo.AoiEdition"; location = "$admin\disk\crystal-disk-info"; }
        @{ name = "Drawio"; id = "JGraph.Draw"; location = "$doc\editor\drwaio"; }
        # Obsidian Plugins: Dateview,Advanced Tables,Calendar,Iconize Editor Syntax Highlight Emoji Toolbar,Paste URL into selection,Editing Toolbar,Obsidian Memos Easy Typing
        @{ name = "Obsidian"; id = "Obsidian.Obsidian"; location = "$doc\editor\obsidian"; }
        @{ name = "Thunderbird"; id = "Mozilla.Thunderbird"; location = "$net\comm\thunderbird"; }
        @{ name = "calibre"; id = "calibre.calibre"; location = "$doc\ebook\calibre"; }
        @{ name = "Picard"; id = "MusicBrainz.Picard"; location = "$media\audio\picard"; }
        @{ name = "OBSStudio"; id = "OBSProject.OBSStudio"; location = "$media\video\obs-studio"; }
        @{ name = "YACReader"; id = "YACReader.YACReader"; location = "$media\graphic\yac-reader"; }
        @{ name = "digiKam"; id = "KDE.digiKam"; location = "$media\graphic\digikam"; }
        @{ name = "ImageMagick"; id = "ImageMagick.ImageMagick"; location = "$media\graphic\image-magick"; }
        @{ name = "Steam"; id = "Valve.Steam"; custom = "/D=$game\platform\steam"; }
        @{  name         = "idea-ic";
            id           = "JetBrains.IntelliJIDEA.Community";
            custom       = """/S /LOG=$coding\ide\idea-ic\install.log /CONFIG=$HOME\silent.config /D=$coding\ide\idea-ic"""; 
            install_mode = "n"
        }
        @{  name         = "pycharm-pc";
            id           = "JetBrains.PyCharm.Community";
            custom       = """/S /LOG=$coding\ide\pycharm\install.log /CONFIG=$HOME\silent.config /D=$coding\ide\pycharm"""
            install_mode = "n"
        }
        @{ name = "GnuCash"; id = "GnuCash.GnuCash"; location = "$finance\gnucash"; }
        @{ name = "Musicfox"; id = "go-musicfox.go-musicfox"; location = "$media\audio\musicfox"; }
        @{ name = "cava"; id = "karlstav.cava"; location = "$desktop\cava"; }
        @{ name = "scrcpy"; id = "Genymobile.scrcpy"; }
        # @{ name = "adb"; id = "Google.PlatformTools";}
        @{ name = "everything"; id = "voidtools.Everything"; location = "$util\everything"; }
        @{ name = "tree"; id = "GnuWin32.Tree"; location = "$util\tree"; }

        # not perfect,need interactive
        @{ name = "NVM"; id = "CoreyButler.NVMforWindows"; location = "$coding\vcs\nvm"; scope = "user"; install_mode = "i"; }
        @{ name = "KDEConnect"; id = "KDE.KDEConnect"; custom = "/D=$net\sync\kde-connect"; install_mode = "i"; }
        @{ name = "PowerShell"; id = "Microsoft.PowerShell"; custom = "TARGETDIR=$util\pwsh"; install_mode = "i"; }
        @{ name = "QQ"; id = "Tencent.QQ.NT"; location = "$net\comm\qq"; install_mode = "i"; }
        @{ name = "PotPlayer"; id = "Daum.PotPlayer"; custom = "/D=$media\video\potplayer"; install_mode = "i"; }
        @{ name = "Python"; id = "Python.Python.3.12"; location = "$coding\sdk\python"; install_mode = "i"; }
        @{ name = "InternetDownloadManager"; id = "Tonec.InternetDownloadManager"; location = "$net\file-sharing\idm"; install_mode = "i"; }
        @{ name = "Powertoys"; id = "Microsoft.PowerToys"; custom = "TARGETDIR=$util\powertoys"; install_mode = "i"; }
        @{ name = "Microsoft-OpenJDK-21"; id = "Microsoft.OpenJDK.21"; location = "$coding\sdk\microsoft-openjdk-21"; install_mode = "i"; }

        # not support 'install location'
        @{ name = "ungoogled-chromium"; id = "eloston.ungoogled-chromium"; }
        @{ name = "Dotnet8"; id = "Microsoft.DotNet.SDK.8"; scope = "none" }
        @{ name = "Autohotkey"; id = "AutoHotkey.AutoHotkey"; }
        @{ name = "OhMyPosh"; id = "JanDeDobbeleer.OhMyPosh"; }
        @{ name = "WindowsTerminal"; id = "Microsoft.WindowsTerminal"; scope = "none"; install_mode = "n" }
        @{ name = "GnuPG"; id = "GnuPG.GnuPG"; location = "$secu\gpg" }

        # optional
        # @{ name = "deployment-toolkit"; id = "Microsoft.DeploymentToolkit"; custom = "TARGETDIR=$coding\build\windows-deploy-toolkit"; install_mode = "i";}
        # @{ name = "ffmpeg"; id = "Gyan.FFmpeg"; location = "$media\graphic\ffmpeg";}
        # @{ name = "Weasel"; id = "Rime.Weasel"; custom = "INSTALL_ROOT=$util\weasel"; install_mode = "i";}
        # @{ name = "WindowsSDK-10"; id = "Microsoft.WindowsSDK.10.0.19041"; install_mode = "i";}
        # @{ name = "Playnite"; id = "Playnite.Playnite"; location = "$game\platform\playnite"; scope = "user"}
        # @{ name = "fluent-reader"; id = "yang991178.fluent-reader"; location = "$doc\office\fluent-reader";}
        # @{ name = "wechat"; id = "Tencent.WeChat"; location = "$net\comm\wechat"; install_mode = "i";} # 安装哈希不匹配

    )

    function is_installed {
        param (
            [string]$id
        )
        winget list -e --id $id *> $null
        return $LASTEXITCODE -eq 0
    }

    Write-Host "Checking for required packages..." -ForegroundColor Blue
    Start-Sleep 2

    # Detet missing packages
    $missing_pkgs = @()
    foreach ($pkg in $dependices) {
        try {
            if (is_installed $pkg.id) {
                Write-Host "[$($pkg.name)] already install" -ForegroundColor Yellow
                continue
            }
            else {
                $missing_pkgs += $pkg
                Write-Host "[$($pkg.name)] not install" -ForegroundColor Red
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
                    "--id", $pkg.id,
                    "--accept-package-agreements"
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
                    # Default silent install
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
                    # Default global install
                    $wingetArgs += @("--scope", "machine") 
                }
    
                if ($pkg.custom) { 
                    $wingetArgs += @("--custom", $pkg.custom) 
                }
                Write-Host "winget $wingetArgs"
            
                Write-Host "Installing [$($pkg.name)]" -ForegroundColor Cyan
                # winget $install_cmd
                # Invoke-Expression $install_cmd
                Start-Process "winget" -ArgumentList $wingetArgs -Wait -NoNewWindow >> $ERROR_LOG

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
            Move-Item -Path $repo_dir -Destination $backup_dir -ErrorAction Stop >> $ERROR_LOG
            
        }
        catch {
            Write-Host "ERROR: - $($_.Exception.Message)"
            Write-Host "Renaming failed!"
            exit 1
        }
        Write-Host "Repository successfully renamed for backup"

    }

    # Clone new repository
    Write-Host "Cloning dotfiles from: ${repo_url}"
    
    git clone --depth 1 "$repo_url" "$repo_dir" >> $ERROR_LOG
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

function stop_specific_processes {
    param (
        [Parameter(Mandatory = $false)]
        [string[]]$process_list = @("AutoHotkey64", "yasb")
    )

    Write-Host "Stop ${process_list} processes"
    foreach ($name in $process_list) {
        # Remove .exe suffix
        $process_name = $name -replace '\.exe$', ''
        
        $process = Get-Process -Name $process_name -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "Stoping: $process_name..."
            Stop-Process -Name $process_name -Force
            Write-Host "Already stopped: $process_name"
        }
        else {
            Write-Host "Not running: $process_name"
        }
    }
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

    New-Item -Path $backup_folder -ItemType Directory -Force *>> $ERROR_LOG
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
            Move-Item -Path $source -Destination $dst -ErrorAction Stop >> $ERROR_LOG
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
        if (-not (Test-Path "$env:APPDATA\Mozilla")) {
            Write-Host "Creating Firefox profile..." -ForegroundColor Yellow
            $firefox_process = Start-Process "$net\browser\firefox\firefox.exe" -ArgumentList "--headless", "--display=0" -WindowStyle Hidden -PassThru 2> $null
            Start-Sleep 2
            if (-not $firefox_process.HasExited) {
                Stop-Process -Id $firefox_process.Id -Force -ErrorAction Stop
                Write-Host "Stop firefox process"
            }
            Start-Sleep 2
        }   
        try {
            # Backup of Firefox components
            $firefox_profile = Get-ChildItem -Path $profiles_dir -Directory -Filter "*.default-release" 2> $null
            if (Test-Path -Path $firefox_profile) {
                backup_item "${firefox_profile}\chrome" "chrome" Container
                backup_item "${firefox_profile}\user.js" "user.js" Leaf
            }
        }
        catch {
            Write-Host "Firefox profile not found." -ForegroundColor Yellow
        }

    }

    # Backup of individual files
    $single_files = @(
        @{ name = "Microsoft.PowerShell_profile(internally).ps1"; path = $windows_powershell_profile; type = "Leaf" }
        @{ name = "Microsoft.PowerShell_profile.ps1"; path = $pwsh_profile; type = "Leaf" }
        @{ name = "winterminal-settings.json"; path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"; type = "Leaf" }
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
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState",
        "$HOME\Documents\PowerToys\Backup"
    )
    foreach ($item in $required_dirs) {
        if (-not (Test-Path -Path $item -PathType Container) ) {
            New-Item -Path $item -ItemType Directory 2>> $ERROR_LOG
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

        Copy-Item -Path $source -Destination $target -Recurse -Force 2>> $ERROR_LOG 
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
        @{name = "startup-page"; source = "$HOME\dotfiles\misc\startup-page"; target = "$HOME\.local\share" }
        @{name = "windows-powershell"; source = "$HOME\dotfiles\home\Microsoft.PowerShell_profile.ps1"; target = $pwsh_profile }
        @{name = "windows-powershell(internally)"; source = "$HOME\dotfiles\home\Microsoft.PowerShell_profile.ps1"; target = $windows_powershell_profile }
        @{name = "windows-terminal"; source = "$HOME\dotfiles\home\windows-terminal\settings.json"; target = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" }
        @{name = "powertoys"; source = "$HOME\dotfiles\home\powertoys\*"; target = "$HOME\Documents\PowerToys\Backup" }

    )
    foreach ($item in $home_files) {
        copy_files $item.name $item.source $item.target
        Start-Sleep 1
    }

    # Handle Firefox theme
    if ($global:try_firefox -eq "y") {
        $firefox_profile = Get-ChildItem -Path $profiles_dir -Directory -Filter "*.default-release" 2> $null
        $firefox_source = Get-ChildItem -Path "$HOME\dotfiles\misc\firefox" | Select-Object -ExpandProperty FullName 2> $null
        # Copy content from firefox/
        if (Test-Path -Path $firefox_profile -PathType Container) {
            foreach ($item in $firefox_source) {
                $name = Split-Path $item -Leaf
                $target = $firefox_profile
                copy_files $name $item $target
            }

        }
        # Update settings
        $user_js = "$firefox_profile\user.js"
        $startup_cfg = "$HOME\.local\share\startup-page\config.js"
        
        if (Test-Path -Path $user_js) {
            (Get-Content $user_js) -replace "C:/Users/morynth", "C:/Users/$env:USERNAME" | Set-Content $user_js 2>> $ERROR_LOG 
            Write-Host "Firefox config updated!" -ForegroundColor Green
        }
        if (Test-Path -Path $startup_cfg) {
            (Get-Content $startup_cfg) -replace "name: 'morynth'", "name: '$env:USERNAME'" | Set-Content $startup_cfg 2>> $ERROR_LOG
            Write-Host "Startup page updated!" -ForegroundColor Green
        }
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
            [string]$source
        )
        $startupDir = [Environment]::GetFolderPath([Environment+SpecialFolder]::Startup)
    
        if (-not (Test-Path $source -PathType Leaf)) {
            Write-Host "$source not found"
            exit 1
        }
        $filename = [System.IO.Path]::GetFileNameWithoutExtension($source)
        $shortcut_file = (Join-Path $startupDir $filename) + ".lnk"
    
        New-Item -ItemType SymbolicLink -Path $shortcut_file -Target $source *>> $ERROR_LOG
    
        Write-Host "Add $filename shortcurt to startup successfully!"
        
    }

    $start_files = @(
        "$env:ProgramFiles\glzr.io\GlazeWM\glazewm.exe"
        "$desktop\yasb\yasb.exe"
        $(Get-ChildItem -Path "$HOME\.config\autohotkey" -File -Filter "*.ahk" | Select-Object -ExpandProperty FullName)

    )
    foreach ($item in $start_files) {
        create_shortcut $item
    }
    Start-Sleep 3

}


initial_checks
welcome

install_dependencies
# clone_dotfiles

stop_specific_processes
backup_existing_config
install_dotfiles
configure_startup