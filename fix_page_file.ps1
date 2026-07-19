# Fix Windows Page File (Virtual Memory) - Mwendo App Build Fix
# Run this script as Administrator to resolve JVM OutOfMemoryError during Gradle builds

Write-Host "=== Mwendo App - Windows Page File Fix ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then re-run this script." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Running as Administrator" -ForegroundColor Green
Write-Host ""

# Get current page file settings
$computerSystem = Get-WmiObject -Class Win32_ComputerSystem
$automaticManagedPageFile = $computerSystem.AutomaticManagedPagefile

Write-Host "Current Settings:" -ForegroundColor Cyan
Write-Host "  Automatic page file management: $automaticManagedPageFile"
Write-Host ""

if ($automaticManagedPageFile) {
    Write-Host "Disabling automatic page file management..." -ForegroundColor Yellow
    $computerSystem | Set-WmiInstance -Arguments @{AutomaticManagedPagefile=$false} | Out-Null
    Write-Host "[OK] Automatic management disabled" -ForegroundColor Green
    Write-Host ""
}

# Get the C: drive page file
$pageFile = Get-WmiObject -Class Win32_PageFileSetting -Filter "Name='C:\\pagefile.sys'" -ErrorAction SilentlyContinue

if ($pageFile) {
    Write-Host "Updating existing page file configuration..." -ForegroundColor Yellow
    $pageFile | Set-WmiInstance -Arguments @{
        InitialSize = 16384
        MaximumSize = 32768
    } | Out-Null
    Write-Host "[OK] Page file updated: 16GB initial, 32GB maximum" -ForegroundColor Green
} else {
    Write-Host "Creating new page file configuration..." -ForegroundColor Yellow
    New-WmiObject -Class Win32_PageFileSetting -Arguments @{
        Name = "C:\pagefile.sys"
        InitialSize = 16384
        MaximumSize = 32768
    } | Out-Null
    Write-Host "[OK] Page file created: 16GB initial, 32GB maximum" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Configuration Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: You must RESTART your computer for changes to take effect." -ForegroundColor Yellow
Write-Host ""
Write-Host "After restart:" -ForegroundColor Cyan
Write-Host "  1. Open a new terminal in the Mwendo project directory" -ForegroundColor White
Write-Host "  2. Run: flutter clean" -ForegroundColor White
Write-Host "  3. Delete the folder: app\android\.gradle" -ForegroundColor White
Write-Host "  4. Run: flutter build apk --release" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")