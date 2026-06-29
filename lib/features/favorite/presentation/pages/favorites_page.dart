import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loomah/features/favorite/data/models/favorite_item.dart';
import 'package:loomah/features/favorite/data/providers/favorites_provider.dart';
import 'package:loomah/features/home/presentation/widgets/floating_bottom_nav_metrics.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/features/map/data/models/place_photo.dart';
import 'package:loomah/features/map/presentation/pages/place_details_page.dart';
import 'package:loomah/features/map/presentation/widgets/place_photo_url.dart';
import 'package:loomah/i18n/strings.g.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// A page that displays the user's favorite places.
class FavoritesPage extends ConsumerWidget {
  /// Creates a [FavoritesPage].
  const FavoritesPage({super.key});

  /// The route path.
  static const String route = '/favorites';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<FavoriteItem>> favorites = ref.watch(
      favoritesProvider,
    );
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double bottomClearance = FloatingBottomNavMetrics.clearance(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(favoritesProvider.future),
        child: favorites.when(
          data: (List<FavoriteItem> items) {
            if (items.isEmpty) {
              return _EmptyFavorites(palette: palette, textTheme: textTheme);
            }

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(20, 24, 20, bottomClearance),
              itemCount: items.length + 1,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 14),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return _FavoritesHeader(count: items.length);
                }

                return _FavoriteCard(favorite: items[index - 1]);
              },
            );
          },
          loading: () => ListView(
            padding: EdgeInsets.fromLTRB(28, 180, 28, bottomClearance),
            children: <Widget>[
              Center(
                child: CircularProgressIndicator(color: palette.accentPrimary),
              ),
            ],
          ),
          error: (Object error, StackTrace stackTrace) =>
              _FavoritesError(onRetry: () => ref.invalidate(favoritesProvider)),
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations$favorite$fr favoriteText = Translations.of(
      context,
    ).favorite;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          favoriteText.title,
          style: textTheme.headlineMedium?.copyWith(
            color: palette.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          favoriteText.savedPlaces(count: count),
          style: textTheme.bodyLarge?.copyWith(color: palette.textLight),
        ),
      ],
    );
  }
}

class _FavoriteCard extends ConsumerWidget {
  const _FavoriteCard({required this.favorite});

  final FavoriteItem favorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlaceDetails place = favorite.place;
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations$favorite$fr favoriteText = Translations.of(
      context,
    ).favorite;
    final AsyncValue<void> mutation = ref.watch(favoriteControllerProvider);
    final List<PlacePhoto> photos = place.photos ?? <PlacePhoto>[];

    return InkWell(
      onTap: () => context.push(PlaceDetailsPage.location(place.id)),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: palette.textDark.withValues(alpha: .08)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: palette.textDark.withValues(alpha: .04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 86,
                height: 86,
                child: photos.isEmpty
                    ? ColoredBox(
                        color: palette.accentLight,
                        child: Icon(
                          LucideIcons.image,
                          color: palette.accentSecondary,
                        ),
                      )
                    : Image.network(
                        placePhotoUrl(photos.first.url),
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return ColoredBox(
                                color: palette.accentLight,
                                child: Icon(
                                  LucideIcons.image_off,
                                  color: palette.accentSecondary,
                                ),
                              );
                            },
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    place.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: palette.accentSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    place.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      color: palette.textDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _addressText(
                      place.address,
                      favoriteText.addressUnavailable,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: palette.textLight,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: mutation.isLoading
                  ? null
                  : () {
                      unawaited(
                        ref
                            .read(favoriteControllerProvider.notifier)
                            .remove(place.id),
                      );
                    },
              icon: const Icon(LucideIcons.heart_off),
              color: palette.accentSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.palette, required this.textTheme});

  final LoomahPalette palette;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final double bottomClearance = FloatingBottomNavMetrics.clearance(context);
    final Translations$favorite$fr favoriteText = Translations.of(
      context,
    ).favorite;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ListView(
          padding: EdgeInsets.fromLTRB(28, 0, 28, bottomClearance),
          children: <Widget>[
            SizedBox(
              height: constraints.maxHeight - bottomClearance,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      LucideIcons.heart,
                      size: 48,
                      color: palette.accentPrimary,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      favoriteText.emptyTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        color: palette.textDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      favoriteText.emptySubtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: palette.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FavoritesError extends StatelessWidget {
  const _FavoritesError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double bottomClearance = FloatingBottomNavMetrics.clearance(context);
    final Translations$favorite$fr favoriteText = Translations.of(
      context,
    ).favorite;

    return ListView(
      padding: EdgeInsets.fromLTRB(28, 120, 28, bottomClearance),
      children: <Widget>[
        Icon(LucideIcons.circle_alert, size: 44, color: palette.accentPrimary),
        const SizedBox(height: 18),
        Text(
          favoriteText.loadError,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        ElevatedButton(onPressed: onRetry, child: Text(favoriteText.retry)),
      ],
    );
  }
}

String _addressText(Address? address, String unavailableText) {
  if (address == null) {
    return unavailableText;
  }

  return <String>[
    address.street,
    '${address.postalCode} ${address.city}'.trim(),
    address.country,
  ].where((String part) => part.isNotEmpty).join(', ');
}
