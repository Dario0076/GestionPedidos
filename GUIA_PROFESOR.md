# 🎓 Guía para el Profesor - Testing del Backend

## 📋 Información del Proyecto

**Estudiante**: [Tu Nombre]
**Proyecto**: Sistema de Gestión de Pedidos
**Backend**: NestJS con Prisma ORM
**Base de Datos**: SQLite (desarrollo) / PostgreSQL (producción)

## 🌐 URLs de Acceso

### Túnel de Desarrollo (Principal)
- **API**: `https://n6sj7t57-3000.usw3.devtunnels.ms/api`
- **Swagger**: `https://n6sj7t57-3000.usw3.devtunnels.ms/api/docs`

### Respaldo (IP Local)
- **API**: `http://10.200.247.133:3000/api`
- **Swagger**: `http://10.200.247.133:3000/api/docs`

## 🔐 Credenciales de Prueba

### Administrador (Acceso completo)
```json
{
  "email": "admin@admin.com",
  "password": "admin123"
}
```

### Usuario Regular
```json
{
  "email": "user@user.com",
  "password": "user123"
}
```

## 🧪 Testing con Swagger

### 1. Acceder a Swagger UI
```
URL: https://n6sj7t57-3000.usw3.devtunnels.ms/api/docs
```

### 2. Autenticación
1. Ir al endpoint `POST /api/auth/login`
2. Usar las credenciales de admin
3. Copiar el `access_token` de la respuesta
4. Hacer clic en "Authorize" en Swagger
5. Ingresa: `Bearer {access_token}`

### 3. Endpoints Disponibles para Testing

#### 🔑 Autenticación
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/register` - Registrar usuario

#### 📦 Productos (CRUD Completo)
- `GET /api/products` - Listar productos
- `POST /api/products` - Crear producto (requiere auth admin)
- `GET /api/products/{id}` - Obtener producto específico
- `PATCH /api/products/{id}` - Actualizar producto (requiere auth admin)
- `DELETE /api/products/{id}` - Eliminar producto (LÓGICO, requiere auth admin)

#### 🏷️ Categorías (CRUD Completo)
- `GET /api/categories` - Listar categorías
- `POST /api/categories` - Crear categoría (requiere auth admin)
- `GET /api/categories/{id}` - Obtener categoría específica
- `PATCH /api/categories/{id}` - Actualizar categoría (requiere auth admin)
- `DELETE /api/categories/{id}` - Eliminar categoría (LÓGICO, requiere auth admin)

#### 📋 Pedidos (CRUD Completo)
- `GET /api/orders` - Listar pedidos del usuario
- `POST /api/orders` - Crear pedido (requiere auth)
- `GET /api/orders/{id}` - Obtener pedido específico
- `PATCH /api/orders/{id}/status` - Actualizar estado (requiere auth admin)
- `PATCH /api/orders/{id}/cancel` - Cancelar pedido

#### 👥 Usuarios (CRUD Completo)
- `GET /api/users` - Listar usuarios (requiere auth admin)
- `GET /api/users/{id}` - Obtener usuario específico
- `PATCH /api/users/{id}` - Actualizar usuario

## 📝 Ejemplos de Prueba

### Crear Producto
```json
{
  "name": "Producto de Prueba",
  "description": "Descripción del producto",
  "price": 29.99,
  "stock": 100,
  "categoryId": "cm3abc123def456ghi789jkl"
}
```

### Crear Categoría
```json
{
  "name": "Categoría de Prueba",
  "description": "Descripción de la categoría"
}
```

### Crear Pedido
```json
{
  "items": [
    {
      "productId": "cm3abc123def456ghi789jkl",
      "quantity": 2,
      "price": 29.99
    }
  ],
  "total": 59.98
}
```

## ✅ Verificaciones Importantes

### 1. Eliminación Lógica (No Física)
- Al eliminar un producto o categoría, NO se borra de la base de datos
- Se marca como `isActive: false`
- Se actualiza la fecha `updatedAt`
- No aparece en las consultas normales

### 2. Autorización por Roles
- **Usuarios normales**: Solo pueden ver productos y crear pedidos
- **Administradores**: Pueden gestionar productos, categorías y usuarios

### 3. Validaciones
- Todos los campos requeridos son validados
- Precios deben ser positivos
- Stock debe ser mayor o igual a 0
- Emails deben ser válidos

## 🔧 Características Técnicas

### Tecnologías Utilizadas
- **Framework**: NestJS (Node.js)
- **ORM**: Prisma
- **Base de Datos**: SQLite (desarrollo) / PostgreSQL (producción)
- **Autenticación**: JWT
- **Documentación**: Swagger/OpenAPI
- **Validación**: Class-validator

### Patrones Implementados
- **Repository Pattern**: Para acceso a datos
- **DTO Pattern**: Para validación de entrada
- **Decorator Pattern**: Para autenticación y autorización
- **Singleton Pattern**: Para servicios

## 🚨 Solución de Problemas

### Si el túnel no funciona:
1. Usar la IP local: `http://10.200.247.133:3000/api/docs`
2. Verificar que el backend esté ejecutándose
3. Asegurar que no hay firewall bloqueando el puerto 3000

### Si falla la autenticación:
1. Verificar que se esté usando `Bearer {token}` en Authorization
2. Verificar que las credenciales sean correctas
3. El token expira en 7 días

### Si no aparecen datos:
1. Los datos de prueba se crean automáticamente
2. Verificar que la base de datos SQLite esté presente
3. Ejecutar `npm run db:sqlite` si es necesario

## 📊 Datos de Prueba Incluidos

- **3 Categorías**: Electrónicos, Ropa, Hogar
- **9 Productos**: Varios productos en cada categoría
- **2 Usuarios**: Admin y usuario regular
- **Pedidos de ejemplo**: Para testing completo

---

**¡El sistema está completamente funcional y listo para evaluación!** 🚀

Todos los endpoints CRUD funcionan correctamente con eliminación lógica, autorización por roles, y validaciones completas.
