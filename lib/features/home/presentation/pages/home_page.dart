import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:loomah/features/favorite/presentation/pages/favorites_page.dart';
import 'package:loomah/features/map/presentation/pages/map_page.dart';
import 'package:loomah/features/profile/presentation/pages/profile_page.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// Main shell with bottom navigation.
class HomePage extends StatefulWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages = <Widget>[
    const MapPage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        top: false,
        bottom: false,
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: _LoomahBottomNavBar(
        currentIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _LoomahBottomNavBar extends StatelessWidget {
  const _LoomahBottomNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<_NavDestination> _destinations = <_NavDestination>[
    _NavDestination(
      icon: LucideIcons.map_pinned,
      label: 'Carte',
    ),
    _NavDestination(
      icon: LucideIcons.heart,
      label: 'Favoris',
    ),
    _NavDestination(
      icon: LucideIcons.user_round,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: palette.textDark.withValues(alpha: .08)),
            borderRadius: BorderRadius.circular(24),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: palette.accentSecondary.withValues(alpha: .08),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: palette.textDark.withValues(alpha: .04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double itemWidth =
                    constraints.maxWidth / _destinations.length;

                return SizedBox(
                  height: 56,
                  child: Stack(
                    children: <Widget>[
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        left: itemWidth * currentIndex,
                        top: 0,
                        width: itemWidth,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: palette.accentLight,
                            border: Border.all(
                              color: palette.accentPrimary.withValues(
                                alpha: .14,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Row(
                          children: List<Widget>.generate(
                            _destinations.length,
                            (int index) {
                              final _NavDestination destination =
                                  _destinations[index];
                              final bool isSelected = index == currentIndex;

                              return Expanded(
                                child: _LoomahNavItem(
                                  destination: destination,
                                  isSelected: isSelected,
                                  onTap: () => onDestinationSelected(index),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LoomahNavItem extends StatelessWidget {
  const _LoomahNavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color foreground =
        isSelected ? palette.accentSecondary : palette.textLight;
    final FontWeight labelWeight =
        isSelected ? FontWeight.w800 : FontWeight.w700;

    return Semantics(
      selected: isSelected,
      button: true,
      label: destination.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 56,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: foreground),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            builder: (BuildContext context, Color? color, Widget? child) {
              final Color resolvedColor = color ?? foreground;
              final TextStyle labelStyle =
                  (textTheme.labelMedium ?? const TextStyle(fontSize: 12))
                      .copyWith(color: resolvedColor, fontWeight: labelWeight);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(destination.icon, size: 22, color: resolvedColor),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    style: labelStyle,
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
