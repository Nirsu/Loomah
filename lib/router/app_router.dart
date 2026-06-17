import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loomah/features/auth/application/auth_controller.dart';
import 'package:loomah/features/auth/presentation/pages/auth_pages.dart';
import 'package:loomah/features/home/presentation/pages/home_page.dart';
import 'package:loomah/features/map/presentation/pages/place_details_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Router for the app.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final AuthStatus authStatus = ref.watch(authStatusProvider);

  return GoRouter(
    initialLocation: AuthSplashPage.route,
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.matchedLocation;
      final bool isAuthRoute = <String>{
        LoginPage.route,
        RegisterPage.route,
        ForgotPasswordPage.route,
        ResetPasswordPage.route,
      }.contains(location);
      final bool hasResetEmail = state.extra is String;

      if (authStatus == AuthStatus.loading) {
        return location == AuthSplashPage.route ? null : AuthSplashPage.route;
      }
      if (authStatus == AuthStatus.unauthenticated) {
        if (location == ResetPasswordPage.route && !hasResetEmail) {
          return ForgotPasswordPage.route;
        }
        return isAuthRoute ? null : LoginPage.route;
      }
      if (location == AuthSplashPage.route || isAuthRoute) {
        return HomePage.route;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AuthSplashPage.route,
        builder: (BuildContext context, GoRouterState state) {
          return const AuthSplashPage();
        },
      ),
      GoRoute(
        path: LoginPage.route,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: RegisterPage.route,
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: ForgotPasswordPage.route,
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordPage();
        },
      ),
      GoRoute(
        path: ResetPasswordPage.route,
        builder: (BuildContext context, GoRouterState state) {
          final Object? email = state.extra;
          return ResetPasswordPage(email: email is String ? email : null);
        },
      ),
      GoRoute(
        path: HomePage.route,
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),
      GoRoute(
        path: PlaceDetailsPage.route,
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['id']!;
          return PlaceDetailsPage(id: id);
        },
      ),
    ],
  );
}
