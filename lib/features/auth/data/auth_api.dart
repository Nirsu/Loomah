import 'package:dio/dio.dart';
import 'package:loomah/features/auth/data/models/auth_session.dart';

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
    final Response<Map<String, dynamic>> response = await _dio
        .post<Map<String, dynamic>>(
          '/auth/register',
          data: <String, String>{
            'username': username,
            'email': email,
            'password': password,
          },
        );

    return AuthSession.fromJson(response.data!);
  }

  /// Logs in with email and password.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .post<Map<String, dynamic>>(
          '/auth/login',
          data: <String, String>{'email': email, 'password': password},
        );

    return AuthSession.fromJson(response.data!);
  }

  /// Loads the current user.
  Future<AuthUser> me() async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>('/auth/me');
    return AuthUser.fromJson(response.data!);
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
    final Response<Map<String, dynamic>> response = await _dio
        .post<Map<String, dynamic>>(
          '/auth/password/reset',
          data: <String, String>{
            'email': email,
            'code': code,
            'password': password,
          },
        );

    return AuthSession.fromJson(response.data!);
  }
}
