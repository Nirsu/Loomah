import 'package:flutter/material.dart';
import 'package:loomah/env/env.dart';
import 'package:loomah/features/map/data/models/place_photo.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// A carousel widget to display a list of [PlacePhoto]
class ImageCarousel extends StatefulWidget {
  /// Default constructor
  const ImageCarousel({required this.photos, super.key});

  /// The list of photos to display
  final List<PlacePhoto> photos;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _controller = PageController();

  String _buildImageUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }
    final Uri apiUri = Uri.parse(Env.apiBaseUrl);
    final String origin = apiUri.origin;
    final String cleanPath = path.startsWith('/') ? path : '/$path';
    return '$origin$cleanPath';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return ColoredBox(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: <Widget>[
        PageView.builder(
          controller: _controller,
          itemCount: widget.photos.length,
          itemBuilder: (BuildContext context, int index) {
            final PlacePhoto photo = widget.photos[index];
            print('Image URL: ${_buildImageUrl(photo.url)}');
            return Image.network(
              _buildImageUrl(photo.url),
              fit: BoxFit.cover,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return ColoredBox(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
            );
          },
        ),
        if (widget.photos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: widget.photos.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
