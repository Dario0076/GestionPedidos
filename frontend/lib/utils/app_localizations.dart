import 'package:flutter/material.dart';

class AppLocalizations {
  final String localeName;

  AppLocalizations(this.localeName);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      // General
      'app_name': 'Order Management',
      'welcome': 'Welcome',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'settings': 'Settings',
      'logout': 'Logout',
      
      // Authentication
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'login_button': 'Sign In',
      'login_error': 'Invalid credentials',
      'login_success': 'Login successful',
      'email_required': 'Email is required',
      'password_required': 'Password is required',
      'invalid_email': 'Invalid email format',
      
      // Orders
      'orders': 'Orders',
      'order': 'Order',
      'new_order': 'New Order',
      'order_details': 'Order Details',
      'order_status': 'Order Status',
      'order_date': 'Order Date',
      'order_total': 'Total',
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
      'order_created': 'Order created successfully',
      'order_updated': 'Order updated successfully',
      'order_deleted': 'Order deleted successfully',
      
      // Products
      'products': 'Products',
      'product': 'Product',
      'product_name': 'Product Name',
      'product_price': 'Price',
      'product_description': 'Description',
      'product_category': 'Category',
      'add_product': 'Add Product',
      'edit_product': 'Edit Product',
      'product_added': 'Product added successfully',
      'product_updated': 'Product updated successfully',
      'product_deleted': 'Product deleted successfully',
      
      // Categories
      'categories': 'Categories',
      'category': 'Category',
      'category_name': 'Category Name',
      'add_category': 'Add Category',
      'edit_category': 'Edit Category',
      'category_added': 'Category added successfully',
      'category_updated': 'Category updated successfully',
      'category_deleted': 'Category deleted successfully',
      
      // Users
      'users': 'Users',
      'user': 'User',
      'user_name': 'Name',
      'user_email': 'Email',
      'user_role': 'Role',
      'admin': 'Administrator',
      'user_role_user': 'User',
      'add_user': 'Add User',
      'edit_user': 'Edit User',
      'user_added': 'User added successfully',
      'user_updated': 'User updated successfully',
      'user_deleted': 'User deleted successfully',
      
      // Dashboard
      'dashboard': 'Dashboard',
      'total_orders': 'Total Orders',
      'total_products': 'Total Products',
      'total_categories': 'Total Categories',
      'recent_orders': 'Recent Orders',
      
      // Theme & Settings
      'theme_settings': 'Theme Settings',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'system_theme': 'System Theme',
      'color_scheme': 'Color Scheme',
      'blue': 'Blue',
      'green': 'Green',
      'purple': 'Purple',
      'orange': 'Orange',
      'red': 'Red',
      'font_size': 'Font Size',
      'small': 'Small',
      'medium': 'Medium',
      'large': 'Large',
      
      // Accessibility
      'accessibility': 'Accessibility',
      'high_contrast': 'High Contrast',
      'screen_reader': 'Screen Reader',
      'vibration': 'Vibration',
      'sounds': 'Sounds',
      'animation_speed': 'Animation Speed',
      'text_scale': 'Text Scale',
      
      // Navigation
      'home': 'Home',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'about': 'About',
      'language': 'Language',
      'theme': 'Theme',
      
      // Validation
      'field_required': 'This field is required',
      'min_length': 'Minimum {count} characters required',
      'max_length': 'Maximum {count} characters allowed',
      'invalid_format': 'Invalid format',
      
      // Network
      'network_error': 'Network connection error',
      'server_error': 'Server error',
      'timeout_error': 'Request timeout',
      'no_internet': 'No internet connection',
      
      // Permissions
      'permission_denied': 'Permission denied',
      'access_denied': 'Access denied',
      'unauthorized': 'Unauthorized access',
    },
    'es': {
      // General
      'app_name': 'Gestión de Pedidos',
      'welcome': 'Bienvenido',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'add': 'Agregar',
      'search': 'Buscar',
      'loading': 'Cargando...',
      'error': 'Error',
      'success': 'Éxito',
      'confirm': 'Confirmar',
      'yes': 'Sí',
      'no': 'No',
      'settings': 'Configuración',
      'logout': 'Cerrar Sesión',
      
      // Authentication
      'login': 'Iniciar Sesión',
      'email': 'Correo Electrónico',
      'password': 'Contraseña',
      'login_button': 'Ingresar',
      'login_error': 'Credenciales inválidas',
      'login_success': 'Inicio de sesión exitoso',
      'email_required': 'El correo electrónico es requerido',
      'password_required': 'La contraseña es requerida',
      'invalid_email': 'Formato de correo inválido',
      
      // Orders
      'orders': 'Pedidos',
      'order': 'Pedido',
      'new_order': 'Nuevo Pedido',
      'order_details': 'Detalles del Pedido',
      'order_status': 'Estado del Pedido',
      'order_date': 'Fecha del Pedido',
      'order_total': 'Total',
      'pending': 'Pendiente',
      'confirmed': 'Confirmado',
      'delivered': 'Entregado',
      'cancelled': 'Cancelado',
      'order_created': 'Pedido creado exitosamente',
      'order_updated': 'Pedido actualizado exitosamente',
      'order_deleted': 'Pedido eliminado exitosamente',
      
      // Products
      'products': 'Productos',
      'product': 'Producto',
      'product_name': 'Nombre del Producto',
      'product_price': 'Precio',
      'product_description': 'Descripción',
      'product_category': 'Categoría',
      'add_product': 'Agregar Producto',
      'edit_product': 'Editar Producto',
      'product_added': 'Producto agregado exitosamente',
      'product_updated': 'Producto actualizado exitosamente',
      'product_deleted': 'Producto eliminado exitosamente',
      
      // Categories
      'categories': 'Categorías',
      'category': 'Categoría',
      'category_name': 'Nombre de la Categoría',
      'add_category': 'Agregar Categoría',
      'edit_category': 'Editar Categoría',
      'category_added': 'Categoría agregada exitosamente',
      'category_updated': 'Categoría actualizada exitosamente',
      'category_deleted': 'Categoría eliminada exitosamente',
      
      // Users
      'users': 'Usuarios',
      'user': 'Usuario',
      'user_name': 'Nombre',
      'user_email': 'Correo',
      'user_role': 'Rol',
      'admin': 'Administrador',
      'user_role_user': 'Usuario',
      'add_user': 'Agregar Usuario',
      'edit_user': 'Editar Usuario',
      'user_added': 'Usuario agregado exitosamente',
      'user_updated': 'Usuario actualizado exitosamente',
      'user_deleted': 'Usuario eliminado exitosamente',
      
      // Dashboard
      'dashboard': 'Panel de Control',
      'total_orders': 'Total de Pedidos',
      'total_products': 'Total de Productos',
      'total_categories': 'Total de Categorías',
      'recent_orders': 'Pedidos Recientes',
      
      // Theme & Settings
      'theme_settings': 'Configuración de Tema',
      'dark_mode': 'Modo Oscuro',
      'light_mode': 'Modo Claro',
      'system_theme': 'Tema del Sistema',
      'color_scheme': 'Esquema de Colores',
      'blue': 'Azul',
      'green': 'Verde',
      'purple': 'Morado',
      'orange': 'Naranja',
      'red': 'Rojo',
      'font_size': 'Tamaño de Fuente',
      'small': 'Pequeño',
      'medium': 'Mediano',
      'large': 'Grande',
      
      // Accessibility
      'accessibility': 'Accesibilidad',
      'high_contrast': 'Alto Contraste',
      'screen_reader': 'Lector de Pantalla',
      'vibration': 'Vibración',
      'sounds': 'Sonidos',
      'animation_speed': 'Velocidad de Animación',
      'text_scale': 'Escala de Texto',
      
      // Navigation
      'home': 'Inicio',
      'profile': 'Perfil',
      'notifications': 'Notificaciones',
      'about': 'Acerca de',
      'language': 'Idioma',
      'theme': 'Tema',
      
      // Validation
      'field_required': 'Este campo es requerido',
      'min_length': 'Se requieren mínimo {count} caracteres',
      'max_length': 'Máximo {count} caracteres permitidos',
      'invalid_format': 'Formato inválido',
      
      // Network
      'network_error': 'Error de conexión de red',
      'server_error': 'Error del servidor',
      'timeout_error': 'Tiempo de espera agotado',
      'no_internet': 'Sin conexión a internet',
      
      // Permissions
      'permission_denied': 'Permiso denegado',
      'access_denied': 'Acceso denegado',
      'unauthorized': 'Acceso no autorizado',
    },
  };

  String translate(String key, {Map<String, String>? params}) {
    String? translation = _localizedValues[localeName]?[key];
    
    translation ??= _localizedValues['en']?[key] ?? key;
    
    // Reemplazar parámetros si existen
    if (params != null) {
      params.forEach((key, value) {
        translation = translation?.replaceAll('{$key}', value);
      });
    }
    
    return translation ?? key;
  }

  // Getter shortcuts para traducir fácilmente
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get search => translate('search');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get settings => translate('settings');
  String get logout => translate('logout');
  
  // Auth
  String get login => translate('login');
  String get email => translate('email');
  String get password => translate('password');
  String get loginButton => translate('login_button');
  String get loginError => translate('login_error');
  String get loginSuccess => translate('login_success');
  
  // Orders
  String get orders => translate('orders');
  String get newOrder => translate('new_order');
  String get orderDetails => translate('order_details');
  String get pending => translate('pending');
  String get confirmed => translate('confirmed');
  String get delivered => translate('delivered');
  String get cancelled => translate('cancelled');
  
  // Products
  String get products => translate('products');
  String get productName => translate('product_name');
  String get productPrice => translate('product_price');
  String get addProduct => translate('add_product');
  
  // Categories
  String get categories => translate('categories');
  String get categoryName => translate('category_name');
  String get addCategory => translate('add_category');
  
  // Users
  String get users => translate('users');
  String get userName => translate('user_name');
  String get userEmail => translate('user_email');
  String get admin => translate('admin');
  
  // Dashboard
  String get dashboard => translate('dashboard');
  String get totalOrders => translate('total_orders');
  String get totalProducts => translate('total_products');
  String get recentOrders => translate('recent_orders');
  
  // Theme
  String get themeSettings => translate('theme_settings');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get colorScheme => translate('color_scheme');
  
  // Navigation
  String get home => translate('home');
  String get profile => translate('profile');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['es', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
