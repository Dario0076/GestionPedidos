import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // Método de login alternativo y simplificado para debugging
  Future<AuthResult> loginSimple(String email, String password) async {
    try {
      print('🔍 AuthService.loginSimple: Starting login for $email');

      // Inicializar ApiService si no está inicializado
      _apiService.init();

      // Hacer la petición de forma muy básica
      final dio = _apiService.dio;
      print('🔍 AuthService.loginSimple: Base URL: ${dio.options.baseUrl}');

      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      print(
        '🔍 AuthService.loginSimple: Response status: ${response.statusCode}',
      );
      print('🔍 AuthService.loginSimple: Response data: ${response.data}');

      // Verificar el status code
      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
          '🔍 AuthService.loginSimple: Invalid status code: ${response.statusCode}',
        );
        return AuthResult.error('Error del servidor: ${response.statusCode}');
      }

      // Verificar que tenemos datos
      if (response.data == null) {
        print('🔍 AuthService.loginSimple: No data received');
        return AuthResult.error('No se recibieron datos del servidor');
      }

      final data = response.data as Map<String, dynamic>;
      print('🔍 AuthService.loginSimple: Data keys: ${data.keys.toList()}');

      // Verificar que tenemos los campos necesarios
      if (!data.containsKey('user') || !data.containsKey('access_token')) {
        print('🔍 AuthService.loginSimple: Missing required fields');
        return AuthResult.error('Respuesta inválida del servidor');
      }

      final userMap = data['user'] as Map<String, dynamic>;
      final token = data['access_token'] as String;

      print('🔍 AuthService.loginSimple: User data: $userMap');
      print('🔍 AuthService.loginSimple: Token length: ${token.length}');

      // Crear el objeto User de forma segura
      final user = User(
        id: userMap['id'] as String,
        email: userMap['email'] as String,
        name: userMap['name'] as String,
        phone: userMap['phone'] as String?,
        address: userMap['address'] as String?,
        role: userMap['role'] as String? ?? 'USER',
        isActive: userMap['isActive'] as bool? ?? true,
        createdAt: userMap['createdAt'] != null
            ? DateTime.parse(userMap['createdAt'] as String)
            : DateTime.now(),
        updatedAt: userMap['updatedAt'] != null
            ? DateTime.parse(userMap['updatedAt'] as String)
            : DateTime.now(),
      );

      print('🔍 AuthService.loginSimple: User object created: ${user.email}');

      // Guardar sesión
      await _saveSession(user, token);
      print('🔍 AuthService.loginSimple: Session saved successfully');

      return AuthResult.success(user, token);
    } catch (e, stackTrace) {
      print('🔍 AuthService.loginSimple: Exception caught: $e');
      print('🔍 AuthService.loginSimple: Stack trace: $stackTrace');
      return AuthResult.error('Error en login simple: $e');
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      print('AuthService: Attempting login for $email');
      print('AuthService: API Base URL: ${ApiConstants.baseUrl}');
      print('AuthService: Making POST request to ${ApiConstants.login}');

      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      print('AuthService: Login response received: ${response.statusCode}');
      print('AuthService: Response headers: ${response.headers}');
      print('AuthService: Response data type: ${response.data.runtimeType}');
      print('AuthService: Raw response data: ${response.data}');

      // Validar que la respuesta es exitosa (200 o 201)
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('AuthService: Unexpected status code: ${response.statusCode}');
        return AuthResult.error('Error del servidor: ${response.statusCode}');
      }

      // Asegurar que tenemos un Map válido
      if (response.data == null) {
        print('AuthService: Response data is null');
        return AuthResult.error('Respuesta vacía del servidor');
      }

      final data = response.data as Map<String, dynamic>;
      print('AuthService: Parsed data keys: ${data.keys.toList()}');

      // Validar estructura de la respuesta
      if (!data.containsKey('user') || !data.containsKey('access_token')) {
        print('AuthService: Missing required fields in response');
        print('AuthService: Available fields: ${data.keys.toList()}');
        return AuthResult.error('Respuesta inválida del servidor');
      }

      final user = User.fromJson(data['user']);
      final token = data['access_token'] as String;

      print('AuthService: User parsed successfully: ${user.email}');
      print('AuthService: Token length: ${token.length}');

      // Guardar datos de sesión
      await _saveSession(user, token);

      print('AuthService: Login successful for user: ${user.email}');
      return AuthResult.success(user, token);
    } on ApiException catch (e) {
      print('AuthService: API Exception during login: ${e.message}');
      print('AuthService: API Exception status code: ${e.statusCode}');
      return AuthResult.error(e.message);
    } catch (e, stackTrace) {
      print('AuthService: Unexpected error during login: $e');
      print('AuthService: Stack trace: $stackTrace');
      return AuthResult.error('Error inesperado durante el login: $e');
    }
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data['user']);
      final token = data['access_token'] as String;

      // Guardar datos de sesión
      await _saveSession(user, token);

      return AuthResult.success(user, token);
    } on ApiException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('Error inesperado durante el registro');
    }
  }

  Future<void> logout() async {
    await _clearSession();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.accessToken);
    return token != null && token.isNotEmpty;
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(StorageKeys.userId);
    final email = prefs.getString(StorageKeys.userEmail);
    final name = prefs.getString(StorageKeys.userName);
    final role = prefs.getString(StorageKeys.userRole);

    if (userId != null && email != null && name != null && role != null) {
      return User(
        id: userId,
        email: email,
        name: name,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.accessToken);
  }

  Future<User> updateProfile({
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConstants.updateProfile,
        data: {
          'name': name,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
        },
      );

      final userData = response.data as Map<String, dynamic>;
      final user = User.fromJson(userData);

      // Actualizar datos guardados en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.userName, user.name);

      return user;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado al actualizar perfil');
    }
  }

  Future<void> _saveSession(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.accessToken, token);
    await prefs.setString(StorageKeys.userId, user.id);
    await prefs.setString(StorageKeys.userEmail, user.email);
    await prefs.setString(StorageKeys.userName, user.name);
    await prefs.setString(StorageKeys.userRole, user.role);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.userEmail);
    await prefs.remove(StorageKeys.userName);
    await prefs.remove(StorageKeys.userRole);
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final String? token;
  final String? error;

  AuthResult._(this.success, this.user, this.token, this.error);

  factory AuthResult.success(User user, String token) {
    return AuthResult._(true, user, token, null);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(false, null, null, error);
  }
}
