class DateTimeHelper {
  static final RegExp _timezoneSuffixPattern = RegExp(
    r'(?:[zZ]|[+-]\d{2}:\d{2})$',
  );

  static DateTime? parseApiDateTime(
    dynamic value, {
    bool assumeUtcForNaiveDateTimes = false,
  }) {
    if (value == null) return null;

    if (value is DateTime) {
      return value.isUtc ? value.toLocal() : value;
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    final normalized = raw.replaceFirst(' ', 'T');
    final hasExplicitTimezone = _timezoneSuffixPattern.hasMatch(normalized);
    final looksLikeDateTime = normalized.contains('T');

    if (!hasExplicitTimezone &&
        looksLikeDateTime &&
        assumeUtcForNaiveDateTimes) {
      final utcParsed = DateTime.tryParse('${normalized}Z');
      if (utcParsed != null) return utcParsed.toLocal();
    }

    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return null;
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  static String formatDate(DateTime date) {
    final localDate = date.isUtc ? date.toLocal() : date;
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    return '$day/$month/$year';
  }

  static String formatRelativeDateTime(DateTime date, {DateTime? now}) {
    final localDate = date.isUtc ? date.toLocal() : date;
    final reference = now ?? DateTime.now();
    var diff = reference.difference(localDate);

    if (diff.isNegative) {
      diff = Duration.zero;
    }

    if (diff.inSeconds < 60) return '\u00C0 l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return formatDate(localDate);
  }
}
