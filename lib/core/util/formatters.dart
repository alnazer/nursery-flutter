/// تنسيقات خفيفة بلا بيانات لغة إضافية.
String formatTime(DateTime? value) {
  if (value == null) {
    return '';
  }
  final DateTime local = value.toLocal();

  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

/// من 2026-09-22 إلى 22/09/2026
String formatDate(String? iso) {
  if (iso == null || iso.length < 10) {
    return iso ?? '';
  }
  final String date = iso.substring(0, 10);
  final List<String> parts = date.split('-');
  if (parts.length != 3) {
    return date;
  }

  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

/// عدّاد تنازلي: `03:12:44` — الساعات بلا سقف (قد تتجاوز 24).
String formatCountdown(Duration value) {
  final int total = value.isNegative ? 0 : value.inSeconds;
  final String hours = (total ~/ 3600).toString().padLeft(2, '0');
  final String minutes = ((total % 3600) ~/ 60).toString().padLeft(2, '0');
  final String seconds = (total % 60).toString().padLeft(2, '0');

  return '$hours:$minutes:$seconds';
}

String formatDateTime(DateTime? value) {
  if (value == null) {
    return '';
  }
  final DateTime local = value.toLocal();

  return '${formatDate(local.toIso8601String())} · ${formatTime(local)}';
}
