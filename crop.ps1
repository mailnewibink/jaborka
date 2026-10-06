Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile("c:\Users\ibink\Downloads\jbrk web\hero-container.png")
$minX = $src.Width
$maxX = 0
$minY = $src.Height
$maxY = 0

for ($y = 0; $y -lt $src.Height; $y += 2) {
    for ($x = 0; $x -lt $src.Width; $x += 2) {
        $c = $src.GetPixel($x, $y)
        if ($c.A -gt 20) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

Write-Host "Bounds: minX=$minX, maxX=$maxX, minY=$minY, maxY=$maxY"
Write-Host "Width=$($maxX - $minX), Height=$($maxY - $minY)"

# Crop tightly around content with small margin
$cropWidth = $maxX - $minX + 20
$cropHeight = $maxY - $minY + 20
$cropX = [Math]::Max(0, $minX - 10)
$cropY = [Math]::Max(0, $minY - 10)

$cropBmp = New-Object System.Drawing.Bitmap($cropWidth, $cropHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($cropBmp)
$g.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $cropWidth, $cropHeight)), (New-Object System.Drawing.Rectangle($cropX, $cropY, $cropWidth, $cropHeight)), [System.Drawing.GraphicsUnit]::Pixel)
$cropBmp.Save("c:\Users\ibink\Downloads\jbrk web\hero-container-tight.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$cropBmp.Dispose()
$src.Dispose()
Write-Host "Saved tightly cropped hero-container-tight.png"
