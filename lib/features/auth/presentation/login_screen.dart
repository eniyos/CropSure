import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/brand_mark.dart';
import '../../../widgets/living_background.dart';
import '../../../widgets/responsive_auth_layout.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: AppConstants.demoEmail,
  );
  final _passwordController = TextEditingController();
  bool _obscure = true;

  AuthController get _auth => widget.authController;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await _auth.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      body: LivingBackground(
        variant: LivingBackgroundVariant.dark,
        showFieldPhoto: true,
        scene: AgriScene.greenCanopy,
        scrimStrength: 0.5,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _auth,
            builder: (context, _) {
              final form = _LoginForm(
                formKey: _formKey,
                theme: theme,
                auth: _auth,
                emailController: _emailController,
                passwordController: _passwordController,
                obscure: _obscure,
                onToggleObscure: () => setState(() => _obscure = !_obscure),
                onSubmit: _submit,
              );

              if (!wide) {
                return ResponsiveAuthLayout(child: form);
              }

              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BrandMark(size: 56),
                          const Spacer(),
                          Text(
                            'CROPSURE',
                            style: AppTypography.display(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.harvest,
                              letterSpacing: 3.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'CropSure',
                            style: AppTypography.display(
                              fontSize: 58,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                              letterSpacing: -1.6,
                              height: 1.02,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'AI crop trust, disease insight, and digital\npassports — rooted in real field data.',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.88),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _Pill(label: 'Trust scoring'),
                              _Pill(label: 'Disease AI'),
                              _Pill(label: 'Weather + market'),
                            ],
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: form,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.theme,
    required this.auth,
    required this.emailController,
    required this.passwordController,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final ThemeData theme;
  final AuthController auth;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: AppCard(
        glass: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const BrandMark(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: AppTypography.display(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Sign in to your farm workspace',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (auth.sessionExpired || auth.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  auth.sessionExpired
                      ? 'Your session expired. Please sign in again.'
                      : auth.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: emailController,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.mail_outline,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              onChanged: (_) => auth.clearError(),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: passwordController,
              label: 'Password',
              obscureText: obscure,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline,
              autofillHints: const [AutofillHints.password],
              validator: Validators.password,
              onSubmitted: (_) => onSubmit(),
              onChanged: (_) => auth.clearError(),
              suffixIcon: IconButton(
                tooltip: obscure ? 'Show password' : 'Hide password',
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: auth.isBusy
                    ? null
                    : () => context.push(AppRoutes.forgotPassword),
                child: const Text('Forgot password?'),
              ),
            ),
            AppButton(
              label: 'Sign in',
              onPressed: auth.isBusy ? null : onSubmit,
              isLoading: auth.isBusy,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Create farmer account',
              variant: AppButtonVariant.outlined,
              onPressed: auth.isBusy
                  ? null
                  : () => context.push(AppRoutes.register),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Demo: ${AppConstants.demoEmail} / ${AppConstants.demoPassword}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
