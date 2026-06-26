import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loomah/features/auth/application/auth_controller.dart';
import 'package:loomah/features/auth/data/models/auth_session.dart';
import 'package:loomah/features/home/presentation/widgets/floating_bottom_nav_metrics.dart';
import 'package:loomah/i18n/strings.g.dart';
import 'package:loomah/theme/loomah_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// A page that displays and edits the user's profile.
class ProfilePage extends ConsumerWidget {
  /// Creates a [ProfilePage].
  const ProfilePage({super.key});

  static final Uri _termsOfUseUrl = Uri.parse('https://loomah.fr/terms-of-use');
  static final Uri _privacyPolicyUrl = Uri.parse(
    'https://loomah.fr/privacy-policy',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState auth = ref.watch(authControllerProvider);
    final AuthUser user = auth.session!.user;
    final double bottomClearance = FloatingBottomNavMetrics.clearance(context);
    final Translations$profile$fr profile = Translations.of(context).profile;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 24, 20, bottomClearance),
        children: <Widget>[
          _ProfileHeader(name: user.username, email: user.email),
          const SizedBox(height: 28),
          _ProfileSection(
            title: profile.sections.account,
            children: <Widget>[
              _ProfileRow(
                icon: LucideIcons.user_round,
                title: profile.rows.personalInfo,
                subtitle: profile.rows.personalInfoSubtitle,
                onTap: () =>
                    _editProfile(context: context, ref: ref, user: user),
              ),
              _ProfileRow(
                icon: LucideIcons.lock_keyhole,
                title: profile.rows.password,
                subtitle: profile.rows.passwordSubtitle,
                onTap: () => _changePassword(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileSection(
            title: profile.sections.preferences,
            children: <Widget>[
              _ProfileRow(
                icon: LucideIcons.globe,
                title: profile.rows.language,
                subtitle: _languageName(profile, LocaleSettings.currentLocale),
                onTap: () => _changeLanguage(context),
              ),
              _ProfileRow(
                icon: LucideIcons.bell,
                title: profile.rows.notifications,
                subtitle: profile.rows.notificationsSubtitle,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileSection(
            title: profile.sections.legal,
            children: <Widget>[
              _ProfileRow(
                icon: LucideIcons.file_text,
                title: profile.rows.terms,
                onTap: () => _openLegalUrl(context, _termsOfUseUrl),
              ),
              _ProfileRow(
                icon: LucideIcons.shield_check,
                title: profile.rows.privacy,
                onTap: () => _openLegalUrl(context, _privacyPolicyUrl),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileSection(
            title: profile.sections.session,
            children: <Widget>[
              _ProfileRow(
                icon: LucideIcons.log_out,
                title: profile.rows.logout,
                tint: context.loomahPalette.accentSecondary,
                onTap: () => ref.read(authControllerProvider.notifier).logout(),
              ),
              _ProfileRow(
                icon: LucideIcons.trash_2,
                title: profile.rows.deleteAccount,
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
      _showSoon(
        context,
        Translations.of(context).profile.snackbars.profileUpdated,
      );
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
      _showSoon(
        context,
        Translations.of(context).profile.snackbars.passwordChanged,
      );
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

  Future<void> _changeLanguage(BuildContext context) async {
    final Translations$profile$fr profile = Translations.of(context).profile;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (BuildContext context) {
        final AppLocale currentLocale = LocaleSettings.currentLocale;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    profile.language.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              _LanguageTile(
                title: profile.language.french,
                locale: AppLocale.fr,
                currentLocale: currentLocale,
              ),
              _LanguageTile(
                title: profile.language.english,
                locale: AppLocale.en,
                currentLocale: currentLocale,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openLegalUrl(BuildContext context, Uri uri) async {
    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      // Keep the same visible fallback when the platform cannot open the URL.
    }

    if (!opened && context.mounted) {
      _showSoon(
        context,
        Translations.of(context).profile.snackbars.legalOpenFailed,
      );
    }
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.locale,
    required this.currentLocale,
  });

  final String title;
  final AppLocale locale;
  final AppLocale currentLocale;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final bool selected = locale == currentLocale;

    return ListTile(
      title: Text(title),
      trailing: selected
          ? Icon(LucideIcons.check, color: palette.accentPrimary)
          : null,
      onTap: () async {
        await LocaleSettings.setLocale(locale);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
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
    final bool enabled = onTap != null;
    final Color color = enabled ? tint ?? palette.textDark : palette.textLight;

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
            if (enabled)
              Icon(
                LucideIcons.chevron_right,
                size: 20,
                color: palette.textLight,
              ),
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
    final Translations$profile$fr profile = Translations.of(context).profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isConfirmingEmail ? profile.edit.confirmTitle : profile.edit.title,
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
                    ? profile.edit.confirmSubtitle(pendingEmail: _pendingEmail!)
                    : profile.edit.subtitle,
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
                              : profile.edit.codeValidation,
                          decoration: InputDecoration(
                            labelText: profile.edit.codeLabel,
                          ),
                        )
                      : Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              validator: (String? value) =>
                                  _required(value, profile.validation.required),
                              decoration: InputDecoration(
                                labelText: profile.edit.nameLabel,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (String? value) => _emailValidator(
                                value,
                                requiredMessage: profile.validation.required,
                                invalidEmailMessage:
                                    profile.validation.invalidEmail,
                              ),
                              decoration: InputDecoration(
                                labelText: profile.edit.emailLabel,
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
                    : Text(
                        isConfirmingEmail
                            ? profile.edit.confirmButton
                            : profile.edit.saveButton,
                      ),
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
    final Translations$profile$fr profile = Translations.of(context).profile;

    return Scaffold(
      appBar: AppBar(title: Text(profile.password.title)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              _ProfilePasswordField(
                controller: _currentController,
                label: profile.password.currentLabel,
              ),
              const SizedBox(height: 14),
              _ProfilePasswordField(
                controller: _newController,
                label: profile.password.newLabel,
              ),
              const SizedBox(height: 14),
              _ProfilePasswordField(
                controller: _confirmController,
                label: profile.password.confirmLabel,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return profile.validation.required;
                  }
                  return value == _newController.text
                      ? null
                      : profile.validation.passwordMismatch;
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
                    : Text(profile.password.submitButton),
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
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final Translations$profile$fr profile = Translations.of(context).profile;

    return TextFormField(
      controller: controller,
      obscureText: true,
      validator:
          validator ??
          (String? value) => _required(value, profile.validation.required),
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
    final Translations$profile$fr profile = Translations.of(context).profile;

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
                profile.deleteAccount.title,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  color: palette.textDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profile.deleteAccount.body,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: palette.textLight),
              ),
              const SizedBox(height: 16),
              _ProfilePasswordField(
                controller: _passwordController,
                label: profile.password.currentLabel,
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
                          : Text(profile.deleteAccount.submitButton),
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
                      child: Text(profile.deleteAccount.cancelButton),
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

String _languageName(Translations$profile$fr profile, AppLocale locale) {
  return switch (locale) {
    AppLocale.fr => profile.language.french,
    AppLocale.en => profile.language.english,
  };
}

String? _required(String? value, String message) {
  return value == null || value.trim().isEmpty ? message : null;
}

String? _emailValidator(
  String? value, {
  required String requiredMessage,
  required String invalidEmailMessage,
}) {
  final String email = value?.trim() ?? '';
  if (email.isEmpty) {
    return requiredMessage;
  }
  return email.contains('@') ? null : invalidEmailMessage;
}
