# Script para configurar automáticamente la IP para presentación móvil
Write-Host "🔧 Configurando IP para presentación móvil..." -ForegroundColor Blue

# Obtener IP automáticamente
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notmatch "Loopback" -and $_.IPAddress -notmatch "^169\.254\."} | Select-Object -First 1).IPAddress

if ($ip) {
    Write-Host "📍 IP detectada: $ip" -ForegroundColor Green
    
    # Ruta al archivo constants.dart
    $constantsFile = ".\frontend\lib\utils\constants.dart"
    
    if (Test-Path $constantsFile) {
        # Leer el archivo
        $content = Get-Content $constantsFile -Raw
        
        # Comentar la línea de Render (la actual)
        $content = $content -replace "static const String baseUrl = 'https://backend-m4do.onrender.com/api';", "// static const String baseUrl = 'https://backend-m4do.onrender.com/api';"
        
        # Descomentar y actualizar la línea de IP local
        $content = $content -replace "// static const String baseUrl = 'http://192\.168\.\d+\.\d+:3000/api';", "static const String baseUrl = 'http://$ip:3000/api';"
        
        # Si no existe la línea, agregarla
        if ($content -notmatch "static const String baseUrl = 'http://$ip:3000/api';") {
            $content = $content -replace "(class ApiConstants \{)", "`$1`n  // IP local para presentación`n  static const String baseUrl = 'http://$ip:3000/api';"
        }
        
        # Guardar el archivo
        $content | Set-Content $constantsFile
        
        Write-Host "✅ Configuración actualizada en constants.dart" -ForegroundColor Green
        Write-Host "📱 URL configurada: http://$ip:3000/api" -ForegroundColor Cyan
        
        # Preguntar si quiere recompilar el APK
        $rebuild = Read-Host "¿Quieres recompilar el APK ahora? (y/n)"
        
        if ($rebuild -eq "y" -or $rebuild -eq "Y") {
            Write-Host "🔨 Recompilando APK..." -ForegroundColor Yellow
            Set-Location ".\frontend"
            flutter clean
            flutter pub get
            flutter build apk --release
            Set-Location ".."
            Write-Host "✅ APK recompilado exitosamente!" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Recuerda recompilar el APK antes de la presentación:" -ForegroundColor Yellow
            Write-Host "   cd frontend" -ForegroundColor White
            Write-Host "   flutter build apk --release" -ForegroundColor White
        }
        
        Write-Host "`n🎯 Listo para presentación:" -ForegroundColor Green
        Write-Host "   • Backend: http://localhost:3000/api" -ForegroundColor White
        Write-Host "   • Swagger: http://localhost:3000/api/docs" -ForegroundColor White
        Write-Host "   • App móvil: http://$ip:3000/api" -ForegroundColor White
        Write-Host "   • APK: frontend\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
        
    } else {
        Write-Host "❌ No se encontró el archivo constants.dart" -ForegroundColor Red
    }
} else {
    Write-Host "❌ No se pudo obtener la IP automáticamente" -ForegroundColor Red
    Write-Host "🔍 Ejecuta 'ipconfig' manualmente y actualiza constants.dart" -ForegroundColor Yellow
}
