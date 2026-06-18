import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loomah/features/map/data/models/place_details.dart';

part 'favorite_item.freezed.dart';
part 'favorite_item.g.dart';

/// Favorite item returned by the API.
@freezed
abstract class FavoriteItem with _$FavoriteItem {
  /// Creates a [FavoriteItem].
  const factory FavoriteItem({
    required String id,
    required DateTime createdAt,
    required PlaceDetails place,
    String? placeId,
  }) = _FavoriteItem;

  /// Creates a [FavoriteItem] from API JSON.
  factory FavoriteItem.fromJson(Map<String, dynamic> json) =>
      _$FavoriteItemFromJson(json);
}
