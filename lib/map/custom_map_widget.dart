import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

/// A custom map widget that displays a Mapbox map.
class CustomMapWidget extends StatefulWidget {
  /// Creates a [CustomMapWidget].
  const CustomMapWidget({super.key});

  @override
  State<CustomMapWidget> createState() => _CustomMapWidgetState();
}

class _CustomMapWidgetState extends State<CustomMapWidget> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  bool _locationPermissionGranted = false;

  final CameraOptions _defaultCameraOptions = CameraOptions(
    // Default center coordinates: Paris, France (latitude 48.85887, longitude 2.34704)
    center: Point(coordinates: Position(2.34704, 48.85887)),
    zoom: 14,
    bearing: 0,
    pitch: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_requestLocationPermission());
    });
  }

  Future<void> _requestLocationPermission() async {
    final PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });

      if (_mapboxMap != null) {
        await _updateMapSettings();
      }
    } else {
      // Permission denied, stays on default location
      setState(() {
        _locationPermissionGranted = false;
      });
    }
  }

  Future<void> _updateMapSettings() async {
    try {
      if (_mapboxMap == null) return;

      await _mapboxMap!.location.updateSettings(
        LocationComponentSettings(enabled: true, pulsingEnabled: true),
      );

      await _mapboxMap!.compass.updateSettings(
        CompassSettings(enabled: true, position: OrnamentPosition.BOTTOM_RIGHT),
      );
    } catch (e) {
      debugPrint('Error enabling user location: $e');
    }
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    await _mapboxMap!.loadStyleURI(
      'mapbox://styles/meruto/cmiyi6xhv001e01r49pwo4vkv',
    );

    pointAnnotationManager = await mapboxMap.annotations
        .createPointAnnotationManager();

    final PointAnnotationOptions pointAnnotationOptions =
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(2.3718951, 48.8334931)),
          iconImage: 'restaurant',
          textField: 'La Felicità',
          textAnchor: TextAnchor.TOP,
          textOffset: <double?>[0, 0.5],
        );

    pointAnnotationManager?.create(pointAnnotationOptions);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      cameraOptions: _defaultCameraOptions,
      onMapCreated: _onMapCreated,
      viewport: _locationPermissionGranted
          ? FollowPuckViewportState(
              zoom: 14,
              bearing: FollowPuckViewportStateBearingConstant(0),
              pitch: 0,
            )
          : null,
    );
  }
}
