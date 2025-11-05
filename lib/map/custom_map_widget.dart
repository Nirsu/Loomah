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

      // If map is already initialized, enable location and move to user
      if (_mapboxMap != null) {
        await _enableUserLocationOnMap();
      }
    } else {
      // Permission denied, stays on default France location
      setState(() {
        _locationPermissionGranted = false;
      });
    }
  }

  Future<void> _enableUserLocationOnMap() async {
    try {
      if (_mapboxMap == null) return;

      await _mapboxMap!.location.updateSettings(
        LocationComponentSettings(enabled: true, pulsingEnabled: true),
      );
    } catch (e) {
      debugPrint('Error enabling user location: $e');
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
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
