import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// Provider para el servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Estado de autenticación
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

// Provider para el estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> loginSimple(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.loginSimple(email, password);

      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: result.user,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: result.error,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.login(email, password);

      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: result.user,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: result.error,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? address,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
      );

      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: result.user,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: result.error,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(
      isLoading: false,
      isAuthenticated: false,
      user: null,
    );
  }

  Future<bool> updateProfile({
    required String name,
    String? phone,
    String? address,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        phone: phone,
        address: address,
      );

      state = state.copyWith(isLoading: false, user: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

// Provider para verificar si el usuario está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

// Provider para obtener el usuario actual
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});
