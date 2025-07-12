# Documentación del Proyecto: Gestión de Pedidos

## Descripción General
Este proyecto es un sistema completo de gestión de pedidos con backend en NestJS (Prisma + PostgreSQL) y frontend Flutter/Dart (Android). Incluye autenticación, roles, panel de administración, CRUD, mejoras UI/UX, internacionalización, accesibilidad y despliegue en Render.

## Estructura del Proyecto
- **backend/**: API NestJS, Prisma, migraciones, seed, scripts de Render.
- **frontend/**: App Flutter, soporte Android, internacionalización, providers, widgets, temas, etc.

## Funcionalidades Clave
- Login funcional (admin y usuario regular)
- CRUD completo de productos, categorías, usuarios y pedidos
- Panel de administración
- Sistema de roles (admin/usuario)
- Mejoras UI/UX: tema claro/oscuro, color primario, animaciones, responsive, accesibilidad, i18n
- Test de conexión y creación de usuario de emergencia

## Despliegue y Pruebas
- Backend desplegado en Render con base de datos PostgreSQL
- Frontend configurado para consumir la API de Render
- APK generado y probado en emulador/dispositivo

## Notas Técnicas
- El backend usa JWT para autenticación y Prisma para ORM
- El frontend usa Riverpod, GoRouter, providers personalizados y helpers
- Internacionalización con `flutter_localizations` e `intl`
- Accesibilidad: escalado de texto, feedback háptico, widgets accesibles

## Uso
1. Ejecuta el backend (`npm run start:prod` en backend/)
2. Ejecuta el frontend (`flutter run` en frontend/)
3. Usa los usuarios de prueba:
   - **Admin:** admin@test.com / admin123
   - **Usuario:** user@user.com / user123

---

## Instrucciones para clonar y ejecutar el proyecto

### 1. Clonar el repositorio
```sh
# Clona el repositorio (reemplaza la URL por la de tu monorepo)
git clone https://github.com/tu-usuario/tu-repo-gestion-pedidos.git
cd tu-repo-gestion-pedidos
```

### 2. Backend (NestJS + Prisma)
```sh
cd backend
npm install
# Configura tu .env si es necesario (ver ejemplo en .env.example)
# Ejecuta migraciones y seed si es la primera vez
npx prisma migrate deploy
npx prisma db seed
# Inicia el servidor
npm run start:prod
```

### 3. Frontend (Flutter)
```sh
cd ../frontend
flutter pub get
flutter run
```

### 4. Acceso
- **Admin:** admin@test.com / admin123
- **Usuario:** user@user.com / user123

### 5. Notas
- El backend debe estar corriendo antes de iniciar el frontend.
- Si usas emulador Android, asegúrate de que la API URL apunte a la IP correcta.
- Para producción, configura las variables de entorno y endpoints según tu despliegue.

---
