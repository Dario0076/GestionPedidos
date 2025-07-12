# Script PowerShell para cambiar a PostgreSQL
Write-Host "🔄 Cambiando a PostgreSQL..." -ForegroundColor Blue

# Copiar el esquema de PostgreSQL
Copy-Item "prisma\schema.postgres.prisma" "prisma\schema.prisma" -Force

# Actualizar el .env
$envContent = Get-Content ".env" -Raw
$envContent = $envContent -replace 'DATABASE_URL="file:\.\/dev\.db"', 'DATABASE_URL="postgresql://postgres:12345678@localhost:5432/GestionPedidos"'
$envContent | Set-Content ".env"

# Generar cliente
Write-Host "📦 Generando cliente Prisma..." -ForegroundColor Yellow
npx prisma generate

# Hacer push a la base de datos
Write-Host "🗃️ Actualizando base de datos..." -ForegroundColor Yellow
npx prisma db push

Write-Host "✅ ¡Cambiado a PostgreSQL!" -ForegroundColor Green
Write-Host "📍 Recuerda iniciar PostgreSQL si no está ejecutándose" -ForegroundColor Cyan
