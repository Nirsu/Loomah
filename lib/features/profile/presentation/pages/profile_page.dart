import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/features/auth/application/auth_controller.dart';
import 'package:loomah/features/home/presentation/widgets/floating_bottom_nav_metrics.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// A page that displays and edits the user's profile.
class ProfilePage extends ConsumerStatefulWidget {
  /// Creates a [ProfilePage].
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String? _name;
  String? _email;

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);
    final Map<String, dynamic>? user = auth.session?.user.data;
    final String name = _name ?? _userName(user);
    final String email = _email ?? _userEmail(user);
    final double bottomClearance = FloatingBottomNavMetrics.clearance(context);

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          bottomClearance,
        ),
        children: <Widget>[
          _ProfileHeader(name: name, email: email),
          const SizedBox(height: 28),
          _ProfileSection(
            title: 'Compte',
            children: <Widget>[
              _ProfileRow(
                icon: LucideIcons.user_round,
                title: 'Informations personnelles',
                subtitle: 'Nom, email',
                onTap: () => _editProfile(name: name, email: email),
              ),
              _ProfileRow(
                icon: LucideIcons.lock_keyhole,
                title: 'Mot de passe',
                subtitle: 'Modifier ton mot de passe',
                onTap: () => _showSoon('Changement de mot de passe à brancher'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileSection(
            title: 'Préférences',
            children: <Widget>[
              _ProfileRow(
                icon: LucideIcons.bell,
                title: 'Notifications',
                subtitle: 'Alertes et rappels',
                onTap: () =>
                    _showSoon('Préférences de notifications à brancher'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileSection(
            title: 'Légal',
            children: <Widget>[
              _ProfileRow(
                icon: LucideIcons.file_text,
                title: 'Conditions générales d’utilisation',
                onTap: () => _showSoon('Lien CGU à brancher'),
              ),
              _ProfileRow(
                icon: LucideIcons.shield_check,
                title: 'Politique de confidentialité',
                onTap: () => _showSoon('Lien confidentialité à brancher'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileSection(
            title: 'Session',
            children: <Widget>[
              _ProfileRow(
                icon: LucideIcons.log_out,
                title: 'Se déconnecter',
                tint: context.loomahPalette.accentSecondary,
                onTap: () => ref.read(authControllerProvider.notifier).logout(),
              ),
              _ProfileRow(
                icon: LucideIcons.trash_2,
                title: 'Supprimer mon compte',
                tint: context.loomahPalette.accentSecondary,
                onTap: _confirmDeleteAccount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile({
    required String name,
    required String email,
  }) async {
    final _ProfileEditResult? result = await Navigator.of(context)
        .push<_ProfileEditResult>(
          MaterialPageRoute<_ProfileEditResult>(
            builder: (BuildContext context) =>
                _EditProfilePage(initialName: name, initialEmail: email),
          ),
        );

    if (result == null || !mounted) return;
    setState(() {
      _name = result.name;
      _email = result.email;
    });
    _showSoon('UI enregistrée localement, API profil à brancher');
  }

  Future<void> _confirmDeleteAccount() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => const _DeleteAccountDialog(),
    );

    if (confirmed == true && mounted) {
      _showSoon('Suppression de compte à brancher');
    }
  }

  void _showSoon(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 34,
          backgroundColor: palette.accentLight,
          child: Text(
            _initials(name, email),
            style: textTheme.titleLarge?.copyWith(
              color: palette.accentPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineMedium?.copyWith(
                  color: palette.textDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(color: palette.textLight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final BorderRadius borderRadius = BorderRadius.circular(18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: textTheme.labelLarge?.copyWith(
              color: palette.textLight,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: borderRadius,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
              side: BorderSide(color: palette.textDark.withValues(alpha: .08)),
            ),
            child: Column(
              children: <Widget>[
                for (int index = 0; index < children.length; index++)
                  ...<Widget>[
                  if (index > 0)
                    Divider(
                      height: 1,
                      indent: 48,
                      color: palette.textDark.withValues(alpha: .08),
                    ),
                  children[index],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.tint,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color color = tint ?? palette.textDark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle case final String subtitle) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: palette.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(LucideIcons.chevron_right, size: 20, color: palette.textLight),
          ],
        ),
      ),
    );
  }
}

class _EditProfilePage extends StatefulWidget {
  const _EditProfilePage({
    required this.initialName,
    required this.initialEmail,
  });

  final String initialName;
  final String initialEmail;

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Informations personnelles')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: <Widget>[
            Text(
              'Ces informations seront utilisées pour personnaliser ton compte.',
              style: textTheme.bodyMedium?.copyWith(color: palette.textLight),
            ),
            const SizedBox(height: 18),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: palette.textDark.withValues(alpha: .08),
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Nom'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  _ProfileEditResult(
                    name: _nameController.text.trim(),
                    email: _emailController.text.trim(),
                  ),
                );
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountDialog extends StatelessWidget {
  const _DeleteAccountDialog();

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 26,
              backgroundColor: palette.accentLight,
              child: Icon(LucideIcons.trash_2, color: palette.accentSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Supprimer le compte ?',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: palette.textDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ton profil, tes favoris et tes préférences seront supprimés définitivement.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: palette.textLight),
            ),
            const SizedBox(height: 22),
            Column(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.accentSecondary,
                    ),
                    child: const Text('Supprimer mon compte'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.accentLight,
                      foregroundColor: palette.accentSecondary,
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEditResult {
  const _ProfileEditResult({required this.name, required this.email});

  final String name;
  final String email;
}

String _userName(Map<String, dynamic>? user) {
  return user?['username'] as String? ?? user?['email'] as String? ?? 'Profil';
}

String _userEmail(Map<String, dynamic>? user) {
  return user?['email'] as String? ?? 'Email non renseigné';
}

String _initials(String name, String email) {
  final String source = name == 'Profil' ? email : name;
  final List<String> parts = source
      .trim()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) return 'P';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();

  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
