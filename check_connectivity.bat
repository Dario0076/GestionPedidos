#!/bin/bash

# Script para verificar conectividad del emulador

echo "🔍 Verificando conectividad..."
echo ""

# Verificar túnel desde la PC
echo "1. Verificando túnel desde PC:"
curl -s -o /dev/null -w "%{http_code}" "https://n6sj7k57-3000.brs.devtunnels.ms/api/health"
echo ""

# Verificar backend local
echo "2. Verificando backend local:"
curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/health"
echo ""

# Mostrar IPs disponibles
echo "3. IPs disponibles:"
ipconfig | findstr /i "IPv4"
echo ""

echo "✅ Verificación completada"
