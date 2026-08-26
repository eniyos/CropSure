enum NotificationType {
  diseaseAlert,
  treatmentReminder,
  trustUpdate,
  weatherAlert,
  marketInfo,
  passportEvent,
  general;

  String get displayName => switch (this) {
    NotificationType.diseaseAlert => 'Disease alert',
    NotificationType.treatmentReminder => 'Treatment reminder',
    NotificationType.trustUpdate => 'Trust score update',
    NotificationType.weatherAlert => 'Weather alert',
    NotificationType.marketInfo => 'Market information',
    NotificationType.passportEvent => 'Passport / verification',
    NotificationType.general => 'General',
  };

  static NotificationType fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'disease_alert':
      case 'diseasealert':
        return NotificationType.diseaseAlert;
      case 'treatment_reminder':
      case 'treatmentreminder':
        return NotificationType.treatmentReminder;
      case 'trust_update':
      case 'trustupdate':
        return NotificationType.trustUpdate;
      case 'weather_alert':
      case 'weatheralert':
        return NotificationType.weatherAlert;
      case 'market_information':
      case 'market_info':
      case 'marketinfo':
        return NotificationType.marketInfo;
      case 'passport_verification':
      case 'passport_event':
      case 'passportevent':
        return NotificationType.passportEvent;
      default:
        return NotificationType.general;
    }
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.details,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? details;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      details: details,
    );
  }
}
