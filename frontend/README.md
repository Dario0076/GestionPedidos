# Sistema de Gestión de Pedidos - Android App

Aplicación móvil para Android desarrollada con Flutter que permite gestionar pedidos de productos de manera intuitiva y eficiente.

## Características

### 🔐 Autenticación
- Registro de nuevos usuarios
- Inicio de sesión seguro
- Gestión de perfil de usuario

### 📱 Funcionalidades principales
- **Catálogo de productos**: Navegación por categorías y búsqueda
- **Carrito de compras**: Agregar/quitar productos, modificar cantidades
- **Gestión de pedidos**: Crear pedidos, seguimiento de estado
- **Historial**: Ver pedidos anteriores y detalles

### 🎨 Interfaz
- Diseño Material Design para Android
- Navegación intuitiva
- Interfaz responsive y moderna
- Manejo de estado con Riverpod

## Instalación y Desarrollo

### Requisitos previos
- Flutter SDK (>=3.8.1)
- Android Studio con SDK de Android
- Dispositivo Android o emulador

### Configuración del proyecto

1. **Instalar dependencias**:
```bash
flutter pub get
```

2. **Configurar conexión con el backend**:
Editar `lib/utils/constants.dart` para apuntar a tu servidor backend.

3. **Ejecutar en Android**:
```bash
# Para dispositivo conectado
flutter run

# Para emulador específico
flutter run -d <device-id>

# Para generar APK de debug
flutter build apk --debug

# Para generar APK de release
flutter build apk --release
```

## Estructura del Proyecto

```
lib/
├── models/          # Modelos de datos (User, Product, Order, etc.)
├── services/        # Servicios HTTP y API
├── screens/         # Pantallas de la aplicación
│   ├── auth/        # Login y registro
│   ├── catalog/     # Catálogo de productos
│   ├── cart/        # Carrito de compras
│   └── orders/      # Historial de pedidos
├── widgets/         # Componentes reutilizables
├── utils/           # Constantes y utilidades
└── main.dart        # Punto de entrada
```

## Pantallas principales

- **🔑 Login/Registro**: Autenticación de usuarios
- **🏠 Home**: Pantalla principal con categorías destacadas
- **📦 Catálogo**: Lista de productos con filtros
- **🛒 Carrito**: Gestión del carrito de compras
- **📋 Pedidos**: Historial y seguimiento de pedidos
- **👤 Perfil**: Gestión de datos personales

## Dependencias principales

- **flutter_riverpod**: Gestión de estado
- **dio**: Cliente HTTP para API REST
- **go_router**: Navegación declarativa
- **shared_preferences**: Almacenamiento local
- **cached_network_image**: Carga optimizada de imágenes

## Conexión con Backend

La aplicación se conecta a la API REST desarrollada en NestJS:
- **Base URL**: `http://localhost:3000/api` (desarrollo)
- **Autenticación**: JWT tokens
- **Endpoints**: CRUD completo para usuarios, productos, categorías y pedidos
