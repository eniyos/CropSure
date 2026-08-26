import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/routing/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/breakpoints.dart';
import 'brand_mark.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.leading,
    this.centerTitle = false,
    this.padding,
    this.resizeToAvoidBottomInset = true,
    this.showBrandInTitle = false,
    this.showBackButton = true,
    this.backFallbackLocation = AppRoutes.dashboard,
  });

  final String? title;
  final Widget? body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? leading;
  final bool centerTitle;
  final EdgeInsetsGeometry? padding;
  final bool resizeToAvoidBottomInset;
  final bool showBrandInTitle;

  /// When true (default), shows a back control in the app bar.
  /// Set false on the Home dashboard.
  final bool showBackButton;

  /// Used when there is nothing to pop (e.g. shell tab roots).
  final String backFallbackLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedLeading = leading ??
        (showBackButton
            ? IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => _handleBack(context),
              )
            : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: title == null
          ? null
          : AppBar(
              title: showBrandInTitle
                  ? Row(
                      children: [
                        const BrandMark(size: 32),
                        const SizedBox(width: AppSpacing.sm),
                        Text(title!, style: theme.textTheme.titleLarge),
                      ],
                    )
                  : Text(title!),
              actions: actions,
              leading: resolvedLeading,
              automaticallyImplyLeading: false,
              centerTitle: centerTitle,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: AppSpacing.glassBlur,
                    sigmaY: AppSpacing.glassBlur,
                  ),
                  child: Container(
                    color: AppColors.white.withValues(alpha: 0.82),
                  ),
                ),
              ),
            ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: padding == null
            ? (body ?? const SizedBox.shrink())
            : Padding(padding: padding!, child: body),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(backFallbackLocation);
  }
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.expandHeight = true,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool expandHeight;

  @override
  Widget build(BuildContext context) {
    final resolvedMaxWidth = maxWidth ?? Breakpoints.contentMaxWidth(context);
    final resolvedPadding = padding ?? Breakpoints.pagePadding(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight =
            expandHeight && constraints.hasBoundedHeight;
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth.clamp(0, resolvedMaxWidth).toDouble()
            : resolvedMaxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: width,
              maxWidth: resolvedMaxWidth,
              minHeight: hasBoundedHeight ? constraints.maxHeight : 0,
              maxHeight: hasBoundedHeight
                  ? constraints.maxHeight
                  : double.infinity,
            ),
            child: Padding(padding: resolvedPadding, child: child),
          ),
        );
      },
    );
  }
}
