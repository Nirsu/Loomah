import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/features/auth/application/auth_controller.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// A page that displays the user's profile.
class ProfilePage extends ConsumerWidget {
  /// Creates a [ProfilePage].
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState auth = ref.watch(authControllerProvider);
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Map<String, dynamic>? user = auth.session?.user.data;
    final String name =
        user?['username'] as String? ?? user?['email'] as String? ?? 'Profil';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              name,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?['email'] as String? ?? 'Votre profil apparaîtra ici.',
              style: textTheme.bodyLarge?.copyWith(color: palette.textLight),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                },
                child: const Text('Se déconnecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
