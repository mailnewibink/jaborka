Add-Type -AssemblyName System.Drawing

$comp = [System.Drawing.Bitmap]::FromFile((Resolve-Path "hero-composite.png").Path)
$imp = [System.Drawing.Bitmap]::FromFile((Resolve-Path "hero-text-import.png").Path)
$easy = [System.Drawing.Bitmap]::FromFile((Resolve-Path "hero-text-easy.png").Path)
$cont = [System.Drawing.Bitmap]::FromFile((Resolve-Path "hero-container-new.png").Path)

$stack = New-Object System.Drawing.Bitmap($comp.Width, $comp.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($stack)

# Draw import, then easy, then container
$g.DrawImage($imp, 0, 0, $comp.Width, $comp.Height)
$g.DrawImage($easy, 0, 0, $comp.Width, $comp.Height)
$g.DrawImage($cont, 0, 0, $comp.Width, $comp.Height)

$stack.Save((Resolve-Path ".").Path + "\test-stack.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Compare difference between stack and composite
$diff = 0
for ($y = 0; $y -lt $comp.Height; $y += 2) {
    for ($x = 0; $x -lt $comp.Width; $x += 2) {
        $p1 = $comp.GetPixel($x, $y)
        $p2 = $stack.GetPixel($x, $y)
        if ([Math]::Abs($p1.R - $p2.R) -gt 5 -or [Math]::Abs($p1.G - $p2.G) -gt 5 -or [Math]::Abs($p1.B - $p2.B) -gt 5 -or [Math]::Abs($p1.A - $p2.A) -gt 5) {
            $diff++
        }
    }
}

Write-Host "Difference count between stack and composite: $diff"

$g.Dispose()
$stack.Dispose()
$cont.Dispose()
$easy.Dispose()
$imp.Dispose()
$comp.Dispose()
