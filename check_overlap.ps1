Add-Type -AssemblyName System.Drawing

$comp = [System.Drawing.Bitmap]::FromFile((Resolve-Path "hero-composite.png").Path)
$cont = [System.Drawing.Bitmap]::FromFile((Resolve-Path "hero-container-new.png").Path)

$overlapCount = 0
for ($y = 0; $y -lt $comp.Height; $y++) {
    for ($x = 0; $x -lt $comp.Width; $x++) {
        $pComp = $comp.GetPixel($x, $y)
        $pCont = $cont.GetPixel($x, $y)
        # Check if container pixel has alpha and composite has different color (or if container covers text)
        if ($pCont.A -gt 20 -and $x -gt 500 -and $y -gt 380) {
            # Let's check color
            $overlapCount++
        }
    }
}

Write-Host "Container pixels in easy area (X>500, Y>380): $overlapCount"

$cont.Dispose()
$comp.Dispose()
