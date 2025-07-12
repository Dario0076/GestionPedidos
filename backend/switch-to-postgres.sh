#!/bin/bash

# Script para cambiar a PostgreSQL
echo "🔄 Cambiando a PostgreSQL..."

# Copiar el esquema de PostgreSQL
cp prisma/schema.postgres.prisma prisma/schema.prisma

# Actualizar el .env
sed -i 's/DATABASE_URL="file:\.\/dev\.db"/DATABASE_URL="postgresql:\/\/postgres:12345678@localhost:5432\/GestionPedidos"/' .env

# Generar cliente
npx prisma generate

# Hacer push a la base de datos
npx prisma db push

echo "✅ ¡Cambiado a PostgreSQL!"
echo "📍 Recuerda iniciar PostgreSQL si no está ejecutándose"
