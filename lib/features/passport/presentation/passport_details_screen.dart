import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/agri_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/crop_passport.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/agri_network_image.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/scroll_reveal.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/passport_controller.dart';

StatusBadgeTone _tone(PassportVerificationStatus status) => switch (status) {
      PassportVerificationStatus.verified => StatusBadgeTone.success,
      PassportVerificationStatus.pending => StatusBadgeTone.warning,
      PassportVerificationStatus.rejected => StatusBadgeTone.error,
      PassportVerificationStatus.expired => StatusBadgeTone.error,
      PassportVerificationStatus.draft => StatusBadgeTone.neutral,
    };

IconData _eventIcon(PassportEventType type) => switch (type) {
      PassportEventType.created => Icons.badge_outlined,
      PassportEventType.planted => Icons.agriculture_outlined,
      PassportEventType.diseaseAnalysis => Icons.biotech_outlined,
      PassportEventType.treatmentApplied => Icons.medical_services_outlined,
      PassportEventType.trustUpdated => Icons.verified_outlined,
      PassportEventType.qrIssued => Icons.qr_code_2_rounded,
      PassportEventType.verified => Icons.verified_user_outlined,
      PassportEventType.shared => Icons.ios_share_rounded,
    };

class PassportDetailsScreen extends StatefulWidget {
  const PassportDetailsScreen({
    super.key,
    this.passportId,
    this.cropBatchId,
  });

  final String? passportId;
  final String? cropBatchId;

  @override
  State<PassportDetailsScreen> createState() => _PassportDetailsScreenState();
}

class _PassportDetailsScreenState extends State<PassportDetailsScreen> {
  late final PassportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).passportController;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (widget.passportId != null) {
      await _controller.loadDetail(widget.passportId!);
    } else if (widget.cropBatchId != null) {
      await _controller.loadForCrop(widget.cropBatchId!);
    }
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code copied.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Crop passport',
      actions: [
        IconButton(
          tooltip: 'Verify a code',
          onPressed: () => context.push(AppRoutes.passportVerify),
          icon: const Icon(Icons.qr_code_scanner_rounded),
        ),
      ],
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.detailState) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(message: 'Opening passport…');
            case LoadState.error:
            case LoadState.empty:
              return AppErrorView(
                message: _controller.errorMessage ?? 'Passport not found.',
                onRetry: _load,
              );
            case LoadState.success:
              final detail = _controller.detail!;
              final passport = detail.passport;
              return RefreshIndicator(
                onRefresh: _load,
                child: ResponsiveContent(
                  maxWidth: 720,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      ScrollReveal(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXl),
                          child: SizedBox(
                            height: 200,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                AgriNetworkImage(
                                  url: AgriAssets.dawnField,
                                  fit: BoxFit.cover,
                                  placeholderColor: AppColors.leafDeep,
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.12),
                                        AppColors.leafDeep
                                            .withValues(alpha: 0.92),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: StatusBadge(
                                          label: passport.status.displayName,
                                          tone: _tone(passport.status),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        passport.cropLabel,
                                        style: AppTypography.display(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        passport.farmName,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: AppColors.white
                                              .withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 60),
                        child: AppCard(
                          glass: true,
                          child: Column(
                            children: [
                              _Row(
                                label: 'Passport ID',
                                value: passport.id,
                              ),
                              const Divider(height: AppSpacing.lg),
                              _Row(
                                label: 'Issued',
                                value: DateFormatters.format(passport.issuedAt),
                              ),
                              const Divider(height: AppSpacing.lg),
                              _Row(
                                label: 'Updated',
                                value:
                                    DateFormatters.format(passport.updatedAt),
                              ),
                              if (passport.trustScore != null) ...[
                                const Divider(height: AppSpacing.lg),
                                _Row(
                                  label: 'Trust score',
                                  value: passport.trustScore!
                                      .toStringAsFixed(0),
                                ),
                              ],
                              if (passport.verifierName != null) ...[
                                const Divider(height: AppSpacing.lg),
                                _Row(
                                  label: 'Verifier',
                                  value: passport.verifierName!,
                                ),
                              ],
                              if (passport.expiresAt != null) ...[
                                const Divider(height: AppSpacing.lg),
                                _Row(
                                  label: 'Expires',
                                  value: DateFormatters.format(
                                    passport.expiresAt,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (passport.summary != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        ScrollReveal(
                          delay: const Duration(milliseconds: 90),
                          child: AppCard(
                            glass: true,
                            child: Text(
                              passport.summary!,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 110),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SectionHeader(
                              eyebrow: 'QR',
                              title: 'Share & verify',
                              subtitle:
                                  'Scan or enter the code to validate provenance',
                            ),
                            AppCard(
                              glass: true,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: AppColors.neutral200,
                                      ),
                                    ),
                                    child: QrImageView(
                                      data: passport.qrPayload,
                                      size: 180,
                                      backgroundColor: AppColors.white,
                                      eyeStyle: const QrEyeStyle(
                                        eyeShape: QrEyeShape.square,
                                        color: AppColors.leafDeep,
                                      ),
                                      dataModuleStyle: const QrDataModuleStyle(
                                        dataModuleShape:
                                            QrDataModuleShape.square,
                                        color: AppColors.leaf,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    passport.verificationCode ?? '—',
                                    style: AppTypography.display(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  AppButton(
                                    label: 'Copy verification code',
                                    variant: AppButtonVariant.outlined,
                                    icon: Icons.copy_rounded,
                                    onPressed: passport.verificationCode == null
                                        ? null
                                        : () => _copyCode(
                                              passport.verificationCode!,
                                            ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  AppButton(
                                    label: 'Open verifier',
                                    icon: Icons.qr_code_scanner_rounded,
                                    onPressed: () => context.push(
                                      AppRoutes.passportVerifyPath(
                                        code: passport.verificationCode,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              eyebrow: 'Trail',
                              title: 'Passport timeline',
                            ),
                            ...detail.timeline.map(
                              (event) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: _TimelineTile(event: event),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Open crop batch',
                        variant: AppButtonVariant.outlined,
                        icon: Icons.grass_outlined,
                        onPressed: () => context.push(
                          AppRoutes.cropDetailsPath(passport.cropBatchId),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event});

  final PassportTimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      glass: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_eventIcon(event.type), color: AppColors.leaf, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: theme.textTheme.titleSmall),
                if (event.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  DateFormatters.formatWithTime(event.occurredAt),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
