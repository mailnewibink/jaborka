Add-Type -AssemblyName System.Drawing

function Check-File($path) {
    $full = (Resolve-Path $path).Path
    $bmp = [System.Drawing.Bitmap]::FromFile($full)
    $minX = $bmp.Width; $maxX = 0; $minY = $bmp.Height; $maxY = 0
    for ($y = 0; $y -lt $bmp.Height; $y += 2) {
        for ($x = 0; $x -lt $bmp.Width; $x += 2) {
            if ($bmp.GetPixel($x, $y).A -gt 20) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    $w = $maxX - $minX; $h = $maxY - $minY
    Write-Host "$path : Content=X:$minX-$maxX, Y:$minY-$maxY, Size:${w}x${h}"
    $bmp.Dispose()
}

Check-File 'hero-text-easy.png'
Check-File 'hero-text-import.png'
Check-File 'hero-container-new.png'
Check-File 'hero-composite.png'
