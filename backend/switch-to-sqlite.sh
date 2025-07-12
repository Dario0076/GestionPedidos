#!/bin/bash

# Script para cambiar a SQLite
echo "🔄 Cambiando a SQLite..."

# Copiar el esquema de SQLite
cp prisma/schema.sqlite.prisma prisma/schema.prisma

# Actualizar el .env
sed -i 's/DATABASE_URL="postgresql:\/\/postgres:12345678@localhost:5432\/GestionPedidos"/DATABASE_URL="file:\.\/dev\.db"/' .env

# Generar cliente
npx prisma generate

# Hacer push a la base de datos
npx prisma db push

# Crear datos de prueba
npx prisma db seed

echo "✅ ¡Cambiado a SQLite!"
echo "📍 Datos de prueba creados automáticamente"
