class ApiConstants {
  // URL base de la API - Para dispositivo móvil en red local
  static const String baseUrl = 'http://192.168.1.6:3000/api';

  // Otras opciones (comentadas)
  // static const String baseUrl = 'https://n6sj7k57-3000.brs.devtunnels.ms/api'; // Túnel de desarrollo (requiere configuración)
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Para emulador Android
  // static const String baseUrl = 'https://backend-m4do.onrender.com/api'; // Render deployment
  // static const String baseUrl = 'http://localhost:3000/api'; // Desarrollo local

  // Endpoints de autenticación
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Endpoints de usuarios
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static const String updateProfile = '/users/profile';

  // Endpoints de categorías
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // Endpoints de productos
  static const String products = '/products';
  static String productById(String id) => '/products/$id';

  // Endpoints de pedidos
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderStatus(String id) => '/orders/$id/status';
  static String orderCancel(String id) => '/orders/$id/cancel';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userRole = 'user_role';
  static const String cart = 'shopping_cart';
  static const String isFirstTime = 'is_first_time';
}

class AppTheme {
  static const primaryColor = 0xFF2196F3; // Material Blue
  static const accentColor = 0xFF03DAC6; // Material Teal
  static const errorColor = 0xFFB00020; // Material Red
  static const successColor = 0xFF4CAF50; // Material Green
  static const warningColor = 0xFFFF9800; // Material Orange
}

class AppStrings {
  // Títulos generales
  static const String appName = 'Gestión de Pedidos';
  static const String welcome = 'Bienvenido';
  static const String login = 'Iniciar Sesión';
  static const String register = 'Registrarse';
  static const String logout = 'Cerrar Sesión';

  // Navegación
  static const String home = 'Inicio';
  static const String catalog = 'Catálogo';
  static const String cart = 'Carrito';
  static const String orders = 'Pedidos';
  static const String profile = 'Perfil';

  // Productos
  static const String products = 'Productos';
  static const String categories = 'Categorías';
  static const String addToCart = 'Agregar al Carrito';
  static const String outOfStock = 'Sin Stock';
  static const String price = 'Precio';
  static const String stock = 'Stock';

  // Carrito
  static const String emptyCart = 'Tu carrito está vacío';
  static const String total = 'Total';
  static const String checkout = 'Finalizar Compra';
  static const String quantity = 'Cantidad';

  // Pedidos
  static const String orderHistory = 'Historial de Pedidos';
  static const String orderDetails = 'Detalles del Pedido';
  static const String orderStatus = 'Estado del Pedido';
  static const String createOrder = 'Crear Pedido';
  static const String cancelOrder = 'Cancelar Pedido';

  // Estados de pedido
  static const String pending = 'Pendiente';
  static const String confirmed = 'Confirmado';
  static const String preparing = 'Preparando';
  static const String shipped = 'Enviado';
  static const String delivered = 'Entregado';
  static const String cancelled = 'Cancelado';

  // Mensajes
  static const String loading = 'Cargando...';
  static const String error = 'Error';
  static const String success = 'Éxito';
  static const String noData = 'No hay datos disponibles';
  static const String tryAgain = 'Intentar de nuevo';
  static const String confirm = 'Confirmar';
  static const String cancel = 'Cancelar';

  // Validaciones
  static const String requiredField = 'Este campo es requerido';
  static const String invalidEmail = 'Email inválido';
  static const String passwordTooShort =
      'La contraseña debe tener al menos 6 caracteres';
  static const String passwordsDoNotMatch = 'Las contraseñas no coinciden';
}

class AppDimensions {
  // Padding y margins
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;

  // Icon sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // Avatar sizes
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 96.0;
}
