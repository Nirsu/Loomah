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

  /// Updates the current user's username and/or email.
  Future<ProfileUpdateResult> updateProfile({
    String? username,
    String? email,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .patch<Map<String, dynamic>>(
          '/auth/me',
          data: <String, String>{
            if (username != null) 'username': username,
            if (email != null) 'email': email,
          },
        );
    return ProfileUpdateResult.fromJson(response.data!);
  }

  /// Confirms the current user's pending email.
  Future<AuthUser> confirmEmail(String code) async {
    final Response<Map<String, dynamic>> response = await _dio
        .post<Map<String, dynamic>>(
          '/auth/email/confirm',
          data: <String, String>{'code': code},
        );
    return AuthUser.fromJson(response.data!['user'] as Map<String, dynamic>);
  }

  /// Changes the current user's password and returns the replacement session.
  Future<AuthSession> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .patch<Map<String, dynamic>>(
          '/auth/password',
          data: <String, String>{
            'currentPassword': currentPassword,
            'newPassword': newPassword,
            'confirmNewPassword': confirmNewPassword,
          },
        );
    return AuthSession.fromJson(response.data!);
  }

  /// Permanently deletes the current user's account.
  Future<void> deleteAccount(String password) {
    return _dio.delete<Object?>(
      '/auth/me',
      data: <String, String>{'password': password},
    );
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
