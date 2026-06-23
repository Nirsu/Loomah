import 'dart:async';

import 'package:dio/dio.dart';
import 'package:loomah/api/api_provider.dart';
import 'package:loomah/features/auth/data/auth_api.dart';
import 'package:loomah/features/auth/data/auth_token_storage.dart';
import 'package:loomah/features/auth/data/models/auth_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// Auth session status.
enum AuthStatus {
  /// Restoring a saved token.
  loading,

  /// A user is signed in.
  authenticated,

  /// No valid session exists.
  unauthenticated,
}

/// Auth UI and session state.
class AuthState {
  /// Creates an [AuthState].
  const AuthState({
    required this.status,
    this.session,
    this.error,
    this.isBusy = false,
  });

  /// Initial loading state.
  const AuthState.loading()
    : status = AuthStatus.loading,
      session = null,
      error = null,
      isBusy = false;

  /// Auth status.
  final AuthStatus status;

  /// Current session.
  final AuthSession? session;

  /// Latest user-facing error.
  final String? error;

  /// Whether a form action is running.
  final bool isBusy;

  /// Whether the user is authenticated.
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState _copyWith({String? error, bool? isBusy}) {
    return AuthState(
      status: status,
      session: session,
      error: error,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}

/// Auth API provider.
@Riverpod(keepAlive: true)
AuthApi authApi(Ref ref) {
  return AuthApi(ref.watch(apiProviderProvider));
}

/// Auth status provider for router redirects.
@Riverpod(keepAlive: true)
AuthStatus authStatus(Ref ref) {
  return ref.watch(authControllerProvider).status;
}

/// Restores and updates the current auth session.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    unawaited(_restore());
    return const AuthState.loading();
  }

  AuthApi get _api => ref.read(authApiProvider);
  AuthTokenStorage get _storage => ref.read(authTokenStorageProvider);

  /// Registers a user and persists the session token.
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) {
    return _run(
      () => _api.register(username: username, email: email, password: password),
    );
  }

  /// Logs in and persists the session token.
  Future<void> login({required String email, required String password}) {
    return _run(() => _api.login(email: email, password: password));
  }

  /// Requests a reset password code.
  Future<bool> forgotPassword(String email) async {
    state = state._copyWith(isBusy: true);
    try {
      await _api.forgotPassword(email);
      state = state._copyWith(isBusy: false);
      return true;
    } on Object catch (error) {
      state = state._copyWith(error: _messageFor(error), isBusy: false);
      return false;
    }
  }

  /// Resets the password and persists the new session token.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) {
    return _run(
      () => _api.resetPassword(email: email, code: code, password: password),
    );
  }

  /// Clears the current session.
  Future<void> logout() async {
    await _storage.deleteToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clears the latest auth error.
  void clearError() {
    if (state.error != null) {
      state = state._copyWith();
    }
  }

  Future<void> _restore() async {
    final String? token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final AuthUser user = await _api.me();
      state = AuthState(
        status: AuthStatus.authenticated,
        session: AuthSession(user: user, token: token),
      );
    } on Object {
      await _storage.deleteToken();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> _run(Future<AuthSession> Function() action) async {
    state = state._copyWith(isBusy: true);
    try {
      final AuthSession session = await action();
      await _storage.writeToken(session.token);
      state = AuthState(status: AuthStatus.authenticated, session: session);
    } on Object catch (error) {
      state = state._copyWith(error: _messageFor(error), isBusy: false);
    }
  }

  String _messageFor(Object error) {
    if (error is DioException && error.response?.statusCode == 401) {
      return 'Email ou mot de passe incorrect.';
    }

    return 'Une erreur est survenue. Réessaie dans un instant.';
  }
}
