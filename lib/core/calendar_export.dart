/// Einfacher iCal-Export für Wochen-Zuweisungen (PRD P7 Kalender-Sync light).
abstract final class CalendarExport {
  static String buildVCalendar({
    required String familyName,
    required List<Map<String, dynamic>> assignmentRows,
  }) {
    final buf = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('CALSCALE:GREGORIAN')
      ..writeln('PRODID:-//Chore Chart//DE//');

    for (final row in assignmentRows) {
      final tpl = row['task_templates'];
      var title = 'Aufgabe';
      if (tpl is Map) title = tpl['title'] as String? ?? title;
      final due = row['due_date'] as String?;
      if (due == null || due.length < 10) continue;
      final id = row['id'] as String? ?? due;
      final ymd = due.replaceAll('-', '');
      buf
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:$id@chore-chart.local')
        ..writeln('DTSTAMP:${_utcStamp()}')
        ..writeln('DTSTART;VALUE=DATE:$ymd')
        ..writeln('SUMMARY:${_escapeText('$title ($familyName)')}')
        ..writeln('END:VEVENT');
    }
    buf.writeln('END:VCALENDAR');
    return buf.toString();
  }

  static String _utcStamp() {
    final u = DateTime.now().toUtc();
    return '${u.year.toString().padLeft(4, '0')}${u.month.toString().padLeft(2, '0')}${u.day.toString().padLeft(2, '0')}T'
        '${u.hour.toString().padLeft(2, '0')}${u.minute.toString().padLeft(2, '0')}${u.second.toString().padLeft(2, '0')}Z';
  }

  static String _escapeText(String s) {
    return s.replaceAll('\\', '\\\\').replaceAll(',', '\\,').replaceAll(';', '\\;').replaceAll('\n', '\\n');
  }
}
