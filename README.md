# A Windows10/11 Glazewm Manager Environment
<div align = center>

</div>


## 👻 Welcome


## 🚀 What does?

This dotfiles script does:

TODO

---

### 💾 Installation:

> [!NOTE]
> Make sure winget is installed

- **Change your host's script execution policy, Make sure your host can execute scripts**
```sh
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass;
```

- **Open any Windows PowerShell in HOME with administrator rights and run**
```sh

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/morynth/windows-dotfiles/main/Installer.ps1" -OutFile Installer.ps1

# Or Direct run

Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/morynth/windows-dotfiles/main/Installer.ps1");

```

- **Finally run the installer**
```sh
./Installer.ps1
```
