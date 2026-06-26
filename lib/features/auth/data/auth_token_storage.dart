import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loomah/features/auth/data/models/auth_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_token_storage.g.dart';

/// Secure storage for the auth token.
class AuthTokenStorage {
  /// Creates an [AuthTokenStorage].
  const AuthTokenStorage(this._storage);

  static const String _tokenKey = 'loomah_auth_token';
  static const String _sessionKey = 'loomah_auth_session';

  final FlutterSecureStorage _storage;

  /// Reads the persisted token.
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  /// Reads the persisted session.
  Future<AuthSession?> readSession() async {
    final String? value = await _storage.read(key: _sessionKey);
    if (value == null) {
      return null;
    }

    try {
      return AuthSession.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } on Object {
      await _storage.delete(key: _sessionKey);
      return null;
    }
  }

  /// Persists the complete session.
  Future<void> writeSession(AuthSession session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));
  }

  /// Deletes all persisted authentication data.
  Future<void> deleteSession() async {
    await _storage.delete(key: _sessionKey);
    await _storage.delete(key: _tokenKey);
  }
}

/// Auth token secure storage provider.
@Riverpod(keepAlive: true)
AuthTokenStorage authTokenStorage(Ref ref) {
  return const AuthTokenStorage(FlutterSecureStorage());
}
