import 'package:dio/dio.dart';

/// App user returned by the backend.
class AuthUser {
  /// Creates an [AuthUser].
  const AuthUser(this.data);

  /// Raw backend payload.
  final Map<String, dynamic> data;
}

/// Authenticated user session.
class AuthSession {
  /// Creates an [AuthSession].
  const AuthSession({required this.user, required this.token});

  /// Current user.
  final AuthUser user;

  /// Bearer token.
  final String token;
}

/// Auth API client.
class AuthApi {
  /// Creates an [AuthApi].
  const AuthApi(this._dio);

  final Dio _dio;

  /// Registers a new user.
  Future<AuthSession> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final Response<Object?> response = await _dio.post<Object?>(
      '/auth/register',
      data: <String, String>{
        'username': username,
        'email': email,
        'password': password,
      },
    );

    return _sessionFrom(response.data);
  }

  /// Logs in with email and password.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final Response<Object?> response = await _dio.post<Object?>(
      '/auth/login',
      data: <String, String>{'email': email, 'password': password},
    );

    return _sessionFrom(response.data);
  }

  /// Loads the current user.
  Future<AuthUser> me() async {
    final Response<Object?> response = await _dio.get<Object?>('/auth/me');
    final Map<String, dynamic> data = _mapFrom(response.data);
    final Object? user = data['user'];

    return AuthUser(user is Map ? Map<String, dynamic>.from(user) : data);
  }

  /// Requests a reset code.
  Future<void> forgotPassword(String email) {
    return _dio.post<Object?>(
      '/auth/password/forgot',
      data: <String, String>{'email': email},
    );
  }

  /// Resets the password with a 6 digit code.
  Future<AuthSession> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final Response<Object?> response = await _dio.post<Object?>(
      '/auth/password/reset',
      data: <String, String>{
        'email': email,
        'code': code,
        'password': password,
      },
    );

    return _sessionFrom(response.data);
  }

  AuthSession _sessionFrom(Object? raw) {
    final Map<String, dynamic> data = _mapFrom(raw);
    final Object? token = data['token'];
    final Object? user = data['user'];

    if (token is! String || user is! Map) {
      throw const FormatException('Invalid auth response');
    }

    return AuthSession(
      user: AuthUser(Map<String, dynamic>.from(user)),
      token: token,
    );
  }

  Map<String, dynamic> _mapFrom(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    throw const FormatException('Invalid auth response');
  }
}
