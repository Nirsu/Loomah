import 'dart:async';
import 'dart:convert';

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

  // Source and layer IDs
  static const String _placesSourceId = 'places-source';
  static const String _placesLayerId = 'places-layer';

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

    // Create GeoJSON data
    final Map<String, dynamic> geoJson = <String, dynamic>{
      'type': 'FeatureCollection',
      'features': <Map<String, Object>>[
        <String, Object>{
          'type': 'Feature',
          'geometry': <String, Object>{
            'type': 'Point',
            'coordinates': <double>[2.3718951, 48.8334931],
          },
          'properties': <String, String>{
            'name': 'La Felicità',
            'icon': 'restaurant',
          },
        },
      ],
    };

    // Add GeoJSON source
    await _mapboxMap!.style.addSource(
      GeoJsonSource(id: _placesSourceId, data: jsonEncode(geoJson)),
    );

    // Symbol layer with icon AND text (visible only from zoom 13)
    await _mapboxMap!.style.addLayer(
      SymbolLayer(
        id: _placesLayerId,
        sourceId: _placesSourceId,
        iconImage: '{icon}',
        iconSize: 1,
        textField: '{name}',
        textAnchor: TextAnchor.TOP,
        textOffset: <double?>[0, 0.5],
        textSize: 14,
        minZoom: 13,
      ),
    );
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
