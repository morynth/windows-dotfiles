oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/tokyonight_storm.omp.json" | Invoke-Expression
# theme: spaceship,json,star,tokyonight_storm,zash,atomic
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete 
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Import-Module PSReadLine
# Install posh-git: PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
Import-Module posh-git

function batch_convert_to_webp {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({ Test-Path $_ })]
        [string[]]$Paths
    )
    
    $supported_extensions = @('.jpg', '.jpeg', '.png', '.bmp', '.tiff', '.tif')
    
    $files_to_process = @()
    
    foreach ($path in $Paths) {
        if (Test-Path $path -PathType Container) {
            # 处理目录
            $files = Get-ChildItem -Path $path -File | Where-Object {
                $supported_extensions -contains $_.Extension.ToLower() -and
                $_.Extension -ne '.webp'
            }
            $files_to_process += $files
        }
        elseif (Test-Path $path -PathType Leaf) {
            # 处理单个文件
            $file = Get-Item $path
            if ($supported_extensions -contains $file.Extension.ToLower()) {
                $files_to_process += $file
            }
            else {
                Write-Warning "Skip unsupported files: $($file.FullName)"
            }
        }
    }
    
    if ($files_to_process.Count -eq 0) {
        Write-Host "No files found to be converted"
        exit
    }
    
    foreach ($file in $files_to_process) {
        $outputFile = [IO.Path]::ChangeExtension($file.FullName, '.webp')
        
        try {
            Write-Host "Converting: $($file.Name)"
            magick $file.FullName -quality 85 $outputFile
            Write-Host "Created: $outputFile" -ForegroundColor Green
        }
        catch {
            Write-Error "Conversion failed: $($file.FullName)"
            Write-Error $_.Exception.Message
        }
    }
    
    Write-Host "Conversion completed! $($files_to_process.Count) files processed" -ForegroundColor Cyan
    
}


function save_terminal_profile {
    try {
        $terminal_profile_path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        $target = "$HOME\Documents\settings.json"
        Copy-Item -Path $terminal_profile_path -Destination $target -Force

    }
    catch {
        Write-Host "Save failed"
    }
    Write-Host "Successfully saved to the document"

}

# Winget Tab
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

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
