import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loomah/features/auth/application/auth_controller.dart';
import 'package:loomah/i18n/strings.g.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// Splash page used while restoring the session.
class AuthSplashPage extends StatelessWidget {
  /// Creates an [AuthSplashPage].
  const AuthSplashPage({super.key});

  /// Route path.
  static const String route = '/splash';

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: palette.accentPrimary),
      ),
    );
  }
}

/// Login page.
class LoginPage extends ConsumerStatefulWidget {
  /// Creates a [LoginPage].
  const LoginPage({super.key});

  /// Route path.
  static const String route = '/login';

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(authControllerProvider.notifier).clearError();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);
    final Translations$auth$fr authText = Translations.of(context).auth;

    return _AuthScaffold(
      title: authText.login.title,
      subtitle: authText.login.subtitle,
      icon: LucideIcons.sparkles,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _EmailField(controller: _emailController),
            const SizedBox(height: 14),
            _PasswordField(controller: _passwordController),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(ForgotPasswordPage.route),
                child: Text(authText.login.forgotPassword),
              ),
            ),
            _ErrorText(auth.error),
            const SizedBox(height: 8),
            _SubmitButton(
              label: authText.login.submit,
              isBusy: auth.isBusy,
              onPressed: _submit,
            ),
            const SizedBox(height: 18),
            _SwitchAuthLink(
              text: authText.login.switchText,
              action: authText.login.switchAction,
              onTap: () => context.go(RegisterPage.route),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }
}

/// Register page.
class RegisterPage extends ConsumerStatefulWidget {
  /// Creates a [RegisterPage].
  const RegisterPage({super.key});

  /// Route path.
  static const String route = '/register';

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(authControllerProvider.notifier).clearError();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);
    final Translations$auth$fr authText = Translations.of(context).auth;

    return _AuthScaffold(
      title: authText.register.title,
      subtitle: authText.register.subtitle,
      icon: LucideIcons.user_round_plus,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _AuthTextField(
              controller: _usernameController,
              label: authText.register.usernameLabel,
              icon: LucideIcons.user_round,
              validator: (String? value) =>
                  _required(value, authText.validation.required),
            ),
            const SizedBox(height: 14),
            _EmailField(controller: _emailController),
            const SizedBox(height: 14),
            _PasswordField(controller: _passwordController),
            const SizedBox(height: 18),
            _ErrorText(auth.error),
            _SubmitButton(
              label: authText.register.submit,
              isBusy: auth.isBusy,
              onPressed: _submit,
            ),
            const SizedBox(height: 18),
            _SwitchAuthLink(
              text: authText.register.switchText,
              action: authText.register.switchAction,
              onTap: () => context.go(LoginPage.route),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }
}

/// Forgot password page.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  /// Creates a [ForgotPasswordPage].
  const ForgotPasswordPage({super.key});

  /// Route path.
  static const String route = '/password/forgot';

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(authControllerProvider.notifier).clearError();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);
    final Translations$auth$fr authText = Translations.of(context).auth;

    return _AuthScaffold(
      title: authText.forgotPassword.title,
      subtitle: authText.forgotPassword.subtitle,
      icon: LucideIcons.mail,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _EmailField(controller: _emailController),
            const SizedBox(height: 18),
            _ErrorText(auth.error),
            _SubmitButton(
              label: authText.forgotPassword.submit,
              isBusy: auth.isBusy,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            _SecondaryButton(
              label: authText.forgotPassword.back,
              onPressed: auth.isBusy ? null : _goBack,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final String email = _emailController.text.trim();
    final bool ok = await ref
        .read(authControllerProvider.notifier)
        .forgotPassword(email);
    if (!mounted || !ok) {
      return;
    }

    context.go(ResetPasswordPage.route, extra: email);
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(LoginPage.route);
  }
}

/// Reset password page.
class ResetPasswordPage extends ConsumerStatefulWidget {
  /// Creates a [ResetPasswordPage].
  const ResetPasswordPage({super.key, this.email});

  /// Route path.
  static const String route = '/password/reset';

  /// Email carried from the forgot password screen.
  final String? email;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController = TextEditingController(
    text: widget.email,
  );
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(authControllerProvider.notifier).clearError();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);
    final Translations$auth$fr authText = Translations.of(context).auth;

    return _AuthScaffold(
      title: authText.resetPassword.title,
      subtitle: authText.resetPassword.subtitle,
      icon: LucideIcons.key_round,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _EmailField(controller: _emailController),
            const SizedBox(height: 14),
            _AuthTextField(
              controller: _codeController,
              label: authText.resetPassword.codeLabel,
              icon: LucideIcons.binary,
              keyboardType: TextInputType.number,
              validator: (String? value) =>
                  _codeValidator(value, authText.validation.invalidCode),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            const SizedBox(height: 14),
            _PasswordField(controller: _passwordController),
            const SizedBox(height: 18),
            _ErrorText(auth.error),
            _SubmitButton(
              label: authText.resetPassword.submit,
              isBusy: auth.isBusy,
              onPressed: _submit,
            ),
            const SizedBox(height: 18),
            _SwitchAuthLink(
              text: authText.resetPassword.switchText,
              action: authText.resetPassword.switchAction,
              onTap: () => context.go(LoginPage.route),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          email: _emailController.text.trim(),
          code: _codeController.text.trim(),
          password: _passwordController.text,
        );
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: palette.accentLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: palette.accentSecondary, size: 26),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: textTheme.bodyLarge?.copyWith(
                      color: palette.textLight,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 32),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: palette.textDark.withValues(alpha: .08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: palette.textDark.withValues(alpha: .08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.accentPrimary, width: 1.4),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final Translations$auth$fr authText = Translations.of(context).auth;

    return _AuthTextField(
      controller: controller,
      label: authText.fields.email,
      icon: LucideIcons.mail,
      keyboardType: TextInputType.emailAddress,
      validator: (String? value) => _emailValidator(
        value,
        requiredMessage: authText.validation.required,
        invalidEmailMessage: authText.validation.invalidEmail,
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final Translations$auth$fr authText = Translations.of(context).auth;

    return _AuthTextField(
      controller: controller,
      label: authText.fields.password,
      icon: LucideIcons.lock_keyhole,
      obscureText: true,
      validator: (String? value) =>
          _required(value, authText.validation.required),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.isBusy,
    required this.onPressed,
  });

  final String label;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: isBusy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.accentPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: palette.accentPrimary.withValues(alpha: .45),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isBusy
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.accentSecondary,
          side: BorderSide(color: palette.accentPrimary.withValues(alpha: .18)),
          backgroundColor: palette.accentLight.withValues(alpha: .45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _SwitchAuthLink extends StatelessWidget {
  const _SwitchAuthLink({
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(text, style: TextStyle(color: palette.textLight)),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.error);

  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        error!,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

String? _required(String? value, String message) {
  if (value == null || value.trim().isEmpty) {
    return message;
  }

  return null;
}

String? _emailValidator(
  String? value, {
  required String requiredMessage,
  required String invalidEmailMessage,
}) {
  final String? requiredError = _required(value, requiredMessage);
  if (requiredError != null) {
    return requiredError;
  }
  if (!value!.contains('@')) {
    return invalidEmailMessage;
  }

  return null;
}

String? _codeValidator(String? value, String message) {
  if (value == null || !RegExp(r'^\d{6}$').hasMatch(value)) {
    return message;
  }

  return null;
}
