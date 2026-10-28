import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/agri_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/load_state.dart';
import '../../../models/crop_passport.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_error_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/agri_network_image.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/scroll_reveal.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/passport_controller.dart';

StatusBadgeTone _statusTone(PassportVerificationStatus status) => switch (status) {
      PassportVerificationStatus.verified => StatusBadgeTone.success,
      PassportVerificationStatus.pending => StatusBadgeTone.warning,
      PassportVerificationStatus.rejected => StatusBadgeTone.error,
      PassportVerificationStatus.expired => StatusBadgeTone.error,
      PassportVerificationStatus.draft => StatusBadgeTone.neutral,
    };

class PassportListScreen extends StatefulWidget {
  const PassportListScreen({super.key, this.cropBatchId});

  final String? cropBatchId;

  @override
  State<PassportListScreen> createState() => _PassportListScreenState();
}

class _PassportListScreenState extends State<PassportListScreen> {
  late final PassportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).passportController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.cropBatchId != null) {
        context.go(AppRoutes.passportForCropPath(widget.cropBatchId!));
        return;
      }
      _controller.loadList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Passports',
      actions: [
        IconButton(
          tooltip: 'Verify QR code',
          onPressed: () => context.push(AppRoutes.passportVerify),
          icon: const Icon(Icons.qr_code_scanner_rounded),
        ),
      ],
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.listState) {
            case LoadState.loading:
            case LoadState.idle:
              return const LoadingWidget(message: 'Loading passports…');
            case LoadState.error:
              return AppErrorView(
                message:
                    _controller.errorMessage ?? 'Could not load passports.',
                onRetry: () => _controller.loadList(),
              );
            case LoadState.empty:
              return EmptyState(
                title: 'No passports yet',
                message:
                    'Open a crop batch and create its digital passport trail.',
                icon: Icons.badge_outlined,
                actionLabel: 'Browse crops',
                onAction: () => context.go(AppRoutes.crops),
              );
            case LoadState.success:
              return RefreshIndicator(
                onRefresh: () => _controller.loadList(),
                child: ResponsiveContent(
                  maxWidth: 720,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: _controller.passports.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const ScrollReveal(child: _PassportHero());
                      }
                      final passport = _controller.passports[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: ScrollReveal(
                          delay: Duration(milliseconds: 50 * (index - 1)),
                          child: _PassportTile(passport: passport),
                        ),
                      );
                    },
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class _PassportHero extends StatelessWidget {
  const _PassportHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: SizedBox(
          height: 168,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AgriNetworkImage(
                url: AgriAssets.mistMorning,
                fit: BoxFit.cover,
                placeholderColor: AppColors.leafDeep,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      AppColors.leafDeep.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROVENANCE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.harvest,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Digital crop passports',
                      style: AppTypography.display(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Timeline, verification status, and shareable QR',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PassportTile extends StatelessWidget {
  const _PassportTile({required this.passport});

  final CropPassport passport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      glass: true,
      onTap: () =>
          context.push(AppRoutes.passportDetailsPath(passport.id)),
      semanticLabel: 'Passport ${passport.cropLabel}',
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.badge_outlined, color: AppColors.leaf),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passport.cropLabel,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  passport.farmName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Updated ${DateFormatters.format(passport.updatedAt)}'
                  '${passport.trustScore != null ? ' · Trust ${passport.trustScore!.toStringAsFixed(0)}' : ''}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: passport.status.displayName,
            tone: _statusTone(passport.status),
          ),
        ],
      ),
    );
  }
}
