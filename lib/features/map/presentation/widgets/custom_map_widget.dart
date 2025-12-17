import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/features/map/data/models/nearby_places_request_model.dart';
import 'package:loomah/features/map/data/models/place_collection.dart';
import 'package:loomah/features/map/data/providers/nearby_places_provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Debounce duration for camera changes (ms)
const int kDebounceDuration = 500;

/// Minimum distance in meters to trigger a refetch
const double kMinDistanceToRefetch = 500;

/// Minimum zoom level to fetch places (below this, icons are hidden anyway)
const double kMinZoomToFetch = 12;

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

  // Debounce timer for camera changes
  Timer? _debounceTimer;

  // Last fetched position to avoid unnecessary refetches
  Position? _lastFetchedPosition;
  double? _lastFetchedZoom;

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

      // Listen to camera changes for refetching
      _mapboxMap!.setOnMapMoveListener(_onMapMove);

      await _fetchNearbyPlaces();
    } catch (e) {
      debugPrint('Error enabling user location: $e');
    }
  }

  void _onMapMove(MapContentGestureContext context) {
    // Debounce to avoid spamming the API
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: kDebounceDuration),
      _checkAndRefetch,
    );
  }

  Future<void> _checkAndRefetch() async {
    if (_mapboxMap == null) return;

    final CameraState cameraState = await _mapboxMap!.getCameraState();
    final Position currentPosition = cameraState.center.coordinates;
    final double currentZoom = cameraState.zoom;

    // Don't fetch if zoomed out too much (icons won't be visible anyway)
    if (currentZoom < kMinZoomToFetch) return;

    // Check if we need to refetch (position changed significantly or zoom changed)
    final bool shouldRefetch =
        _lastFetchedPosition == null ||
        _lastFetchedZoom == null ||
        _calculateDistance(_lastFetchedPosition!, currentPosition) >
            kMinDistanceToRefetch ||
        (currentZoom - _lastFetchedZoom!).abs() > 1;

    if (shouldRefetch) {
      await _fetchNearbyPlaces();
    }
  }

  /// Calculate distance between two positions in meters using Haversine formula
  double _calculateDistance(Position p1, Position p2) {
    const double earthRadius = 6371000; // meters
    final double lat1Rad = p1.lat.toDouble() * math.pi / 180;
    final double lat2Rad = p2.lat.toDouble() * math.pi / 180;
    final double deltaLat =
        (p2.lat.toDouble() - p1.lat.toDouble()) * math.pi / 180;
    final double deltaLng =
        (p2.lng.toDouble() - p1.lng.toDouble()) * math.pi / 180;

    final double a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calculate radius based on zoom level
  /// Higher zoom = smaller area = smaller radius
  int _calculateRadiusFromZoom(double zoom) {
    // Approximate meters per pixel at equator for each zoom level
    // At zoom 0: ~156543 m/px, halves with each zoom level
    const double baseMetersPerPixel = 156543;
    final double metersPerPixel = baseMetersPerPixel / math.pow(2, zoom);

    // Assume a reasonable screen width of ~400px for radius calculation
    final int radius = (metersPerPixel * 400).round();

    // Clamp between 500m and 50km
    return radius.clamp(500, 50000);
  }

  Future<void> _fetchNearbyPlaces() async {
    try {
      if (_mapboxMap == null) return;

      final CameraState cameraState = await _mapboxMap!.getCameraState();
      final Position currentPosition = cameraState.center.coordinates;
      final double currentZoom = cameraState.zoom;

      // Calculate radius based on zoom level
      final int radius = _calculateRadiusFromZoom(currentZoom);

      final NearbyPlacesRequestModel request = NearbyPlacesRequestModel(
        latitude: currentPosition.lat.toDouble(),
        longitude: currentPosition.lng.toDouble(),
        radius: radius,
      );

      final PlaceCollection places = await ref.read(
        nearbyPlacesProvider(request).future,
      );

      // Update last fetched state
      _lastFetchedPosition = currentPosition;
      _lastFetchedZoom = currentZoom;

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
    _debounceTimer?.cancel();
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
