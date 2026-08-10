#Requires -RunAsAdministrator
Write-Host "=== Liberando execucao de scripts ===" -ForegroundColor Cyan
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# ---------------------------------------------------------
# Verifica se o winget esta disponivel
# ---------------------------------------------------------
Write-Host "=== Verificando winget ===" -ForegroundColor Cyan
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget nao encontrado. Instale o 'App Installer' pela Microsoft Store e rode o script novamente." -ForegroundColor Red
    Write-Host "Link: https://apps.microsoft.com/detail/9nblggh4nns1" -ForegroundColor Yellow
    exit 1
}

# ---------------------------------------------------------
# Lista de programas (id winget)
# ---------------------------------------------------------
$apps = @(
    "Docker.DockerDesktop",
    "Discord.Discord",
    "Telegram.TelegramDesktop",
    "Valve.Steam",
    "CommandLine.Waveterm",
    "Mozilla.Thunderbird",
    "Microsoft.VisualStudioCode",
    "Notepad++.Notepad++",
    "Google.Chrome"
)

Write-Host "=== Instalando aplicativos via winget ===" -ForegroundColor Cyan
foreach ($app in $apps) {
    Write-Host ">> Instalando $app ..." -ForegroundColor Yellow
    winget install --id $app --silent --accept-package-agreements --accept-source-agreements
}

# ---------------------------------------------------------
# Habilita WSL2
# ---------------------------------------------------------
Write-Host "=== Habilitando recursos do WSL2 ===" -ForegroundColor Cyan
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

wsl --set-default-version 2

# ---------------------------------------------------------
# Instala Arch Linux no WSL2
# ---------------------------------------------------------
Write-Host "=== Instalando Arch Linux no WSL2 ===" -ForegroundColor Cyan
wsl --install -d archlinux

Write-Host ""
Write-Host "=== CONCLUIDO ===" -ForegroundColor Green
Write-Host "Pode ser necessario REINICIAR o computador para o WSL2 funcionar corretamente." -ForegroundColor Yellow
Write-Host "Apos reiniciar, abra o Arch Linux pelo menu Iniciar para finalizar a configuracao (usuario/senha)." -ForegroundColor Yellow
