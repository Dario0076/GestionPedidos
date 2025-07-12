# 🔧 Cómo Activar el Túnel de Desarrollo

## Para que el profesor pueda acceder desde su máquina:

### 1. En VS Code:
1. Abre la paleta de comandos (Ctrl+Shift+P)
2. Busca "Ports: Forward a Port"
3. Ingresa el puerto: `3000`
4. Selecciona "Public" para que sea accesible desde internet
5. El túnel se activará automáticamente

### 2. Alternativa - Comando desde terminal:
```bash
# Instalar la extensión de túneles si no está instalada
code --install-extension ms-vscode.remote-repositories

# Activar el túnel
code tunnel --accept-server-license-terms
```

### 3. Verificar que el túnel esté funcionando:
```bash
curl https://n6sj7t57-3000.usw3.devtunnels.ms/api
```

## URLs finales para el profesor:
- **Swagger**: `https://n6sj7t57-3000.usw3.devtunnels.ms/api/docs`
- **API**: `https://n6sj7t57-3000.usw3.devtunnels.ms/api`

## Si el túnel no funciona:
El profesor puede usar tu IP local: `http://10.200.247.133:3000/api/docs`
(Asegúrate de que ambos estén en la misma red)
