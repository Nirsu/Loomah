import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/features/favorite/data/models/favorite_item.dart';
import 'package:loomah/features/favorite/data/providers/favorites_provider.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/features/map/data/models/place_photo.dart';
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

  /// Route path.
  static const String route = '/places/:id';

  /// Location for a place details page.
  static String location(String id) => '/places/$id';

  /// ID of the place to display.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PlaceDetails> placeDetailsAsync = ref.watch(
      placeDetailsProvider(id),
    );
    final AsyncValue<List<FavoriteItem>> favoritesAsync = ref.watch(
      favoritesProvider,
    );
    final AsyncValue<void> favoriteAction = ref.watch(
      favoriteControllerProvider,
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
                toolbarHeight: 112,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                forceMaterialTransparency: true,
                flexibleSpace: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ImageCarousel(photos: place.photos ?? const <PlacePhoto>[]),
                    Positioned(
                      top: MediaQuery.viewPaddingOf(context).top + 12,
                      left: 4,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: palette.textDark,
                        ),
                        style: _topButtonStyle(),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.viewPaddingOf(context).top + 12,
                      right: 8,
                      child: _FavoriteActionButton(
                        placeId: place.id,
                        favorites: favoritesAsync,
                        isBusy: favoriteAction.isLoading,
                      ),
                    ),
                  ],
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
                      SizedBox(
                        height: 48 + MediaQuery.viewPaddingOf(context).bottom,
                      ),
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

class _FavoriteActionButton extends ConsumerWidget {
  const _FavoriteActionButton({
    required this.placeId,
    required this.favorites,
    required this.isBusy,
  });

  final String placeId;
  final AsyncValue<List<FavoriteItem>> favorites;
  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LoomahPalette palette = context.loomahPalette;
    final bool isFavorite =
        favorites.whenOrNull(
          data: (List<FavoriteItem> items) =>
              items.any((FavoriteItem item) => item.place.id == placeId),
        ) ??
        false;

    return IconButton(
      onPressed: isBusy
          ? null
          : () {
              unawaited(
                ref
                    .read(favoriteControllerProvider.notifier)
                    .toggle(placeId: placeId, isFavorite: isFavorite),
              );
            },
      icon: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      ),
      color: isFavorite ? palette.accentPrimary : palette.textDark,
      style: _topButtonStyle(),
    );
  }
}

ButtonStyle _topButtonStyle() {
  return IconButton.styleFrom(
    backgroundColor: Colors.white,
    shadowColor: Colors.black.withValues(alpha: .08),
    elevation: 4,
  );
}
