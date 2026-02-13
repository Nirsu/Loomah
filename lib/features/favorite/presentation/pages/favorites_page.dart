import 'package:flutter/material.dart';

/// A page that displays the user's favorite places.
class FavoritesPage extends StatelessWidget {
  /// Creates a [FavoritesPage].
  const FavoritesPage({super.key});

  /// The route path.
  static const String path = '/favorites';

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Vos lieux favoris apparaitront ici.'));
  }
}
