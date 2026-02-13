import 'package:flutter/material.dart';
import 'package:loomah/features/map/presentation/widgets/custom_map_widget.dart';

/// A page that hosts the map.
class MapPage extends StatelessWidget {
  /// Creates a [MapPage].
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomMapWidget();
  }
}
