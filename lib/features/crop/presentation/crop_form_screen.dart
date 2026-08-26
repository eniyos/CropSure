import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../models/crop_batch.dart';
import '../../../models/farm.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_text_field.dart';
import '../../farm/controllers/farm_controller.dart';
import '../controllers/crop_controller.dart';

class CropFormScreen extends StatefulWidget {
  const CropFormScreen({super.key, this.cropId, this.initialFarmId});

  final String? cropId;
  final String? initialFarmId;

  bool get isEditing => cropId != null;

  @override
  State<CropFormScreen> createState() => _CropFormScreenState();
}

class _CropFormScreenState extends State<CropFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropTypeController = TextEditingController();
  final _varietyController = TextEditingController();
  final _areaController = TextEditingController();
  final _notesController = TextEditingController();

  late final CropController _cropController;
  late final FarmController _farmController;

  String? _farmId;
  DateTime _plantingDate = DateTime.now();
  GrowthStage _growthStage = GrowthStage.seedling;
  bool _hydrated = false;
  bool _farmsLoaded = false;

  @override
  void initState() {
    super.initState();
    _cropController = AppScope.read(context).cropController;
    _farmController = AppScope.read(context).farmController;
    _farmId = widget.initialFarmId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await _farmController.loadFarms();
    if (!mounted) return;
    setState(() => _farmsLoaded = true);

    if (widget.isEditing) {
      await _cropController.loadCrop(widget.cropId!);
      final crop = _cropController.selected;
      if (crop == null || !mounted) return;
      _cropTypeController.text = crop.cropType;
      _varietyController.text = crop.variety;
      _areaController.text = crop.areaHectares?.toString() ?? '';
      _notesController.text = crop.notes ?? '';
      _farmId = crop.farmId;
      _plantingDate = crop.plantingDate;
      _growthStage = crop.growthStage;
      setState(() => _hydrated = true);
    } else {
      _farmId ??= _farmController.farms.isNotEmpty
          ? _farmController.farms.first.id
          : null;
      setState(() => _hydrated = true);
    }
  }

  @override
  void dispose() {
    _cropTypeController.dispose();
    _varietyController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate,
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _plantingDate = picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_farmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a farm first.')),
      );
      return;
    }

    final areaText = _areaController.text.trim();
    final area = areaText.isEmpty ? null : double.tryParse(areaText);

    final input = CropBatchInput(
      farmId: _farmId!,
      cropType: _cropTypeController.text,
      variety: _varietyController.text,
      plantingDate: _plantingDate,
      growthStage: _growthStage,
      areaHectares: area,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text,
    );

    final saved = widget.isEditing
        ? await _cropController.updateCrop(widget.cropId!, input)
        : await _cropController.createCrop(input);

    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cropController.successMessage ?? 'Crop batch saved.'),
        ),
      );
      context.go(AppRoutes.cropDetailsPath(saved.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: widget.isEditing ? 'Edit crop batch' : 'Add crop batch',
      body: ListenableBuilder(
        listenable: Listenable.merge([_cropController, _farmController]),
        builder: (context, _) {
          if (!_farmsLoaded || !_hydrated) {
            return const Center(child: CircularProgressIndicator());
          }

          final farms = _farmController.farms;
          if (farms.isEmpty) {
            return ResponsiveContent(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add a farm first',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Crop batches must be linked to a farm.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Add farm',
                      onPressed: () => context.push(AppRoutes.farmNew),
                    ),
                  ],
                ),
              ),
            );
          }

          return ResponsiveContent(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(
                    widget.isEditing
                        ? 'Update crop batch'
                        : 'Register a new crop batch',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Link the batch to a farm and set its growth stage.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_cropController.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Text(
                        _cropController.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _farmId,
                    decoration: const InputDecoration(
                      labelText: 'Farm',
                      prefixIcon: Icon(Icons.agriculture_outlined),
                    ),
                    items: [
                      for (final Farm farm in farms)
                        DropdownMenuItem<String>(
                          value: farm.id,
                          child: Text(farm.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _farmId = value),
                    validator: (value) =>
                        value == null ? 'Select a farm' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _cropTypeController,
                    label: 'Crop type',
                    hint: 'e.g. Tomato',
                    prefixIcon: Icons.eco_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.requiredField(v, fieldName: 'Crop type'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _varietyController,
                    label: 'Variety',
                    hint: 'e.g. Hybrid 61',
                    prefixIcon: Icons.category_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.requiredField(v, fieldName: 'Variety'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Planting date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(DateFormatters.format(_plantingDate)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<GrowthStage>(
                    // ignore: deprecated_member_use
                    value: _growthStage,
                    decoration: const InputDecoration(
                      labelText: 'Growth stage',
                      prefixIcon: Icon(Icons.timeline),
                    ),
                    items: GrowthStage.values
                        .map(
                          (stage) => DropdownMenuItem(
                            value: stage,
                            child: Text(stage.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _growthStage = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _areaController,
                    label: 'Area (hectares, optional)',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.square_foot_outlined,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
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
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: widget.isEditing
                        ? 'Save changes'
                        : 'Create crop batch',
                    isLoading: _cropController.isSaving,
                    onPressed: _cropController.isSaving ? null : _submit,
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
