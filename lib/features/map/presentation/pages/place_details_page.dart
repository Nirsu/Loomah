import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/features/map/data/providers/place_details_provider.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Détails du lieu')),
      body: placeDetailsAsync.when(
        data: (PlaceDetails place) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  place.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  place.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                // L'UI complète sera faite plus tard.
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        // TODO(Nirsu): Handle error state.
        error: (Object error, StackTrace stack) =>
            Center(child: Text('An error occurred')),
      ),
    );
  }
}
