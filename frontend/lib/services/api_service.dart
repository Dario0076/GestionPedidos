import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  Dio get dio => _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          seconds: 30,
        ), // Increased for Render cold start
        receiveTimeout: const Duration(
          seconds: 30,
        ), // Increased for Render cold start
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor para agregar token de autenticación
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expirado o inválido, limpiar sesión
            await _clearSession();
          }
          handler.next(error);
        },
      ),
    );

    // Interceptor para logging en desarrollo
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (object) {
          // Activado temporalmente para debugging
          print('[API] $object');
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.accessToken);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.userEmail);
    await prefs.remove(StorageKeys.userName);
    await prefs.remove(StorageKeys.userRole);
  }

  // Métodos HTTP genéricos
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print('ApiService: POST request to $path');
      print('ApiService: Request data: $data');
      print('ApiService: Base URL: ${_dio.options.baseUrl}');
      print('ApiService: Full URL: ${_dio.options.baseUrl}$path');
      print(
        'ApiService: Timeout settings - Connect: ${_dio.options.connectTimeout}, Receive: ${_dio.options.receiveTimeout}',
      );

      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      print('ApiService: POST response received');
      print('ApiService: Status code: ${response.statusCode}');
      print('ApiService: Response headers: ${response.headers.map}');
      print('ApiService: Response data type: ${response.data.runtimeType}');
      print('ApiService: Response data: ${response.data}');

      return response;
    } on DioException catch (e) {
      print('ApiService: DioException in POST: ${e.message}');
      print('ApiService: DioException type: ${e.type}');
      print(
        'ApiService: DioException response status: ${e.response?.statusCode}',
      );
      print('ApiService: DioException response data: ${e.response?.data}');
      print('ApiService: DioException error: ${e.error}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      print('ApiService: Unexpected error in POST: $e');
      print('ApiService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Tiempo de conexión agotado',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          message: error.response?.data['message'] ?? 'Error del servidor',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Solicitud cancelada',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Error de conexión. Verifica tu conexión a internet.',
          statusCode: error.response?.statusCode,
        );
      default:
        return ApiException(
          message: 'Error inesperado: ${error.message}',
          statusCode: error.response?.statusCode,
        );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message (Code: $statusCode)';
}
