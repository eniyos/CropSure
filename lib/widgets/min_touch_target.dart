import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

/// Ensures interactive children meet the minimum touch target size.
class MinTouchTarget extends StatelessWidget {
  const MinTouchTarget({
    super.key,
    required this.child,
    this.size = AppSpacing.minTouchTarget,
    this.semanticLabel,
    this.onTap,
  });

  final Widget child;
  final double size;
  final String? semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      child: Center(child: child),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: content,
      );
    }

    if (semanticLabel == null) return content;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: content,
    );
  }
}
