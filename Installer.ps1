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
$backup_folder = Join-Path -Path $PSScriptRoot -ChildPath ".DotfileBackup"
$ERROR_LOG = Join-Path -Path $PSScriptRoot -ChildPath "InstallerERROR.log"

# 获取当前脚本所在的目录路径（规范化处理）
$scriptPath = $PSScriptRoot
# 获取用户家目录路径（规范化处理）
$homePath = $HOME

# 定义 ANSI 颜色代码

$CRE = "`e[31m"  # 红色
$CYE = "`e[33m"  # 黄色
$CGR = "`e[32m"  # 绿色
$CBL = "`e[34m"  # 蓝色
$BLD = "`e[1m"   # 加粗
$CNC = "`e[0m"   # 重置颜色

# function instal_winget {

#     Clear-Host
#     logo "Add molin custom repo"
#     $repo_name="molin-dotfiles"
#     Start-Sleep -Seconds 2

#     # Check if the repository already exists
#     Write-Host "${BLD}${CYE}Installing ${CBL}${repo_name} ${CYE}repository...${CNC}"
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
    param(
        [Parameter(Mandatory)]
        [string]$Text
    )
    
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    # 多行 ASCII 艺术字
    $logoArt = @" 
    $BLD${CRE}[ $CYE$Text $CRE]$CNC
"@
    Write-Host $logoArt
}

# 错误日志处理函数
function logo_error {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] ERROR: $Message"

    # 写入日志文件
    $logEntry | Out-File $ERROR_LOG -Append

    # 控制台彩色输出
    Write-Host "${BLD}${CRE}ERROR:${CNC} $Message" -ForegroundColor Red
}

function welcome {

    Clear-Host
    logo -Text "welcome $env:USERNAME"
    Write-Host "${BLD}${CGR}This script will install my dotfiles and this is what it will do:${CNC}
        ${BLD}${CGR}[${CYE}i${CGR}]${CNC} 2 repositories will be installed. ${CBL}gh0stzk-dotfiles${CNC} and ${CBL}Chaotic-Aur${CNC}
        ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Check necessary dependencies and install them
        ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Download my dotfiles in ${HOME}/dotfiles
        ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Backup of possible existing configurations (bspwm, polybar, etc...)
        ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Install my configuration
        ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Enabling MPD service (Music player daemon)
        ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Change your shell to zsh shell

        ${BLD}${CGR}[${CRE}!${CGR}]${CNC} ${BLD}${CRE}My dotfiles DO NOT modify any of your system configurations${CNC}
        ${BLD}${CGR}[${CRE}!${CGR}]${CNC} ${BLD}${CRE}This script does NOT have the potential power to break your system${CNC}

    " 

    while ($true) {
        # 带颜色的交互提示
        Write-Host "${BLD}${CGR}Do you wish to continue? [y/N]:${CNC} "-NoNewline
        $yn = Read-Host

        # 处理用户输入
        switch -Regex ($yn.Trim().ToLower()) {
            '^(y|yes)$' { 
                return  # 继续执行脚本
            }
            '^(n|no)?$' {
                Write-Host "`n${BLD}${CYE}Operation cancelled${CNC}"
                exit 0  # 退出脚本
            }
            default {
                Write-Host "`n${BLD}${CRE}Error: Just write '${CYE}y${CRE}' or '${CYE}n${CRE}'${CNC}`n"
            }
        }
    }

}

function initial_checks {

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "The script must be executed for admin"
        exit 1
    }

    # if ($scriptPath -ne $homePath) {
    #     Write-Host "The script must be executed from HOME directory. " -ForegroundColor Red -NoNewline
    #     Write-Host "Home directory is: $HOME" -ForegroundColor Red
    #     exit 1
    # }

    if (-not (Test-Connection -TargetName 8.8.8.8 -Quiet) ) {
        Write-Host "No internet connection detected." -ForegroundColor Red
        exit 1
    }

    $TargetDrive = "O:"
    if (-not (Test-Path $TargetDrive)) {
        Write-Host "软件分区 $TargetDrive 不存在！" -ForegroundColor Red
        exit 1
    }


}

function add_env {
    
    $envVariables = @(
        @{ name = "GLAZEWM_CONFIG_PATH"; value = "C:\Users\molin\.config\glazewm\glazewm.yaml"; scope = "Machine" }
        @{ name = "YAZI_CONFIG_HOME"; value = "C:\Users\molin\.config\yazi"; scope = "Machine" }
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
            Write-Error "Failed to set env variables: $_"
        }
    }
    Write-Host “Please restart Shell"
    
}

function add_dependices {

    $soft_disk = "O:"
    $utilities = Join-Path -Path $soft_disk -ChildPath "utilities"
    $desktop = Join-Path -Path $soft_disk -ChildPath "desktop"
    $coding = Join-Path -Path $soft_disk -ChildPath "coding"
    $doc = Join-Path -Path $soft_disk -ChildPath "documents"
    $admin = Join-Path -Path $soft_disk -ChildPath "admin"
    $net = Join-Path -Path $soft_disk -ChildPath "internet"
    $multimedia = Join-Path -Path $soft_disk -ChildPath "multimedia"

    $dependices = @(
        @{ name = "yasb"; id = "AmN.yasb"; scope = "user"}
        @{ name = "nvim"; id = "Neovim.Neovim"; location = "$doc\editors\neovim"; interactive = $true;}
        @{ name = "glazewm"; id = "glzr-io.glazewm"; location = "$desktop\glazewm";}
        @{ name = "jetbrainsMonoNerdFonts"; id = "DEVCOM.JetBrainsMonoNerdFont";}
        @{ name = "flameshot"; id = "Flameshot.Flameshot"; location = "$utilities\ime\flameshot"; interactive = $true;}
        @{ name = "gnuPG"; id = "GnuPG.GnuPG";}
        
        )
    # Detet missing packages
    $missing_pkgs = @()
    foreach ($pkg in $dependices) {
        try {
            winget list -e --id $($pkg.id) | Out-Null
        
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[√] [$($pkg.name)] already install" -ForegroundColor Yellow
                continue
            }
            else {
                $missing_pkgs += $pkg
                Write-Host "[×] [$($pkg.name)] not install" -ForegroundColor Red
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
            Write-Host "${BLD}${CYE}Installing $($missing_pkgs.Count) missing packages...${CNC}"
            $failed_install = @()
            foreach ($pkg in $missing_pkgs) {
                try {
                $install_cmd = "winget install -e --id $($pkg.id)"
    
                if ($pkg.interactive) { 
                    $install_cmd += " -i"
                }
                else {
                    # 默认静默安装
                    $install_cmd += " -h"
                }
                if ($pkg.location) { $install_cmd += @(" -l", "`"$($pkg.location)`"") }

                if ($pkg.scope) { 
                    $install_cmd += @(" --scope", "$($pkg.scope)") 
                } else {
                    # 默认全局安装
                    $install_cmd += @(" --scope", "machine") 
                }
    
                Write-Host $install_cmd
            
                Write-Host "Installing [$($pkg.name)]" -ForegroundColor Cyan
                # winget $install_cmd
                Invoke-Expression $install_cmd
                # if ($LASTEXITCODE -ne 0) {
                #     $failed_install += $pkg
                #     logo_error -Message "$($pkg.name) install failed"
                # }
            }
            catch {
                $failed_install += $pkg
                logo_error -Message "$($pkg.name) install failed,error message: $($_.Exception.Message)"
            }

        }

 
    }



}

function Test {
    winget source remove winget
    winget source add winget https://mirrors.ustc.edu.cn/winget-source --trust-level trusted
    
}

# initial_checks
# welcome
# add_env
add_dependices
# Test