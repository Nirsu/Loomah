import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loomah/features/map/data/models/place_photo.dart';

part 'place_details.freezed.dart';
part 'place_details.g.dart';

/// Details of a place.
@freezed
abstract class PlaceDetails with _$PlaceDetails {
  /// Default constructor.
  const factory PlaceDetails({
    required String id,
    required String name,
    required String type,
    required double latitude,
    required double longitude,
    required String description,
    required List<PlacePhoto> photos,
    Address? address,
    String? website,
    String? phone,
    Pricing? pricing,
    AgeRanges? ageRanges,
    OpeningHours? openingHours,
  }) = _PlaceDetails;

  /// Create a [PlaceDetails] from a JSON.
  factory PlaceDetails.fromJson(Map<String, dynamic> json) =>
      _$PlaceDetailsFromJson(json);
}

/// Address of a place.
@freezed
abstract class Address with _$Address {
  /// Default constructor.
  const factory Address({
    required String street,
    required String city,
    required String postalCode,
    required String country,
  }) = _Address;

  /// Create an [Address] from a JSON.
  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}

/// Pricing of a place.
@freezed
abstract class Pricing with _$Pricing {
  /// Default constructor.
  const factory Pricing({required String kind, String? tier}) = _Pricing;

  /// Create a [Pricing] from a JSON.
  factory Pricing.fromJson(Map<String, dynamic> json) =>
      _$PricingFromJson(json);
}

/// Age ranges of a place.
@freezed
abstract class AgeRanges with _$AgeRanges {
  /// Default constructor.
  const factory AgeRanges({
    required bool babies,
    required bool toddlers,
    required bool kids,
    required bool olderKids,
  }) = _AgeRanges;

  /// Create an [AgeRanges] from a JSON.
  factory AgeRanges.fromJson(Map<String, dynamic> json) =>
      _$AgeRangesFromJson(json);
}

/// Opening hours of a place.
@freezed
abstract class OpeningHours with _$OpeningHours {
  /// Default constructor.
  const factory OpeningHours({
    required String timezone,
    required List<OpeningPeriod> monday,
    required List<OpeningPeriod> tuesday,
    required List<OpeningPeriod> wednesday,
    required List<OpeningPeriod> thursday,
    required List<OpeningPeriod> friday,
    required List<OpeningPeriod> saturday,
    required List<OpeningPeriod> sunday,
  }) = _OpeningHours;

  /// Create an [OpeningHours] from a JSON.
  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);
}

/// Opening period of a place.
@freezed
abstract class OpeningPeriod with _$OpeningPeriod {
  /// Default constructor.
  const factory OpeningPeriod({required String open, required String close}) =
      _OpeningPeriod;

  /// Create an [OpeningPeriod] from a JSON.
  factory OpeningPeriod.fromJson(Map<String, dynamic> json) =>
      _$OpeningPeriodFromJson(json);
}
