import 'package:intl/intl.dart';

// Enum for reusable format types
enum DateFormatType {
  iso, // yyyy-MM-dd
  longDay, // EEEE, MMMM d
  timeOnly, // h:mm a
  fullLong, // EEEE, MMMM d, yyyy
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

DateTime parseDate(String input, DateFormatType type) {
  final pattern = dateFormatPatterns[type]!;
  return DateFormat(pattern).parse(input);
}

DateTime _combineDateAndTime(DateTime date, String timeString) {
  final timeParts = timeString.split(' ');
  final hourMinute = timeParts[0].split(':');
  int hour = int.parse(hourMinute[0]);
  final int minute = int.parse(hourMinute[1]);

  if (timeParts[1] == 'PM' && hour != 12) hour += 12;
  if (timeParts[1] == 'AM' && hour == 12) hour = 0;

  return DateTime(date.year, date.month, date.day, hour, minute);
}

bool isPastSlot(DateTime date, String time) {
  final slotDateTime = _combineDateAndTime(date, time);
  return slotDateTime.isBefore(DateTime.now());
}

bool isPastDay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final selected = DateTime(date.year, date.month, date.day);

  return selected.isBefore(today);
}
