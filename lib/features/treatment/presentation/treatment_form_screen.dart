import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../models/crop_batch.dart';
import '../../../models/treatment.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_text_field.dart';
import '../../crop/controllers/crop_controller.dart';
import '../controllers/treatment_controller.dart';

class TreatmentFormScreen extends StatefulWidget {
  const TreatmentFormScreen({
    super.key,
    this.treatmentId,
    this.initialCropId,
  });

  final String? treatmentId;
  final String? initialCropId;

  bool get isEditing => treatmentId != null;

  @override
  State<TreatmentFormScreen> createState() => _TreatmentFormScreenState();
}

class _TreatmentFormScreenState extends State<TreatmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  late final TreatmentController _treatmentController;
  late final CropController _cropController;

  String? _cropId;
  DateTime _date = DateTime.now();
  TreatmentStatus _status = TreatmentStatus.planned;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final deps = AppScope.read(context);
    _treatmentController = deps.treatmentController;
    _cropController = deps.cropController;
    _cropId = widget.initialCropId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await _cropController.loadCrops();
    if (!mounted) return;

    if (widget.isEditing) {
      await _treatmentController.loadTreatment(widget.treatmentId!);
      final item = _treatmentController.selected;
      if (item != null && mounted) {
        _nameController.text = item.name;
        _notesController.text = item.notes ?? '';
        _cropId = item.cropBatchId;
        _date = item.date;
        _status = item.status;
      }
    } else {
      _cropId ??= _cropController.crops.isNotEmpty
          ? _cropController.crops.first.id
          : null;
    }
    setState(() => _ready = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_cropId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a crop batch first.')),
      );
      return;
    }

    final input = TreatmentInput(
      name: _nameController.text,
      date: _date,
      status: _status,
      cropBatchId: _cropId!,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text,
    );

    final saved = widget.isEditing
        ? await _treatmentController.updateTreatment(widget.treatmentId!, input)
        : await _treatmentController.createTreatment(input);

    if (!mounted) return;
    if (saved != null) {
      // Refresh trust after treatment changes (backend would recompute).
      await AppScope.read(context).trustController.load(
        cropBatchId: saved.cropBatchId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _treatmentController.successMessage ?? 'Treatment saved.',
          ),
        ),
      );
      context.go(AppRoutes.treatmentDetailsPath(saved.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: widget.isEditing ? 'Edit treatment' : 'Add treatment',
      body: ListenableBuilder(
        listenable: Listenable.merge([_treatmentController, _cropController]),
        builder: (context, _) {
          if (!_ready) {
            return const Center(child: CircularProgressIndicator());
          }

          final crops = _cropController.crops;
          if (crops.isEmpty) {
            return ResponsiveContent(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Add a crop first', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Treatments must be linked to a crop batch.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Add crop',
                      onPressed: () => context.push(AppRoutes.cropNew),
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
                        ? 'Update treatment record'
                        : 'Log a new treatment',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Saving updates local records and refreshes trust data from the mock Trust Engine.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_treatmentController.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Text(
                        _treatmentController.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _cropId,
                    decoration: const InputDecoration(
                      labelText: 'Crop batch',
                      prefixIcon: Icon(Icons.grass_outlined),
                    ),
                    items: [
                      for (final CropBatch crop in crops)
                        DropdownMenuItem(
                          value: crop.id,
                          child: Text(crop.displayTitle),
                        ),
                    ],
                    onChanged: (value) => setState(() => _cropId = value),
                    validator: (value) =>
                        value == null ? 'Select a crop batch' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _nameController,
                    label: 'Treatment name',
                    prefixIcon: Icons.medical_services_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.requiredField(
                      v,
                      fieldName: 'Treatment name',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(DateFormatters.format(_date)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<TreatmentStatus>(
                    // ignore: deprecated_member_use
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: [
                      for (final status in TreatmentStatus.values)
                        DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _status = value);
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
                    label: widget.isEditing ? 'Save changes' : 'Save treatment',
                    isLoading: _treatmentController.isSaving,
                    onPressed:
                        _treatmentController.isSaving ? null : _submit,
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
