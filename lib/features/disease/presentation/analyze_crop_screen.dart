import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/crop_batch.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/image_preview.dart';
import '../../../widgets/loading_widget.dart';
import '../controllers/disease_analysis_controller.dart';

class AnalyzeCropScreen extends StatefulWidget {
  const AnalyzeCropScreen({super.key, this.cropId});

  final String? cropId;

  @override
  State<AnalyzeCropScreen> createState() => _AnalyzeCropScreenState();
}

class _AnalyzeCropScreenState extends State<AnalyzeCropScreen> {
  late final DiseaseAnalysisController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).diseaseAnalysisController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.bootstrap(cropId: widget.cropId);
    });
  }

  Future<void> _onConfirm() async {
    final ok = await _controller.confirmAndAnalyze();
    if (!mounted) return;
    if (ok) {
      context.push(AppRoutes.analysisResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Analyze crop',
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.cropsState == LoadState.loading ||
              _controller.cropsState == LoadState.idle) {
            return const LoadingWidget(message: 'Preparing analysis…');
          }
          if (_controller.cropsState == LoadState.error) {
            return AppErrorView(
              message: _controller.errorMessage ?? 'Could not load crops.',
              onRetry: () => _controller.bootstrap(cropId: widget.cropId),
            );
          }
          if (_controller.cropsState == LoadState.empty) {
            return EmptyState(
              title: 'No crop batches',
              message: 'Add a crop batch before running disease analysis.',
              icon: Icons.grass_outlined,
              actionLabel: 'Add crop',
              onAction: () => context.push(AppRoutes.cropNew),
            );
          }

          return switch (_controller.step) {
            AnalysisFlowStep.selectCrop => _SelectCropStep(
              crops: _controller.crops,
              onSelected: _controller.selectCrop,
            ),
            AnalysisFlowStep.selectImage => _SelectImageStep(
              crop: _controller.selectedCrop!,
              errorMessage: _controller.errorMessage,
              onCamera: () async {
                final ok = await _controller.pickFromCamera();
                if (!context.mounted) return;
                if (!ok && _controller.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_controller.errorMessage!)),
                  );
                }
              },
              onGallery: () async {
                final ok = await _controller.pickFromGallery();
                if (!context.mounted) return;
                if (!ok && _controller.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_controller.errorMessage!)),
                  );
                }
              },
              onChangeCrop: () => _controller.bootstrap(),
            ),
            AnalysisFlowStep.preview => _PreviewStep(
              crop: _controller.selectedCrop!,
              imageBytes: _controller.imageBytes,
              isBusy: _controller.isBusy,
              errorMessage: _controller.errorMessage,
              onReplace: _controller.clearImage,
              onConfirm: _onConfirm,
              onBack: _controller.backToImageSelection,
            ),
            AnalysisFlowStep.analyzing => _AnalyzingStep(
              statusMessage: _controller.statusMessage,
            ),
            AnalysisFlowStep.failed => AppErrorView(
              title: 'Analysis failed',
              message: _controller.errorMessage ??
                  'The AI service could not complete analysis.',
              onRetry: _controller.retryAnalysis,
              retryLabel: 'Retry analysis',
            ),
            AnalysisFlowStep.result => ResponsiveContent(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Analysis complete',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'View AI result',
                    onPressed: () => context.push(AppRoutes.analysisResult),
                  ),
                ],
              ),
            ),
          };
        },
      ),
    );
  }
}

class _SelectCropStep extends StatelessWidget {
  const _SelectCropStep({required this.crops, required this.onSelected});

  final List<CropBatch> crops;
  final ValueChanged<CropBatch> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ResponsiveContent(
      child: ListView(
        children: [
          Text('Choose a crop batch', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Analysis results will be linked to the selected batch.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...crops.map(
            (crop) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () => onSelected(crop),
                child: Row(
                  children: [
                    const Icon(Icons.grass_outlined, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(crop.displayTitle, style: theme.textTheme.titleMedium),
                          Text(crop.farmName, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectImageStep extends StatelessWidget {
  const _SelectImageStep({
    required this.crop,
    required this.onCamera,
    required this.onGallery,
    required this.onChangeCrop,
    this.errorMessage,
  });

  final CropBatch crop;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onChangeCrop;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ResponsiveContent(
      child: ListView(
        children: [
          Text('Capture or select a leaf image', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Crop: ${crop.displayTitle}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              children: [
                const Icon(Icons.biotech_outlined, size: 48, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'The image is sent to the CropSure AI service for analysis. '
                  'No disease model runs on this device.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Text(
                errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Use camera',
            icon: Icons.photo_camera_outlined,
            onPressed: onCamera,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Choose from gallery',
            variant: AppButtonVariant.outlined,
            icon: Icons.photo_library_outlined,
            onPressed: onGallery,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Change crop batch',
            variant: AppButtonVariant.text,
            onPressed: onChangeCrop,
          ),
        ],
      ),
    );
  }
}

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({
    required this.crop,
    required this.imageBytes,
    required this.isBusy,
    required this.onReplace,
    required this.onConfirm,
    required this.onBack,
    this.errorMessage,
  });

  final CropBatch crop;
  final Uint8List? imageBytes;
  final bool isBusy;
  final VoidCallback onReplace;
  final VoidCallback onConfirm;
  final VoidCallback onBack;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ResponsiveContent(
      child: ListView(
        children: [
          Text('Confirm leaf image', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            crop.displayTitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ImagePreview(
            imageBytes: imageBytes,
            height: 280,
            onReplace: onReplace,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Start AI analysis',
            icon: Icons.radar,
            isLoading: isBusy,
            onPressed: isBusy ? null : onConfirm,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Back',
            variant: AppButtonVariant.outlined,
            onPressed: isBusy ? null : onBack,
          ),
        ],
      ),
    );
  }
}

class _AnalyzingStep extends StatelessWidget {
  const _AnalyzingStep({this.statusMessage});

  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Analyzing crop health',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            statusMessage ?? 'Contacting the AI service…',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Please wait. This may take a few moments.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
