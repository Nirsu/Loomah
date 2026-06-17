import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_token_storage.g.dart';

/// Secure storage for the auth token.
class AuthTokenStorage {
  /// Creates an [AuthTokenStorage].
  const AuthTokenStorage(this._storage);

  static const String _tokenKey = 'loomah_auth_token';

  final FlutterSecureStorage _storage;

  /// Reads the persisted token.
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  /// Persists the token.
  Future<void> writeToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  /// Deletes the persisted token.
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}

/// Auth token secure storage provider.
@Riverpod(keepAlive: true)
AuthTokenStorage authTokenStorage(Ref ref) {
  return const AuthTokenStorage(FlutterSecureStorage());
}
