import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

/// App user returned by the backend.
@freezed
abstract class AuthUser with _$AuthUser {
  /// Creates an [AuthUser].
  const factory AuthUser({
    required String id,
    required String email,
    required String username,
  }) = _AuthUser;

  /// Creates an [AuthUser] from backend JSON.
  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}

/// Authenticated user session.
@freezed
abstract class AuthSession with _$AuthSession {
  /// Creates an [AuthSession].
  const factory AuthSession({required AuthUser user, required String token}) =
      _AuthSession;

  /// Creates an [AuthSession] from backend JSON.
  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}

/// Result returned after updating the current user's profile.
@freezed
abstract class ProfileUpdateResult with _$ProfileUpdateResult {
  /// Creates a profile update result.
  const factory ProfileUpdateResult({
    required AuthUser user,
    String? pendingEmail,
    @Default(false) bool emailVerificationRequired,
  }) = _ProfileUpdateResult;

  /// Creates a profile update result from backend JSON.
  factory ProfileUpdateResult.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateResultFromJson(json);
}
