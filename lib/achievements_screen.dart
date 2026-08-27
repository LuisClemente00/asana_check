// Archivo: achievements_screen.dart

import 'package:flutter/material.dart';
import 'gamification_service.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int requiredAmount;
  final String category; // 'Práctica', 'Estudio', 'Racha', 'Especial'

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredAmount,
    required this.category,
  });
}

class AchievementsScreen extends StatelessWidget {
  AchievementsScreen({super.key});

  final List<Achievement> achievements = [
    // --- BÁSICOS Y PRIMEROS PASOS ---
    Achievement(
      id: 'first_session',
      title: 'Primer Paso',
      description: 'Completa tu primera sesión de práctica en cámara',
      icon: '🧘‍♂️',
      requiredAmount: 1,
      category: 'Práctica',
    ),
    Achievement(
      id: 'tree_master',
      title: 'Enraizado',
      description: 'Mantén la postura del Árbol con buena alineación',
      icon: '🌳',
      requiredAmount: 1,
      category: 'Práctica',
    ),

    // --- ESTUDIO Y ACADEMIA ---
    Achievement(
      id: 'first_lesson',
      title: 'Estudiante Zen',
      description: 'Lee y completa tu primera lección teórica',
      icon: '📖',
      requiredAmount: 1,
      category: 'Estudio',
    ),
    Achievement(
      id: 'scholar',
      title: 'Erudito del Yoga',
      description: 'Estudia 5 lecciones teóricas en la Academia',
      icon: '🎓',
      requiredAmount: 5,
      category: 'Estudio',
    ),
    Achievement(
      id: 'module1_complete',
      title: 'Maestro de los Fundamentos',
      description: 'Completa todas las lecciones del Módulo 1',
      icon: '📜',
      requiredAmount: 3,
      category: 'Estudio',
    ),
    Achievement(
      id: 'anatomist',
      title: 'Anatomista Consciente',
      description: 'Lee y absorbe 10 lecciones teóricas',
      icon: '🧠',
      requiredAmount: 10,
      category: 'Estudio',
    ),

    // --- RACHAS Y CONSTANCIA ---
    Achievement(
      id: 'streak_3',
      title: 'Guerrero Constante',
      description: 'Alcanza una racha de 3 días consecutivos practicando',
      icon: '🔥',
      requiredAmount: 3,
      category: 'Racha',
    ),
    Achievement(
      id: 'streak_7',
      title: 'Disciplina de Hierro',
      description: 'Mantén la racha durante 7 días seguidos',
      icon: '⚡',
      requiredAmount: 7,
      category: 'Racha',
    ),

    // --- TIEMPO Y PRÁCTICA ---
    Achievement(
      id: 'time_15m',
      title: 'Inamovible como la Montaña',
      description: 'Acumula 15 minutos en alineación correcta',
      icon: '⏱️',
      requiredAmount: 900, // en segundos
      category: 'Práctica',
    ),
    Achievement(
      id: 'all_asanas',
      title: 'Yogui Polivalente',
      description: 'Practica 3 asanas distintas con el sensor',
      icon: '✨',
      requiredAmount: 3,
      category: 'Práctica',
    ),

    // --- HORARIOS Y HÁBITOS ---
    Achievement(
      id: 'early_bird',
      title: 'Madrugador Zen',
      description: 'Completa una sesión matutina antes de las 9:00 AM',
      icon: '🌅',
      requiredAmount: 1,
      category: 'Especial',
    ),
    Achievement(
      id: 'night_owl',
      title: 'Búho Nocturno',
      description: 'Practica y relájate después de las 8:00 PM',
      icon: '🌙',
      requiredAmount: 1,
      category: 'Especial',
    ),

    // --- EXPERIENCIA Y NIVEL ---
    Achievement(
      id: 'xp_500',
      title: 'Aspirante Avanzado',
      description: 'Acumula 500 Puntos de Experiencia (XP)',
      icon: '⭐',
      requiredAmount: 500,
      category: 'Especial',
    ),
    Achievement(
      id: 'xp_1000',
      title: 'Gran Maestro',
      description: 'Alcanza la cifra de 1,000 XP acumulados',
      icon: '👑',
      requiredAmount: 1000,
      category: 'Especial',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDF),
      appBar: AppBar(
        title: const Text(
          "Logros y Medallas",
          style: TextStyle(
            color: Color(0xFF2D3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3A3A)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadUserGamificationData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A7C59)),
            );
          }

          final unlockedIds =
              List<String>.from(snapshot.data?['unlocked'] ?? []);
          final currentXP = snapshot.data?['xp'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Tarjeta de Resumen XP ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🏆', style: TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$currentXP XP acumulados",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3A3A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${unlockedIds.length} de ${achievements.length} Logros Desbloqueados",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A8D8D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "Todos los Logros",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3A3A),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Grid de Logros ---
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    final isUnlocked = unlockedIds.contains(achievement.id);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: isUnlocked
                            ? Border.all(
                                color: const Color(0xFF4A7C59)
                                    .withValues(alpha: 0.3),
                                width: 1.5)
                            : Border.all(
                                color: Colors.grey.withValues(alpha: 0.2)),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: isUnlocked ? 1.0 : 0.35,
                            child: Text(
                              achievement.icon,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            achievement.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? const Color(0xFF2D3A3A)
                                  : const Color(0xFF7A8D8D),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            achievement.description,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.25,
                              color: isUnlocked
                                  ? const Color(0xFF4A5555)
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadUserGamificationData() async {
    final unlocked = await GamificationService.getUnlockedAchievements();
    final xp = await GamificationService.getXP();
    return {'unlocked': unlocked, 'xp': xp};
  }
}