import 'package:loomah/features/map/data/models/place_details.dart';

/// Formats pricing for compact display.
String? placePricingLabel(Pricing? pricing) {
  return switch (pricing?.kind) {
    null || PricingKind.unknown => null,
    PricingKind.free => 'Gratuit',
    PricingKind.paid => _tierLabel(pricing!.tier),
    PricingKind.mixed => _mixedPricingLabel(pricing!.tier),
  };
}

String? _mixedPricingLabel(int? tier) {
  final String? tierLabel = _tierLabel(tier);
  if (tierLabel == null) return 'Gratuit et payant';

  return 'Gratuit et payant · $tierLabel';
}

String? _tierLabel(int? tier) {
  return switch (tier) {
    1 => '€ Abordable',
    2 => '€€ Prix moyen',
    3 => '€€€ Cher',
    4 => '€€€€ Très cher',
    _ => null,
  };
}
