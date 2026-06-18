import 'dart:async';

import 'package:dio/dio.dart';
import 'package:loomah/api/api_provider.dart';
import 'package:loomah/features/favorite/data/models/favorite_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_provider.g.dart';

/// Current user's favorite places.
@riverpod
Future<List<FavoriteItem>> favorites(Ref ref) async {
  final Dio api = ref.read(apiProviderProvider);
  final Response<Map<String, dynamic>> response = await api
      .get<Map<String, dynamic>>('/favorites');
  final List<dynamic> favorites = response.data!['favorites'] as List<dynamic>;

  return favorites
      .map(
        (dynamic json) => FavoriteItem.fromJson(json as Map<String, dynamic>),
      )
      .toList();
}

/// Favorite mutation controller.
@riverpod
class FavoriteController extends _$FavoriteController {
  @override
  FutureOr<void> build() {}

  /// Adds a favorite.
  Future<void> add(String placeId) {
    return _run(() async {
      await ref
          .read(apiProviderProvider)
          .post<Object?>(
            '/favorites',
            data: <String, String>{'placeId': placeId},
          );
    });
  }

  /// Removes a favorite.
  Future<void> remove(String placeId) {
    return _run(() async {
      await ref
          .read(apiProviderProvider)
          .delete<Object?>('/favorites/$placeId');
    });
  }

  /// Toggles a favorite.
  Future<void> toggle({required String placeId, required bool isFavorite}) {
    return isFavorite ? remove(placeId) : add(placeId);
  }

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await action();
      ref.invalidate(favoritesProvider);
    });
  }
}
