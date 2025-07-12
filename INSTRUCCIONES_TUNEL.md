# 🚀 Instrucciones para Activar el Túnel

## Para que el profesor pueda usar los puertos asignados:

### Opción 1: Desde VS Code (Interfaz Gráfica)
1. Abre VS Code con tu proyecto
2. Presiona `Ctrl+Shift+P` (Paleta de comandos)
3. Busca: "Ports: Forward a Port"
4. Ingresa: `3000`
5. Selecciona: "Public"
6. Se generará automáticamente la URL del túnel

### Opción 2: Desde Terminal
```bash
# Desde la carpeta de tu proyecto
code tunnel --accept-server-license-terms
```

### Opción 3: Port Forwarding Manual
```bash
# Usar la extensión Remote Tunnels
code --install-extension ms-vscode.remote-server
```

## 🔍 Verificar que funcione:

Una vez activado, deberías poder acceder a:
- **Swagger**: `https://n6sj7t57-3000.usw3.devtunnels.ms/api/docs`
- **API**: `https://n6sj7t57-3000.usw3.devtunnels.ms/api`

## 📋 Para el Profesor:

**URLs principales:**
- API: `https://n6sj7t57-3000.usw3.devtunnels.ms/api`
- Swagger: `https://n6sj7t57-3000.usw3.devtunnels.ms/api/docs`

**Credenciales:**
- Admin: `admin@admin.com` / `admin123`
- User: `user@user.com` / `user123`

## 🚨 Si el túnel no funciona:

**Respaldo - IP Local:**
- API: `http://10.200.247.133:3000/api`
- Swagger: `http://10.200.247.133:3000/api/docs`

*Nota: La IP local solo funciona si están en la misma red*
