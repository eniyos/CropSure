import 'package:flutter/material.dart';

import '../core/theme/agri_assets.dart';
import '../core/theme/app_colors.dart';

/// Resolves agri photos from bundled assets or remote URLs.
///
/// Empty paths skip network/asset loads and show a themed placeholder
/// (avoids Unsplash 404 console noise).
class AgriNetworkImage extends StatelessWidget {
  const AgriNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.semanticLabel,
    this.borderRadius,
    this.placeholderColor,
    this.cacheWidth,
    this.cacheHeight,
  });

  final String url;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final double? width;
  final double? height;
  final String? semanticLabel;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            placeholderColor ?? AppColors.green50,
            AppColors.leaf.withValues(alpha: 0.35),
            AppColors.leafDeep.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.agriculture_rounded,
          color: AppColors.white,
          size: 28,
        ),
      ),
    );

    if (!AgriAssets.hasImage(url)) {
      return _wrap(fallback);
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final resolvedCacheWidth = cacheWidth ??
        (width != null && width!.isFinite ? (width! * dpr).round() : null);
    final resolvedCacheHeight = cacheHeight ??
        (height != null && height!.isFinite ? (height! * dpr).round() : null);

    final Widget image;
    if (AgriAssets.isAssetPath(url)) {
      image = Image.asset(
        url,
        fit: fit,
        alignment: alignment,
        width: width,
        height: height,
        cacheWidth: resolvedCacheWidth,
        cacheHeight: resolvedCacheHeight,
        filterQuality: FilterQuality.medium,
        semanticLabel: semanticLabel,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    } else {
      image = Image.network(
        url,
        fit: fit,
        alignment: alignment,
        width: width,
        height: height,
        cacheWidth: resolvedCacheWidth,
        cacheHeight: resolvedCacheHeight,
        filterQuality: FilterQuality.medium,
        semanticLabel: semanticLabel,
        errorBuilder: (context, error, stackTrace) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ColoredBox(
            color: placeholderColor ?? AppColors.surfaceMuted,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      );
    }

    return _wrap(image);
  }

  Widget _wrap(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
