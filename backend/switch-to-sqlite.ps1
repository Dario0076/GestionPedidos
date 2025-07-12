# Script PowerShell para cambiar a SQLite
Write-Host "🔄 Cambiando a SQLite..." -ForegroundColor Blue

# Copiar el esquema de SQLite
Copy-Item "prisma\schema.sqlite.prisma" "prisma\schema.prisma" -Force

# Actualizar el .env
$envContent = Get-Content ".env" -Raw
$envContent = $envContent -replace 'DATABASE_URL="postgresql://postgres:12345678@localhost:5432/GestionPedidos"', 'DATABASE_URL="file:./dev.db"'
$envContent | Set-Content ".env"

# Generar cliente
Write-Host "📦 Generando cliente Prisma..." -ForegroundColor Yellow
npx prisma generate

# Hacer push a la base de datos
Write-Host "🗃️ Actualizando base de datos..." -ForegroundColor Yellow
npx prisma db push

# Crear datos de prueba
Write-Host "🌱 Creando datos de prueba..." -ForegroundColor Yellow
npx prisma db seed

Write-Host "✅ ¡Cambiado a SQLite!" -ForegroundColor Green
Write-Host "📍 Datos de prueba creados automáticamente" -ForegroundColor Cyan
