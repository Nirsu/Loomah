import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loomah/env/env.dart';
import 'package:loomah/i18n/strings.g.dart';
import 'package:loomah/router/app_router.dart';
import 'package:loomah/theme/loomah_theme.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

Future<void> main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  MapboxOptions.setAccessToken(Env.mapboxAccessToken);
  await LocaleSettings.useDeviceLocale();

  runApp(ProviderScope(child: TranslationProvider(child: MyApp())));
}

/// The main application widget.
class MyApp extends ConsumerWidget {
  /// Creates a [MyApp] widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      theme: LoomahTheme.light(),
      routerConfig: router,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
