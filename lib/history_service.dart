// Archivo: history_service.dart

import 'session_storage.dart';

class HistoryService {
  /// Obtiene un conjunto con las fechas formateadas como "YYYY-MM-DD" en las que hubo práctica
  static Future<Set<String>> getPracticedDays() async {
    final history = await SessionStorage.getSessionHistory();
    final Set<String> practicedDays = {};

    for (var session in history) {
      if (session['timestamp'] != null) {
        final DateTime date = DateTime.parse(session['timestamp']);
        final String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        practicedDays.add(formattedDate);
      }
    }
    return practicedDays;
  }
}