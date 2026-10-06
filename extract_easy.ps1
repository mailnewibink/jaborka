Add-Type -AssemblyName System.Drawing

$comp = [System.Drawing.Bitmap]::FromFile((Resolve-Path "hero-composite.png").Path)
$cont = [System.Drawing.Bitmap]::FromFile((Resolve-Path "hero-container-new.png").Path)
$imp = [System.Drawing.Bitmap]::FromFile((Resolve-Path "hero-text-import.png").Path)

$easyBmp = New-Object System.Drawing.Bitmap($comp.Width, $comp.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

for ($y = 0; $y -lt $comp.Height; $y++) {
    for ($x = 0; $x -lt $comp.Width; $x++) {
        $pComp = $comp.GetPixel($x, $y)
        $pCont = $cont.GetPixel($x, $y)
        $pImp = $imp.GetPixel($x, $y)

        # If it is in composite and NOT in container and NOT in import, it's easy!
        if ($pComp.A -gt 10 -and $pCont.A -eq 0 -and $pImp.A -eq 0) {
            $easyBmp.SetPixel($x, $y, $pComp)
        }
    }
}

$easyBmp.Save((Resolve-Path ".").Path + "\hero-text-easy.png", [System.Drawing.Imaging.ImageFormat]::Png)

$easyBmp.Dispose()
$imp.Dispose()
$cont.Dispose()
$comp.Dispose()

Write-Host "hero-text-easy.png created!"
