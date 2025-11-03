import 'package:flutter/material.dart';
import 'package:loomah/env/env.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MapboxOptions.setAccessToken(Env.mapboxAccessToken);

  runApp(MyApp());
}

/// The main application widget.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] widget.
  MyApp({super.key});

  // Define options for your camera
  final CameraOptions _camera = CameraOptions(
    center: Point(coordinates: Position(-98.0, 39.5)),
    zoom: 2,
    bearing: 0,
    pitch: 0,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(child: MapWidget(cameraOptions: _camera)),
    );
  }
}
