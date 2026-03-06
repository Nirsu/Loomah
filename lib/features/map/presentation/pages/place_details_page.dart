import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/features/map/data/providers/place_details_provider.dart';
import 'package:loomah/features/map/presentation/widgets/image_carousel.dart';
import 'package:loomah/features/map/presentation/widgets/place_badges_wrap.dart';
import 'package:loomah/features/map/presentation/widgets/place_opening_hours.dart';
import 'package:loomah/features/map/presentation/widgets/place_practical_info.dart';
import 'package:loomah/features/map/presentation/widgets/place_pricing_info.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// Page to display the details of a place.
class PlaceDetailsPage extends ConsumerWidget {
  /// Default constructor.
  const PlaceDetailsPage({required this.id, super.key});

  /// ID of the place to display.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PlaceDetails> placeDetailsAsync = ref.watch(
      placeDetailsProvider(id),
    );

    final LoomahPalette palette = Theme.of(context).extension<LoomahPalette>()!;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: palette.background,
      body: placeDetailsAsync.when(
        data: (PlaceDetails place) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ImageCarousel(photos: place.photos),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: palette.textDark,
                  ),
                  style: IconButton.styleFrom(backgroundColor: palette.glassBg),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      PlaceBadgesWrap(
                        type: place.type,
                        ageRanges: place.ageRanges,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        place.name,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: palette.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        place.description,
                        style: textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: palette.textDark,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (place.pricing != null &&
                          place.pricing!.kind !=
                              PricingKind.unknown) ...<Widget>[
                        PlacePricingInfo(pricing: place.pricing!),
                        const SizedBox(height: 32),
                      ],
                      PlacePracticalInfo(place: place),
                      const SizedBox(height: 32),
                      PlaceOpeningHours(openingHours: place.openingHours),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        // TODO(Nirsu): Create a proper error widget
        error: (Object error, StackTrace stack) => Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('An error occurred'),
            ),
          ),
        ),
      ),
    );
  }
}
