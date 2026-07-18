# Lance TradingView Desktop avec le port de debug CDP (9222) pour le pont claudeverstradingview.
# Retrouve l'exe automatiquement via Get-AppxPackage (survit aux mises a jour).

$ErrorActionPreference = 'Stop'
$port = 9222

Write-Host "Fermeture de TradingView en cours..."
Get-Process TradingView -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

$pkg = Get-AppxPackage *TradingView* | Select-Object -First 1
if (-not $pkg) { Write-Host "TradingView introuvable (Get-AppxPackage)."; exit 1 }

$exe = Join-Path $pkg.InstallLocation 'TradingView.exe'
if (-not (Test-Path $exe)) { Write-Host "Exe introuvable: $exe"; exit 1 }

Write-Host "Lancement: $exe --remote-debugging-port=$port"
Start-Process -FilePath $exe -ArgumentList "--remote-debugging-port=$port"

Start-Sleep -Seconds 6
try {
  $r = Invoke-WebRequest "http://localhost:$port/json/version" -TimeoutSec 5 -UseBasicParsing
  Write-Host "OK - port $port actif. Le pont peut se connecter." -ForegroundColor Green
} catch {
  Write-Host "Le port $port ne repond pas encore. Attends quelques secondes puis reessaie." -ForegroundColor Yellow
}
