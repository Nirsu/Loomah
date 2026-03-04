import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_photo.freezed.dart';
part 'place_photo.g.dart';

/// Model representing a photo associated with a place
@freezed
abstract class PlacePhoto with _$PlacePhoto {
  /// Default constructor
  const factory PlacePhoto({
    required String url,
    required String alt,
    String? caption,
  }) = _PlacePhoto;

  /// Create a [PlacePhoto] from JSON
  factory PlacePhoto.fromJson(Map<String, dynamic> json) =>
      _$PlacePhotoFromJson(json);
}
