Set-Location $PSScriptRoot
if (!(Test-Path "WebContent/WEB-INF/classes")) {
    New-Item -ItemType Directory -Force -Path "WebContent/WEB-INF/classes" | Out-Null
}

$files = (Get-ChildItem -Path "src" -Filter "*.java" -Recurse).FullName
$javac = "C:\Program Files\Java\jdk-26.0.2\bin\javac.exe"

& $javac -cp "WebContent/WEB-INF/lib/*" -d "WebContent/WEB-INF/classes" $files
if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] All Java source files compiled successfully with ZERO errors!"
} else {
    Write-Host "[ERROR] Compilation failed with code $LASTEXITCODE"
}
