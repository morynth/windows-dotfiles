
# 1. set env

$username = $env:USERNAME
$app_driver = "O:"
$home_driver = "H:"
$game_driver = "G:"
$my_profile = "$home_driver\$env:USERNAME"
Write-Host 'Add env vars'

$addEnvs = @(
    @{ name="MyApp";value = "$app_driver";scope = ""},
    @{ name="MyProfile";value = "$my_profile"},
    @{ name="Admin";value = "$app_driver\admin"},
    @{ name="Internet";value = "$app_driver\internet"},
    @{ name="Docs";value = "$app_driver\documents"},
    @{ name="Security";value = "$app_driver\security"},
    @{ name="Multimedia";value = "$app_driver\multimedia"},
    @{ name="Utilities";value = "$app_driver\utilities"},
    @{ name="Coding";value = "$app_driver\coding"}
    @{ name="Games";value = "$app_driver\games"}
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

