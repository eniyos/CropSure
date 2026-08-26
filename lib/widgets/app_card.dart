import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Frosted or solid surface card for CropSure.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.semanticLabel,
    this.glass = false,
    this.emphasized = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool glass;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    final radius = BorderRadius.circular(AppSpacing.radiusLg);
    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: BorderSide(
        color: emphasized
            ? AppColors.leafBright.withValues(alpha: 0.4)
            : AppColors.neutral200,
      ),
    );

    Widget material = Material(
      color: emphasized
          ? AppColors.leaf
          : (glass
              ? AppColors.white.withValues(alpha: 0.78)
              : AppColors.white),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, borderRadius: radius, child: content),
    );

    if (glass) {
      material = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: material,
        ),
      );
    }

    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: material,
    );

    if (semanticLabel == null) return card;
    return Semantics(label: semanticLabel, button: onTap != null, child: card);
  }
}
