import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/brand_mark.dart';
import '../../../widgets/living_background.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final started = DateTime.now();
    await widget.authController.bootstrap();
    final elapsed = DateTime.now().difference(started);
    final remaining = AppConstants.splashMinDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LivingBackground(
        variant: LivingBackgroundVariant.dark,
        showFieldPhoto: true,
        scene: AgriScene.dawnField,
        scrimStrength: 0.65,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandMark(size: 56),
                    const Spacer(),
                    Text(
                      'CROPSURE',
                      style: AppTypography.display(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.harvest,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'CropSure',
                      style: AppTypography.display(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.05,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trust grown in the field',
                      style: AppTypography.display(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppConstants.appTagline,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.78),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 36),
                    const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: Color(0x33FFFFFF),
                        color: AppColors.harvest,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
