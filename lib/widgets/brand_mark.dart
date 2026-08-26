import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'living_background.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 40,
    this.letter = 'C',
    this.onCream = false,
  });

  final double size;
  final String letter;
  final bool onCream;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: onCream
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.leafBright, AppColors.leafDeep],
              ),
        color: onCream ? AppColors.white : null,
        shape: BoxShape.circle,
        border: onCream
            ? Border.all(color: AppColors.leaf, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.leaf.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        letter,
        style: AppTypography.display(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          color: onCream ? AppColors.leaf : AppColors.white,
        ),
      ),
    );
  }
}

class AppAtmosphere extends StatelessWidget {
  const AppAtmosphere({
    super.key,
    required this.child,
    this.variant = LivingBackgroundVariant.light,
    this.showFieldPhoto = false,
    this.scene = AgriScene.dawnField,
  });

  final Widget child;
  final LivingBackgroundVariant variant;
  final bool showFieldPhoto;
  final AgriScene scene;

  @override
  Widget build(BuildContext context) {
    return LivingBackground(
      variant: variant,
      showFieldPhoto: showFieldPhoto,
      scene: scene,
      child: child,
    );
  }
}

typedef AuraAtmosphere = AppAtmosphere;
