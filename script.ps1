<#
.SYNOPSIS
    Initial Windows setup script that installs applications, configures VS Code, and sets up terminal tools.
.DESCRIPTION
    This script performs the following actions:
    1. Installs Brave, VS Code, QBittorrent, .NET, JVM, Python3, Steam
    2. Configures VS Code with specified plugins and settings.json
    3. Sets up OhMyPosh and Clink for terminal customization
.NOTES
    File Name      : InitialSetup.ps1
    Prerequisite   : PowerShell 5.1 or later, run as Administrator
#>

#Requires -RunAsAdministrator

# Function to check if a command exists
function Test-CommandExists {
    param($command)
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

# Function to install a package using winget if not already installed
function Install-WingetPackage {
    param(
        [string]$packageId,
        [string]$packageName
    )
    
    if (-not (Test-CommandExists "winget")) {
        Write-Host "winget is not available. Please install App Installer from Microsoft Store." -ForegroundColor Red
        return $false
    }
    
    $installed = winget list --id $packageId --exact -e 2>$null
    if ($null -eq $installed) {
        Write-Host "Installing $packageName..." -ForegroundColor Cyan
        winget install --id $packageId --exact --silent --accept-package-agreements --accept-source-agreements
        Write-Host "$packageName installed successfully." -ForegroundColor Green
        return $true
    } else {
        Write-Host "$packageName is already installed." -ForegroundColor Yellow
        return $false
    }
}

# Install applications using winget
Write-Host "Starting application installations..." -ForegroundColor Cyan

$packages = @(
    @{Id = "Brave.Brave"; Name = "Brave Browser"},
    @{Id = "Microsoft.VisualStudioCode"; Name = "VS Code"},
    @{Id = "qBittorrent.qBittorrent"; Name = "qBittorrent"},
    @{Id = "Microsoft.DotNet.SDK.7"; Name = ".NET 7 SDK"},
    @{Id = "EclipseAdoptium.Temurin.17.JDK"; Name = "Java JDK 17"},
    @{Id = "Python.Python.3.11"; Name = "Python 3.11"},
    @{Id = "Valve.Steam"; Name = "Steam"}
)

foreach ($package in $packages) {
    Install-WingetPackage -packageId $package.Id -packageName $package.Name
}

# Install VS Code extensions
Write-Host "Installing VS Code extensions..." -ForegroundColor Cyan

$extensions = @(
    "akamud.vscode-theme-onedark",
    "usernamehw.errorlens",
    "GitHub.copilot",
    "PKief.material-icon-theme",
    "esbenp.prettier-vscode",
    "Gruntfuggly.todo-tree"
)

foreach ($extension in $extensions) {
    code --install-extension $extension --force
}

# Configure VS Code settings.json
Write-Host "Configuring VS Code settings..." -ForegroundColor Cyan

$vscodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
$vscodeSettings = @'
{
    "window.zoomLevel": 0.5,

    "debug.onTaskErrors": "abort",

    "explorer.confirmDragAndDrop": false,
    "explorer.confirmDelete": false,
    "explorer.confirmPasteNative": false,

    "workbench.startupEditor": "none",
    "workbench.iconTheme": "eq-material-theme-icons",
    "workbench.list.fastScrollSensitivity": 2,

    "editor.fontFamily": "'JetBrains Mono NFM Regular'",

    "editor.fontSize": 14,
    "editor.lineHeight": 1.5,
    "editor.tabSize": 4,
    "editor.detectIndentation": false,
    "editor.formatOnSave": true,
    "editor.suggestSelection": "first",
    "editor.find.cursorMoveOnType": false,
    "editor.fontLigatures": false,
    "editor.quickSuggestionsDelay": 0,
    "editor.hover.delay": 200,
    "editor.bracketPairColorization.independentColorPoolPerBracketType": true,
    "editor.stickyScroll.enabled": false,
    "editor.guides.indentation": false,
    "editor.minimap.enabled": false,
    "editor.lineNumbers": "off",

    "files.autoSave": "onFocusChange",
    "files.exclude": {
        "/.classpath": true,
        "/.project": true,
        "/.settings": true,
        "/.factorypath": true
    },

    "terminal.integrated.defaultProfile.windows": "Command Prompt",
    "terminal.integrated.fontFamily": "MesloLGM Nerd Font",
    "terminal.integrated.fontSize": 12,
    "terminal.integrated.enableMultiLinePasteWarning": "never",
    "terminal.integrated.env.windows": {},
    "terminal.integrated.cursorStyle": "line",
    "terminal.integrated.cursorStyleInactive": "none",

    "[json]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.tabSize": 4
    },
    "[jsonc]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.tabSize": 4
    },
    "[typescript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.tabSize": 4
    },
    "[typescriptreact]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.tabSize": 4
    },
    "[javascript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.tabSize": 4
    },
    "[javascriptreact]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.tabSize": 4
    },

    "javascript.updateImportsOnFileMove.enabled": "always",
    "typescript.updateImportsOnFileMove.enabled": "always",

    "tailwindCSS.experimental.classRegex": ["tw`([^]*)"],

    "database-client.autoSync": true,

    "prettier.jsxSingleQuote": true,
    "prettier.quoteProps": "consistent",
    "prettier.semi": false,
    "prettier.singleQuote": true,
    "prettier.tabWidth": 4,
    "prettier.trailingComma": "none",
    "prettier.printWidth": 100,
    "prettier.bracketSameLine": true,

    "C_Cpp.default.compilerPath": "C:\\MinGW\\bin\\gcc.exe",
    "C_Cpp.inlayHints.parameterNames.suppressWhenArgumentContainsName": false,
    "C_Cpp.vcFormat.indent.caseLabels": true,
    "C_Cpp.vcFormat.newLine.beforeCatch": false,
    "C_Cpp.vcFormat.newLine.beforeElse": false,
    "C_Cpp.vcFormat.newLine.beforeOpenBrace.block": "sameLine",
    "C_Cpp.vcFormat.newLine.beforeOpenBrace.function": "sameLine",
    "C_Cpp.vcFormat.newLine.beforeOpenBrace.type": "sameLine",
    "files.associations": {
        "stdlib.h": "c",
        "string.h": "c"
    }
}
'@

# Create directory if it doesn't exist
if (-not (Test-Path "$env:APPDATA\Code\User")) {
    New-Item -ItemType Directory -Path "$env:APPDATA\Code\User" -Force
}

# Write settings.json
$vscodeSettings | Out-File -FilePath $vscodeSettingsPath -Encoding utf8 -Force
Write-Host "VS Code settings configured." -ForegroundColor Green

# Install OhMyPosh and Clink
Write-Host "Setting up terminal tools..." -ForegroundColor Cyan

# Install OhMyPosh
if (-not (Test-CommandExists "oh-my-posh")) {
    Write-Host "Installing OhMyPosh..." -ForegroundColor Cyan
    winget install JanDeDobbeleer.OhMyPosh -s winget
} else {
    Write-Host "OhMyPosh is already installed." -ForegroundColor Yellow
}

# Install Clink
$clinkUrl = "https://github.com/chrisant996/clink/releases/download/v1.4.15/clink.1.4.15.3c719.zip"
$clinkZip = "$env:TEMP\clink.zip"
$clinkFolder = "$env:ProgramFiles\Clink"

if (-not (Test-Path "$clinkFolder\clink.bat")) {
    Write-Host "Downloading and installing Clink..." -ForegroundColor Cyan
    
    # Download Clink
    Invoke-WebRequest -Uri $clinkUrl -OutFile $clinkZip
    
    # Extract and install
    if (-not (Test-Path $clinkFolder)) {
        New-Item -ItemType Directory -Path $clinkFolder -Force
    }
    Expand-Archive -Path $clinkZip -DestinationPath $clinkFolder -Force
    
    # Add to PATH
    $envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if (-not $envPath.Contains($clinkFolder)) {
        [Environment]::SetEnvironmentVariable("Path", "$envPath;$clinkFolder", "Machine")
    }
    
    Write-Host "Clink installed successfully." -ForegroundColor Green
} else {
    Write-Host "Clink is already installed." -ForegroundColor Yellow
}

# Configure PowerShell profile with OhMyPosh
Write-Host "Configuring PowerShell profile..." -ForegroundColor Cyan

$profileContent = @'
oh-my-posh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/amro.omp.json' init pwsh | Invoke-Expression
'@

# Create profile if it doesn't exist
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

# Write content to profile
$profileContent | Out-File -FilePath $PROFILE -Encoding utf8 -Force

Write-Host "PowerShell profile configured." -ForegroundColor Green

Write-Host "All tasks completed successfully!" -ForegroundColor Green