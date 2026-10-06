Add-Type -AssemblyName System.Drawing

function Crop-Tight($srcPath, $dstPath) {
    $src = [System.Drawing.Bitmap]::FromFile((Resolve-Path $srcPath).Path)
    $minX = $src.Width; $maxX = 0; $minY = $src.Height; $maxY = 0
    for ($y = 0; $y -lt $src.Height; $y++) {
        for ($x = 0; $x -lt $src.Width; $x++) {
            if ($src.GetPixel($x, $y).A -gt 15) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    $w = $maxX - $minX + 1; $h = $maxY - $minY + 1
    Write-Host "${srcPath} - minX=$minX, minY=$minY, w=$w, h=$h"
    $dst = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dst)
    $g.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $w, $h)), (New-Object System.Drawing.Rectangle($minX, $minY, $w, $h)), [System.Drawing.GraphicsUnit]::Pixel)
    $dst.Save((Resolve-Path ".").Path + "\" + $dstPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $dst.Dispose(); $src.Dispose()
}

Crop-Tight "hero-text-import.png" "hero-import-tight.png"
Crop-Tight "hero-text-easy.png" "hero-easy-tight.png"
Crop-Tight "hero-container-new.png" "hero-container-new-tight.png"
