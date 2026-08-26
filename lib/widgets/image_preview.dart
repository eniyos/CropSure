import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'agri_network_image.dart';

/// Image preview used by disease analysis and passport flows.
class ImagePreview extends StatelessWidget {
  const ImagePreview({
    super.key,
    this.imageBytes,
    this.imageUrl,
    this.height = 220,
    this.emptyLabel = 'No image selected',
    this.onReplace,
  });

  final Uint8List? imageBytes;
  final String? imageUrl;
  final double height;
  final String emptyLabel;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (imageBytes != null) {
      image = Image.memory(imageBytes!, fit: BoxFit.cover);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      image = AgriNetworkImage(
        url: imageUrl!,
        height: height,
        fit: BoxFit.cover,
        semanticLabel: 'Selected crop leaf image',
      );
    } else {
      image = _placeholder(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: ColoredBox(
              color: AppColors.surfaceMuted,
              child: image,
            ),
          ),
        ),
        if (onReplace != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onReplace,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Replace image'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _placeholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.image_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            emptyLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
