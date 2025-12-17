import 'package:dio/dio.dart';
import 'package:loomah/api/api_provider.dart';
import 'package:loomah/features/map/data/models/nearby_places_request_model.dart';
import 'package:loomah/features/map/data/models/place_collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nearby_places_provider.g.dart';

/// Provider to fetch nearby places from the API
@riverpod
Future<PlaceCollection> nearbyPlaces(
  Ref ref,
  NearbyPlacesRequestModel request,
) async {
  final Dio api = ref.read(apiProviderProvider);

  final Response<Map<String, dynamic>> response = await api
      .get<Map<String, dynamic>>(
        '/places/nearby',
        queryParameters: <String, dynamic>{
          'lat': request.latitude,
          'lng': request.longitude,
          'radius': request.radius,
        },
      );

  return PlaceCollection.fromJson(response.data!);
}
