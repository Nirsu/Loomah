// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

/// Annotation to generate the Env class from the .env file
@Envied(path: '.env')
abstract class Env {
  /// Mapbox access token
  @EnviedField(varName: 'MAPBOX_ACCESS_TOKEN')
  static const String mapboxAccessToken = _Env.mapboxAccessToken;

  /// API base URL
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _Env.apiBaseUrl;
}
