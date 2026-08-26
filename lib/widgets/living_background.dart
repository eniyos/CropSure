import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/agri_assets.dart';
import '../core/theme/app_colors.dart';
import 'agri_network_image.dart';

enum LivingBackgroundVariant { light, dark }

enum AgriScene { dawnField, greenCanopy, mistMorning, none }

/// Immersive agricultural backdrop with breathe scale + floating collage depth.
class LivingBackground extends StatefulWidget {
  const LivingBackground({
    super.key,
    required this.child,
    this.variant = LivingBackgroundVariant.light,
    this.showFieldPhoto = false,
    this.scene = AgriScene.dawnField,
    this.scrimStrength = 0.55,
  });

  final Widget child;
  final LivingBackgroundVariant variant;
  final bool showFieldPhoto;
  final AgriScene scene;
  final double scrimStrength;

  static String urlFor(AgriScene scene) => switch (scene) {
        AgriScene.dawnField => AgriAssets.dawnField,
        AgriScene.greenCanopy => AgriAssets.greenCanopy,
        AgriScene.mistMorning => AgriAssets.mistMorning,
        AgriScene.none => AgriAssets.dawnField,
      };

  @override
  State<LivingBackground> createState() => _LivingBackgroundState();
}

class _LivingBackgroundState extends State<LivingBackground>
    with TickerProviderStateMixin {
  late final AnimationController _breathe;
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    );
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncMotion(MediaQuery.disableAnimationsOf(context));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // Defer so we never markNeedsBuild / start tickers during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncMotion(reduceMotion);
    });
  }

  void _syncMotion(bool reduceMotion) {
    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgetsFlutterBinding');
    if (reduceMotion || isTest) {
      _breathe.stop();
      _drift.stop();
      _breathe.value = 0;
      _drift.value = 0;
      return;
    }
    if (!_breathe.isAnimating) {
      _breathe.repeat(reverse: true);
    }
    if (!_drift.isAnimating) {
      _drift.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breathe.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.variant == LivingBackgroundVariant.dark;
    final path = LivingBackground.urlFor(widget.scene);
    final showPhoto = widget.showFieldPhoto &&
        widget.scene != AgriScene.none &&
        AgriAssets.hasImage(path);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    Widget photoLayer() {
      final cacheW = (size.width * dpr).round().clamp(320, 1600);
      final cacheH = (size.height * dpr).round().clamp(320, 1600);

      Widget buildImage({required Alignment alignment}) {
        return AgriNetworkImage(
          url: path,
          fit: BoxFit.cover,
          alignment: alignment,
          cacheWidth: cacheW,
          cacheHeight: cacheH,
          semanticLabel: 'Agricultural field background',
          placeholderColor: dark ? AppColors.leafDeep : AppColors.green50,
        );
      }

      if (reduceMotion) {
        return buildImage(alignment: Alignment.center);
      }

      return AnimatedBuilder(
        animation: _breathe,
        builder: (context, _) {
          final scale = 1.0 + (_breathe.value * 0.07);
          return Transform.scale(
            scale: scale,
            child: buildImage(
              alignment: Alignment(-0.05 + _breathe.value * 0.08, 0),
            ),
          );
        },
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? const [
                      Color(0xFF0A2E1A),
                      AppColors.leafDeep,
                      Color(0xFF071A10),
                    ]
                  : const [
                      Color(0xFFF7FAF5),
                      AppColors.skyMist,
                      Color(0xFFE8F0E6),
                    ],
            ),
          ),
        ),
        if (showPhoto) RepaintBoundary(child: photoLayer()),
        if (showPhoto || dark)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [
                        AppColors.leafDeep.withValues(
                          alpha: showPhoto
                              ? 0.42 + widget.scrimStrength * 0.22
                              : 0.15,
                        ),
                        Colors.black.withValues(
                          alpha: showPhoto
                              ? 0.28 + widget.scrimStrength * 0.28
                              : 0.08,
                        ),
                        AppColors.ink.withValues(
                          alpha: showPhoto ? 0.68 : 0.2,
                        ),
                      ]
                    : [
                        AppColors.skyMist.withValues(
                          alpha: showPhoto ? 0.55 : 0.15,
                        ),
                        AppColors.skyMist.withValues(
                          alpha: showPhoto ? 0.72 : 0.25,
                        ),
                        AppColors.skyMist.withValues(
                          alpha: showPhoto ? 0.9 : 0.4,
                        ),
                      ],
              ),
            ),
          ),
        // Soft bottom vignette for readable auth copy.
        if (dark)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x66000000),
                ],
                stops: [0.45, 1],
              ),
            ),
          ),
        if (!reduceMotion)
          AnimatedBuilder(
            animation: Listenable.merge([_breathe, _drift]),
            builder: (context, _) {
              return CustomPaint(
                painter: _AtmospherePainter(
                  breathe: _breathe.value,
                  drift: _drift.value,
                  dark: dark,
                  muted: showPhoto,
                ),
                child: const SizedBox.expand(),
              );
            },
          )
        else
          CustomPaint(
            painter: _AtmospherePainter(
              breathe: 0,
              drift: 0,
              dark: dark,
              muted: showPhoto,
            ),
            child: const SizedBox.expand(),
          ),
        if (!dark && !showPhoto)
          IgnorePointer(
            child: reduceMotion
                ? Stack(
                    children: [
                      for (var i = 0; i < AgriAssets.collage.length; i++)
                        _CollageTile(
                          size: size,
                          index: i,
                          drift: 0,
                          url: AgriAssets.collage[i],
                        ),
                    ],
                  )
                : AnimatedBuilder(
                    animation: _drift,
                    builder: (context, _) {
                      final d = _drift.value;
                      return Stack(
                        children: [
                          for (var i = 0; i < AgriAssets.collage.length; i++)
                            _CollageTile(
                              size: size,
                              index: i,
                              drift: d,
                              url: AgriAssets.collage[i],
                            ),
                        ],
                      );
                    },
                  ),
          ),
        widget.child,
      ],
    );
  }
}

class _CollageTile extends StatelessWidget {
  const _CollageTile({
    required this.size,
    required this.index,
    required this.drift,
    required this.url,
  });

  final Size size;
  final int index;
  final double drift;
  final String url;

  @override
  Widget build(BuildContext context) {
    final corners = <(double, double, double, double)>[
      (0.04, 0.12 + drift * 0.02, 0.2, 0.13),
      (0.76 - drift * 0.02, 0.1, 0.18, 0.12),
      (0.06 + drift * 0.01, 0.72, 0.17, 0.12),
      (0.78, 0.68 - drift * 0.02, 0.16, 0.14),
    ];
    final (l, t, w, h) = corners[index % corners.length];
    final angles = [-0.07, 0.09, 0.05, -0.06];
    final provider = AgriAssets.imageProviderOrNull(url);
    final softFills = [
      AppColors.green50,
      AppColors.leaf.withValues(alpha: 0.35),
      AppColors.harvest.withValues(alpha: 0.28),
      AppColors.leafBright.withValues(alpha: 0.3),
    ];

    return Positioned(
      left: size.width * l,
      top: size.height * t,
      child: Transform.rotate(
        angle: angles[index % angles.length] + drift * 0.03 * (index.isEven ? 1 : -1),
        child: Opacity(
          opacity: 0.55,
          child: Container(
            width: size.width * w,
            height: size.height * h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
              color: provider == null ? softFills[index % softFills.length] : null,
              image: provider == null
                  ? null
                  : DecorationImage(
                      image: provider,
                      fit: BoxFit.cover,
                      opacity: 0.9,
                    ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  _AtmospherePainter({
    required this.breathe,
    required this.drift,
    required this.dark,
    required this.muted,
  });

  final double breathe;
  final double drift;
  final bool dark;
  final bool muted;

  @override
  void paint(Canvas canvas, Size size) {
    final amp = muted ? 0.5 : 1.0;

    void orb(Offset c, double r, Color color) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: r));
      canvas.drawCircle(c, r, paint);
    }

    orb(
      Offset(
        size.width * (0.8 + drift * 0.04),
        size.height * (0.16 - breathe * 0.05),
      ),
      size.shortestSide * (0.52 + breathe * 0.05),
      AppColors.leaf.withValues(alpha: (dark ? 0.32 : 0.14) * amp),
    );
    orb(
      Offset(
        size.width * (0.16 - drift * 0.04),
        size.height * (0.75 + breathe * 0.03),
      ),
      size.shortestSide * 0.48,
      AppColors.harvest.withValues(alpha: (dark ? 0.2 : 0.11) * amp),
    );
    orb(
      Offset(
        size.width * (0.52 + math.sin(drift * math.pi) * 0.07),
        size.height * (0.42 + math.cos(breathe * math.pi) * 0.05),
      ),
      size.shortestSide * 0.4,
      AppColors.leafBright.withValues(alpha: (dark ? 0.16 : 0.1) * amp),
    );
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) {
    return oldDelegate.breathe != breathe ||
        oldDelegate.drift != drift ||
        oldDelegate.dark != dark ||
        oldDelegate.muted != muted;
  }
}
