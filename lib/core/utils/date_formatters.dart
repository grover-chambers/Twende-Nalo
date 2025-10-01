import 'package:intl/intl.dart';

class DateFormatters {
  /// Formats date like "July 6, 2025"
  static String formatFullDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  /// Formats date like "06 Jul 2025"
  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM y').format(date);
  }

  /// Formats time like "3:45 PM"
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  /// Formats datetime like "Sun, 6 Jul at 3:45 PM"
  static String formatDayDateTime(DateTime dateTime) {
    return DateFormat('E, d MMM \'at\' h:mm a').format(dateTime);
  }

  /// Formats for trip cards: "Jul 6 - Jul 10, 2025"
  static String formatTripRange(DateTime start, DateTime end) {
    if (start.year == end.year) {
      if (start.month == end.month) {
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('d, y').format(end)}';
      } else {
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, y').format(end)}';
      }
    } else {
      return '${DateFormat('MMM d, y').format(start)} - ${DateFormat('MMM d, y').format(end)}';
    }
  }

  /// ISO 8601 format: 2025-07-06T14:00:00Z (for API use)
  static String toIsoString(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }
}
