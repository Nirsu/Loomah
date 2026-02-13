import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/env/env.dart';
import 'package:loomah/features/map/presentation/widgets/custom_map_widget.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  MapboxOptions.setAccessToken(Env.mapboxAccessToken);

  runApp(ProviderScope(child: MyApp()));
}

/// The main application widget.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SafeArea(top: false, child: CustomMapWidget()));
  }
}
