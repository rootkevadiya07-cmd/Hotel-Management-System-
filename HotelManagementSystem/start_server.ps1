$env:JAVA_HOME = "C:\Program Files\Java\jdk-26.0.2"
$env:CATALINA_HOME = "C:\Users\Rahul Prasad\.gemini\antigravity\scratch\apache-tomcat-10.1.61"
$binDir = Join-Path $env:CATALINA_HOME "bin"
$catalina = Join-Path $binDir "catalina.bat"

Write-Host "Starting Apache Tomcat 10.1.61 on port 8080..." -ForegroundColor Cyan
Write-Host "JAVA_HOME: $env:JAVA_HOME"
Write-Host "CATALINA_HOME: $env:CATALINA_HOME"

Set-Location $binDir
& $catalina run
