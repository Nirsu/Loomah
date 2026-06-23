import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the place in the user's map app.
Future<void> openPlaceInMaps(PlaceDetails place) async {
  final String coordinates = '${place.latitude},${place.longitude}';
  final Uri geoUri = Uri.parse(
    'geo:$coordinates?q=$coordinates(${Uri.encodeComponent(place.name)})',
  );

  if (await _tryLaunch(geoUri)) return;

  await _tryLaunch(
    Uri.https('www.google.com', '/maps/search/', <String, String>{
      'api': '1',
      'query': coordinates,
    }),
  );
}

/// Opens a place website.
Future<void> openPlaceUrl(String value) async {
  final Uri uri = Uri.parse(
    value.startsWith('http') ? value : 'https://$value',
  );
  await _tryLaunch(uri);
}

/// Starts a phone call to a place.
Future<void> callPlacePhone(String phone) async {
  await _tryLaunch(Uri(scheme: 'tel', path: phone));
}

Future<bool> _tryLaunch(Uri uri) async {
  try {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Exception {
    return false;
  }
}
