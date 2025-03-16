

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/tokyonight_storm.omp.json" | Invoke-Expression
# tokyonight_storm
# atomic
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete 
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Import-Module PSReadLine
Import-Module posh-git
# Import-Module microsoft.powershell.localaccounts -UseWindowsPowerShell

function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

Function Test-CommandExists
{
    Param ($command)

    try { if (Get-Command $command -ErrorAction Stop) { return $true } }

    Catch { return $false }


}

# vars
function checkIfInstall {
    param (
        $installPath,
        $name
    )
    if (Test-Path -Path $installPath) {
        Write-Host "$name already install"
        return False
    }
}
function createShortcut {
    param ([string]$TargetFile, [string]$ShortcutFile)
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
        
}


function downloadApp {
    param ([string]$url, [string]$destination = "$env:MyProfile\Downloads", [string]$dirName)
    Invoke-WebRequest -Uri $url -OutFile $destination 
        
}


function ChezmoiApply {
    chezmoi apply
}

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}


New-Alias -Name vi -Value nvim
Set-Alias -Name cay -Value ChezmoiApply

Invoke-Expression (& { (zoxide init powershell | Out-String) })


# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
