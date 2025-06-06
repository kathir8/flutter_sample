import 'package:intl/intl.dart';

// Enum for reusable format types
enum DateFormatType {
  iso,        // yyyy-MM-dd
  longDay,    // EEEE, MMMM d
  timeOnly,   // h:mm a
  fullLong,   // EEEE, MMMM d, yyyy
}

// Map format types to actual pattern strings
const Map<DateFormatType, String> dateFormatPatterns = {
  DateFormatType.iso: 'yyyy-MM-dd',
  DateFormatType.longDay: 'EEEE, MMMM d',
  DateFormatType.timeOnly: 'h:mm a',
  DateFormatType.fullLong: 'EEEE, MMMM d, yyyy',
};

// Common function to format a date
String formatDate(DateTime date, DateFormatType type) {
  final pattern = dateFormatPatterns[type]!;
  return DateFormat(pattern).format(date);
}
