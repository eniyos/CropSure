import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/agri_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/brand_mark.dart';
import '../../../widgets/responsive_auth_layout.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  AuthController get _auth => widget.authController;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await _auth.register(
      fullName: _nameController.text,
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
      backgroundColor: AppColors.leafDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              AgriAssets.signupFieldSunset,
              fit: BoxFit.cover,
              alignment: const Alignment(0.25, 0),
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) {
                return const ColoredBox(color: AppColors.leafDeep);
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.28),
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListenableBuilder(
              listenable: _auth,
              builder: (context, _) {
                final form = _RegisterForm(
                  formKey: _formKey,
                  theme: theme,
                  auth: _auth,
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmController: _confirmController,
                  obscure: _obscure,
                  obscureConfirm: _obscureConfirm,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onToggleObscureConfirm: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  onSubmit: _submit,
                );

                if (!wide) {
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: 'Back',
                          color: AppColors.white,
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.login);
                            }
                          },
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      Expanded(child: ResponsiveAuthLayout(child: form)),
                    ],
                  );
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
                            Row(
                              children: [
                                IconButton(
                                  tooltip: 'Back',
                                  color: AppColors.white,
                                  onPressed: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go(AppRoutes.login);
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_back_rounded),
                                ),
                                const SizedBox(width: 8),
                                const BrandMark(size: 52, onCream: true),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'CropSure',
                              style: AppTypography.display(
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                                letterSpacing: -1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Create your farmer workspace — trust scores,\ndisease insight, and digital crop passports.',
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
                          child: SingleChildScrollView(
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
        ],
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
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.theme,
    required this.auth,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.obscure,
    required this.obscureConfirm,
    required this.onToggleObscure,
    required this.onToggleObscureConfirm,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final ThemeData theme;
  final AuthController auth;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscure;
  final bool obscureConfirm;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleObscureConfirm;
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
                        'Join as a farmer',
                        style: AppTypography.display(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Create your CropSure account',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (auth.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  auth.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: nameController,
              label: 'Full name',
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validators.fullName,
              onChanged: (_) => auth.clearError(),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              onChanged: (_) => auth.clearError(),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: passwordController,
              label: 'Password',
              obscureText: obscure,
              prefixIcon: Icons.lock_outline,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.password,
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
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: confirmController,
              label: 'Confirm password',
              obscureText: obscureConfirm,
              prefixIcon: Icons.lock_outline,
              textInputAction: TextInputAction.done,
              validator: (value) => Validators.confirmPassword(
                value,
                passwordController.text,
              ),
              onSubmitted: (_) => onSubmit(),
              suffixIcon: IconButton(
                tooltip:
                    obscureConfirm ? 'Show password' : 'Hide password',
                onPressed: onToggleObscureConfirm,
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Create account',
              onPressed: auth.isBusy ? null : onSubmit,
              isLoading: auth.isBusy,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Already have an account? Sign in',
              variant: AppButtonVariant.outlined,
              onPressed:
                  auth.isBusy ? null : () => context.go(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}
