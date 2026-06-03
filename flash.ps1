# Flash La michie de Titi
# Usage: .\flash.ps1
# ou avec un fichier specifique: .\flash.ps1 -img "C:\chemin\vers\la_machine.img"

param(
    [string]$img = "$env:USERPROFILE\Downloads\la_machine_flash\la_machine.img"
)

$env:PATH += ";C:\Users\Asus\AppData\Roaming\Python\Python313\Scripts"

# Dezippe si on recoit un zip
$zip = "$env:USERPROFILE\Downloads\la_machine.img.zip"
if (Test-Path $zip) {
    Write-Host "Archive zip trouvee, dezippage..."
    Expand-Archive $zip -DestinationPath "$env:USERPROFILE\Downloads\la_machine_flash\" -Force
    Write-Host "Dezippage OK."
}

if (!(Test-Path $img)) {
    Write-Host "ERREUR : fichier $img introuvable."
    Write-Host "Telecharge la_machine.img depuis GitHub Actions > Artifacts."
    exit 1
}

Write-Host ""
Write-Host "=== Flash de La michie de Titi ==="
Write-Host "Image : $img"
Write-Host ""
Write-Host "Appuie sur le bouton rouge de La Machine pour la reveiller..."

while (!(Get-WmiObject Win32_SerialPort -ErrorAction SilentlyContinue | Where-Object {$_.DeviceID -eq "COM3"})) {
    Start-Sleep -Milliseconds 500
}

Write-Host "COM3 detecte ! Flash en cours (~2 min)..."
python -m esptool --chip esp32c3 --port COM3 write_flash 0 $img

if ($?) {
    Write-Host ""
    Write-Host "=== Flash reussi ! ==="
    Write-Host "La Machine va redemarrer et faire 3 boots de calibration :"
    Write-Host "  Boot 1 : son de demarrage -> debranche USB -> appuie le bouton"
    Write-Host "  Boot 2 : calibration servo automatique"
    Write-Host "  Boot 3 : son de confirmation"
    Write-Host "  Boot 4+ : mode normal -> bouton = Champions League !"
} else {
    Write-Host "ERREUR pendant le flash. Reessaie."
}
