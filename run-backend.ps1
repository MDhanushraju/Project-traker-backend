# Run Spring Boot backend with Gradle
$ErrorActionPreference = "Stop"
$ProjectDir = $PSScriptRoot

# Find Java
$JavaExe = $null
if ($env:JAVA_HOME -and (Test-Path (Join-Path $env:JAVA_HOME "bin\java.exe"))) {
    $JavaExe = Join-Path $env:JAVA_HOME "bin\java.exe"
}
if (-not $JavaExe) {
    try { $JavaExe = (Get-Command java -ErrorAction Stop).Source } catch {}
}
if (-not $JavaExe) {
    $jdk21 = Join-Path ${env:ProgramFiles} "Java\jdk-21\bin\java.exe"
    if (Test-Path $jdk21) { $JavaExe = $jdk21 }
}
if (-not $JavaExe) {
    $paths = @(
        "${env:ProgramFiles}\Java\jdk-21*\bin\java.exe",
        "${env:ProgramFiles}\Java\jdk-17*\bin\java.exe",
        "${env:ProgramFiles}\Eclipse Adoptium\jdk-21*\bin\java.exe",
        "${env:ProgramFiles}\Microsoft\jdk-21*\bin\java.exe"
    )
    foreach ($p in $paths) {
        $resolved = Get-Item $p -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($resolved) { $JavaExe = $resolved.FullName; break }
    }
}
if (-not $JavaExe -or -not (Test-Path $JavaExe)) {
    Write-Host "Java not found. Install JDK 21 and ensure it is in PATH or Program Files\Java\" -ForegroundColor Red
    exit 1
}
$env:JAVA_HOME = (Get-Item $JavaExe).Directory.Parent.FullName
Write-Host "Using Java: $JavaExe"

# Gradle: wrapper first, then system
$GradleCmd = $null
$gradlew = Join-Path $ProjectDir "gradlew.bat"
if (Test-Path $gradlew) { $GradleCmd = $gradlew }
if (-not $GradleCmd -and (Get-Command gradle -ErrorAction SilentlyContinue)) { $GradleCmd = "gradle" }
if (-not $GradleCmd) {
    Write-Host "Gradle not found. Use the Gradle wrapper (gradlew.bat) or install Gradle." -ForegroundColor Red
    exit 1
}

# Port check (backend default port from application.yml)
$backendPort = 10000
$port = Get-NetTCPConnection -LocalPort $backendPort -ErrorAction SilentlyContinue | Select-Object -First 1
if ($port) {
    Write-Host "Port $backendPort in use by PID $($port.OwningProcess). Run: Stop-Process -Id $($port.OwningProcess) -Force" -ForegroundColor Yellow
    exit 1
}

Set-Location $ProjectDir

# Load .env.local if present (DATABASE_PASSWORD etc.; file is gitignored)
$envFile = Join-Path $ProjectDir ".env.local"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim() -replace '^["'']|["'']$'
            Set-Item -Path "env:$key" -Value $val
        }
    }
}

# Use 'local' profile so application-local.yml supplies DB username/password for local PostgreSQL (SCRAM auth)
Write-Host "Running: $GradleCmd bootRun --args='--spring.profiles.active=local'" -ForegroundColor Cyan
& $GradleCmd bootRun --args='--spring.profiles.active=local' @args
