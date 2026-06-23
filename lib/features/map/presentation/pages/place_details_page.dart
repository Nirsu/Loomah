import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/features/favorite/data/models/favorite_item.dart';
import 'package:loomah/features/favorite/data/providers/favorites_provider.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/features/map/data/models/place_photo.dart';
import 'package:loomah/features/map/data/providers/place_details_provider.dart';
import 'package:loomah/features/map/presentation/widgets/image_carousel.dart';
import 'package:loomah/features/map/presentation/widgets/place_actions_bar.dart';
import 'package:loomah/features/map/presentation/widgets/place_badges_wrap.dart';
import 'package:loomah/features/map/presentation/widgets/place_opening_hours.dart';
import 'package:loomah/features/map/presentation/widgets/place_practical_info.dart';
import 'package:loomah/features/map/presentation/widgets/place_quick_facts.dart';
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
          return Stack(
            children: <Widget>[
              CustomScrollView(
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
                        ImageCarousel(
                          photos: place.photos ?? const <PlacePhoto>[],
                        ),
                        Positioned(
                          top: MediaQuery.viewPaddingOf(context).top + 12,
                          left: 16,
                          child: SizedBox.square(
                            dimension: 48,
                            child: IconButton(
                              icon: Icon(
                                Icons.chevron_left_rounded,
                                color: palette.textDark,
                                size: 28,
                              ),
                              style: _topButtonStyle(),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.viewPaddingOf(context).top + 12,
                          right: 16,
                          child: SizedBox.square(
                            dimension: 48,
                            child: _FavoriteActionButton(
                              placeId: place.id,
                              favorites: favoritesAsync,
                              isBusy: favoriteAction.isLoading,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 150),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          PlaceBadgesWrap(
                            type: place.type,
                            ageRanges: place.ageRanges,
                            pricing: place.pricing,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            place.name,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: palette.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PlaceQuickFacts(place: place),
                          const SizedBox(height: 22),
                          _DescriptionText(description: place.description),
                          const SizedBox(height: 28),
                          PlacePracticalInfo(place: place),
                          const SizedBox(height: 28),
                          PlaceOpeningHours(openingHours: place.openingHours),
                          SizedBox(
                            height:
                                24 + MediaQuery.viewPaddingOf(context).bottom,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PlaceActionsBar(place: place),
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

class _DescriptionText extends StatefulWidget {
  const _DescriptionText({required this.description});

  final String description;

  @override
  State<_DescriptionText> createState() => _DescriptionTextState();
}

class _DescriptionTextState extends State<_DescriptionText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.description,
          maxLines: _expanded ? null : 4,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: textTheme.bodyLarge?.copyWith(
            height: 1.55,
            color: palette.textDark,
          ),
        ),
        if (widget.description.length > 180)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: palette.accentSecondary,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(_expanded ? 'Voir moins' : 'Lire plus'),
          ),
      ],
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
