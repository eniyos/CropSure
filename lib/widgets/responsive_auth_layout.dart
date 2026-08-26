import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

/// Shared centered column layout for auth screens (Chrome + mobile).
class ResponsiveAuthLayout extends StatelessWidget {
  const ResponsiveAuthLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? AppSpacing.xl : AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - AppSpacing.lg,
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }
}
