import 'package:flutter/material.dart';
import 'package:loomah/env/env.dart';
import 'package:loomah/map/custom_map_widget.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MapboxOptions.setAccessToken(Env.mapboxAccessToken);

  runApp(MyApp());
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
