# Script para configurar para emulador
Write-Host "🔧 Configurando para emulador Android..." -ForegroundColor Blue

# Ruta al archivo constants.dart
$constantsFile = ".\frontend\lib\utils\constants.dart"

if (Test-Path $constantsFile) {
    # Leer el archivo
    $content = Get-Content $constantsFile -Raw
    
    # Comentar todas las otras líneas
    $content = $content -replace "static const String baseUrl = 'https://backend-m4do.onrender.com/api';", "// static const String baseUrl = 'https://backend-m4do.onrender.com/api';"
    $content = $content -replace "static const String baseUrl = 'http://192\.168\.\d+\.\d+:3000/api';", "// static const String baseUrl = 'http://192.168.1.4:3000/api';"
    $content = $content -replace "static const String baseUrl = 'http://localhost:3000/api';", "// static const String baseUrl = 'http://localhost:3000/api';"
    
    # Activar la línea del emulador
    $content = $content -replace "// static const String baseUrl = 'http://10\.0\.2\.2:3000/api';", "static const String baseUrl = 'http://10.0.2.2:3000/api';"
    
    # Guardar el archivo
    $content | Set-Content $constantsFile
    
    Write-Host "✅ Configuración actualizada para emulador" -ForegroundColor Green
    Write-Host "📱 URL configurada: http://10.0.2.2:3000/api" -ForegroundColor Cyan
    Write-Host "🎯 Listo para usar con emulador Android" -ForegroundColor Green
    
} else {
    Write-Host "❌ No se encontró el archivo constants.dart" -ForegroundColor Red
}
