// Archivo: gamification_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'session_storage.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}

class GamificationService {
  static const String _xpKey = 'user_xp';

  // Obtener la experiencia acumulada (XP)
  static Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  // Sumar XP (Ej: 1 segundo practicado = 1 XP, lección de academia = +50 XP)
  static Future<void> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentXP = await getXP();
    await prefs.setInt(_xpKey, currentXP + amount);
  }

  // Calcular Nivel según XP
  static String getLevelName(int xp) {
    if (xp < 300) return "Yogui Novato  🌱";
    if (xp < 900) return "Buscador Zen 🧘";
    if (xp < 2000) return "Guerrero de Luz ⚔️";
    if (xp < 5000) return "Maestro de Asanas 🧘‍♂️";
    return "Iluminado 🌟";
  }

  // Obtener porcentaje de progreso hacia el siguiente nivel (0.0 a 1.0)
  static double getLevelProgress(int xp) {
    if (xp < 300) return xp / 300;
    if (xp < 900) return (xp - 300) / 600;
    if (xp < 2000) return (xp - 900) / 1100;
    if (xp < 5000) return (xp - 2000) / 3000;
    return 1.0;
  }

  // Obtener lista de logros y verificar cuáles se han completado
  static Future<List<Achievement>> getAchievements() async {
    final history = await SessionStorage.getSessionHistory();
    final streak = await SessionStorage.getStreak();
    final xp = await getXP();

    final totalSessions = history.length;
    final hasTree = history.any((s) => s['asana'] == 'El Árbol');
    final hasWarrior = history.any((s) => s['asana'] == 'El Guerrero II');
    final hasPlank = history.any((s) => s['asana'] == 'La Plancha');

    return [
      Achievement(
        id: 'first_step',
        title: 'Primer Paso',
        description: 'Completa tu primera sesión de yoga',
        icon: '🐣',
        isUnlocked: totalSessions >= 1,
      ),
      Achievement(
        id: 'streak_3',
        title: 'Constancia Zen',
        description: 'Alcanza una racha de 3 días consecutivos',
        icon: '🔥',
        isUnlocked: streak >= 3,
      ),
      Achievement(
        id: 'tree_master',
        title: 'Raíces Fuertes',
        description: 'Completa la postura del Árbol',
        icon: '🌳',
        isUnlocked: hasTree,
      ),
      Achievement(
        id: 'warrior_spirit',
        title: 'Espíritu Guerrero',
        description: 'Completa la postura del Guerrero II',
        icon: '🛡️',
        isUnlocked: hasWarrior,
      ),
      Achievement(
        id: 'core_steel',
        title: 'Core de Acero',
        description: 'Completa la postura de La Plancha',
        icon: '⚡',
        isUnlocked: hasPlank,
      ),
      Achievement(
        id: 'xp_1000',
        title: 'Dedicación Absoluta',
        description: 'Acumula 1,000 puntos de XP',
        icon: '🏆',
        isUnlocked: xp >= 1000,
      ),
    ];
  }
}