import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loomah/features/home/presentation/pages/home_page.dart';
import 'package:loomah/features/map/presentation/pages/place_details_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Router for the app.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),
      GoRoute(
        path: '/places/:id',
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['id']!;
          return PlaceDetailsPage(id: id);
        },
      ),
    ],
  );
}
