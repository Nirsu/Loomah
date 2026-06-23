import 'package:loomah/env/env.dart';

/// Builds a displayable URL for a place photo path.
String placePhotoUrl(String path) {
  if (path.startsWith('http')) return path;

  final Uri apiUri = Uri.parse(Env.apiBaseUrl);
  final String cleanPath = path.startsWith('/') ? path : '/$path';
  return '${apiUri.origin}$cleanPath';
}
