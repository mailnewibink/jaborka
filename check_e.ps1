Add-Type -AssemblyName System.Drawing

$easy = [System.Drawing.Bitmap]::FromFile((Resolve-Path "hero-text-easy.png").Path)

# Check top of letter 'e'
# MinX was 520, MinY was 388
Write-Host "Top pixel of 'e' is at Y: $($easy.Height)"
for ($y = 0; $y -lt $easy.Height; $y++) {
    for ($x = 520; $x -lt 620; $x++) {
        if ($easy.GetPixel($x, $y).A -gt 20) {
            Write-Host "First pixel of 'e': X=$x, Y=$y"
            $y = 999999
            break
        }
    }
}
$easy.Dispose()
