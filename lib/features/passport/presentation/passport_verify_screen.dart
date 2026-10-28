import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/load_state.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/passport_controller.dart';

class PassportVerifyScreen extends StatefulWidget {
  const PassportVerifyScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  State<PassportVerifyScreen> createState() => _PassportVerifyScreenState();
}

class _PassportVerifyScreenState extends State<PassportVerifyScreen> {
  late final PassportController _controller;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).passportController;
    _codeController = TextEditingController(text: widget.initialCode ?? '');
    _controller.clearVerification();
    if (widget.initialCode != null && widget.initialCode!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.verify(widget.initialCode!);
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() => _controller.verify(_codeController.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Verify passport',
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final result = _controller.verification;
          final busy = _controller.verifyState == LoadState.loading;
          final successWithPassport =
              result != null && result.isValid && result.passport != null;

          return ResponsiveContent(
            child: ListView(
              children: [
                Text(
                  'Enter the code from a CropSure passport QR to validate crop provenance.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  glass: true,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _codeController,
                        label: 'Verification code',
                        hint: 'e.g. CS-PASS-01',
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.qr_code_2_rounded,
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Verify code',
                        icon: Icons.verified_user_outlined,
                        onPressed: busy ? null : _submit,
                        isLoading: busy,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Try demo code CS-PASS-01',
                        variant: AppButtonVariant.outlined,
                        onPressed: busy
                            ? null
                            : () {
                                _codeController.text = 'CS-PASS-01';
                                _submit();
                              },
                      ),
                    ],
                  ),
                ),
                if (busy) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const LoadingWidget(message: 'Checking code…'),
                ],
                if (_controller.verifyState == LoadState.error) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppErrorView(
                    message: _controller.errorMessage ?? 'Verification failed.',
                    onRetry: _submit,
                  ),
                ],
                if (result != null && !busy) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    glass: true,
                    emphasized: successWithPassport,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              result.isValid
                                  ? Icons.check_circle_rounded
                                  : Icons.error_outline_rounded,
                              color: successWithPassport
                                  ? AppColors.white
                                  : (result.isValid
                                      ? AppColors.success
                                      : AppColors.error),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                result.isValid
                                    ? 'Verification succeeded'
                                    : 'Verification failed',
                                style: AppTypography.display(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: successWithPassport
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          result.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: successWithPassport
                                ? AppColors.white.withValues(alpha: 0.9)
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (result.passport != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          StatusBadge(
                            label: result.passport!.status.displayName,
                            tone: StatusBadgeTone.success,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            result.passport!.cropLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: successWithPassport
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            result.passport!.farmName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: successWithPassport
                                  ? AppColors.white.withValues(alpha: 0.8)
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: 'Open passport',
                            variant: successWithPassport
                                ? AppButtonVariant.forest
                                : AppButtonVariant.outlined,
                            onPressed: () => context.push(
                              AppRoutes.passportDetailsPath(
                                result.passport!.id,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
