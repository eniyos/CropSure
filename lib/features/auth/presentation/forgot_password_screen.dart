import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/brand_mark.dart';
import '../../../widgets/responsive_auth_layout.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  AuthController get _auth => widget.authController;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await _auth.requestPasswordReset(
      email: _emailController.text,
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Forgot password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: AppAtmosphere(
        child: SafeArea(
        child: ListenableBuilder(
          listenable: _auth,
          builder: (context, _) {
            return ResponsiveAuthLayout(
              child: _submitted
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.mark_email_read_outlined,
                          size: 56,
                          color: AppColors.success,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Check your email',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'If an account exists for ${_emailController.text.trim()}, '
                          'you will receive password reset instructions.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: 'Back to sign in',
                          onPressed: () => context.pop(),
                        ),
                      ],
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Reset your password',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Enter the email associated with your CropSure account.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (_auth.errorMessage != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            AppCard(
                              child: Text(
                                _auth.errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.mail_outline,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.email],
                            validator: Validators.email,
                            onSubmitted: (_) => _submit(),
                            onChanged: (_) => _auth.clearError(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(
                            label: 'Send reset link',
                            onPressed: _auth.isBusy ? null : _submit,
                            isLoading: _auth.isBusy,
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
      ),
    );
  }
}
