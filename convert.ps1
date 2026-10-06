Add-Type -AssemblyName System.Drawing

$srcPath = "c:\Users\ibink\Downloads\jbrk web\hero-container.jpg"
$dstPath = "c:\Users\ibink\Downloads\jbrk web\hero-container.png"

$src = [System.Drawing.Bitmap]::FromFile($srcPath)
$width = $src.Width
$height = $src.Height

# Make transparent copy
$dst = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $c = $src.GetPixel($x, $y)
        # Check if white background
        if ($c.R -gt 248 -and $c.G -gt 248 -and $c.B -gt 248) {
            $dst.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 255, 255, 255))
        } else {
            $dst.SetPixel($x, $y, $c)
        }
    }
}

$dst.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)
$dst.Dispose()
$src.Dispose()
Write-Host "hero-container.png successfully generated with transparent background!"
