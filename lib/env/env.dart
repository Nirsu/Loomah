// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

/// Annotation to generate the Env class from the .env.dev file
@Envied(path: '.env')
abstract class Env {
  /// Mapbox access token
  @EnviedField(varName: 'MAPBOX_ACCESS_TOKEN')
  static const String mapboxAccessToken = _Env.mapboxAccessToken;
}
