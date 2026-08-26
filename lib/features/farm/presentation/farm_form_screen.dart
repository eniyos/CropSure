import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../models/farm.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_text_field.dart';
import '../controllers/farm_controller.dart';

class FarmFormScreen extends StatefulWidget {
  const FarmFormScreen({super.key, this.farmId});

  final String? farmId;

  bool get isEditing => farmId != null;

  @override
  State<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends State<FarmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();
  final _notesController = TextEditingController();

  late final FarmController _controller;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _controller = AppScope.read(context).farmController;
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  Future<void> _loadExisting() async {
    await _controller.loadFarm(widget.farmId!);
    final farm = _controller.selected;
    if (farm == null || !mounted) return;
    _nameController.text = farm.name;
    _locationController.text = farm.location;
    _areaController.text = farm.areaHectares.toString();
    _notesController.text = farm.notes ?? '';
    setState(() => _hydrated = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final area = double.tryParse(_areaController.text.trim());
    if (area == null) return;

    final input = FarmInput(
      name: _nameController.text,
      location: _locationController.text,
      areaHectares: area,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text,
    );

    final saved = widget.isEditing
        ? await _controller.updateFarm(widget.farmId!, input)
        : await _controller.createFarm(input);

    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.successMessage ?? 'Farm saved.')),
      );
      context.go(AppRoutes.farmDetailsPath(saved.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: widget.isEditing ? 'Edit farm' : 'Add farm',
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (widget.isEditing && !_hydrated) {
            return const Center(child: CircularProgressIndicator());
          }

          return ResponsiveContent(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(
                    widget.isEditing
                        ? 'Update farm details'
                        : 'Register a new farm',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Location and area help CropSure organize crop batches.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_controller.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Text(
                        _controller.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _nameController,
                    label: 'Farm name',
                    prefixIcon: Icons.agriculture_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.requiredField(v, fieldName: 'Farm name'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'Village / district / state',
                    prefixIcon: Icons.place_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.requiredField(v, fieldName: 'Location'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _areaController,
                    label: 'Area (hectares)',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.square_foot_outlined,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Area is required';
                      }
                      final parsed = double.tryParse(value.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid area greater than zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _notesController,
                    label: 'Notes (optional)',
                    prefixIcon: Icons.notes_outlined,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: widget.isEditing ? 'Save changes' : 'Create farm',
                    isLoading: _controller.isSaving,
                    onPressed: _controller.isSaving ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
