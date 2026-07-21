// Archivo: academy_progress_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class AcademyProgressService {
  static const String _completedLessonsKey = 'completed_lessons';

  /// Obtiene el conjunto de IDs de lecciones completadas
  static Future<Set<String>> getCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(_completedLessonsKey);
    return list != null ? list.toSet() : {};
  }

  /// Marca una lección como completada
  static Future<void> completeLesson(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompletedLessons();
    completed.add(lessonId);
    await prefs.setStringList(_completedLessonsKey, completed.toList());
  }

  /// Verifica si una lección está desbloqueada
  static Future<bool> isLessonUnlocked(String lessonId, String? previousLessonId) async {
    if (previousLessonId == null) return true; // La primera lección siempre está abierta
    final completed = await getCompletedLessons();
    return completed.contains(previousLessonId);
  }
}