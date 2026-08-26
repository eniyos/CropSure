import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../models/disease_analysis.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/image_preview.dart';
import '../../../../widgets/section_header.dart';

/// Side-by-side original image vs AI-provided Grad-CAM visualization.
///
/// The heatmap is supplied conceptually by the AI service. In mock mode we
/// render a placeholder attention overlay — not a local Grad-CAM algorithm.
class GradCamComparisonView extends StatelessWidget {
  const GradCamComparisonView({
    super.key,
    required this.originalBytes,
    required this.gradCam,
    this.showOverlay = true,
  });

  final Uint8List? originalBytes;
  final GradCamResult gradCam;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Grad-CAM visualization',
          subtitle: 'Original leaf vs AI attention heatmap',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 560;
            final panels = [
              Expanded(
                child: _LabeledPanel(
                  label: 'Original image',
                  child: ImagePreview(
                    imageBytes: originalBytes,
                    height: 220,
                    emptyLabel: 'Original image unavailable',
                  ),
                ),
              ),
              SizedBox(
                width: stacked ? 0 : AppSpacing.md,
                height: stacked ? AppSpacing.md : 0,
              ),
              Expanded(
                child: _LabeledPanel(
                  label: 'AI heatmap',
                  child: _HeatmapPanel(
                    originalBytes: originalBytes,
                    showOverlay: showOverlay,
                    opacity: gradCam.overlayOpacity,
                  ),
                ),
              ),
            ];

            return stacked
                ? Column(children: panels)
                : Row(crossAxisAlignment: CrossAxisAlignment.start, children: panels);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Areas of attention', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              ...gradCam.attentionAreas.map(
                (area) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.my_location,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(child: Text(area, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                gradCam.explanation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Heatmap provided by the AI service — not generated on device.',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabeledPanel extends StatelessWidget {
  const _LabeledPanel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _HeatmapPanel extends StatelessWidget {
  const _HeatmapPanel({
    required this.originalBytes,
    required this.showOverlay,
    required this.opacity,
  });

  final Uint8List? originalBytes;
  final bool showOverlay;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (originalBytes != null)
              Image.memory(originalBytes!, fit: BoxFit.cover)
            else
              const ColoredBox(color: AppColors.surfaceMuted),
            if (showOverlay)
              CustomPaint(
                painter: _MockHeatmapPainter(opacity: opacity),
              ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  'AI service heatmap',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative mock heatmap representing backend Grad-CAM output in UI demos.
class _MockHeatmapPainter extends CustomPainter {
  _MockHeatmapPainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final centers = [
      Offset(size.width * 0.35, size.height * 0.55),
      Offset(size.width * 0.62, size.height * 0.38),
      Offset(size.width * 0.48, size.height * 0.72),
    ];
    final radii = [size.shortestSide * 0.34, size.shortestSide * 0.28, size.shortestSide * 0.22];
    final colors = [
      const Color(0xE6B42318),
      const Color(0xCCB7791F),
      const Color(0x992E7D4F),
    ];

    for (var i = 0; i < centers.length; i++) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            colors[i].withValues(alpha: opacity),
            colors[i].withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: centers[i], radius: radii[i]));
      canvas.drawCircle(centers[i], radii[i], paint);
    }

    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawArc(
      Rect.fromCenter(
        center: centers.first,
        width: radii.first,
        height: radii.first,
      ),
      -math.pi / 2,
      math.pi,
      false,
      sweep,
    );
  }

  @override
  bool shouldRepaint(covariant _MockHeatmapPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
