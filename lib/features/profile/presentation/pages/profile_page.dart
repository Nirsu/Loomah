import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/features/auth/application/auth_controller.dart';
import 'package:loomah/features/auth/data/models/auth_session.dart';
import 'package:loomah/features/home/presentation/widgets/floating_bottom_nav_metrics.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// A page that displays and edits the user's profile.
class ProfilePage extends ConsumerWidget {
  /// Creates a [ProfilePage].
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState auth = ref.watch(authControllerProvider);
    final AuthUser user = auth.session!.user;
    final double bottomClearance = FloatingBottomNavMetrics.clearance(context);

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 24, 20, bottomClearance),
        children: <Widget>[
          _ProfileHeader(name: user.username, email: user.email),
          const SizedBox(height: 28),
          _ProfileSection(
            title: 'Compte',
            children: <Widget>[
              _ProfileRow(
                icon: LucideIcons.user_round,
                title: 'Informations personnelles',
                subtitle: 'Nom, email',
                onTap: () =>
                    _editProfile(context: context, ref: ref, user: user),
              ),
              _ProfileRow(
                icon: LucideIcons.lock_keyhole,
                title: 'Mot de passe',
                subtitle: 'Modifier ton mot de passe',
                onTap: () => _changePassword(context, ref),
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
                onTap: () => _showSoon(
                  context,
                  'Préférences de notifications à brancher',
                ),
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
                onTap: () => _showSoon(context, 'Lien CGU à brancher'),
              ),
              _ProfileRow(
                icon: LucideIcons.shield_check,
                title: 'Politique de confidentialité',
                onTap: () =>
                    _showSoon(context, 'Lien confidentialité à brancher'),
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
                onTap: () => _confirmDeleteAccount(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile({
    required BuildContext context,
    required WidgetRef ref,
    required AuthUser user,
  }) async {
    ref.read(authControllerProvider.notifier).clearError();
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => _EditProfilePage(
          initialName: user.username,
          initialEmail: user.email,
        ),
      ),
    );

    if (saved == true && context.mounted) {
      _showSoon(context, 'Profil mis à jour.');
    }
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    ref.read(authControllerProvider.notifier).clearError();
    final bool? changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => const _ChangePasswordPage(),
      ),
    );

    if (changed == true && context.mounted) {
      _showSoon(context, 'Mot de passe modifié.');
    }
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    ref.read(authControllerProvider.notifier).clearError();
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => const _DeleteAccountDialog(),
    );
  }

  void _showSoon(BuildContext context, String message) {
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
                for (
                  int index = 0;
                  index < children.length;
                  index++
                ) ...<Widget>[
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

class _EditProfilePage extends ConsumerStatefulWidget {
  const _EditProfilePage({
    required this.initialName,
    required this.initialEmail,
  });

  final String initialName;
  final String initialEmail;

  @override
  ConsumerState<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<_EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final TextEditingController _codeController = TextEditingController();
  String? _pendingEmail;

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
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AuthState auth = ref.watch(authControllerProvider);
    final bool isConfirmingEmail = _pendingEmail != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isConfirmingEmail
              ? 'Confirmer le nouvel email'
              : 'Informations personnelles',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: <Widget>[
              Text(
                isConfirmingEmail
                    ? 'Un code à 6 chiffres a été envoyé à $_pendingEmail. '
                          'Il expire après 10 minutes et 5 essais.'
                    : 'Ces informations seront utilisées pour personnaliser ton compte.',
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
                  child: isConfirmingEmail
                      ? TextFormField(
                          controller: _codeController,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (String? value) => value?.length == 6
                              ? null
                              : 'Saisis le code à 6 chiffres.',
                          decoration: const InputDecoration(
                            labelText: 'Code de confirmation',
                          ),
                        )
                      : Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              validator: _required,
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _emailValidator,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (auth.error case final String error) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  error,
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.accentSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: auth.isBusy ? null : _submit,
                child: auth.isBusy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isConfirmingEmail ? 'Confirmer' : 'Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final AuthController controller = ref.read(authControllerProvider.notifier);
    if (_pendingEmail != null) {
      final bool confirmed = await controller.confirmEmail(
        _codeController.text,
      );
      if (confirmed && mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    final String username = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String? changedUsername = username == widget.initialName
        ? null
        : username;
    final String? changedEmail = email == widget.initialEmail ? null : email;
    if (changedUsername == null && changedEmail == null) {
      Navigator.of(context).pop(false);
      return;
    }

    final ProfileUpdateResult? result = await controller.updateProfile(
      username: changedUsername,
      email: changedEmail,
    );
    if (!mounted || result == null) {
      return;
    }
    if (result.emailVerificationRequired && result.pendingEmail != null) {
      setState(() => _pendingEmail = result.pendingEmail);
      return;
    }
    Navigator.of(context).pop(true);
  }
}

class _ChangePasswordPage extends ConsumerStatefulWidget {
  const _ChangePasswordPage();

  @override
  ConsumerState<_ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<_ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);
    final LoomahPalette palette = context.loomahPalette;

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le mot de passe')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              _ProfilePasswordField(
                controller: _currentController,
                label: 'Mot de passe actuel',
              ),
              const SizedBox(height: 14),
              _ProfilePasswordField(
                controller: _newController,
                label: 'Nouveau mot de passe',
              ),
              const SizedBox(height: 14),
              _ProfilePasswordField(
                controller: _confirmController,
                label: 'Confirmer le nouveau mot de passe',
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis.';
                  }
                  return value == _newController.text
                      ? null
                      : 'Les mots de passe ne correspondent pas.';
                },
              ),
              if (auth.error case final String error) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  error,
                  style: TextStyle(
                    color: palette.accentSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: auth.isBusy ? null : _submit,
                child: auth.isBusy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Modifier le mot de passe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final bool changed = await ref
        .read(authControllerProvider.notifier)
        .changePassword(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
          confirmNewPassword: _confirmController.text,
        );
    if (changed && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

class _ProfilePasswordField extends StatelessWidget {
  const _ProfilePasswordField({
    required this.controller,
    required this.label,
    this.validator = _required,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AuthState auth = ref.watch(authControllerProvider);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 26,
                backgroundColor: palette.accentLight,
                child: Icon(
                  LucideIcons.trash_2,
                  color: palette.accentSecondary,
                ),
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
              const SizedBox(height: 16),
              _ProfilePasswordField(
                controller: _passwordController,
                label: 'Mot de passe actuel',
              ),
              if (auth.error case final String error) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.accentSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: auth.isBusy ? null : _deleteAccount,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accentSecondary,
                      ),
                      child: auth.isBusy
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Supprimer mon compte'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: auth.isBusy
                          ? null
                          : () => Navigator.of(context).pop(false),
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
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    final bool deleted = await ref
        .read(authControllerProvider.notifier)
        .deleteAccount(_passwordController.text);
    if (deleted && mounted) {
      navigator.pop(true);
    }
  }
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

String? _required(String? value) {
  return value == null || value.trim().isEmpty ? 'Ce champ est requis.' : null;
}

String? _emailValidator(String? value) {
  final String email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Ce champ est requis.';
  }
  return email.contains('@') ? null : 'Saisis un email valide.';
}
