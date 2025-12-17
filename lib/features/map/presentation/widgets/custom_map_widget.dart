import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/features/map/data/models/nearby_places_request_model.dart';
import 'package:loomah/features/map/data/models/place_collection.dart';
import 'package:loomah/features/map/data/providers/nearby_places_provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Default radius for nearby places search (10km)
const int kDefaultRadius = 10000;

/// A custom map widget that displays a Mapbox map.
class CustomMapWidget extends ConsumerStatefulWidget {
  /// Creates a [CustomMapWidget].
  const CustomMapWidget({super.key});

  @override
  ConsumerState<CustomMapWidget> createState() => _CustomMapWidgetState();
}

class _CustomMapWidgetState extends ConsumerState<CustomMapWidget> {
  MapboxMap? _mapboxMap;
  bool _locationPermissionGranted = false;
  bool _hasInitializedLocation = false;

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
      if (_mapboxMap == null || _hasInitializedLocation) return;
      _hasInitializedLocation = true;

      await _mapboxMap!.location.updateSettings(
        LocationComponentSettings(enabled: true, pulsingEnabled: true),
      );

      await _mapboxMap!.compass.updateSettings(
        CompassSettings(enabled: true, position: OrnamentPosition.BOTTOM_RIGHT),
      );

      await _fetchNearbyPlaces();
    } catch (e) {
      debugPrint('Error enabling user location: $e');
    }
  }

  Future<void> _fetchNearbyPlaces() async {
    try {
      if (_mapboxMap == null) return;

      // Get the camera center (user's position when using FollowPuckViewportState)
      final CameraState cameraState = await _mapboxMap!.getCameraState();
      final Position userPosition = cameraState.center.coordinates;

      final NearbyPlacesRequestModel request = NearbyPlacesRequestModel(
        latitude: userPosition.lat.toDouble(),
        longitude: userPosition.lng.toDouble(),
        radius: kDefaultRadius,
      );

      final PlaceCollection places = await ref.read(
        nearbyPlacesProvider(request).future,
      );

      await _displayPlaces(places);
    } catch (e) {
      debugPrint('Error fetching nearby places: $e');
    }
  }

  Future<void> _displayPlaces(PlaceCollection places) async {
    if (_mapboxMap == null) return;

    final String geoJsonString = jsonEncode(places.toJson());

    // Check if source already exists, update it or create it
    final bool sourceExists = await _mapboxMap!.style.styleSourceExists(
      _placesSourceId,
    );

    if (sourceExists) {
      final GeoJsonSource source =
          (await _mapboxMap!.style.getSource(_placesSourceId))!
              as GeoJsonSource;
      await source.updateGeoJSON(geoJsonString);
    } else {
      await _mapboxMap!.style.addSource(
        GeoJsonSource(id: _placesSourceId, data: geoJsonString),
      );

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
          minZoom: 12,
        ),
      );
    }
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    await _mapboxMap!.loadStyleURI(
      'mapbox://styles/meruto/cmiyi6xhv001e01r49pwo4vkv',
    );

    if (_locationPermissionGranted) {
      await _updateMapSettings();
    }
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
