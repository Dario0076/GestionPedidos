# Guía de Transaccionabilidad - Sistema de Gestión de Pedidos

## ¿Qué es la Transaccionabilidad?

La transaccionabilidad es un conjunto de propiedades que garantizan que las operaciones de base de datos se ejecuten de forma confiable y consistente. Se basa en las propiedades **ACID**:

### Propiedades ACID

1. **Atomicidad (A)**: Una transacción es "todo o nada"
   - Si cualquier parte de la transacción falla, TODA la transacción se revierte
   - No se permiten estados parciales

2. **Consistencia (C)**: Los datos mantienen su integridad
   - Las reglas de negocio se respetan siempre
   - Los datos pasan de un estado válido a otro estado válido

3. **Aislamiento (I)**: Las transacciones no se interfieren
   - Cada transacción se ejecuta como si fuera la única
   - Los cambios no confirmados no son visibles para otras transacciones

4. **Durabilidad (D)**: Los cambios persisten
   - Una vez confirmada, la transacción sobrevive a fallos del sistema
   - Los datos se guardan permanentemente

## Implementación en nuestro Backend

Hemos implementado 4 endpoints que demuestran transaccionabilidad:

### 1. Crear Pedido con Transacción
**Endpoint:** `POST /transactions/create-order`

```typescript
// Ejemplo de uso atómico: crear pedido Y actualizar stock
await this.prisma.$transaction(async (prisma) => {
  // 1. Verificar stock disponible
  const product = await prisma.product.findUnique({
    where: { id: createOrderDto.productId }
  });

  if (product.stock < createOrderDto.quantity) {
    throw new Error('Stock insuficiente'); // Revierte TODO
  }

  // 2. Crear el pedido
  const order = await prisma.order.create({
    data: { /* datos del pedido */ }
  });

  // 3. Actualizar el stock
  const updatedProduct = await prisma.product.update({
    where: { id: product.id },
    data: { stock: product.stock - createOrderDto.quantity }
  });

  // Si llegamos aquí, TODO fue exitoso
  return { order, updatedProduct };
});
```

**Payload de ejemplo:**
```json
{
  "productId": "clxxxxx",
  "quantity": 2,
  "userId": "clxxxxx"
}
```

### 2. Demostrar Fallo de Transacción
**Endpoint:** `POST /transactions/create-order-with-failure`

```typescript
// Demuestra cómo se revierte una transacción al fallar
await this.prisma.$transaction(async (prisma) => {
  // 1. Crear pedido (esto SÍ se ejecuta)
  const order = await prisma.order.create({
    data: { /* datos del pedido */ }
  });

  // 2. Simular error - REVIERTE TODO
  throw new Error('Error simulado');

  // El pedido NO se guarda en la base de datos
});
```

### 3. Transferir Stock entre Productos
**Endpoint:** `POST /transactions/transfer-stock/:fromId/:toId/:quantity`
**Requiere:** Token JWT con rol ADMIN

```typescript
// Transacción compleja: transferir stock de un producto a otro
await this.prisma.$transaction(async (prisma) => {
  // 1. Verificar stock del producto origen
  const fromProduct = await prisma.product.findUnique({
    where: { id: fromProductId }
  });

  if (fromProduct.stock < quantity) {
    throw new Error('Stock insuficiente'); // Revierte TODO
  }

  // 2. Reducir stock del producto origen
  await prisma.product.update({
    where: { id: fromProductId },
    data: { stock: fromProduct.stock - quantity }
  });

  // 3. Aumentar stock del producto destino
  await prisma.product.update({
    where: { id: toProductId },
    data: { stock: toProduct.stock + quantity }
  });

  // AMBAS operaciones se confirman juntas
});
```

### 4. Estadísticas del Sistema
**Endpoint:** `GET /transactions/stats`
**Requiere:** Token JWT con rol ADMIN

```typescript
// Lectura transaccional para garantizar consistencia
await this.prisma.$transaction(async (prisma) => {
  const totalOrders = await prisma.order.count();
  const totalProducts = await prisma.product.count();
  const totalUsers = await prisma.user.count();
  const totalRevenue = await prisma.order.aggregate({
    _sum: { total: true }
  });

  // Todos los datos son consistentes al mismo momento
  return { totalOrders, totalProducts, totalUsers, totalRevenue };
});
```

## Cómo Probar en Swagger

1. **Acceder a Swagger:**
   ```
   https://n6sj7k57-3000.brs.devtunnels.ms/api/docs
   ```

2. **Autenticarse:**
   - Ir a `/auth/login`
   - Usar credenciales: `admin@example.com` / `admin123`
   - Copiar el token JWT
   - Hacer clic en "Authorize" y pegar el token

3. **Probar Transacciones:**

### Ejemplo 1: Crear Pedido Exitoso
```bash
POST /transactions/create-order
{
  "productId": "clxxxxx", // ID de un producto existente
  "quantity": 1,
  "userId": "clxxxxx"    // ID de un usuario existente
}
```

### Ejemplo 2: Demostrar Fallo
```bash
POST /transactions/create-order-with-failure
{
  "productId": "clxxxxx",
  "quantity": 1,
  "userId": "clxxxxx"
}
```

### Ejemplo 3: Transferir Stock (requiere ADMIN)
```bash
POST /transactions/transfer-stock/{fromId}/{toId}/5
```

### Ejemplo 4: Ver Estadísticas (requiere ADMIN)
```bash
GET /transactions/stats
```

## Conceptos Clave para Explicar

### 1. Atomicidad en Acción
```typescript
// Si CUALQUIER operación falla, TODA la transacción se revierte
await prisma.$transaction(async (prisma) => {
  await prisma.order.create({...});     // ✅ Éxito
  await prisma.product.update({...});   // ✅ Éxito
  await prisma.user.update({...});      // ❌ Falla
  
  // Resultado: NADA se guarda, todo se revierte
});
```

### 2. Consistencia de Datos
```typescript
// Los datos siempre mantienen reglas de negocio
if (product.stock < quantity) {
  throw new Error('Stock insuficiente'); // Previene inconsistencias
}
```

### 3. Aislamiento
```typescript
// Cada transacción ve un estado consistente
await prisma.$transaction(async (prisma) => {
  // Esta transacción no ve cambios no confirmados de otras transacciones
  const product = await prisma.product.findUnique({...});
  // El stock que vemos es consistente durante toda la transacción
});
```

### 4. Durabilidad
```typescript
// Una vez confirmada, la transacción persiste
const result = await prisma.$transaction(async (prisma) => {
  // Todas estas operaciones se guardan permanentemente
  return await prisma.order.create({...});
});
// El pedido YA está guardado en la base de datos
```

## Escenarios de Prueba

### Escenario 1: Stock Insuficiente
1. Crear un producto con stock = 5
2. Intentar crear un pedido con quantity = 10
3. **Resultado:** Error y NO se crea el pedido

### Escenario 2: Transferencia Exitosa
1. Producto A: stock = 10
2. Producto B: stock = 5
3. Transferir 3 unidades de A a B
4. **Resultado:** A = 7, B = 8

### Escenario 3: Fallo Simulado
1. Intentar crear pedido con endpoint de fallo
2. **Resultado:** Error y NO se crea nada

## Ventajas de las Transacciones

1. **Confiabilidad:** Garantiza que los datos estén siempre en un estado válido
2. **Recuperación:** Si algo falla, el sistema vuelve al estado anterior
3. **Concurrencia:** Múltiples usuarios pueden usar el sistema simultáneamente
4. **Integridad:** Las reglas de negocio se respetan siempre

## Tecnologías Utilizadas

- **Prisma ORM:** Manejo de transacciones con `$transaction()`
- **NestJS:** Framework para la estructura y decoradores
- **TypeScript:** Tipado fuerte para mayor seguridad
- **Swagger:** Documentación interactiva para pruebas
- **JWT:** Autenticación y autorización

## Credenciales de Prueba

**Usuario Admin:**
- Email: `admin@example.com`
- Password: `admin123`
- Rol: `ADMIN`

**Usuario Regular:**
- Email: `user@example.com`
- Password: `user123`
- Rol: `USER`

---
*Esta implementación demuestra los principios fundamentales de transaccionabilidad en sistemas de gestión de datos, garantizando la integridad y consistencia de la información.*
