# 🎓 Guía de Presentación - Sistema de Gestión de Pedidos

## 📋 Estado Actual del Sistema

✅ **Backend**: SQLite configurado correctamente
✅ **Frontend**: Flutter con múltiples configuraciones de URL  
✅ **API**: Swagger funcionando
✅ **APK**: Generado y listo para instalar

## 🚀 Preparación para Presentación

### 1. Configuración del Backend

**Tu configuración actual:**
- Base de datos: SQLite (archivo local)
- Puerto: 3000
- Swagger: Disponible

**Ventajas para presentación:**
- ✅ No depende de PostgreSQL
- ✅ Base de datos portátil
- ✅ Datos de prueba incluidos
- ✅ Funciona offline

### 2. Configuración del Frontend

**URLs disponibles en tu app:**
```dart
// Producción (Render)
static const String baseUrl = 'https://backend-m4do.onrender.com/api';

// Opciones locales comentadas:
// static const String baseUrl = 'http://192.168.1.4:3000/api'; // IP local
// static const String baseUrl = 'http://10.0.2.2:3000/api'; // Emulador Android
// static const String baseUrl = 'http://localhost:3000/api'; // Desarrollo local
```

## 🔧 Configuración Según Escenario

### Escenario 1: Presentación con tu Laptop + Teléfono

**Pasos:**
1. Obtener IP de tu laptop:
   ```bash
   ipconfig | findstr "IPv4"
   ```

2. Cambiar URL en `constants.dart`:
   ```dart
   static const String baseUrl = 'http://[TU-IP]:3000/api';
   ```

3. Recompilar APK:
   ```bash
   cd frontend
   flutter build apk --release
   ```

### Escenario 2: Presentación con Emulador

**Configuración automática:**
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

### Escenario 3: Presentación usando Render (Online)

**Configuración actual:**
```dart
static const String baseUrl = 'https://backend-m4do.onrender.com/api';
```

## 📱 Scripts de Configuración Rápida

Voy a crear scripts que te permitan cambiar rápidamente entre configuraciones:

### Para IP Local (Teléfono):
```bash
# Obtener IP automáticamente y configurar
npm run setup-mobile
```

### Para Emulador:
```bash
# Configurar para emulador
npm run setup-emulator
```

### Para Online:
```bash
# Configurar para Render
npm run setup-online
```

## 📊 Credenciales de Prueba

**Administrador:**
- Email: `admin@admin.com`
- Password: `admin123`

**Usuario Regular:**
- Email: `user@user.com`
- Password: `user123`

## 🎯 Flujo de Presentación Recomendado

### 1. Demo Backend (Swagger)
1. Mostrar Swagger UI: `http://localhost:3000/api/docs`
2. Hacer login con admin
3. Mostrar endpoints disponibles
4. Probar CRUD de productos

### 2. Demo App Móvil
1. Mostrar login
2. Navegar por el catálogo
3. Agregar al carrito
4. Realizar pedido
5. Mostrar historial

### 3. Demo Admin
1. Login como admin
2. Gestionar productos
3. Ver pedidos
4. Cambiar estados

## 🔍 Verificación Pre-Presentación

### Checklist Backend:
```bash
# 1. Verificar servidor
curl http://localhost:3000/api

# 2. Verificar Swagger
curl http://localhost:3000/api/docs

# 3. Verificar datos
curl http://localhost:3000/api/products
```

### Checklist Frontend:
```bash
# 1. Verificar compilación
flutter doctor

# 2. Verificar conexión
flutter run
```

## 🚨 Solución de Problemas Durante Presentación

### Si no hay internet:
- Usar configuración local
- Backend funciona offline con SQLite

### Si cambia la IP:
- Usar script de configuración rápida
- Recompilar APK si es necesario

### Si falla la conexión:
- Verificar firewall
- Usar localhost para emulador
- Verificar que ambos estén en la misma red

## 📋 Respaldo de Configuraciones

Todas las configuraciones están comentadas en `constants.dart`, solo necesitas descomentar la línea apropiada.

## 🎯 Puntos Clave para Destacar

1. **Arquitectura completa**: Frontend Flutter + Backend NestJS
2. **Base de datos**: Prisma ORM con SQLite/PostgreSQL
3. **Autenticación**: JWT con roles de usuario
4. **Documentación**: Swagger UI completa
5. **Internacionalización**: Español/Inglés
6. **Responsive**: Funciona en móvil y web
7. **Containerización**: Docker listo para producción

---

**¡Tu sistema está 100% listo para presentar!** 🚀

Todo funcionará perfectamente mientras tengas:
- Tu laptop con el backend ejecutándose
- La IP correcta configurada en la app
- Los dispositivos en la misma red (para conexión local)
