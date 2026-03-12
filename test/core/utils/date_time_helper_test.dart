import 'package:community/core/utils/date_time_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeHelper.parseApiDateTime', () {
    test('interprets naive API datetimes as UTC when requested', () {
      final parsed = DateTimeHelper.parseApiDateTime(
        '2026-03-11 10:15:30',
        assumeUtcForNaiveDateTimes: true,
      );

      expect(parsed, isNotNull);
      expect(parsed!.toUtc(), DateTime.utc(2026, 3, 11, 10, 15, 30));
    });

    test('keeps date-only values as local calendar dates', () {
      final parsed = DateTimeHelper.parseApiDateTime(
        '2026-03-11',
        assumeUtcForNaiveDateTimes: true,
      );

      expect(parsed, isNotNull);
      expect(parsed!.year, 2026);
      expect(parsed.month, 3);
      expect(parsed.day, 11);
      expect(parsed.hour, 0);
      expect(parsed.minute, 0);
    });
  });

  group('DateTimeHelper.formatRelativeDateTime', () {
    test('formats recent timestamps as instant', () {
      final now = DateTime(2026, 3, 11, 12, 0, 0);
      final value = DateTime(2026, 3, 11, 11, 59, 45);

      expect(
        DateTimeHelper.formatRelativeDateTime(value, now: now),
        '\u00C0 l\'instant',
      );
    });

    test('clamps future timestamps instead of showing negative delays', () {
      final now = DateTime(2026, 3, 11, 12, 0, 0);
      final future = DateTime(2026, 3, 11, 12, 5, 0);

      expect(
        DateTimeHelper.formatRelativeDateTime(future, now: now),
        '\u00C0 l\'instant',
      );
    });
  });
}
