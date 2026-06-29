import 'package:flutter/widgets.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/i18n/strings.g.dart';

/// Formats pricing for compact display.
String? placePricingLabel(BuildContext context, Pricing? pricing) {
  final Translations$map$fr map = Translations.of(context).map;

  return switch (pricing?.kind) {
    null || PricingKind.unknown => null,
    PricingKind.free => map.pricing.free,
    PricingKind.paid => _tierLabel(map, pricing!.tier),
    PricingKind.mixed => _mixedPricingLabel(map, pricing!.tier),
  };
}

String? _mixedPricingLabel(Translations$map$fr map, int? tier) {
  final String? tierLabel = _tierLabel(map, tier);
  if (tierLabel == null) return map.pricing.mixed;

  return map.pricing.mixedWithTier(tier: tierLabel);
}

String? _tierLabel(Translations$map$fr map, int? tier) {
  return switch (tier) {
    1 => map.pricing.tier1,
    2 => map.pricing.tier2,
    3 => map.pricing.tier3,
    4 => map.pricing.tier4,
    _ => null,
  };
}
