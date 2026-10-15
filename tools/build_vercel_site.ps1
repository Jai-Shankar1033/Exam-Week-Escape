# Builds the Flutter web game and copies it into vercel-site/ (Windows PowerShell).
# Run from the project root:   .\tools\build_vercel_site.ps1
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

flutter pub get
flutter build web --release
if (-not (Test-Path "build\web\index.html")) { throw "Build failed: build\web\index.html not found" }

# Empty vercel-site (keep its README), then copy the fresh build in.
New-Item -ItemType Directory -Force -Path "vercel-site" | Out-Null
Get-ChildItem "vercel-site" -Force | Where-Object { $_.Name -ne "README.md" } | Remove-Item -Recurse -Force
Copy-Item "build\web\*" "vercel-site" -Recurse -Force

Write-Host ""
Write-Host "Done. vercel-site/ now contains the compiled game." -ForegroundColor Green
Write-Host "Next: git add vercel-site; git commit -m 'Update web build'; git push"
