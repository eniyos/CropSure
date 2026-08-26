/// Five-level disease severity model. Values come from the AI/backend service.
enum DiseaseSeverityLevel {
  healthy,
  mild,
  moderate,
  severe,
  critical;

  String get displayName => switch (this) {
    DiseaseSeverityLevel.healthy => 'Healthy',
    DiseaseSeverityLevel.mild => 'Mild',
    DiseaseSeverityLevel.moderate => 'Moderate',
    DiseaseSeverityLevel.severe => 'Severe',
    DiseaseSeverityLevel.critical => 'Critical',
  };

  int get levelIndex => index + 1;

  String get explanation => switch (this) {
    DiseaseSeverityLevel.healthy =>
      'No disease indicators were detected on the submitted leaf sample.',
    DiseaseSeverityLevel.mild =>
      'Early or limited symptoms. Continue monitoring and follow advisory care.',
    DiseaseSeverityLevel.moderate =>
      'Clear disease presence. Treatment planning is recommended soon.',
    DiseaseSeverityLevel.severe =>
      'Widespread symptoms. Prioritize treatment to limit further spread.',
    DiseaseSeverityLevel.critical =>
      'Severe infection risk. Immediate agronomic intervention is advised.',
  };

  static DiseaseSeverityLevel fromString(String? value) {
    return DiseaseSeverityLevel.values.firstWhere(
      (level) => level.name == value?.toLowerCase().trim(),
      orElse: () => DiseaseSeverityLevel.moderate,
    );
  }
}
