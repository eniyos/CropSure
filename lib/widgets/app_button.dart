import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

enum AppButtonVariant { filled, outlined, text, forest }

/// Pill CTA — Amaranth green-600 primary.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final onDark = variant == AppButtonVariant.filled ||
        variant == AppButtonVariant.forest;

    final child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: onDark ? AppColors.white : AppColors.green600,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(label),
            ],
          );

    final button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
        onPressed: enabled ? onPressed : null,
        child: child,
      ),
      AppButtonVariant.forest => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green700,
          foregroundColor: AppColors.white,
        ),
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: enabled ? onPressed : null,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: enabled ? onPressed : null,
        child: child,
      ),
    };

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
