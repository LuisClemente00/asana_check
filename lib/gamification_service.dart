// Archivo: gamification_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'session_storage.dart';
import 'academy_progress_service.dart';

class GamificationService {
  static const String _xpKey = 'user_xp';

  /// Obtiene la experiencia acumulada (XP)
  static Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  /// Suma XP al usuario
  static Future<void> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentXP = await getXP();
    await prefs.setInt(_xpKey, currentXP + amount);
  }

  /// Calcula Nivel según XP
  static String getLevelName(int xp) {
    if (xp < 300) return "Yogui Novato 🌱";
    if (xp < 900) return "Buscador Zen 🧘";
    if (xp < 2000) return "Guerrero de Luz ⚔️";
    if (xp < 5000) return "Maestro de Asanas 🧘‍♂️";
    return "Iluminado 🌟";
  }

  /// Porcentaje de progreso de nivel (0.0 a 1.0)
  static double getLevelProgress(int xp) {
    if (xp < 300) return xp / 300;
    if (xp < 900) return (xp - 300) / 600;
    if (xp < 2000) return (xp - 900) / 1100;
    if (xp < 5000) return (xp - 2000) / 3000;
    return 1.0;
  }

  /// Devuelve los IDs de los logros desbloqueados evaluando las métricas reales
  static Future<List<String>> getUnlockedAchievements() async {
    final List<String> unlocked = [];

    final history = await SessionStorage.getSessionHistory();
    final streak = await SessionStorage.getStreak();
    final xp = await getXP();
    final completedLessons = await AcademyProgressService.getCompletedLessons();

    // 1. Primera sesión
    if (history.isNotEmpty) {
      unlocked.add('first_session');
    }

    // 2. Postura del árbol completada
    if (history.any((s) => s['asana'] == 'El Árbol')) {
      unlocked.add('tree_master');
    }

    // 3. Lecciones teóricas
    if (completedLessons.isNotEmpty) {
      unlocked.add('first_lesson');
    }
    if (completedLessons.length >= 5) {
      unlocked.add('scholar');
    }
    if (completedLessons.length >= 10) {
      unlocked.add('anatomist');
    }

    // 4. Módulo 1 completado (supone lecciones l1, l2, l3)
    if (completedLessons.containsAll(['l1', 'l2', 'l3'])) {
      unlocked.add('module1_complete');
    }

    // 5. Rachas
    if (streak >= 3) {
      unlocked.add('streak_3');
    }
    if (streak >= 7) {
      unlocked.add('streak_7');
    }

    // 6. Tiempo acumulado en segundos
    final totalSeconds = history.fold<int>(
      0,
      (sum, item) => sum + ((item['duration'] as int?) ?? 0),
    );
    if (totalSeconds >= 900) {
      unlocked.add('time_15m');
    }

    // 7. Posturas distintas practicadas
    final uniqueAsanas = history.map((s) => s['asana']).toSet();
    if (uniqueAsanas.length >= 3) {
      unlocked.add('all_asanas');
    }

    // 8. Horarios (Mañana / Noche)
    for (var session in history) {
      final dateStr = session['date'] as String?;
      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          if (date.hour < 9) unlocked.add('early_bird');
          if (date.hour >= 20) unlocked.add('night_owl');
        }
      }
    }

    // 9. XP
    if (xp >= 500) {
      unlocked.add('xp_500');
    }
    if (xp >= 1000) {
      unlocked.add('xp_1000');
    }

    return unlocked.toSet().toList(); // Retornamos sin duplicados
  }
}