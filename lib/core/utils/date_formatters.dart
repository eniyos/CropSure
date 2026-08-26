import 'package:intl/intl.dart';

/// Shared date formatting helpers for farmer-facing UI.
abstract final class DateFormatters {
  static final DateFormat display = DateFormat('dd MMM yyyy');
  static final DateFormat displayWithTime = DateFormat('dd MMM yyyy · HH:mm');
  static final DateFormat short = DateFormat('dd MMM');

  static String format(DateTime? value) {
    if (value == null) return '—';
    return display.format(value);
  }

  static String formatWithTime(DateTime? value) {
    if (value == null) return '—';
    return displayWithTime.format(value);
  }
}
