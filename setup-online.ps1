# Script para configurar para Render (online)
Write-Host "🔧 Configurando para Render (online)..." -ForegroundColor Blue

# Ruta al archivo constants.dart
$constantsFile = ".\frontend\lib\utils\constants.dart"

if (Test-Path $constantsFile) {
    # Leer el archivo
    $content = Get-Content $constantsFile -Raw
    
    # Comentar todas las otras líneas
    $content = $content -replace "static const String baseUrl = 'http://192\.168\.\d+\.\d+:3000/api';", "// static const String baseUrl = 'http://192.168.1.4:3000/api';"
    $content = $content -replace "static const String baseUrl = 'http://10\.0\.2\.2:3000/api';", "// static const String baseUrl = 'http://10.0.2.2:3000/api';"
    $content = $content -replace "static const String baseUrl = 'http://localhost:3000/api';", "// static const String baseUrl = 'http://localhost:3000/api';"
    
    # Activar la línea de Render
    $content = $content -replace "// static const String baseUrl = 'https://backend-m4do.onrender.com/api';", "static const String baseUrl = 'https://backend-m4do.onrender.com/api';"
    
    # Guardar el archivo
    $content | Set-Content $constantsFile
    
    Write-Host "✅ Configuración actualizada para Render" -ForegroundColor Green
    Write-Host "🌐 URL configurada: https://backend-m4do.onrender.com/api" -ForegroundColor Cyan
    Write-Host "🎯 Listo para usar online (requiere internet)" -ForegroundColor Green
    
} else {
    Write-Host "❌ No se encontró el archivo constants.dart" -ForegroundColor Red
}
