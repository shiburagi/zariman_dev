import 'package:intl/intl.dart';

extension StringDateParsing on String? {
  DateTime toDateTime() {
    if (this == null) return DateTime.now();
    return DateTime.parse(this ?? "");
  }
}

extension DateStringParsing on DateTime {
  String toMonthYearText() {
    final format = DateFormat.MMM().add_y();
    return format.format(this);
  }

  String toYearText() {
    final format = DateFormat.y();
    return format.format(this);
  }
}
