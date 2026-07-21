// Archivo: session_storage.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'gamification_service.dart';

class SessionStorage {
  static const String _historyKey = 'session_history';
  static const String _streakKey = 'current_streak';
  static const String _lastPracticeDateKey = 'last_practice_date';

  // Guardar sesión, actualizar racha y otorgar XP
  static Future<void> saveSession(String asanaName, int seconds) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Guardar en el historial
    final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];
    final newSession = {
      'asana': asanaName,
      'seconds': seconds,
      'date': DateTime.now().toIso8601String(),
    };
    historyJson.insert(0, jsonEncode(newSession));
    await prefs.setStringList(_historyKey, historyJson);

    // 2. Actualizar la Racha (Streak)
    await _updateStreak(prefs);

    // 3. Otorgar XP (1 segundo = 1 XP + 50 XP bonus por completar)
    await GamificationService.addXP(seconds + 50);
  }

  static Future<void> _updateStreak(SharedPreferences prefs) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final String? lastDateStr = prefs.getString(_lastPracticeDateKey);
    int currentStreak = prefs.getInt(_streakKey) ?? 0;

    if (lastDateStr == null) {
      // Primera práctica de la historia
      currentStreak = 1;
      await prefs.setString(_lastPracticeDateKey, today.toIso8601String());
    } else {
      final lastDate = DateTime.parse(lastDateStr);
      final lastPracticeDay = DateTime(lastDate.year, lastDate.month, lastDate.day);

      final differenceInDays = today.difference(lastPracticeDay).inDays;

      if (differenceInDays == 1) {
        // Practicó ayer -> Incrementa racha
        currentStreak++;
        await prefs.setString(_lastPracticeDateKey, today.toIso8601String());
      } else if (differenceInDays > 1) {
        // Pasó más de un día -> Reinicia racha a 1
        currentStreak = 1;
        await prefs.setString(_lastPracticeDateKey, today.toIso8601String());
      }
      // Si differenceInDays == 0 (ya practicó hoy), la racha se mantiene igual.
    }

    await prefs.setInt(_streakKey, currentStreak);
  }

  // Obtener racha actual
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastDateStr = prefs.getString(_lastPracticeDateKey);

    if (lastDateStr == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime.parse(lastDateStr);
    final lastPracticeDay = DateTime(lastDate.year, lastDate.month, lastDate.day);

    // Si ha pasado más de 1 día sin entrenar, la racha expira a 0
    if (today.difference(lastPracticeDay).inDays > 1) {
      await prefs.setInt(_streakKey, 0);
      return 0;
    }

    return prefs.getInt(_streakKey) ?? 0;
  }

  // Obtener historial
  static Future<List<Map<String, dynamic>>> getSessionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];

    return historyJson.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList();
  }

  // Limpiar historial y progreso
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_streakKey);
    await prefs.remove(_lastPracticeDateKey);
  }
}