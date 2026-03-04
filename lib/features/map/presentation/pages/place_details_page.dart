import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/features/map/data/providers/place_details_provider.dart';
import 'package:loomah/features/map/presentation/widgets/image_carousel.dart';
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _buildBadge(
                            place.type,
                            palette.pastelPeach,
                            palette.accentPrimary,
                            textTheme,
                          ),
                          ..._buildAgeBadges(
                            place.ageRanges,
                            palette,
                            textTheme,
                          ),
                        ],
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
                      _buildPracticalInfo(context, place, palette, textTheme),
                      const SizedBox(height: 32),
                      _buildOpeningHours(context, place, palette, textTheme),
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

  Widget _buildPracticalInfo(
    BuildContext context,
    PlaceDetails place,
    LoomahPalette palette,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Informations pratiques',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.textDark,
          ),
        ),
        const SizedBox(height: 16),
        if (place.address != null) ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.location_on_outlined,
                size: 24,
                color: palette.accentPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${place.address!.street}, ${place.address!.postalCode} ${place.address!.city}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.textDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (place.website != null) ...<Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.language, size: 24, color: palette.accentPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Site web',
                  style: textTheme.bodyMedium?.copyWith(
                    decoration: TextDecoration.underline,
                    color: palette.textDark,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: palette.accentPrimary),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (place.phone != null) ...<Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.phone_outlined,
                size: 24,
                color: palette.accentPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                place.phone!,
                style: textTheme.bodyMedium?.copyWith(color: palette.textDark),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildOpeningHours(
    BuildContext context,
    PlaceDetails place,
    LoomahPalette palette,
    TextTheme textTheme,
  ) {
    if (place.openingHours == null) return const SizedBox.shrink();
    final OpeningHours hours = place.openingHours!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Horaires',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.textDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildDayRow('Lundi', hours.monday, palette, textTheme),
        const SizedBox(height: 8),
        _buildDayRow('Mardi', hours.tuesday, palette, textTheme),
        const SizedBox(height: 8),
        _buildDayRow('Mercredi', hours.wednesday, palette, textTheme),
        const SizedBox(height: 8),
        _buildDayRow('Jeudi', hours.thursday, palette, textTheme),
        const SizedBox(height: 8),
        _buildDayRow('Vendredi', hours.friday, palette, textTheme),
        const SizedBox(height: 8),
        _buildDayRow('Samedi', hours.saturday, palette, textTheme),
        const SizedBox(height: 8),
        _buildDayRow('Dimanche', hours.sunday, palette, textTheme),
      ],
    );
  }

  Widget _buildDayRow(
    String day,
    List<OpeningPeriod> periods,
    LoomahPalette palette,
    TextTheme textTheme,
  ) {
    final String timeText = periods.isEmpty
        ? 'FERMÉ'
        : periods.map((OpeningPeriod p) => '${p.open} - ${p.close}').join(', ');
    return Row(
      children: <Widget>[
        SizedBox(
          width: 100,
          child: Text(
            day,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.textDark,
            ),
          ),
        ),
        Text(
          timeText,
          style: textTheme.bodyMedium?.copyWith(
            color: palette.textDark,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAgeBadges(
    AgeRanges? ageRanges,
    LoomahPalette palette,
    TextTheme textTheme,
  ) {
    if (ageRanges == null) return <Widget>[];

    final List<Widget> badges = <Widget>[];
    final bool allTrue =
        ageRanges.babies &&
        ageRanges.toddlers &&
        ageRanges.kids &&
        ageRanges.olderKids;

    if (allTrue) {
      badges.add(
        _buildBadge(
          'Tous âges',
          palette.pastelMint,
          palette.accentGreen,
          textTheme,
        ),
      );
    } else {
      if (ageRanges.babies) {
        badges.add(
          _buildBadge(
            'Bébé (0–1)',
            palette.pastelPink,
            palette.accentPink,
            textTheme,
          ),
        );
      }
      if (ageRanges.toddlers) {
        badges.add(
          _buildBadge(
            '0–3 ans',
            palette.pastelLavender,
            palette.accentPrimary,
            textTheme,
          ),
        );
      }
      if (ageRanges.kids) {
        badges.add(
          _buildBadge(
            '3–6 ans',
            palette.pastelViolet,
            palette.accentSecondary,
            textTheme,
          ),
        );
      }
      if (ageRanges.olderKids) {
        badges.add(
          _buildBadge(
            '6+ ans',
            palette.pastelMint,
            palette.accentGreen,
            textTheme,
          ),
        );
      }
    }

    return badges;
  }

  Widget _buildBadge(
    String text,
    Color bgColor,
    Color textColor,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
