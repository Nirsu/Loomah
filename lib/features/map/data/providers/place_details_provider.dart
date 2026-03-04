import 'package:dio/dio.dart';
import 'package:loomah/api/api_provider.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'place_details_provider.g.dart';

/// Provider to fetch place details by ID from the API
@riverpod
Future<PlaceDetails> placeDetails(Ref ref, String id) async {
  final Dio api = ref.read(apiProviderProvider);

  final Response<Map<String, dynamic>> response = await api
      .get<Map<String, dynamic>>('/places/$id');

  return PlaceDetails.fromJson(response.data!);
}
